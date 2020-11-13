def tick args
  args.outputs.background_color = [ 0, 0, 0 ]
  args.outputs.primitives << [640, 700, "Touch your screen.", 5, 1, 255, 255, 255].label

  # If you don't want to get fancy, you can just look for finger_one
  #  (and _two, if you like), which are assigned in the order new touches hit
  #  the screen. If not nil, they are touching right now, and are just
  #  references to specific items in the args.input.touch hash.
  # If finger_one lifts off, it will become nil, but finger_two, if it was
  #  touching, remains until it also lifts off. When all fingers lift off, the
  #  the next new touch will be finger_one again, but until then, new touches
  #  don't fill in earlier slots.
  if !args.inputs.finger_one.nil?
    args.outputs.primitives << [640, 650, "Finger #1 is touching at (#{args.inputs.finger_one.x}, #{args.inputs.finger_one.y}).", 5, 1, 255, 255, 255].label
  end
  if !args.inputs.finger_two.nil?
    args.outputs.primitives << [640, 600, "Finger #2 is touching at (#{args.inputs.finger_two.x}, #{args.inputs.finger_two.y}).", 5, 1, 255, 255, 255].label
  end

  # Here's the more flexible interface: this will report as many simultaneous
  #  touches as the system can handle, but it's a little more effort to track
  #  them. Each item in the args.input.touch hash has a unique key (an
  #  incrementing integer) that exists until the finger lifts off. You can
  #  tell which order the touches happened globally by the key value, or
  #  by the touch[id].touch_order field, which resets to zero each time all
  #  touches have lifted.

  args.state.colors ||= [
    0xFF0000, 0x00FF00, 0x1010FF, 0xFFFF00, 0xFF00FF, 0x00FFFF, 0xFFFFFF
  ]

  size = 100
  args.inputs.touch.each { |k,v|
    color = args.state.colors[v.touch_order % 7]
    r = (color & 0xFF0000) >> 16
    g = (color & 0x00FF00) >> 8
    b = (color & 0x0000FF)
    args.outputs.primitives << [v.x - (size / 2), v.y + (size / 2), size, size, r, g, b, 255].solid
    args.outputs.primitives << [v.x, v.y + size, k.to_s, 0, 1, 0, 0, 0].label
  }
end

