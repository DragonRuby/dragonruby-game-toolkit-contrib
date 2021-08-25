=begin

APIs that haven't been encountered in a previous sample apps:

- args.outputs.borders: An array. Values in this array will be rendered as
  unfilled rectangles on the screen.
- ARRAY#intersect_rect?: An array with at least four values is
  considered a rect. The intersect_rect? function returns true
  or false depending on if the two rectangles intersect.

  ```
  # Rect One: x: 100, y: 100, w: 100, h: 100
  # Rect Two: x: 0, y: 0, w: 500, h: 500
  # Result:   true

  [100, 100, 100, 100].intersect_rect? [0, 0, 500, 500]
  ```

  ```
  # Rect One: x: 100, y: 100, w: 10, h: 10
  # Rect Two: x: 500, y: 500, w: 10, h: 10
  # Result:   false

  [100, 100, 10, 10].intersect_rect? [500, 500, 10, 10]
  ```

=end

# Similarly, whether rects intersect can be found through
# rect1.intersect_rect? rect2

def tick args
  tick_instructions args, "Sample app shows how to determine if two rectangles intersect."
  x = 460

  args.outputs.labels << small_label(args, x, 3, "Click anywhere on the screen")
  # red_box = [460, 250, 355, 90, 170, 0, 0]
  # args.outputs.borders << red_box

  # args.state.box_collision_one and args.state.box_collision_two
  # Are given values of a solid when they should be rendered
  # They are stored in game so that they do not get reset every tick
  if args.inputs.mouse.click
    if !args.state.box_collision_one
      args.state.box_collision_one = { x: args.inputs.mouse.click.point.x - 25,
                                       y: args.inputs.mouse.click.point.y - 25,
                                       w: 125, h: 125,
                                       r: 180, g: 0, b: 0, a: 180 }
    elsif !args.state.box_collision_two
      args.state.box_collision_two = { x: args.inputs.mouse.click.point.x - 25,
                                       y: args.inputs.mouse.click.point.y - 25,
                                       w: 125, h: 125,
                                       r: 0, g: 0, b: 180, a: 180 }
    else
      args.state.box_collision_one = nil
      args.state.box_collision_two = nil
    end
  end

  if args.state.box_collision_one
    args.outputs.solids << args.state.box_collision_one
  end

  if args.state.box_collision_two
    args.outputs.solids << args.state.box_collision_two
  end

  if args.state.box_collision_one && args.state.box_collision_two
    if args.state.box_collision_one.intersect_rect? args.state.box_collision_two
      args.outputs.labels << small_label(args, x, 4, 'The boxes intersect.')
    else
      args.outputs.labels << small_label(args, x, 4, 'The boxes do not intersect.')
    end
  else
    args.outputs.labels << small_label(args, x, 4, '--')
  end
end

def small_label args, x, row, message
  { x: x, y: row_to_px(args, row), text: message, size_enum: -2 }
end

def row_to_px args, row_number
  args.grid.top - 5 - (20 * row_number)
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end
