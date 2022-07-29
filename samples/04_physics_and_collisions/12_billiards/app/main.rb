# Demonstrates collision against arbitrary lines using vector math.
# Use arrow keys to move stick. Press space to add power, release to hit ball.

include MatrixFunctions

class BilliardsLite
  attr_gtk

  def tick
    defaults
    render
    input
    calc

    reset_ball if inputs.keyboard.key_down.r
  end

  def defaults
    state.walls ||= []

    state.ball ||= { x: 250, y: 250, w: 50, h: 50, path: 'circle-white.png' }
    state.ball_speed ||= 0
    state.ball_vector ||= vec2(0, 0)

    state.stick_length = 200
    state.stick_angle ||= 0
    state.stick_power ||= 0

    # Prevent consecutive bounces on the same normal vector
    # Solves issue where ball gets stuck on a wall
    state.prevent_collision ||= nil
    state.collision_occurred_this_tick = false
  end

  def render
    outputs.lines << state.walls
    outputs.sprites << state.ball
    render_stick
    render_point_one
  end

  def render_stick
    return if ball_moving?

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
    input_click if inputs.mouse.click
    state.point_one = nil if inputs.keyboard.key_down.escape
  end

  def input_stick
    return if ball_moving?

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

  def input_walls
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
    puts "SNAP: #{ value } --> #{ result }"
    result
  end

  def hit_ball
    state.ball_speed = state.stick_power
    stick_vec_x = Math.cos(state.stick_angle.to_radians)
    stick_vec_y = Math.sin(state.stick_angle.to_radians)
    state.ball_vector = vec2(stick_vec_x, stick_vec_y)
  end

  def calc
    state.ball[:x] += state.ball_speed * state.ball_vector[:x]
    state.ball[:y] += state.ball_speed * state.ball_vector[:y]
    state.ball_speed *= 0.97

    calc_collisions
  end

  def calc_collisions
    state.walls.each do |wall|
      if line_intersect_rect?(wall, state.ball)
        collision(compute_normal_vector(wall))
      end
    end

    state.prevent_collision = nil unless state.collision_occurred_this_tick
  end

  # Line segment intersects rect if it intersects
  # any of the lines that make up the rect
  # This doesn't cover the case where the line is completely within the rect
  def line_intersect_rect?(line, rect)
    rect_to_lines(rect).each do |rect_line|
      return true if line_intersect_line?(line, rect_line)
    end

    false
  end

  # https://stackoverflow.com/questions/573084/
  def collision(normal_vector)
    return if state.prevent_collision == normal_vector
    state.prevent_collision = normal_vector

    dot = dot(normal_vector, state.ball_vector)
    # Because normal vector is always normalized
    # There is no need to divide by normal vector * normal vector
    perpendicular = vector_multiply(normal_vector, dot)
    # ball vector = perpendicular component + parallel component
    # so, parallel = ball vector - perpendicular
    parallel = vector_minus(state.ball_vector, perpendicular)
    # To bounce off a surface, invert the perpendicular component of the vector
    state.ball_vector = vector_minus(parallel, perpendicular)

    state.collision_occurred_this_tick = true
  end

  # The normal vector is the negative reciprocal of the parallel vector
  # Similar to slopes in that manner
  def compute_normal_vector(line)
    h = line[:y2] - line[:y]
    w = line[:x2] - line[:x]
    normalize vec2(-h, w)
  end

  def vector_multiply(vector, value)
    vec2(vector[:x] * value, vector[:y] * value)
  end

  def vector_minus(vec_a, vec_b)
    vec2(vec_a[:x] - vec_b[:x], vec_a[:y] - vec_b[:y])
  end

  def ball_moving?
    state.ball_speed > 0.1
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
  # Source: http://jeffreythompson.org/collision-detection/line-line.php
  def line_intersect_line?(line_one, line_two)
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
    state.ball_speed = nil
  end
end


def tick args
  $game ||= BilliardsLite.new
  $game.args = args
  $game.tick
end
