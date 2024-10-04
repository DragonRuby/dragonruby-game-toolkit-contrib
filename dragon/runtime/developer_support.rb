# coding: utf-8
# Copyright 2023 DragonRuby LLC
# MIT License
# developer_support.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module DeveloperSupport
      def version
        GTK_VERSION
      end

      def version_pro?
        @ffi_misc.version_pro?
      end

      def game_version
        @args.cvars["game_metadata.version"].value
      end

      def reset_sprite path
        @ffi_draw.unload_sprite path
      end

      def reset_sprites directory: nil, indentation: 1, suppress_logging: false
        return if Kernel.global_tick_count <= 0

        if @args.cvars["game_metadata.sprites_directory"]
          directory ||= @args.cvars["game_metadata.sprites_directory"].value
        end

        directory ||= "sprites"

        if !GTK.stat_file(directory) && @is_resetting
          log_warn <<-S
* WARNING: ~GTK.reset_sprites~ skipped during GTK.reset.
The directory =#{directory}= does not exist. ~GTK.reset_sprites~ requires a valid directory.

To explicitly provide a directory during reset, place the following code in =main.rb=:

#+begin_src ruby
  # inside of main.rb
  def reset args
    GTK.reset_sprites directory: "DIRECTORY_NAME"
  end
#+end_src
S
          return
        end

        indentation_prefix = "*" * indentation
        indentation_padding_prefix = " " * indentation
        if !suppress_logging
          puts "#{indentation_prefix} Resetting sprites in directory =#{directory}="
        end
        files = list_files directory
        files.sort! do |l, r|
          if l.end_with?(".png") && r.end_with?(".png")
            l <=> r
          elsif l.end_with?(".png")
            -1
          elsif r.end_with?(".png")
            1
          else
            l <=> r
          end
        end
        files.each do |f|
          path = File.join directory, f
          stat = stat_file path
          if stat.file_type == :regular && f.end_with?(".png")
            if !suppress_logging
              puts "#{indentation_padding_prefix} - #{f}"
            end
            reset_sprite path
          elsif stat.file_type == :directory
            directory_path = File.join directory, f
            reset_sprites directory: directory_path,
                          indentation: indentation + 1,
                          suppress_logging: suppress_logging
          end
        end
        nil
      end

      def calcspritebox str
        @ffi_misc.calcspritebox str
      end

      def warn_array_primitives!
        $warn_array_primitives = true
      end

      def trace_puts!
        $trace_puts = true
      end

      alias_method :add_caller_to_puts!, :trace_puts!

      def speedup! factor
        @speedup_was_invoked = true
        factor = factor.to_i
        factor = 1 if factor < 1
        return if @speedup_factor == factor
        if factor != 1
          notify! "Simulation loop sped up by #{factor}x. ~args.gtk.speedup! #{factor}~"
          log_info "Simulation loop sped up by #{factor}x. ~args.gtk.speedup! #{factor}~"
        end
        @speedup_factor = factor
        @speedup_factor_global_at = Kernel.global_tick_count
      end

      def slowmo! factor, should_notify = true
        @slowmo_was_invoked = true
        factor = factor.to_i
        factor = 1 if factor < 1
        return if @slowmo_factor == factor
        if factor != 1
          if should_notify
            notify! "Simulation loop slowed down to #{(60 / factor).to_i} fps. ~args.gtk.slowmo! #{factor}~"
          end
          log_info "Simulation loop slowed down to #{(60 / factor).to_i} fps. ~args.gtk.slowmo! #{factor}~"
        end
        log_info "~def tick args~ SlowMo factor has been set to normal speed." if factor == 1
        @slowmo_factor = factor
        @slowmo_factor_debounce = nil
      end

      alias_method :slowdown!, :slowmo!

      def get_relative_game_dir
        dir = get_game_dir.gsub get_base_dir, ""
        if dir.start_with? "./"
          dir = dir[2..-1]
        elsif dir.start_with? ".\\"
          dir = dir[2..-1]
        end
        dir
      end

      def get_game_dir
        (@ffi_file.get_game_dir || "").strip.gsub "//", "/"
      end

      def open_game_dir additional_directories = ""
        $gtk.openurl(get_game_dir_url additional_directories)
      end

      def get_game_dir_url additional_directories = ""
        path = File.expand_path(File.join $gtk.get_game_dir, additional_directories)
        path = path.gsub " ", "%20"
        "file://#{path}"
      end
    end # end module DeveloperSupport
  end # end class Runtime
end # end module GTK

module GTK
  class Runtime
    include DeveloperSupport
  end
end
