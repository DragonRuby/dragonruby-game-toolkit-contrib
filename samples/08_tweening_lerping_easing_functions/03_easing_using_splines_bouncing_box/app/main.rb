def tick args
  args.state.box ||= {
    x: 640,
    y: 360,
    w: 80,
    h: 80,
    path: :solid,
    r: 0,
    g: 80,
    b: 80,
    anchor_x: 0.5,
    anchor_y: 0.0,
    bounce_at: 0,
    bounce_duration: 30,
    bounce_spline: [
      [0.0, 0.0, 0.66, 1.0],
      [1.0, 0.33, 0.0,  0.0]
    ]
  }

  calc_bounce args.state.box
  args.outputs.sprites << bounce_prefab(args.state.box)
end

def calc_bounce box
  if box.bounce_at.elapsed_time == box.bounce_duration
    box.bounce_at = Kernel.tick_count
    puts "bounce complete"
  end
end

def bounce_prefab box
  perc = Easing.spline box.bounce_at,
                       Kernel.tick_count,
                       box.bounce_duration,
                       box.bounce_spline

  box.merge(w: box.h + 20 * perc,
            h: box.w - 40 * perc)
end

GTK.reset
