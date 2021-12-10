class Game
  attr_gtk

  def tick
    defaults
    render
    input
    calc
  end

  def defaults
    return if state.tick_count != 0

    player.x                     = 64
    player.y                     = 800
    player.size                  = 50
    player.dx                    = 0
    player.dy                    = 0
    player.action                = :falling

    player.max_speed             = 20
    player.jump_power            = 15
    player.jump_air_time         = 15
    player.jump_increase_power   = 1

    state.gravity                = -1
    state.drag                   = 0.001
    state.tile_size              = 64
    state.tiles                ||= [
      { ordinal_x:  0, ordinal_y: 0 },
      { ordinal_x:  1, ordinal_y: 0 },
      { ordinal_x:  2, ordinal_y: 0 },
      { ordinal_x:  3, ordinal_y: 0 },
      { ordinal_x:  4, ordinal_y: 0 },
      { ordinal_x:  5, ordinal_y: 0 },
      { ordinal_x:  6, ordinal_y: 0 },
      { ordinal_x:  7, ordinal_y: 0 },
      { ordinal_x:  8, ordinal_y: 0 },
      { ordinal_x:  9, ordinal_y: 0 },
      { ordinal_x: 10, ordinal_y: 0 },
      { ordinal_x: 11, ordinal_y: 0 },
      { ordinal_x: 12, ordinal_y: 0 },

      { ordinal_x:  9, ordinal_y: 3 },
      { ordinal_x: 10, ordinal_y: 3 },
      { ordinal_x: 11, ordinal_y: 3 },
    ]

    tiles.each do |t|
      t.rect = { x: t.ordinal_x * 64,
                 y: t.ordinal_y * 64,
                 w: 64,
                 h: 64 }
    end
  end

  def render
    render_player
    render_tiles
    # render_grid
  end

  def input
    input_jump
    input_move
  end

  def calc
    calc_player_rect
    calc_left
    calc_right
    calc_below
    calc_above
    calc_player_dy
    calc_player_dx
    calc_game_over
  end

  def render_player
    outputs.sprites << {
      x: player.x,
      y: player.y,
      w: player.size,
      h: player.size,
      path: 'sprites/square/red.png'
    }
  end

  def render_tiles
    outputs.sprites << state.tiles.map do |t|
      t.merge path: 'sprites/square/white.png',
              x: t.ordinal_x * 64,
              y: t.ordinal_y * 64,
              w: 64,
              h: 64
    end
  end

  def render_grid
    if state.tick_count == 0
      outputs[:grid].background_color = [0, 0, 0, 0]
      outputs[:grid].borders << available_brick_locations
      outputs[:grid].labels  << available_brick_locations.map do |b|
        [
          b.merge(text: "#{b.ordinal_x},#{b.ordinal_y}",
                  x: b.x + 2,
                  y: b.y + 2,
                  size_enum: -3,
                  vertical_alignment_enum: 0,
                  blendmode_enum: 0),
          b.merge(text: "#{b.x},#{b.y}",
                  x: b.x + 2,
                  y: b.y + 2 + 20,
                  size_enum: -3,
                  vertical_alignment_enum: 0,
                  blendmode_enum: 0)
        ]
      end
    end

    outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :grid }
  end

  def input_jump
    if inputs.keyboard.key_down.space
      player_jump
    end

    if inputs.keyboard.key_held.space
      player_jump_increase_air_time
    end
  end

  def input_move
    if player.dx.abs < 20
      if inputs.keyboard.left
        player.dx -= 2
      elsif inputs.keyboard.right
        player.dx += 2
      end
    end
  end

  def calc_game_over
    if player.y < -64
      player.x = 64
      player.y = 800
      player.dx = 0
      player.dy = 0
    end
  end

  def calc_player_rect
    player.rect      = player_current_rect
    player.next_rect = player_next_rect
    player.prev_rect = player_prev_rect
  end

  def calc_player_dx
    player.dx  = player_next_dx
    player.x  += player.dx
  end

  def calc_player_dy
    player.y  += player.dy
    player.dy  = player_next_dy
  end

  def calc_below
    return unless player.dy < 0
    tiles_below = tiles_find { |t| t.rect.top <= player.prev_rect.y }
    collision = tiles_find_colliding tiles_below, (player.rect.merge y: player.next_rect.y)
    if collision
      player.y  = collision.rect.y + state.tile_size
      player.dy = 0
      player.action = :standing
    else
      player.action = :falling
    end
  end

  def calc_left
    return unless player.dx < 0 && player_next_dx < 0
    tiles_left = tiles_find { |t| t.rect.right <= player.prev_rect.left }
    collision = tiles_find_colliding tiles_left, (player.rect.merge x: player.next_rect.x)
    return unless collision
    player.x  = collision.rect.right
    player.dx = 0
  end

  def calc_right
    return unless player.dx > 0 && player_next_dx > 0
    tiles_right = tiles_find { |t| t.rect.left >= player.prev_rect.right }
    collision = tiles_find_colliding tiles_right, (player.rect.merge x: player.next_rect.x)
    return unless collision
    player.x  = collision.rect.left - player.rect.w
    player.dx = 0
  end

  def calc_above
    return unless player.dy > 0
    tiles_above = tiles_find { |t| t.rect.y >= player.prev_rect.y }
    collision = tiles_find_colliding tiles_above, (player.rect.merge y: player.next_rect.y)
    return unless collision
    player.dy = 0
    player.y  = collision.rect.bottom - player.rect.h
  end

  def player_current_rect
    { x: player.x, y: player.y, w: player.size, h: player.size }
  end

  def available_brick_locations
    (0..19).to_a
      .product(0..11)
      .map do |(ordinal_x, ordinal_y)|
      { ordinal_x: ordinal_x,
        ordinal_y: ordinal_y,
        x: ordinal_x * 64,
        y: ordinal_y * 64,
        w: 64,
        h: 64 }
    end
  end

  def player
    state.player ||= args.state.new_entity :player
  end

  def player_next_dy
    player.dy + state.gravity + state.drag ** 2 * -1
  end

  def player_next_dx
    player.dx * 0.8
  end

  def player_next_rect
    player.rect.merge x: player.x + player_next_dx,
                      y: player.y + player_next_dy
  end

  def player_prev_rect
    player.rect.merge x: player.x - player.dx,
                      y: player.y - player.dy
  end

  def player_jump
    return if player.action != :standing
    player.action = :jumping
    player.dy = state.player.jump_power
    current_frame = state.tick_count
    player.action_at = current_frame
  end

  def player_jump_increase_air_time
    return if player.action != :jumping
    return if player.action_at.elapsed_time >= player.jump_air_time
    player.dy += player.jump_increase_power
  end

  def tiles
    state.tiles
  end

  def tiles_find_colliding tiles, target
    tiles.find { |t| t.rect.intersect_rect? target }
  end

  def tiles_find &block
    tiles.find_all(&block)
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

$gtk.reset
