def tick args
  # create buttons
  args.state.buttons ||= [
    create_button(args, id: :button_1, row: 0, col: 0, text: "button 1"),
    create_button(args, id: :button_2, row: 1, col: 0, text: "button 2"),
    create_button(args, id: :clear,    row: 2, col: 0, text: "clear")
  ]

  # render button's border and label
  args.outputs.primitives << args.state.buttons.map do |b|
    b.primitives
  end

  # render center label if the text is set
  if args.state.center_label_text
    args.outputs.labels << { x: 640,
                             y: 360,
                             text: args.state.center_label_text,
                             alignment_enum: 1,
                             vertical_alignment_enum: 1 }
  end

  # if the mouse is clicked, see if the mouse click intersected
  # with a button
  if args.inputs.mouse.click
    button = args.state.buttons.find do |b|
      args.inputs.mouse.intersect_rect? b
    end

    # update the center label text based on button clicked
    case button.id
    when :button_1
      args.state.center_label_text = "button 1 was clicked"
    when :button_2
      args.state.center_label_text = "button 2 was clicked"
    when :clear
      args.state.center_label_text = nil
    end
  end
end

def create_button args, id:, row:, col:, text:;
  # args.layout.rect(row:, col:, w:, h:) is method that will
  # return a rectangle inside of a grid with 12 rows and 24 columns
  rect = args.layout.rect row: row, col: col, w: 3, h: 1

  # get senter of rect for label
  center = args.geometry.rect_center_point rect

  {
    id: id,
    x: rect.x,
    y: rect.y,
    w: rect.w,
    h: rect.h,
    primitives: [
      {
        x: rect.x,
        y: rect.y,
        w: rect.w,
        h: rect.h,
        primitive_marker: :border
      },
      {
        x: center.x,
        y: center.y,
        text: text,
        size_enum: -1,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        primitive_marker: :label
      }
    ]
  }
end

$gtk.reset
