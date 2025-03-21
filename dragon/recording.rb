# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# recording.rb has been released under MIT (*only this file*).

module GTK
  # FIXME: Gross
  class Replay
    def self.start file_name = nil, speed: 1
      $recording.start_replay file_name, speed: speed
    end

    def self.stop
      $recording.stop_replay
    end
  end

  class Recording
    attr :should_reset_after_replay_completed

    def initialize runtime
      @runtime = runtime
      @global_input_order = 1
      @should_reset_after_replay_completed = true
    end

    def replay_callbacks_do_tick
      return if !is_replaying?
      if @on_replay_tick
        @on_replay_tick.calls @runtime.args
      end

      if @on_replay_tick_only_this_run
        @on_replay_tick_only_this_run.call @runtime.args
      end
    end

    def tick_before
      if @replay_next_tick && !is_replaying?
        @replay_next_tick = nil
        start_replay @replay_next_tick_file_name, speed: @replay_next_tick_simulation_speed
        @replay_next_tick_simulation_speed = nil
      end

      stage_replay_values
    end

    def tick_after
      replay_callbacks_do_tick
    end

    def on_replay_tick &block
      @on_replay_tick = block
    end

    def on_recording_tick &block
      @on_recording_tick = block
    end

    def start_recording seed_number = nil, rng_seed: nil, simulation_speed: nil
      seed_number ||= rng_seed
      if !seed_number
        log <<-S
* ERROR:
To start recording, you must provide an integer value to
seed random number generation.
S
        $console.set_command "$recording.start rng_seed: 100"
        return
      end

      if @is_recording
        log <<-S
* ERROR:
You are already recording, first cancel (or stop) the current recording.
S
        $console.set_command "$recording.cancel"
        return
      end

      if @is_replaying
        log <<-S
* ERROR:
You are currently replaying a recording, first stop the replay.
S
        return
      end

      log_info <<-S
Recording has begun with RNG seed value set to #{seed_number}.
To stop recording use stop_recording(filename).
The recording will stop without saving a file if a filename is nil.
S
      $console.set_command_extended histories: ["$recording.start #{seed_number}"],
                                    command: "$recording.stop 'replay.txt'"
      @keys_to_ignore_during_recording = $console.console_toggle_keys.map { |k| k.without_ending_bang }
      @is_recording = true
      @runtime.__reset__
      @seed_number = seed_number
      @runtime.simulation_speed = simulation_speed if simulation_speed
      @runtime.set_rng seed_number

      @global_input_order = 1
      @input_history = []
      @runtime.notify! "Recording started. When completed, open the console to save it using $recording.stop FILE_NAME (or cancel).", 300
    end

    def start seed_number = nil, rng_seed: nil, simulation_speed: nil
      start_recording seed_number, rng_seed: rng_seed, simulation_speed: simulation_speed
    end

    def is_replaying?
      !!@is_replaying
    end

    def is_recording?
      !!@is_recording
    end

    def stop file_name = nil
      stop_recording file_name
    end

    def cancel
      stop_recording_core
      @runtime.notify! "Recording cancelled."
    end

    def stop_recording file_name = nil
      if !file_name
        log <<-S
* ERROR:
To please specify a file name when calling:
$recording.stop FILE_NAME

If you do NOT want to save the recording, call:
$recording.cancel
S
        $console.set_command "$recording.stop 'replay.txt'"
        return
      end

      if !@is_recording
        log_info "You are not currently recording. Use start_recording(seed_number) to start recording."
        $console.set_command "$recording.start"
        return
      end

      if file_name
        stopped_at = Kernel.tick_count
        # if the last input was ignored, then we want to set stopped at to the point in time before the last input was ignored.
        if @last_recorded_input_was_ignored
          stopped_at -= stopped_at - @last_recorded_input_was_ignored_at
        end
        text = "replay_version 2.1\n"
        text << "stopped_at #{stopped_at}\n"
        text << "seed #{@seed_number}\n"
        text << "recorded_at #{Time.now.to_s}\n"
        @input_history.each do |items|
          text << "#{items}\n"
        end
        @runtime.write_file file_name, text
        @runtime.write_file 'last_replay.txt', text
        log_info "The recording has been saved successfully at #{file_name}. You can use start_replay(\"#{file_name}\") to replay the recording."
      end

      $console.set_command "$replay.start '#{file_name}', speed: 1"
      stop_recording_core
      @runtime.notify! "Recording saved to #{file_name}. To replay it: ~$replay.start \"#{file_name}\", speed: 1~."
      log_info "You can run the replay later on startup using: ./dragonruby mygame --replay #{@replay_file_name}"
      @recording_stopped_at = Kernel.global_tick_count
      nil
    end

    def recording_recently_completed?
      return false if !@recording_stopped_at
      (Kernel.global_tick_count - @recording_stopped_at) <= 5
    end

    def on_replay_completed_successfully &block
      @replay_completed_successfully_block = block
    end

    def stop_recording_core
      @is_recording = false
      @input_history = nil
      @last_history = nil
      @runtime.__reset__
    end

    def replay_completed_successfully?
      @replay_completed_successfully
    end

    def __deserialize_replay_value__ value
      return value if !value
      return value.gsub('"', '') if value.start_with? '"'
      return value.gsub(':', '').to_sym if value.start_with? ':'
      return value == 'true' if value == 'true' || value == 'false'
      return value.to_f
    end

    def start_replay file_name = nil, speed: 1
      return if replay_recently_stopped?
      @exception_in_completed_successfully_block = nil
      @replay_completed_successfully = false
      if !file_name
        log <<-S
* ERROR:
Please provide a file name to $recording.start.
S
        $console.set_command_silent "$replay.start 'replay.txt', speed: 1"
        return
      end

      text = @runtime.read_file file_name
      return false unless text

      replay_version = text.each_line.first.strip.gsub("replay_version ", "")

      if replay_version != "2.0" && replay_version != "2.1"
        raise "The replay file #{file_name} is not compatible with this version of DragonRuby Game Toolkit. Please recreate the replay (sorry)."
      end

      @replay_started_at = Kernel.global_tick_count
      @replay_file_name = file_name

      $replay_data = {
        input_history: { },
        stopped_at_current_tick: -1
      }

      # the replay file is a text file with the following format:
      # replay_version 2.0 (the version of the replay file)
      # stopped_at 123456789 (tick count when the recording was stopped)
      # seed 123456789 (rng seed that was used to record the replay)
      # recorded_at 2019-01-01 12:00:00 -0500 (date and time when the recording was created)
      # inputs recorded as an array (delimited by new lines)
      # all record inputs have 6 entires except for mouse wheel which can have 6 or 7 entries (new parameters were added)
      # example:
      #   for entries with 6 parameters:
      #   [function_called, parameter_1, parameter_2 (if applicable), parameter count (1 or 2), input order, tick count]
      #   [:mouse_button_up, 1, 0, 1, 1, 3]
      #
      #   for entries with 7 parameters:
      #   [function_called, parameter_1, parameter_2 (if applicable), parameter_3 (if applicable), parameter count (always 3), input order, tick count]
      #   [:mouse_wheel, 1, 0, 1, 1, 3]
      text.each_line do |l|
        if l.strip.length == 0
          next
        elsif l.start_with? 'replay_version'
          next
        elsif l.start_with? 'seed'
          $replay_data[:seed] = l.split(' ').last.to_i
        elsif l.start_with? 'stopped_at'
          $replay_data[:stopped_at] = l.split(' ').last.to_i
        elsif l.start_with? 'recorded_at'
          $replay_data[:recorded_at] = l.split(' ')[1..-1].join(' ')
        elsif l.start_with? '['
          # this is the logic to parse the array of inputs
          items = l.strip.gsub('[', '').gsub(']', '').split(',').map(&:strip)

          # item 0 is the function name
          name        = __deserialize_replay_value__ items[0]
          value_1     = nil
          value_2     = nil
          value_3     = nil
          value_count = 0
          id          = 0
          tick_count  = 0

          # if the name is mouse_wheel, handle the 6 or 7 parameter case (6 parameters is the old format)
          if name == :mouse_wheel
            # always set the number of parameters for mouse wheel to 3
            value_count = 3

            # value_3 is nil if there are only 6 parameters
            if items.length == 6
              # when destructoring items, we don't need the name (first item) or the value_count (4th item)
              _, value_1, value_2, _, id, tick_count = items
              value_3 = nil
            elsif items.length == 7
              # when destructoring items, we don't need the name (first item) or the value_count (4th item)
              _, value_1, value_2, value_3, _, id, tick_count = items
            else
              raise "Unable to parse replay entry #{l.strip}. Expected 6 or 7 values for mouse_wheel."
            end
          elsif items.length == 6
            # general case for 6 parameters
            _, value_1, value_2, value_count, id, tick_count = items
            value_3 = nil
          elsif items.length == 7
            # general case for 7 parameters
            _, value_1, value_2, value_3, value_count, id, tick_count = items
          else
            raise "Unable able to parse replay entry #{l.strip}. Expected 6 or 7 values."
          end

          # deserialize the string value into the correct type
          value_1 = __deserialize_replay_value__ value_1
          value_2 = __deserialize_replay_value__ value_2
          value_3 = __deserialize_replay_value__ value_3

          # create a dictionary entry for the input
          $replay_data[:input_history][tick_count.to_i] ||= []
          $replay_data[:input_history][tick_count.to_i] << {
            id: id.to_i,
            name: name,
            value_1: value_1,
            value_2: value_2,
            value_3: value_3,
            value_count: value_count.to_i
          }

          # added scancodes and changed args.inputs.left_right's implementation to look for
          # (w|a|s|d)_scancode instead of (w|a|s|d). because of this replay versions 2.0 need to insert
          # a scancode entry for key_(down|up)_raw wasd
          if replay_version == "2.0"
            if name == :key_down_raw || name == :key_up_raw
              scancode_name = if name == :key_down_raw
                                :scancode_down_raw
                              else
                                :scancode_up_raw
                              end

              scancode_value_1 = if value_1 == 119 # ascii w
                                   26
                                 elsif value_1 == 97 # ascii a
                                   4
                                 elsif value_1 == 115 # ascii s
                                   22
                                 elsif value_1 == 100 # ascii d
                                   7
                                 else
                                   nil
                                 end

              if scancode_value_1
                $replay_data[:input_history][tick_count.to_i] << {
                  id: id.to_i,
                  name: scancode_name,
                  value_1: scancode_value_1,
                  value_2: value_2,
                  value_3: value_3,
                  value_count: value_count.to_i
                }
              end
            end
          end
        else
          raise "Replay data seems corrupt. I don't know how to parse #{l}."
        end
      end

      $replay_data[:input_history].keys.each do |key|
        $replay_data[:input_history][key] = $replay_data[:input_history][key].sort_by {|input| input[:id]}
      end

      @runtime.__reset__
      @runtime.set_rng $replay_data[:seed]
      @is_replaying = true
      if speed
        speed = speed.clamp(1, 60)
        @runtime.simulation_speed = speed
      end
      log_info "Replay started =#{@replay_file_name}= speed: #{@runtime.simulation_speed}. (#{Kernel.global_tick_count})"
      @runtime.notify! "Replay started =#{@replay_file_name}= speed: #{@runtime.simulation_speed}."
    end

    def replay_next_tick file_name, speed: 1, &block
      log <<-S
* INFO - Replay queued for next tick for file_name: =#{file_name}=, speed: ~#{speed}~.
** Caller
#{caller.map { |l| "*** #{l}" }.join "\n"}
S
      @replay_next_tick = true
      @replay_next_tick_file_name = file_name
      @on_replay_tick_only_this_run = block
      if speed
        speed = speed.clamp(1, 60)
        @replay_next_tick_simulation_speed = speed
      end
    end

    alias_method :start_replay_next_tick, :replay_next_tick

    def replay_completed_at
      @replay_completed_at
    end

    def replay_stopped_at
      @replay_stopped_at
    end

    def replay_recently_started?
      return false if !@replay_started_at
      (Kernel.global_tick_count - @replay_started_at) <= 5
    end

    def replay_recently_stopped?
      return false if !@replay_stopped_at
      (Kernel.global_tick_count - @replay_stopped_at) <= 5
    end

    def replay_recently_completed?
      return false if !@replay_completed_at
      (Kernel.global_tick_count - @replay_completed_at) <= 5
    end

    def clear_replay_stopped_at!
      @replay_stopped_at = nil
    end

    def stop_replay notification_message = "Replay has been stopped."
      @runtime.simulation_speed = 1
      if !is_replaying?
        log <<-S
* ERROR:
No replay is currently running. Call ~$replay.start FILE_NAME, speed: 1~ to start a replay.
S

        $console.set_command "$replay.start 'replay.txt', speed: 1"
        return
      end
      log_info "#{notification_message} (#{Kernel.global_tick_count})"
      $replay_data = nil
      @global_input_order = 1
      @replay_stopped_at = Kernel.global_tick_count
      $console.set_command_silent "$replay.start '#{@replay_file_name}', speed: 1"
      @is_replaying = false
      @on_replay_tick_only_this_run = nil


      if @exception_in_completed_successfully_block
        log "* ERROR: Exception was raised when on_replay_completed_successfully's callback was invoked."
        raise @exception_in_completed_successfully_block
      else
        @runtime.__reset__ if @should_reset_after_replay_completed
      end

      @runtime.notify! notification_message
    end

    def record_input? name, raw_key, modifier_keys
      return false if $gtk.console.visible?
      return false if @is_replaying
      return false unless @is_recording
      # do not record console activation
      if name == :key_up_raw || name == :key_down_raw
        names = KeyboardKeys.sdl_to_key raw_key, modifier_keys
        return false if (names & @keys_to_ignore_during_recording).length > 0
        return false if @input_history.length == 0 && names.include?(:enter)
      end
      return true
    end

    # these values are used later to determine if the replay length should be shortened
    # (for example if the last bits of the replay were in the console/wouldn't be recorded)
    def capture_record_input_timestamps name, raw_key, modifier_keys
      if !record_input? name, raw_key, modifier_keys
        @last_recorded_input_was_ignored_at ||= Kernel.tick_count
        @last_recorded_input_was_ignored ||= true
      else
        @last_recorded_input_was_ignored_at = nil
        @last_recorded_input_was_ignored = nil
      end
    end

    # 1 or 2 params
    def record_input_history name, value_1, value_2, value_count, clear_cache = false
      capture_record_input_timestamps name, value_1, value_2
      return if !record_input? name, value_1, value_2
      @input_history << [name, value_1, value_2, value_count, @global_input_order, Kernel.tick_count]
      @global_input_order += 1
    end

    def record_input_history_3_params name, value_1, value_2, value_3, clear_cache = false
      capture_record_input_timestamps name, value_1, value_2
      return if !record_input? name, value_1, value_2
      @input_history << [name, value_1, value_2, value_3, 3, @global_input_order, Kernel.tick_count]
      @global_input_order += 1
    end

    def stage_replay_values
      return unless @is_replaying
      return unless $replay_data

      if ($replay_data[:stopped_at] - $replay_data[:stopped_at_current_tick]) <= 1
        @replay_completed_successfully = true
        log_info "Checking callback provided by ~GTK.recording.on_replay_completed_successfully(&block)~."
        if @replay_completed_successfully_block
          begin
            log_info "Callback found. Invoking ~callback.call(args)~."
            @replay_completed_successfully_block.call @runtime.args
          rescue Exception => e
            @exception_in_completed_successfully_block = e
          end
        else
          log_info "No callback found."
        end

        @replay_completed_at = Kernel.global_tick_count
        stop_replay "Replay completed [#{@replay_file_name}]. To rerun, bring up the Console and press enter."
        @runtime.simulation_speed = 1
        return
      end

      inputs_this_tick = $replay_data[:input_history][$replay_data[:stopped_at_current_tick]]
      if Kernel.global_tick_count.zmod?(60 * @runtime.simulation_speed)
        calculated_tick_count = ($replay_data[:stopped_at] + @replay_started_at) - Kernel.global_tick_count
        log_info "Replay ends in #{calculated_tick_count.idiv(60 * @runtime.simulation_speed)} second(s). (#{Kernel.global_tick_count})"
      end

      $replay_data[:stopped_at_current_tick] += 1

      return unless inputs_this_tick

      inputs_this_tick.each do |v|
        args = []
        args << v[:value_1] if v[:value_count] >= 1
        args << v[:value_2] if v[:value_count] >= 2
        args << v[:value_3] if v[:value_count] >= 3
        args << :replay
        $gtk.send v[:name], *args
      end
    end
  end
end
