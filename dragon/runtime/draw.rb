# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# draw.rb has been released under MIT (*only this file*).

module GTK
  class Runtime
    module Draw
      def draw_solid s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          s = s.as_hash if s.is_a? OpenEntity
          w = s.w
          h = s.h
          anchor_x = 0
          anchor_y = 0
          anchor_x = s.anchor_x if s.respond_to? :anchor_x
          anchor_y = s.anchor_y if s.respond_to? :anchor_y
          if !w && !h
            @ffi_draw.draw_triangle_2 s.x, s.y, s.x2, s.y2, s.x3, s.y3,
                                      s.r, s.g, s.b, s.a,
                                      nil, nil, nil, nil, nil, nil, nil,
                                      (s.blendmode_enum || 1),
                                      s.r2, s.g2, s.b2, s.a2,
                                      s.r3, s.g3, s.b3, s.a3
          else
            @ffi_draw.draw_solid_3 s.x, s.y, w, h,
                                   s.r, s.g, s.b, s.a,
                                   (s.blendmode_enum || 1), anchor_x, anchor_y
          end
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed s, e, :solid
      end

      def draw_sprite s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          s = s.as_hash if s.is_a? OpenEntity
          w = s.w
          h = s.h
          if !w && !h
            @ffi_draw.draw_triangle s.x, s.y, s.x2, s.y2, s.x3, s.y3,
                                    s.r || 255,
                                    s.g || 255,
                                    s.b || 255,
                                    s.a || 255,
                                    s.path || 'pixel',
                                    s.source_x,
                                    s.source_y,
                                    s.source_x2,
                                    s.source_y2,
                                    s.source_x3,
                                    s.source_y3,
                                    (s.blendmode_enum || 1)
          else
            if s.is_a? Hash
              @ffi_draw.draw_sprite_hash s
            else
              anchor_x = nil
              anchor_x = s.anchor_x if s.respond_to? :anchor_x

              anchor_y = nil
              anchor_y = s.anchor_y if s.respond_to? :anchor_y

              scale_quality_enum = nil
              scale_quality_enum = s.scale_quality_enum if s.respond_to? :scale_quality_enum

              @ffi_draw.draw_sprite_6 s.x, s.y, w, h,
                                      (s.path || 'pixel').to_s,
                                      s.angle,
                                      s.a, s.r, s.g, s.b,
                                      s.tile_x, s.tile_y, s.tile_w, s.tile_h,
                                      !!s.flip_horizontally, !!s.flip_vertically,
                                      s.angle_anchor_x, s.angle_anchor_y,
                                      s.source_x, s.source_y, s.source_w, s.source_h,
                                      (s.blendmode_enum || 1), anchor_x, anchor_y,
                                      scale_quality_enum
            end
          end
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed s, e, :sprite
      end

      def draw_screenshot s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          s = s.as_hash if s.is_a? OpenEntity
          @ffi_draw.draw_screenshot (s.path || '').to_s,
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
          l = l.as_hash if l.is_a? OpenEntity

          size_px = if l.respond_to? :size_px
                      l.size_px
                    else
                      nil
                    end

          anchor_x = if l.respond_to? :anchor_x
                       l.anchor_x
                     else
                       nil
                     end

          anchor_y = if l.respond_to? :anchor_y
                       l.anchor_y
                     else
                       nil
                     end

          @ffi_draw.draw_label_5 l.x, l.y,
                                 (l.text || '').to_s,
                                 l.size_enum, l.alignment_enum,
                                 l.r, l.g, l.b, l.a,
                                 l.font,
                                 (l.vertical_alignment_enum || 2),
                                 (l.blendmode_enum || 1), size_px,
                                 anchor_x, anchor_y
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed l, e, :label
      end

      def draw_line l
        return unless l
        if l.respond_to? :draw_override
          l.draw_override @ffi_draw
        else
          l = l.as_hash if l.is_a? OpenEntity
          if l.x2
            @ffi_draw.draw_line_2 l.x, l.y, l.x2, l.y2,
                                  l.r, l.g, l.b, l.a,
                                  (l.blendmode_enum || 1)
          else
            w = l.w || 0
            w = 1 if w == 0
            h = l.h || 0
            h = 1 if h == 0
            @ffi_draw.draw_line_2 l.x, l.y,
                                  l.x + w - 1,
                                  l.y + h - 1,
                                  l.r, l.g, l.b, l.a,
                                  (l.blendmode_enum || 1)
          end
        end
      rescue Exception => e
        raise_conversion_for_rendering_failed l, e, :line
      end

      def draw_border s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          s = s.as_hash if s.is_a? OpenEntity
          anchor_x = 0
          anchor_y = 0
          anchor_x = s.anchor_x if s.respond_to? :anchor_x
          anchor_y = s.anchor_y if s.respond_to? :anchor_y
          @ffi_draw.draw_border_3 s.x, s.y, s.w, s.h,
                                  s.r, s.g, s.b, s.a,
                                  (s.blendmode_enum || 1), anchor_x, anchor_y
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

      def draw_primitive p
        return unless p

        if p.primitive_marker == :solid
          return draw_solid p
        elsif p.primitive_marker == :sprite
          return draw_sprite p
        elsif p.primitive_marker == :label
          return draw_label p
        elsif p.primitive_marker == :line
          return draw_line p
        elsif p.primitive_marker == :border
          return draw_border p
        else
          raise <<-S
* ERROR:
#{p}

I don't know how to use the above #{p.class} with SDL's FFI. Please
add a method on the object called ~primitive_marker~ that
returns :solid, :sprite, :label, :line, or :border. If the object
is a Hash, please add { primitive_marker: :PRIMITIVE_SYMBOL } to the Hash.

S
        end
      rescue Exception => e
        pause!
        pretty_print_exception_and_export! e
      end
    end
  end
end
