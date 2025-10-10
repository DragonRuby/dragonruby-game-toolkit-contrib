SOURCE_TILE_SIZE = 16
DESTINATION_TILE_SIZE = 16
TILE_SHEET_SIZE = 256

class Game
  attr_gtk

  # this is the mapping of ascii characters to locations on the tile sheet
  def sprite_lookup
    {
      '@' => [4, 0], '|' => [7, 12],
      0 => [3, 0], 1 => [3, 1], 2 => [3, 2], 3 => [3, 3], 4 => [3, 4],
      5 => [3, 5], 6 => [3, 6], 7 => [3, 7], 8 => [3, 8], 9 => [3, 9],
      A: [4,  1], B: [4,  2], C: [4,  3], D: [4,  4],
      E: [4,  5], F: [4,  6], G: [4,  7], H: [4,  8],
      I: [4,  9], J: [4, 10], K: [4, 11], L: [4, 12],
      M: [4, 13], N: [4, 14], O: [4, 15], P: [5,  0],
      Q: [5,  1], R: [5,  2], S: [5,  3], T: [5,  4],
      U: [5,  5], V: [5,  6], W: [5,  7], X: [5,  8],
      Y: [5,  9], Z: [5, 10], a: [6,  1], b: [6,  2],
      c: [6,  3], d: [6,  4], e: [6,  5], f: [6,  6],
      g: [6,  7], h: [6,  8], i: [6,  9], j: [6, 10],
      k: [6, 11], l: [6, 12], m: [6, 13], n: [6, 14],
      o: [6, 15], p: [7,  0], q: [7,  1], r: [7,  2],
      s: [7,  3], t: [7,  4], u: [7,  5], v: [7,  6],
      w: [7,  7], x: [7,  8], y: [7,  9], z: [7, 10],
    }
  end

  def tick
    # the main tick for the game
    tick_game

    # this renders help text for getting tile locations
    tick_legend
  end

  def tick_game
    state.sprite_lookup ||= sprite_lookup

    # setup the world
    state.world ||= {
      padding: 104,
      sz: 512
    }

    # set up your game
    # initialize the game/game defaults. ||= means that you only initialize it if
    # the value isn't alread initialized
    state.player ||= {
      x: 0,
      y: 0
    }

    state.enemies ||= [
      { x: 10, y: 10, type: :goblin, tile_key: :G },
      { x: 15, y: 30, type: :rat,    tile_key: :R }
    ]

    state.info_message ||= "Use arrow keys to move around."

    # handle keyboard input
    # keyboard input (arrow keys to move player)
    new_player_x = state.player.x
    new_player_y = state.player.y
    player_direction = ""
    player_moved = false
    if inputs.keyboard.key_down.up && state.player.y < 31
      new_player_y += 1
      player_direction = "north"
      player_moved = true
    elsif inputs.keyboard.key_down.down && state.player.y > 0
      new_player_y -= 1
      player_direction = "south"
      player_moved = true
    elsif inputs.keyboard.key_down.right && state.player.x < 31
      new_player_x += 1
      player_direction = "east"
      player_moved = true
    elsif inputs.keyboard.key_down.left && state.player.x > 0
      new_player_x -= 1
      player_direction = "west"
      player_moved = true
    end

    #handle game logic
    # determine if there is an enemy on that square,
    # if so, don't let the player move there
    if player_moved
      found_enemy = state.enemies.find do |e|
        e.x == new_player_x && e.y == new_player_y
      end

      if !found_enemy
        state.player.x = new_player_x
        state.player.y = new_player_y
        state.info_message = "You moved #{player_direction}."
      else
        state.info_message = "You cannot move into a square an enemy occupies."
      end
    end

    outputs.sprites << tile_in_game(x: state.player.x, y: state.player.y, tile_key: '@')

    # render game
    # render enemies at locations
    outputs.sprites << state.enemies.map do |e|
      tile_in_game(x: e.x, y: e.y, tile_key: e.tile_key)
    end

    # example of rendering a tile at a location
    # outputs.sprites << tile_in_game(x: 6, y: 5, tile_key: "|")

    # render the border
    border_x = state.world.padding - DESTINATION_TILE_SIZE
    border_y = state.world.padding - DESTINATION_TILE_SIZE
    border_size = state.world.sz + DESTINATION_TILE_SIZE * 2

    outputs.borders << { x: border_x,
                         y: border_y,
                         w: border_size,
                         h: border_size }

    # render label stuff
    outputs.labels << { x: border_x, y: border_y - 10, text: "Current player location is: #{state.player.x}, #{state.player.y}" }
    outputs.labels << { x: border_x, y: border_y + 25 + border_size, text: state.info_message }
  end

  def tile_in_game(x:, y:, tile_key:)
    tile(x: state.world.padding + x * DESTINATION_TILE_SIZE,
         y: state.world.padding + y * DESTINATION_TILE_SIZE,
         loc_or_char: tile_key)
  end

  def sprite key
    state.sprite_lookup[key]
  end

  def tile(x:, y:, loc_or_char:)
    tile_extended x: x,
                  y: y,
                  w: DESTINATION_TILE_SIZE,
                  h: DESTINATION_TILE_SIZE,
                  loc_or_char: loc_or_char
  end

  def tile_extended(x:, y:, w:, h:, loc_or_char:, r: 0, g: 0, b: 0, a: 255)
    row_or_key, column = loc_or_char
    if !column
      row, column = sprite row_or_key
    else
      row, column = row_or_key, column
    end

    if !row
      member_name = member_name_as_code loc_or_char
      raise "Unabled to find a sprite for #{member_name}. Make sure the value exists in app/sprite_lookup.rb."
    end

    # Sprite provided by Rogue Yun
    # http://www.bay12forums.com/smf/index.php?topic=144897.0
    # License: Public Domain
    {
      x: x,
      y: y,
      w: w,
      h: h,
      tile_x: column * 16,
      tile_y: (row * 16),
      tile_w: 16,
      tile_h: 16,
      r: r,
      g: g,
      b: b,
      a: a,
      path: 'sprites/simple-mood-16x16.png'
    }
  end

  def tick_legend
    legend_padding = 16
    legend_x = 1280 - TILE_SHEET_SIZE - legend_padding
    legend_y =  720 - TILE_SHEET_SIZE - legend_padding
    tile_sheet_sprite = { x: legend_x,
                          y: legend_y,
                          w: TILE_SHEET_SIZE,
                          h: TILE_SHEET_SIZE,
                          path: 'sprites/simple-mood-16x16.png',
                          r: 0,
                          g: 0,
                          b: 0,
                          a: 255, }

    if inputs.mouse.point.inside_rect? tile_sheet_sprite
      mouse_row = inputs.mouse.point.y.idiv(SOURCE_TILE_SIZE)
      tile_row = 15 - (mouse_row - legend_y.idiv(SOURCE_TILE_SIZE))

      mouse_col = inputs.mouse.point.x.idiv(SOURCE_TILE_SIZE)
      tile_col = (mouse_col - legend_x.idiv(SOURCE_TILE_SIZE))

      outputs.primitives << { x: legend_x - legend_padding * 2,
                              y: mouse_row * SOURCE_TILE_SIZE,
                              w: 256 + legend_padding * 2,
                              h: 16,
                              r: 128,
                              g: 128,
                              b: 128,
                              a: 64,
                              path: :solid }

      outputs.primitives << { x: mouse_col * SOURCE_TILE_SIZE,
                              y: legend_y - legend_padding * 2,
                              w: 16,
                              h: 256 + legend_padding * 2,
                              r: 128,
                              g: 128,
                              b: 128,
                              a: 64,
                              path: :solid }

      sprite_key = sprite_lookup.find { |k, v| v == [tile_row, tile_col] }

      if sprite_key
        member_name, _ = sprite_key
        member_name = member_name_as_code member_name
        outputs.labels << { x: 660, y: 180, text: "# CODE SAMPLE PLACE THE FOLLOWING IN THE tick_game METHOD",      size_px: 20, anchor_x: 0, anchor_y: 0 }
        outputs.labels << { x: 660, y: 180, text: "outputs.sprites << tile_in_game(x: 5, y: 6, tile_key: #{member_name})", size_px: 20, anchor_x: 0, anchor_y: 1 }
      else
        outputs.labels << { x: 660, y: 180, text: "TILE [#{tile_row}, #{tile_col}] NOT FOUND. ADD A KEY/VALUE TO THE sprite_lookup", size_px: 20, anchor_x: 0, anchor_y: 0 }
        outputs.labels << { x: 660, y: 180, text: "METHOD LOCATED NEAR THE TOP OF main.rb", size_px: 20, anchor_x: 0, anchor_y: 1 }
        outputs.labels << { x: 660, y: 180, text: "{ \"some_string\" => [#{tile_row}, #{tile_col}] }", size_px: 20, anchor_x: 0, anchor_y: 2 }
        outputs.labels << { x: 660, y: 180, text: "OR", size_px: 20, anchor_x: 0, anchor_y: 3 }
        outputs.labels << { x: 660, y: 180, text: "{ some_symbol: [#{tile_row}, #{tile_col}] }", size_px: 20, anchor_x: 0, anchor_y: 4 }
      end

    end

    # render the sprite in the top right with a padding to the top and right so it's
    # not flush against the edge
    outputs.sprites << tile_sheet_sprite

    # carefully place some ascii arrows to show the legend labels
    outputs.labels  <<  { x: 895, y: 707, text: "ROW --->" }
    outputs.labels  <<  { x: 943, y: 324, text: "       ^", anchor_y: -3 }
    outputs.labels  <<  { x: 943, y: 324, text: "       |", anchor_y: -2 }
    outputs.labels  <<  { x: 943, y: 324, text: "COL ---+", anchor_y: -1  }
    outputs.labels  <<  { x: 650, y: 570, text: "HOVER OVER TILES FOR CODE HINTS", anchor_y: 0 }
    outputs.labels  <<  { x: 650, y: 570, text: "              |                ", anchor_y: 1 }
    outputs.labels  <<  { x: 650, y: 570, text: "              +--------------->", anchor_y: 2 }
    # use the tile sheet to print out row and column numbers
    outputs.sprites << 16.map_with_index do |i|
      sprite_key = i % 10
      [
        tile(x: 1280 - TILE_SHEET_SIZE - legend_padding * 2 - SOURCE_TILE_SIZE,
             y: 720 - legend_padding * 2 - (SOURCE_TILE_SIZE * i),
             loc_or_char: sprite(sprite_key)),
        tile(x: 1280 - TILE_SHEET_SIZE - SOURCE_TILE_SIZE + (SOURCE_TILE_SIZE * i),
             y: 720 - TILE_SHEET_SIZE - legend_padding * 3,
             loc_or_char: sprite(sprite_key))
      ]
    end
  end

  def member_name_as_code raw_member_name
    if raw_member_name.is_a? Symbol
      ":#{raw_member_name}"
    elsif raw_member_name.is_a? String
      "'#{raw_member_name}'"
    elsif raw_member_name.is_a? Fixnum
      "#{raw_member_name}"
    else
      "UNKNOWN: #{raw_member_name}"
    end
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

GTK.reset
