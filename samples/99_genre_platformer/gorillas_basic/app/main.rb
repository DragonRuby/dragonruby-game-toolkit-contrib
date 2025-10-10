class YouSoBasicGorillas
  attr_gtk

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
    state.current_turn         ||= :player_1
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
    outputs.primitives << { x: 0, y: 0, w: 1280, h: 31, path: :solid, **white_color }
    outputs.primitives << { x: 1, y: 1, w: 1279, h: 29, path: :solid, r: 0, g: 0, b: 0 }
    outputs.labels << { x: 10, y: 25, text: "Score: #{state.player_1_score}", **white_color }
    outputs.labels << { x: 1270, y: 25, text: "Score: #{state.player_2_score}", anchor_x: 1.0, **white_color }
  end

  def render_wind
    outputs.primitives << { x: 640, y: 12, w: state.wind * 500 + state.wind * 10 * rand, path: :solid, h: 4, r: 35, g: 136, b: 162 }
    outputs.lines     <<  { x: 640, y: 30, x2: 640, y2: 0, **white_color }
  end

  def render_game_over
    return unless state.game_over
    outputs.primitives << { **Grid.rect, path: :solid, r: 0, g: 0, b: 0, a: 200 }
    outputs.primitives << { x: 640, y: 370, text: "Game Over!!", size_px: 36, anchor_x: 0.5, **white_color }
    if state.winner == :player_1
      outputs.primitives << { x: 640, y: 340, text: "Player 1 Wins!!", size_px: 36, anchor_x: 0.5, **white_color }
    else
      outputs.primitives << { x: 640, y: 340, text: "Player 2 Wins!!", size_px: 36, anchor_x: 0.5, **white_color }
    end
  end

  def render_stage
    return if !state.stage_generated

    if !state.stage_rt_generated
      outputs[:stage].w = 1280
      outputs[:stage].h = 720
      outputs[:stage].solids << { **Grid.rect, r: 33, g: 32, b: 87 }
      outputs[:stage].solids << state.buildings.map(&:prefab)
      state.stage_rt_generated = true
    else
      outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :stage }
    end
  end

  def render_gorilla gorilla, player_id, id
    return unless gorilla
    if state.banana && state.banana.owner == player_id
      animation_index  = state.banana.created_at.frame_index(3, 5, false)
    end
    if !animation_index
      outputs.primitives << { **gorilla.hurt_box, path: "sprites/#{id}-idle.png" }
    else
      outputs.primitives << { **gorilla.hurt_box, path: "sprites/#{id}-#{animation_index}.png" }
    end
  end

  def render_gorillas
    render_gorilla state.player_1, :player_1, :left
    render_gorilla state.player_2, :player_2, :right
  end

  def render_value_insertion
    return if state.banana
    return if state.game_over

    turn = if state.current_turn_input == :player_1_angle || state.current_turn_input == :player_1_velocity
             "It's your turn Player 1!"
           else
             "It's your turn Player 2!"
           end

    outputs.labels << { x: 640, y: 720 - 22, text: turn, **white_color, anchor_x: 0.5, anchor_y: 0.5 }

    if    state.current_turn_input == :player_1_angle
      outputs.labels << { x: 10, y: 710, text: "Angle:    #{state.player_1_angle}_", **white_color }
    elsif state.current_turn_input == :player_1_velocity
      outputs.labels << { x: 10, y: 710, text: "Angle:    #{state.player_1_angle}",  **white_color }
      outputs.labels << { x: 10, y: 690, text: "Velocity: #{state.player_1_velocity}_", **white_color }
    elsif state.current_turn_input == :player_2_angle
      outputs.labels << { x: 1120, y: 710, text: "Angle:    #{state.player_2_angle}_", **white_color }
    elsif state.current_turn_input == :player_2_velocity
      outputs.labels << { x: 1120, y: 710, text: "Angle:    #{state.player_2_angle}",  **white_color }
      outputs.labels << { x: 1120, y: 690, text: "Velocity: #{state.player_2_velocity}_", **white_color }
    end
  end

  def render_banana
    return unless state.banana
    rotation = Kernel.tick_count.%(360) * 20
    rotation *= -1 if state.banana.dx > 0
    outputs.primitives << { x: state.banana.x, y: state.banana.y, w: 15, h: 15, path: "sprites/banana.png", angle: rotation }
  end

  def render_holes
    outputs.primitives << state.holes.map do |s|
      animation_index = s.created_at.frame_index(7, 3, false)
      if animation_index
        [s.prefab, { **s.prefab.rect, path: "sprites/explosion#{animation_index}.png" }]
      else
        s.prefab
      end
    end
  end

  def calc
    calc_generate_stage
    calc_current_turn
    calc_banana 0.5
    calc_banana 0.5
  end

  def calc_current_turn
    return if state.current_turn_input

    state.current_turn_input = :player_1_angle
    state.current_turn_input = :player_2_angle if state.current_turn == :player_2
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
    {
      x: (x - 25),
      y: y,
      hurt_box: { x: x - 25, y: y, w: 50, h: 50 }
    }
  end

  def calc_banana simulation_dt
    return unless state.banana

    state.banana.x  += state.banana.dx * simulation_dt
    state.banana.dx += state.wind.fdiv(50) * simulation_dt
    state.banana.y  += state.banana.dy * simulation_dt
    state.banana.dy -= state.gravity * simulation_dt
    banana_collision = { x: state.banana.x, y: state.banana.y, w: 10, h: 10 }

    if state.player_1 && banana_collision.intersect_rect?(state.player_1.hurt_box)
      state.game_over = true
      state.winner = :player_2
      state.player_2_score += 1
    elsif state.player_2 && banana_collision.intersect_rect?(state.player_2.hurt_box)
      state.game_over = true
      state.winner = :player_1
      state.player_1_score += 1
    end

    if state.game_over
      place_hole
      return
    end

    return if state.holes.any? do |h|
      h.prefab.intersect_rect?(x: state.banana.x, y: state.banana.y, w: 10, h: 10, anchor_x: 0.5, anchor_y: 0.5)
    end

    return unless state.banana.y < 0 || state.buildings.any? do |b|
      b.rect.intersect_rect? x: state.banana.x, y: state.banana.y, w: 1, h: 1
    end

    place_hole
  end

  def place_hole
    return unless state.banana

    state.holes << state.new_entity(:banana) do |b|
      b.prefab = { x: state.banana.x, y: state.banana.y, w: 40, h: 40, path: "sprites/hole.png", anchor_x: 0.5, anchor_y: 0.5 }
    end

    state.banana = nil
  end

  def process_inputs_main
    return if state.banana
    return if state.game_over

    if inputs.keyboard.key_down.enter
      input_execute_turn
    elsif inputs.keyboard.key_down.backspace
      state.as_hash[state.current_turn_input] ||= ""
      state.as_hash[state.current_turn_input]   = state.as_hash[state.current_turn_input][0..-2]
    elsif inputs.keyboard.key_down.char
      state.as_hash[state.current_turn_input] ||= ""
      state.as_hash[state.current_turn_input]  += inputs.keyboard.key_down.char
    end
  end

  def process_inputs_game_over
    return unless state.game_over
    return unless inputs.keyboard.key_down.truthy_keys.any?
    state.game_over = false
    outputs.static_solids.clear
    state.buildings.clear
    state.holes.clear
    state.stage_generated = false
    state.stage_rt_generated = false
    if state.current_turn == :player_1
      state.current_turn = :player_2
    else
      state.current_turn = :player_1
    end
  end

  def process_inputs
    process_inputs_main
    process_inputs_game_over
  end

  def input_execute_turn
    return if state.banana

    if state.current_turn_input == :player_1_angle && parse_or_clear!(:player_1_angle)
      state.current_turn_input = :player_1_velocity
    elsif state.current_turn_input == :player_1_velocity && parse_or_clear!(:player_1_velocity)
      state.current_turn_input = :player_2_angle
      state.banana =
        new_banana(:player_1,
                   state.player_1.x + 25,
                   state.player_1.y + 60,
                   state.player_1_angle,
                   state.player_1_velocity)
      state.current_turn = :player_2
    elsif state.current_turn_input == :player_2_angle && parse_or_clear!(:player_2_angle)
      state.current_turn_input = :player_2_velocity
    elsif state.current_turn_input == :player_2_velocity && parse_or_clear!(:player_2_velocity)
      state.current_turn_input = :player_1_angle
      state.banana =
        new_banana(:player_2,
                   state.player_2.x + 25,
                   state.player_2.y + 60,
                   180 - state.player_2_angle,
                         state.player_2_velocity)
      state.current_turn = :player_1
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
    [{ r: 99, g:   0, b: 107 },
     { r: 35, g:  64, b: 124 },
     { r: 35, g: 136, b: 162 }].sample
  end

  def random_window_color
    [{ r: 88,  g: 62,  b: 104 },
     { r: 253, g: 224, b: 187 }].sample
  end

  def windows_for_building starting_x, floors, rooms
    floors.-(1).combinations(rooms - 1).map do |floor, room|
      { x: starting_x + (state.building_room_width * room) + (state.building_room_spacing * (room + 1)),
        y: (state.building_room_height * floor) +
        (state.building_room_spacing * (floor + 1)),
        w: state.building_room_width,
        h: state.building_room_height,
        **random_window_color }
    end
  end

  def building_prefab starting_x, floors, rooms
    b = {}
    b.x      = starting_x
    b.y      = 0
    b.w      = (state.building_room_width * rooms) + (state.building_room_spacing * (rooms + 1))
    b.h      = (state.building_room_height * floors) + (state.building_room_spacing * (floors + 1))
    b.right  = b.x + b.w
    b.rect   = { x: b.x, y: b.y, w: b.w, h: b.h }
    b.prefab = [{ x: b.x - 1, y: b.y, w: b.w + 2, h: b.h + 1, **white_color },
                { x: b.x, y: b.y, w: b.w, h: b.h, **random_building_color },
                windows_for_building(b.x, floors, rooms)]
    b
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
    {
      owner: owner,
      x: x,
      y: y,
      angle: angle % 360,
      velocity: velocity / 5,
      dx: angle.vector_x(velocity / 5),
      dy: angle.vector_y(velocity / 5),
      created_at: Kernel.tick_count
    }
  end

  def white_color
    { r: 253, g: 252, b: 253 }
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= YouSoBasicGorillas.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end
