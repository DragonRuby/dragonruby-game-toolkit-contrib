$gtk.ffi_misc.gtk_dlopen("ext")
include FFI::CExt

def tick args
  args.state.rotation ||= 0

  update_scanner_texture   # this calls into a C extension!

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

