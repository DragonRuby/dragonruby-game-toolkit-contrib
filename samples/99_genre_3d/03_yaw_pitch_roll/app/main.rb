class Game
  attr_gtk

  def tick
    defaults
    render
    input
  end

  def matrix_mul m, v
    (hmap x: ((m.x.x * v.x) + (m.x.y * v.y) + (m.x.z * v.z) + (m.x.w * v.w)),
          y: ((m.y.x * v.x) + (m.y.y * v.y) + (m.y.z * v.z) + (m.y.w * v.w)),
          z: ((m.z.x * v.x) + (m.z.y * v.y) + (m.z.z * v.z) + (m.z.w * v.w)),
          w: ((m.w.x * v.x) + (m.w.y * v.y) + (m.w.z * v.z) + (m.w.w * v.w)))
  end

  def player_ship
    [
      # engine back
      { x: -1, y: -1, z: 1, w: 0 },
      { x: -1, y:  1, z: 1, w: 0 },

      { x: -1, y:  1, z: 1, w: 0 },
      { x:  1, y:  1, z: 1, w: 0 },

      { x:  1, y:  1, z: 1, w: 0 },
      { x:  1, y: -1, z: 1, w: 0 },

      { x:  1, y: -1, z: 1, w: 0 },
      { x: -1, y: -1, z: 1, w: 0 },

      # engine front
      { x: -1, y: -1, z: -1, w: 0 },
      { x: -1, y:  1, z: -1, w: 0 },

      { x: -1, y:  1, z: -1, w: 0 },
      { x:  1, y:  1, z: -1, w: 0 },

      { x:  1, y:  1, z: -1, w: 0 },
      { x:  1, y: -1, z: -1, w: 0 },

      { x:  1, y: -1, z: -1, w: 0 },
      { x: -1, y: -1, z: -1, w: 0 },

      # engine left
      { x: -1, z:  -1, y: -1, w: 0 },
      { x: -1, z:  -1, y:  1, w: 0 },

      { x: -1, z:  -1, y:  1, w: 0 },
      { x: -1, z:   1, y:  1, w: 0 },

      { x: -1, z:   1, y:  1, w: 0 },
      { x: -1, z:   1, y: -1, w: 0 },

      { x: -1, z:   1, y: -1, w: 0 },
      { x: -1, z:  -1, y: -1, w: 0 },

      # engine right
      { x:  1, z:  -1, y: -1, w: 0 },
      { x:  1, z:  -1, y:  1, w: 0 },

      { x:  1, z:  -1, y:  1, w: 0 },
      { x:  1, z:   1, y:  1, w: 0 },

      { x:  1, z:   1, y:  1, w: 0 },
      { x:  1, z:   1, y: -1, w: 0 },

      { x:  1, z:   1, y: -1, w: 0 },
      { x:  1, z:  -1, y: -1, w: 0 },

      # top front of engine to front of ship
      { x:  1, y:   1, z: 1, w: 0 },
      { x:  0, y:  -1, z: 9, w: 0 },

      { x:  0, y:  -1, z: 9, w: 0 },
      { x: -1, y:   1, z: 1, w: 0 },

      # bottom front of engine
      { x:  1, y:  -1, z: 1, w: 0 },
      { x:  0, y:  -1, z: 9, w: 0 },

      { x: -1, y:  -1, z: 1, w: 0 },
      { x:  0, y:  -1, z: 9, w: 0 },

      # right wing
      # front of wing
      { x: 1, y: 0.10, z:  1, w: 0 },
      { x: 9, y: 0.10, z: -1, w: 0 },

      { x:  9, y: 0.10, z: -1, w: 0 },
      { x: 10, y: 0.10, z: -2, w: 0 },

      # back of wing
      { x: 1, y: 0.10, z: -1, w: 0 },
      { x: 9, y: 0.10, z: -1, w: 0 },

      { x: 10, y: 0.10, z: -2, w: 0 },
      { x:  8, y: 0.10, z: -1, w: 0 },

      # front of wing
      { x: 1, y: -0.10, z:  1, w: 0 },
      { x: 9, y: -0.10, z: -1, w: 0 },

      { x:  9, y: -0.10, z: -1, w: 0 },
      { x: 10, y: -0.10, z: -2, w: 0 },

      # back of wing
      { x: 1, y: -0.10, z: -1, w: 0 },
      { x: 9, y: -0.10, z: -1, w: 0 },

      { x: 10, y: -0.10, z: -2, w: 0 },
      { x:  8, y: -0.10, z: -1, w: 0 },

      # left wing
      # front of wing
      { x: -1, y: 0.10, z:  1, w: 0 },
      { x: -9, y: 0.10, z: -1, w: 0 },

      { x: -9, y: 0.10, z: -1, w: 0 },
      { x: -10, y: 0.10, z: -2, w: 0 },

      # back of wing
      { x: -1, y: 0.10, z: -1, w: 0 },
      { x: -9, y: 0.10, z: -1, w: 0 },

      { x: -10, y: 0.10, z: -2, w: 0 },
      { x: -8, y: 0.10, z: -1, w: 0 },

      # front of wing
      { x: -1, y: -0.10, z:  1, w: 0 },
      { x: -9, y: -0.10, z: -1, w: 0 },

      { x: -9, y: -0.10, z: -1, w: 0 },
      { x: -10, y: -0.10, z: -2, w: 0 },

      # back of wing
      { x: -1, y: -0.10, z: -1, w: 0 },
      { x: -9, y: -0.10, z: -1, w: 0 },

      { x: -10, y: -0.10, z: -2, w: 0 },
      { x: -8, y: -0.10, z: -1, w: 0 },

      # left fin
      # top
      { x: -1, y: 0.10, z: 1, w: 0 },
      { x: -1, y: 3, z: -3, w: 0 },

      { x: -1, y: 0.10, z: -1, w: 0 },
      { x: -1, y: 3, z: -3, w: 0 },

      { x: -1.1, y: 0.10, z: 1, w: 0 },
      { x: -1.1, y: 3, z: -3, w: 0 },

      { x: -1.1, y: 0.10, z: -1, w: 0 },
      { x: -1.1, y: 3, z: -3, w: 0 },

      # bottom
      { x: -1, y: -0.10, z: 1, w: 0 },
      { x: -1, y: -2, z: -2, w: 0 },

      { x: -1, y: -0.10, z: -1, w: 0 },
      { x: -1, y: -2, z: -2, w: 0 },

      { x: -1.1, y: -0.10, z: 1, w: 0 },
      { x: -1.1, y: -2, z: -2, w: 0 },

      { x: -1.1, y: -0.10, z: -1, w: 0 },
      { x: -1.1, y: -2, z: -2, w: 0 },

      # right fin
      { x:  1, y: 0.10, z: 1, w: 0 },
      { x:  1, y: 3, z: -3, w: 0 },

      { x:  1, y: 0.10, z: -1, w: 0 },
      { x:  1, y: 3, z: -3, w: 0 },

      { x:  1.1, y: 0.10, z: 1, w: 0 },
      { x:  1.1, y: 3, z: -3, w: 0 },

      { x:  1.1, y: 0.10, z: -1, w: 0 },
      { x:  1.1, y: 3, z: -3, w: 0 },

      # bottom
      { x:  1, y: -0.10, z: 1, w: 0 },
      { x:  1, y: -2, z: -2, w: 0 },

      { x:  1, y: -0.10, z: -1, w: 0 },
      { x:  1, y: -2, z: -2, w: 0 },

      { x:  1.1, y: -0.10, z: 1, w: 0 },
      { x:  1.1, y: -2, z: -2, w: 0 },

      { x:  1.1, y: -0.10, z: -1, w: 0 },
      { x:  1.1, y: -2, z: -2, w: 0 },
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

  def matrix_new x0, y0, z0, w0, x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3
    (hmap x: (hmap x: x0, y: y0, z: z0, w: w0),
          y: (hmap x: x1, y: y1, z: z1, w: w1),
          z: (hmap x: x2, y: y2, z: z2, w: w2),
          w: (hmap x: x3, y: y3, z: z3, w: w3))
  end

  def angle_z_matrix degrees
    cos_t = Math.cos degrees.to_radians
    sin_t = Math.sin degrees.to_radians
    (matrix_new cos_t, -sin_t, 0, 0,
                sin_t,  cos_t, 0, 0,
                0,      0,     1, 0,
                0,      0,     0, 1)
  end

  def angle_y_matrix degrees
    cos_t = Math.cos degrees.to_radians
    sin_t = Math.sin degrees.to_radians
    (matrix_new  cos_t,  0, sin_t, 0,
                 0,      1, 0,     0,
                 -sin_t, 0, cos_t, 0,
                 0,      0, 0,     1)
  end

  def angle_x_matrix degrees
    cos_t = Math.cos degrees.to_radians
    sin_t = Math.sin degrees.to_radians
    (matrix_new  1,     0,      0, 0,
                 0, cos_t, -sin_t, 0,
                 0, sin_t,  cos_t, 0,
                 0,     0,      0, 1)
  end

  def scale_matrix factor
    (matrix_new factor,      0,      0, 0,
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
      (matrix_mul s_matrix,
                  (matrix_mul z_matrix,
                              (matrix_mul x_matrix,
                                          (matrix_mul y_matrix, point)))).merge(original: point)
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
