=begin

APIs that haven't been encountered in a previous sample apps:

- args.inputs.mouse.click: This property will be set if the mouse was clicked.
- args.inputs.mouse.click.point.(x|y): The x and y location of the mouse.
- args.inputs.mouse.click.point.created_at: The frame the mouse click occurred in.
- args.inputs.mouse.click.point.created_at_elapsed: How many frames have passed
  since the click event.

Reminder:

- args.state.PROPERTY: The state property on args is a dynamic
  structure. You can define ANY property here with ANY type of
  arbitrary nesting. Properties defined on args.state will be retained
  across frames. If you attempt access a property that doesn't exist
  on args.state, it will simply return nil (no exception will be thrown).

=end

# This code demonstrates DragonRuby mouse input

# To see if the a mouse click occurred
# Use args.inputs.mouse.click
# Which returns a boolean

# To see where a mouse click occurred
# Use args.inputs.mouse.click.point.x AND
# args.inputs.mouse.click.point.y

# To see which frame the click occurred
# Use args.inputs.mouse.click.created_at

# To see how many frames its been since the click occurred
# Use args.inputs.mouse.click.created_at_elapsed

# Saving the click in args.state can be quite useful

def tick args
  tick_instructions args, "Sample app shows how mouse events are registered and how to measure elapsed time."
  x = 460

  args.outputs.labels << small_label(args, x, 11, "Mouse input: args.inputs.mouse")

  if args.inputs.mouse.click
    args.state.last_mouse_click = args.inputs.mouse.click
  end

  if args.state.last_mouse_click
    click = args.state.last_mouse_click
    args.outputs.labels << small_label(args, x, 12, "Mouse click happened at: #{click.created_at}")
    args.outputs.labels << small_label(args, x, 13, "Mouse clicked #{click.created_at_elapsed} ticks ago")
    args.outputs.labels << small_label(args, x, 14, "Mouse click location: #{click.point.x}, #{click.point.y}")
  else
    args.outputs.labels << small_label(args, x, 12, "Mouse click has not occurred yet.")
    args.outputs.labels << small_label(args, x, 13, "Please click mouse.")
  end
end

def small_label args, x, row, message
  # This method effectively combines the row_to_px and small_font methods
  # It changes the given row value to a DragonRuby pixel value
  # and adds the customization parameters
  { x: x, y: row_to_px(args, row), text: message, alignment_enum: -2 }
end

def row_to_px args, row_number
  args.grid.top.shift_down(5).shift_down(20 * row_number)
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << { x: 0,   y: y - 50, w: 1280, h: 60 }.solid!
  args.outputs.debug << { x: 640, y: y, text: text, size_enum: 1, alignment_enum: 1, r: 255, g: 255, b: 255 }.label!
  args.outputs.debug << { x: 640, y: y - 25, text: "(click to dismiss instructions)", size_enum: -2, alignment_enum: 1, r: 255, g: 255, b: 255 }.label!
end
