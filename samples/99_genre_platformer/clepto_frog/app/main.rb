MAP_FILE_PATH = 'map.txt'

require 'app/map.rb'

class CleptoFrog
  attr_gtk

  def render_ending
    state.game_over_at ||= state.tick_count

    outputs.labels << [640, 700, "Clepto Frog", 4, 1]

    if state.tick_count >= (state.game_over_at + 120)
      outputs.labels << [640, 620, "\"I... I.... don't believe it.\" - New Guy",
                         4, 1, 0, 0, 0, 255 * (state.game_over_at + 120).ease(60)]
    end

    if state.tick_count >= (state.game_over_at + 240)
      outputs.labels << [640, 580, "\"He actually stole all the mugs?\" - New Guy",
                         4, 1, 0, 0, 0, 255 * (state.game_over_at + 240).ease(60)]
    end

    if state.tick_count >= (state.game_over_at + 360)
      outputs.labels << [640, 540, "\"Kind of feel bad STARTING HIM WITH NOTHING again.\" - New Guy",
                         4, 1, 0, 0, 0, 255 * (state.game_over_at + 360).ease(60)]
    end

    outputs.sprites << [640 - 50, 360 - 50, 100, 100,
                        "sprites/square-green.png"]

    outputs.labels << [640, 300, "Current Time: #{"%.2f" % state.stuff_time}", 4, 1]
    outputs.labels << [640, 270, "Best Time: #{"%.2f" % state.stuff_best_time}", 4, 1]

    if state.tick_count >= (state.game_over_at + 550)
      restart_game
    end
  end

  def restart_game
    state.world = nil
    state.x = nil
    state.y = nil
    state.dx = nil
    state.dy = nil
    state.stuff_score = 0
    state.stuff_time = 0
    state.intro_tick_count = nil
    defaults
    state.game_start_at = state.tick_count
    state.scene = :game
    state.game_over_at = nil
  end

  def render_intro
    outputs.labels << [640, 700, "Clepto Frog", 4, 1]
    if state.tick_count == 120
      state.scene = :game
      state.game_start_at = state.tick_count
    end
  end

  def tick
    defaults
    if state.scene == :intro && state.tick_count <= 120
      render_intro
    elsif state.scene == :ending
      render_ending
    else
      render
    end
    calc
    process_inputs
  end

  def defaults
    state.scene ||= :intro
    state.stuff_score     ||= 0
    state.stuff_time      ||= 0
    state.stuff_best_time ||= nil
    state.camera_x ||= 0
    state.camera_y ||= 0
    state.target_camera_scale ||= 1
    state.camera_scale ||= 1
    state.tongue_length          ||= 100
    state.dev_action             ||= :collision_mode
    state.action                 ||= :aiming
    state.tongue_angle           ||= 90
    state.tile_size                = 64
    state.gravity                  = -0.1
    state.air                      = -0.01
    state.player_width             = 60
    state.player_height            = 60
    state.collision_tolerance      = 0.0
    state.previous_tile_size     ||= state.tile_size
    state.x                      ||= 2400
    state.y                      ||= 200
    state.dy                     ||= 0
    state.dx                     ||= 0
    attempt_load_world_from_file
    state.world_lookup           ||= { }
    state.world_collision_rects  ||= []
    state.mode                   ||= :creating
    state.select_menu            ||= [0, 720, 1280, 720]
    state.sprite_quantity        ||= 20
    state.sprite_coords          ||= []
    state.banner_coords          ||= [640, 680 + 720]
    state.sprite_selected        ||= 1
    state.map_saved_at           ||= 0
    state.intro_tick_count       ||= state.tick_count
    if state.sprite_coords == []
      count = 1
      temp_x = 165
      temp_y = 500 + 720
      state.sprite_quantity.times do
        state.sprite_coords += [[temp_x, temp_y, count]]
        temp_x += 100
        count += 1
        if temp_x > 1280 - (165 + 50)
          temp_x = 165
          temp_y -= 75
        end
      end
    end
  end

  def start_of_tongue x = nil, y = nil
    x ||= state.x
    y ||= state.y
    [
      x + state.player_width.half,
      y + state.player_height.half
    ]
  end

  def stage_definition
    outputs.sprites << [vx(0), vy(0), vw(10000), vw(5875), 'sprites/level-map.png']
  end

  def render
    stage_definition
    start_of_tongue_render = [vx(start_of_tongue.x), vy(start_of_tongue.y)]
    end_of_tongue_render = [vx(end_of_tongue.x), vy(end_of_tongue.y)]

    if state.anchor_point
      anchor_point_render = [vx(state.anchor_point.x), vy(state.anchor_point.y)]
      outputs.sprites << { x: start_of_tongue_render.x,
                           y: start_of_tongue_render.y,
                           w: vw(2),
                           h: args.geometry.distance(start_of_tongue_render, anchor_point_render),
                           path:  'sprites/square-pink.png',
                           angle_anchor_y: 0,
                           angle: state.tongue_angle - 90 }
    else
      outputs.sprites << { x: vx(start_of_tongue.x),
                           y: vy(start_of_tongue.y),
                           w: vw(2),
                           h: vh(state.tongue_length),
                           path:  'sprites/square-pink.png',
                           angle_anchor_y: 0,
                           angle: state.tongue_angle - 90 }
    end

    outputs.sprites << state.objects.map { |o| [vx(o.x), vy(o.y), vw(o.w), vh(o.h), o.path] }

    if state.god_mode
      # SHOW HIDE COLLISIONS
      outputs.sprites << state.world.map do |rect|
        x = vx(rect.x)
        y = vy(rect.y)
        if x > -80 && x < 1280 && y > -80 && y < 720
          {
            x: x,
            y: y,
            w: vw(rect.w || state.tile_size),
            h: vh(rect.h || state.tile_size),
            path: 'sprites/square-gray.png',
            a: 128
          }
        end
      end
    end

    render_player
    outputs.sprites << [vx(2315), vy(45), vw(569), vh(402), 'sprites/square-blue.png', 0, 40]

    # Label in top left of the screen
    outputs.primitives << [20, 640, 180, 70, 255, 255, 255, 128].solid
    outputs.primitives << [30, 700, "Stuff: #{state.stuff_score} of #{$mugs.count}", 1].label
    outputs.primitives << [30, 670, "Time: #{"%.2f" % state.stuff_time}", 1].label

    if state.god_mode
      if state.map_saved_at > 0 && state.map_saved_at.elapsed_time < 120
        outputs.primitives << [920, 670, 'Map has been exported!', 1, 0, 50, 100, 50].label
      end


      # Creates sprite following mouse to help indicate which sprite you have selected
      outputs.primitives << [inputs.mouse.position.x - 32 * state.camera_scale,
                             inputs.mouse.position.y - 32 * state.camera_scale,
                             state.tile_size * state.camera_scale,
                             state.tile_size * state.camera_scale, 'sprites/square-indigo.png', 0, 100].sprite
    end

    render_mini_map
    outputs.primitives << [0, 0, 1280, 720, 255, 255, 255, 255 * state.game_start_at.ease(60, :flip)].solid
  end

  def render_mini_map
    x, y = 1170, 10
    outputs.primitives << [x, y, 100, 58, 0, 0, 0, 200].solid
    outputs.primitives << [x + args.state.x.fdiv(100) - 1, y + args.state.y.fdiv(100) - 1, 2, 2, 0, 255, 0].solid
    t_start = start_of_tongue
    t_end = end_of_tongue
    outputs.primitives << [
      x + t_start.x.fdiv(100), y + t_start.y.fdiv(100),
      x + t_end.x.fdiv(100), y + t_end.y.fdiv(100),
      255, 255, 255
    ].line

    state.objects.each do |o|
      outputs.primitives << [x + o.x.fdiv(100) - 1, y + o.y.fdiv(100) - 1, 2, 2, 200, 200, 0].solid
    end
  end

  def calc_camera percentage_override = nil
    percentage = percentage_override || (0.2 * state.camera_scale)
    target_scale = state.target_camera_scale
    distance_scale = target_scale - state.camera_scale
    state.camera_scale += distance_scale * percentage

    target_x = state.x * state.target_camera_scale
    target_y = state.y * state.target_camera_scale

    distance_x = target_x - (state.camera_x + 640)
    distance_y = target_y - (state.camera_y + 360)
    state.camera_x += distance_x * percentage if distance_x.abs > 1
    state.camera_y += distance_y * percentage if distance_y.abs > 1
    state.camera_x = 0 if state.camera_x < 0
    state.camera_y = 0 if state.camera_y < 0
  end

  def vx x
     (x * state.camera_scale) - state.camera_x
  end

  def vy y
    (y * state.camera_scale) - state.camera_y
  end

  def vw w
    w * state.camera_scale
  end

  def vh h
    h * state.camera_scale
  end

  def calc
    calc_camera
    calc_world_lookup
    calc_player
    calc_on_floor
    calc_score
  end

  def set_camera_scale v = nil
    return if v < 0.1
    state.target_camera_scale = v
  end

  def process_inputs_god_mode
    return unless state.god_mode

    if inputs.keyboard.key_down.equal_sign || (inputs.keyboard.equal_sign && state.tick_count.mod_zero?(10))
      set_camera_scale state.camera_scale + 0.1
    elsif inputs.keyboard.key_down.hyphen || (inputs.keyboard.hyphen && state.tick_count.mod_zero?(10))
      set_camera_scale state.camera_scale - 0.1
    elsif inputs.keyboard.eight || inputs.keyboard.zero
      set_camera_scale 1
    end

    if inputs.mouse.click
      state.id_seed += 1
      id = state.id_seed
      x = state.camera_x + (inputs.mouse.click.x.fdiv(state.camera_scale) - 32)
      y = state.camera_y + (inputs.mouse.click.y.fdiv(state.camera_scale) - 32)
      x = ((x + 2).idiv 4) * 4
      y = ((y + 2).idiv 4) * 4
      w = 64
      h = 64
      candidate_rect = { id: id, x: x, y: y, w: w, h: h }
      scaled_candidate_rect = { x: x + 30, y: y + 30, w: w - 60, h: h - 60 }
      to_remove = state.world.find { |r| r.intersect_rect? scaled_candidate_rect }
      if to_remove && args.inputs.keyboard.x
        state.world.reject! { |r| r.id == to_remove.id }
      else
        state.world << candidate_rect
      end
      export_map
      state.world_lookup = {}
      state.world_collision_rects = nil
      calc_world_lookup
    end

    if input_up?
      state.y += 10
      state.dy = 0
    elsif input_down?
      state.y -= 10
      state.dy = 0
    end

    if input_left?
      state.x -= 10
      state.dx = 0
    elsif input_right?
      state.x += 10
      state.dx = 0
    end
  end

  def process_inputs
    if state.scene == :game
      process_inputs_player_movement
      process_inputs_god_mode
    end
  end

  def input_up?
    inputs.keyboard.w || inputs.keyboard.up || inputs.keyboard.k
  end

  def input_up_released?
    inputs.keyboard.key_up.w ||
    inputs.keyboard.key_up.up ||
    inputs.keyboard.key_up.k
  end

  def input_down?
    inputs.keyboard.s || inputs.keyboard.down || inputs.keyboard.j
  end

  def input_down_released?
    inputs.keyboard.key_up.s ||
    inputs.keyboard.key_up.down ||
    inputs.keyboard.key_up.j
  end

  def input_left?
    inputs.keyboard.a || inputs.keyboard.left || inputs.keyboard.h
  end

  def input_right?
    inputs.keyboard.d || inputs.keyboard.right || inputs.keyboard.l
  end

  def set_object path, w, h
    state.object = path
    state.object_w = w
    state.object_h = h
  end

  def collision_mode
    state.dev_action = :collision_mode
  end

  def process_inputs_player_movement
    if inputs.keyboard.key_down.g
      state.god_mode = !state.god_mode
      puts state.god_mode
    end

    if inputs.keyboard.key_down.u && state.dev_action == :collision_mode
      state.world = state.world[0..-2]
      state.world_lookup = {}
    end

    if inputs.keyboard.key_down.space && !state.anchor_point
      state.tongue_length = 0
      state.action = :shooting
      outputs.sounds << 'sounds/shooting.wav'
    elsif inputs.keyboard.key_down.space
      state.action = :aiming
      state.anchor_point  = nil
      state.tongue_length = 100
    end

    if state.anchor_point
      if input_up?
        if state.tongue_length >= 105
          state.tongue_length -= 5
          state.dy += 0.8
        end
      elsif input_down?
        state.tongue_length += 5
        state.dy -= 0.8
      end

      if input_left? && state.dx > 1
        state.dx *= 0.98
      elsif input_left? && state.dx < -1
        state.dx *= 1.03
      elsif input_left? && !state.on_floor
        state.dx -= 3
      elsif input_right? && state.dx > 1
        state.dx *= 1.03
      elsif input_right? && state.dx < -1
        state.dx *= 0.98
      elsif input_right? && !state.on_floor
        state.dx += 3
      end
    else
      if input_left?
        state.tongue_angle += 1.5
        state.tongue_angle = state.tongue_angle
      elsif input_right?
        state.tongue_angle -= 1.5
        state.tongue_angle = state.tongue_angle
      end
    end
  end

  def attempt_load_world_from_file
    return if state.world
    # exported_world = gtk.read_file(MAP_FILE_PATH)
    state.world = []
    state.objects = []

    if $collisions
      state.id_seed ||= 0
      $collisions.each do |x, y, w, h|
        state.id_seed += 1
        state.world << { id: state.id_seed, x: x, y: y, w: w, h: h }
      end
    end

    if $mugs
      $mugs.map do |x, y, w, h, path|
        state.objects << [x, y, w, h, path]
      end
    end
  end

  def calc_world_lookup
    if state.tile_size != state.previous_tile_size
      state.previous_tile_size = state.tile_size
      state.world_lookup = {}
    end

    return if state.world_lookup.keys.length > 0
    return unless state.world.length > 0

    # Searches through the world and finds the cordinates that exist
    state.world_lookup = {}
    state.world.each do |rect|
      state.world_lookup[rect.id] = rect
    end

    # Assigns collision rects for every sprite drawn
    state.world_collision_rects =
      state.world_lookup
           .keys
           .map do |key|
             rect = state.world_lookup[key]
             s = state.tile_size
             rect.w ||= s
             rect.h ||= s
             {
               args:       rect,
               left_right: { x: rect.x,     y: rect.y + 4, w: rect.w,     h: rect.h - 6 },
               top:        { x: rect.x + 4, y: rect.y + 6, w: rect.w - 8, h: rect.h - 6 },
               bottom:     { x: rect.x + 1, y: rect.y - 1, w: rect.w - 2, h: rect.h - 8 },
             }
           end

  end

  def calc_pendulum
    return if !state.anchor_point
    target_x = state.anchor_point.x - start_of_tongue.x
    target_y = state.anchor_point.y -
               state.tongue_length - 5 - 20 - state.player_height

    diff_y = state.y - target_y

    if target_x > 0
      state.dx += 0.6
    elsif target_x < 0
      state.dx -= 0.6
    end

    if diff_y > 0
      state.dy -= 0.1
    elsif diff_y < 0
      state.dy += 0.1
    end

    state.dx *= 0.99

    if state.dy.abs < 2
      state.dy *= 0.8
    else
      state.dy *= 0.90
    end

    if state.tongue_length && state.y
      state.dy += state.tongue_angle.vector_y state.tongue_length.fdiv(1000)
    end
  end

  def calc_tongue_angle
    return unless state.anchor_point
    state.tongue_angle = args.geometry.angle_from state.anchor_point, start_of_tongue
    state.tongue_length = args.geometry.distance(start_of_tongue, state.anchor_point)
    state.tongue_length = state.tongue_length.greater(100)
  end

  def player_from_end_of_tongue
    p = state.tongue_angle.vector(state.tongue_length)
    derived_start = [state.anchor_point.x - p.x, state.anchor_point.y - p.y]
    derived_start.x -= state.player_width.half
    derived_start.y -= state.player_height.half
    derived_start
  end

  def end_of_tongue
    p = state.tongue_angle.vector(state.tongue_length)
    { x: start_of_tongue.x + p.x, y: start_of_tongue.y + p.y }
  end

  def calc_shooting
    calc_shooting_increment
    calc_shooting_increment
    calc_shooting_increment
    calc_shooting_increment
    calc_shooting_increment
    calc_shooting_increment
  end

  def calc_shooting_increment
    return unless state.action == :shooting
    state.tongue_length += 5
    potential_anchor = end_of_tongue
    if potential_anchor.x <= 0
      state.anchor_point = potential_anchor
      state.action = :anchored
      outputs.sounds << 'sounds/attached.wav'
    elsif potential_anchor.x >= 10000
      state.anchor_point = potential_anchor
      state.action = :anchored
      outputs.sounds << 'sounds/attached.wav'
    elsif potential_anchor.y <= 0
      state.anchor_point = potential_anchor
      state.action = :anchored
      outputs.sounds << 'sounds/attached.wav'
    elsif potential_anchor.y >= 5875
      state.anchor_point = potential_anchor
      state.action = :anchored
      outputs.sounds << 'sounds/attached.wav'
    else
      anchor_rect = { x: potential_anchor.x - 5, y: potential_anchor.y - 5, w: 10, h: 10 }
      collision = state.world_collision_rects.find_all do |v|
        v[:args].intersect_rect?(anchor_rect)
      end.first
      if collision
        state.anchor_point = potential_anchor
        state.action = :anchored
      outputs.sounds << 'sounds/attached.wav'
      end
    end
  end

  def calc_player
    calc_shooting
    if !state.god_mode
      state.dy += state.gravity  # Since acceleration is the change in velocity, the change in y (dy) increases every frame
      state.dx += state.dx * state.air
    end
    calc_pendulum
    calc_box_collision
    calc_edge_collision
    if !state.god_mode
      state.y  += state.dy
      state.x  += state.dx
    end
    calc_tongue_angle
  end

  def calc_box_collision
    return unless state.world_lookup.keys.length > 0
    collision_floor
    collision_left
    collision_right
    collision_ceiling
  end

  def calc_edge_collision
    # Ensures that player doesn't fall below the map
    if next_y < 0 && state.dy < 0
      state.y = 0
      state.dy = state.dy.abs * 0.8
      state.collision_on_y = true
    # Ensures player doesn't go insanely high
    elsif next_y > 5875 - state.tile_size && state.dy > 0
      state.y = 5875 - state.tile_size
      state.dy = state.dy.abs * 0.8 * -1
      state.collision_on_y = true
    end

    # Ensures that player remains in the horizontal range its supposed to
    if state.x >= 10000 - state.tile_size && state.dx > 0
      state.x = 10000 - state.tile_size
      state.dx = state.dx.abs * 0.8 * -1
      state.collision_on_x = true
    elsif state.x <= 0 && state.dx < 0
      state.x = 0
      state.dx = state.dx.abs * 0.8
      state.collision_on_x = true
    end
  end

  def next_y
    state.y + state.dy
  end

  def next_x
    if state.dx < 0
      return (state.x + state.dx) - (state.tile_size - state.player_width)
    else
      return (state.x + state.dx) + (state.tile_size - state.player_width)
    end
  end

  def collision_floor
    return unless state.dy <= 0

    player_rect = [state.x, next_y, state.tile_size, state.tile_size]

    # Runs through all the sprites on the field and determines if the player hits the bottom of sprite (hence "-0.1" above)
    floor_collisions = state.world_collision_rects
                         .find_all { |r| r[:top].intersect_rect?(player_rect, state.collision_tolerance) }
                         .first

    return unless floor_collisions
    state.y = floor_collisions[:top].top
    state.dy = state.dy.abs * 0.8
  end

  def collision_left
    return unless state.dx < 0
    player_rect = [next_x, state.y, state.tile_size, state.tile_size]

    # Runs through all the sprites on the field and determines if the player hits the left side of sprite (hence "-0.1" above)
    left_side_collisions = state.world_collision_rects
                             .find_all { |r| r[:left_right].intersect_rect?(player_rect, state.collision_tolerance) }
                             .first

    return unless left_side_collisions
    state.x = left_side_collisions[:left_right].right + 1
    state.dx = state.dy.abs * 0.8
    state.collision_on_x = true
  end

  def collision_right
    return unless state.dx > 0

    player_rect = [next_x, state.y, state.tile_size, state.tile_size]
    # Runs through all the sprites on the field and determines if the player hits the right side of sprite (hence "-0.1" above)
    right_side_collisions = state.world_collision_rects
                              .find_all { |r| r[:left_right].intersect_rect?(player_rect, state.collision_tolerance) }
                              .first

    return unless right_side_collisions
    state.x = right_side_collisions[:left_right].left - state.tile_size - 1
    state.dx = state.dx.abs * 0.8 * -1
    state.collision_on_x = true
  end

  def collision_ceiling
    return unless state.dy > 0

    player_rect = [state.x, next_y, state.player_width, state.player_height]

    # Runs through all the sprites on the field and determines if the player hits the ceiling of sprite (hence "+0.1" above)
    ceil_collisions = state.world_collision_rects
                        .find_all { |r| r[:bottom].intersect_rect?(player_rect, state.collision_tolerance) }
                        .first

    return unless ceil_collisions
    state.y = ceil_collisions[:bottom].y - state.tile_size - 1
    state.dy = state.dy.abs * 0.8 * -1
    state.collision_on_y = true
  end

  def to_coord point
    # Integer divides (idiv) point.x to turn into grid
    # Then, you can just multiply each integer by state.tile_size
    # later and huzzah. Grid coordinates
    [point.x.idiv(state.tile_size), point.y.idiv(state.tile_size)]
  end

  def export_map
    export_string = "$collisions = [\n"
    export_string += state.world.map do |rect|
      "[#{rect.x},#{rect.y},#{rect.w},#{rect.h}],"
    end.join "\n"
    export_string += "\n]\n\n"
    export_string += "$mugs = [\n"
    export_string += state.objects.map do |x, y, w, h, path|
      "[#{x},#{y},#{w},#{h},'#{path}'],"
    end.join "\n"
    export_string += "\n]\n\n"
    gtk.write_file(MAP_FILE_PATH, export_string)
    state.map_saved_at = state.tick_count
  end

  def inputs_export_stage
  end

  def calc_score
    return unless state.scene == :game
    player = [state.x, state.y, state.player_width, state.player_height]
    collected = state.objects.find_all { |s| s.intersect_rect? player }
    state.stuff_score += collected.length
    if collected.length > 0
      outputs.sounds << 'sounds/collectable.wav'
    end
    state.objects = state.objects.reject { |s| collected.include? s }
    state.stuff_time += 0.01
    if state.objects.length == 0
      if !state.stuff_best_time || state.stuff_time < state.stuff_best_time
        state.stuff_best_time = state.stuff_time
      end
      state.game_over_at = nil
      state.scene = :ending
    end
  end

  def calc_on_floor
    if state.action == :anchored
      state.on_floor = false
      state.on_floor_debounce = 30
    else
      state.on_floor_debounce ||= 30

      if state.dy.round != 0
        state.on_floor_debounce = 30
        state.on_floor = false
      else
        state.on_floor_debounce -= 1
      end

      if state.on_floor_debounce <= 0
        state.on_floor_debounce = 0
        state.on_floor = true
      end
    end
  end

  def render_player
    path = "sprites/square-green.png"
    angle = 0
    # outputs.labels << [vx(state.x), vy(state.y) - 30, "dy: #{state.dy.round}"]
    if state.action == :idle
      # outputs.labels << [vx(state.x), vy(state.y), "IDLE"]
      path = "sprites/square-green.png"
    elsif state.action == :aiming && !state.on_floor
      # outputs.labels << [vx(state.x), vy(state.y), "AIMING AIR BORN"]
      angle = state.tongue_angle - 90
      path = "sprites/square-green.png"
    elsif state.action == :aiming # ON THE GROUND
      # outputs.labels << [vx(state.x), vy(state.y), "AIMING GROUND"]
      path = "sprites/square-green.png"
    elsif state.action == :shooting && !state.on_floor
      # outputs.labels << [vx(state.x), vy(state.y), "SHOOTING AIR BORN"]
      path = "sprites/square-green.png"
      angle = state.tongue_angle - 90
    elsif state.action == :shooting
      # outputs.labels << [vx(state.x), vy(state.y), "SHOOTING ON GROUND"]
      path = "sprites/square-green.png"
    elsif state.action == :anchored
      # outputs.labels << [vx(state.x), vy(state.y), "SWINGING"]
      angle = state.tongue_angle - 90
      path = "sprites/square-green.png"
    end

    outputs.sprites << [vx(state.x),
                        vy(state.y),
                        vw(state.player_width),
                        vh(state.player_height),
                        path,
                        angle]
  end

  def render_player_old
    # Player
    if state.action == :aiming
      path = 'sprites\frg\idle\frog_idle.png'
      if state.dx > 2
	  #directional right sprite was here but i needa redo it
        path = 'sprites\frg\anchor\frog-anchor-0.png'
      #directional left sprite was here but i needa redo it
	  elsif state.dx < -2
        path = 'sprites\frg\anchor\frog-anchor-0.png'
      end
      outputs.sprites << [vx(state.x),
                          vy(state.y),
                          vw(state.player_width),
                          vh(state.player_height),
                          path,
                          (state.tongue_angle - 90)]
    elsif state.action == :anchored || state.action == :shooting
      outputs.sprites << [vx(state.x),
                          vy(state.y),
                          vw(state.player_width),
                          vw(state.player_height),
                          'sprites/animations_povfrog/frog_bwah_up.png',
                          (state.tongue_angle - 90)]
    end
  end
end


$game = CleptoFrog.new

def tick args
  if args.state.scene == :game
    tick_instructions args, "SPACE to SHOOT and RELEASE tongue. LEFT, RIGHT to SWING and BUILD momentum. MINIMAP in bottom right corner.", 360
  end
  $game.args = args
  $game.tick
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.keyboard.directional_vector || args.inputs.keyboard.key_down.space
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(SPACE to dismiss instructions)" , -2, 1, 255, 255, 255].label
end
