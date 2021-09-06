# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# recording.rb has been released under MIT (*only this file*).

module GTK
  # FIXME: Gross
  # @gtk
  class Replay
    # @gtk
    def self.start file_name = nil
      $recording.start_replay file_name
    end

    # @gtk
    def self.stop
      $recording.stop_replay
    end
  end

  # @gtk
  class Recording
    def initialize runtime
      @runtime = runtime
      @tick_count = 0
      @global_input_order = 1
    end

    def tick
      @tick_count += 1
    end

    def start_recording seed_number = nil
      if !seed_number
        log <<-S
* ERROR:
To start recording, you must provide an integer value to
seed random number generation.
S
        $console.set_command "$recording.start SEED_NUMBER"
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

      $console.set_command "$recording.stop 'replay.txt'"
      @runtime.__reset__
      @seed_number = seed_number
      @runtime.set_rng seed_number

      @tick_count = 0
      @global_input_order = 1
      @is_recording = true
      @input_history = []
      @runtime.notify! "Recording started. When completed, open the console to save it using $recording.stop FILE_NAME (or cancel).", 300
    end

    # @gtk
    def start seed_number = nil
      start_recording seed_number
    end

    def is_replaying?
      @is_replaying
    end

    def is_recording?
      @is_recording
    end

    # @gtk
    def stop file_name = nil
      stop_recording file_name
    end

    # @gtk
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
        text = "replay_version 2.0\n"
        text << "stopped_at #{@tick_count}\n"
        text << "seed #{@seed_number}\n"
        text << "recorded_at #{Time.now.to_s}\n"
        @input_history.each do |items|
          text << "#{items}\n"
        end
        @runtime.write_file file_name, text
        @runtime.write_file 'last_replay.txt', text
        log_info "The recording has been saved successfully at #{file_name}. You can use start_replay(\"#{file_name}\") to replay the recording."
      end

      $console.set_command "$replay.start '#{file_name}'"
      stop_recording_core
      @runtime.notify! "Recording saved to #{file_name}. To replay it: $replay.start \"#{file_name}\"."
      log_info "You can run the replay later on startup using: ./dragonruby mygame --replay #{@replay_file_name}"
      nil
    end

    def stop_recording_core
      @is_recording = false
      @input_history = nil
      @last_history = nil
      @runtime.__reset__
    end

    def start_replay file_name = nil
      if !file_name
        log <<-S
* ERROR:
Please provide a file name to $recording.start.
S
        $console.set_command "$replay.start 'replay.txt'"
        return
      end

      text = @runtime.read_file file_name
      return false unless text

      if text.each_line.first.strip != "replay_version 2.0"
        raise "The replay file #{file_name} is not compatible with this version of DragonRuby Game Toolkit. Please recreate the replay (sorry)."
      end

      @replay_file_name = file_name

      $replay_data = { input_history: { } }
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
          name, value_1, value_2, value_count, id, tick_count = l.strip.gsub('[', '').gsub(']', '').split(',')
          $replay_data[:input_history][tick_count.to_i] ||= []
          $replay_data[:input_history][tick_count.to_i] << {
            id: id.to_i,
            name: name.gsub(':', '').to_sym,
            value_1: value_1.to_f,
            value_2: value_2.to_f,
            value_count: value_count.to_i
          }
        else
          raise "Replay data seems corrupt. I don't know how to parse #{l}."
        end
      end

      $replay_data[:input_history].keys.each do |key|
        $replay_data[:input_history][key] = $replay_data[:input_history][key].sort_by {|input| input[:id]}
      end

      @runtime.__reset__
      @runtime.set_rng $replay_data[:seed]
      @tick_count = 0
      @is_replaying = true
      log_info "Replay has been started."
      @runtime.notify! "Replay started [#{@replay_file_name}]."
    end

    def stop_replay notification_message =  "Replay has been stopped."
      if !is_replaying?
        log <<-S
* ERROR:
No replay is currently running. Call $replay.start FILE_NAME to start a replay.
S

        $console.set_command "$replay.start 'replay.txt'"
        return
      end
      log_info notification_message
      @is_replaying = false
      $replay_data = nil
      @tick_count = 0
      @global_input_order = 1
      $console.set_command_silent "$replay.start '#{@replay_file_name}'"
      @runtime.__reset__
      @runtime.notify! notification_message
    end

    def record_input_history name, value_1, value_2, value_count, clear_cache = false
      return if @is_replaying
      return unless @is_recording
      @input_history << [name, value_1, value_2, value_count, @global_input_order, @tick_count]
      @global_input_order += 1
    end

    def stage_replay_values
      return unless @is_replaying
      return unless $replay_data

      if $replay_data[:stopped_at] <= @tick_count
        stop_replay "Replay completed [#{@replay_file_name}]. To rerun, bring up the Console and press enter."
        return
      end

      inputs_this_tick = $replay_data[:input_history][@tick_count]

      if @tick_count.zmod? 60
        log_info "Replay ends in #{($replay_data[:stopped_at] - @tick_count).idiv 60} second(s)."
      end

      return unless inputs_this_tick
      inputs_this_tick.each do |v|
        args = []
        args << v[:value_1] if v[:value_count] >= 1
        args << v[:value_2] if v[:value_count] >= 2
        args << :replay
        $gtk.send v[:name], *args
      end
    end
  end
end
