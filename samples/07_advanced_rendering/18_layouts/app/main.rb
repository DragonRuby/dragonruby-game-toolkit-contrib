def tick args
  args.outputs.solids << Layout.rect(row: 0,
                                          col: 0,
                                          w: 24,
                                          h: 12,
                                          include_row_gutter: true,
                                          include_col_gutter: true).merge(b: 255, a: 80)
  render_row_examples args
  render_column_examples args
  render_max_width_max_height_examples args
  render_points_with_anchored_label_examples args
  render_centered_rect_examples args
  render_rect_group_examples args
end

def render_row_examples args
  # rows (light blue)
  args.outputs.labels << Layout.rect(row: 1, col: 6 + 3).merge(text: "row examples", anchor_x: 0.5, anchor_y: 0.5)
  4.map_with_index do |row|
    args.outputs.solids << Layout.rect(row: row, col: 6, w: 1, h: 1).merge(**light_blue)
  end

  2.map_with_index do |row|
    args.outputs.solids << Layout.rect(row: row * 2, col: 6 + 1, w: 1, h: 2).merge(**light_blue)
  end

  4.map_with_index do |row|
    args.outputs.solids << Layout.rect(row: row, col: 6 + 2, w: 2, h: 1).merge(**light_blue)
  end

  2.map_with_index do |row|
    args.outputs.solids << Layout.rect(row: row * 2, col: 6 + 4, w: 2, h: 2).merge(**light_blue)
  end
end

def render_column_examples args
  # columns (yellow)
  yellow = { r: 255, g: 255, b: 128 }
  args.outputs.labels << Layout.rect(row: 1, col: 12 + 3).merge(text: "column examples", anchor_x: 0.5, anchor_y: 0.5)
  6.times do |col|
    args.outputs.solids << Layout.rect(row: 0, col: 12 + col, w: 1, h: 1).merge(**yellow)
  end

  3.times do |col|
    args.outputs.solids << Layout.rect(row: 1, col: 12 + col * 2, w: 2, h: 1).merge(**yellow)
  end

  6.times do |col|
    args.outputs.solids << Layout.rect(row: 2, col: 12 + col, w: 1, h: 2).merge(**yellow)
  end
end

def render_max_width_max_height_examples args
  # max width/height baseline (transparent green)
  args.outputs.labels << Layout.rect(row: 4, col: 12).merge(text: "max width/height examples", anchor_x: 0.5, anchor_y: 0.5)
  args.outputs.solids << Layout.rect(row: 4, col: 0, w: 24, h: 2).merge(a: 64, **green)

  # max height
  args.outputs.solids << Layout.rect(row: 4, col: 0, w: 24, h: 2, max_height: 1).merge(a: 64, **green)

  # max width
  args.outputs.solids << Layout.rect(row: 4, col: 0, w: 24, h: 2, max_width: 12).merge(a: 64, **green)
end

def render_points_with_anchored_label_examples args
  # labels relative to rects
  label_color = { r: 0, g: 0, b: 0 }

  # labels realtive to point, achored at 0.0, 0.0
  args.outputs.borders << Layout.rect(row: 6, col: 3, w: 6, h: 5)
  args.outputs.labels << Layout.rect(row: 6, col: 3, w: 6, h: 1).center.merge(text: "layout.point anchored to 0.0, 0.0", anchor_x: 0.5, anchor_y: 0.5, size_px: 15)
  grey = { r: 128, g: 128, b: 128 }
  args.outputs.solids << Layout.rect(row: 7, col: 4.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 7, col: 4.5, row_anchor: 1.0, col_anchor: 0.0).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)

  args.outputs.solids << Layout.rect(row: 7, col: 5.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 7, col: 5.5, row_anchor: 1.0, col_anchor: 0.5).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)

  args.outputs.solids << Layout.rect(row: 7, col: 6.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 7, col: 6.5, row_anchor: 1.0, col_anchor: 1.0).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)

  args.outputs.solids << Layout.rect(row: 8, col: 4.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 8, col: 4.5, row_anchor: 0.5, col_anchor: 0.0).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)

  args.outputs.solids << Layout.rect(row: 8, col: 5.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 8, col: 5.5, row_anchor: 0.5, col_anchor: 0.5).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)

  args.outputs.solids << Layout.rect(row: 8, col: 6.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 8, col: 6.5, row_anchor: 0.5, col_anchor: 1.0).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)

  args.outputs.solids << Layout.rect(row: 9, col: 4.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 9, col: 4.5, row_anchor: 0.0, col_anchor: 0.0).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)

  args.outputs.solids << Layout.rect(row: 9, col: 5.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 9, col: 5.5, row_anchor: 0.0, col_anchor: 0.5).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)

  args.outputs.solids << Layout.rect(row: 9, col: 6.5).merge(**grey)
  args.outputs.labels << Layout.point(row: 9, col: 6.5, row_anchor: 0.0, col_anchor: 1.0).merge(text: "[x]", anchor_x: 0.5, anchor_y: 0.5, **label_color)
end

def render_centered_rect_examples args
  # centering rects
  args.outputs.borders << Layout.rect(row: 6, col: 9, w: 6, h: 5)
  args.outputs.labels << Layout.rect(row: 6, col: 9, w: 6, h: 1).center.merge(text: "layout.rect centered inside another rect", anchor_x: 0.5, anchor_y: 0.5, size_px: 15)
  outer_rect = Layout.rect(row: 7, col: 10.5, w: 3, h: 3)

  # render outer rect
  args.outputs.solids << outer_rect.merge(**light_blue)

  # # center a yellow rect with w and h of two
  args.outputs.solids << Layout.rect_center(
    Layout.rect(w: 1, h: 5), # inner rect
    outer_rect, # outer rect
  ).merge(**yellow)

  # # center a black rect with w three h of one
  args.outputs.solids << Layout.rect_center(
    Layout.rect(w: 5, h: 1), # inner rect
    outer_rect, # outer rect
  )
end

def render_rect_group_examples args
  args.outputs.labels << Layout.rect(row: 6, col: 15, w: 6, h: 1).center.merge(text: "layout.rect_group usage", anchor_x: 0.5, anchor_y: 0.5, size_px: 15)
  args.outputs.borders << Layout.rect(row: 6, col: 15, w: 6, h: 5)

  horizontal_markers = [
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
  ]

  args.outputs.solids << Layout.rect_group(row: 7,
                                                col: 15,
                                                dcol: 1,
                                                w: 1,
                                                h: 1,
                                                group: horizontal_markers)

  vertical_markers = [
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 },
    { r: 0, g: 0, b: 0 }
  ]

  args.outputs.solids << Layout.rect_group(row: 7,
                                                col: 15,
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
    { r: 250, g: 250, b: 250 },
  ]

  args.outputs.solids << Layout.rect_group(row: 8,
                                                col: 15,
                                                dcol: 1,
                                                w: 1,
                                                h: 1,
                                                group: colors)
end

def light_blue
  { r: 128, g: 255, b: 255 }
end

def yellow
  { r: 255, g: 255, b: 128 }
end

def green
  { r: 0, g: 128, b: 80 }
end

def white
  { r: 255, g: 255, b: 255 }
end

def label_color
  { r: 0, g: 0, b: 0 }
end

GTK.reset
