def tick args
  args.outputs.labels << {
    x: 640,
    y: 30.from_top,
    text: "Triangle rendering is available in Indie and Pro versions (ignored in Standard Edition).",
    alignment_enum: 1
  }

  dragonruby_logo_width  = 128
  dragonruby_logo_height = 101

  row_0 = 400
  row_1 = 250

  col_0 = 384 - dragonruby_logo_width.half + dragonruby_logo_width * 0
  col_1 = 384 - dragonruby_logo_width.half + dragonruby_logo_width * 1
  col_2 = 384 - dragonruby_logo_width.half + dragonruby_logo_width * 2
  col_3 = 384 - dragonruby_logo_width.half + dragonruby_logo_width * 3
  col_4 = 384 - dragonruby_logo_width.half + dragonruby_logo_width * 4

  # row 0
  args.outputs.solids << make_triangle(
    col_0,
    row_0,
    col_0 + dragonruby_logo_width.half,
    row_0 + dragonruby_logo_height,
    col_0 + dragonruby_logo_width.half + dragonruby_logo_width.half,
    row_0,
    0, 128, 128,
    128
  )

  args.outputs.solids << {
    x:  col_1,
    y:  row_0,
    x2: col_1 + dragonruby_logo_width.half,
    y2: row_0 + dragonruby_logo_height,
    x3: col_1 + dragonruby_logo_width,
    y3: row_0,
  }

  args.outputs.sprites << {
    x:  col_2,
    y:  row_0,
    w:  dragonruby_logo_width,
    h:  dragonruby_logo_height,
    path: 'dragonruby.png'
  }

  args.outputs.sprites << {
    x:  col_3,
    y:  row_0,
    x2: col_3 + dragonruby_logo_width.half,
    y2: row_0 + dragonruby_logo_height,
    x3: col_3 + dragonruby_logo_width,
    y3: row_0,
    path: 'dragonruby.png',
    source_x:  0,
    source_y:  0,
    source_x2: dragonruby_logo_width.half,
    source_y2: dragonruby_logo_height,
    source_x3: dragonruby_logo_width,
    source_y3: 0
  }

  args.outputs.sprites << TriangleLogo.new(x:  col_4,
                                           y:  row_0,
                                           x2: col_4 + dragonruby_logo_width.half,
                                           y2: row_0 + dragonruby_logo_height,
                                           x3: col_4 + dragonruby_logo_width,
                                           y3: row_0,
                                           path: 'dragonruby.png',
                                           source_x:  0,
                                           source_y:  0,
                                           source_x2: dragonruby_logo_width.half,
                                           source_y2: dragonruby_logo_height,
                                           source_x3: dragonruby_logo_width,
                                           source_y3: 0)

  # row 1
  args.outputs.primitives << make_triangle(
    col_0,
    row_1,
    col_0 + dragonruby_logo_width.half,
    row_1 + dragonruby_logo_height,
    col_0 + dragonruby_logo_width,
    row_1,
    0, 128, 128,
    args.state.tick_count.to_radians.sin_r.abs * 255
  )

  args.outputs.primitives << {
    x:  col_1,
    y:  row_1,
    x2: col_1 + dragonruby_logo_width.half,
    y2: row_1 + dragonruby_logo_height,
    x3: col_1 + dragonruby_logo_width,
    y3: row_1,
    r:  0, g: 0, b: 0, a: args.state.tick_count.to_radians.sin_r.abs * 255
  }

  args.outputs.sprites << {
    x:  col_2,
    y:  row_1,
    w:  dragonruby_logo_width,
    h:  dragonruby_logo_height,
    path: 'dragonruby.png',
    source_x:  0,
    source_y:  0,
    source_w:  dragonruby_logo_width,
    source_h:  dragonruby_logo_height.half +
               dragonruby_logo_height.half * Math.sin(args.state.tick_count.to_radians).abs,
  }

  args.outputs.primitives << {
    x:  col_3,
    y:  row_1,
    x2: col_3 + dragonruby_logo_width.half,
    y2: row_1 + dragonruby_logo_height,
    x3: col_3 + dragonruby_logo_width,
    y3: row_1,
    path: 'dragonruby.png',
    source_x:  0,
    source_y:  0,
    source_x2: dragonruby_logo_width.half,
    source_y2: dragonruby_logo_height.half +
               dragonruby_logo_height.half * Math.sin(args.state.tick_count.to_radians).abs,
    source_x3: dragonruby_logo_width,
    source_y3: 0
  }

  args.outputs.primitives << TriangleLogo.new(x:  col_4,
                                              y:  row_1,
                                              x2: col_4 + dragonruby_logo_width.half,
                                              y2: row_1 + dragonruby_logo_height,
                                              x3: col_4 + dragonruby_logo_width,
                                              y3: row_1,
                                              path: 'dragonruby.png',
                                              source_x:  0,
                                              source_y:  0,
                                              source_x2: dragonruby_logo_width.half,
                                              source_y2: dragonruby_logo_height.half +
                                                         dragonruby_logo_height.half * Math.sin(args.state.tick_count.to_radians).abs,
                                              source_x3: dragonruby_logo_width,
                                              source_y3: 0)
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

class TriangleLogo
  attr_sprite

  def initialize x:, y:, x2:, y2:, x3:, y3:, path:, source_x:, source_y:, source_x2:, source_y2:, source_x3:, source_y3:;
    @x         = x
    @y         = y
    @x2        = x2
    @y2        = y2
    @x3        = x3
    @y3        = y3
    @path      = path
    @source_x  = source_x
    @source_y  = source_y
    @source_x2 = source_x2
    @source_y2 = source_y2
    @source_x3 = source_x3
    @source_y3 = source_y3
  end
end
