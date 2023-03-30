def tick args
  # create a texture/render_target that's composed of a border and a label
  create_button args, :hello_world_button, "Hello World", 500, 50

  # two button primitives using the hello_world_button render_target
  args.state.buttons ||= [
    # one button at the top
    { id: :top_button, x: 640 - 250, y: 80.from_top, w: 500, h: 50, path: :hello_world_button },

    # another button at the buttom, upside down, and flipped horizontally
    { id: :bottom_button, x: 640 - 250, y: 30, w: 500, h: 50, path: :hello_world_button, angle: 180, flip_horizontally: true },
  ]

  # check if a mouse click occurred
  if args.inputs.mouse.click
    # check to see if any of the buttons were intersected
    # and set the selected button if so
    args.state.selected_button = args.state.buttons.find { |b| b.intersect_rect? args.inputs.mouse }
  end

  # render the buttons
  args.outputs.sprites << args.state.buttons

  # if there was a selected button, print it's id
  if args.state.selected_button
    args.outputs.labels << { x: 30, y: 30.from_top, text: "#{args.state.selected_button.id} was clicked." }
  end
end

def create_button args, id, text, w, h
  # render_targets only need to be created once, we use the the id to determine if the texture
  # has already been created
  args.state.created_buttons ||= {}
  return if args.state.created_buttons[id]

  # if the render_target hasn't been created, then generate it and store it in the created_buttons cache
  args.state.created_buttons[id] = { created_at: args.state.tick_count, id: id, w: w, h: h, text: text }

  # define the w/h of the texture
  args.outputs[id].w = w
  args.outputs[id].h = h

  # create a border
  args.outputs[id].borders << { x: 0, y: 0, w: w, h: h }

  # create a label centered vertically and horizontally within the texture
  args.outputs[id].labels << { x: w / 2, y: h / 2, text: text, vertical_alignment_enum: 1, alignment_enum: 1 }
end
