def tick args
  args.state.x ||= 500
  args.state.y ||= 350
  args.state.xinc ||= 7
  args.state.yinc ||= 7
  args.state.bgcolor ||= 1
  args.state.bginc ||= 1

  # clear the render target on the first tick, and then never again. Draw
  #  another box to it every tick, accumulating over time.
  clear_target = (args.state.tick_count == 0) || (args.inputs.keyboard.key_down.space)
  args.render_target(:accumulation).background_color = [ 0, 0, 0, 0 ];
  args.render_target(:accumulation).clear_before_render = clear_target
  args.render_target(:accumulation).solids << [args.state.x, args.state.y, 25, 25, 255, 0, 0, 255];
  args.state.x += args.state.xinc
  args.state.y += args.state.yinc
  args.state.bgcolor += args.state.bginc

  # animation upkeep...change where we draw the next box and what color the
  #  window background will be.
  if args.state.xinc > 0 && args.state.x >= 1280
    args.state.xinc = -7
  elsif args.state.xinc < 0 && args.state.x < 0
    args.state.xinc = 7
  end

  if args.state.yinc > 0 && args.state.y >= 720
    args.state.yinc = -7
  elsif args.state.yinc < 0 && args.state.y < 0
    args.state.yinc = 7
  end

  if args.state.bginc > 0 && args.state.bgcolor >= 255
    args.state.bginc = -1
  elsif args.state.bginc < 0 && args.state.bgcolor <= 0
    args.state.bginc = 1
  end

  # clear the screen to a shade of blue and draw the render target, which
  #  is not clearing every frame, on top of it. Note that you can NOT opt to
  #  skip clearing the screen, only render targets. The screen clears every
  #  frame; double-buffering would prevent correct updates between frames.
  args.outputs.background_color = [ 0, 0, args.state.bgcolor, 255 ]
  args.outputs.sprites << [ 0, 0, 1280, 720, :accumulation ]
end

$gtk.reset
