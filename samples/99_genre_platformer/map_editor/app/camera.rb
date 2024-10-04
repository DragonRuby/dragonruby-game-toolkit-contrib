class Camera
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  WORLD_SIZE = 1500
  WORLD_SIZE_HALF = WORLD_SIZE / 2
  OFFSET_X = (SCREEN_WIDTH - WORLD_SIZE) / 2
  OFFSET_Y = (SCREEN_HEIGHT - WORLD_SIZE) / 2

  class << self
    def to_world_space camera, rect
      x = (rect.x - WORLD_SIZE_HALF + camera.x * camera.scale - OFFSET_X) / camera.scale
      y = (rect.y - WORLD_SIZE_HALF + camera.y * camera.scale - OFFSET_Y) / camera.scale
      w = rect.w / camera.scale
      h = rect.h / camera.scale
      rect.merge x: x, y: y, w: w, h: h
    end

    def to_screen_space camera, rect
      x = rect.x * camera.scale - camera.x * camera.scale + WORLD_SIZE_HALF
      y = rect.y * camera.scale - camera.y * camera.scale + WORLD_SIZE_HALF
      w = rect.w * camera.scale
      h = rect.h * camera.scale
      rect.merge x: x, y: y, w: w, h: h
    end

    def viewport
      {
        x: OFFSET_X,
        y: OFFSET_Y,
        w: 1500,
        h: 1500
      }
    end

    def viewport_world camera
      to_world_space camera, viewport
    end

    def find_all_intersect_viewport camera, os
      Geometry.find_all_intersect_rect viewport_world(camera), os
    end
  end
end
