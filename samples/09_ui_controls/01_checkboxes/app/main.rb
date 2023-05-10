def tick args
  # use layout apis to position check boxes
  args.state.checkboxes ||= [
    args.layout.rect(row: 0, col: 0, w: 1, h: 1).merge(id: :option1, text: "Option 1", checked: false, changed_at: -120),
    args.layout.rect(row: 1, col: 0, w: 1, h: 1).merge(id: :option1, text: "Option 2", checked: false, changed_at: -120),
    args.layout.rect(row: 2, col: 0, w: 1, h: 1).merge(id: :option1, text: "Option 3", checked: false, changed_at: -120),
    args.layout.rect(row: 3, col: 0, w: 1, h: 1).merge(id: :option1, text: "Option 4", checked: false, changed_at: -120),
  ]

  # check for click of checkboxes
  if args.inputs.mouse.click
    args.state.checkboxes.find_all do |checkbox|
      args.inputs.mouse.inside_rect? checkbox
    end.each do |checkbox|
      # mark checkbox value
      checkbox.checked = !checkbox.checked
      # set the time the checkbox was changed
      checkbox.changed_at = args.state.tick_count
    end
  end

  # render checkboxes
  args.outputs.primitives << args.state.checkboxes.map do |checkbox|
    # baseline prefab for checkbox
    prefab = {
      x: checkbox.x,
      y: checkbox.y,
      w: checkbox.w,
      h: checkbox.h
    }

    # label for checkbox centered vertically
    label = {
      x: checkbox.x + checkbox.w + 10,
      y: checkbox.y + checkbox.h / 2,
      text: checkbox.text,
      alignment_enum: 0,
      vertical_alignment_enum: 1
    }

    # rendering if checked or not
    if checkbox.checked
      # fade in
      a = 255 * args.easing.ease(checkbox.changed_at, args.state.tick_count, 30, :smooth_stop_quint)

      [
        label,
        prefab.merge(primitive_marker: :solid, a: a),
        prefab.merge(primitive_marker: :border)
      ]
    else
      # fade out
      a = 255 * args.easing.ease(checkbox.changed_at, args.state.tick_count, 30, :smooth_stop_quint, :flip)

      [
        label,
        prefab.merge(primitive_marker: :solid, a: a),
        prefab.merge(primitive_marker: :border)
      ]
    end
  end
end
