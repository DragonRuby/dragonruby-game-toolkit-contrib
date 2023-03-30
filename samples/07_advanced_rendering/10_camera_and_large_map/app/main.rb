def tick args
  # you want to make sure all of your pngs are a maximum size of 1280x1280
  # low-end android devices and machines with underpowered GPUs are unable to
  # load very large textures.

  # this sample app creates 640x640 tiles of a 6400x6400 pixel png and displays them
  # on the screen relative to the player's position

  # tile creation process
  create_tiles_if_needed args

  # if tiles are already present the show map
  display_tiles args
end

def display_tiles args
  # set the player's starting location
  args.state.player ||= {
    x:  0,
    y:  0,
    w: 40,
    h: 40,
    path: "sprites/square/blue.png"
  }

  # if all tiles have been created, then we are
  # in "displaying_tiles" mode
  if args.state.displaying_tiles
    # create a render target that can hold 9 640x640 tiles
    args.outputs[:scene].background_color = [0, 0, 0, 0]
    args.outputs[:scene].w = 1920
    args.outputs[:scene].h = 1920

    # allow player to be moved with arrow keys
    args.state.player.x += args.inputs.left_right * 10
    args.state.player.y += args.inputs.up_down * 10

    # given the player's location, return a collection of primitives
    # to render that are within the 1920x1920 viewport
    args.outputs[:scene].primitives << tiles_in_viewport(args)

    # place the player in the center of the render_target
    args.outputs[:scene].primitives << {
      x: 960 - 20,
      y: 960 - 20,
      w: 40,
      h: 40,
      path: "sprites/square/blue.png"
    }

    # center the 1920x1920 render target within the 1280x720 window
    args.outputs.sprites << {
      x: -320,
      y: -600,
      w: 1920,
      h: 1920,
      path: :scene
    }
  end
end

def tiles_in_viewport args
  state = args.state
  # define the size of each tile
  tile_size = 640

  # determine what tile the player is on
  tile_player_is_on = { x: state.player.x.idiv(tile_size), y: state.player.y.idiv(tile_size) }

  # calculate the x and y offset of the player so that tiles are positioned correctly
  offset_x = 960 - (state.player.x - (tile_player_is_on.x * tile_size))
  offset_y = 960 - (state.player.y - (tile_player_is_on.y * tile_size))

  primitives = []

  # get 9 tiles in total (the tile the player is on and the 8 surrounding tiles)

  # center tile
  primitives << (tile_in_viewport size:       tile_size,
                                  from_row:   tile_player_is_on.y,
                                  from_col:   tile_player_is_on.x,
                                  offset_row: 0,
                                  offset_col: 0,
                                  dy:         offset_y,
                                  dx:         offset_x)

  # tile to the right
  primitives << (tile_in_viewport size:       tile_size,
                                  from_row:   tile_player_is_on.y,
                                  from_col:   tile_player_is_on.x,
                                  offset_row: 0,
                                  offset_col: 1,
                                  dy:         offset_y,
                                  dx:         offset_x)
  # tile to the left
  primitives << (tile_in_viewport size:        tile_size,
                                  from_row:    tile_player_is_on.y,
                                  from_col:    tile_player_is_on.x,
                                  offset_row:  0,
                                  offset_col: -1,
                                  dy:          offset_y,
                                  dx:          offset_x)

  # tile directly above
  primitives << (tile_in_viewport size:       tile_size,
                                  from_row:   tile_player_is_on.y,
                                  from_col:   tile_player_is_on.x,
                                  offset_row: 1,
                                  offset_col: 0,
                                  dy:         offset_y,
                                  dx:         offset_x)
  # tile directly below
  primitives << (tile_in_viewport size:         tile_size,
                                  from_row:     tile_player_is_on.y,
                                  from_col:     tile_player_is_on.x,
                                  offset_row:  -1,
                                  offset_col:   0,
                                  dy:           offset_y,
                                  dx:           offset_x)
  # tile up and to the left
  primitives << (tile_in_viewport size:        tile_size,
                                  from_row:    tile_player_is_on.y,
                                  from_col:    tile_player_is_on.x,
                                  offset_row:  1,
                                  offset_col: -1,
                                  dy:          offset_y,
                                  dx:          offset_x)

  # tile up and to the right
  primitives << (tile_in_viewport size:       tile_size,
                                  from_row:   tile_player_is_on.y,
                                  from_col:   tile_player_is_on.x,
                                  offset_row: 1,
                                  offset_col: 1,
                                  dy:         offset_y,
                                  dx:         offset_x)

  # tile down and to the left
  primitives << (tile_in_viewport size:        tile_size,
                                  from_row:    tile_player_is_on.y,
                                  from_col:    tile_player_is_on.x,
                                  offset_row: -1,
                                  offset_col: -1,
                                  dy:          offset_y,
                                  dx:          offset_x)

  # tile down and to the right
  primitives << (tile_in_viewport size:        tile_size,
                                  from_row:    tile_player_is_on.y,
                                  from_col:    tile_player_is_on.x,
                                  offset_row: -1,
                                  offset_col:  1,
                                  dy:          offset_y,
                                  dx:          offset_x)

  primitives
end

def tile_in_viewport size:, from_row:, from_col:, offset_row:, offset_col:, dy:, dx:;
  x = size * offset_col + dx
  y = size * offset_row + dy

  return nil if (from_row + offset_row) < 0
  return nil if (from_row + offset_row) > 9

  return nil if (from_col + offset_col) < 0
  return nil if (from_col + offset_col) > 9

  # return the tile sprite, a border demarcation, and label of which tile x and y
  [
    {
      x: x,
      y: y,
      w: size,
      h: size,
      path: "sprites/tile-#{from_col + offset_col}-#{from_row + offset_row}.png",
    },
    {
      x: x,
      y: y,
      w: size,
      h: size,
      r: 255,
      primitive_marker: :border,
    },
    {
      x: x + size / 2 - 150,
      y: y + size / 2 - 25,
      w: 300,
      h: 50,
      primitive_marker: :solid,
      r: 0,
      g: 0,
      b: 0,
      a: 128
    },
    {
      x: x + size / 2,
      y: y + size / 2,
      text: "tile #{from_col + offset_col}, #{from_row + offset_row}",
      alignment_enum: 1,
      vertical_alignment_enum: 1,
      size_enum: 2,
      r: 255,
      g: 255,
      b: 255
    },
  ]
end

def create_tiles_if_needed args
  # We are going to use args.outputs.screenshots to generate tiles of a
  # png of size 6400x6400 called sprites/large.png.
  if !args.gtk.stat_file("sprites/tile-9-9.png") && !args.state.creating_tiles
    args.state.displaying_tiles = false
    args.outputs.labels << {
      x: 960,
      y: 360,
      text: "Press enter to generate tiles of sprites/large.png.",
      alignment_enum: 1,
      vertical_alignment_enum: 1
    }
  elsif !args.state.creating_tiles
    args.state.displaying_tiles = true
  end

  # pressing enter will start the tile creation process
  if args.inputs.keyboard.key_down.enter && !args.state.creating_tiles
    args.state.displaying_tiles = false
    args.state.creating_tiles = true
    args.state.tile_clock = 0
  end

  # the tile creation process renders an area of sprites/large.png
  # to the screen and takes a screenshot of it every half second
  # until all tiles are generated.
  # once all tiles are generated a map viewport will be rendered that
  # stitches tiles together.
  if args.state.creating_tiles
    args.state.tile_x ||= 0
    args.state.tile_y ||= 0

    # render a sub-square of the large png.
    args.outputs.sprites << {
      x: 0,
      y: 0,
      w: 640,
      h: 640,
      source_x: args.state.tile_x * 640,
      source_y: args.state.tile_y * 640,
      source_w: 640,
      source_h: 640,
      path: "sprites/large.png"
    }

    # determine tile file name
    tile_path = "sprites/tile-#{args.state.tile_x}-#{args.state.tile_y}.png"

    args.outputs.labels << {
      x: 960,
      y: 320,
      text: "Generating #{tile_path}",
      alignment_enum: 1,
      vertical_alignment_enum: 1
    }

    # take a screenshot on frames divisible by 29
    if args.state.tile_clock.zmod?(29)
      args.outputs.screenshots << {
        x: 0,
        y: 0,
        w: 640,
        h: 640,
        path: tile_path,
        a: 255
      }
    end

    # increment tile to render on frames divisible by 30 (half a second)
    # (one frame is allotted to take screenshot)
    if args.state.tile_clock.zmod?(30)
      args.state.tile_x += 1
      if args.state.tile_x >= 10
        args.state.tile_x  = 0
        args.state.tile_y += 1
      end

      # once all of tile tiles are created, begin displaying map
      if args.state.tile_y >= 10
        args.state.creating_tiles = false
        args.state.displaying_tiles = true
      end
    end

    args.state.tile_clock += 1
  end
end

$gtk.reset
