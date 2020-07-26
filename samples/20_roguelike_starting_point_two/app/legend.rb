def tick_legend args
  return unless SHOW_LEGEND

  legend_padding = 16
  legend_x = 1280 - TILE_SHEET_SIZE - legend_padding
  legend_y =  720 - TILE_SHEET_SIZE - legend_padding
  tile_sheet_sprite = [legend_x,
                       legend_y,
                       TILE_SHEET_SIZE,
                       TILE_SHEET_SIZE,
                       'sprites/simple-mood-16x16.png', 0,
                       TILE_A,
                       TILE_R,
                       TILE_G,
                       TILE_B]

  if args.inputs.mouse.point.inside_rect? tile_sheet_sprite
    mouse_row = args.inputs.mouse.point.y.idiv(SOURCE_TILE_SIZE)
    tile_row = 15 - (mouse_row - legend_y.idiv(SOURCE_TILE_SIZE))

    mouse_col = args.inputs.mouse.point.x.idiv(SOURCE_TILE_SIZE)
    tile_col = (mouse_col - legend_x.idiv(SOURCE_TILE_SIZE))

    args.outputs.primitives << [legend_x - legend_padding * 2,
                                mouse_row * SOURCE_TILE_SIZE, 256 + legend_padding * 2, 16, 128, 128, 128, 64].solid

    args.outputs.primitives << [mouse_col * SOURCE_TILE_SIZE,
                                legend_y - legend_padding * 2, 16, 256 + legend_padding * 2, 128, 128, 128, 64].solid

    sprite_key = sprite_lookup.find { |k, v| v == [tile_row, tile_col] }
    if sprite_key
      member_name, _ = sprite_key
      member_name = member_name_as_code member_name
      args.outputs.labels << [660, 70, "# CODE SAMPLE (place in the tick_game method located in main.rb)", -1, 0]
      args.outputs.labels << [660, 50, "#                                    GRID_X, GRID_Y, TILE_KEY", -1, 0]
      args.outputs.labels << [660, 30, "args.outputs.sprites << tile_in_game(     5,      6, #{member_name}    )", -1, 0]
    else
      args.outputs.labels << [660, 50, "Tile [#{tile_row}, #{tile_col}] not found. Add a key and value to app/sprite_lookup.rb:", -1, 0]
      args.outputs.labels << [660, 30, "{ \"some_string\" => [#{tile_row}, #{tile_col}] } OR { some_symbol: [#{tile_row}, #{tile_col}] }.", -1, 0]
    end

  end

  # render the sprite in the top right with a padding to the top and right so it's
  # not flush against the edge
  args.outputs.sprites << tile_sheet_sprite

  # carefully place some ascii arrows to show the legend labels
  args.outputs.labels  <<  [895, 707, "ROW --->"]
  args.outputs.labels  <<  [943, 412, "       ^"]
  args.outputs.labels  <<  [943, 412, "       |"]
  args.outputs.labels  <<  [943, 394, "COL ---+"]

  # use the tile sheet to print out row and column numbers
  args.outputs.sprites << 16.map_with_index do |i|
    sprite_key = i % 10
    [
      tile(1280 - TILE_SHEET_SIZE - legend_padding * 2 - SOURCE_TILE_SIZE,
            720 - legend_padding * 2 - (SOURCE_TILE_SIZE * i),
            sprite(sprite_key)),
      tile(1280 - TILE_SHEET_SIZE - SOURCE_TILE_SIZE + (SOURCE_TILE_SIZE * i),
            720 - TILE_SHEET_SIZE - legend_padding * 3, sprite(sprite_key))
    ]
  end
end
