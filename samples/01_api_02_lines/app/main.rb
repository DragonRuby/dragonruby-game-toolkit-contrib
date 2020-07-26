=begin

APIs listing that haven't been encountered in a previous sample apps:

- args.outputs.lines: An array. Values in this array generate lines on
  the screen.
- args.state.tick_count: This property contains an integer value that
  represents the current frame. GTK renders at 60 FPS. A value of 0
  for args.state.tick_count represents the initial load of the game.

=end

# The parameters required for lines are:
# 1. The initial point (x, y)
# 2. The end point (x2, y2)
# 3. The rgba values for the color and transparency (r, g, b, a)

# An example of creating a line would be:
# args.outputs.lines << [100, 100, 300, 300, 255, 0, 255, 255]

# This would create a line from (100, 100) to (300, 300)
# The RGB code (255, 0, 255) would determine its color, a purple
# It would have an Alpha value of 255, making it completely opaque

def tick args
  tick_instructions args, "Sample app shows how to create lines."

  args.outputs.labels << [480, 620, "Lines (x, y, x2, y2, r, g, b, a)"]

  # Some simple lines
  args.outputs.lines  << [380, 450, 675, 450]
  args.outputs.lines  << [380, 410, 875, 410]

  # These examples utilize args.state.tick_count to change the length of the lines over time
  # args.state.tick_count is the ticks that have occurred in the game
  # This is accomplished by making either the starting or ending point based on the args.state.tick_count
  args.outputs.lines  << [380, 370, 875, 370, args.state.tick_count % 255, 0, 0, 255]
  args.outputs.lines  << [380, 330 - args.state.tick_count % 25, 875, 330, 0, 0, 0, 255]
  args.outputs.lines  << [380 + args.state.tick_count % 400, 290, 875, 290, 0, 0, 0, 255]
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
