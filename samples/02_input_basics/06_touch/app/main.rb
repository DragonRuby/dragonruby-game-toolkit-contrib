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
    args.outputs.primitives << { x: 640, y: 650, text: "Finger #1 is touching at (#{args.inputs.finger_one.x}, #{args.inputs.finger_one.y}).",
                                 size_enum: 5, alignment_enum: 1, r: 255, g: 255, b: 255 }.label!
  end
  if !args.inputs.finger_two.nil?
    args.outputs.primitives << { x: 640, y: 600, text: "Finger #2 is touching at (#{args.inputs.finger_two.x}, #{args.inputs.finger_two.y}).",
                                 size_enum: 5, alignment_enum: 1, r: 255, g: 255, b: 255 }.label!
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
    args.outputs.primitives << { x: v.x - (size / 2), y: v.y + (size / 2), w: size, h: size, r: r, g: g, b: b, a: 255 }.solid!
    args.outputs.primitives << { x: v.x, y: v.y + size, text: k.to_s, alignment_enum: 1 }.label!
  }
end
