class Game
  attr_gtk

  def tick
    defaults
    input
    calc
    render
  end

  def defaults
    state.high_score          ||= 0
    state.damage_render_queue ||= []
    game_reset if state.tick_count == 0 || state.start_new_game
  end

  def game_reset
    state.start_new_game      = false
    state.game_over           = false
    state.game_over_countdown = nil

    state.player.tile_size          = 64
    state.player.speed              = 4
    state.player.slash_frames       = 15
    state.player.hp                 = 3
    state.player.damaged_at         = -1000
    state.player.x                  = 50
    state.player.y                  = 400
    state.player.dir_x              =  1
    state.player.dir_y              = -1
    state.player.is_moving          = false

    state.boss.damage               = 0
    state.boss.x                    = 800
    state.boss.y                    = 400
    state.boss.w                    = 256
    state.boss.h                    = 256
    state.boss.target_x             = 800
    state.boss.target_y             = 400
    state.boss.attack_cooldown      = 600
  end

  def input
    return if state.game_over

    player.is_moving = false

    if input_attack?
      player.slash_at = state.tick_count
    end

    if !player_attacking?
      vector = inputs.directional_vector
      if vector
        next_player_x = player.x + vector.x * player.speed
        next_player_y = player.y + vector.y * player.speed
        player.x = next_player_x if player_x_inside_stage? next_player_x
        player.y = next_player_y if player_y_inside_stage? next_player_y

        player.is_moving = true

        player.dir_x = if vector.x < 0
                         -1
                       elsif vector.x > 0
                         1
                       else
                         player.dir_x
                       end

        player.dir_y = if vector.y < 0
                         -1
                       elsif vector.y > 0
                         1
                       else
                         player.dir_y
                       end
      end
    end
  end

  def input_attack?
    inputs.controller_one.key_down.a ||
    inputs.controller_one.key_down.b ||
    inputs.keyboard.key_down.j
  end

  def calc
    calc_player
    calc_boss
    calc_damage_render_queue
    calc_high_score
    calc_game_over
  end

  def calc_player
    player.slash_at = nil if !player_attacking?
    return unless player_slash_can_damage?
    if player_hit_box.intersect_rect? boss_hurt_box
      boss.damage += 1
      queue_damage player_hit_box.x + player_hit_box.w / 2 * player.dir_x,
                   player_hit_box.y + player_hit_box.h / 2
    end
  end

  def calc_boss
    boss.attack_cooldown -= 1
    if boss.attack_cooldown < 0
      boss.target_x = player.x - 100
      boss.target_y = player.y - 100
      boss.attack_cooldown = if    boss.damage > 200
                               200
                             elsif boss.damage > 150
                               300
                             elsif boss.damage > 100
                               400
                             elsif boss.damage > 50
                               500
                             else
                               600
                             end
    end

    dx = boss.target_x - boss.x
    dy = boss.target_y - boss.y
    boss.x += dx * 0.25 ** 2
    boss.y += dy * 0.25 ** 2

    if boss.intersect_rect?(player_hurt_box) && player.damaged_at.elapsed?(120)
      player.damaged_at = state.tick_count
      player.hp -= 1
      player.hp  = 0 if player.hp < 0
    end
  end

  def calc_damage_render_queue
    state.damage_render_queue.each { |label| label.a -= 5 }
    state.damage_render_queue.reject! { |l| l.a < 0 }
  end

  def calc_high_score
    state.high_score = boss.damage if boss.damage > state.high_score
  end

  def calc_game_over
    if player.hp <= 0
      state.game_over = true
      state.game_over_countdown ||= 160
    end

    state.game_over_countdown -= 1 if state.game_over_countdown
    state.start_new_game = true    if state.game_over_countdown && state.game_over_countdown < 0
  end

  def render
    render_boss
    render_player
    render_damage_queue
    render_scores
    render_instructions
    render_game_over
    # render_debug
  end

  def render_player
    outputs.labels << { x: player.x + 5,
                        y: player.y + 5,
                        text: "hp: #{player.hp}" }

    if state.game_over
      outputs.labels << { x: player.x + player.tile_size / 2,
                          y: player.y + 85,
                          text: "RIP",
                          size_enum: 2,
                          alignment_enum: 1 }
    elsif !player.damaged_at.elapsed?(120)
      outputs.labels << { x: player.x + player.tile_size / 2,
                          y: player.y + 85,
                          text: "ouch!!",
                          size_enum: 2,
                          alignment_enum: 1 }
    end

    if state.game_over
      outputs.sprites << player_sprite_stand.merge(angle: -90, flip_horizontally: false)
    elsif player.slash_at
      outputs.sprites << player_sprite_slash
    elsif player.is_moving
      outputs.sprites << player_sprite_run
    else
      outputs.sprites << player_sprite_stand
    end
  end

  def render_boss
    outputs.sprites << boss_sprite
  end

  def render_damage_queue
    outputs.labels << state.damage_render_queue
  end

  def render_scores
    outputs.labels << { x: 30, y: 30.from_top, text: "curr score: #{boss.damage}" }
    outputs.labels << { x: 30, y: 50.from_top, text: "high score: #{state.high_score}" }
  end

  def render_instructions
    outputs.labels << { x: 30, y: 70, text: "Controls:" }
    outputs.labels << { x: 30, y: 50, text: "Keyboard:   WASD/Arrow keys to move. J to attack." }
    outputs.labels << { x: 30, y: 30, text: "Controller: D-Pad to move. A/B button to attack." }
  end

  def render_game_over
    return unless state.game_over
    outputs.labels << { x: 640, y: 360, text: "GAME OVER!!!", alignment_enum: 1, size_enum: 3 }
  end

  def render_debug
    outputs.borders << player_sprite_stand
    outputs.borders << player_hurt_box
    outputs.borders << player_hit_box
    outputs.borders << boss_hurt_box
    outputs.borders << boss_hit_box
  end

  def player
    state.player
  end

  def player_x_inside_stage? player_x
    return false if player_x < 0
    return false if (player_x + player.tile_size) > 1280
    return true
  end

  def player_y_inside_stage? player_y
    return false if player_y < 0
    return false if (player_y + player.tile_size) > 720
    return true
  end

  def player_attacking?
    return false if !player.slash_at
    return false if player.slash_at.elapsed?(player.slash_frames)
    return true
  end

  def player_slash_can_damage?
    return false if !player_attacking?
    return false if (player.slash_at + player.slash_frames.idiv(2)) != state.tick_count
    return true
  end

  def player_hit_box
    sword_w = 50
    sword_h = 20
    if player.dir_x > 0
      {
        x: player.x + player.tile_size / 2 + sword_w / 2,
        y: player.y + player.tile_size / 2 - sword_h / 2,
        w: sword_w,
        h: sword_h
      }
    else
      {
        x: player.x + player.tile_size / 2 - sword_w / 2 - sword_w,
        y: player.y + player.tile_size / 2 - sword_h / 2,
        w: sword_w,
        h: sword_h
      }
    end
  end

  def player_hurt_box
    {
      x: player.x + 25,
      y: player.y + 25,
      w: 10,
      h: 10
    }
  end

  def player_sprite_run
    tile_index = 0.frame_index count:    6,
                               hold_for: 3,
                               repeat:   true

    tile_index = 0 if !player.is_moving

    {
      x:                 player.x,
      y:                 player.y,
      w:                 player.tile_size,
      h:                 player.tile_size,
      path:              'sprites/boss-battle/player-run-tile-sheet.png',
      tile_x:            0 + (tile_index * player.tile_size),
      tile_y:            0,
      tile_w:            player.tile_size,
      tile_h:            player.tile_size,
      flip_horizontally: player.dir_x > 0,
    }
  end

  def player_sprite_stand
    {
      x:                 player.x,
      y:                 player.y,
      w:                 player.tile_size,
      h:                 player.tile_size,
      path:              'sprites/boss-battle/player-stand.png',
      flip_horizontally: player.dir_x > 0,
    }
  end

  def player_sprite_slash
    tile_index   = player.slash_at.frame_index count: 5,
                                               hold_for: player.slash_frames.idiv(5),
                                               repeat: false

    tile_index ||= 0
    tile_offset = 41.25

    if player.dir_x > 0
      {
        x:                 player.x - tile_offset,
        y:                 player.y - tile_offset,
        w:                 165,
        h:                 165,
        path:              'sprites/boss-battle/player-slash-tile-sheet.png',
        tile_x:            0 + (tile_index * 128),
        tile_y:            0,
        tile_w:            128,
        tile_h:            128,
        flip_horizontally: true
      }
    else
      {
        x:                 player.x - tile_offset - tile_offset / 2,
        y:                 player.y - tile_offset,
        w:                 165,
        h:                 165,
        path:              'sprites/boss-battle/player-slash-tile-sheet.png',
        tile_x:            0 + (tile_index * 128),
        tile_y:            0,
        tile_w:            128,
        tile_h:            128,
        flip_horizontally: false
      }
    end
  end

  def boss
    state.boss
  end

  def boss_hurt_box
    {
      x: boss.x,
      y: boss.y,
      w: boss.w,
      h: boss.h
    }
  end

  def boss_hit_box
    {
      x: boss.x,
      y: boss.y,
      w: boss.w,
      h: boss.h
    }
  end

  def boss_sprite
    case boss_attack_state
    when :sleeping
      { x: boss.x,
        y: boss.y,
        w: boss.w,
        h: boss.h,
        path: 'sprites/boss-battle/boss-sleeping.png' }
    when :aware
      { x: boss.x,
        y: boss.y,
        w: boss.w,
        h: boss.h,
        path: 'sprites/boss-battle/boss-aware.png' }
    when :annoyed
      { x: boss.x,
        y: boss.y,
        w: boss.w,
        h: boss.h,
        path: 'sprites/boss-battle/boss-annoyed.png' }
    when :will_attack
      shake_x  =  2 * rand
      shake_x *= -1 if rand < 0.5

      shake_y  =  2 * rand
      shake_y *= -1 if rand < 0.5

      { x: boss.x + shake_x,
        y: boss.y + shake_x,
        w: boss.w,
        h: boss.h,
        path: 'sprites/boss-battle/boss-will-attack.png' }
    when :attacking
      flip_horizontally = false
      flip_horizontally = true if boss.target_x > boss.x

      { x: boss.x,
        y: boss.y,
        w: boss.w,
        h: boss.h,
        flip_horizontally: flip_horizontally,
        path: 'sprites/boss-battle/boss-attacking.png' }
    else
      { x: boss.x, y: boss.y, w: boss.w, h: boss.h, r: 255, g: 0, b: 0 }
    end
  end

  def boss_attack_state
    if boss.target_x.round != boss.x.round || boss.target_y.round != boss.y.round
      :attacking
    elsif boss.attack_cooldown < 30
      :will_attack
    elsif boss.attack_cooldown < 120
      :annoyed
    elsif boss.attack_cooldown < 180
      :aware
    else
      :sleeping
    end
  end

  def queue_damage x, y
    rand_x_offset = rand * 20
    rand_y_offset = rand * 20
    rand_x_offset *= -1 if rand < 0.5
    rand_y_offset *= -1 if rand < 0.5
    state.damage_render_queue << { x: x + rand_x_offset, y: y + rand_y_offset, a: 255, text: "wack!" }
  end
end

$game = Game.new

def tick args
  $game.args = args
  $game.tick
end
