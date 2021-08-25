# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# hotlaod.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    # @visibility private
    module Hotload
      def hotload_init
        @hotload_if_needed = 0
        @mailbox_if_needed = 0

        # schema for file_mtimes
        # { FILE_PATH: { current: (Time as Fixnum),
        #                last:    (Time as Fixnum) },
        #   FILE_PATH: { current: (Time as Fixnum),
        #                last:    (Time as Fixnum) } }
        @file_mtimes = { }

        @suppress_mailbox = true
        files_to_reload.each { |f| init_mtimes f }
        init_mtimes 'app/mailbox.rb'
      end

      def hotload_on_write_file file_name
        return unless file_name.include? 'mailbox.rb'
        @mailbox_if_needed = :force
      end

      def files_to_reload
        if @rcb_release_mode
          core_files_to_reload + @required_files
        else
          [
            'dragon/docs.rb',
            'dragon/help.rb',
            'dragon/kernel_docs.rb',
            'dragon/kernel.rb',
            'dragon/easing.rb',
            'dragon/top_level.rb',
            'dragon/log.rb',
            'dragon/geometry.rb',
            'dragon/attr_gtk.rb',
            'dragon/attr_sprite.rb',
            'dragon/object.rb',
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
            'dragon/inputs.rb',
            'dragon/mouse_docs.rb',
            'dragon/recording.rb',
            'dragon/grid.rb',
            'dragon/layout.rb',
            'dragon/args_deprecated.rb',
            'dragon/fn.rb',
            'dragon/args.rb',
            'dragon/console_prompt.rb',
            'dragon/console_menu.rb',
            'dragon/console.rb',
            'dragon/assert.rb',
            'dragon/tests.rb',
            'dragon/controller_config.rb',
            'dragon/runtime/draw.rb',
            'dragon/runtime/deprecated.rb',
            'dragon/runtime/framerate.rb',
            'dragon/runtime/c_bridge.rb',
            'dragon/runtime/hotload.rb',
            'dragon/runtime/backup.rb',
            'dragon/runtime/async_require.rb',
            'dragon/runtime/autocomplete.rb',
            'dragon/api.rb',
            'dragon/runtime.rb',
            'dragon/trace.rb',
            'dragon/readme_docs.rb',
            'dragon/hotload_client.rb',
            'dragon/wizards.rb',
            'dragon/ios_wizard.rb',
            'dragon/itch_wizard.rb',
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
        @hotload_if_needed += 1
        return unless @hotload_if_needed == 60
        @hotload_if_needed = 0
        files_to_reload.each { |f| reload_if_needed f }
        console.enable
      end

      def mailbox_timeout
        if @suppress_mailbox
          60
        else
          3
        end
      end

      def check_mailbox
        if @mailbox_if_needed == :force # lol
          reload_if_needed 'app/mailbox.rb', true
          @mailbox_if_needed = 1
          return
        end
        @mailbox_if_needed += 1
        return unless @mailbox_if_needed.mod_zero? mailbox_timeout
        @mailbox_if_needed = 1
        reload_if_needed 'app/mailbox.rb'
      end

      def hotload_if_needed
        return if Kernel.tick_count < 0
        hotload_source_files
        check_mailbox
      end

      def on_load_succeeded file
        self.files_reloaded << file
        self.reloaded_files << file
        Trace.untrace_classes!
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
        on_load_succeeded file if reload_ruby_file file
        @file_mtimes[file].last = @file_mtimes[file].current
      end
    end
  end
end
