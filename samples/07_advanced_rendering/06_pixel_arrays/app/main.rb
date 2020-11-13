$gtk.reset

def tick args
  args.state.posinc ||= 1
  args.state.pos ||= 0
  args.state.rotation ||= 0

  dimension = 10  # keep it small and let the GPU scale it when rendering the sprite.

  # Set up our "scanner" pixel array and fill it with black pixels.
  args.pixel_array(:scanner).width = dimension
  args.pixel_array(:scanner).height = dimension
  args.pixel_array(:scanner).pixels.fill(0xFF000000, 0, dimension * dimension)  # black, full alpha

  # Draw a green line that bounces up and down the sprite.
  args.pixel_array(:scanner).pixels.fill(0xFF00FF00, dimension * args.state.pos, dimension)  # green, full alpha

  # Adjust position for next frame.
  args.state.pos += args.state.posinc
  if args.state.posinc > 0 && args.state.pos >= dimension
    args.state.posinc = -1
    args.state.pos = dimension - 1
  elsif args.state.posinc < 0 && args.state.pos < 0
    args.state.posinc = 1
    args.state.pos = 1
  end

  # New/changed pixel arrays get uploaded to the GPU before we render
  #  anything. At that point, they can be scaled, rotated, and otherwise
  #  used like any other sprite.
  w = 100
  h = 100
  x = (1280 - w) / 2
  y = (720 - h) / 2
  args.outputs.background_color = [64, 0, 128]
  args.outputs.primitives << [x, y, w, h, :scanner, args.state.rotation].sprite
  args.state.rotation += 1

  args.outputs.primitives << args.gtk.current_framerate_primitives
end

