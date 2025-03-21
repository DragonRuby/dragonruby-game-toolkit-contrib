def tick args
  # create a tick count variant called clock
  # so I can manually control "tick_count"
  args.state.clock ||= 0

  # calc for frame by frame stepping
  calc_debug args

  # conditional calc of game
  calc_game args

  # always render game
  render_game args

  # increment clock
  if args.state.frame_by_frame
    if args.state.increment_frame > 0
      args.state.clock += 1
    end
  else
    args.state.clock += 1
  end
end

def calc_debug args
  # create an increment_frame counter for frame by frame
  # stepping
  args.state.increment_frame ||= 0
  args.state.increment_frame  -= 1

  # press l to increment by 30 frames or if any key is pressed
  if args.inputs.keyboard.key_down.l || args.inputs.keyboard.key_down.truthy_keys.length > 0
    args.state.increment_frame = 30
  end

  # enable disable frame by frame mode
  if args.inputs.keyboard.key_down.p
    if args.state.frame_by_frame == true
      args.state.frame_by_frame = false
    else
      args.state.frame_by_frame = true
      args.state.increment_frame = 0
    end
  end

  # press k to increment by one frame
  if args.inputs.keyboard.key_down.k
    args.state.increment_frame = 1
  end
end

def render_game args
  args.outputs.sprites << args.state.player
end

def calc_game args
  return if args.state.frame_by_frame && args.state.increment_frame < 0

  args.state.player ||= {
    x: 0,
    y: 360,
    w: 40,
    h: 40,
    anchor_x: 0.5,
    anchor_y: 0.5,
    path: :pixel,
    r: 0, g: 0, b: 255
  }

  args.state.player.x += 10
  args.state.player.y += args.inputs.up_down * 10

  if args.state.player.x > 1280
    args.state.player.x = 0
  end

  if args.state.player.y > 720
    args.state.player.y = 0
  elsif args.state.player.y < 0
    args.state.player.y = 720
  end
end

GTK.reset
