def tick args
  # defaults
  args.state.scroll_location  ||= 0
  args.state.textbox.messages ||= []
  args.state.textbox.scroll   ||= 0

  # render
  args.outputs.background_color = [0, 0, 0, 255]
  render_messages args
  render_instructions args

  # inputs
  if args.inputs.keyboard.key_down.one
    queue_message args, "Hello there neighbour! my name is mark, how is your day today?"
  end

  if args.inputs.keyboard.key_down.two
    queue_message args, "I'm doing great sir, actually I'm having a picnic today"
  end

  if args.inputs.keyboard.key_down.three
    queue_message args, "Well that sounds wonderful!"
  end

  if args.inputs.keyboard.key_down.home
    args.state.scroll_location = 1
  end

  if args.inputs.keyboard.key_down.delete
    clear_message_queue args
  end
end

def queue_message args, msg
  args.state.textbox.messages.concat msg.wrapped_lines 50
end

def clear_message_queue args
  args.state.textbox.messages = nil
  args.state.textbox.scroll = 0
end

def render_messages args
  args.outputs[:textbox].w = 400
  args.outputs[:textbox].h = 720

  args.outputs.primitives << args.state.textbox.messages.each_with_index.map do |s, idx|
    {
      x: 0,
      y: 20 * (args.state.textbox.messages.size - idx) + args.state.textbox.scroll * 20,
      text: s,
      size_enum: -3,
      alignment_enum: 0,
      r: 255, g:255, b: 255, a: 255
    }
  end

  args.outputs[:textbox].labels << args.state.textbox.messages.each_with_index.map do |s, idx|
    {
      x: 0,
      y: 20 * (args.state.textbox.messages.size - idx) + args.state.textbox.scroll * 20,
      text: s,
      size_enum: -3,
      alignment_enum: 0,
      r: 255, g:255, b: 255, a: 255
    }
  end

  args.outputs[:textbox].borders << [0, 0, args.outputs[:textbox].w, 720]

  args.state.textbox.scroll += args.inputs.mouse.wheel.y unless args.inputs.mouse.wheel.nil?

  if args.state.scroll_location > 0
    args.state.textbox.scroll = 0
    args.state.scroll_location = 0
  end

  args.outputs.sprites << [900, 0, args.outputs[:textbox].w, 720, :textbox]
end

def render_instructions args
  args.outputs.labels << [30,
                          30.from_top,
                          "press 1, 2, 3 to display messages, MOUSE WHEEL to scroll, HOME to go to top, BACKSPACE to delete.",
                          0, 255, 255]

  args.outputs.primitives << [0, 55.from_top, 1280, 30, :pixel, 0, 255, 0, 0, 0].sprite
end
