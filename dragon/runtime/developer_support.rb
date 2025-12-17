# coding: utf-8
# Copyright 2023 DragonRuby LLC
# MIT License
# developer_support.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module DeveloperSupport
      def setenv name, value, overwrite
        @ffi_misc.setenv name, value, overwrite
      end

      def getenv name
        @ffi_misc.getenv name
      end

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

      def reset_sprites directory: nil, indentation: 1, log: true, suppress_logging: false
        return if Kernel.global_tick_count <= 0

        # suppress_logging arg is deprecated (and hard to spell)
        log = false if suppress_logging

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
        if log
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
            if log
              puts "#{indentation_padding_prefix} - #{f}"
            end
            reset_sprite path
          elsif stat.file_type == :directory
            directory_path = File.join directory, f
            reset_sprites directory: directory_path,
                          indentation: indentation + 1,
                          log: log
          end
        end
        nil
      end

      def calcspritebox str
        @ffi_misc.calcspritebox str
      end

      def get_string_rect  str, sz_enum = 0, fnt = "font.ttf", size_enum: nil, size_px: nil, font: nil
        w, h = calcstringbox str, size_enum, fnt, size_enum: size_enum, size_px: size_px, font: font
        Geometry.rect_props(x: 0, y: 0, w: w, h: h)
      end

      def get_sprite_rect path
        w, h = @ffi_misc.calcspritebox path
        Geometry.rect_props(x: 0, y: 0, w: w, h: h)
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

      def capture_timings category: nil, color: nil, &block
        category ||= block.source_location.join(":")

        if @production
          result = block.call
        else
          @capture_timings_invoked = true
          @capture_timings_data[category] ||= { color: color, entries: [] }
          if @capture_timings_data[category][:entries].length > 240
            @capture_timings_data[category][:entries].pop_front
          end

          before = Time.now
          result = block.call
          after = Time.now
          @capture_timings_data[category][:color] = color
          @capture_timings_data[category][:entries] << { at: Kernel.tick_count, ms_elapsed: ((after.to_f - before.to_f)) }
        end
        result
      end

      def tick_capture_timings_before
        @capture_timings_invoked = false
        if Kernel.global_tick_count - 1 == GTK.hotload_global_at
          @capture_timings_data.clear
        end
      end

      def __capture_timings_colors__
        # dawn bringer color palette
        @__capture_timings_colors__ = [
          { r: 50 + 20,  g: 50 + 12,  b: 50 + 28 },
          { r: 50 + 68,  g: 50 + 36,  b: 50 + 52 },
          { r: 50 + 48,  g: 50 + 52,  b: 50 + 109 },
          { r: 50 + 78,  g: 50 + 74,  b: 50 + 78 },
          { r: 50 + 133, g: 50 + 76,  b: 50 + 48 },
          { r: 50 + 52,  g: 50 + 101, b: 50 + 36 },
          { r: 50 + 208, g: 50 + 70,  b: 50 + 72 },
          { r: 50 + 117, g: 50 + 113, b: 50 + 97 },
          { r: 50 + 89,  g: 50 + 125, b: 50 + 206 },
          { r: 50 + 210, g: 50 + 125, b: 50 + 44 },
          { r: 50 + 133, g: 50 + 149, b: 50 + 161 },
          { r: 50 + 109, g: 50 + 170, b: 50 + 44 },
          { r: 50 + 210, g: 50 + 170, b: 50 + 153 },
          { r: 50 + 109, g: 50 + 194, b: 50 + 202 },
          { r: 50 + 218, g: 50 + 212, b: 50 + 94 },
          { r: 50 + 222, g: 50 + 238, b: 50 + 214 }
        ]
      end

      def tick_capture_timings_after
        if !@capture_timings_invoked || @production
          @capture_timings_data.clear
          return
        end

        @current_scale ||= 40000
        @target_scale  = 40000

        timing_prefab_w = 720
        timing_prefab_h = 720
        @args.outputs[:__timing_prefab__].background_color = [0, 0, 0, 0]
        @args.outputs[:__timing_prefab__].w = timing_prefab_w
        @args.outputs[:__timing_prefab__].h = timing_prefab_h
        timing_prefab_left = if Grid.origin_name == :bottom_left
                               0
                             else
                               -360
                             end

        timing_prefab_bottom = if Grid.origin_name == :bottom_left
                                 0
                               else
                                 -360
                               end


        r = @capture_timings_data.map do |category, v|
          max_ms_elapsed = v[:entries].map { |t| t.ms_elapsed }.max
          { category: category, max_ms_elapsed: max_ms_elapsed }
        end

        max_ms_elapsed = r.map { |t| t[:max_ms_elapsed] || 0 }.max

        @target_scale = @target_scale * 0.016 / max_ms_elapsed
        @target_scale = 40000 if @target_scale > 40000
        @current_scale = @current_scale.lerp(@target_scale, 0.1)

        @args.outputs[:__timing_prefab__].primitives << {
          x: timing_prefab_left,
          y: timing_prefab_bottom + 0.016 * @current_scale,
          x2: timing_prefab_left + 720,
          y2: timing_prefab_bottom + 0.016 * @current_scale,
          r: 255,
          g: 0,
          b: 0
        }

        @args.outputs[:__timing_prefab__].primitives << {
          x: timing_prefab_left + 0,
          y: timing_prefab_bottom + 0.012 * @current_scale,
          x2: timing_prefab_left + 720,
          y2: timing_prefab_bottom + 0.012 * @current_scale,
          r: 0,
          g: 128,
          b: 0
        }

        @args.outputs[:__timing_prefab__].primitives << {
          x: timing_prefab_left + 0,
          y: timing_prefab_bottom + 0.008 * @current_scale,
          x2: timing_prefab_left + 720,
          y2: timing_prefab_bottom + 0.008 * @current_scale,
          r: 0,
          g: 255,
          b: 0
        }

        @args.outputs[:__timing_prefab__].primitives << {
          x: timing_prefab_left + 0,
          y: timing_prefab_bottom + 0.004 * @current_scale,
          x2: timing_prefab_left + 720,
          y2: timing_prefab_bottom + 0.004 * @current_scale,
          r: 0,
          g: 128,
          b: 0
        }

        @args.outputs[:__timing_prefab__].primitives << {
          x: timing_prefab_left + 0,
          y: timing_prefab_bottom + 1,
          x2: timing_prefab_left + 720,
          y2: timing_prefab_bottom + 1,
          r: 0,
          g: 255,
          b: 0
        }

        color_i = 0
        @capture_timings_data.each.with_index do |(category, v), i|
          timings = v[:entries]
          color = v[:color] || __capture_timings_colors__[color_i % __capture_timings_colors__.length]
          color_i += 1

          @args.outputs[:__timing_prefab__].primitives << {
            x: timing_prefab_left + 8 + 1,
            y: timing_prefab_bottom + 720 - 80 - 1,
            text: category,
            r: 0, g: 0, b: 0,
            anchor_y: i + 0.5,
          }

          @args.outputs[:__timing_prefab__].primitives << {
            x: timing_prefab_left + 8,
            y: timing_prefab_bottom + 720 - 80,
            text: category,
            **color,
            anchor_y: i + 0.5,
          }

          @args.outputs[:__timing_prefab__].primitives << timings.map_with_index do |timing, i|
            [
              {
                x: timing_prefab_left + 3 * i,
                y: timing_prefab_bottom + timing.ms_elapsed * @current_scale,
                w: 4,
                h: 4,
                anchor_x: 0.5,
                anchor_y: 0.5,
                path: :solid,
                r: 0, g: 0, b: 0, a: 255
              },
              {
                x: timing_prefab_left + 3 * i,
                y: timing_prefab_bottom + timing.ms_elapsed * @current_scale,
                w: 2,
                h: 2,
                anchor_x: 0.5,
                anchor_y: 0.5,
                path: :solid,
                **color, a: 255
              },
            ]
          end
        end

        @capture_timings_data.each do |category, v|
          v[:entries].reject! do |timing|
            timing[:at].elapsed_time > 240
          end
        end

        args.outputs.debug << { x: Grid.x + Grid.w / 2,
                                y: Grid.y + Grid.h / 2,
                                w: 720,
                                h: 720,
                                path: :__timing_prefab__,
                                anchor_x: 0.5,
                                anchor_y: 0.5 }
      end
    end # end module DeveloperSupport
  end # end class Runtime
end # end module GTK

module GTK
  class Runtime
    include DeveloperSupport
  end
end
