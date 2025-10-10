=begin

APIs that haven't been encountered in a previous sample apps:

- args.inputs.mouse.click: This property will be set if the mouse was clicked.
- args.inputs.mouse.click.(x|y): The x and y location of the mouse.
- args.inputs.mouse.click.created_at: The frame the mouse click occurred in.
- args.inputs.mouse.click.created_at_elapsed: How many frames have passed
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
# Use args.inputs.mouse.click.x AND
# args.inputs.mouse.click.y

# To see which frame the click occurred
# Use args.inputs.mouse.click.created_at

# To see how many frames its been since the click occurred
# Use args.inputs.mouse.click.created_at_elapsed

# Saving the click in args.state can be quite useful

def tick args
  args.outputs.labels << { x: 640,
                           y: 700,
                           anchor_x: 0.5,
                           anchor_y: 0.5,
                           text: "Sample app shows how mouse events are registered and how to measure elapsed time." }

  args.outputs.labels << { x: 640, y: 540, text: "Mouse input: args.inputs.mouse", anchor_x: 0.5, anchor_y: 0.5 }

  if args.inputs.mouse.click
    args.state.last_mouse_click = args.inputs.mouse.click
  end

  if args.state.last_mouse_click
    click = args.state.last_mouse_click
    args.outputs.labels << { x: 640, y: 360, text: "Mouse click happened at: #{click.created_at}", anchor_x: 0.5, anchor_y: 0.5 - 1 }
    args.outputs.labels << { x: 640, y: 360, text: "Mouse clicked #{click.created_at_elapsed} ticks ago", anchor_x: 0.5, anchor_y: 0.5 }
    args.outputs.labels << { x: 640, y: 360, text: "Mouse click location: #{click.x}, #{click.y}", anchor_x: 0.5, anchor_y: 0.5 + 1 }
  else
    args.outputs.labels << { x: 640, y: 360, text: "Mouse click has not occurred yet.", anchor_x: 0.5, anchor_y: 0.5 - 0.5 }
    args.outputs.labels << { x: 640, y: 360, text: "Please click mouse.", anchor_x: 0.5, anchor_y: 0.5 + 0.5 }
  end
end
