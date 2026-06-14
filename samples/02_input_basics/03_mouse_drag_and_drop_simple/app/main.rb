module Main
  def start
    state.square_1 = {
      x: 320 - 50,
      y: 360 - 50,
      w: 100,
      h: 100,
      path: :solid,
      r: 128, g: 128, b: 128
    }

    state.square_2 = {
      x: 960 - 50,
      y: 360 - 50,
      w: 100,
      h: 100,
      path: :solid,
      r: 128, g: 128, b: 128
    }
  end

  def tick
    if Geometry.intersect_rect?(inputs.mouse, state.square_1) && inputs.mouse.left && inputs.mouse.moved
      state.square_1.x += inputs.mouse.x - inputs.mouse.previous_x
      state.square_1.y += inputs.mouse.y - inputs.mouse.previous_y
    end

    if Geometry.intersect_rect?(inputs.mouse, state.square_2) && inputs.mouse.left && inputs.mouse.moved
      state.square_2.x += inputs.mouse.relative_x
      state.square_2.y += inputs.mouse.relative_y
    end

    outputs.background_color = [30, 30, 30]
    outputs.primitives << state.square_1
    outputs.primitives << state.square_2
  end
end
