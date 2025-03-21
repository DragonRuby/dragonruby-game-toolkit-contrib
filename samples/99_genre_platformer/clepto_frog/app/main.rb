class CleptoFrog
  attr_gtk

  def tick
    defaults
    render
    input
    calc
  end

  def defaults
    state.level_editor_rect_w ||= 32
    state.level_editor_rect_h     ||= 32
    state.target_camera_scale ||= 0.5
    state.camera_scale        ||= 1
    state.tongue_length       ||= 100
    state.action              ||= :aiming
    state.tongue_angle        ||= 90
    state.tile_size           ||= 32
    state.gravity             ||= -0.1
    state.drag                ||= -0.005
    state.player ||= {
      x: 2400,
      y: 200,
      w: 60,
      h: 60,
      dx: 0,
      dy: 0,
    }
    state.camera_x     ||= state.player.x - 640
    state.camera_y     ||= 0
    load_if_needed
    state.map_saved_at ||= 0
  end

  def player
    state.player
  end

  def render
    render_world
    render_player
    render_level_editor
    render_mini_map
    render_instructions
  end

  def to_camera_space rect
    rect.merge(x: to_camera_space_x(rect.x),
               y: to_camera_space_y(rect.y),
               w: to_camera_space_w(rect.w),
               h: to_camera_space_h(rect.h))
  end

  def to_camera_space_x x
    return nil if !x
     (x * state.camera_scale) - state.camera_x
  end

  def to_camera_space_y y
    return nil if !y
    (y * state.camera_scale) - state.camera_y
  end

  def to_camera_space_w w
    return nil if !w
    w * state.camera_scale
  end

  def to_camera_space_h h
    return nil if !h
    h * state.camera_scale
  end

  def render_world
    viewport = {
      x: player.x - 1280 / state.camera_scale,
      y: player.y - 720 / state.camera_scale,
      w: 2560 / state.camera_scale,
      h: 1440 / state.camera_scale
    }

    outputs.sprites << Geometry.find_all_intersect_rect(viewport, state.mugs).map do |rect|
      to_camera_space rect
    end

    outputs.sprites << Geometry.find_all_intersect_rect(viewport, state.walls).map do |rect|
      to_camera_space(rect).merge!(path: :pixel, r: 128, g: 128, b: 128, a: 128)
    end
  end

  def render_player
    start_of_tongue_render = to_camera_space start_of_tongue

    if state.anchor_point
      anchor_point_render = to_camera_space state.anchor_point
      outputs.sprites << { x: start_of_tongue_render.x - 2,
                           y: start_of_tongue_render.y - 2,
                           w: to_camera_space_w(4),
                           h: Geometry.distance(start_of_tongue_render, anchor_point_render),
                           path:  :pixel,
                           angle_anchor_y: 0,
                           r: 255, g: 128, b: 128,
                           angle: state.tongue_angle - 90 }
    else
      outputs.sprites << { x: to_camera_space_x(start_of_tongue.x) - 2,
                           y: to_camera_space_y(start_of_tongue.y) - 2,
                           w: to_camera_space_w(4),
                           h: to_camera_space_h(state.tongue_length),
                           path:  :pixel,
                           r: 255, g: 128, b: 128,
                           angle_anchor_y: 0,
                           angle: state.tongue_angle - 90 }
    end

    angle = 0
    if state.action == :aiming && !player.on_floor
      angle = state.tongue_angle - 90
    elsif state.action == :shooting && !player.on_floor
      angle = state.tongue_angle - 90
    elsif state.action == :anchored
      angle = state.tongue_angle - 90
    end

    outputs.sprites << to_camera_space(player).merge!(path: "sprites/square/green.png", angle: angle)
  end

  def render_mini_map
    x, y = 1170, 10
    outputs.primitives << { x: x,
                            y: y,
                            w: 100,
                            h: 58,
                            r: 0,
                            g: 0,
                            b: 0,
                            a: 200,
                            path: :pixel }

    outputs.primitives << { x: x + player.x.fdiv(100) - 1,
                            y: y + player.y.fdiv(100) - 1,
                            w: 2,
                            h: 2,
                            r: 0,
                            g: 255,
                            b: 0,
                            path: :pixel }

    t_start = start_of_tongue
    t_end = end_of_tongue

    outputs.primitives << {
      x: x + t_start.x.fdiv(100),
      y: y + t_start.y.fdiv(100),
      x2: x + t_end.x.fdiv(100),
      y2: y + t_end.y.fdiv(100),
      r: 255, g: 255, b: 255
    }

    outputs.primitives << state.mugs.map do |o|
      { x: x + o.x.fdiv(100) - 1,
        y: y + o.y.fdiv(100) - 1,
        w: 2,
        h: 2,
        r: 200,
        g: 200,
        b: 0,
        path: :pixel }
    end
  end

  def render_level_editor
    return if !state.level_editor_mode
    if state.map_saved_at > 0 && state.map_saved_at.elapsed_time < 120
      outputs.primitives << { x: 920, y: 670, text: 'Map has been exported!', size_enum: 1, r: 0, g: 50, b: 100, a: 50 }
    end

    outputs.primitives << { x: to_camera_space_x(((state.camera_x + inputs.mouse.x) / state.camera_scale).ifloor(state.tile_size)),
                            y: to_camera_space_y(((state.camera_y + inputs.mouse.y) / state.camera_scale).ifloor(state.tile_size)),
                            w: to_camera_space_w(state.level_editor_rect_w),
                            h: to_camera_space_h(state.level_editor_rect_h), path: :pixel, a: 200, r: 180, g: 80, b: 200 }
  end

  def render_instructions
    if state.level_editor_mode
      outputs.labels << { x: 640,
                          y: 10.from_top,
                          text: "Click to place wall. HJKL to change wall size. X + click to remove wall. M + click to place mug. Arrow keys to move around.",
                          size_enum: -1,
                          anchor_x: 0.5 }
      outputs.labels << { x: 640,
                          y: 35.from_top,
                          text: " - and + to zoom in and out. 0 to reset camera to default zoom. G to exit level editor mode.",
                          size_enum: -1,
                          anchor_x: 0.5 }
    else
      outputs.labels << { x: 640,
                          y: 10.from_top,
                          text: "Left and Right to aim tongue. Space to shoot or release tongue. G to enter level editor mode.",
                          size_enum: -1,
                          anchor_x: 0.5 }

      outputs.labels << { x: 640,
                          y: 35.from_top,
                          text: "Up and Down to change tongue length (when tongue is attached). Left and Right to swing (when tongue is attached).",
                          size_enum: -1,
                          anchor_x: 0.5 }
    end
  end

  def start_of_tongue
    {
      x: player.x + player.w / 2,
      y: player.y + player.h / 2
    }
  end

  def calc
    calc_camera
    calc_player
    calc_mug_collection
  end

  def calc_camera
    percentage = 0.2 * state.camera_scale
    target_scale = state.target_camera_scale
    distance_scale = target_scale - state.camera_scale
    state.camera_scale += distance_scale * percentage

    target_x = player.x * state.target_camera_scale
    target_y = player.y * state.target_camera_scale

    distance_x = target_x - (state.camera_x + 640)
    distance_y = target_y - (state.camera_y + 360)
    state.camera_x += distance_x * percentage if distance_x.abs > 1
    state.camera_y += distance_y * percentage if distance_y.abs > 1
    state.camera_x = 0 if state.camera_x < 0
    state.camera_y = 0 if state.camera_y < 0
  end

  def calc_player
    calc_shooting
    calc_swing
    calc_aabb_collision
    calc_tongue_angle
    calc_on_floor
  end

  def calc_shooting
    calc_shooting_step
    calc_shooting_step
    calc_shooting_step
    calc_shooting_step
    calc_shooting_step
    calc_shooting_step
  end

  def calc_shooting_step
    return unless state.action == :shooting
    state.tongue_length += 5
    potential_anchor = end_of_tongue
    anchor_rect = { x: potential_anchor.x - 5, y: potential_anchor.y - 5, w: 10, h: 10 }
    collision = state.walls.find_all do |v|
      v.intersect_rect?(anchor_rect)
    end.first
    if collision
      state.anchor_point = potential_anchor
      state.action = :anchored
    end
  end

  def calc_swing
    return if !state.anchor_point
    target_x = state.anchor_point.x - start_of_tongue.x
    target_y = state.anchor_point.y -
               state.tongue_length - 5 - 20 - player.h

    diff_y = player.y - target_y

    distance = Geometry.distance(player, state.anchor_point)
    pull_strength = if distance < 100
                      0
                    else
                      (distance / 800)
                    end

    vector = state.tongue_angle.to_vector

    player.dx += vector.x * pull_strength**2
    player.dy += vector.y * pull_strength**2
  end

  def calc_aabb_collision
    return if !state.walls

    player.dx = player.dx.clamp(-30, 30)
    player.dy = player.dy.clamp(-30, 30)

    player.dx += player.dx * state.drag
    player.x += player.dx

    collision = Geometry.find_intersect_rect player, state.walls

    if collision
      if player.dx > 0
        player.x = collision.x - player.w
      elsif player.dx < 0
        player.x = collision.x + collision.w
      end
      player.dx *= -0.8
    end

    if !state.level_editor_mode
      player.dy += state.gravity  # Since acceleration is the change in velocity, the change in y (dy) increases every frame
      player.y += player.dy
    end

    collision = Geometry.find_intersect_rect player, state.walls

    if collision
      if player.dy > 0
        player.y = collision.y - 60
      elsif player.dy < 0
        player.y = collision.y + collision.h
      end

      player.dy *= -0.8
    end
  end

  def calc_tongue_angle
    return unless state.anchor_point
    state.tongue_angle = Geometry.angle_from state.anchor_point, start_of_tongue
    state.tongue_length = Geometry.distance(start_of_tongue, state.anchor_point)
    state.tongue_length = state.tongue_length.greater(100)
  end

  def calc_on_floor
    if state.action == :anchored
      player.on_floor = false
      player.on_floor_debounce = 30
    else
      player.on_floor_debounce ||= 30

      if player.dy.round != 0
        player.on_floor_debounce = 30
        player.on_floor = false
      else
        player.on_floor_debounce -= 1
      end

      if player.on_floor_debounce <= 0
        player.on_floor_debounce = 0
        player.on_floor = true
      end
    end
  end

  def calc_mug_collection
    collected = state.mugs.find_all { |s| s.intersect_rect? player }
    state.mugs.reject! { |s| collected.include? s }
  end

  def set_camera_scale v = nil
    return if v < 0.1
    state.target_camera_scale = v
  end

  def input
    input_game
    input_level_editor
  end

  def input_up?
    inputs.keyboard.w || inputs.keyboard.up
  end

  def input_down?
    inputs.keyboard.s || inputs.keyboard.down
  end

  def input_left?
    inputs.keyboard.a || inputs.keyboard.left
  end

  def input_right?
    inputs.keyboard.d || inputs.keyboard.right
  end

  def input_game
    if inputs.keyboard.key_down.g
      state.level_editor_mode = !state.level_editor_mode
    end

    if player.on_floor
      if inputs.keyboard.q
        player.dx = -5
      elsif inputs.keyboard.e
        player.dx = 5
      end
    end

    if inputs.keyboard.key_down.space && !state.anchor_point
      state.tongue_length = 0
      state.action = :shooting
    elsif inputs.keyboard.key_down.space
      state.action = :aiming
      state.anchor_point  = nil
      state.tongue_length = 100
    end

    if state.anchor_point
      vector = state.tongue_angle.to_vector

      if input_up?
        state.tongue_length -= 5
        player.dy += vector.y
        player.dx += vector.x
      elsif input_down?
        state.tongue_length += 5
        player.dy -= vector.y
        player.dx -= vector.x
      end

      if input_left?
        player.dx -= 0.5
      elsif input_right?
        player.dx += 0.5
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

  def input_level_editor
    return unless state.level_editor_mode

    if Kernel.tick_count.mod_zero?(5)
      # zoom
      if inputs.keyboard.equal_sign || inputs.keyboard.plus
        set_camera_scale state.camera_scale + 0.1
      elsif inputs.keyboard.hyphen
        set_camera_scale state.camera_scale - 0.1
      elsif inputs.keyboard.zero
        set_camera_scale 0.5
      end

      # change wall width
      if inputs.keyboard.h
        state.level_editor_rect_w -= state.tile_size
      elsif inputs.keyboard.l
        state.level_editor_rect_w += state.tile_size
      end

      state.level_editor_rect_w = state.tile_size if state.level_editor_rect_w < state.tile_size

      # change wall height
      if inputs.keyboard.j
        state.level_editor_rect_h -= state.tile_size
      elsif inputs.keyboard.k
        state.level_editor_rect_h += state.tile_size
      end

      state.level_editor_rect_h = state.tile_size if state.level_editor_rect_h < state.tile_size
    end

    if inputs.mouse.click
      x = ((state.camera_x + inputs.mouse.x) / state.camera_scale).ifloor(state.tile_size)
      y = ((state.camera_y + inputs.mouse.y) / state.camera_scale).ifloor(state.tile_size)
      # place mug
      if inputs.keyboard.m
        w = 32
        h = 32
        candidate_rect = { x: x, y: y, w: w, h: h }
        if inputs.keyboard.x
          mouse_rect = { x: (state.camera_x + inputs.mouse.x) / state.camera_scale,
                         y: (state.camera_y + inputs.mouse.y) / state.camera_scale,
                         w: 10,
                         h: 10 }
          to_remove = state.mugs.find do |r|
            r.intersect_rect? mouse_rect
          end
          if to_remove
            state.mugs.reject! { |r| r == to_remove }
          end
        else
          exists = state.mugs.find { |r| r == candidate_rect }
          if !exists
            state.mugs << candidate_rect.merge(path: "sprites/square/orange.png")
          end
        end
      else
        # place wall
        w = state.level_editor_rect_w
        h = state.level_editor_rect_h
        candidate_rect = { x: x, y: y, w: w, h: h }
        if inputs.keyboard.x
          mouse_rect = { x: (state.camera_x + inputs.mouse.x) / state.camera_scale,
                         y: (state.camera_y + inputs.mouse.y) / state.camera_scale,
                         w: 10,
                         h: 10 }
          to_remove = state.walls.find do |r|
            r.intersect_rect? mouse_rect
          end
          if to_remove
            state.walls.reject! { |r| r == to_remove }
          end
        else
          exists = state.walls.find { |r| r == candidate_rect }
          if !exists
            state.walls << candidate_rect
          end
        end
      end

      save
    end

    if input_up?
      player.y += 10
      player.dy = 0
    elsif input_down?
      player.y -= 10
      player.dy = 0
    end

    if input_left?
      player.x -= 10
      player.dx = 0
    elsif input_right?
      player.x += 10
      player.dx = 0
    end
  end

  def end_of_tongue
    p = state.tongue_angle.to_vector
    { x: start_of_tongue.x + p.x * state.tongue_length,
      y: start_of_tongue.y + p.y * state.tongue_length }
  end

  def save
    GTK.write_file("data/mugs.txt", "")
    state.mugs.each do |o|
      GTK.append_file "data/mugs.txt", "#{o.x},#{o.y},#{o.w},#{o.h}\n"
    end

    GTK.write_file("data/walls.txt", "")
    state.walls.map do |o|
      GTK.append_file "data/walls.txt", "#{o.x},#{o.y},#{o.w},#{o.h}\n"
    end
  end

  def load_if_needed
    return if state.walls
    state.walls = []
    state.mugs = []

    contents = GTK.read_file "data/mugs.txt"
    if contents
      contents.each_line do |l|
        x, y, w, h = l.split(',').map(&:to_i)
        state.mugs << { x: x.ifloor(state.tile_size),
                        y: y.ifloor(state.tile_size),
                        w: w,
                        h: h,
                        path: "sprites/square/orange.png" }
      end
    end

    contents = GTK.read_file "data/walls.txt"
    if contents
      contents.each_line do |l|
        x, y, w, h = l.split(',').map(&:to_i)
        state.walls << { x: x.ifloor(state.tile_size),
                         y: y.ifloor(state.tile_size),
                         w: w,
                         h: h,
                         path: :pixel,
                         r: 128,
                         g: 128,
                         b: 128,
                         a: 128 }
      end
    end
  end
end

$game = CleptoFrog.new

def tick args
  $game.args = args
  $game.tick
end

# GTK.reset
