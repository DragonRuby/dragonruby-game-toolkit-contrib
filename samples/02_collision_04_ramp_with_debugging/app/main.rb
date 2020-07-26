class FallingCircle
  attr_gtk

  def fiddle
    state.gravity = -0.8
    state.terrain = [
      [0, 300, 600, 20]
    ]
  end

  def defaults
    state.circle.x   ||= 30
    state.circle.y   ||= 700
    state.circle.dy  ||= 0
  end

  def circle_center
    [state.circle.x, state.circle.y]
  end

  def circle_points center
    max_points = 10
    max_points.map_with_index do |i|
      p = 360.fdiv(max_points)
      center.rect_shift((i * p).vector(25)).point
    end
  end

  def point_sprite point
    [point.rect_shift(-1, -1).point, 2, 2, 'sprites/circle-red.png']
  end

  def render
    args.outputs.sprites << [state.circle.x - 25,
                             state.circle.y - 25,
                             50,
                             50,
                             'sprites/circle-gray.png']
    args.outputs.lines << state.terrain
    args.outputs.sprites << point_sprite(circle_center)
    args.outputs.sprites << circle_points(circle_center).map do |p|
      point_sprite(p)
    end
  end

  def m line
    (line.y2 - line.y).fdiv(line.x2 - line.x)
  end

  def b line
    # b = y - mx
    line.y - m(line) * line.x
  end

  def point_on_line line, x
    # y = mx+b
    # m = y2 - y1 / x2 - x1
    m(line) * x + b(line)
  end

  def calc
    point_distances = circle_points(circle_center.point).map do |c|
      y = point_on_line(state.terrain[0], c.x)
      rect_one = [c.x - 5, c.y - 5 + state.circle.dy + state.gravity, 10, state.circle.dy.abs]
      rect_two = [c.x, y - 55, 10, 50]
      intersect = rect_one.intersect_rect?(rect_two)
      if intersect
        # debug collision
        outputs.borders << [rect_one, 255, 0, 0]
        outputs.borders << [rect_two, 255, 0, 0]
      else
        # debug collision
        outputs.borders << rect_one
        outputs.borders << rect_two
      end

      {
        c: c,
        point_on_line: y,
        distance_y: rect_two.y - rect_one.y,
        rect_one: rect_one,
        rect_two: rect_two,
        intersect: intersect
      }
    end

    if !state.circle.on_floor
      close = point_distances.find_all { |p| p[:intersect] }.first
      if close
        state.circle.on_floor = true
        state.circle.dy += state.gravity
        delta =  close[:distance_y] - state.circle.dy
        state.circle.y += delta
        state.circle.dy = 0
      end
    end

    if !state.circle.on_floor
      state.circle.dy += state.gravity
      state.circle.y += state.circle.dy
    end

    if state.circle.y < -100
      state.circle.y = 800
      state.circle.dy = 0
    end
  end

  def tick
    fiddle
    defaults
    render
    calc
  end
end

$falling_circle = FallingCircle.new

def tick args
  # uncomment the line below to slow down the game so you
  # can see each tick as it passes
  # args.gtk.slowmo! 30
  $falling_circle.args = args
  $falling_circle.tick
  tick_instructions args, "Sample app shows how to do collisions for a ramp."
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end

$gtk.reset
