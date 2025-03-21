def tick args
  defaults args
  calc args
  render args
end

def defaults args
  tile_size = 100
  tiles_per_row = 32
  number_of_rows = 32
  number_of_tiles = tiles_per_row * number_of_rows

  # generate map tiles
  args.state.tiles ||= number_of_tiles.map_with_index do |i|
    row = i.idiv(tiles_per_row)
    col = i.mod(tiles_per_row)
    {
      x: row * tile_size,
      y: col * tile_size,
      w: tile_size,
      h: tile_size,
      path: 'sprites/square/blue.png'
    }
  end

  center_map = {
    x: tiles_per_row.idiv(2) * tile_size,
    y: number_of_rows.idiv(2) * tile_size,
    w: 1,
    h: 1
  }

  args.state.center_tile ||= args.state.tiles.find { |o| o.intersect_rect? center_map }
  args.state.selected_tile ||= args.state.center_tile

  # camera must have the following properties (x, y, and scale)
  if !args.state.camera
    args.state.camera = {
      x: 0,
      y: 0,
      scale: 1,
      target_x: 0,
      target_y: 0,
      target_scale: 1
    }

    args.state.camera.target_x = args.state.selected_tile.x + args.state.selected_tile.w.half
    args.state.camera.target_y = args.state.selected_tile.y + args.state.selected_tile.h.half
    args.state.camera.x = args.state.camera.target_x
    args.state.camera.y = args.state.camera.target_y
  end
end

def calc args
  calc_inputs args
  calc_camera args
end

def calc_inputs args
  # "i" to zoom in, "o" to zoom out
  if args.inputs.keyboard.key_down.i || args.inputs.keyboard.key_down.equal_sign || args.inputs.keyboard.key_down.plus
    args.state.camera.target_scale += 0.1 * args.state.camera.scale
  elsif args.inputs.keyboard.key_down.o || args.inputs.keyboard.key_down.minus
    args.state.camera.target_scale -= 0.1 * args.state.camera.scale
    args.state.camera.target_scale = 0.1 if args.state.camera.scale < 0.1
  end

  # "zero" to reset zoom and camera
  if args.inputs.keyboard.key_down.zero
    args.state.camera.target_scale = 1
    args.state.selected_tile = args.state.center_tile
  end

  # if mouse is clicked
  if args.inputs.mouse.click
    # convert the mouse to world space and delete any tiles that intersect with the mouse
    rect = Camera.to_world_space args.state.camera, args.inputs.mouse
    selected_tile = args.state.tiles.find { |o| rect.intersect_rect? o }
    if selected_tile
      args.state.selected_tile = selected_tile
      args.state.camera.target_scale = 1
    end
  end

  # "r" to reset
  if args.inputs.keyboard.key_down.r
    GTK.reset_next_tick
  end
end

def calc_camera args
  args.state.camera.target_x = args.state.selected_tile.x + args.state.selected_tile.w.half
  args.state.camera.target_y = args.state.selected_tile.y + args.state.selected_tile.h.half
  dx = args.state.camera.target_x - args.state.camera.x
  dy = args.state.camera.target_y - args.state.camera.y
  ds = args.state.camera.target_scale - args.state.camera.scale
  args.state.camera.x += dx * 0.1 * args.state.camera.scale
  args.state.camera.y += dy * 0.1 * args.state.camera.scale
  args.state.camera.scale += ds * 0.1
end

def render args
  args.outputs.background_color = [0, 0, 0]

  # define scene
  args.outputs[:scene].w = Camera::WORLD_SIZE
  args.outputs[:scene].h = Camera::WORLD_SIZE
  args.outputs[:scene].background_color = [0, 0, 0, 0]

  # render diagonals and background of scene
  args.outputs[:scene].lines << { x: 0, y: 0, x2: 1500, y2: 1500, r: 0, g: 0, b: 0, a: 255 }
  args.outputs[:scene].lines << { x: 0, y: 1500, x2: 1500, y2: 0, r: 0, g: 0, b: 0, a: 255 }
  args.outputs[:scene].solids << { x: 0, y: 0, w: 1500, h: 1500, a: 128 }

  # find all tiles to render
  objects_to_render = Camera.find_all_intersect_viewport args.state.camera, args.state.tiles

  # convert mouse to world space to see if it intersects with any tiles (hover color)
  mouse_in_world = Camera.to_world_space args.state.camera, args.inputs.mouse

  # for tiles that were found, convert the rect to screen coordinates and place them in scene
  args.outputs[:scene].sprites << objects_to_render.map do |o|
    if o == args.state.selected_tile
      tile_to_render = o.merge path: 'sprites/square/green.png'
    elsif o.intersect_rect? mouse_in_world
      tile_to_render = o.merge path: 'sprites/square/orange.png'
    else
      tile_to_render = o.merge path: 'sprites/square/blue.png'
    end

    Camera.to_screen_space args.state.camera, tile_to_render
  end

  # render scene to screen
  args.outputs.sprites << { **Camera.viewport, path: :scene }

  # render instructions
  args.outputs.sprites << { x: 0, y: 110.from_top, w: 1280, h: 110, path: :pixel, r: 0, g: 0, b: 0, a: 200 }
  label_style = { r: 255, g: 255, b: 255, anchor_y: 0.5 }
  args.outputs.labels << { x: 30, y: 30.from_top, text: "I/O or +/- keys to zoom in and zoom out (0 to reset camera, R to reset everything).", **label_style }
  args.outputs.labels << { x: 30, y: 60.from_top, text: "Click to center on square.", **label_style }
  args.outputs.labels << { x: 30, y: 90.from_top, text: "Mouse location in world: #{(Camera.to_world_space args.state.camera, args.inputs.mouse).to_sf}", **label_style }
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
        w: WORLD_SIZE,
        h: WORLD_SIZE
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
