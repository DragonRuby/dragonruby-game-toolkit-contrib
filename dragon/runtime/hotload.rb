# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# hotload.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    # @visibility private
    module Hotload
      def hotload_init
        @hotload_debounce = 0

        # schema for file_mtimes
        # { FILE_PATH: { current: (Time as Fixnum),
        #                last:    (Time as Fixnum) },
        #   FILE_PATH: { current: (Time as Fixnum),
        #                last:    (Time as Fixnum) } }
        @file_mtimes = { }

        files_to_reload.each { |f| init_mtimes f }
      end

      def files_to_reload
        if @rcb_release_mode
          core_files_to_reload + @required_files
        else
          [
            'dragon/cvar.rb',
            'dragon/docs.rb',
            'dragon/help.rb',
            'dragon/kernel_docs.rb',
            'dragon/kernel.rb',
            'dragon/easing.rb',
            'dragon/top_level.rb',
            'dragon/log.rb',
            'dragon/math.rb',
            'dragon/geometry.rb',
            'dragon/geometry_docs.rb',
            'dragon/attr_gtk.rb',
            'dragon/attr_sprite.rb',
            'dragon/object.rb',
            'dragon/object_matrix.rb',
            'dragon/class.rb',
            'dragon/string.rb',
            'dragon/entity.rb',
            'dragon/strict_entity.rb',
            'dragon/open_entity.rb',
            'dragon/serialize.rb',
            'dragon/primitive.rb',
            'dragon/nil_class_false_class.rb',
            'dragon/symbol.rb',
            'dragon/numeric_deprecated.rb',
            'dragon/numeric.rb',
            'dragon/hash_deprecated.rb',
            'dragon/hash.rb',
            'dragon/outputs_deprecated.rb',
            'dragon/array_docs.rb',
            'dragon/array.rb',
            'dragon/outputs.rb',
            'dragon/outputs_docs.rb',
            'dragon/keyboard_keys_aliases.rb',
            'dragon/keyboard_keys.rb',
            'dragon/keyboard.rb',
            'dragon/mouse_keys.rb',
            'dragon/mouse.rb',
            'dragon/keyboard.rb',
            'dragon/inputs.rb',
            'dragon/mouse.rb',
            'dragon/controller.rb',
            'dragon/inputs_docs.rb',
            'dragon/mouse_docs.rb',
            'dragon/recording.rb',
            'dragon/grid.rb',
            'dragon/layout.rb',
            'dragon/layout_docs.rb',
            'dragon/args_deprecated.rb',
            'dragon/fn.rb',
            'dragon/args.rb',
            'dragon/args_docs.rb',
            'dragon/console_font_style.rb',
            'dragon/console_prompt.rb',
            'dragon/console_menu.rb',
            'dragon/console_evaluator.rb',
            'dragon/console.rb',
            'dragon/assert.rb',
            'dragon/tests.rb',
            'dragon/controller_config.rb',
            'dragon/runtime/draw.rb',
            'dragon/runtime/deprecated.rb',
            'dragon/runtime/framerate.rb',
            'dragon/runtime/framerate_diagnostics.rb',
            'dragon/runtime/c_bridge.rb',
            'dragon/runtime/hotload.rb',
            'dragon/runtime/backup.rb',
            'dragon/runtime/require.rb',
            'dragon/runtime/async_require.rb',
            'dragon/runtime/platform.rb',
            'dragon/runtime/autocomplete.rb',
            'dragon/runtime/texture_atlas.rb',
            'dragon/runtime/download_stb_rb.rb',
            'dragon/runtime/auto_test.rb',
            'dragon/runtime/a11y.rb',
            'dragon/runtime/a11y_emulation.rb',
            'dragon/runtime/notify.rb',
            'dragon/runtime/window.rb',
            'dragon/runtime/developer_support.rb',
            'dragon/api.rb',
            'dragon/runtime.rb',
            'dragon/runtime_docs.rb',
            'dragon/readme_docs.rb',
            'dragon/hotload_client.rb',
            'dragon/wizards.rb',
            'dragon/ios_wizard.rb',
            'dragon/itch_wizard.rb',
            'dragon/runtime/benchmark.rb',
            'dragon/tweetcart.rb',
          ] + core_files_to_reload + @required_files
        end
      end

      def core_files_to_reload
        [
          'repl.rb',
          'app/main.rb',
          'app/repl.rb',
          'app/tests.rb',
          'app/test.rb',
          'app/stdin.rb'
        ]
      end

      def init_mtimes file
        @file_mtimes[file] ||= { current: @ffi_file.mtime(file),
                                 last: @ffi_file.mtime(file) }
      end

      def hotload_source_files
        fps_diff = if current_framerate != 0
                     60.idiv(current_framerate)
                   else
                     1
                   end

        fps_diff = 1 if fps_diff < 1

        @hotload_debounce += fps_diff
        return unless @hotload_debounce >= 60
        @hotload_debounce = 0
        files_to_reload.each { |f| reload_if_needed f }
      end

      def tick_hotload
        return if Kernel.tick_count <= 0 && !paused?
        hotload_source_files
      end

      def on_load_succeeded file
        $gtk.reset_framerate_calculation
        self.files_reloaded << file
        self.reloaded_files << file
      end

      def reset_all_mtimes
        @file_mtimes.each do |file, _|
          @file_mtimes[file].current = @ffi_file.mtime(file)
          @file_mtimes[file].last    = @file_mtimes[file].current
        end

        files_to_reload.each do |file, _|
          @file_mtimes[file] ||= {}
          @file_mtimes[file].current = @ffi_file.mtime(file)
          @file_mtimes[file].last    = @file_mtimes[file].current
        end
      end

      def reload_if_needed file, force = false
        @file_mtimes[file] ||= { current: @ffi_file.mtime(file), last: @ffi_file.mtime(file) }
        @file_mtimes[file].current = @ffi_file.mtime(file)
        return if !force && @file_mtimes[file].current == @file_mtimes[file].last
        @hotload_global_at = Kernel.global_tick_count
        # in the event that an exception was thrown on initial load, if
        # a file is changed, set load status to :dragonruby_started
        # so that initialization can be tried again.
        if @load_status == :main_rb_load_error_shown
          @load_status = :dragonruby_started
        end
        on_load_succeeded file if reload_ruby_file file
        @file_mtimes[file].last = @file_mtimes[file].current
      end
    end
  end
end
