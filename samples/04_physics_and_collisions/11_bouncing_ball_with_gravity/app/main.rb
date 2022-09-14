include MatrixFunctions

class BouncingBall
  attr_gtk

  def tick
    defaults
    render
    input
    calc

    reset_ball if args.inputs.keyboard.key_down.r

    args.state.debug = !args.state.debug if inputs.keyboard.key_down.g
    debug if args.state.debug
  end

  def defaults
    args.state.rest ||= false
    args.state.debug ||= false

    state.walls ||= [
      { x: 50.from_left, y: 50.from_bottom, x2: 50.from_left, y2: 50.from_top },
      { x: 50.from_left, y: 50.from_bottom, x2: 50.from_right, y2: 50.from_bottom },
      { x: 50.from_left, y: 50.from_top, x2: 50.from_right, y2: 50.from_top },
      { x: 50.from_right, y: 50.from_bottom, x2: 50.from_right, y2: 50.from_top },
    ]

    state.ball ||= { x: 250, y: 250, w: 50, h: 50, path: 'circle-white.png' }
    state.ball_old_x ||= state.ball[:x]
    state.ball_old_y ||= state.ball[:y]
    state.ball_vector ||= vec2(0, 0)

    state.stick_length = 200
    state.stick_angle ||= 0
    state.stick_power ||= 0

    # Prevent consecutive bounces on the same normal vector
    # Solves issue where ball gets stuck on a wall
    state.prevent_collision ||= {}

    state.physics.gravity = 0.4
    state.physics.restitution = 0.80
    state.physics.friction = 0.70
  end

  def render
    outputs.lines << state.walls
    outputs.sprites << state.ball
    render_stick
    render_point_one
  end

  def render_stick
    stick_vec_x = Math.cos(state.stick_angle.to_radians)
    stick_vec_y = Math.sin(state.stick_angle.to_radians)
    ball_center_x = state.ball[:x] + (state.ball[:w] / 2)
    ball_center_y = state.ball[:y] + (state.ball[:h] / 2)
    # Draws the line starting 15% of stick_length away from the ball
    outputs.lines << {
      x: ball_center_x + (stick_vec_x * state.stick_length * -0.15),
      y: ball_center_y + (stick_vec_y * state.stick_length * -0.15),
      w: stick_vec_x * state.stick_length * -1,
      h: stick_vec_y * state.stick_length * -1,
    }
  end

  def render_point_one
    return unless state.point_one

    outputs.lines << { x: state.point_one.x, y: state.point_one.y,
                       x2: inputs.mouse.x, y2: inputs.mouse.y,
                       r: 255 }
  end

  def input
    input_stick
    input_lines
    state.point_one = nil if inputs.keyboard.key_down.escape
  end

  def input_stick
    if inputs.keyboard.key_up.space
      hit_ball
      state.stick_power = 0
    end

    if inputs.keyboard.key_held.space
      state.stick_power += 1 unless state.stick_power >= 50
      outputs.labels << [100, 100, state.stick_power]
    end

    state.stick_angle += inputs.keyboard.left_right
  end

  def input_lines
    return unless inputs.mouse.click

    if state.point_one
      x = snap(state.point_one.x)
      y = snap(state.point_one.y)
      x2 = snap(inputs.mouse.click.x)
      y2 = snap(inputs.mouse.click.y)
      state.walls << { x: x, y: y, x2: x2, y2: y2 }
      state.point_one = nil
    else
      state.point_one = inputs.mouse.click.point
    end
  end

  # FIX: does not snap negative numbers properly
  def snap value
    snap_number = 10
    min = value.to_i.idiv(snap_number) * snap_number
    max = min + snap_number
    result = (max - value).abs < (min - value).abs ? max : min
    puts "SNAP: #{ value } --> #{ result }" if state.debug
    result
  end

  def hit_ball
    vec_x = Math.cos(state.stick_angle.to_radians) * state.stick_power
    vec_y = Math.sin(state.stick_angle.to_radians) * state.stick_power
    state.ball_vector = vec2(vec_x, vec_y)
    state.rest = false
  end

  def entropy
    state.ball_vector[:x].abs + state.ball_vector[:y].abs
  end

  # Ball is resting if
  # entropy is low, ball is touching a line
  # the line is not steep and the ball is above the line
  def ball_is_resting?(walls, true_normal)
    entropy < 1.5 && !walls.empty? && true_normal[:y] > 0.96
  end

  def calc
    walls = []
    state.walls.each do |wall|
      if line_intersect_rect?(wall, state.ball)
        walls << wall unless state.prevent_collision.key?(wall)
      end
    end

    state.prevent_collision = {}
    walls.each { |w| state.prevent_collision[w] = true }

    normals = walls.map { |w| compute_proper_normal(w) }
    true_normal = normals.inject { |a, b| normalize(vector_add(a, b)) }

    unless state.rest
      state.ball_vector = collision(true_normal) unless walls.empty?
      state.ball_old_x = state.ball[:x]
      state.ball_old_y = state.ball[:y]
      state.ball[:x] += state.ball_vector[:x]
      state.ball[:y] += state.ball_vector[:y]
      state.ball_vector[:y] -= state.physics.gravity

      if ball_is_resting?(walls, true_normal)
        state.ball[:y] += 1
        state.rest = true
      end
    end
  end

  # Line segment intersects rect if it intersects
  # any of the lines that make up the rect
  # This doesn't cover the case where the line is completely within the rect
  def line_intersect_rect?(line, rect)
    rect_to_lines(rect).each do |rect_line|
      return true if segments_intersect?(line, rect_line)
    end

    false
  end

  # https://stackoverflow.com/questions/573084/
  def collision(normal_vector)
    dot_product = dot(state.ball_vector, normal_vector)
    normal_square = dot(normal_vector, normal_vector)
    perpendicular = vector_multiply(normal_vector, (dot_product / normal_square))
    parallel = vector_minus(state.ball_vector, perpendicular)
    perpendicular = vector_multiply(perpendicular, state.physics.restitution)
    parallel = vector_multiply(parallel, state.physics.friction)
    vector_minus(parallel, perpendicular)
  end

  # https://stackoverflow.com/questions/1243614/
  def compute_normals(line)
    h = line[:y2] - line[:y]
    w = line[:x2] - line[:x]
    a = normalize vec2(-h, w)
    b = normalize vec2(h, -w)
    [a, b]
  end

  # https://stackoverflow.com/questions/3838319/
  # Get the normal vector that points at the ball from the center of the line
  def compute_proper_normal(line)
    normals = compute_normals(line)
    ball_center_x = state.ball_old_x + (state.ball[:w] / 2)
    ball_center_y = state.ball_old_y + (state.ball[:h] / 2)
    v1 = vec2(line[:x2] - line[:x], line[:y2] - line[:y])
    v2 = vec2(line[:x2] - ball_center_x, line[:y2] - ball_center_y)
    cp = v1[:x] * v2[:y] - v1[:y] * v2[:x]
    cp < 0 ? normals[0] : normals[1]
  end

  def vector_multiply(vector, value)
    vec2(vector[:x] * value, vector[:y] * value)
  end

  def vector_minus(vec_a, vec_b)
    vec2(vec_a[:x] - vec_b[:x], vec_a[:y] - vec_b[:y])
  end

  def vector_add a, b
    vec2(a[:x] + b[:x], a[:y] + b[:y])
  end

  # The lines composing the boundaries of a rectangle
  def rect_to_lines(rect)
    x = rect[:x]
    y = rect[:y]
    x2 = rect[:x] + rect[:w]
    y2 = rect[:y] + rect[:h]
    [{ x: x, y: y, x2: x2, y2: y },
     { x: x, y: y, x2: x, y2: y2 },
     { x: x2, y: y, x2: x2, y2: y2 },
     { x: x, y: y2, x2: x2, y2: y2 }]
  end

  # This is different from args.geometry.line_intersect
  # This considers line segments instead of lines
  # http://jeffreythompson.org/collision-detection/line-line.php
  def segments_intersect?(line_one, line_two)
    x1 = line_one[:x]
    y1 = line_one[:y]
    x2 = line_one[:x2]
    y2 = line_one[:y2]

    x3 = line_two[:x]
    y3 = line_two[:y]
    x4 = line_two[:x2]
    y4 = line_two[:y2]

    uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
    uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))

    uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1
  end

  def reset_ball
    state.ball = nil
    state.ball_vector = nil
    state.rest = false
  end

  def debug
    outputs.labels << { x: 50.from_left, y: 50.from_top, text: "Entropy: #{entropy}"}
  end
end


def tick args
  $game ||= BouncingBall.new
  $game.args = args
  $game.tick
end
