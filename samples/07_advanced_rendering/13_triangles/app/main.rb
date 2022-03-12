def tick args
  args.outputs.labels << {
    x: 640,
    y: 30.from_top,
    text: "Triangle rendering is available in Indie and Pro versions (ignored in Standard Edition).",
    alignment_enum: 1
  }

  dragonruby_logo_width  = 128
  dragonruby_logo_height = 101

  row_1 = 400
  row_2 = 250

  args.outputs.solids << make_triangle(
    640 - dragonruby_logo_width.half - dragonruby_logo_width,
    row_1,
    640 - dragonruby_logo_width,
    row_1 + 101,
    640 + dragonruby_logo_width.half - dragonruby_logo_width,
    row_1,
    0, 128, 128,
    128
  )

  args.outputs.solids << {
    x:  640 - dragonruby_logo_width.half,
    y:  row_1,
    x2: 640,
    y2: row_1 + dragonruby_logo_height,
    x3: 640 + dragonruby_logo_width.half,
    y3: row_1,
  }

  args.outputs.sprites << {
    x:  640 - dragonruby_logo_width.half + dragonruby_logo_width,
    y:  row_1,
    x2: 640 + dragonruby_logo_width,
    y2: row_1 + 101,
    x3: 640 + dragonruby_logo_width.half + dragonruby_logo_width,
    y3: row_1,
    path: 'dragonruby.png',
    source_x:  0,
    source_y:  0,
    source_x2: dragonruby_logo_width.half,
    source_y2: dragonruby_logo_height,
    source_x3: dragonruby_logo_width,
    source_y3: 0
  }

  args.outputs.primitives << make_triangle(
    640 - dragonruby_logo_width.half - dragonruby_logo_width,
    row_2,
    640 - dragonruby_logo_width,
    row_2 + 101,
    640 + dragonruby_logo_width.half - dragonruby_logo_width,
    row_2,
    0, 128, 128,
    args.state.tick_count.to_radians.sin_r.abs * 255
  )

  args.outputs.primitives << {
    x:  640 - dragonruby_logo_width.half,
    y:  row_2,
    x2: 640,
    y2: row_2 + dragonruby_logo_height,
    x3: 640 + dragonruby_logo_width.half,
    y3: row_2,
    r:  255
  }

  args.outputs.primitives << {
    x:  640 - dragonruby_logo_width.half + dragonruby_logo_width,
    y:  row_2,
    x2: 640 + dragonruby_logo_width,
    y2: row_2 + 101,
    x3: 640 + dragonruby_logo_width.half + dragonruby_logo_width,
    y3: row_2,
    path: 'dragonruby.png',
    source_x:  0,
    source_y:  0,
    source_x2: dragonruby_logo_width.half,
    source_y2: dragonruby_logo_height.half +
               dragonruby_logo_height.half * Math.sin(args.state.tick_count.to_radians).abs,
    source_x3: dragonruby_logo_width,
    source_y3: 0
  }
end

def make_triangle *opts
  x, y, x2, y2, x3, y3, r, g, b, a = opts
  {
    x: x, y: y, x2: x2, y2: y2, x3: x3, y3: y3,
    r: r || 0,
    g: g || 0,
    b: b || 0,
    a: a || 255
  }
end
