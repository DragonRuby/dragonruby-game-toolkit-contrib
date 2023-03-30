def tick_toolbar args
  # ================================================
  # tollbar defaults
  # ================================================
  if !args.state.toolbar
    # these are the tiles you can select from
    tile_definitions = [
      { name: "16-12", left_height: 16, right_height: 12  },
      { name: "12-8",  left_height: 12, right_height: 8   },
      { name: "8-4",   left_height: 8,  right_height: 4   },
      { name: "4-0",   left_height: 4,  right_height: 0   },
      { name: "0-4",   left_height: 0,  right_height: 4   },
      { name: "4-8",   left_height: 4,  right_height: 8   },
      { name: "8-12",  left_height: 8,  right_height: 12  },
      { name: "12-16", left_height: 12, right_height: 16  },

      { name: "16-8",  left_height: 16, right_height: 8   },
      { name: "8-0",   left_height: 8,  right_height: 0   },
      { name: "0-8",   left_height: 0,  right_height: 8   },
      { name: "8-16",  left_height: 8,  right_height: 16  },

      { name: "0-0",   left_height: 0,  right_height: 0   },
      { name: "8-8",   left_height: 8,  right_height: 8   },
      { name: "16-16", left_height: 16, right_height: 16  },
    ]

    # toolbar data representation which will be used to render the toolbar.
    # the buttons array will be used to render the buttons
    # the toolbar_rect will be used to restrict the creation of tiles
    # within the toolbar area
    args.state.toolbar = {
      toolbar_rect: nil,
      buttons: []
    }

    # for each tile definition, create a button
    args.state.toolbar.buttons = tile_definitions.map_with_index do |spec, index|
      left_height  = spec.left_height
      right_height = spec.right_height
      button_size  = 48
      column_size  = 15
      column_padding = 2
      column = index % column_size
      column_padding = column * column_padding
      margin = 10
      row = index.idiv(column_size)
      row_padding = row * 2
      x = margin + column_padding + (column * button_size)
      y = (margin + button_size + row_padding + (row * button_size)).from_top

      # when a tile is added, the data of this button will be used
      # to construct the terrain

      # each tile has an x, y, w, h which represents the bounding box
      # of the button.
      # the button also contains the left_height and right_height which is
      # important when determining collision of the ramps
      {
        name: spec.name,
        left_height: left_height,
        right_height: right_height,
        button_rect: {
          x: x,
          y: y,
          w: 48,
          h: 48
        }
      }
    end

    # with the buttons populated, compute the bounding box of the entire
    # toolbar (again this will be used to restrict the creation of tiles)
    min_x = args.state.toolbar.buttons.map { |t| t.button_rect.x }.min
    min_y = args.state.toolbar.buttons.map { |t| t.button_rect.y }.min

    max_x = args.state.toolbar.buttons.map { |t| t.button_rect.x }.max
    max_y = args.state.toolbar.buttons.map { |t| t.button_rect.y }.max

    args.state.toolbar.rect = {
      x: min_x - 10,
      y: min_y - 10,
      w: max_x - min_x + 10 + 64,
      h: max_y - min_y + 10 + 64
    }
  end

  # set the selected tile to the last button in the toolbar
  args.state.selected_tile ||= args.state.toolbar.buttons.last

  # ================================================
  # starting terrain generation
  # ================================================
  if !args.state.terrain
    world = [
      { row: 14, col: 25, name: "0-8"   },
      { row: 14, col: 26, name: "8-16"  },
      { row: 15, col: 27, name: "0-8"   },
      { row: 15, col: 28, name: "8-16"  },
      { row: 16, col: 29, name: "0-8"   },
      { row: 16, col: 30, name: "8-16"  },
      { row: 17, col: 31, name: "0-8"   },
      { row: 17, col: 32, name: "8-16"  },
      { row: 18, col: 33, name: "0-8"   },
      { row: 18, col: 34, name: "8-16"  },
      { row: 18, col: 35, name: "16-12" },
      { row: 18, col: 36, name: "12-8"  },
      { row: 18, col: 37, name: "8-4"   },
      { row: 18, col: 38, name: "4-0"   },
      { row: 18, col: 39, name: "0-0"   },
      { row: 18, col: 40, name: "0-0"   },
      { row: 18, col: 41, name: "0-0"   },
      { row: 18, col: 42, name: "0-4"   },
      { row: 18, col: 43, name: "4-8"   },
      { row: 18, col: 44, name: "8-12"  },
      { row: 18, col: 45, name: "12-16" },
    ]

    args.state.terrain = world.map do |tile|
      template = tile_by_name(args, tile.name)
      next if !template
      grid_rect = grid_rect_for(tile.row, tile.col)
      new_terrain_definition(grid_rect, template)
    end
  end

  # ================================================
  # toolbar input and rendering
  # ================================================
  # store the mouse position alligned to the tile grid
  mouse_grid_aligned_rect = grid_aligned_rect args.inputs.mouse, 16

  # determine if the mouse intersects the toolbar
  mouse_intersects_toolbar = args.state.toolbar.rect.intersect_rect? args.inputs.mouse

  # determine if the mouse intersects a toolbar button
  toolbar_button = args.state.toolbar.buttons.find { |t| t.button_rect.intersect_rect? args.inputs.mouse }

  # determine if the mouse click occurred over a tile in the terrain
  terrain_tile = args.geometry.find_intersect_rect mouse_grid_aligned_rect, args.state.terrain


  # if a mouse click occurs....
  if args.inputs.mouse.click
    if toolbar_button
      # if a toolbar button was clicked, set the currently selected tile to the toolbar tile
      args.state.selected_tile = toolbar_button
    elsif terrain_tile
      # if a tile was clicked, delete it from the terrain
      args.state.terrain.delete terrain_tile
    elsif !args.state.toolbar.rect.intersect_rect? args.inputs.mouse
      # if the mouse was not clicked in the toolbar area
      # add a new terrain based off of the information in the selected tile
      args.state.terrain << new_terrain_definition(mouse_grid_aligned_rect, args.state.selected_tile)
    end
  end

  # render a light blue background for the toolbar button that is currently
  # being hovered over (if any)
  if toolbar_button
    args.outputs.primitives << toolbar_button.button_rect.merge(primitive_marker: :solid, a: 10, b: 255)
  end

  # put a blue background around the currently selected tile
  args.outputs.primitives << args.state.selected_tile.button_rect.merge(primitive_marker: :solid, b: 255)

  if !mouse_intersects_toolbar
    if terrain_tile
      # if the mouse is hoving over an existing terrain tile, render a red border around the
      # tile to signify that it will be deleted if the mouse is clicked
      args.outputs.borders << terrain_tile.merge(a: 255, r: 255)
    else
      # if the mouse is not hovering over an existing terrain tile, render the currently
      # selected tile at the mouse position
      grid_aligned_rect = grid_aligned_rect args.inputs.mouse, 16

      args.outputs.solids << {
        **grid_aligned_rect,
        a: 30,
        g: 128
      }

      args.outputs.lines << {
        x:  grid_aligned_rect.x,
        y:  grid_aligned_rect.y + args.state.selected_tile.left_height,
        x2: grid_aligned_rect.x + grid_aligned_rect.w,
        y2: grid_aligned_rect.y + args.state.selected_tile.right_height,
      }
    end
  end

  # render each toolbar button using two primitives, a border to denote
  # the click area of the button, and a line to denote the terrain that
  # will be created when the button is clicked
  args.outputs.primitives << args.state.toolbar.buttons.map do |toolbar_tile|
    primitives = []
    scale = toolbar_tile.button_rect.w / 16

    primitive_type = :border

    [
      {
        **toolbar_tile.button_rect,
        primitive_marker: primitive_type,
        a: 64,
      },
      {
        x:  toolbar_tile.button_rect.x,
        y:  toolbar_tile.button_rect.y + toolbar_tile.left_height * scale,
        x2: toolbar_tile.button_rect.x + toolbar_tile.button_rect.w,
        y2: toolbar_tile.button_rect.y + toolbar_tile.right_height * scale
      }
    ]
  end
end

# ================================================
# helper methods
#=================================================

# converts a row and column on the grid to
# a rect
def grid_rect_for row, col
  { x: col * 16, y: row * 16, w: 16, h: 16 }
end

# find a tile by name
def tile_by_name args, name
  args.state.toolbar.buttons.find { |b| b.name == name }
end

# data structure containing terrain information
# specifcially tile.left_height and tile.right_height
def new_terrain_definition grid_rect, tile
  grid_rect.merge(
    tile: tile,
    line: {
      x:  grid_rect.x,
      y:  grid_rect.y + tile.left_height,
      x2: grid_rect.x + grid_rect.w,
      y2: grid_rect.y + tile.right_height
    }
  )
end

# helper method that returns a grid aligned rect given
# an arbitrary rect and a grid size
def grid_aligned_rect point, size
  grid_aligned_x = point.x - (point.x % size)
  grid_aligned_y = point.y - (point.y % size)
  { x: grid_aligned_x.to_i, y: grid_aligned_y.to_i, w: size.to_i, h: size.to_i }
end
