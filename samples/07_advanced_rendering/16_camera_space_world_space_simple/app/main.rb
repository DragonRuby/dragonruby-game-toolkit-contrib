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
    rect = Camera.to_world_space args.state.camera, args.inputs.mouse
    args.state.objects.reject! { |o| rect.intersect_rect? o }
  end

  # "r" to reset
  if args.inputs.keyboard.key_down.r
    GTK.reset_next_tick
  end

  # define scene
  args.outputs[:scene].w = Camera::WORLD_SIZE
  args.outputs[:scene].h = Camera::WORLD_SIZE

  # render diagonals and background of scene
  args.outputs[:scene].lines << { x: 0, y: 0, x2: 1500, y2: 1500, r: 0, g: 0, b: 0, a: 255 }
  args.outputs[:scene].lines << { x: 0, y: 1500, x2: 1500, y2: 0, r: 0, g: 0, b: 0, a: 255 }
  args.outputs[:scene].solids << { x: 0, y: 0, w: 1500, h: 1500, a: 128 }

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
  args.outputs.labels << { x: 30, y: 90.from_top, text: "Mouse locationin world: #{(Camera.to_world_space args.state.camera, args.inputs.mouse).to_sf}", **label_style }
end

# helper methods to create a camera and go to and from screen space and world space
class Camera
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  WORLD_SIZE = 1500
  WORLD_SIZE_HALF = WORLD_SIZE / 2
  OFFSET_X = (SCREEN_WIDTH - WORLD_SIZE) / 2
  OFFSET_Y = (SCREEN_HEIGHT - WORLD_SIZE) / 2

  class << self
    # given a rect in screen space, converts the rect to world space
    def to_world_space camera, rect
      rect_x = rect.x
      rect_y = rect.y
      rect_w = rect.w || 0
      rect_h = rect.h || 0
      x = (rect_x - WORLD_SIZE_HALF + camera.x * camera.scale - OFFSET_X) / camera.scale
      y = (rect_y - WORLD_SIZE_HALF + camera.y * camera.scale - OFFSET_Y) / camera.scale
      w = rect_w / camera.scale
      h = rect_h / camera.scale
      rect.merge x: x, y: y, w: w, h: h
    end

    # given a rect in world space, converts the rect to screen space
    def to_screen_space camera, rect
      rect_x = rect.x
      rect_y = rect.y
      rect_w = rect.w || 0
      rect_h = rect.h || 0
      x = rect_x * camera.scale - camera.x * camera.scale + WORLD_SIZE_HALF
      y = rect_y * camera.scale - camera.y * camera.scale + WORLD_SIZE_HALF
      w = rect_w * camera.scale
      h = rect_h * camera.scale
      rect.merge x: x, y: y, w: w, h: h
    end

    # viewport of the scene
    def viewport
      {
        x: OFFSET_X,
        y: OFFSET_Y,
        w: 1500,
        h: 1500
      }
    end

    # viewport in the context of the world
    def viewport_world camera
      to_world_space camera, viewport
    end

    # helper method to find objects within viewport
    def find_all_intersect_viewport camera, os
      Geometry.find_all_intersect_rect viewport_world(camera), os
    end
  end
end

GTK.reset
