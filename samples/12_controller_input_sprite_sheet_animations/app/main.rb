class Game
  attr_gtk

  def defaults
    state.show_debug_layer  = true if state.tick_count == 0
    player.tile_size        = 64
    player.speed            = 3
    player.slash_frames     = 15
    player.x              ||= 50
    player.y              ||= 400
    player.dir_x          ||=  1
    player.dir_y          ||= -1
    player.is_moving      ||= false
    state.watch_list      ||= {}
    state.enemies         ||= []
  end

  def add_enemy
    state.enemies << { x: 1200 * rand, y: 600 * rand, w: 64, h: 64 }
  end

  def sprite_horizontal_run
    tile_index = 0.frame_index(6, 3, true)
    tile_index = 0 if !player.is_moving

    {
      x: player.x,
      y: player.y,
      w: player.tile_size,
      h: player.tile_size,
      path: 'sprites/horizontal-run.png',
      tile_x: 0 + (tile_index * player.tile_size),
      tile_y: 0,
      tile_w: player.tile_size,
      tile_h: player.tile_size,
      flip_horizontally: player.dir_x > 0,
      # a: 40
    }
  end

  def sprite_horizontal_stand
    {
      x: player.x,
      y: player.y,
      w: player.tile_size,
      h: player.tile_size,
      path: 'sprites/horizontal-stand.png',
      flip_horizontally: player.dir_x > 0,
      # a: 40
    }
  end

  def sprite_horizontal_slash
    tile_index   = player.slash_at.frame_index(5, player.slash_frames.idiv(5), false) || 0

    {
      x: player.x - 41.25,
      y: player.y - 41.25,
      w: 165,
      h: 165,
      path: 'sprites/horizontal-slash.png',
      tile_x: 0 + (tile_index * 128),
      tile_y: 0,
      tile_w: 128,
      tile_h: 128,
      flip_horizontally: player.dir_x > 0
    }
  end

  def render_player
    if player.slash_at
      outputs.sprites << sprite_horizontal_slash
    elsif player.is_moving
      outputs.sprites << sprite_horizontal_run
    else
      outputs.sprites << sprite_horizontal_stand
    end
  end

  def render_enemies
    outputs.borders << state.enemies
  end

  def render_debug_layer
    return if !state.show_debug_layer
    outputs.labels << state.watch_list.map.with_index do |(k, v), i|
       [30, 710 - i * 28, "#{k}: #{v || "(nil)"}"]
    end

    outputs.borders << player.slash_collision_rect
  end

  def slash_initiate?
    # buffalo usb controller has a button and b button swapped lol
    inputs.controller_one.key_down.a || inputs.keyboard.key_down.j
  end

  def input
    # player movement
    if slash_complete? && (vector = inputs.directional_vector)
      player.x += vector.x * player.speed
      player.y += vector.y * player.speed
    end
    player.slash_at = slash_initiate? if slash_initiate?
  end

  def calc_movement
    # movement
    if vector = inputs.directional_vector
      state.debug_label = vector
      player.dir_x = vector.x
      player.dir_y = vector.y
      player.is_moving = true
    else
      state.debug_label = vector
      player.is_moving = false
    end
  end

  def calc_slash
    # re-calc the location of the swords collision box
    if player.dir_x.positive?
      player.slash_collision_rect = [player.x + player.tile_size,
                                     player.y + player.tile_size.half - 10,
                                     40, 20]
    else
      player.slash_collision_rect = [player.x - 32 - 8,
                                     player.y + player.tile_size.half - 10,
                                     40, 20]
    end

    # recalc sword's slash state
    player.slash_at = nil if slash_complete?

    # determine collision if the sword is at it's point of damaging
    return unless slash_can_damage?

    state.enemies.reject! { |e| e.intersect_rect? player.slash_collision_rect }
  end

  def slash_complete?
    !player.slash_at || player.slash_at.elapsed?(player.slash_frames)
  end

  def slash_can_damage?
    # damage occurs half way into the slash animation
    return false if slash_complete?
    return false if (player.slash_at + player.slash_frames.idiv(2)) != state.tick_count
    return true
  end

  def calc
    # generate an enemy if there aren't any on the screen
    add_enemy if state.enemies.length == 0
    calc_movement
    calc_slash
  end

  # source is at http://github.com/amirrajan/dragonruby-link-to-the-past
  def tick
    defaults
    render_enemies
    render_player
    outputs.labels << [30, 30, "Gamepad: D-Pad to move. B button to attack."]
    outputs.labels << [30, 52, "Keyboard: WASD/Arrow keys to move. J to attack."]
    render_debug_layer
    input
    calc
  end

  def player
    state.player
  end
end

$game = Game.new

def tick args
  $game.args = args
  $game.tick
end

$gtk.reset
