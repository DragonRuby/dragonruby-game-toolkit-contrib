# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# runtime.rb has been released under MIT (*only this file*).

module FFI
  class Draw
    def serialize
      "#{self}"
    end

    def inspect
      "#{self}"
    end

    def to_s
      ""
    end
  end
end

module GTK
  class RemoteHotloadClientWrapper
    attr :remote_hotload_client

    def initialize runtime
      @runtime = runtime
    end

    def start
      return if @remote_hotload_client
      # !!! FIXME: should we migrate this to a cvar?
      server_ip_address   = $gtk.read_file "metadata/dragonruby_remote_hotload"
      server_ip_address ||= ""
      server_ip_address.strip!
      @remote_hotload_client = RemoteHotloadClient.new server_ip_address, $cvars['webserver.port'].value
    end

    def tick
      return unless @remote_hotload_client
      @remote_hotload_client.args = @runtime.args
      @remote_hotload_client.tick
    end
  end

  class Runtime
    include CBridge
    include Deprecated
    include Hotload
    include Framerate
    include Draw
    include DrawVR
    include AsyncRequire
    include Autocomplete
    include SaveStateLoadState
    include Notify
    include ProcessARGSV
    include AutoTest
    include Logging

    attr_accessor :argv,
                  :required_files, :files_reloaded, :paused, :time_per_tick, :reloaded_files,
                  :scheduled_callbacks,
                  :suppress_hotload,
                  :reload_list_history, :simulation_speed, :started_at, :production,
                  :__state_assigned_to_hash_on_boot__, :rng_seed, :hotload_global_at,
                  :__sdl_tick_too_early_count__


    attr_reader :ffi_file, :ffi_mrb, :ffi_misc, :input_history, :recording, :console, :reserved_primitives,
                :ffi_draw, :args, :controller_config, :logical_width, :logical_height,
                :device_width, :device_height,
                :binary_path, :current_framerate_render, :current_framerate_calc, :sdl_tick, :vrmode, :y_offset,
                :remote_hotload_client_wrapper, :orientation, :mouse_grab, :last_reset_global_at, :require_stack,
                :debug_require, :remote_hotload_enabled, :current_thermal_state, :reboot_requested, :capture_timings_data

    def initialize platform, production, vrmode, logical_width, logical_height, argv, binary_path, y_offset, orientation, remote_hotload_enabled, a11y_enabled
      @__sdl_tick_too_early_count__ = 0
      @__pending_log_entry_count__ = 0
      @core_modules = []
      @user_modules = []
      if !production
        ObjectSpace.each_object(Module) do |klass|
          @core_modules << klass
        end
      end
      $gtk = self if $gtk.nil?
      $runtime = self if $runtime.nil?
      @binary_path = binary_path.strip
      @log_level = :on
      @platform = platform
      @production = production
      @vrmode = vrmode
      @argv = argv.strip
      @ffi_file = FFI::File.new
      @ffi_misc = FFI::Misc.new
      @ffi_mrb = FFI::MRB.new
      @ffi_draw = FFI::Draw.new
      # @remote_hotload_enabled = remote_hotload_enabled
      # !!! FIXME: currently this does not look at CVARS (ios_wizard isn't part of dragonruby_publish)
      @remote_hotload_enabled = read_file "metadata/dragonruby_remote_hotload"
      @orientation = orientation
      @device_width, @device_height = @ffi_misc.device_size
      @logical_width = logical_width
      @logical_height = logical_height
      @required_files ||= []
      @files_reloaded ||= []
      @reserved_primitives ||= []
      @key_up_queue = []
      @replay_autoload_check_ran = false
      @recording = Recording.new self
      @console = Console.new
      @tests = Tests.new
      @args = Args.new self, @recording
      @args.inputs.touch_enabled = @ffi_misc.touch_enabled?
      @args.inputs.locale_raw = @ffi_misc.get_locale
      @args.inputs.locale = @args.inputs.locale_raw || "en"
      @quit_requested = false
      @rcb_release_mode = ((@ffi_file.read 'dragon/top_level.rb') || "").strip.length == 0
      @is_steam_release =  if @ffi_file.stat('metadata/dragonruby_steam_build')
                             true
                           else
                             false
                           end
      @sound_queue = []    # !!! FIXME: part of legacy audio API...deprecate and remove this.
      @scheduled_callbacks = {}
      @http_requests = []
      @controller_config = Controller::Config.new self
      @slowmo_factor = 1
      @speedup_factor = 1
      @load_status = :dragonruby_started
      @cursor_shown = true
      @current_framerate_calc = 60
      @current_framerate_render = 60
      @current_touch_count = 0
      @current_touch_count_changed_at = 0
      @current_touch_count_changed_global_at = 0
      @mouse_grab = 0
      @y_offset = y_offset
      @last_reset_global_at = 0
      @last_reload_complete_global_at = 0
      @require_stack = []
      @started_at = Time.now.to_i
      @rng_seed = @started_at
      @reset_via_ctrl_r = true
      @current_thermal_state = nil
      @render_targets_to_reset = []
      @a11y_emulation = A11yEmulation.new self
      @a11y_enabled = a11y_enabled
      @capture_timings_data = {}
      @hotload_global_at = -1

      if !@rcb_release_mode
        $warn_array_primitives = true
        $gtk.log_warn("WARNING: YOU ARE IN AN UNOPTIMIZED DEV MODE.", "Engine")
      end
      @api = Api.new
      hotload_init
      framerate_init
      async_require_init
      __reset__
      $recording ||= @recording
      $replay    ||= Replay
      $console   ||= @console
      $args      ||= @args
      $state     ||= @args.state
      $grid      ||= @args.grid
      $geometry  ||= GTK::Geometry
      $tests     ||= @tests
      $wizards   ||= @args.wizards
      $fn        ||= @args.fn
      $api       ||= @api
      $layout    ||= @args.layout
      $log       ||= GTK::Log
      $inputs    ||= $args.inputs
      $outputs   ||= $args.outputs
      $audio     ||= $args.audio
      $nil_punning_disabled = false
      $trace_puts = nil
      $remote_hotload_client = nil

      if @ffi_file.stat 'logs/puts.txt'
        $gtk.write_file_root 'logs/puts.txt', "Contents moved to =logs/puts.log="
      end

      $gtk.write_file_root 'logs/puts.log', <<~S
      * INFO - If you need to find rogue puts statements do:
      #+begin_src
        def tick args
          # adding the following line to the TOP of your tick method
          # will print ~caller~ along side each ~puts~ statement
          $gtk.trace_puts!
        end
      #+end_src
      S

      if @ffi_file.stat 'logs/log.txt'
        $gtk.write_file_root 'logs/log.txt', "Contents moved to =logs/all.log="
      end

      disable_console! if platform?(:mobile) && @production && !@remote_hotload_enabled
      @core_global_variables = if !@production
                                 global_variables
                               else
                                 []
                               end
    end

    def reboot
      return if @production
      return if Kernel.global_tick_count == -1
      @reboot_requested = true
    end

    def purge_user_global_variables
      return if @production
      global_variables.each do |var|
        if !@core_global_variables.include? var
          puts "setting #{var} to nil"
          var_name = var.to_s
          eval("#{var_name} = nil")
        end
      end
    end

    def purge_user_modules
      return if @production
      $gtk.ivar(:user_modules).each do |klass|
        puts "purging #{klass.name}"
        Object.purge_class klass
      rescue Exception => e
        log_warning "Failed to purge #{klass.name}. Skipping...\n#{e}"
      end
    end

    def production?
      @production
    end

    def register_cvar name, desc, type, deflt
      $gtk.ffi_misc.cvar_register(name, desc, type.to_s, deflt.to_s)  # returns bool on whether it succeeded, then it'll be a CVar object in the args.cvars hash. If this was already set, it'll take the pending value. Otherwise, deflt.
    end

    def is_vr
      return @vrmode > 0
    end

    def reload_history
      @reload_list_history
    end

    def reload_history_pending
      @reload_list_history.find_all do |k, v|
        v[:current][:event] != :reload_completed
      end
    end

    def cli_arguments
      @cli_arguments ||= @argv.split(" --").map do |arg_pair|
        tokens = arg_pair.split " "
        rest = (tokens.rest || "").join(" ").strip
        if rest.length == 0
          rest = nil
        end
        first_token = tokens.first
        if tokens.first.include?('dragonruby')
          first_token = :dragonruby
          rest ||= 'mygame'
          rest = '' if rest == './'
        else
          first_token = tokens.first.to_sym
        end
        [first_token, rest]
      end.reject_nil.pairs_to_hash

      @cli_arguments
    end

    def reset_touch_count
      @current_touch_count = 0
      @current_touch_count_changed_at = Kernel.tick_count
      @current_touch_count_changed_global_at = Kernel.global_tick_count
    end

    def increase_touch_count
      retval = @current_touch_count
      @current_touch_count += 1
      @current_touch_count_changed_at = Kernel.tick_count
      @current_touch_count_changed_global_at = Kernel.global_tick_count
      retval
    end

    def quit!
      if cli_arguments.keys.include?(:record) && @recording.is_recording?
        @recording.stop_recording "replay_#{Time.now.to_i}.txt"
      end
      @console.save_history

      # Make a copy because r.reject deletes from @http_requests.
      @http_requests.clone.each { |r| r.reject }
    end

    def request_quit
      log_info "* INFO: Quit requested (#{Kernel.global_tick_count}).", subsystem="Engine"
      @quit_requested = true
    end

    def request_quit_fatal reason
      @ffi_misc.request_quit_fatal reason
    end

    def quit_requested?
      @quit_requested
    end

    def debug_require!
      return if @debug_require
      @debug_require = true
      log "* REQUIRE DEBUG: ~$gtk.debug_require!~ enabled in =#{@require_stack.last || "app/main.rb"}=."
    end

    def __require_sync__ path
      @require_history ||= {}
      return if @require_history[path] == Kernel.global_tick_count
      @require_history[path] = Kernel.global_tick_count
      @require_stack.push path
      @require_stack.uniq!
      reload_requested_ruby_files_synchronously
      @require_stack.pop
    end

    def get_require_metadata file
      file_path_with_rb_extension = if file.end_with?(".rb")
                                      file
                                    elsif file.end_with?(".rbc")
                                      file.gsub(".rbc", ".rb")
                                    else
                                      "#{file}.rb"
                                    end

      file_path_with_rbc_extension = "#{file_path_with_rb_extension}c"
      file_with_rb_extension_exist = @ffi_file.path_exists(file_path_with_rb_extension)
      file_with_rbc_extension_exist = @ffi_file.path_exists(file_path_with_rbc_extension)
      file_exist = file_with_rb_extension_exist || file_with_rbc_extension_exist
      output_file = file_with_rbc_extension_exist ? file_path_with_rbc_extension : file_path_with_rb_extension

      {
        input_file: file,
        file_exist: file_exist,
        file_path_with_rb_extension: file_path_with_rb_extension,
        file_path_with_rbc_extension: file_path_with_rbc_extension,
        file_with_rb_extension_exist: file_with_rb_extension_exist,
        file_with_rbc_extension_exist: file_with_rbc_extension_exist,
        output_file: output_file,
      }
    end

    class LoadError < Exception
      attr :inner_exception, :path

      def initialize path, inner_exception, message
        super(message)
        @path = path
        @inner_exception = inner_exception
      end
    end

    def disable_reset_via_ctrl_r
      @reset_via_ctrl_r = false
    end

    def enable_reset_via_ctrl_r
      @reset_via_ctrl_r = true
    end

    def disable_console
      $gtk.disable_reset_via_ctrl_r
      @console.disable
    end

    def disable_console!
      disable_console
    end

    def enable_console
      @console.enable
    end

    def enable_console!
      enable_console
    end

    def show_console reason = nil
      @console.show reason
    end

    def hide_console
      @console.hide
    end

    def start_replay file_name = nil, speed: nil
      file_name ||= 'last_replay.txt'
      @console.hide if read_file file_name
      @recording.start_replay file_name, speed: nil
    end

    def reset_and_replay file_name = nil, speed: 1, force: false, &block
      if !force
        return if @production
      end

      $gtk.slowmo! 1, false
      if paused? && @recording.is_replaying?
        unpause!
        return
      end

      if @reset_and_replay_inside_tick_raise_exception
        @reset_and_replay_inside_tick_raise_exception = false
        return
      end

      if inside_tick?
        @reset_and_replay_inside_tick_raise_exception = true
        raise <<-S
* ERROR: Can't call reset_and_replay inside tick.
The ~reset_and_replay~ method is designed to be called
outside of tick. For example:

#+begin_src
  def tick args
    ...
  end

  GTK.reset_and_replay
#+end_src
S
      end

      return if Kernel.global_tick_count < 60
      return if @recording.is_recording?
      return if @recording.recording_recently_completed?
      return if @recording.replay_recently_completed?
      return if @recording.replay_recently_started?

      if @recording.is_replaying? && !@recording.replay_recently_started?
        @recording.stop_replay
        @recording.clear_replay_stopped_at!
      end

      file_name ||= 'last_replay.txt'
      reset
      @simulation_speed = speed
      @recording.replay_next_tick file_name, speed: speed, &block
    end

    def stop_replay
      @recording.stop_replay
    end

    def start_recording seed_value
      @console.hide
      @recording.start_recording seed_value
    end

    def set_rng value
      @rng_seed = value if value
      srand @rng_seed
      log_debug "RNG seed has been set to #{@rng_seed}.", "Engine"
    end

    def stop_recording file_name = nil
      @recording.stop_recording file_name
    end

    def cancel_recording
      @recording.cancel
    end

    # 1 or 2 input parameters
    def record_input_history name, value_1, value_2, value_count, clear_cache = false
      @recording.record_input_history name, value_1, value_2, value_count, clear_cache
    end

    # 3 input parameters
    def record_input_history_3_params name, value_1, value_2, value_3, clear_cache = false
      @recording.record_input_history_3_params name, value_1, value_2, value_3, clear_cache
    end

    def load_image file_name
      return @ffi_file.load_image file_name
    end

    def write_file file_name, text
      @ffi_file.write file_name, text
    rescue Exception => e
      raise e, <<-S
* ERROR:
~$gtk.write_file~ for #{file_name} failed.
#{e}
S
    end

    def write_file_root file_name, text
      @ffi_file.write_root file_name, text
    end

    def append_file file_name, text
      @ffi_file.append file_name, text
    rescue Exception => e
      raise e, <<-S
* ERROR:
~$gtk.append_file~ for #{file_name} failed.
#{e}
S
    end

    def append_file_root file_name, text
      @ffi_file.append_root file_name, text
    end

    def read_file file_name
      @ffi_file.read file_name
    rescue Exception => e
      raise e, <<-S
* ERROR:
~$gtk.read_file~ for #{file_name} failed.
#{e}
S
    end

    def list_files dir
      if platform? :mobile
        @ffi_file.list dir
      else
        @ffi_file.list File.join(get_relative_game_dir, dir)
      end
    end

    def stat_file path
      @ffi_file.stat path
    end

    def delete_file path
      if @ffi_file.stat path
        if platform? :mobile
          @ffi_file.delete path
        else
          @ffi_file.delete File.join(get_relative_game_dir, path)
        end
      end
    end

    def delete_file_if_exist path
      if @ffi_file.stat path
        if platform? :mobile
          @ffi_file.delete path
        else
          @ffi_file.delete File.join(get_relative_game_dir, path)
        end
      end
    end

    def delete_file_if_exist? path
      delete_file_if_exist path
      true
    end

    def parse_xml xmlstr, stripcontent=true
      @ffi_misc.parse_xml(xmlstr, stripcontent)
    end

    def parse_xml_file fname, stripcontent=true
      @ffi_misc.parse_xml_file(fname, stripcontent)
    end

    def parse_json jsonstr
      @ffi_misc.parse_json(jsonstr)
    end

    def parse_json_file fname
      @ffi_misc.parse_json_file(fname)
    end

    # This lets us move some data manipulation into easier Ruby code, lets us protect the
    #  state hash from garbage collection, and, if an app wants it, lets them have more
    #  control over the HTTP effort if they provide this interface directly.
    class HTTPCallbacks
      attr_accessor :state

      def ready newstate
        @state = newstate
        return nil if @state.nil?
        @state[:cancel] = false
        @state[:response_headers] = {}
        @state[:response_data] = ''
        return @state
      end

      # These are callbacks from native code.
      def http_response_header key, value
        @state[:response_headers][key] = value
        return !@state[:cancel]
      end

      def http_response_data newdata
        @state[:response_data] << newdata
        return !@state[:cancel]
      end

      def http_done
        @state = nil
      end
    end

    def http_get url, extra_headers=nil
      http = HTTPCallbacks.new
      return http.ready(@ffi_misc.http_get http, url, extra_headers)
    end

    def http_head url, extra_headers=nil
      http = HTTPCallbacks.new
      return http.ready(@ffi_misc.http_head http, url, extra_headers)
    end

    def http_post url, form_fields=nil, extra_headers=nil
      form_fields_array = nil
      if !form_fields.nil?
        form_fields_array = []
        form_fields.each { |key, value|
          form_fields_array << key.to_s
          form_fields_array << value.to_s
        }
      end
      http = HTTPCallbacks.new
      return http.ready(@ffi_misc.http_post http, url, extra_headers, form_fields_array)
    end

    def http_post_body url, body, extra_headers=nil
      http = HTTPCallbacks.new
      return http.ready(@ffi_misc.http_post_body http, url, extra_headers, body)
    end

    def http_put url, fname, extra_headers=nil
      http = HTTPCallbacks.new
      return http.ready(@ffi_misc.http_put http, url, extra_headers, fname)
    end

    def export! with_comments = nil, file_name_override = nil
      export_state! with_comments, file_name_override
    end

    def export_state! with_comments = nil, file_name_override = nil
      text = ""

      if with_comments
        commented_text = with_comments.each_line.map {|l| "# #{l.strip}"}.join("\n")
        text = commented_text + "\n\n"
      end

      text += "Game State:\n#{@args.serialize}"

      file_name = "logs/exceptions/game_state_#{Kernel.tick_count}.txt"
      file_name = file_name_override if file_name_override
      @ffi_file.write_root "logs/exceptions/current.txt", text
      @ffi_file.write_root file_name, text

      return file_name
    rescue Exception => e
      log <<-S
* ERROR:
Exporting the game state failed:

Export exception: #{e}.

Original comments: #{with_comments || "(none)"}.

If the export exception above looks confusing, you should let DragonRuby know about this error.

S
    end

    def passes
      @args.passes
    rescue Exception => e
      @args.pretty_print_exception_and_export! e
      @args.pause!
    end

    def toast id, message
      @console.toast id, message
    end

    def target pass
      pass ? pass.target : nil
    end

    def render_width pass
      pass ? pass.width : 0
    end

    def render_height pass
      pass ? pass.height : 0
    end

    def render_transient pass
      pass ? pass.transient : false
    end

    def raise_conversion_for_rendering_failed p, e, name = nil
      if name == :label
        help_text = GTK::Help.label_contract
      elsif name == :solid
        help_text = GTK::Help.solid_border_contract
      elsif name == :border
        help_text = GTK::Help.solid_border_contract
      elsif name == :sprite
        help_text = GTK::Help.sprite_contract
      else
        help_text = name
      end

      raise e, <<-S
* ERROR:
Failed to convert #{p} for rendering (#{name}).

A primitive must respond to :primitive_marker, and then subsequently
respond to ALL the methods required for that specific marker:

#{Help.primitive_contract name}
#{e}
S
    end

    def reset_state
      if @__state_assigned_to_hash_on_boot__
        @args.state = {}
      else
        @args.state.as_hash.clear
        @args.state.entity_id = Entity.id!
      end
    end

    def __reboot__(mousex, mousey, relative_x, relative_y)
      GTK.on_tick_count 0 do
        if Grid.origin_name == :bottom_left
          Grid.origin_bottom_left!
        else
          Grid.origin_center!
        end
        mouse_move_relative mousex, mousey, relative_x, relative_y
      end
    end

    def reset rng_override = nil, seed: nil, include_sprites: true
      # FIXME: Dirty hack added so that infinite reset
      # doesn't occur when $gtk.reset is placed at the bottom of main.rb.
      return if Kernel.tick_count <= 0 && !paused?
      log_debug "~reset~ has been invoked (#{Kernel.global_tick_count}).", "Engine"
      __reset__ rng_override, seed: seed, include_sprites: include_sprites
      unpause!
    end

    def reset_next_tick rng_override = nil, seed: nil
      log_debug "~reset_next_tick~ has been invoked (#{Kernel.global_tick_count - 1}).", "Engine"
      @reset_next_tick_flag = true
      @reset_next_tick_rng_override = rng_override
      @reset_next_tick_seed = seed
    end

    def __reset_render_targets__
      @render_targets_to_reset.each do |rt|
        reset_sprite rt
      end

      @render_targets_to_reset.clear
    end

    def __reset__ rng_override = nil, seed: nil, include_sprites: true
      return if @is_resetting == Kernel.global_tick_count
      @is_resetting = Kernel.global_tick_count
      $warn_array_primitives = false
      $warn_array_primitives_caller_lookup = {}
      if !$nil_punning_disabled
        nil.unassign_method_missing if nil.respond_to? :unassign_method_missing
      end

      pin_root_values

      if @args
        if $top_level.respond_to? :reset
          if $top_level.method(:reset).parameters.length == 1
            $top_level.reset @args
          else
            $top_level.reset
          end
        end
        if include_sprites
          reset_sprites log: false
        end
      end

      Entity.strict_entities.clear

      if @args
        Kernel.tick_count = -1
        clear_draw_passes
        reset_state
        @args.reset
      end

      unpause!
      show_cursor
      @console.hide
      @console.toast_ids.clear
      set_rng (rng_override || seed || @rng_seed)
      @is_resetting = false
      @pin_to_30_fps = false
      @framerate_pin_grace_period = false
      @args.inputs.keyboard.clear
      if @grid_origin_on_boot == :center
        @args.grid.origin_center!(force: true)
      else
        @args.grid.origin_bottom_left!(force: true)
      end
      if inside_tick?
        @last_reset_global_at = Kernel.global_tick_count
        @last_reset_caller = caller
      end
      @scheduled_callbacks = {}
      reset_framerate_calculation
      Entity.__reset_id__!
    end

    def last_reset_global_at
      @last_reset_global_at || -1
    end

    def last_tick_exception_global_at
      @last_tick_exception_global_at || -1
    end

    def last_reset_caller
      @last_reset_caller ||= []
    end

    def paused?
      @paused
    end

    def pause!
      @paused = true
    end

    def unpause!
      clear_draw_passes
      @paused = false
      should_reset_framerate = true
      should_reset_framerate = false if @no_tick || @test_path || Kernel.global_tick_count == -1
      if should_reset_framerate
        on_tick_count Kernel.tick_count + 30 do
          reset_framerate_calculation
        end
      end
    end

    def queue_key_up key
      @key_up_queue << key.to_sym
    end

    def pin_root_values
      @files_reloaded ||= []
      @files_reloaded   = [] if !@files_reloaded.is_a? Array
      @reloaded_files ||= []
      @reloaded_files   = [] if !@reloaded_files.is_a? Array
      @paused = false        if @paused.nil?
      @time_per_tick ||= 16
    end

    def audio
      @args.audio
    end

    # !!! FIXME: part of legacy audio API...deprecate and remove this.
    # !!! FIXED: sound api for one-time sounds should still be supported. looping sound has been removed.
    def queue_sound path, gain

      # !!! FIXME: Get rid of the intermediary Sound class and accept a
      #            hash that respects all args.audio properties
      @sound_queue << { input: path, gain: gain }
    end

    # !!! FIXME: part of legacy audio API...deprecate and remove this.
    # !!! FIXED: sound api for one-time sounds should still be supported. looping sound has been removed.
    def stop_music
      log_once_important :stop_music_is_deprecated, Messages.messages_stop_music_is_deprecated
    end

    # !!! FIXME: part of legacy audio API...deprecate and remove this.
    # !!! FIXED: sound api for one-time sounds should still be supported. looping sound has been removed.
    def dequeue_sounds pass
      pass.sounds.each do |s|
        queue_sound s.path, s.gain
      end
      pass.sounds.clear
    end

    # !!! FIXME: remove this when we remove the original audio API. This just maps the old way into the new one.
    # !!! FIXED: sound api for one-time sounds should still be supported. looping sound has been removed.
    def process_one_time_sounds
      @args.passes.each { |p| dequeue_sounds p }
      @sound_queue.each_with_index do |sound_hash, i|
        @args.audio["ONE_TIME_SOUND_#{sound_hash.object_id}_#{Time.now.to_f}_#{i}".to_sym] ||= { :input => sound_hash[:input], :gain => sound_hash[:gain].to_f, :playtime => 0.0 }
      end
      @sound_queue.clear
    end

    class HTTPRequest
      attr_reader :id, :address, :method, :uri, :headers, :body, :ignore_tick_count, :raw_body

      def initialize runtime, address, method, uri, headers, raw_body, reqcptr
        # we'll drop the request if not responded to in 30 seconds worth of ticks.
        @id = "#{Time.now.to_i}-#{rand(100_000) + 100_000}-#{rand(100_000) + 100_000}-#{rand(100_000) + 100_000}"
        @runtime = runtime
        @ignore_tick_count = Kernel.tick_count + (60 * 30)
        @address = address
        @method = method
        @uri = uri
        @headers = headers
        @raw_body = raw_body
        if @raw_body
          tmp = []
          content_disposition_id = ''
          @raw_body.each_line do |l|
            if l.start_with? '--------------------------'
              # do nothing
            elsif l.start_with? 'Content-Disposition'
              # do nothing
            else
              tmp << l
            end
          end
          @body = tmp.join
        end
        @reqcptr = reqcptr
      end

      def serialize
        {
          id: @id,
          uri: @uri,
          address: @address,
          method: @method,
          headers: @headers,
          raw_body: @raw_body,
          body: @body
        }
      end

      def inspect
        "#{serialize}"
      end

      def to_s
        <<-S
* HTTPRequest
** id
#{@id}
** uri
#{@uri}
** address
#{@address}
** method
#{@method}
** headers
#{@headers.map do |k, v| "*** #{k}\n#{v}" end.join("\n")}
** raw_body
#{@raw_body}
** body
#{@body}
S
      end

      def reject
        self.respond 400, "This request was rejected, sorry.\n", { "Content-Type" => "text/plain; charset=utf-8" }
      end

      def respond httpcode, body=nil, headers=nil
        headers ||= {}
        @runtime.http_respond self, @reqcptr, httpcode, body, headers
        @reqcptr = nil   # ignore any further attempts to respond.
      end
    end

    def new_http_request address, method, uri, headers, body, reqcptr
      req = HTTPRequest.new self, address, method, uri, headers, body, reqcptr
      @http_requests << req
    end

    def http_respond req, reqcptr, httpcode, body, headers_hash
      @http_requests.delete(req)
      if !reqcptr.nil?
        headers = []
        headers_hash.each { |k,v| headers << "#{k}: #{v}" }
        self.ffi_misc.http_respond reqcptr, httpcode, body, headers
      end
    end

    def stage_replay_values
      @recording.stage_replay_values
    end

    def clear_draw_primitives pass
      pass.target = nil
      pass.width = nil
      pass.height = nil
      pass.clear_non_static unless @slowmo_factor_debounce
      pass.clear_non_static_reserved
    end

    def a11y_inputs_tick_before
      @a11y_emulation.tick_before

      if @args.inputs.a11y[:activated_global_at_raw] && (@args.inputs.a11y[:activated_global_at_raw] - Kernel.global_tick_count).abs < 30
        activation = @args.inputs.a11y[:activated_id]
        if (activation || "").length > 0
          entry = @args.outputs.a11y_processed[activation]

          if entry
            entry_rect = Geometry.rect_props(entry)

            entry_x = entry_rect.center.x
            entry_y = entry_rect.center.y

            __mouse_move_relative_with_untransformed_points_ entry_x, entry_y, 0, 0, false

            on_tick_count Kernel.tick_count + 5 do
              mouse_button_pressed 1, false
              on_tick_count Kernel.tick_count + 5 do
                mouse_button_up 1, false
              end
            end
          end
        end
      end
    end

    def inputs_tick_before
      return if @slowmo_factor_debounce
      all_keyboard_up_keys = @args.inputs.keyboard.key_up.truthy_keys
      @args.inputs.keyboard.key_down.set all_keyboard_up_keys, nil
      @args.inputs.keyboard.key_held.set all_keyboard_up_keys, nil

      # manage keycodes
      # remove all nil values first
      @args.inputs.keyboard.key_down.keycodes.reject! {|k,v| !v}
      @args.inputs.keyboard.key_held.keycodes.reject! {|k,v| !v}
      @args.inputs.keyboard.key_up.keycodes.reject!   {|k,v| !v}

      # for all key_up keycodes, delete key_down and key_held
      @args.inputs.keyboard.key_up.keycodes.each do |k,v|
        @args.inputs.keyboard.key_down.keycodes.delete k
        @args.inputs.keyboard.key_held.keycodes.delete k
      end

      # if reset via the ctrl+r keyboard shortcut is enabled
      if @reset_via_ctrl_r
        # and ctrl is pressed
        r_key_down_or_held = @args.inputs.keyboard.key_down.r || @args.inputs.keyboard.key_held.r
        ctrl_key_down_or_held = @args.inputs.keyboard.key_down.control || @args.inputs.keyboard.key_held.control
        shift_key_down_or_held = @args.inputs.keyboard.key_down.shift || @args.inputs.keyboard.key_held.shift
        meta_key_down_or_held = @args.inputs.keyboard.key_down.meta || @args.inputs.keyboard.key_held.meta
        # reboot shortcuts: ctrl+shift+r, ctrl+meta(option/alt)+r, meta(option/alt)+shift+r
        if ((r_key_down_or_held && ctrl_key_down_or_held && shift_key_down_or_held) ||
            (r_key_down_or_held && ctrl_key_down_or_held && meta_key_down_or_held) ||
            (r_key_down_or_held && meta_key_down_or_held && shift_key_down_or_held))
          reboot
        elsif r_key_down_or_held && ctrl_key_down_or_held
          log_once_important :reset_via_ctrl_r, Messages.messages_reset_via_ctrl_r

          # reset right away or next tick depending on if the console is visible or not
          # note: this is done before tick_console because tick console clears out keyboard input so that
          # it isn't sent to the game
          if @a11y_emulation.enabled?
            @a11y_emulation.disable_via_ctrl_r!
            @args.inputs.clear
          elsif @console.visible?
            reset
          else
            reset_next_tick
          end
        end
      end

      a11y_inputs_tick_before
    end

    def a11y_enable!
      @a11y_emulation.enable!
    end

    def a11y_disable!
      @a11y_emulation.disable!
    end

    def a11y_enabled?
      @a11y_emulation.enabled? || @a11y_enabled
    end

    def inputs_tick_after
      all_down_keys = @args.inputs.keyboard.key_down.truthy_keys
      current_down_char = @args.inputs.keyboard.key_down.char
      if !@slowmo_factor_debounce
        @args.inputs.keyboard.last_directional_vector = @args.inputs.keyboard.directional_vector
        @args.inputs.keyboard.key_down.last_directional_vector = nil
        @args.inputs.keyboard.key_held.last_directional_vector = @args.inputs.keyboard.key_held.directional_vector
        @args.inputs.keyboard.key_up.last_directional_vector = nil
        @args.inputs.keyboard.key_down.set all_down_keys, nil
        @args.inputs.keyboard.key_held.set all_down_keys, Kernel.tick_count
        @args.inputs.keyboard.key_up.clear

        # manage keycodes
        # remove all nil values first
        @args.inputs.keyboard.key_down.keycodes.reject! {|k,v| !v}
        @args.inputs.keyboard.key_held.keycodes.reject! {|k,v| !v}
        @args.inputs.keyboard.key_up.keycodes.reject!   {|k,v| !v}

        # for all key_down keycodes, transition them to key_held
        @args.inputs.keyboard.key_down.keycodes.each do |k,v|
          @args.inputs.keyboard.key_held.keycodes[k] = Kernel.tick_count
        end
        @args.inputs.keyboard.key_down.keycodes.clear
        @args.inputs.keyboard.key_repeat.clear
      end
      @args.inputs.keyboard.key_held.char = current_down_char

      @args.outputs.tick_a11y
      @a11y_emulation.tick_after

      if @args.inputs.touch.length > 0
        touch_points = @args.inputs.touch.map { |_, touch| { x: touch.x, y: touch.y } }

        # compute the center of all touch points
        center = touch_points.reduce({ x: 0, y: 0 }) do |acc, touch|
          acc.x += touch.x
          acc.y += touch.y
          acc
        end

        center.x /= touch_points.count
        center.y /= touch_points.count

        # simulate mouse move
        transform_x = @args.grid.transform_x(center.x)
        transform_y = @args.grid.transform_y(center.y)

        @args.inputs.mouse_touch.x = @args.inputs.mouse_touch.x.lerp(transform_x, 0.1)
        @args.inputs.mouse_touch.y = @args.inputs.mouse_touch.y.lerp(transform_y, 0.1)
        mouse_move @args.inputs.mouse_touch.x, @args.inputs.mouse_touch.y
      end

      clear_inputs
    end

    def clear_draw_passes
      clear_draw_primitives @args.outputs
      @args.passes.each { |p| clear_draw_primitives p }
      @args.passes.clear
      @args.clear_render_targets
      @args.clear_pixel_arrays
    end

    def clear_inputs
      @files_reloaded.clear
      @reloaded_files.clear
      return if @slowmo_factor_debounce
      @args.inputs.controller_one.last_directional_vector = @args.inputs.controller_one.directional_vector
      @args.inputs.controller_one.key_down.last_directional_vector = nil
      @args.inputs.controller_one.key_held.last_directional_vector = @args.inputs.controller_one.key_held.directional_vector
      @args.inputs.controller_one.key_up.last_directional_vector = nil
      @args.inputs.controller_one.key_down.clear
      @args.inputs.controller_one.key_up.clear
      @args.inputs.controller_two.last_directional_vector = @args.inputs.controller_two.directional_vector
      @args.inputs.controller_two.key_down.last_directional_vector = nil
      @args.inputs.controller_two.key_held.last_directional_vector = @args.inputs.controller_two.key_held.directional_vector
      @args.inputs.controller_two.key_up.last_directional_vector = nil
      @args.inputs.controller_two.key_down.clear
      @args.inputs.controller_two.key_up.clear
      @args.inputs.controller_three.last_directional_vector = @args.inputs.controller_three.directional_vector
      @args.inputs.controller_three.key_down.last_directional_vector = nil
      @args.inputs.controller_three.key_held.last_directional_vector = @args.inputs.controller_three.key_held.directional_vector
      @args.inputs.controller_three.key_up.last_directional_vector = nil
      @args.inputs.controller_three.key_down.clear
      @args.inputs.controller_three.key_up.clear
      @args.inputs.controller_four.last_directional_vector = @args.inputs.controller_four.directional_vector
      @args.inputs.controller_four.key_down.last_directional_vector = nil
      @args.inputs.controller_four.key_held.last_directional_vector = @args.inputs.controller_four.key_held.directional_vector
      @args.inputs.controller_four.key_up.last_directional_vector = nil
      @args.inputs.controller_four.key_down.clear
      @args.inputs.controller_four.key_up.clear
      @args.inputs.mouse.clear
      @args.inputs.text.clear
      @args.inputs.http_requests.clear
      @args.inputs.keyboard.active = false
      @args.inputs.controller_one.active = false
      @args.inputs.controller_two.active = false
      @args.inputs.controller_three.active = false
      @args.inputs.controller_four.active = false
      @args.inputs.mouse.active = false
      @args.inputs.a11y.clear
      @args.inputs.pinch_zoom = 0

      if platform?(:mobile) && !@args.inputs.touch.any? && !a11y_enabled?
        @args.inputs.mouse.x = -1000
        @args.inputs.mouse.y = -1000
      end
    end

    def tick_console
      #FIXME: @take_screenshot has been deprecated remove.
      return if @take_screenshot   # don't include console in screenshots.
      @console.tick @args
    end

    def print_console_activation_help
      return if @no_tick
      log_once :hello_world, <<-S
* INFO: Hello World!
This is the DragonRuby Console.
Type \"docs\" and press the ENTER key for documentation.
This notification will not be displayed when you release your game (it only displays during development).
S
    end

    def console_button_primitive
      return nil if self.production
      return nil if @console.visible?

      @console_button ||= { x: 55.from_right, y: 50.from_top, w: 50, h: 50, path: 'console-logo.png', a: 80 }.sprite
      if @args.inputs.mouse.click && (@args.inputs.mouse.inside_rect? @console_button)
        @args.inputs.mouse.click = nil
        @console.show
      end
      @console_button
    end

    # used for unit testing http and isn't meant
    # to be used for game dev
    def schedule_callback tick_count, &callback
      if !@scheduled_callbacks[tick_count]
        @scheduled_callbacks[tick_count] = []
      elsif !@scheduled_callbacks[tick_count].is_a? Array
        @scheduled_callbacks[tick_count] = [@scheduled_callbacks[tick_count]]
      end
      @scheduled_callbacks[tick_count] << callback
    end

    def on_tick_count tick_count, &callback
      if tick_count <= Kernel.tick_count
        puts <<-S
* INFO - ~on_tick_count~ has been ignored.
You invoked ~on_tick_count~ with #{tick_count} which has already passed (Kernel.tick_count: #{Kernel.tick_count}).
** Backtrace
#{caller.join("\n")}
S
        return
      end

      schedule_callback tick_count, &callback
    end

    def tick_scheduled_callbacks
      if @scheduled_callbacks[Kernel.tick_count]
        entries = @scheduled_callbacks[Kernel.tick_count]
        if !entries.is_a? Array
          entries = [entries]
        end

        entries.each do |entry|
          if entry.parameters.length == 1
            entry.call @args
          else
            entry.call
          end
        end
      end

      completed_callbacks = @scheduled_callbacks.keys.find_all { |k| k <= Kernel.tick_count }
      completed_callbacks.each { |k| @scheduled_callbacks.delete k }
    end

    def tick_controller_config
      should_tick_controller_config = true
      should_tick_controller_config = false if platform?(:mobile)
      should_tick_controller_config = false if @platform == "Steam Deck"
      should_tick_controller_config = false if @controller_config.disabled
      should_tick_controller_config = false if Kernel.tick_count < 0
      @args.layout.reset if @args.events.resize_occurred
      if should_tick_controller_config
        @controller_config.tick @args
      end
    end

    def tick_gtk_engine_before
      unpause_if_needed
      if !skip_tick_usr_engine?
        @recording.tick_before
      end
      clear_draw_passes

      inputs_tick_before

      @args.inputs.http_requests = @http_requests.clone
      # we want to tick Kernel.global_tick_count if the engine is ready, or
      # if main.rb failed to load and we are ready to show the dev the error.
      # we have to increment Kernel.global_tick_count because the console relies
      # on this for interaction/"ticking"
      if @load_status == :ready || @load_status == :main_rb_load_error_shown
        Kernel.global_tick_count += 1
        # mRuby has a bug in String#split. A corrected version of the function
        # is monkey patched in after DR source code has been initialized/loaded.
        String.class_eval do
          alias_method(:__original_split__, :split) unless method_defined?(:__original_split__)

          define_method(:split) do |*args|
            String.split(self, *args)
          end
        end
      end

      tick_console
      tick_notification
      tick_download_stb_rb
      # !!! FIXME: we are getting false positives for unrecognized controllers, disabling this feature for now
      #            also need to get rid of the usage of global_ease function within the implementation
      # tick_controller_config
      render_replay_mouse

      if @args.state.is_a? OpenEntity
        @args.state.__touched__ = false
      end

      @args.tick_before

      tick_remote_hotload_client

      if !skip_tick_usr_engine?
        Kernel.tick_count += 1

        if @args.state
          if @args.state.is_a?(OpenEntity) || @args.state.is_a?(Hash) || @args.state.respond_to?(:tick_count=)
            @args.state.tick_count = Kernel.tick_count
          end
        end

        tick_scheduled_callbacks
      end

      tick_capture_timings_before
    end

    def unpause_if_needed
      return if !paused?
      return if @console.visible?
      return if @console.toggled_at != Kernel.global_tick_count
      # attempt to unpause the game if the console is closed (maybe an exception was fixed within the console)
      unpause!
    end

    def tick_remote_hotload_client
      return if @load_status != :ready

      if !@remote_hotload_client_wrapper
        @remote_hotload_client_wrapper = RemoteHotloadClientWrapper.new self
        if @remote_hotload_enabled
          @remote_hotload_client_wrapper.start
        end
        $remote_hotload_client = @remote_hotload_client_wrapper
      end

      if @remote_hotload_enabled
        @remote_hotload_client_wrapper.tick
      end

      if @remote_hotload_enabled && Kernel.global_tick_count == 60
        notify_extended! message: "Remote hotload enabled.", env: :prod
      end
    end

    def get_thermal_state
      @ffi_misc.get_thermal_state
    end

    def check_thermal_state
      return @current_thermal_state unless Kernel.global_tick_count.zmod? 600
      return @current_thermal_state if !platform? :ios
      return @current_thermal_state if production?
      @current_thermal_state = @ffi_misc.get_thermal_state
      if @current_thermal_state == :serious || @current_thermal_state == :critical
        notify! "* IMPORTANT: Thermal state for device is [#{@current_thermal_state}]!"
        log_once_important :check_thermal_state, Messages.messages_check_thermal_state
      end
    end

    def tick_gtk_engine_after
      tick_api
      check_framerate
      check_thermal_state
      @args.outputs.target = nil   # just force this to the framebuffer, just in case.
      @args.capture_render_target_sizes
      @args.passes << @args.outputs  # move the default pass to the end of the list of passes...
      @args.passes.each { |p| p.tick }  # ...then process them all.

      # Any old HTTP requests get rejected here. If they were responded to during this tick, this is a safe no-op.
      reject_requests = nil
      @http_requests.each { |r|
        # copy to a temp array, since r.reject will remove things from @http_requests as we go.
        if r.ignore_tick_count <= Kernel.tick_count
          reject_requests = [] if reject_requests.nil?
          reject_requests << r
        end
      }
      reject_requests.each { |r| r.reject } if !reject_requests.nil?

      if !@args.audio.is_a?(AudioHash)   # in case the app broke this or something...
        @args.audio = AudioHash.new  # this will make any playing sounds stop, but what can you do?
      end

      # !!! FIXME: part of legacy audio API...deprecate and remove this.
      # !!! FIXED: one time sounds will still be supported (simpler api vs using audio directly)
      #            looping sounds has been removed/is no longer supported
      process_one_time_sounds
      @args.tick_after
      inputs_tick_after

      if Kernel.global_tick_count == 1 && !@server_started && @args.cvars["webserver.enabled"].value == true
        start_server! port: @args.cvars["webserver.port"].value, enable_in_prod: false
      end

      @render_targets_to_reset ||= []
      @render_targets_to_reset.concat @args.render_targets.keys
      @render_targets_to_reset.uniq!

      if !skip_tick_usr_engine?
        @recording.tick_after
      end

      a11y_tick_gtk_engine_after
      tick_capture_timings_after

      @args.layout.tick_after @args.grid.x, @args.grid.y,
                              @args.grid.w, @args.grid.h,
                              @args.grid.aspect_ratio_w,
                              @args.grid.aspect_ratio_h,
                              @args.grid.orientation,
                              @args.grid.origin_name
    end

    def a11y_logical_to_points logical
      to_translate = logical
      logical_to_native = Grid.allscreen_w_px / Grid.allscreen_w
      native_to_points = Grid.allscreen_w_pt / Grid.allscreen_w_px
      to_translate_in_native = to_translate * logical_to_native
      to_translate_in_native * native_to_points
    end

    def a11y_tick_gtk_engine_after
      if @args.outputs.a11y_processed.any? { |k, v| v.a11y_trait.to_s == "notification" }
        # immediatly draw a11ys if a notification entry exists
      else
        return if !Kernel.global_tick_count.zmod? 30
      end
      r = []

      @args.outputs.a11y_processed.each do |k, e|
        a11y_text = if e.a11y_trait == "button"
                      "#{e.a11y_text} . Button."
                    else
                      e.a11y_text
                    end
        r << {
          x: a11y_logical_to_points(Grid.allscreen_offset_x) + a11y_logical_to_points(e.x),
          y: (a11y_logical_to_points(Grid.allscreen_h) - (a11y_logical_to_points(Grid.allscreen_offset_y) + a11y_logical_to_points(e.y))) - a11y_logical_to_points(e.h),
          w: a11y_logical_to_points(e.w),
          h: a11y_logical_to_points(e.h),
          a11y_id: k.to_s,
          a11y_trait: e.a11y_trait.to_s,
          a11y_text: a11y_text.gsub("\n", " ").to_s,
          a11y_notification_target: e.a11y_notification_target
        }
      end

      r = r.sort_by { |e| [e.y, e.x] }

      @ffi_draw.draw_a11ys r
    end

    def tick_api
      @api.tick @args
    end

    def tick_usr_engine
      return if skip_tick_usr_engine?
      @slowmo_was_invoked = false
      @speedup_was_invoked = false
      $perf_counter_outputs_push_count = 0
      $perf_counter_primitive_is_array = 0

      if @reset_next_tick_flag
        @reset_next_tick_flag = false
        reset @reset_next_tick_rng_override, seed: @reset_next_tick_seed
      end

      tick_core

      if !@slowmo_was_invoked
        if @slowmo_factor != 1
          notify! "Simulation loop has been returned to 60 fps."
        end

        @slowmo_factor = 1
      end

      if !@speedup_was_invoked
        if @speedup_factor != 1
          notify! "Simulation loop has been returned to 60 fps."
        end

        @speedup_factor = 1
      end
    end

    def skip_tick_usr_engine?
      @paused ||
      quit_after_startup_eval? ||
      @controller_config.should_tick? ||
      @slowmo_factor_debounce ||
      @load_status != :ready  ||
      @is_reloading ||
      @reload_debounce > 0
    end

    def calc_wrapper tick_override_lambda = nil
      if @slowmo_factor && @slowmo_factor != 1
        @slowmo_factor_debounce ||= @slowmo_factor
        if @slowmo_factor_debounce > 0
          @slowmo_factor_debounce -= 1
        else
          @slowmo_factor_debounce = nil
        end
      end

      @debug_require = false

      tick_gtk_engine_before
      tick_usr_engine
      tick_gtk_engine_after

      if !@recording.is_replaying? && !@recording.is_recording?
        if @simulation_speed != 1
          @simulation_speed = 1
        end
      end
    end

    def render_replay_mouse
      return unless @recording.is_replaying?
      if @args.inputs.mouse.click
        @mouse_clicked_at = Kernel.tick_count
        @mouse_clicked_x = @args.inputs.mouse.position.x
        @mouse_clicked_y = @args.inputs.mouse.position.y
      end

      @args.outputs.borders << { x: @args.inputs.mouse.position.x - 5,
                                 y: @args.inputs.mouse.position.y - 5,
                                 w: 10,
                                 h: 10 }

      @args.outputs.borders << { x: @args.inputs.mouse.position.x - 6,
                                 y: @args.inputs.mouse.position.y - 6,
                                 w: 12,
                                 h: 12,
                                 r: 255,
                                 g: 255,
                                 b: 255 }

      if @mouse_clicked_at
        duration = 0.20.seconds

        perc = Easing.smooth_stop start_at: @mouse_clicked_at,
                                  tick_count: Kernel.tick_count,
                                  duration: duration

        @args.outputs.borders << {
          x: @mouse_clicked_x - 20 * perc,
          y: @mouse_clicked_y - 20 * perc,
          w: 40 * perc,
          h: 40 * perc,
          r: 0,
          g: 0,
          b: 0,
          a: 255 * perc
        }

        @args.outputs.borders << {
          x: @mouse_clicked_x - 21 * perc,
          y: @mouse_clicked_y - 21 * perc,
          w: 42 * perc,
          h: 42 * perc,
          r: 255,
          g: 255,
          b: 255,
          a: 255 * perc
        }

        if @mouse_clicked_at.elapsed_time > duration
          @mouse_clicked_at = nil
        end
      end
    end

    def __nil_state_migration_message__
<<-S
* INFO - ~args.state~ was initialized to ~nil~. This experimental behavior has been changed.
~args.state~ will be initialized to an empty ~Hash~ instead.

** Migration instructions:
*** 1. Change boot function and initialize ~args.state~ to an empty ~Hash~ instead of ~nil~.
The following:

#+begin_src
  def boot args
    args.state = nil
  end
#+end_src

Needs to be changed to:

#+begin_src
  def boot args
    args.state = {}
  end
#+end_src

*** 2. Update your game state initialization.
The following example initialization:

#+begin_src ruby
  def tick args
    # this expression will not be invoked since
    # args.state will always be a non nil value
    args.state ||= { x: 0, y: 0 }
  end
#+end_src

Needs to be changed to:

#+begin_src ruby
  def tick args
    # args.state will always be a non nil value
    # each top-level property needs to be initialized seperately
    args.state.x ||= 0
    args.state.y ||= 0

    # OR

    # create a containing hash for top-level properties
    # and update call sites to use containing hash
    args.state.player ||= { x: 0, y: 0 }
  end
#+end_src
S
    end

    def __invalid_state_type_message__
<<-S
* WARNING - ~args.state~ was initialized to something other than ~Hash~ during ~boot~. Ignoring initialization and using ~OpenEntity~.
You may only do:
#+begin_src
  def boot args
    # args.state will be hydrated with a ~Hash~ and nil punning will be disabled.
    args.state = {}
  end

  def tick args
    # args.state will be an empty Hash instead of an OpenEntity
    args.state.player ||= { ... }
  end
#+end_src
S
    end

    def __sdl_tick__simulation__
      $state = @args.state
      $grid = @args.grid
      $trace_puts = false
      load_main_rb
      tick_hotload
      tick_auto_test
      process_argsv
      calc_wrapper
      # if the load status is :main_rb_load_failed, then that means there
      # was a syntax error in main.rb at first launch
      # change the status to :main_rb_load_error_shown and raise the error
      # this swap is needed so that Kernel.global_tick_count increments (which
      # controls the usage of the DR console).
      if @load_status == :main_rb_load_failed
        @load_status = :main_rb_load_error_shown
        raise @load_status_exception
      elsif @load_status == :boot
        Kernel.tick_count = -1
        Kernel.global_tick_count = -1
        Grid.letterbox = @args.cvars["game_metadata.hd_letterbox"].value
        $gtk.write_file_root (File.join Backup.backup_directory, "boot.txt"), Time.now.to_i.to_s
        @load_status = :ready
        $top_level.boot @args if $top_level.respond_to? :boot
        @grid_origin_on_boot = Grid.origin_name

        if @args.state && @args.state.is_a?(OpenEntity)
          # noop: @args.state was not changed during boot
          @__state_assigned_to_hash_on_boot__ = false
        elsif @args.state && @args.state.is_a?(Hash)
          @__state_assigned_to_hash_on_boot__ = true
          $disable_array_primitives = true
          @args.temp_state = {}
          disable_nil_punning!
          log "* INFO - ~args.state~ was initialized to ~Hash~ during ~boot~. ~nil~ punning has been disabled."
        elsif !@args.state
          @__state_assigned_to_hash_on_boot__ = true
          $disable_array_primitives = true
          @args.state = {}
          @args.temp_state = {}
          disable_nil_punning!
          log __nil_state_migration_message__
        else
          @__state_assigned_to_hash_on_boot__ = false
          @args.state = OpenEntity.new
          @args.temp_state = OpenEntity.new
          log __invalid_state_type_message__
        end

        @args.state.tick_count = -1

        if platform?(:touch)
          @args.inputs.last_active = :mouse
          @args.inputs.last_active_at = 0
        elsif platform?(:steamdeck)
          @args.inputs.last_active = :controller
          @args.inputs.last_active_at = 0
        else
          @args.inputs.last_active = :keyboard
          @args.inputs.last_active_at = 0
        end

        if platform?(:mobile)
          @args.inputs.mouse.x = -1000
          @args.inputs.mouse.y = -1000
        end
      end
    end

    def disable_aggressive_gc!
      @disable_aggressive_gc = true
    end

    def __sdl_tick__ sdl_tick
      # GC.start unless @disable_aggressive_gc
      @last_sdl_tick ||= sdl_tick
      @sdl_tick = sdl_tick
      # in the event of a slowdown, sdl attempts to catch up the simulation
      # this prevents the simulation from running too fast
      if (sdl_tick - @last_sdl_tick) < 16
        @__sdl_tick_too_early_count__ += 1
        return
      end

      @last_sdl_tick = sdl_tick

      tick_argv

      return if @no_tick

      __sdl_tick__simulation__

      should_set_speedup_factor = @speedup_factor && @speedup_factor > 1
      @simulation_speed = @speedup_factor if should_set_speedup_factor

      if (@simulation_speed && @simulation_speed != 1)
        (@simulation_speed - 1).abs.times do
          __sdl_tick__simulation__
          # one time RT may be generated within a tick, explicitly execute "draw" to export args.outputs
          @ffi_draw.draw
        end
      end

      update_simulation_audio_state
    rescue Exception => e
      if $top_level.respond_to? :unhandled_exception
        $top_level.unhandled_exception args, e
      else
        unhandled_exception e
      end
    end

    def unhandled_exception e
      @last_tick_exception_global_at = Kernel.global_tick_count
      @is_inside_tick = false
      local_file_name = "logs/exceptions/game_state_#{Kernel.tick_count}.txt"
      log_info "* INFO - Game state and exception will be written to #{local_file_name} and logs/exceptions/current.txt."
      log_info "  global_tick_count: #{Kernel.global_tick_count}"
      log_info "  tick_count: #{Kernel.tick_count}"
      pretty_print_exception_and_export! e
      if @no_tick
        request_quit
      else
        pause!
      end
    end

    def export_error! exception_text
      GTK.write_file "errors/last.txt", exception_text

      if !@production
        GTK.write_file "errors/readme.txt", Messages.messages_production_errors_readme
      end
    end

    def pretty_print_exception_and_export! e
      exception_text = __pretty_print_exception__ e, nil
      export_error! exception_text

      if @production && platform?(:ios)
        @ffi_misc.request_quit_fatal exception_text
      end

      file_name = self.export_state! exception_text
      @exception_occurred = true
      console_show_reason = if @is_reloading
                              :exception_on_load
                            else
                              :exception
                            end

      self.show_console console_show_reason

      if self.console.command_set_at != Kernel.global_tick_count
        self.console.set_command "$gtk.reset seed: #{self.rng_seed}", console_show_reason
        if e.to_s.include?("** docs:")
          docs_command = (e.to_s.split("** docs: ")[1] || "").strip
          self.console.set_command docs_command, console_show_reason if docs_command.length > 0
        end
      end
    rescue Exception => e
      log <<-S
* EXCEPTION: pretty_print_exception_and_export! had an unhandled exception. You might want to let DragonRuby know about this.
** INNER EXCEPTION
#{e}
S
    end

    def text_font
      nil
    end

    def calcstringbox str, sz_enum = 0, fnt = "font.ttf", size_enum: nil, size_px: nil, font: nil
      str ||= ""
      # multiply size_px by 10 for precision
      size_px_multipler = 10

      multiplier_used = false

      if size_enum
        sz_enum = size_enum
      end

      if size_px
        multiplier_used = true
        sz_enum = ((size_px * size_px_multipler) - 22).idiv(2)
      end

      if font
        fnt = font
      end

      if fnt
        w, h = @ffi_misc.calcstringbox str, sz_enum.to_f, fnt
      else
        w, h = @ffi_misc.calcstringbox str, sz_enum.to_f
      end

      if multiplier_used
        [w / size_px_multipler, h / size_px_multipler]
      else
        [w, h]
      end
    end

    def calcstringbox_h str, sz_enum = 0, fnt = "font.ttf", size_enum: nil, size_px: nil, font: nil
      w, h = calcstringbox str, size_enum, fnt, size_enum: size_enum, size_px: size_px, font: font
      { w: w, h: h }
    end

    def autocomplete_methods
      __custom_object_methods__ - Runtime::Deprecated.instance_methods
    end

    def ignore_search_term? word
      word ||= ""
      return true if word.length < 3
      return true if word.gsub(".", "") == "state"
      return false
    end

    def grep_did_you_mean_recommendations instance, method
      r = instance.methods.find_all { |m| m.start_with? method.to_s }
      if method.to_s.length <= 3
        return []
      elsif r.length > 0
        return r.sort
      else
        return grep_did_you_mean_recommendations instance, method.to_s[0..-2]
      end
    end

    def grep_did_you_mean instance, method, prefix = "", delimeter = ", ", take: nil
      variations = *method.to_s.split('_')

      recommendations = variations.map do |v|
        grep_did_you_mean_recommendations instance, v
      end

      recommendations = grep_did_you_mean_recommendations(instance, method).sort + recommendations.sort
      recommendations.flatten!.uniq!

      take ||= recommendations.length

      recommendations = recommendations.take(take)

      if recommendations.length > 0
        <<-S.strip
Here's a list of methods that kind of look like :#{method}.
#{recommendations.map { |r| prefix + ":#{r}" }.join(delimeter)}
S
      else
        ""
      end
    end

    def grep_source_file file, *strings_with_recommendations
      return [] if File.extname(file) != '.rb'

      text = read_file file

      return [] unless text

      text.each_line.with_index.map do |l, i|
        strings_with_recommendations.map do |word, recommendation|
          word = word.to_s
          recommendation = (recommendation || "").to_s
          line_info = "#{file}, line #{i + 1}: " + l.strip
          if l.gsub("  ", " ")
               .gsub("   ", " ")
               .gsub("    ", " ")
               .gsub("     ", " ")
               .gsub("      ", " ")
               .gsub("       ", " ")
               .include?(word)
            if ignore_search_term? word
              nil
            elsif recommendation.length == 0
              [line_info]
            else
              [line_info, "  recommendation: #{recommendation} (#{word}, #{i + 1})"]
            end
          else
            nil
          end
        end.flatten.reject_nil.uniq
      end.flatten.reject_nil.uniq
    end

    def grep_source *strings_with_recommendations
      if strings_with_recommendations.length == 0
        return "No search parameters were provided. The request to search came from #{self.class} with value #{self}."
      end

      markers = [
        'app/main.rb',
        'app/tests.rb',
        'app/test.rb',
        *@required_files
      ].flat_map { |f| grep_source_file f, *strings_with_recommendations }

      help_array = strings_with_recommendations.map { |l| "[\"#{l[0]}\", \"#{l[1]}\"]" }.join(", ")

      if !@help_message_already_displayed
        help_message = "
You can re-run this search using the following code. Type it into
the file called repl.rb and save:

puts $gtk.grep_source #{help_array}

After saving repl.rb, go to the game and press one of these [`] [~] [²] [^] [º] [§]
to open the DragonRuby GTK Console.

".strip
      else
        help_message = ""
      end

      @help_message_already_displayed = true

      if markers
        search_results = "Here is a search of the source code:\n\n" + markers.join("\n") + "\n\n" + help_message
      else
        search_results = "No recommendations available. Searching the code yielded no results."
      end

      search_results
    end

    def tests
      @tests
    end

    def log_level
      @log_level ||= :on
    end

    def log_levels
      [:on, :off]
    end

    def log_level= value
      if !log_levels.include? value
        self.log_level = :on
        return
      end

      if @log_level != value
        log_important "* IMPORTANT: Log level has been changed to: [#{value}] from [#{@log_level}]."
        @log_level = value
      end
    end

    def seed
      @rng_seed
    end

    def system cmd
      puts (exec cmd)
    end

    def exec cmd
      `#{cmd}`
    end

    def self.argv_window_scale argv
      (parse_cli_argument(argv, :window_scale) || "1.0").to_f
    end

    def self.argv_window_position_x argv
      (parse_cli_argument(argv, :window_position_x) || "-1").to_i
    end

    def self.argv_window_position_y argv
      (parse_cli_argument(argv, :window_position_y) || "-1").to_i
    end

    def self.parse_cli_argument_i argv, name, default = 0
      ((parse_cli_argument argv, name) || default).to_i
    end

    def self.parse_cli_argument argv, name, default = nil
      cli_arguments ||= argv.split(" --").map do |arg_pair|
        tokens = arg_pair.split " "
        rest = (tokens.rest || "").join(" ").strip
        if rest.length == 0
          rest = nil
        end
        first_token = tokens.first
        if tokens.first.include?('dragonruby')
          first_token = :dragonruby
          rest ||= 'mygame'
          rest = '' if rest == './'
        else
          first_token = tokens.first.gsub("-", "_").to_sym
        end
        [first_token, rest]
      end.reject_nil.pairs_to_hash

      cli_arguments[name] || default
    end

    def show_cursor
      return if @cursor_shown
      @cursor_shown = true
      self.ffi_draw.toggle_cursor true
    end

    def hide_cursor
      return if !@cursor_shown

      if @console.visible?
        @cursor_shown = true
        self.ffi_draw.toggle_cursor true
        return
      end

      @cursor_shown = false
      self.ffi_draw.toggle_cursor false
    end

    def cursor_shown?
      @cursor_shown
    end

    def set_system_cursor type
      self.ffi_draw.set_system_cursor type.to_s
    end

    def set_cursor fname, hot_x=0, hot_y=0
      self.ffi_draw.set_cursor fname, hot_x, hot_y
    end

    def set_mouse_grab value
      return if @mouse_grab == value
      @mouse_grab = value
      self.ffi_draw.set_mouse_grab value.to_i
    end

    def openurl url
      self.ffi_draw.openurl url
    end

    alias_method :open_url, :openurl

    def mailto email:, subject:, body: nil, exception: nil;
      mailto_string = "mailto:#{email}?subject=#{subject}&body=#{body}"
      self.ffi_draw.openurl mailto_string
    end

    def take_screenshot
      @args.outputs.screenshots.length > 0
    end

    def simulate_render_targets_reset
      self.ffi_draw.simulate_render_targets_reset
    end

    def simulate_render_device_reset
      self.ffi_draw.simulate_render_device_reset
    end

    def serialize
      {
        argv: argv,
        platform: platform,
        required_files: required_files,
        reload_list_history: reload_list_history
      }
    end

    def get_base_dir
      (@ffi_file.get_base_dir || "").strip
    end

    def open_docs
      $gtk.openurl(get_game_dir_url "../docs/static/docs.html")
    end

    def export_docs!
      Kernel.export_docs!
    end

    def get_game_id
      game_id_line = $gtk.read_file('metadata/game_metadata.txt')
                         .each_line
                         .find { |l| l.start_with? "gameid=" }

      game_id_line ||= "gameid=hello-SDL"

      return game_id_line.strip.split('=')[1] || ""
    end

    def get_pixels path
      pixels, w, h = @ffi_file.load_image path
      {
        pixels: pixels,
        w: w,
        h: h
      }
    end

    def trace_nil_punning!
      return if $nil_punning_trace_enabled
      $nil_punning_trace_enabled = true
        log <<-S
* INFO: trace_nil_punning! enabled
#{caller.map { |c| "** " + c }.join("\n")}

To disable, remove any invocations of ~$gtk.trace_nil_punning!~ and invoke ~$gtk.untrace_nil_punning!~ in the Console.
S
    end

    def untrace_nil_punning!
      $nil_punning_trace_enabled = false
    end

    def disable_nil_punning!
      return if $nil_punning_disabled
      $nil_punning_disabled = true

      if inside_tick?
        raise <<~S
          * ERROR: Can't call disable_nil_punning inside tick.
          The ~disable_nil_punning!~ method is designed to be called
          outside of tick. For example:

          #+begin_src
            def tick args
              ...
            end

            $gtk.disable_nil_punning!
          #+end_src
        S
      end

      nil.unassign_method_missing if nil.respond_to? :unassign_method_missing

      NilClassFalseClass.instance_methods.each do |m|
        begin
          NilClass.remove_method m if NilClass.instance_methods.include? m
        rescue
        end

        begin
          FalseClass.remove_method m if FalseClass.instance_methods.include? m
        rescue
        end
      end

      if Kernel.global_tick_count >= 0
        reset
      end
    end

    def enable_nil_punning!
      return if $nil_punning_disabled == false
      $nil_punning_disabled = false

      if inside_tick?
        raise <<~S
          * ERROR: Can't call ~enable_nil_punning~ inside tick.
          The ~enable_nil_punning!~ method is designed to be called
          outside of tick. For example:

          #+begin_src
            def tick args
              ...
            end

            $gtk.enable_nil_punning!
          #+end_src
        S
      end

      NilClass.class_eval do
        include NilClassFalseClass
      end

      FalseClass.class_eval do
        include NilClassFalseClass
      end

      if Kernel.global_tick_count >= 0
        reset
      end
    end

    def disable_nil_coersion!
      disable_nil_punning!
    end

    def start_server!(port: nil, enable_in_prod: false, **rest)
      return unless @load_status == :ready
      return if @server_started
      port ||= @args.cvars["webserver.port"].value
      return if @production && !enable_in_prod
      @server_started = true
      remote_clients = @args.cvars["webserver.remote_clients"].value
      if enable_in_prod
        remote_clients = true
      end
      @ffi_misc.httpserver_init port.to_i, remote_clients
    end

    define_method :__global_variable_get__ do |name|
      begin
        Kernel.eval("$__g__ = $#{name}")
        l = $__g__
        $__g__ = nil
        "#{l}"
      rescue Exception => e
        ""
      end
    end

    def dlopen name
      @ffi_misc.gtk_dlopen name
    end

    def get_dlopen_path(*args)
      @ffi_misc.get_dlopen_path(*args)
    end

    def disable_controller_config!
      @controller_config.disabled = true
    end

    def disable_controller_config
      disable_controller_config!
    end

    def enable_controller_config!
      @controller_config.disabled = false
    end

    def enable_controller_config
      enable_controller_config!
    end

    def __tick_count__
      Kernel.tick_count
    end

    def __global_tick_count__
      Kernel.global_tick_count
    end

    def quit
      $top_level.shutdown @args if $top_level.respond_to? :shutdown
    end

    def benchmark(opts = nil, **kwargs)
      # !!! NOTE: Ruby 3.1 breaks the duality of being able to pass in
      #           a hash or kwargs. This null check is added
      #           for backwards compat
      Benchmark.benchmark(opts, **kwargs)
    end

    def get_texture_atlas sprites_directory
      TextureAtlas.get_texture_atlas sprites_directory,
                                     ffi_file: @ffi_file,
                                     cli_arguments: cli_arguments
    end

    def create_uuid
      @ffi_misc.create_uuid
    end
  end # end Runtime
end # end GTK

GTKRuntime = GTK::Runtime

class File
  def self.read path
    $gtk.read_file path
  end

  def self.write path, contents
    $gtk.write_file path, contents
  end

  def self.append path, contents
    $gtk.append_file path, contents
  end
end

module GTK
  class << self
    def reset rng_override = nil, seed: nil, include_sprites: true
      $gtk.reset rng_override, seed: seed, include_sprites: include_sprites
    end

    def unhandled_exception e
      $gtk.unhandled_exception e
    end

    # GTK::method passes through to $gtk.method
    def method_missing(m, *args, &block)
      if $gtk.respond_to? m
        define_singleton_method(m) do |*args, &block|
          $gtk.send(m, *args, &block)
        end

        send(m, *args, &block)
      elsif $gtk.class.respond_to? m
        define_singleton_method(m) do |*args, &block|
          $gtk.class.send(m, *args, &block)
        end

        send(m, *args, &block)
      else
        super
      end
    end
  end
end
