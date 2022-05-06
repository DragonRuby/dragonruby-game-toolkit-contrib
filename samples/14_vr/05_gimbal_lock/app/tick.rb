class Game
  attr_gtk

  def tick
    grid.origin_center!
    state.angle_x ||= 0
    state.angle_y ||= 0
    state.angle_z ||= 0

    if inputs.left
      state.angle_z += 1
    elsif inputs.right
      state.angle_z -= 1
    end

    if inputs.up
      state.angle_x += 1
    elsif inputs.down
      state.angle_x -= 1
    end

    if inputs.controller_one.a
      state.angle_y += 1
    elsif inputs.controller_one.b
      state.angle_y -= 1
    end

    outputs.sprites << {
      x: 0,
      y: 0,
      w: 100,
      h: 100,
      path: 'sprites/square/blue.png',
      angle_x: state.angle_x,
      angle_y: state.angle_y,
      angle: state.angle_z,
    }
  end
end
