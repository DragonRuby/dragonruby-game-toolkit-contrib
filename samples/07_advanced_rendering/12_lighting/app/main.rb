def calc args
  args.state.swinging_light_sign     ||= 1
  args.state.swinging_light_start_at ||= 0
  args.state.swinging_light_duration ||= 300
  args.state.swinging_light_perc       = args.state
                                             .swinging_light_start_at
                                             .ease_spline_extended args.state.tick_count,
                                                                   args.state.swinging_light_duration,
                                                                   [
                                                                     [0.0, 1.0, 1.0, 1.0],
                                                                     [1.0, 1.0, 1.0, 0.0]
                                                                   ]
  args.state.max_swing_angle ||= 45

  if args.state.swinging_light_start_at.elapsed_time > args.state.swinging_light_duration
    args.state.swinging_light_start_at = args.state.tick_count
    args.state.swinging_light_sign *= -1
  end

  args.state.swinging_light_angle = 360 + ((args.state.max_swing_angle * args.state.swinging_light_perc) * args.state.swinging_light_sign)
end

def render args
  args.outputs.background_color = [0, 0, 0]

  # render scene
  args.outputs[:scene].sprites << { x:        0, y:   0, w: 1280, h: 720, path: :pixel }
  args.outputs[:scene].sprites << { x: 640 - 40, y: 100, w:   80, h:  80, path: 'sprites/square/blue.png' }
  args.outputs[:scene].sprites << { x: 640 - 40, y: 200, w:   80, h:  80, path: 'sprites/square/blue.png' }
  args.outputs[:scene].sprites << { x: 640 - 40, y: 300, w:   80, h:  80, path: 'sprites/square/blue.png' }
  args.outputs[:scene].sprites << { x: 640 - 40, y: 400, w:   80, h:  80, path: 'sprites/square/blue.png' }
  args.outputs[:scene].sprites << { x: 640 - 40, y: 500, w:   80, h:  80, path: 'sprites/square/blue.png' }

  # render light
  swinging_light_w = 1100
  args.outputs[:lights].background_color = [0, 0, 0, 0]
  args.outputs[:lights].sprites << { x: 640 - swinging_light_w.half,
                                     y: -1300,
                                     w: swinging_light_w,
                                     h: 3000,
                                     angle_anchor_x: 0.5,
                                     angle_anchor_y: 1.0,
                                     path: "sprites/lights/mask.png",
                                     angle: args.state.swinging_light_angle }

  args.outputs[:lights].sprites << { x: args.inputs.mouse.x - 400,
                                     y: args.inputs.mouse.y - 400,
                                     w: 800,
                                     h: 800,
                                     path: "sprites/lights/mask.png" }

  # merge unlighted scene with lights
  args.outputs[:lighted_scene].sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lights, blendmode_enum: 0 }
  args.outputs[:lighted_scene].sprites << { blendmode_enum: 2, x: 0, y: 0, w: 1280, h: 720, path: :scene }

  # output lighted scene to main canvas
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lighted_scene }

  # render lights and scene render_targets as a mini map
  args.outputs.debug  << { x: 16,      y: (16 + 90).from_top, w: 160, h: 90, r: 255, g: 255, b: 255 }.solid!
  args.outputs.debug  << { x: 16,      y: (16 + 90).from_top, w: 160, h: 90, path: :lights }
  args.outputs.debug  << { x: 16 + 80, y: (16 + 90 + 8).from_top, text: ":lights render_target", r: 255, g: 255, b: 255, size_enum: -3, alignment_enum: 1 }

  args.outputs.debug  << { x: 16 + 160 + 16,      y: (16 + 90).from_top, w: 160, h: 90, r: 255, g: 255, b: 255 }.solid!
  args.outputs.debug  << { x: 16 + 160 + 16,      y: (16 + 90).from_top, w: 160, h: 90, path: :scene }
  args.outputs.debug  << { x: 16 + 160 + 16 + 80, y: (16 + 90 + 8).from_top, text: ":scene render_target", r: 255, g: 255, b: 255, size_enum: -3, alignment_enum: 1 }
end

def tick args
  render args
  calc args
end

$gtk.reset
