
def m line
  (line.y2 - line.y).fdiv(line.x2 - line.x)
end

def b line
  # b = y - mx
  line.y - m(line) * line.x
end

def f_y line, x
  # y = mx+b
  # m = y2 - y1 / x2 - x1
  m(line) * x + b(line)
end

def f_x line, y
  # y = mx+b
  # x = (y - b) / m
  (y - b(line)) / m(line)
end

def tragectory body
  [body.x, body.y, body.x + body.dx * 1000, body.y + body.dy * 1000]
end

def intersect line_one, line_two
  m1 = m(line_one)
  b1 = b(line_one)
  m2 = m(line_two)
  b2 = b(line_two)

  x = (b1 - b2) / (m2 - m1)
  y = (-b2.fdiv(m2) + b1.fdiv(m1)).fdiv(1.fdiv(m1) - 1.fdiv(m2))
  [x, y]
end

def point_orientation point, other
  # if point.x < other.x
  #   return -1
  # else
    return  1
  # end
end

def tick args
  args.state.circle.radius = 50
  args.state.circle.x  ||= 10
  args.state.circle.y  ||= 500
  args.state.circle.dx ||=  15
  args.state.circle.dy ||=  -0.2
  args.state.terrain = [700, 0, 2000, 800]

  args.outputs.sprites << [
    args.state.circle.x - args.state.circle.radius.half,
    args.state.circle.y - args.state.circle.radius.half,
    args.state.circle.radius,
    args.state.circle.radius,
    'sprites/circle-gray.png'
  ]

  args.outputs.lines << args.state.line_one if args.state.line_one
  args.outputs.lines << args.state.line_two if args.state.line_two

  if args.state.point
    args.outputs.borders << [args.state.point.x - 5, args.state.point.y - 5, 10, 10]
    args.outputs.borders << [args.state.point.x - 4, args.state.point.y - 4,  8,  8]
  end

  args.state.circle.x  += args.state.circle.dx
  args.state.circle.y  += args.state.circle.dy
  args.state.circle.dy -= 0.2

  args.state.line_one = tragectory(args.state.circle)
  args.state.line_two = args.state.terrain
  args.state.point = intersect args.state.line_one, args.state.line_two
  args.state.current_orientation ||= point_orientation(args.state.circle, args.state.point)
  next_orientation = point_orientation(args.state.circle, args.state.point)
  if(args.state.current_orientation != next_orientation)
    args.state.circle.dx = 0
    args.state.circle.dy = 0
  end

  tick_instructions args, "Sample app shows how to calculate the point of collision on a line."
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
