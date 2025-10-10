class Camera
  class << self
    def viewport_w
      Grid.allscreen_w
    end

    def viewport_h
      Grid.allscreen_h
    end

    def viewport_w_half
      if Grid.origin_center?
        0
      else
        Grid.allscreen_w.fdiv(2).ceil
      end
    end

    def viewport_h_half
      if Grid.origin_center?
        0
      else
        Grid.allscreen_h.fdiv(2).ceil
      end
    end

    def viewport_offset_x
      if Grid.origin_center?
        0
      else
        Grid.allscreen_x
      end
    end

    def viewport_offset_y
      if Grid.origin_center?
        0
      else
        Grid.allscreen_y
      end
    end

    def __to_world_space__ camera, rect
      return nil if !rect

      x = (rect.x - viewport_w_half + camera.x * camera.scale - viewport_offset_x) / camera.scale
      y = (rect.y - viewport_h_half + camera.y * camera.scale - viewport_offset_y) / camera.scale

      if rect.w
        w = rect.w / camera.scale
        h = rect.h / camera.scale
        { **rect, x: x, y: y, w: w, h: h }
      else
        { **rect, x: x, y: y }
      end
    end

    def to_world_space camera, rect
      if rect.is_a? Array
        rect.map { |r| to_world_space camera, rect }
      else
        __to_world_space__ camera, rect
      end
    end

    def __to_screen_space__ camera, rect
      return nil if !rect

      x = rect.x * camera.scale - camera.x * camera.scale + viewport_w_half
      y = rect.y * camera.scale - camera.y * camera.scale + viewport_h_half

      if rect.w
        w = rect.w * camera.scale
        h = rect.h * camera.scale
        { **rect, x: x, y: y, w: w, h: h }
      else
        { **rect, x: x, y: y }
      end
    end

    def to_screen_space camera, rect
      if rect.is_a? Array
        rect.map { |r| to_screen_space camera, r }
      else
        __to_screen_space__ camera, rect
      end
    end

    def viewport
      if Grid.origin_center?
        {
          x: viewport_offset_x,
          y: viewport_offset_y,
          w: viewport_w,
          h: viewport_h,
          anchor_x: 0.5,
          anchor_y: 0.5
        }
      else
        {
          x: viewport_offset_x,
          y: viewport_offset_y,
          w: viewport_w,
          h: viewport_h,
        }
      end
    end

    def viewport_world camera
      to_world_space camera, viewport
    end

    def find_all_intersect_viewport camera, os
      Geometry.find_all_intersect_rect viewport_world(camera), os
    end
  end
end
