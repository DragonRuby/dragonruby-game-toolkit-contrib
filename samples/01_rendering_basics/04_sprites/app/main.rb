=begin

APIs listing that haven't been encountered in a previous sample apps:

- args.outputs.sprites: An array. Values in this array generate
  sprites on the screen. The location of the sprite is assumed to
  be under the mygame/ directory (the exception being dragonruby.png).

=end


# For all other display outputs, Sprites are your solution
# Sprites import images and display them with a certain rectangular area
# The image can be of any usual format and should be located within the folder,
# similar to additional fonts.

# Sprites have the following parameters
# Rectangular area (x, y, width, height)
# The image (path)
# Rotation (angle)
# Alpha (a)

def tick args
  tick_instructions args, "Sample app shows how to render a sprite. Set its alpha, and rotate it."
  args.outputs.labels <<  [460, 600, "Sprites (x, y, w, h, path, angle, a)"]
  args.outputs.sprites << [460, 470, 128, 101, 'dragonruby.png']
  args.outputs.sprites << [610, 470, 128, 101, 'dragonruby.png', args.state.tick_count % 360]
  args.outputs.sprites << [760, 470, 128, 101, 'dragonruby.png', 0, args.state.tick_count % 255]
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
