def cube args, x, y, z, size
  sprite = { w: size, h: size, path: 'sprites/square/blue.png', a: 80 }
  back   = { x: x,                 y: y,                 z: z - size.half + 1,              **sprite }
  front  = { x: x,                 y: y,                 z: z + size.half - 1,              **sprite }
  top    = { x: x,                 y: y + size.half - 1, z: z,                 angle_x: 90, **sprite }
  bottom = { x: x,                 y: y - size.half + 1, z: z,                 angle_x: 90, **sprite }
  left   = { x: x - size.half + 1, y: y,                 z: z,                 angle_y: 90, **sprite }
  right  = { x: x + size.half - 1, y: y,                 z: z,                 angle_y: 90, **sprite }

  args.outputs.sprites << [back, left, top, bottom, right, front]
end

def tick_game args
  args.grid.origin_center!
  args.outputs.background_color = [0, 0, 0]

  args.state.x ||= 0
  args.state.y ||= 0

  args.state.x += 10 * args.inputs.controller_one.right_analog_x_perc
  args.state.y += 10 * args.inputs.controller_one.right_analog_y_perc

  cube args, args.state.x, args.state.y, 0, 100
end
