def tick args
  # String.line_anchors is a helpful function if you want
  # to center a multi-line text vertically or horizontally
  16.times do |line_count_index|
    c = line_count_index + 1
    args.outputs.labels << String.line_anchors(c).map_with_index do |anchor_value, line_index|
      # to_sf is a hellper method for formatting numbers (useful for debugging purposes)
      v_to_s = anchor_value.to_sf(decimal_places: 1, include_sign: true)
      { x: line_count_index * 76 + 64,
        y: 360,
        text: "#{(line_index + 1).to_s.rjust(2)} [#{v_to_s}]",
        anchor_x: 0.5,
        anchor_y: anchor_value,
        size_px: 16 }
    end
  end

  args.outputs.lines << { x: 0, y: 360, x2: 1280, y2: 360 }
  args.outputs.lines << { x: 640, y: 0, x2: 640, y2: 720 }
end
