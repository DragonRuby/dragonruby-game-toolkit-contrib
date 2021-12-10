class FlappyDragon
  attr_accessor :grid, :inputs, :state, :outputs

  def tick
    defaults
    render
    calc
    process_inputs
  end

  def defaults
    state.flap_power              = 11
    state.gravity                 = 0.9
    state.ceiling                 = 600
    state.ceiling_flap_power      = 6
    state.wall_countdown_length   = 100
    state.wall_gap_size           = 100
    state.wall_countdown        ||= 0
    state.hi_score              ||= 0
    state.score                 ||= 0
    state.walls                 ||= []
    state.x                     ||= 50
    state.y                     ||= 500
    state.dy                    ||= 0
    state.scene                 ||= :menu
    state.scene_at              ||= 0
    state.difficulty            ||= :normal
    state.new_difficulty        ||= :normal
    state.countdown             ||= 4.seconds
    state.flash_at              ||= 0
  end

  def render
    outputs.sounds << "sounds/flappy-song.ogg" if state.tick_count == 1
    render_score
    render_menu
    render_game
  end

  def render_score
    outputs.primitives << { x: 10, y: 710, text: "HI SCORE: #{state.hi_score}", **large_white_typeset }
    outputs.primitives << { x: 10, y: 680, text: "SCORE: #{state.score}", **large_white_typeset }
    outputs.primitives << { x: 10, y: 650, text: "DIFFICULTY: #{state.difficulty.upcase}", **large_white_typeset }
  end

  def render_menu
    return unless state.scene == :menu
    render_overlay

    outputs.labels << { x: 640, y: 700, text: "Flappy Dragon", size_enum: 50, alignment_enum: 1, **white }
    outputs.labels << { x: 640, y: 500, text: "Instructions: Press Spacebar to flap. Don't die.", size_enum: 4, alignment_enum: 1, **white }
    outputs.labels << { x: 430, y: 430, text: "[Tab]    Change difficulty", size_enum: 4, alignment_enum: 0, **white }
    outputs.labels << { x: 430, y: 400, text: "[Enter]  Start at New Difficulty ", size_enum: 4, alignment_enum: 0, **white }
    outputs.labels << { x: 430, y: 370, text: "[Escape] Cancel/Resume ", size_enum: 4, alignment_enum: 0, **white }
    outputs.labels << { x: 640, y: 300, text: "(mouse, touch, and game controllers work, too!) ", size_enum: 4, alignment_enum: 1, **white }
    outputs.labels << { x: 640, y: 200, text: "Difficulty: #{state.new_difficulty.capitalize}", size_enum: 4, alignment_enum: 1, **white }

    outputs.labels << { x: 10, y: 100, text: "Code:   @amirrajan",     **white }
    outputs.labels << { x: 10, y:  80, text: "Art:    @mobypixel",     **white }
    outputs.labels << { x: 10, y:  60, text: "Music:  @mobypixel",     **white }
    outputs.labels << { x: 10, y:  40, text: "Engine: DragonRuby GTK", **white }
  end

  def render_overlay
    overlay_rect = grid.rect.scale_rect(1.1, 0, 0)
    outputs.primitives << { x: overlay_rect.x,
                            y: overlay_rect.y,
                            w: overlay_rect.w,
                            h: overlay_rect.h,
                            r: 0, g: 0, b: 0, a: 230 }.solid!
  end

  def render_game
    render_game_over
    render_background
    render_walls
    render_dragon
    render_flash
  end

  def render_game_over
    return unless state.scene == :game
    outputs.labels << { x: 638, y: 358, text: score_text,     size_enum: 20, alignment_enum: 1 }
    outputs.labels << { x: 635, y: 360, text: score_text,     size_enum: 20, alignment_enum: 1, r: 255, g: 255, b: 255 }
    outputs.labels << { x: 638, y: 428, text: countdown_text, size_enum: 20, alignment_enum: 1 }
    outputs.labels << { x: 635, y: 430, text: countdown_text, size_enum: 20, alignment_enum: 1, r: 255, g: 255, b: 255 }
  end

  def render_background
    outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: 'sprites/background.png' }

    scroll_point_at   = state.tick_count
    scroll_point_at   = state.scene_at if state.scene == :menu
    scroll_point_at   = state.death_at if state.countdown > 0
    scroll_point_at ||= 0

    outputs.sprites << scrolling_background(scroll_point_at, 'sprites/parallax_back.png',   0.25)
    outputs.sprites << scrolling_background(scroll_point_at, 'sprites/parallax_middle.png', 0.50)
    outputs.sprites << scrolling_background(scroll_point_at, 'sprites/parallax_front.png',  1.00, -80)
  end

  def scrolling_background at, path, rate, y = 0
    [
      { x:    0 - at.*(rate) % 1440, y: y, w: 1440, h: 720, path: path },
      { x: 1440 - at.*(rate) % 1440, y: y, w: 1440, h: 720, path: path }
    ]
  end

  def render_walls
    state.walls.each do |w|
      w.sprites = [
        { x: w.x, y: w.bottom_height - 720, w: 100, h: 720, path: 'sprites/wall.png',       angle: 180 },
        { x: w.x, y: w.top_y,               w: 100, h: 720, path: 'sprites/wallbottom.png', angle: 0 }
      ]
    end
    outputs.sprites << state.walls.map(&:sprites)
  end

  def render_dragon
    state.show_death = true if state.countdown == 3.seconds

    if state.show_death == false || !state.death_at
      animation_index = state.flapped_at.frame_index 6, 2, false if state.flapped_at
      sprite_name = "sprites/dragon_fly#{animation_index.or(0) + 1}.png"
      state.dragon_sprite = { x: state.x, y: state.y, w: 100, h: 80, path: sprite_name, angle: state.dy * 1.2 }
    else
      sprite_name = "sprites/dragon_die.png"
      state.dragon_sprite = { x: state.x, y: state.y, w: 100, h: 80, path: sprite_name, angle: state.dy * 1.2 }
      sprite_changed_elapsed    = state.death_at.elapsed_time - 1.seconds
      state.dragon_sprite.angle += (sprite_changed_elapsed ** 1.3) * state.death_fall_direction * -1
      state.dragon_sprite.x     += (sprite_changed_elapsed ** 1.2) * state.death_fall_direction
      state.dragon_sprite.y     += (sprite_changed_elapsed * 14 - sprite_changed_elapsed ** 1.6)
    end

    outputs.sprites << state.dragon_sprite
  end

  def render_flash
    return unless state.flash_at

    outputs.primitives << { **grid.rect.to_hash,
                            **white,
                            a: 255 * state.flash_at.ease(20, :flip) }.solid!

    state.flash_at = 0 if state.flash_at.elapsed_time > 20
  end

  def calc
    return unless state.scene == :game
    reset_game if state.countdown == 1
    state.countdown -= 1 and return if state.countdown > 0
    calc_walls
    calc_flap
    calc_game_over
  end

  def calc_walls
    state.walls.each { |w| w.x -= 8 }

    walls_count_before_removal = state.walls.length

    state.walls.reject! { |w| w.x < -100 }

    state.score += 1 if state.walls.count < walls_count_before_removal

    state.wall_countdown -= 1 and return if state.wall_countdown > 0

    state.walls << state.new_entity(:wall) do |w|
      w.x             = grid.right
      w.opening       = grid.top
                            .randomize(:ratio)
                            .greater(200)
                            .lesser(520)
      w.bottom_height = w.opening - state.wall_gap_size
      w.top_y         = w.opening + state.wall_gap_size
    end

    state.wall_countdown = state.wall_countdown_length
  end

  def calc_flap
    state.y += state.dy
    state.dy = state.dy.lesser state.flap_power
    state.dy -= state.gravity
    return if state.y < state.ceiling
    state.y  = state.ceiling
    state.dy = state.dy.lesser state.ceiling_flap_power
  end

  def calc_game_over
    return unless game_over?

    state.death_at = state.tick_count
    state.death_from = state.walls.first
    state.death_fall_direction = -1
    state.death_fall_direction =  1 if state.x > state.death_from.x
    outputs.sounds << "sounds/hit-sound.wav"
    begin_countdown
  end

  def process_inputs
    process_inputs_menu
    process_inputs_game
  end

  def process_inputs_menu
    return unless state.scene == :menu

    changediff = inputs.keyboard.key_down.tab || inputs.controller_one.key_down.select
    if inputs.mouse.click
      p = inputs.mouse.click.point
      if (p.y >= 165) && (p.y < 200) && (p.x >= 500) && (p.x < 800)
        changediff = true
      end
    end

    if changediff
      case state.new_difficulty
      when :easy
        state.new_difficulty = :normal
      when :normal
        state.new_difficulty = :hard
      when :hard
        state.new_difficulty = :flappy
      when :flappy
        state.new_difficulty = :easy
      end
    end

    if inputs.keyboard.key_down.enter || inputs.controller_one.key_down.start || inputs.controller_one.key_down.a
      state.difficulty = state.new_difficulty
      change_to_scene :game
      reset_game false
      state.hi_score = 0
      begin_countdown
    end

    if inputs.keyboard.key_down.escape || (inputs.mouse.click && !changediff) || inputs.controller_one.key_down.b
      state.new_difficulty = state.difficulty
      change_to_scene :game
    end
  end

  def process_inputs_game
    return unless state.scene == :game

    clicked_menu = false
    if inputs.mouse.click
      p = inputs.mouse.click.point
      clicked_menu = (p.y >= 620) && (p.x < 275)
    end

    if clicked_menu || inputs.keyboard.key_down.escape || inputs.keyboard.key_down.enter || inputs.controller_one.key_down.start
      change_to_scene :menu
    elsif (inputs.mouse.down || inputs.mouse.click || inputs.keyboard.key_down.space || inputs.controller_one.key_down.a) && state.countdown == 0
      state.dy = 0
      state.dy += state.flap_power
      state.flapped_at = state.tick_count
      outputs.sounds << "sounds/fly-sound.wav"
    end
  end

  def white
    { r: 255, g: 255, b: 255 }
  end

  def large_white_typeset
    { size_enum: 5, alignment_enum: 0, r: 255, g: 255, b: 255 }
  end

  def at_beginning?
    state.walls.count == 0
  end

  def dragon_collision_box
    state.dragon_sprite
         .scale_rect(1.0 - collision_forgiveness, 0.5, 0.5)
         .rect_shift_right(10)
         .rect_shift_up(state.dy * 2)
  end

  def game_over?
    return true if state.y <= 0.-(500 * collision_forgiveness) && !at_beginning?

    state.walls
        .flat_map { |w| w.sprites }
        .any? do |s|
          s && s.intersect_rect?(dragon_collision_box)
        end
  end

  def collision_forgiveness
    case state.difficulty
    when :easy
      0.9
    when :normal
      0.7
    when :hard
      0.5
    when :flappy
      0.3
    else
      0.9
    end
  end

  def countdown_text
    state.countdown ||= -1
    return ""          if state.countdown == 0
    return "GO!"       if state.countdown.idiv(60) == 0
    return "GAME OVER" if state.death_at
    return "READY?"
  end

  def begin_countdown
    state.countdown = 4.seconds
  end

  def score_text
    return ""                        unless state.countdown > 1.seconds
    return ""                        unless state.death_at
    return "SCORE: 0 (LOL)"          if state.score == 0
    return "HI SCORE: #{state.score}" if state.score == state.hi_score
    return "SCORE: #{state.score}"
  end

  def reset_game set_flash = true
    state.flash_at = state.tick_count if set_flash
    state.walls = []
    state.y = 500
    state.dy = 0
    state.hi_score = state.hi_score.greater(state.score)
    state.score = 0
    state.wall_countdown = state.wall_countdown_length.fdiv(2)
    state.show_death = false
    state.death_at = nil
  end

  def change_to_scene scene
    state.scene = scene
    state.scene_at = state.tick_count
    inputs.keyboard.clear
    inputs.controller_one.clear
  end
end

$flappy_dragon = FlappyDragon.new

def tick args
  $flappy_dragon.grid = args.grid
  $flappy_dragon.inputs = args.inputs
  $flappy_dragon.state = args.state
  $flappy_dragon.outputs = args.outputs
  $flappy_dragon.tick
end
