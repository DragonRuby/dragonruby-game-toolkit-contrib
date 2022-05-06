def tick args
  defaults args
  render args
  input args
  calc args
end

def defaults args
  args.state.player.x      ||= args.grid.w.half
  args.state.player.y      ||= 0
  args.state.player.size   ||= 100
  args.state.player.dy     ||= 0
  args.state.player.action ||= :jumping
  args.state.jump.power           = 20
  args.state.jump.increase_frames = 10
  args.state.jump.increase_power  = 1
  args.state.gravity              = -1
end

def render args
  args.outputs.sprites << {
    x: args.state.player.x -
       args.state.player.size.half,
    y: args.state.player.y,
    w: args.state.player.size,
    h: args.state.player.size,
    path: 'sprites/square/red.png'
  }
end

def input args
  if args.inputs.keyboard.key_down.space
    if args.state.player.action == :standing
      args.state.player.action = :jumping
      args.state.player.dy = args.state.jump.power

      # record when the action took place
      current_frame = args.state.tick_count
      args.state.player.action_at = current_frame
    end
  end

  # if the space bar is being held
  if args.inputs.keyboard.key_held.space
    # is the player jumping
    is_jumping = args.state.player.action == :jumping

    # when was the jump performed
    time_of_jump = args.state.player.action_at

    # how much time has passed since the jump
    jump_elapsed_time = time_of_jump.elapsed_time

    # how much time is allowed for increasing power
    time_allowed = args.state.jump.increase_frames

    # if the player is jumping
    # and the elapsed time is less than
    # the allowed time
    if is_jumping && jump_elapsed_time < time_allowed
       # increase the dy by the increase power
       power_to_add = args.state.jump.increase_power
       args.state.player.dy += power_to_add
    end
  end
end

def calc args
  if args.state.player.action == :jumping
    args.state.player.y  += args.state.player.dy
    args.state.player.dy += args.state.gravity
  end

  if args.state.player.y < 0
    args.state.player.y      = 0
    args.state.player.action = :standing
  end
end
