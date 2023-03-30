def tick args
  # every 4.5 seconds, swap between origin_bottom_left and origin_center
  args.state.origin_state ||= :bottom_left

  if args.state.tick_count.zmod? 270
    args.state.origin_state = if args.state.origin_state == :bottom_left
                                :center
                              else
                                :bottom_left
                              end
  end

  if args.state.origin_state == :bottom_left
    tick_origin_bottom_left args
  else
    tick_origin_center args
  end
end

def tick_origin_center args
  # set the coordinate system to origin_center
  args.grid.origin_center!
  args.outputs.labels <<  { x: 0, y: 100, text: "args.grid.origin_center! with sprite inside of a render target, centered at 0, 0", vertical_alignment_enum: 1, alignment_enum: 1 }

  # create a render target with a sprint in the center assuming the origin is center screen
  args.outputs[:scene].sprites << { x: -50, y: -50, w: 100, h: 100, path: 'sprites/square/blue.png' }
  args.outputs.sprites << { x: -640, y: -360, w: 1280, h: 720, path: :scene }
end

def tick_origin_bottom_left args
  args.grid.origin_bottom_left!
  args.outputs.labels <<  { x: 640, y: 360 + 100, text: "args.grid.origin_bottom_left! with sprite inside of a render target, centered at 640, 360", vertical_alignment_enum: 1, alignment_enum: 1 }

  # create a render target with a sprint in the center assuming the origin is bottom left
  args.outputs[:scene].sprites << { x: 640 - 50, y: 360 - 50, w: 100, h: 100, path: 'sprites/square/blue.png' }
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
end
