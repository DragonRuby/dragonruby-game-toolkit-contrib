=begin

APIs listing that haven't been encountered in a previous sample apps:

- args.outputs.solids: An array. Values in this array generate
  solid/filled rectangles on the screen.

=end

# Rects are outputted in DragonRuby as rectangles
# If filled in, they are solids
# If hollow, they are borders

# Solids are added to args.outputs.solids
# Borders are added to args.outputs.borders

# The parameters required for rects are:
# 1. The upper right corner (x, y)
# 2. The width (w)
# 3. The height (h)
# 4. The rgba values for the color and transparency (r, g, b, a)

# Here is an example of a rect definition:
# [100, 100, 400, 500, 0, 255, 0, 180]

# The example would create a rect from (100, 100)
# Extending 400 pixels across the x axis
# and 500 pixels across the y axis
# The rect would be green (0, 255, 0)
# and mostly opaque with some transparency (180)

# Whether the rect would be filled or not depends on if
# it is added to args.outputs.solids or args.outputs.borders


def tick args
  tick_instructions args, "Sample app shows how to create solid squares."
  args.outputs.labels << [460, 600, "Solids (x, y, w, h, r, g, b, a)"]
  args.outputs.solids << [470, 520, 50, 50]
  args.outputs.solids << [530, 520, 50, 50, 0, 0, 0]
  args.outputs.solids << [590, 520, 50, 50, 255, 0, 0]
  args.outputs.solids << [650, 520, 50, 50, 255, 0, 0, 128]
  args.outputs.solids << [710, 520, 50, 50, 0, 0, 0, 128 + args.state.tick_count % 128]


  args.outputs.labels <<  [460, 400, "Borders (x, y, w, h, r, g, b, a)"]
  args.outputs.borders << [470, 320, 50, 50]
  args.outputs.borders << [530, 320, 50, 50, 0, 0, 0]
  args.outputs.borders << [590, 320, 50, 50, 255, 0, 0]
  args.outputs.borders << [650, 320, 50, 50, 255, 0, 0, 128]
  args.outputs.borders << [710, 320, 50, 50, 0, 0, 0, 128 + args.state.tick_count % 128]
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
