=begin

APIs that haven't been encountered in a previous sample apps:

- args.outputus.borders: An array. Values in this array will be rendered as
  unfilled rectangles on the screen.
- ARRAY#inside_rect?: An array with at least two values is considered a point. An array
  with at least four values is considered a rect. The inside_rect? function returns true
  or false depending on if the point is inside the rect.

  ```
  # Point:  x: 100, y: 100
  # Rect:   x: 0, y: 0, w: 500, h: 500
  # Result: true

  [100, 100].inside_rect? [0, 0, 500, 500]
  ```

  ```
  # Point:  x: 100, y: 100
  # Rect:   x: 300, y: 300, w: 100, h: 100
  # Result: false

  [100, 100].inside_rect? [300, 300, 100, 100]
  ```

- args.inputs.mouse.click.point.created_at: The frame the mouse click occurred in.
- args.inputs.mouse.click.point.created_at_elapsed: How many frames have passed
  since the click event.

=end

# To determine whether a point is in a rect
# Use point.inside_rect? rect

# This is useful to determine if a click occurred in a rect

def tick args
  tick_instructions args, "Sample app shows how to determing if a click happened inside a rectangle."

  x = 460

  args.outputs.labels << small_label(args, x, 15, "Click inside the blue box maybe ---->")

  box = { x: 785, y: 370, w: 50, h: 50, r: 0, g: 0, b: 170 }
  args.outputs.borders << box

  # Saves the most recent click into args.state
  # Unlike the other components of args,
  # args.state does not reset every tick.
  if args.inputs.mouse.click
    args.state.last_mouse_click = args.inputs.mouse.click
  end

  if args.state.last_mouse_click
    if args.state.last_mouse_click.point.inside_rect? box
      args.outputs.labels << small_label(args, x, 16, "Mouse click happened *inside* the box.")
    else
      args.outputs.labels << small_label(args, x, 16, "Mouse click happened *outside* the box.")
    end
  else
    args.outputs.labels << small_label(args, x, 16, "Mouse click has not occurred yet.")
  end
end

def small_label args, x, row, message
  { x: x, y: row_to_px(args, row), text: message, size_enum: -2 }
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
