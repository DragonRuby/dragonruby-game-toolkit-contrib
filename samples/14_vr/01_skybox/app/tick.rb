def skybox args, x, y, z, size
  sprite = { a: 80, path: 'sprites/box.png' }

  front      = { x: x, y: y, z: z, w: size, h: size, **sprite }
  front_720  = { x: x, y: y, z: z + 1, w: size, h: size * 9.fdiv(16), **sprite }
  back       = { x: x, y: y, z: z + size, w: size, h: size, **sprite }
  bottom     = { x: x, y: y - size.half, z: z + size.half, w: size, h: size, angle_x: 90, **sprite }
  top        = { x: x, y: y + size.half, z: z + size.half, w: size, h: size, angle_x: 90, **sprite }
  left       = { x: x - size.half, y: y, w: size, h: size, z: z + size.half, angle_y: 90, **sprite }
  right      = { x: x + size.half, y: y, w: size, h: size, z: z + size.half, angle_y: 90, **sprite }

  args.outputs.sprites << [back,
                           left,
                           top,
                           bottom,
                           right,
                           front,
                           front_720]
end

def tick_game args
  args.outputs.background_color = [0, 0, 0]

  args.state.z     ||= 0
  args.state.scale ||= 0.05

  if args.inputs.controller_one.key_down.a
    if args.grid.name == :bottom_left
      args.grid.origin_center!
    else
      args.grid.origin_bottom_left!
    end
  end

  args.state.scale += args.inputs.controller_one.right_analog_x_perc * 0.01
  args.state.z -= args.inputs.controller_one.right_analog_y_perc * 1.5

  args.state.scale = args.state.scale.clamp(0.05, 1.0)
  args.state.z = 0    if args.state.z < 0
  args.state.z = 1280 if args.state.z > 1280

  skybox args, 0, 0, args.state.z, 1280 * args.state.scale

  render_guides args
end

def render_guides args
  label_style = { alignment_enum: 1,
                  size_enum: -2,
                  vertical_alignment_enum: 0, r: 255, g: 255, b: 255 }

  instructions = [
    "controller position: #{args.inputs.controller_one.left_hand.x} #{args.inputs.controller_one.left_hand.y} #{args.inputs.controller_one.left_hand.z}",
    "scale: #{args.state.scale.to_sf} (right analog left/right)",
    "z: #{args.state.z.to_sf} (right analog up/down)",
    "origin: :#{args.grid.name} (A button)",
  ]

  args.outputs.labels << instructions.map_with_index do |text, i|
    { x: 640,
      y: 100 + ((instructions.length - (i + 3)) * 22),
      z: args.state.z + 2,
      a: 255,
      text: text,
      ** label_style,
      alignment_enum: 1,
      vertical_alignment_enum: 0 }
  end

  # lines for scaled box
  size      = 1280 * args.state.scale
  size_16_9 = size * 9.fdiv(16)

  args.outputs.primitives << [
    { x: size - 1280, y: size,        z:            0, w: 1280 * 2, r: 128, g: 128, b: 128, a:  64 }.line!,
    { x: size - 1280, y: size,        z: args.state.z + 2, w: 1280 * 2, r: 128, g: 128, b: 128, a: 255 }.line!,

    { x: size - 1280, y: size_16_9,   z:            0, w: 1280 * 2, r: 128, g: 128, b: 128, a:  64 }.line!,
    { x: size - 1280, y: size_16_9,   z: args.state.z + 2, w: 1280 * 2, r: 128, g: 128, b: 128, a: 255 }.line!,

    { x: size,        y: size - 1280, z:            0, h: 1280 * 2, r: 128, g: 128, b: 128, a:  64 }.line!,
    { x: size,        y: size - 1280, z: args.state.z + 2, h: 1280 * 2, r: 128, g: 128, b: 128, a: 255 }.line!,

    { x: size,        y: size,        z: args.state.z + 3, size_enum: -2,
      vertical_alignment_enum: 0,
      text: "#{size.to_sf}, #{size.to_sf}, #{args.state.z.to_sf}",
      r: 255, g: 255, b: 255, a: 255 }.label!,

    { x: size,        y: size_16_9,   z: args.state.z + 3, size_enum: -2,
      vertical_alignment_enum: 0,
      text: "#{size.to_sf}, #{size_16_9.to_sf}, #{args.state.z.to_sf}",
      r: 255, g: 255, b: 255, a: 255 }.label!,
  ]

  xs = [
    { description: "left",   x:    0, alignment_enum: 0 },
    { description: "center", x:  640, alignment_enum: 1 },
    { description: "right",  x: 1280, alignment_enum: 2 },
  ]

  ys = [
    { description: "bottom",        y:    0, vertical_alignment_enum: 0 },
    { description: "center",        y:  640, vertical_alignment_enum: 1 },
    { description: "center (720p)", y:  360, vertical_alignment_enum: 1 },
    { description: "top",           y: 1280, vertical_alignment_enum: 2 },
    { description: "top (720p)",    y:  720, vertical_alignment_enum: 2 },
  ]

  args.outputs.primitives << xs.product(ys).map do |(xdef, ydef)|
    [
      { x: xdef.x,
        y: ydef.y,
        z: args.state.z + 3,
        text: "#{xdef.x.to_sf}, #{ydef.y.to_sf} #{args.state.z.to_sf}",
        **label_style,
        alignment_enum: xdef.alignment_enum,
        vertical_alignment_enum: ydef.vertical_alignment_enum
      },
      { x: xdef.x,
        y: ydef.y - 20,
        z: args.state.z + 3,
        text: "#{ydef.description}, #{xdef.description}",
        **label_style,
        alignment_enum: xdef.alignment_enum,
        vertical_alignment_enum: ydef.vertical_alignment_enum
      }
    ]
  end

  args.outputs.primitives << xs.product(ys).map do |(xdef, ydef)|
    [
      {
        x: xdef.x - 1280,
        y: ydef.y,
        w: 1280 * 2,
        a: 64,
        r: 128, g: 128, b: 128
      }.line!,
      {
        x: xdef.x,
        y: ydef.y - 720,
        h: 720 * 2,
        a: 64,
        r: 128, g: 128, b: 128
      }.line!,
    ].map do |p|
      [
        p.merge(z:            0, a:  64),
        p.merge(z: args.state.z + 2, a: 255)
      ]
    end
  end
end

GTK.reset
