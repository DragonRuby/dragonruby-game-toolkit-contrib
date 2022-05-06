class Game
  include MatrixFunctions

  attr_gtk

  def tick
    defaults
    render
    input
  end

  def player_ship
    [
      # engine back
      (vec4  -1,  -1,  1,  0),
      (vec4  -1,   1,  1,  0),

      (vec4  -1,   1,  1,  0),
      (vec4   1,   1,  1,  0),

      (vec4   1,   1,  1,  0),
      (vec4   1,  -1,  1,  0),

      (vec4   1,  -1,  1,  0),
      (vec4  -1,  -1,  1,  0),

      # engine front
      (vec4  -1,  -1,  -1,  0),
      (vec4  -1,   1,  -1,  0),

      (vec4  -1,   1,  -1,  0),
      (vec4   1,   1,  -1,  0),

      (vec4   1,   1,  -1,  0),
      (vec4   1,  -1,  -1,  0),

      (vec4   1,  -1,  -1,  0),
      (vec4  -1,  -1,  -1,  0),

      # engine left
      (vec4  -1,   -1,  -1,  0),
      (vec4  -1,   -1,   1,  0),

      (vec4  -1,   -1,   1,  0),
      (vec4  -1,    1,   1,  0),

      (vec4  -1,    1,   1,  0),
      (vec4  -1,    1,  -1,  0),

      (vec4  -1,    1,  -1,  0),
      (vec4  -1,   -1,  -1,  0),

      # engine right
      (vec4   1,   -1,  -1,  0),
      (vec4   1,   -1,   1,  0),

      (vec4   1,   -1,   1,  0),
      (vec4   1,    1,   1,  0),

      (vec4   1,    1,   1,  0),
      (vec4   1,    1,  -1,  0),

      (vec4   1,    1,  -1,  0),
      (vec4   1,   -1,  -1,  0),

      # top front of engine to front of ship
      (vec4   1,    1,  1,  0),
      (vec4   0,   -1,  9,  0),

      (vec4   0,   -1,  9,  0),
      (vec4  -1,    1,  1,  0),

      # bottom front of engine
      (vec4   1,   -1,  1,  0),
      (vec4   0,   -1,  9,  0),

      (vec4  -1,   -1,  1,  0),
      (vec4   0,   -1,  9,  0),

      # right wing
      # front of wing
      (vec4  1,  0.10,   1,  0),
      (vec4  9,  0.10,  -1,  0),

      (vec4   9,  0.10,  -1,  0),
      (vec4  10,  0.10,  -2,  0),

      # back of wing
      (vec4  1,  0.10,  -1,  0),
      (vec4  9,  0.10,  -1,  0),

      (vec4  10,  0.10,  -2,  0),
      (vec4   8,  0.10,  -1,  0),

      # front of wing
      (vec4  1,  -0.10,   1,  0),
      (vec4  9,  -0.10,  -1,  0),

      (vec4   9,  -0.10,  -1,  0),
      (vec4  10,  -0.10,  -2,  0),

      # back of wing
      (vec4  1,  -0.10,  -1,  0),
      (vec4  9,  -0.10,  -1,  0),

      (vec4  10,  -0.10,  -2,  0),
      (vec4   8,  -0.10,  -1,  0),

      # left wing
      # front of wing
      (vec4  -1,  0.10,   1,  0),
      (vec4  -9,  0.10,  -1,  0),

      (vec4  -9,  0.10,  -1,  0),
      (vec4  -10,  0.10,  -2,  0),

      # back of wing
      (vec4  -1,  0.10,  -1,  0),
      (vec4  -9,  0.10,  -1,  0),

      (vec4  -10,  0.10,  -2,  0),
      (vec4  -8,  0.10,  -1,  0),

      # front of wing
      (vec4  -1,  -0.10,   1,  0),
      (vec4  -9,  -0.10,  -1,  0),

      (vec4  -9,  -0.10,  -1,  0),
      (vec4  -10,  -0.10,  -2,  0),

      # back of wing
      (vec4  -1,  -0.10,  -1,  0),
      (vec4  -9,  -0.10,  -1,  0),
      (vec4  -10,  -0.10,  -2,  0),
      (vec4   -8,  -0.10,  -1,  0),

      # left fin
      # top
      (vec4  -1,  0.10,  1,  0),
      (vec4  -1,  3,  -3,  0),

      (vec4  -1,  0.10,  -1,  0),
      (vec4  -1,  3,  -3,  0),

      (vec4  -1.1,  0.10,  1,  0),
      (vec4  -1.1,  3,  -3,  0),

      (vec4  -1.1,  0.10,  -1,  0),
      (vec4  -1.1,  3,  -3,  0),

      # bottom
      (vec4  -1,  -0.10,  1,  0),
      (vec4  -1,  -2,  -2,  0),

      (vec4  -1,  -0.10,  -1,  0),
      (vec4  -1,  -2,  -2,  0),

      (vec4  -1.1,  -0.10,  1,  0),
      (vec4  -1.1,  -2,  -2,  0),

      (vec4  -1.1,  -0.10,  -1,  0),
      (vec4  -1.1,  -2,  -2,  0),

      # right fin
      (vec4   1,  0.10,  1,  0),
      (vec4   1,  3,  -3,  0),

      (vec4   1,  0.10,  -1,  0),
      (vec4   1,  3,  -3,  0),

      (vec4   1.1,  0.10,  1,  0),
      (vec4   1.1,  3,  -3,  0),

      (vec4   1.1,  0.10,  -1,  0),
      (vec4   1.1,  3,  -3,  0),

      # bottom
      (vec4   1,  -0.10,  1,  0),
      (vec4   1,  -2,  -2,  0),

      (vec4   1,  -0.10,  -1,  0),
      (vec4   1,  -2,  -2,  0),

      (vec4   1.1,  -0.10,  1,  0),
      (vec4   1.1,  -2,  -2,  0),

      (vec4   1.1,  -0.10,  -1,  0),
      (vec4   1.1,  -2,  -2,  0),
    ]
  end

  def defaults
    state.points ||= player_ship
    state.shifted_points ||= state.points.map { |point| point }

    state.scale   ||= 1
    state.angle_x ||= 0
    state.angle_y ||= 0
    state.angle_z ||= 0
  end

  def angle_z_matrix degrees
    cos_t = Math.cos degrees.to_radians
    sin_t = Math.sin degrees.to_radians
    (mat4 cos_t, -sin_t, 0, 0,
          sin_t,  cos_t, 0, 0,
          0,      0,     1, 0,
          0,      0,     0, 1)
  end

  def angle_y_matrix degrees
    cos_t = Math.cos degrees.to_radians
    sin_t = Math.sin degrees.to_radians
    (mat4  cos_t,  0, sin_t, 0,
           0,      1, 0,     0,
           -sin_t, 0, cos_t, 0,
           0,      0, 0,     1)
  end

  def angle_x_matrix degrees
    cos_t = Math.cos degrees.to_radians
    sin_t = Math.sin degrees.to_radians
    (mat4  1,     0,      0, 0,
           0, cos_t, -sin_t, 0,
           0, sin_t,  cos_t, 0,
           0,     0,      0, 1)
  end

  def scale_matrix factor
    (mat4 factor,      0,      0, 0,
          0,      factor,      0, 0,
          0,           0, factor, 0,
          0,           0,      0, 1)
  end

  def input
    if (inputs.keyboard.shift && inputs.keyboard.p)
      state.scale -= 0.1
    elsif  inputs.keyboard.p
      state.scale += 0.1
    end

    if inputs.mouse.wheel
      state.scale += inputs.mouse.wheel.y
    end

    state.scale = state.scale.clamp(0.1, 1000)

    if (inputs.keyboard.shift && inputs.keyboard.y) || inputs.keyboard.right
      state.angle_y += 1
    elsif (inputs.keyboard.y) || inputs.keyboard.left
      state.angle_y -= 1
    end

    if (inputs.keyboard.shift && inputs.keyboard.x) || inputs.keyboard.down
      state.angle_x -= 1
    elsif (inputs.keyboard.x || inputs.keyboard.up)
      state.angle_x += 1
    end

    if inputs.keyboard.shift && inputs.keyboard.z
      state.angle_z += 1
    elsif inputs.keyboard.z
      state.angle_z -= 1
    end

    if inputs.keyboard.zero
      state.angle_x = 0
      state.angle_y = 0
      state.angle_z = 0
    end

    angle_x = state.angle_x
    angle_y = state.angle_y
    angle_z = state.angle_z
    scale   = state.scale

    s_matrix = scale_matrix state.scale
    x_matrix = angle_z_matrix angle_z
    y_matrix = angle_y_matrix angle_y
    z_matrix = angle_x_matrix angle_x

    state.shifted_points = state.points.map do |point|
      (mul point, y_matrix, x_matrix, z_matrix, s_matrix).merge(original: point)
    end
  end

  def thick_line line
    [
      line.merge(y: line.y - 1, y2: line.y2 - 1, r: 0, g: 0, b: 0),
      line.merge(x: line.x - 1, x2: line.x2 - 1, r: 0, g: 0, b: 0),
      line.merge(x: line.x - 0, x2: line.x2 - 0, r: 0, g: 0, b: 0),
      line.merge(y: line.y + 1, y2: line.y2 + 1, r: 0, g: 0, b: 0),
      line.merge(x: line.x + 1, x2: line.x2 + 1, r: 0, g: 0, b: 0)
    ]
  end

  def render
    outputs.lines << state.shifted_points.each_slice(2).map do |(p1, p2)|
      perc = 0
      thick_line({ x:  p1.x.*(10) + 640, y:  p1.y.*(10) + 320,
                   x2: p2.x.*(10) + 640, y2: p2.y.*(10) + 320,
                   r: 255 * perc,
                   g: 255 * perc,
                   b: 255 * perc })
    end

    outputs.labels << [ 10, 700, "angle_x: #{state.angle_x.to_sf}", 0]
    outputs.labels << [ 10, 670, "x, shift+x", 0]

    outputs.labels << [210, 700, "angle_y: #{state.angle_y.to_sf}", 0]
    outputs.labels << [210, 670, "y, shift+y", 0]

    outputs.labels << [410, 700, "angle_z: #{state.angle_z.to_sf}", 0]
    outputs.labels << [410, 670, "z, shift+z", 0]

    outputs.labels << [610, 700, "scale: #{state.scale.to_sf}", 0]
    outputs.labels << [610, 670, "p, shift+p", 0]
  end
end

$game = Game.new

def tick args
  $game.args = args
  $game.tick
end

def set_angles x, y, z
  $game.state.angle_x = x
  $game.state.angle_y = y
  $game.state.angle_z = z
end

$gtk.reset
