# Copyright 2019 DragonRuby LLC
# MIT License
# draw.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Draw
      def primitives pass
        if $top_level.respond_to? :primitives_override
          return $top_level.tick_render @args, pass
        end

        # Don't change this draw order unless you understand
        # the implications.

        # pass.solids.each            { |s| draw_solid s }
        # while loops are faster than each with block
        idx = 0
        while idx < pass.solids.length
          draw_solid (pass.solids.value idx) # accessing an array using .value instead of [] is faster
          idx += 1
        end

        # pass.static_solids.each     { |s| draw_solid s }
        idx = 0
        while idx < pass.static_solids.length
          draw_solid (pass.static_solids.value idx)
          idx += 1
        end

        # pass.sprites.each           { |s| draw_sprite s }
        idx = 0
        while idx < pass.sprites.length
          draw_sprite (pass.sprites.value idx)
          idx += 1
        end

        # pass.static_sprites.each    { |s| draw_sprite s }
        idx = 0
        while idx < pass.static_sprites.length
          draw_sprite (pass.static_sprites.value idx)
          idx += 1
        end

        # pass.primitives.each        { |p| draw_primitive p }
        idx = 0
        while idx < pass.primitives.length
          draw_primitive (pass.primitives.value idx)
          idx += 1
        end

        # pass.static_primitives.each { |p| draw_primitive p }
        idx = 0
        while idx < pass.static_primitives.length
          draw_primitive (pass.static_primitives.value idx)
          idx += 1
        end

        # pass.labels.each            { |l| draw_label l }
        idx = 0
        while idx < pass.labels.length
          draw_label (pass.labels.value idx)
          idx += 1
        end

        # pass.static_labels.each     { |l| draw_label l }
        idx = 0
        while idx < pass.static_labels.length
          draw_label (pass.static_labels.value idx)
          idx += 1
        end

        # pass.lines.each             { |l| draw_line l }
        idx = 0
        while idx < pass.lines.length
          draw_line (pass.lines.value idx)
          idx += 1
        end

        # pass.static_lines.each      { |l| draw_line l }
        idx = 0
        while idx < pass.static_lines.length
          draw_line (pass.static_lines.value idx)
          idx += 1
        end

        # pass.borders.each           { |b| draw_border b }
        idx = 0
        while idx < pass.borders.length
          draw_border (pass.borders.value idx)
          idx += 1
        end

        # pass.static_borders.each    { |b| draw_border b }
        idx = 0
        while idx < pass.static_borders.length
          draw_border (pass.static_borders.value idx)
          idx += 1
        end

        if !$gtk.production
          # pass.debug.each        { |r| draw_primitive r }
          idx = 0
          while idx < pass.debug.length
            draw_primitive (pass.debug.value idx)
            idx += 1
          end

          # pass.static_debug.each { |r| draw_primitive r }
          idx = 0
          while idx < pass.static_debug.length
            draw_primitive (pass.static_debug.value idx)
            idx += 1
          end
        end

        # pass.reserved.each          { |r| draw_primitive r }
        idx = 0
        while idx < pass.reserved.length
          draw_primitive (pass.reserved.value idx)
          idx += 1
        end

        # pass.static_reserved.each   { |r| draw_primitive r }
        idx = 0
        while idx < pass.static_reserved.length
          draw_primitive (pass.static_reserved.value idx)
          idx += 1
        end
      rescue Exception => e
        pause!
        pretty_print_exception_and_export! e
      end

      def draw_solid s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          @ffi_draw.draw_solid s.x, s.y, s.w, s.h, s.r, s.g, s.b, s.a
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed s, e, :solid
      end

      def draw_sprite s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          @ffi_draw.draw_sprite_3 s.x, s.y, s.w, s.h,
                                  s.path.s_or_default,
                                  s.angle,
                                  s.a, s.r, s.g, s.b,
                                  s.tile_x, s.tile_y, s.tile_w, s.tile_h,
                                  !!s.flip_horizontally, !!s.flip_vertically,
                                  s.angle_anchor_x, s.angle_anchor_y,
                                  s.source_x, s.source_y, s.source_w, s.source_h
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed s, e, :sprite
      end

      def draw_screenshot s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          @ffi_draw.draw_screenshot s.path.s_or_default,
                                    s.x, s.y, s.w, s.h,
                                    s.angle,
                                    s.a, s.r, s.g, s.b,
                                    s.tile_x, s.tile_y, s.tile_w, s.tile_h,
                                    !!s.flip_horizontally, !!s.flip_vertically,
                                    s.angle_anchor_x, s.angle_anchor_y,
                                    s.source_x, s.source_y, s.source_w, s.source_h
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed s, e, :screenshot
      end

      def draw_label l
        return unless l
        if l.respond_to? :draw_override
          l.draw_override @ffi_draw
        else
          @ffi_draw.draw_label l.x, l.y, l.text.s_or_default,
                               l.size_enum, l.alignment_enum,
                               l.r, l.g, l.b, l.a,
                               l.font.s_or_default(nil)
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed l, e, :label
      end

      def draw_line l
        return unless l
        if l.respond_to? :draw_override
          l.draw_override @ffi_draw
        else
          @ffi_draw.draw_line l.x, l.y, l.x2, l.y2, l.r, l.g, l.b, l.a
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed l, e, :line
      end

      def draw_border s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          @ffi_draw.draw_border s.x, s.y, s.w, s.h, s.r, s.g, s.b, s.a
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed s, e, :border
      end

      def draw_screenshots
        @args.outputs.screenshots.each { |s| draw_screenshot s }
      end

      def pixel_arrays
        @args.pixel_arrays.each { |k,v|
          if v.pixels.length == (v.width * v.height)  # !!! FIXME: warning? exception? Different API?
            @ffi_draw.upload_pixel_array k.to_s, v.width.to_i, v.height.to_i, v.pixels
          end
        }
      rescue Exception => e
        pause!
        pretty_print_exception_and_export! e
      end

    end
  end
end
