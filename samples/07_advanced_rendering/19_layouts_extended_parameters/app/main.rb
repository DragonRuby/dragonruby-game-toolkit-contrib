def tick args
  args.state.origin ||= :top_left
  args.state.safe_area ||= :yes

  args.outputs.watch "Instructions:"
  args.outputs.watch "Use tab to change origin, use space to toggle safe area."
  args.outputs.watch "origin: #{args.state.origin}"
  args.outputs.watch "safe_area: #{args.state.safe_area}"

  if args.inputs.keyboard.key_down.tab
    if args.state.origin == :top_left
      args.state.origin = :top_right
    elsif args.state.origin == :top_right
      args.state.origin = :bottom_right
    elsif args.state.origin == :bottom_right
      args.state.origin = :bottom_left
    elsif args.state.origin == :bottom_left
      args.state.origin = :top_left
    end
  end

  if args.inputs.keyboard.key_down.space
    if args.state.safe_area == :yes
      args.state.safe_area = :no
    elsif args.state.safe_area == :no
      args.state.safe_area = :yes
    end
  end

  origin = args.state.origin
  safe_area = args.state.safe_area == :yes

  sub_grid = Layout.rect(row: 0,
                         col: 0,
                         w: 4,
                         h: 5,
                         include_row_gutter: true,
                         include_col_gutter: true,
                         origin: origin,
                         safe_area: safe_area)

  slots ||= {}
  20.times do |i|
    row = i.idiv(4)
    col = i % 4
    slots[i] = Layout.rect(row: i.idiv(4),
                           col: i % 4,
                           w: 1,
                           h: 1,
                           safe_area: safe_area,
                           origin: origin)
                     .merge(row: row, col: col)
  end

  args.outputs.primitives << Layout.debug_primitives
  args.outputs.primitives << sub_grid.merge(path: :solid, r: 255, g: 0, b: 0, a: 255)
  args.outputs.primitives << slots.values.map { |r| r.merge(path: :solid, r: 0, g: 0, b: 0, a: 255) }
  args.outputs.primitives << slots.values.map { |r| r.center.merge(text: "#{r.row},#{r.col}", r: 255, g: 255, b: 255, anchor_x: 0.5, anchor_y: 0.5) }
end
