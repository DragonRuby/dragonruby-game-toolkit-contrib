class YouSoBasicGorillas
  attr_accessor :outputs, :grid, :state, :inputs

  def tick
    defaults
    render
    calc
    process_inputs
  end

  def defaults
    outputs.background_color = [33, 32, 87]
    state.building_spacing       = 1
    state.building_room_spacing  = 15
    state.building_room_width    = 10
    state.building_room_height   = 15
    state.building_heights       = [4, 4, 6, 8, 15, 20, 18]
    state.building_room_sizes    = [5, 4, 6, 7]
    state.gravity                = 0.25
    state.first_strike         ||= :player_1
    state.buildings            ||= []
    state.holes                ||= []
    state.player_1_score       ||= 0
    state.player_2_score       ||= 0
    state.wind                 ||= 0
  end

  def render
    render_stage
    render_value_insertion
    render_gorillas
    render_holes
    render_banana
    render_game_over
    render_score
    render_wind
  end

  def render_score
    outputs.primitives << [0, 0, 1280, 31, fancy_white].solid
    outputs.primitives << [1, 1, 1279, 29].solid
    outputs.labels << [  10, 25, "Score: #{state.player_1_score}", 0, 0, fancy_white]
    outputs.labels << [1270, 25, "Score: #{state.player_2_score}", 0, 2, fancy_white]
  end

  def render_wind
    outputs.primitives << [640, 12, state.wind * 500 + state.wind * 10 * rand, 4, 35, 136, 162].solid
    outputs.lines     <<  [640, 30, 640, 0, fancy_white]
  end

  def render_game_over
    return unless state.over
    outputs.primitives << [grid.rect, 0, 0, 0, 200].solid
    outputs.primitives << [640, 370, "Game Over!!", 5, 1, fancy_white].label
    if state.winner == :player_1
      outputs.primitives << [640, 340, "Player 1 Wins!!", 5, 1, fancy_white].label
    else
      outputs.primitives << [640, 340, "Player 2 Wins!!", 5, 1, fancy_white].label
    end
  end

  def render_stage
    return unless state.stage_generated
    return if state.stage_rendered

    outputs.static_solids << [grid.rect, 33, 32, 87]
    outputs.static_solids << state.buildings.map(&:solids)
    state.stage_rendered = true
  end

  def render_gorilla gorilla, id
    return unless gorilla
    if state.banana && state.banana.owner == gorilla
      animation_index  = state.banana.created_at.frame_index(3, 5, false)
    end
    if !animation_index
      outputs.sprites << [gorilla.solid, "sprites/#{id}-idle.png"]
    else
      outputs.sprites << [gorilla.solid, "sprites/#{id}-#{animation_index}.png"]
    end
  end

  def render_gorillas
    render_gorilla state.player_1, :left
    render_gorilla state.player_2, :right
  end

  def render_value_insertion
    return if state.banana
    return if state.over

    if    state.current_turn == :player_1_angle
      outputs.labels << [  10, 710, "Angle:    #{state.player_1_angle}_",    fancy_white]
    elsif state.current_turn == :player_1_velocity
      outputs.labels << [  10, 710, "Angle:    #{state.player_1_angle}",     fancy_white]
      outputs.labels << [  10, 690, "Velocity: #{state.player_1_velocity}_", fancy_white]
    elsif state.current_turn == :player_2_angle
      outputs.labels << [1120, 710, "Angle:    #{state.player_2_angle}_",    fancy_white]
    elsif state.current_turn == :player_2_velocity
      outputs.labels << [1120, 710, "Angle:    #{state.player_2_angle}",     fancy_white]
      outputs.labels << [1120, 690, "Velocity: #{state.player_2_velocity}_", fancy_white]
    end
  end

  def render_banana
    return unless state.banana
    rotation = state.tick_count.%(360) * 20
    rotation *= -1 if state.banana.dx > 0
    outputs.sprites << [state.banana.x, state.banana.y, 15, 15, 'sprites/banana.png', rotation]
  end

  def render_holes
    outputs.sprites << state.holes.map do |s|
      animation_index = s.created_at.frame_index(7, 3, false)
      if animation_index
        [s.sprite, [s.sprite.rect, "sprites/explosion#{animation_index}.png" ]]
      else
        s.sprite
      end
    end
  end

  def calc
    calc_generate_stage
    calc_current_turn
    calc_banana
  end

  def calc_current_turn
    return if state.current_turn

    state.current_turn = :player_1_angle
    state.current_turn = :player_2_angle if state.first_strike == :player_2
  end

  def calc_generate_stage
    return if state.stage_generated

    state.buildings << building_prefab(state.building_spacing + -20, *random_building_size)
    8.numbers.inject(state.buildings) do |buildings, i|
      buildings <<
        building_prefab(state.building_spacing +
                        state.buildings.last.right,
                        *random_building_size)
    end

    building_two = state.buildings[1]
    state.player_1 = new_player(building_two.x + building_two.w.fdiv(2),
                               building_two.h)

    building_nine = state.buildings[-3]
    state.player_2 = new_player(building_nine.x + building_nine.w.fdiv(2),
                               building_nine.h)
    state.stage_generated = true
    state.wind = 1.randomize(:ratio, :sign)
  end

  def new_player x, y
    state.new_entity(:gorilla) do |p|
      p.x = x - 25
      p.y = y
      p.solid = [p.x, p.y, 50, 50]
    end
  end

  def calc_banana
    return unless state.banana

    state.banana.x  += state.banana.dx
    state.banana.dx += state.wind.fdiv(50)
    state.banana.y  += state.banana.dy
    state.banana.dy -= state.gravity
    banana_collision = [state.banana.x, state.banana.y, 10, 10]

    if state.player_1 && banana_collision.intersect_rect?(state.player_1.solid)
      state.over = true
      if state.banana.owner == state.player_2
        state.winner = :player_2
      else
        state.winner = :player_1
      end

      state.player_2_score += 1
    elsif state.player_2 && banana_collision.intersect_rect?(state.player_2.solid)
      state.over = true
      if state.banana.owner == state.player_2
        state.winner = :player_1
      else
        state.winner = :player_2
      end
      state.player_1_score += 1
    end

    if state.over
      place_hole
      return
    end

    return if state.holes.any? do |h|
      h.sprite.scale_rect(0.8, 0.5, 0.5).intersect_rect? [state.banana.x, state.banana.y, 10, 10]
    end

    return unless state.banana.y < 0 || state.buildings.any? do |b|
      b.rect.intersect_rect? [state.banana.x, state.banana.y, 1, 1]
    end

    place_hole
  end

  def place_hole
    return unless state.banana

    state.holes << state.new_entity(:banana) do |b|
      b.sprite = [state.banana.x - 20, state.banana.y - 20, 40, 40, 'sprites/hole.png']
    end

    state.banana = nil
  end

  def process_inputs_main
    return if state.banana
    return if state.over

    if inputs.keyboard.key_down.enter
      input_execute_turn
    elsif inputs.keyboard.key_down.backspace
      state.as_hash[state.current_turn] ||= ""
      state.as_hash[state.current_turn]   = state.as_hash[state.current_turn][0..-2]
    elsif inputs.keyboard.key_down.char
      state.as_hash[state.current_turn] ||= ""
      state.as_hash[state.current_turn]  += inputs.keyboard.key_down.char
    end
  end

  def process_inputs_game_over
    return unless state.over
    return unless inputs.keyboard.key_down.truthy_keys.any?
    state.over = false
    outputs.static_solids.clear
    state.buildings.clear
    state.holes.clear
    state.stage_generated = false
    state.stage_rendered = false
    if state.first_strike == :player_1
      state.first_strike = :player_2
    else
      state.first_strike = :player_1
    end
  end

  def process_inputs
    process_inputs_main
    process_inputs_game_over
  end

  def input_execute_turn
    return if state.banana

    if state.current_turn == :player_1_angle && parse_or_clear!(:player_1_angle)
      state.current_turn = :player_1_velocity
    elsif state.current_turn == :player_1_velocity && parse_or_clear!(:player_1_velocity)
      state.current_turn = :player_2_angle
      state.banana =
        new_banana(state.player_1,
                   state.player_1.x + 25,
                   state.player_1.y + 60,
                   state.player_1_angle,
                   state.player_1_velocity)
    elsif state.current_turn == :player_2_angle && parse_or_clear!(:player_2_angle)
      state.current_turn = :player_2_velocity
    elsif state.current_turn == :player_2_velocity && parse_or_clear!(:player_2_velocity)
      state.current_turn = :player_1_angle
      state.banana =
        new_banana(state.player_2,
                   state.player_2.x + 25,
                   state.player_2.y + 60,
                   180 - state.player_2_angle,
                   state.player_2_velocity)
    end

    if state.banana
      state.player_1_angle = nil
      state.player_1_velocity = nil
      state.player_2_angle = nil
      state.player_2_velocity = nil
    end
  end

  def random_building_size
    [state.building_heights.sample, state.building_room_sizes.sample]
  end

  def int? v
    v.to_i.to_s == v.to_s
  end

  def random_building_color
    [[ 99,   0, 107],
     [ 35,  64, 124],
     [ 35, 136, 162],
     ].sample
  end

  def random_window_color
    [[ 88,  62, 104],
     [253, 224, 187]].sample
  end

  def windows_for_building starting_x, floors, rooms
    floors.-(1).combinations(rooms - 1).map do |floor, room|
      [starting_x +
       state.building_room_width.*(room) +
       state.building_room_spacing.*(room + 1),
       state.building_room_height.*(floor) +
       state.building_room_spacing.*(floor + 1),
       state.building_room_width,
       state.building_room_height,
       random_window_color]
    end
  end

  def building_prefab starting_x, floors, rooms
    state.new_entity(:building) do |b|
      b.x      = starting_x
      b.y      = 0
      b.w      = state.building_room_width.*(rooms) +
                 state.building_room_spacing.*(rooms + 1)
      b.h      = state.building_room_height.*(floors) +
                 state.building_room_spacing.*(floors + 1)
      b.right  = b.x + b.w
      b.rect   = [b.x, b.y, b.w, b.h]
      b.solids = [[b.x - 1, b.y, b.w + 2, b.h + 1, fancy_white],
                  [b.x, b.y, b.w, b.h, random_building_color],
                  windows_for_building(b.x, floors, rooms)]
    end
  end

  def parse_or_clear! game_prop
    if int? state.as_hash[game_prop]
      state.as_hash[game_prop] = state.as_hash[game_prop].to_i
      return true
    end

    state.as_hash[game_prop] = nil
    return false
  end

  def new_banana owner, x, y, angle, velocity
    state.new_entity(:banana) do |b|
      b.owner     = owner
      b.x         = x
      b.y         = y
      b.angle     = angle % 360
      b.velocity  = velocity / 5
      b.dx        = b.angle.vector_x(b.velocity)
      b.dy        = b.angle.vector_y(b.velocity)
    end
  end

  def fancy_white
    [253, 252, 253]
  end
end

$you_so_basic_gorillas = YouSoBasicGorillas.new

def tick args
  $you_so_basic_gorillas.outputs = args.outputs
  $you_so_basic_gorillas.grid    = args.grid
  $you_so_basic_gorillas.state    = args.state
  $you_so_basic_gorillas.inputs  = args.inputs
  $you_so_basic_gorillas.tick
end
