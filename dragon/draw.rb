# coding: utf-8
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

        fn.each_send pass.solids,            self, :draw_solid
        fn.each_send pass.static_solids,     self, :draw_solid
        fn.each_send pass.sprites,           self, :draw_sprite
        fn.each_send pass.static_sprites,    self, :draw_sprite
        fn.each_send pass.primitives,        self, :draw_primitive
        fn.each_send pass.static_primitives, self, :draw_primitive
        fn.each_send pass.labels,            self, :draw_label
        fn.each_send pass.static_labels,     self, :draw_label
        fn.each_send pass.lines,             self, :draw_line
        fn.each_send pass.static_lines,      self, :draw_line
        fn.each_send pass.borders,           self, :draw_border
        fn.each_send pass.static_borders,    self, :draw_border

        if !self.production
          fn.each_send pass.debug,           self, :draw_primitive
          fn.each_send pass.static_debug,    self, :draw_primitive
        end

        fn.each_send pass.reserved,          self, :draw_primitive
        fn.each_send pass.static_reserved,   self, :draw_primitive
      rescue Exception => e
        pause!
        pretty_print_exception_and_export! e
      end

      def draw_solid s
        return unless s
        if s.respond_to? :draw_override
          s.draw_override @ffi_draw
        else
          s = s.as_hash if s.is_a? OpenEntity
          @ffi_draw.draw_solid_2 s.x, s.y, s.w, s.h,
                                 s.r, s.g, s.b, s.a,
                                 (s.blendmode_enum || 1)
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
          @ffi_draw.draw_sprite_4 s.x, s.y, s.w, s.h,
                                  (s.path || '').to_s,
                                  s.angle,
                                  s.a, s.r, s.g, s.b,
                                  s.tile_x, s.tile_y, s.tile_w, s.tile_h,
                                  !!s.flip_horizontally, !!s.flip_vertically,
                                  s.angle_anchor_x, s.angle_anchor_y,
                                  s.source_x, s.source_y, s.source_w, s.source_h,
                                  (s.blendmode_enum || 1)
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
          @ffi_draw.draw_label_3 l.x, l.y,
                                 (l.text || '').to_s,
                                 l.size_enum, l.alignment_enum,
                                 l.r, l.g, l.b, l.a,
                                 l.font,
                                 (l.vertical_alignment_enum || 2),
                                 (l.blendmode_enum || 1)
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
          @ffi_draw.draw_border_2 s.x, s.y, s.w, s.h,
                                  s.r, s.g, s.b, s.a,
                                  (s.blendmode_enum || 1)
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
