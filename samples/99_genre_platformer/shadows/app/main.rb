class Game
  attr_gtk

  def tick
    defaults
    input
    calc
    render
  end

  def defaults
    new_game if !state.clock || state.game_over == true
  end

  def input
    input_entity player,
                 find_input_timeline(at: player.clock, key: :left_right),
                 find_input_timeline(at: player.clock, key: :space),
                 find_input_timeline(at: player.clock, key: :down)

    shadows.find_all { |shadow| entity_active? shadow }
           .each do |shadow|
             input_entity shadow,
                          find_input_timeline(at: shadow.clock, key: :left_right),
                          find_input_timeline(at: shadow.clock, key: :space),
                          find_input_timeline(at: shadow.clock, key: :down)
             end
  end

  def input_entity entity, left_right, jump, fall_through
    return if !entity_active? entity

    entity.dx += left_right

    if left_right == 0
      if (entity.action == :running)
        entity_set_action! entity, :standing
      end
    elsif entity.left_right != left_right && (entity_on_platform? entity)
      entity_set_action! entity, :running
    end

    entity.left_right = left_right

    entity.orientation = if left_right == -1
                           :left
                         elsif left_right == 1
                           :right
                         else
                           entity.orientation
                         end

    if fall_through && (entity_on_platform? entity)
      entity.jumped_at      = 0
      entity.jumped_down_at = entity.clock
      entity.jump_count    += 1
    end

    if jump && entity.jump_count < 3
      if entity.jump_count == 0
        entity_set_action! entity, :first_jump
      elsif entity.jump_count == 1
        entity_set_action! entity, :midair_jump
      elsif entity.jump_count == 2
        entity_set_action! entity, :midair_jump
      end

      entity.dy             = entity.jump_power
      entity.jumped_at      = entity.clock
      entity.jumped_down_at = 0
      entity.jump_count    += 1
    end
  end

  def calc
    calc_light_meter
    calc_action_history
    calc_entity player
    calc_shadows
    calc_light_crystal
    calc_render_queues
    calc_game_over
    calc_clock
  end

  def calc_light_meter
    state.light_meter -= 1
    d = state.light_meter_queue * 0.1
    state.light_meter += d
    state.light_meter_queue -= d
  end

  def calc_action_history
    state.curr_left_right     = inputs.left_right
    if state.prev_left_right != state.curr_left_right
      state.input_timeline.unshift({ at: state.clock, k: :left_right, v: state.curr_left_right })
    end
    state.prev_left_right = state.curr_left_right

    state.curr_space     = inputs.keyboard.key_down.space    ||
                           inputs.controller_one.key_down.a  ||
                           inputs.keyboard.key_down.up       ||
                           inputs.controller_one.key_down.b

    if state.prev_space != state.curr_space
      state.input_timeline.unshift({ at: state.clock, k: :space, v: state.curr_space })
    end
    state.prev_space = state.curr_space

    state.curr_down     = inputs.keyboard.down || inputs.controller_one.down
    if state.prev_down != state.curr_down
      state.input_timeline.unshift({ at: state.clock, k: :down, v: state.curr_down })
    end
    state.prev_down = state.curr_down
  end

  def calc_entity entity
    calc_entity_rect entity
    return if !entity_active? entity
    calc_entity_collision entity
    calc_entity_action entity
    calc_entity_movement entity
  end

  def calc_entity_rect entity
    entity.render_rect = { x: entity.x, y: entity.y, w: entity.w, h: entity.h }
    entity.rect = entity.render_rect.merge x: entity.render_rect.x + entity.render_rect.w * 0.33,
                                           w: entity.render_rect.w * 0.33
    entity.next_rect = entity.rect.merge x: entity.x + entity.dx,
                                         y: entity.y + entity.dy
    entity.prev_rect = entity.rect.merge x: entity.x - entity.dx,
                                         y: entity.y - entity.dy
    orientation_shift = 0
    if entity.orientation == :right
      orientation_shift = entity.rect.w.half
    end
    entity.hurt_rect  = entity.rect.merge y: entity.rect.y + entity.h * 0.33,
                                          x: entity.rect.x - entity.rect.w.half + orientation_shift,
                                          h: entity.rect.h * 0.33
  end

  def calc_entity_collision entity
    calc_entity_below entity
    calc_entity_left entity
    calc_entity_right entity
  end

  def calc_entity_below entity
    return unless entity.dy < 0
    tiles_below = find_tiles { |t| t.rect.top <= entity.prev_rect.y }
    collision = find_collision tiles_below, (entity.rect.merge y: entity.next_rect.y)
    return unless collision
    can_drop = true
    if entity.last_standing_at && (entity.clock - entity.last_standing_at) < 8
      can_drop = false
    end

    if can_drop && entity.jumped_down_at.elapsed_time(entity.clock) < 10 && !collision.impassable
      if (entity_on_platform? entity) && can_drop
        entity.dy = -1
      end

      entity.jump_count = 1
    else
      entity.y  = collision.rect.y + collision.rect.h
      entity.dy = 0
      entity.jump_count = 0
    end
  end

  def calc_entity_left entity
    return unless entity.dx < 0
    return if entity.next_rect.x > 8 - 32
    entity.x  = 8 - 32
    entity.dx = 0
  end

  def calc_entity_right entity
    return unless entity.dx > 0
    return if (entity.next_rect.x + entity.rect.w) < (1280 - 8 - 32)
    entity.x  = (1280 - 8 - entity.rect.w - 32)
    entity.dx = 0
  end

  def calc_entity_action entity
    if entity.dy < 0
      if entity.action == :midair_jump
        if entity_action_complete? entity, state.midair_jump_duration
          entity_set_action! entity, :falling
        end
      else
        entity_set_action! entity, :falling
      end
    elsif entity.dy == 0 && !(entity_on_platform? entity)
      if entity.left_right == 0
        entity_set_action! entity, :standing
      else
        entity_set_action! entity, :running
      end
    end
  end

  def calc_entity_movement entity
    calc_entity_dy entity
    calc_entity_dx entity
  end

  def calc_entity_dx entity
    entity.dx  = entity.dx.clamp(-5,  5)
    entity.dx *= 0.9
    entity.x  += entity.dx
  end

  def calc_entity_dy entity
    entity.y  += entity.dy
    entity.dy += state.gravity
    entity.dy += entity.dy * state.drag ** 2 * -1
  end

  def calc_shadows
    add_shadow! if state.clock.zmod?(300)

    shadows.each do |shadow|
      calc_entity shadow
      shadow.spawn_countdown -= 1 if shadow.spawn_countdown > 0
    end
  end

  def calc_light_crystal
    light_rect = state.light_crystal
    if player.hurt_rect.intersect_rect? light_rect
      state.jitter_fade_out_render_queue << { x:    state.light_crystal.x,
                                              y:    state.light_crystal.y,
                                              w:    state.light_crystal.w,
                                              h:    state.light_crystal.h,
                                              a:    255,
                                              path: 'sprites/light.png' }
      state.light_meter_queue += 600
      state.light_crystal = new_light_crystal
    end
  end

  def calc_render_queues
    state.jitter_fade_out_render_queue.each do |s|
      new_w = s.w * 1.02 ** 5
      ds = new_w - s.w
      s.w = new_w
      s.h = new_w
      s.x -= ds.half
      s.y -= ds.half
      s.a = s.a * 0.97 ** 5
    end

    state.jitter_fade_out_render_queue.reject! { |s| s.a <= 1 }

    state.game_over_render_queue.each { |s| s.a = s.a * 0.95 }
    state.game_over_render_queue.reject! { |s| s.a <= 1 }
  end

  def calc_game_over
    state.game_over = false
    state.game_over ||= shadows.find_all { |s| s.spawn_countdown <= 0 }
                               .any? { |s| s.hurt_rect.intersect_rect? player.hurt_rect }

    state.game_over ||= state.light_meter <= 1

    if inputs.keyboard.key_down.r
      state.you_win = false
      state.game_over = true
    end

    if state.game_over
      state.you_win = false
      state.game_over = true
    end

    if state.light_meter >= 6000
      state.you_win = true
      state.game_over = true
    end

    if state.game_over
      state.game_over_render_queue.concat shadows.map { |s| s.sprite.merge(a: 255) }
      state.game_over_render_queue << player.sprite.merge(a: 255)
      state.game_over_render_queue << state.light_crystal.merge(a: 255, path: 'sprites/light.png', b: 128)
    end
  end

  def calc_clock
    return if state.game_over
    state.clock += 1
    player.clock += 1
    shadows.each { |s| s.clock += 1 if entity_active? s }
  end

  def render
    render_stage
    render_light_meter
    render_instructions
    render_render_queues
    render_light_meter_warning
    render_light_crystal
    render_entities
  end

  def render_stage
    outputs.background_color = [255, 255, 255]
    outputs.sprites << { x: 0,
                         y: 0,
                         w: 1280,
                         h: 720,
                         path: "sprites/stage.png",
                         a: 200 }
  end

  def render_light_meter
    meter_perc = state.light_meter.fdiv(6000) + (0.002 * rand)
    light_w = (1280 * meter_perc).round
    dark_w  = 1280 - light_w
    outputs.sprites << { x: 0,
                         y: 64.from_top,
                         w: light_w,
                         source_x: 0,
                         source_y: 0,
                         source_w: light_w,
                         source_h: 128,
                         h: 64,
                         path: 'sprites/meter-light.png' }

    outputs.sprites << { x: 1280 * meter_perc,
                         y: 64.from_top,
                         w: dark_w,
                         source_x: light_w,
                         source_y: 0,
                         source_w: dark_w,
                         source_h: 128,
                         h: 64,
                         path: 'sprites/meter-dark.png' }
  end

  def render_instructions
    outputs.labels << { x: 640,
                        y: 40,
                        text: '[left/right] to move, [up/space] to jump, [down] to drop through platform',
                        alignment_enum: 1 }

    if state.you_win
      outputs.labels << { x: 640,
                          y: 40.from_top,
                          text: 'You win!',
                          size_enum: -1,
                          alignment_enum: 1 }
    end
  end

  def render_render_queues
    outputs.sprites << state.jitter_fade_out_render_queue
    outputs.sprites << state.game_over_render_queue
  end

  def render_light_meter_warning
    return if state.light_meter >= 255

    outputs.primitives << { x: 0,
                            y: 0,
                            w: 1280,
                            h: 720,
                            a: 255 - state.light_meter,
                            path: :pixel,
                            r: 0,
                            g: 0,
                            b: 0 }

    outputs.primitives << { x: state.light_crystal.x - 32,
                            y: state.light_crystal.y - 32,
                            w: 128,
                            h: 128,
                            a: 255 - state.light_meter,
                            path: 'sprites/spotlight.png' }
  end

  def render_light_crystal
    jitter_sprite = { x: state.light_crystal.x + 5 * rand,
                      y: state.light_crystal.y + 5 * rand,
                      w: state.light_crystal.w + 5 * rand,
                      h: state.light_crystal.h + 5 * rand,
                      path: 'sprites/light.png' }
    outputs.primitives << jitter_sprite
  end

  def render_entities
    render_entity player, r: 0, g: 0, b: 0
    shadows.each { |shadow| render_entity shadow, g: 0, b: 0 }
  end

  def render_entity entity, r: 255, g: 255, b: 255;
    a = 255

    entity.sprite = nil

    if entity.activate_at
      activation_elapsed_time = state.clock - entity.activate_at
      if entity.activate_at > state.clock
        entity.sprite = { x: entity.initial_x + 5 * rand,
                          y: entity.initial_y + 5 * rand,
                          w: 64 + 5 * rand,
                          h: 64 + 5 * rand,
                          path: "sprites/light.png",
                          g: 0, b: 0,
                          a: a }

        outputs.sprites << entity.sprite
        return
      elsif !entity.activated
        entity.activated = true
        state.jitter_fade_out_render_queue << { x: entity.initial_x + 5 * rand,
                                                y: entity.initial_y + 5 * rand,
                                                w: 86 + 5 * rand, h: 86 + 5 * rand,
                                                path: "sprites/light.png",
                                                g: 0, b: 0, a: 255 }
      end
    end

    if entity.action == :standing
      path = "sprites/player/stand.png"
    elsif entity.action == :running
      sprint_index = entity.action_at
                           .frame_index count: 4,
                                        hold_for: 8,
                                        repeat: true,
                                        tick_count_override: entity.clock
      path = "sprites/player/run-#{sprint_index}.png"
    elsif entity.action == :first_jump
      sprint_index = entity.action_at
                           .frame_index count: 2,
                                        hold_for: 8,
                                        repeat: false,
                                        tick_count_override: entity.clock
      path = "sprites/player/jump-#{sprint_index || 1}.png"
    elsif entity.action == :midair_jump
      sprint_index = entity.action_at
                           .frame_index count: state.midair_jump_frame_count,
                                        hold_for: state.midair_jump_hold_for,
                                        repeat: false,
                                        tick_count_override: entity.clock
      path = "sprites/player/midair-jump-#{sprint_index || 8}.png"
    elsif entity.action == :falling
      path = "sprites/player/falling.png"
    end

    flip_horizontally = true if entity.orientation == :left
    entity.sprite = entity.render_rect.merge path: path,
                                             a: a,
                                             r: r,
                                             g: g,
                                             b: b,
                                             flip_horizontally: flip_horizontally
    outputs.sprites << entity.sprite
  end

  def new_game
    state.clock                   = 0
    state.game_over               = false
    state.gravity                 = -0.4
    state.drag                    = 0.15

    state.activation_time         = 90
    state.light_meter             = 600
    state.light_meter_queue       = 0

    state.midair_jump_frame_count = 9
    state.midair_jump_hold_for    = 6
    state.midair_jump_duration    = state.midair_jump_frame_count * state.midair_jump_hold_for

    state.tiles                   = [
      { impassable: true, x: 0, y: 0, w: 1280, h: 8, path: :pixel, r: 0, g: 0, b: 0 },
      { impassable: true, x: 0, y: 0, w: 8, h: 1500, path: :pixel, r: 0, g: 0, b: 0 },
      { impassable: true, x: 1280 - 8, y: 0, w: 8, h: 1500, path: :pixel, r: 0, g: 0, b: 0 },

      { x: 80 + 320 + 80,            y: 128, w: 320, h: 8, path: :pixel, r: 0, g: 0, b: 0 },
      { x: 80 + 320 + 80 + 320 + 80, y: 192, w: 320, h: 8, path: :pixel, r: 0, g: 0, b: 0 },

      { x: 160,                      y: 320, w: 400, h: 8, path: :pixel, r: 0, g: 0, b: 0 },
      { x: 160 + 400 + 160,          y: 400, w: 400, h: 8, path: :pixel, r: 0, g: 0, b: 0 },

      { x: 320,                      y: 600, w: 320, h: 8, path: :pixel, r: 0, g: 0, b: 0 },

      { x: 8, y: 500, w: 100, h: 8, path: :pixel, r: 0, g: 0, b: 0 },

      { x: 8, y: 60, w: 100, h: 8, path: :pixel, r: 0, g: 0, b: 0 },
    ]

    state.player                = new_entity
    state.player.jump_count     = 1
    state.player.jumped_at      = state.player.clock
    state.player.jumped_down_at = 0

    state.shadows   = []

    state.input_timeline = [
      { at: 0, k: :left_right, v: inputs.left_right },
      { at: 0, k: :space,      v: false },
      { at: 0, k: :down,       v: false },
    ]

    state.jitter_fade_out_render_queue   = []
    state.game_over_render_queue       ||= []

    state.light_crystal = new_light_crystal
  end

  def new_light_crystal
    r = { x: 124 + rand(1000), y: 135 + rand(500), w: 64, h: 64 }
    return new_light_crystal if tiles.any? { |t| t.intersect_rect? r }
    return new_light_crystal if (player.x - r.x).abs < 200
    r
  end

  def entity_active? entity
    return true unless entity.activate_at
    return entity.activate_at <= state.clock
  end

  def add_shadow!
    s = new_entity(from_entity: player)
    s.activate_at = state.clock + state.activation_time * (shadows.length + 1)
    s.spawn_countdown = state.activation_time
    shadows << s
  end

  def find_input_timeline at:, key:;
    state.input_timeline.find { |t| t.at <= at && t.k == key }.v
  end

  def new_entity from_entity: nil
    pe = state.new_entity(:body)
    pe.w                  = 96
    pe.h                  = 96
    pe.jump_power         = 12
    pe.y                  = 500
    pe.x                  = 640 - 8
    pe.initial_x          = pe.x
    pe.initial_y          = pe.y
    pe.dy                 = 0
    pe.dx                 = 0
    pe.jumped_down_at     = 0
    pe.jumped_at          = 0
    pe.jump_count         = 0
    pe.clock              = state.clock
    pe.orientation        = :right
    pe.action             = :falling
    pe.action_at          = state.clock
    pe.left_right         = 0
    if from_entity
      pe.w              = from_entity.w
      pe.h              = from_entity.h
      pe.jump_power     = from_entity.jump_power
      pe.x              = from_entity.x
      pe.y              = from_entity.y
      pe.initial_x      = from_entity.x
      pe.initial_y      = from_entity.y
      pe.dy             = from_entity.dy
      pe.dx             = from_entity.dx
      pe.jumped_down_at = from_entity.jumped_down_at
      pe.jumped_at      = from_entity.jumped_at
      pe.orientation    = from_entity.orientation
      pe.action         = from_entity.action
      pe.action_at      = from_entity.action_at
      pe.jump_count     = from_entity.jump_count
      pe.left_right     = from_entity.left_right
    end
    pe
  end

  def entity_on_platform? entity
    entity.action == :standing || entity.action == :running
  end

  def entity_action_complete? entity, action_duration
    entity.action_at.elapsed_time(entity.clock) + 1 >= action_duration
  end

  def entity_set_action! entity, action
    entity.action = action
    entity.action_at = entity.clock
    entity.last_standing_at = entity.clock if action == :standing
  end

  def player
    state.player
  end

  def shadows
    state.shadows
  end

  def tiles
    state.tiles
  end

  def find_tiles &block
    tiles.find_all(&block)
  end

  def find_collision tiles, target
    tiles.find { |t| t.rect.intersect_rect? target }
  end
end

def boot args
  $game = Game.new
end

def tick args
  $game.args = args
  $game.tick
end

def reset args
  $game = Game.new
end
