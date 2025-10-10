def tick args
  # camera must have the following properties (x, y, and scale)
  args.state.camera ||= {
    x: 0,
    y: 0,
    scale: 1
  }

  args.state.camera.x += args.inputs.left_right * 10 * args.state.camera.scale
  args.state.camera.y += args.inputs.up_down * 10 * args.state.camera.scale

  # generate 500 shapes with random positions
  args.state.objects ||= 500.map do
    {
      x: -2000 + rand(4000),
      y: -2000 + rand(4000),
      w: 16,
      h: 16,
      path: 'sprites/square/blue.png'
    }
  end

  # "i" to zoom in, "o" to zoom out
  if args.inputs.keyboard.key_down.i || args.inputs.keyboard.key_down.equal_sign || args.inputs.keyboard.key_down.plus
    args.state.camera.scale += 0.1
  elsif args.inputs.keyboard.key_down.o || args.inputs.keyboard.key_down.minus
    args.state.camera.scale -= 0.1
    args.state.camera.scale = 0.1 if args.state.camera.scale < 0.1
  end

  # "zero" to reset zoom and camera
  if args.inputs.keyboard.key_down.zero
    args.state.camera.scale = 1
    args.state.camera.x = 0
    args.state.camera.y = 0
  end

  # if mouse is clicked
  if args.inputs.mouse.click
    # convert the mouse to world space and delete any objects that intersect with the mouse
    rect = Camera.to_world_space args.state.camera, args.inputs.mouse.rect
    args.state.objects.reject! { |o| rect.intersect_rect? o }
  end

  # "r" to reset
  if args.inputs.keyboard.key_down.r
    GTK.reset_next_tick
  end

  # define scene
  args.outputs[:scene].w = Camera.viewport_w
  args.outputs[:scene].h = Camera.viewport_h

  # render diagonals and background of scene
  args.outputs[:scene].lines << { x: 0, y: 0, x2: Camera.viewport_w, y2: Camera.viewport_h, r: 0, g: 0, b: 0, a: 255 }
  args.outputs[:scene].lines << { x: 0, y: Camera.viewport_h, x2: Camera.viewport_w, y2: 0, r: 0, g: 0, b: 0, a: 255 }
  args.outputs[:scene].solids << { x: 0, y: 0, w: Camera.viewport_w, h: Camera.viewport_w, a: 128 }

  # find all objects to render
  objects_to_render = Camera.find_all_intersect_viewport args.state.camera, args.state.objects

  # for objects that were found, convert the rect to screen coordinates and place them in scene
  args.outputs[:scene].sprites << objects_to_render.map { |o| Camera.to_screen_space args.state.camera, o }

  # render scene to screen
  args.outputs.sprites << { **Camera.viewport, path: :scene }

  # render instructions
  args.outputs.sprites << { x: 0, y: 110.from_top, w: 1280, h: 110, path: :pixel, r: 0, g: 0, b: 0, a: 128 }
  label_style = { r: 255, g: 255, b: 255, anchor_y: 0.5 }
  args.outputs.labels << { x: 30, y: 30.from_top, text: "Arrow keys to move around. I and O Keys to zoom in and zoom out (0 to reset camera, R to reset everything).", **label_style }
  args.outputs.labels << { x: 30, y: 60.from_top, text: "Click square to remove from world.", **label_style }
  args.outputs.labels << { x: 30, y: 90.from_top, text: "Mouse locationin world: #{(Camera.to_world_space args.state.camera, args.inputs.mouse.rect).to_sf}", **label_style }
end

# helper methods to create a camera and go to and from screen space and world space
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

GTK.reset
