# Focused tutorial video: https://s3.amazonaws.com/s3.dragonruby.org/dragonruby-nddnug-workshop.mp4
# Workshop/Presentation which provides motivation for creating a game engine: https://www.youtube.com/watch?v=S3CFce1arC8

def defaults args
  args.outputs.background_color = [0, 0, 0]
  args.state.x ||= 640
  args.state.y ||= 360
  args.state.stars ||= 100.map do
    [1280 * rand, 720 * rand, rand.fdiv(10), 255 * rand, 255 * rand, 255 * rand]
  end

  args.state.sun ||= args.state.new_entity(:sun) do |s|
    s.s = 100
    s.path = 'sprites/sun.png'
  end

  args.state.planets = [
    [:mercury,   65,  5,          88],
    [:venus,    100, 10,         225],
    [:earth,    120, 10,         365],
    [:mars,     140,  8,         687],
    [:jupiter,  280, 30, 365 *  11.8],
    [:saturn,   350, 20, 365 *  29.5],
    [:uranus,   400, 15, 365 *    84],
    [:neptune,  440, 15, 365 * 164.8],
    [:pluto,    480,  5, 365 * 247.8],
  ].map do |name, distance, size, year_in_days|
    args.state.new_entity(name) do |p|
      p.path = "sprites/#{name}.png"
      p.distance = distance * 0.7
      p.s = size * 0.7
      p.year_in_days = year_in_days
    end
  end

  args.state.ship ||= args.state.new_entity(:ship) do |s|
    s.x = 1280 * rand
    s.y = 720 * rand
    s.angle = 0
  end
end

def to_sprite args, entity
  x = 0
  y = 0

  if entity.year_in_days
    day = args.state.tick_count
    day_in_year = day % entity.year_in_days
    entity.random_start_day ||= day_in_year * rand
    percentage_of_year = day_in_year.fdiv(entity.year_in_days)
    angle = 365 * percentage_of_year
    x = angle.vector_x(entity.distance)
    y = angle.vector_y(entity.distance)
  end

  [640 + x - entity.s.half, 360 + y - entity.s.half, entity.s, entity.s, entity.path]
end

def render args
  args.outputs.solids << [0, 0, 1280, 720]

  args.outputs.sprites << args.state.stars.map do |x, y, _, r, g, b|
    [x, y, 10, 10, 'sprites/star.png', 0, 100, r, g, b]
  end

  args.outputs.sprites << to_sprite(args, args.state.sun)
  args.outputs.sprites << args.state.planets.map { |p| to_sprite args, p }
  args.outputs.sprites << [args.state.ship.x, args.state.ship.y, 20, 20, 'sprites/ship.png', args.state.ship.angle]
end

def calc args
  args.state.stars = args.state.stars.map do |x, y, speed, r, g, b|
    x += speed
    y += speed
    x = 0 if x > 1280
    y = 0 if y > 720
    [x, y, speed, r, g, b]
  end

  if args.state.tick_count == 0
    args.outputs.sounds << 'sounds/bg.ogg'
  end
end

def process_inputs args
  if args.inputs.keyboard.left || args.inputs.controller_one.key_held.left
    args.state.ship.angle += 1
  elsif args.inputs.keyboard.right || args.inputs.controller_one.key_held.right
    args.state.ship.angle -= 1
  end

  if args.inputs.keyboard.up || args.inputs.controller_one.key_held.a
    args.state.ship.x += args.state.ship.angle.x_vector
    args.state.ship.y += args.state.ship.angle.y_vector
  end
end

def tick args
  defaults args
  render args
  calc args
  process_inputs args
end

def r
  $gtk.reset
end
