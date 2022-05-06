class Game
  attr_gtk

  def tick
    defaults
    render
    input_edit_map
    input_player
    calc_player
  end

  def defaults
    state.gravity           = -0.4
    state.drag              = 0.15
    state.tile_size         = 32
    state.player.size       = 16
    state.player.jump_power = 12

    state.tiles                 ||= []
    state.player.y              ||= 800
    state.player.x              ||= 100
    state.player.dy             ||= 0
    state.player.dx             ||= 0
    state.player.jumped_down_at ||= 0
    state.player.jumped_at      ||= 0

    calc_player_rect if !state.player.rect
  end

  def render
    outputs.labels << [10, 10.from_top, "tile: click to add a tile, hold X key and click to delete a tile."]
    outputs.labels << [10, 35.from_top, "move: use left and right to move, space to jump, down and space to jump down."]
    outputs.labels << [10, 55.from_top, "      You can jump through or jump down through tiles with a height of 1."]
    outputs.background_color = [80, 80, 80]
    outputs.sprites << tiles.map(&:sprite)
    outputs.sprites << (player.rect.merge path: 'sprites/square/green.png')

    mouse_overlay = {
      x: (inputs.mouse.x.ifloor state.tile_size),
      y: (inputs.mouse.y.ifloor state.tile_size),
      w: state.tile_size,
      h: state.tile_size,
      a: 100
    }

    mouse_overlay = mouse_overlay.merge r: 255 if state.delete_mode

    if state.mouse_held
      outputs.primitives << mouse_overlay.border!
    else
      outputs.primitives << mouse_overlay.solid!
    end
  end

  def input_edit_map
    state.mouse_held = true  if inputs.mouse.down
    state.mouse_held = false if inputs.mouse.up

    if inputs.keyboard.x
      state.delete_mode = true
    elsif inputs.keyboard.key_up.x
      state.delete_mode = false
    end

    return unless state.mouse_held

    ordinal = { x: (inputs.mouse.x.idiv state.tile_size),
                y: (inputs.mouse.y.idiv state.tile_size) }

    found = find_tile ordinal
    if !found && !state.delete_mode
      tiles << (state.new_entity :tile, ordinal)
      recompute_tiles
    elsif found && state.delete_mode
      tiles.delete found
      recompute_tiles
    end
  end

  def input_player
    player.dx += inputs.left_right

    if inputs.keyboard.key_down.space && inputs.keyboard.down
      player.dy             = player.jump_power * -1
      player.jumped_at      = 0
      player.jumped_down_at = state.tick_count
    elsif inputs.keyboard.key_down.space
      player.dy             = player.jump_power
      player.jumped_at      = state.tick_count
      player.jumped_down_at = 0
    end
  end

  def calc_player
    calc_player_rect
    calc_below
    calc_left
    calc_right
    calc_above
    calc_player_dy
    calc_player_dx
    reset_player if player_off_stage?
  end

  def calc_player_rect
    player.rect      = current_player_rect
    player.next_rect = player.rect.merge x: player.x + player.dx,
                                         y: player.y + player.dy
    player.prev_rect = player.rect.merge x: player.x - player.dx,
                                         y: player.y - player.dy
  end

  def calc_below
    return unless player.dy <= 0
    tiles_below = find_tiles { |t| t.rect.top <= player.prev_rect.y }
    collision = find_colliding_tile tiles_below, (player.rect.merge y: player.next_rect.y)
    return unless collision
    if collision.neighbors.b == :none && player.jumped_down_at.elapsed_time < 10
      player.dy = -1
    else
      player.y  = collision.rect.y + state.tile_size
      player.dy = 0
    end
  end

  def calc_left
    return unless player.dx < 0
    tiles_left = find_tiles { |t| t.rect.right <= player.prev_rect.left }
    collision = find_colliding_tile tiles_left, (player.rect.merge x: player.next_rect.x)
    return unless collision
    player.x  = collision.rect.right
    player.dx = 0
  end

  def calc_right
    return unless player.dx > 0
    tiles_right = find_tiles { |t| t.rect.left >= player.prev_rect.right }
    collision = find_colliding_tile tiles_right, (player.rect.merge x: player.next_rect.x)
    return unless collision
    player.x  = collision.rect.left - player.rect.w
    player.dx = 0
  end

  def calc_above
    return unless player.dy > 0
    tiles_above = find_tiles { |t| t.rect.y >= player.prev_rect.y }
    collision = find_colliding_tile tiles_above, (player.rect.merge y: player.next_rect.y)
    return unless collision
    return if collision.neighbors.t == :none
    player.dy = 0
    player.y  = collision.rect.bottom - player.rect.h
  end

  def calc_player_dx
    player.dx  = player.dx.clamp(-5,  5)
    player.dx *= 0.9
    player.x  += player.dx
  end

  def calc_player_dy
    player.y  += player.dy
    player.dy += state.gravity
    player.dy += player.dy * state.drag ** 2 * -1
  end

  def reset_player
    player.x  = 100
    player.y  = 720
    player.dy = 0
  end

  def recompute_tiles
    tiles.each do |t|
      t.w = state.tile_size
      t.h = state.tile_size
      t.neighbors = tile_neighbors t, tiles

      t.rect = [t.x * state.tile_size,
                t.y * state.tile_size,
                state.tile_size,
                state.tile_size].rect.to_hash

      sprite_sub_path = t.neighbors.mask.map { |m| flip_bit m }.join("")

      t.sprite = {
        x: t.x * state.tile_size,
        y: t.y * state.tile_size,
        w: state.tile_size,
        h: state.tile_size,
        path: "sprites/tile/wall-#{sprite_sub_path}.png"
      }
    end
  end

  def flip_bit bit
    return 0 if bit == 1
    return 1
  end

  def player
    state.player
  end

  def player_off_stage?
    player.rect.top < grid.bottom ||
    player.rect.right < grid.left ||
    player.rect.left > grid.right
  end

  def current_player_rect
    { x: player.x, y: player.y, w: player.size, h: player.size }
  end

  def tiles
    state.tiles
  end

  def find_tile ordinal
    tiles.find { |t| t.x == ordinal.x && t.y == ordinal.y }
  end

  def find_tiles &block
    tiles.find_all(&block)
  end

  def find_colliding_tile tiles, target
    tiles.find { |t| t.rect.intersect_rect? target }
  end

  def tile_neighbors tile, other_points
    t = find_tile x: tile.x + 0, y: tile.y + 1
    r = find_tile x: tile.x + 1, y: tile.y + 0
    b = find_tile x: tile.x + 0, y: tile.y - 1
    l = find_tile x: tile.x - 1, y: tile.y + 0

    tile_t, tile_r, tile_b, tile_l = 0

    tile_t = 1 if t
    tile_r = 1 if r
    tile_b = 1 if b
    tile_l = 1 if l

    state.new_entity :neighbors, mask: [tile_t, tile_r, tile_b, tile_l],
                                 t:    t ? :some : :none,
                                 b:    b ? :some : :none,
                                 l:    l ? :some : :none,
                                 r:    r ? :some : :none
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end
