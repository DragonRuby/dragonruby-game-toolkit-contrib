# Sample app demonstrates how to use Hooke's Law and Columb's Law
# to render things to the screen without things overlapping
def boot args
  args.state = {}
end

def tick args
  args.state.center_screen ||= { x: 640, y: 360 }
  args.state.particles ||= 10.map do
    { x: Numeric.rand(500..800),
      y: Numeric.rand(200..400),
      w: 16,
      h: 16,
      dx: Numeric.rand(-1.0..1.0),
      dy: Numeric.rand(-1.0..1.0),
      r: 128 * rand,
      g: 128 * rand,
      b: 128 * rand,
      path: :solid }
  end

  if args.inputs.mouse.click
    args.state.particles.push_back({ x: args.inputs.mouse.x - 8,
                                     y: args.inputs.mouse.y - 8,
                                     w: 16,
                                     h: 16,
                                     dx: Numeric.rand(-1.0..1.0),
                                     dy: Numeric.rand(-1.0..1.0),
                                     r: 128 * rand,
                                     g: 128 * rand,
                                     b: 128 * rand,
                                     path: :solid })
  end


  args.state.particles.each do |p1|
    hookes_law! p1, args.state.center_screen
    args.state.particles.each do |p2|
      next if p1 == p2
      coulombs_law! p1, p2
    end
  end

  args.state.particles.each do |p1|
    p1.dx = p1.dx.clamp(-2.5, 2.5)
    p1.dy = p1.dy.clamp(-2.5, 2.5)
    p1.x += p1.dx
    p1.y += p1.dy
    collide_edge! p1
  end

  collisions = false

  Geometry.each_intersect_rect(args.state.particles, args.state.particles) do |p1, p2|
    collisions = true
  end

  if !collisions
    args.state.particles.each do |p1|
      p1.dx *= 0.95
      p1.dy *= 0.95
    end
  end

  args.outputs.sprites << args.state.particles
  args.outputs.labels << { x: 640,
                           y: 360,
                           text: "Click to add particles",
                           anchor_x: 0.5,
                           anchor_y: 0.5 }
end

def hookes_law! p1, p2
  dx = p2.x - p1.x
  dy = p2.y - p1.y
  distance = Math.sqrt(dx * dx + dy * dy)
  force = (distance - 100) / 100.0 * 0.01

  if distance > 0
    p1.dx += (dx / distance) * force
    p1.dy += (dy / distance) * force
  end
end

def coulombs_law! p1, p2
  dx = p2.x - p1.x
  dy = p2.y - p1.y
  distance = Math.sqrt(dx * dx + dy * dy)
  return if distance < 1
  force = 20 / (distance * distance)

  dx_force = (dx / distance) * force
  dy_force = (dy / distance) * force

  p1.dx -= dx_force
  p1.dy -= dy_force
  p2.dx += dx_force
  p2.dy += dy_force
end

def collide_edge! p1
  if p1.x < 0
    p1.x = 0
    p1.dx *= -1
  elsif p1.x > 1280 - p1.w
    p1.x = 1280 - p1.w
    p1.dx *= -1
  end

  if p1.y < 0
    p1.y = 0
    p1.dy *= -1
  elsif p1.y > 720 - p1.h
    p1.y = 720 - p1.h
    p1.dy *= -1
  end
end
