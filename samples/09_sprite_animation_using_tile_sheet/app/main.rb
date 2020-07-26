def tick args
  args.state.player.x ||= 100
  args.state.player.y ||= 100
  args.state.player.w ||= 64
  args.state.player.h ||= 64
  args.state.player.direction ||= 1

  args.state.player.is_moving = false

  # get the keyboard input and set player properties
  if args.inputs.keyboard.right
    args.state.player.x += 3
    args.state.player.direction = 1
    args.state.player.started_running_at ||= args.state.tick_count
  elsif args.inputs.keyboard.left
    args.state.player.x -= 3
    args.state.player.direction = -1
    args.state.player.started_running_at ||= args.state.tick_count
  end

  if args.inputs.keyboard.up
    args.state.player.y += 1
    args.state.player.started_running_at ||= args.state.tick_count
  elsif args.inputs.keyboard.down
    args.state.player.y -= 1
    args.state.player.started_running_at ||= args.state.tick_count
  end

  # if no arrow keys are being pressed, set the player as not moving
  if !args.inputs.keyboard.directional_vector
    args.state.player.started_running_at = nil
  end

  # wrap player around the stage
  if args.state.player.x > 1280
    args.state.player.x = -64
    args.state.player.started_running_at ||= args.state.tick_count
  elsif args.state.player.x < -64
    args.state.player.x = 1280
    args.state.player.started_running_at ||= args.state.tick_count
  end

  if args.state.player.y > 720
    args.state.player.y = -64
    args.state.player.started_running_at ||= args.state.tick_count
  elsif args.state.player.y < -64
    args.state.player.y = 720
    args.state.player.started_running_at ||= args.state.tick_count
  end

  # render player as standing or running
  if args.state.player.started_running_at
    args.outputs.sprites << running_sprite(args)
  else
    args.outputs.sprites << standing_sprite(args)
  end
  args.outputs.labels << [30, 700, "Use arrow keys to move around."]
end

def standing_sprite args
  {
    x: args.state.player.x,
    y: args.state.player.y,
    w: args.state.player.w,
    h: args.state.player.h,
    path: "sprites/horizontal-stand.png",
    flip_horizontally: args.state.player.direction > 0
  }
end

def running_sprite args
  if !args.state.player.started_running_at
    tile_index = 0
  else
    how_many_frames_in_sprite_sheet = 6
    how_many_ticks_to_hold_each_frame = 3
    should_the_index_repeat = true
    tile_index = args.state
                     .player
                     .started_running_at
                     .frame_index(how_many_frames_in_sprite_sheet,
                                  how_many_ticks_to_hold_each_frame,
                                  should_the_index_repeat)
  end

  {
    x: args.state.player.x,
    y: args.state.player.y,
    w: args.state.player.w,
    h: args.state.player.h,
    path: 'sprites/horizontal-run.png',
    tile_x: 0 + (tile_index * args.state.player.w),
    tile_y: 0,
    tile_w: args.state.player.w,
    tile_h: args.state.player.h,
    flip_horizontally: args.state.player.direction > 0,
  }
end
