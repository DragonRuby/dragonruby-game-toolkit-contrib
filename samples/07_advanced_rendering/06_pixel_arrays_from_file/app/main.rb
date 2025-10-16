def tick args
  args.state.rotation ||= 0

  # on load, get pixels from png and load it into a pixel array
  if Kernel.tick_count == 0
    pixel_array = GTK.get_pixels 'sprites/square/blue.png'
    args.pixel_array(:square).w = pixel_array.w
    args.pixel_array(:square).h = pixel_array.h
    args.pixel_array(:square).pixels = pixel_array.pixels
  end

  w = 100
  h = 100
  x = (1280 - w) / 2
  y = (720 - h) / 2
  args.outputs.background_color = [64, 0, 128]
  # render the pixel array by name
  args.outputs.primitives << { x: x, y: y, w: w, h: h, path: :square, angle: args.state.rotation }
  args.state.rotation += 1

  args.outputs.primitives << GTK.current_framerate_primitives
end

GTK.reset
