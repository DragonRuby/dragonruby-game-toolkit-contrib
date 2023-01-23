def tick args
  if !args.gtk.version_pro?
    args.outputs.labels << { x: args.grid.w / 2,
                             y: args.grid.h / 2,
                             alignment_enum: 1,
                             vertical_alignment_enum: 1,
                             text: "Portrait mode is a Pro feature." }
    return
  elsif args.gtk.version_pro? && args.grid.orientation == :landscape
    args.outputs.labels << { x: args.grid.w / 2,
                             y: args.grid.h / 2,
                             alignment_enum: 1,
                             vertical_alignment_enum: 1,
                             text: "Landscape orientation detected. Make sure your metadata/game_metadata.txt has the value orientation=portrait." }
    return
  end

  args.outputs.solids << args.layout.rect(row: 0, col: 0, w: 12, h: 24, include_row_gutter: true, include_col_gutter: true).merge(b: 255, a: 80)

  # rows (light blue)
  light_blue = { r: 128, g: 255, b: 255 }
  args.outputs.labels << args.layout.rect(row: 1, col: 3).merge(text: "row examples", vertical_alignment_enum: 1, alignment_enum: 1)
  4.map_with_index do |row|
    args.outputs.solids << args.layout.rect(row: row, col: 0, w: 1, h: 1).merge(**light_blue)
  end

  2.map_with_index do |row|
    args.outputs.solids << args.layout.rect(row: row * 2, col: 1, w: 1, h: 2).merge(**light_blue)
  end

  4.map_with_index do |row|
    args.outputs.solids << args.layout.rect(row: row, col: 2, w: 2, h: 1).merge(**light_blue)
  end

  2.map_with_index do |row|
    args.outputs.solids << args.layout.rect(row: row * 2, col: 4, w: 2, h: 2).merge(**light_blue)
  end

  # columns (yellow)
  yellow = { r: 255, g: 255, b: 128 }
  args.outputs.labels << args.layout.rect(row: 1, col: 9).merge(text: "column examples", vertical_alignment_enum: 1, alignment_enum: 1)
  6.times do |col|
    args.outputs.solids << args.layout.rect(row: 0, col: 6 + col, w: 1, h: 1).merge(**yellow)
  end

  3.times do |col|
    args.outputs.solids << args.layout.rect(row: 1, col: 6 + col * 2, w: 2, h: 1).merge(**yellow)
  end

  6.times do |col|
    args.outputs.solids << args.layout.rect(row: 2, col: 6 + col, w: 1, h: 2).merge(**yellow)
  end

  # max width/height baseline (transparent green)
  green = { r: 0, g: 128, b: 80 }
  args.outputs.labels << args.layout.rect(row: 4, col: 6).merge(text: "max width/height examples", vertical_alignment_enum: 1, alignment_enum: 1)
  args.outputs.solids << args.layout.rect(row: 4, col: 0, w: 12, h: 2).merge(a: 64, **green)

  # max height
  args.outputs.solids << args.layout.rect(row: 4, col: 0, w: 12, h: 2, max_height: 1).merge(a: 64, **green)

  # max width
  args.outputs.solids << args.layout.rect(row: 4, col: 0, w: 12, h: 2, max_width: 6).merge(a: 64, **green)

  # labels relative to rects
  label_color = { r: 0, g: 0, b: 0 }
  white = { r: 232, g: 232, b: 232 }

  # labels realtive to point, achored at 0.0, 0.0
  args.outputs.labels << args.layout.rect(row: 5.5, col: 6).merge(text: "labels using args.layout.point anchored to 0.0, 0.0", vertical_alignment_enum: 1, alignment_enum: 1)
  grey = { r: 128, g: 128, b: 128 }
  args.outputs.solids << args.layout.rect(row: 7, col: 4).merge(**grey)
  args.outputs.labels << args.layout.point(row: 7, col: 4, row_anchor: 1.0, col_anchor: 0.0).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  args.outputs.solids << args.layout.rect(row: 7, col: 5).merge(**grey)
  args.outputs.labels << args.layout.point(row: 7, col: 5, row_anchor: 1.0, col_anchor: 0.5).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  args.outputs.solids << args.layout.rect(row: 7, col: 6).merge(**grey)
  args.outputs.labels << args.layout.point(row: 7, col: 6, row_anchor: 1.0, col_anchor: 1.0).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  args.outputs.solids << args.layout.rect(row: 8, col: 4).merge(**grey)
  args.outputs.labels << args.layout.point(row: 8, col: 4, row_anchor: 0.5, col_anchor: 0.0).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  args.outputs.solids << args.layout.rect(row: 8, col: 5).merge(**grey)
  args.outputs.labels << args.layout.point(row: 8, col: 5, row_anchor: 0.5, col_anchor: 0.5).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  args.outputs.solids << args.layout.rect(row: 8, col: 6).merge(**grey)
  args.outputs.labels << args.layout.point(row: 8, col: 6, row_anchor: 0.5, col_anchor: 1.0).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  args.outputs.solids << args.layout.rect(row: 9, col: 4).merge(**grey)
  args.outputs.labels << args.layout.point(row: 9, col: 4, row_anchor: 0.0, col_anchor: 0.0).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  args.outputs.solids << args.layout.rect(row: 9, col: 5).merge(**grey)
  args.outputs.labels << args.layout.point(row: 9, col: 5, row_anchor: 0.0, col_anchor: 0.5).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  args.outputs.solids << args.layout.rect(row: 9, col: 6).merge(**grey)
  args.outputs.labels << args.layout.point(row: 9, col: 6, row_anchor: 0.0, col_anchor: 1.0).merge(text: "[x]", alignment_enum: 1, vertical_alignment_enum: 1, **label_color)

  # centering rects
  args.outputs.labels << args.layout.rect(row: 10.5, col: 6).merge(text: "layout.rect centered inside another layout.rect", vertical_alignment_enum: 1, alignment_enum: 1)
  outer_rect = args.layout.rect(row: 12, col: 4, w: 3, h: 3)

  # render outer rect
  args.outputs.solids << outer_rect.merge(**light_blue)

  # center a yellow rect with w and h of two
  args.outputs.solids << args.layout.rect_center(
    args.layout.rect(w: 1, h: 5), # inner rect
    outer_rect, # outer rect
  ).merge(**yellow)

  # center a black rect with w three h of one
  args.outputs.solids << args.layout.rect_center(
    args.layout.rect(w: 5, h: 1), # inner rect
    outer_rect, # outer rect
  )

  args.outputs.labels << args.layout.rect(row: 16.5, col: 6).merge(text: "layout.rect_group usage", vertical_alignment_enum: 1, alignment_enum: 1)

  horizontal_markers = [
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 }
  ]

  args.outputs.solids << args.layout.rect_group(row: 18,
                                                dcol: 1,
                                                w: 1,
                                                h: 1,
                                                group: horizontal_markers)

  vertical_markers = [
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 }
  ]

  args.outputs.solids << args.layout.rect_group(row: 18,
                                                drow: 1,
                                                w: 1,
                                                h: 1,
                                                group: vertical_markers)

  colors = [
    { r:   0, g:   0, b:   0 },
    { r:  50, g:  50, b:  50 },
    { r: 100, g: 100, b: 100 },
    { r: 150, g: 150, b: 150 },
    { r: 200, g: 200, b: 200 },
  ]

  args.outputs.solids << args.layout.rect_group(row: 19,
                                                col: 1,
                                                dcol: 2,
                                                w: 2,
                                                h: 1,
                                                group: colors)

  args.outputs.solids << args.layout.rect_group(row: 19,
                                                col: 1,
                                                drow: 1,
                                                w: 2,
                                                h: 1,
                                                group: colors)
end

$gtk.reset
