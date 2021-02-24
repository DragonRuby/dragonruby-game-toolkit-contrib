# Contributors outside of DragonRuby who also hold Copyright: Nick Sandberg
# Copyright 2019 DragonRuby LLC
# MIT License
# draw.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Draw

      def execute_draw_order pass
        # Don't change this draw order unless you understand
        # the implications.
        render_solids pass
        render_static_solids pass
        render_sprites pass
        render_static_sprites pass
        render_primitives pass
        render_static_primitives pass
        render_labels pass
        render_static_labels pass
        render_lines pass
        render_static_lines pass
        render_borders pass
        render_static_borders pass
      end

      def primitives pass
        if $top_level.respond_to? :primitives_override
          return $top_level.tick_render @args, pass
        end

        execute_draw_order pass

        if !$gtk.production
          # pass.debug.each        { |r| draw_primitive r }
          idx = 0
          length = pass.debug.length
          while idx < length
            draw_primitive (pass.debug.at idx)
            idx += 1
          end

          # pass.static_debug.each { |r| draw_primitive r }
          idx = 0
          length = pass.static_debug.length
          while idx < length
            draw_primitive (pass.static_debug.at idx)
            idx += 1
          end
        end

        # pass.reserved.each          { |r| draw_primitive r }
        idx = 0
        length = pass.reserved.length
        while idx < length
          draw_primitive (pass.reserved.at idx)
          idx += 1
        end

        # pass.static_reserved.each   { |r| draw_primitive r }
        idx = 0
        length = pass.static_reserved.length
        while idx < length
          draw_primitive (pass.static_reserved.at idx)
          idx += 1
        end
      rescue Exception => e
        pause!
        pretty_print_exception_and_export! e
      end


      def render_solids pass
        # pass.solids.each            { |s| draw_solid s }
        # while loops are faster than each with block
        idx = 0
        length = pass.solids.length
        while idx < pass.solids.length
          draw_solid (pass.solids.at idx) # accessing an array using .value instead of [] is faster
          idx += 1
        end
      end

      def render_static_solids pass
        # pass.static_solids.each     { |s| draw_solid s }
        idx = 0
        length = pass.static_solids.length
        while idx < length
          draw_solid (pass.static_solids.at idx)
          idx += 1
        end
      end

      def render_sprites pass
        # pass.sprites.each           { |s| draw_sprite s }
        idx = 0
        length = pass.sprites.length
        while idx < length
          draw_sprite (pass.sprites.at idx)
          idx += 1
        end
      end

      def render_static_sprites pass
        # pass.static_sprites.each    { |s| draw_sprite s }
        idx = 0
        length = pass.static_sprites.length
        while idx < length
          draw_sprite (pass.static_sprites.at idx)
          idx += 1
        end
      end

      def render_primitives pass
        # pass.primitives.each        { |p| draw_primitive p }
        idx = 0
        length = pass.primitives.length
        while idx < length
          draw_primitive (pass.primitives.at idx)
          idx += 1
        end
      end

      def render_static_primitives pass
        # pass.static_primitives.each { |p| draw_primitive p }
        idx = 0
        length = pass.static_primitives.length
        while idx < length
          draw_primitive (pass.static_primitives.at idx)
          idx += 1
        end
      end

      def render_labels pass
        # pass.labels.each            { |l| draw_label l }
        idx = 0
        length = pass.labels.length
        while idx < length
          draw_label (pass.labels.at idx)
          idx += 1
        end
      end

      def render_static_labels pass
        # pass.static_labels.each     { |l| draw_label l }
        idx = 0
        length = pass.static_labels.length
        while idx < length
          draw_label (pass.static_labels.at idx)
          idx += 1
        end
      end

      def render_lines pass
        # pass.lines.each             { |l| draw_line l }
        idx = 0
        length = pass.lines.length
        while idx < length
          draw_line (pass.lines.at idx)
          idx += 1
        end
      end
      
      def render_static_lines pass
        # pass.static_lines.each      { |l| draw_line l }
        idx = 0
        length = pass.static_lines.length
        while idx < pass.static_lines.length
          draw_line (pass.static_lines.at idx)
          idx += 1
        end
      end

      def render_borders pass
        # pass.borders.each           { |b| draw_border b }
        idx = 0
        length = pass.borders.length
        while idx < length
          draw_border (pass.borders.at idx)
          idx += 1
        end
      end

      def render_static_borders pass
        # pass.static_borders.each    { |b| draw_border b }
        idx = 0
        length = pass.static_borders.length
        while idx < length
          draw_border (pass.static_borders.at idx)
          idx += 1
        end
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
