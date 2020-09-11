def tick args
  args.state.duration = 10.seconds
  args.state.spline = [
    [0.0, 0.33, 0.66, 1.0],
    [1.0, 1.0,  1.0,  1.0],
    [1.0, 0.66, 0.33, 0.0],
  ]

  args.state.simulation_tick = args.state.tick_count % args.state.duration
  progress = 0.ease_spline_extended args.state.simulation_tick, args.state.duration, args.state.spline
  args.outputs.borders << args.grid.rect
  args.outputs.solids << [20 + 1240 * progress,
                          20 +  680 * progress,
                          20, 20].anchor_rect(0.5, 0.5)
  args.outputs.labels << [10,
                          710,
                          "perc: #{"%.2f" % (args.state.simulation_tick / args.state.duration)} t: #{args.state.simulation_tick}"]
end
