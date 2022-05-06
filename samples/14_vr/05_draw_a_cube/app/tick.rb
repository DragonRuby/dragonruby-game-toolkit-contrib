def cube args, x, y, z, size
  sprite = { w: size, h: size, path: 'sprites/square/blue.png' }
  back   = { x: x,                 y: y,                 z: z - size.half + 1,              **sprite }
  front  = { x: x,                 y: y,                 z: z + size.half - 1,              **sprite }
  top    = { x: x,                 y: y + size.half - 1, z: z,                 angle_x: 90, **sprite }
  bottom = { x: x,                 y: y - size.half + 1, z: z,                 angle_x: 90, **sprite }
  left   = { x: x - size.half + 1, y: y,                 z: z,                 angle_y: 90, **sprite }
  right  = { x: x + size.half - 1, y: y,                 z: z,                 angle_y: 90, **sprite }

  # assumes cube is always in front of player
  # looking at cube straight on
  #    0         0
  if y == 0 && x == 0
    args.outputs.sprites << [back, left, top, bottom, right, front]
  end

  # looking at right side of cube, head on
  #    -         0
  if x < 0 && y == 0
    args.outputs.sprites << [back, left, top, bottom, right, front]
  end

  # looking at left side of the cube, head on
  #    +         0
  if x > 0 && y == 0
    args.outputs.sprites << [back, right, top, bottom, left, front]
  end

  # looking at top of the cube, head on
  #    0         -
  if x == 0 && y < 0
    args.outputs.sprites << [back, left, bottom, right, front, top]
  end

  # looking at bottom of the cube, head on
  #    0         +
  if x == 0 && y > 0
    args.outputs.sprites << [back, left, top, right, front, bottom]
  end

  # looking at right, and top of cube
  #    -        -
  if x < 0 && y < 0
    args.outputs.sprites << [back, left, bottom, right, top, front]
  end

  # looking at right, and bottom of cube
  #    -        +
  if x < 0 && y > 0
    args.outputs.sprites << [back, left, bottom, top, right, front]
  end

  # looking at left, and top of cube
  #    +        -
  if x > 0 && y < 0
    args.outputs.sprites << [back, right, bottom, left, top, front]
  end

  # looking at left, and bottom of cube
  #    +        +
  if x > 0 && y > 0
    args.outputs.sprites << [back, right, top, left, bottom, front]
  end
end

def tick_game args
  args.grid.origin_center!
  args.outputs.background_color = [0, 0, 0]

  args.state.x ||= 0
  args.state.y ||= 0

  args.state.x += 10 * args.inputs.controller_one.right_analog_x_perc
  args.state.y += 10 * args.inputs.controller_one.right_analog_y_perc * -1

  cube args, args.state.x, args.state.y, 0, 100
end

$gtk.reset
