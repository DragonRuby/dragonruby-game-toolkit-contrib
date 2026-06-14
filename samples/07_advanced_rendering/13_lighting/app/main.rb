def boot args
  args.state = { }
end

def tick args
  args.outputs.background_color = [0, 0, 0]

  # render scene
  args.outputs[:scene].primitives << { x:        0, y:   0, w: 1280, h: 720, path: :pixel }
  args.outputs[:scene].primitives << { x: 640 - 40, y: 100, w:   80, h:  80, path: 'sprites/square/blue.png' }
  args.outputs[:scene].primitives << { x: 640 - 40, y: 200, w:   80, h:  80, path: 'sprites/square/blue.png' }
  args.outputs[:scene].primitives << { x: 640 - 40, y: 300, w:   80, h:  80, path: 'sprites/square/blue.png' }
  args.outputs[:scene].primitives << { x: 640 - 40, y: 400, w:   80, h:  80, path: 'sprites/square/blue.png' }
  args.outputs[:scene].primitives << { x: 640 - 40, y: 500, w:   80, h:  80, path: 'sprites/square/blue.png' }

  # render swinging light
  swing_angle = swinging_light_angle(args)
  args.outputs[:lights].background_color = [0, 0, 0, 0]
  args.outputs[:lights].primitives << { x: 640 - 1100 / 2,
                                        y: -1300,
                                        w: 1100,
                                        h: 3000,
                                        angle_anchor_x: 0.5,
                                        angle_anchor_y: 1.0,
                                        path: "sprites/lights/mask.png",
                                        angle: swing_angle }

  # render spotlight over mouse that expands and contracts
  spotlight_size = 800 * Math.sin(Kernel.tick_count.fdiv(60) % 360).abs
  args.outputs[:lights].primitives << { x: args.inputs.mouse.x,
                                        y: args.inputs.mouse.y,
                                        w: spotlight_size,
                                        h: spotlight_size,
                                        anchor_x: 0.5,
                                        anchor_y: 0.5,
                                        path: "sprites/lights/mask.png" }

  # merge unlighted scene with lights
  # blendmode of 0 is no blending
  args.outputs[:lighted_scene].primitives << { x: 0, y: 0, w: 1280, h: 720, path: :lights, blendmode: 0 }
  # blendmode of 2 is additive blend
  args.outputs[:lighted_scene].primitives << { blendmode: 2, x: 0, y: 0, w: 1280, h: 720, path: :scene }

  # output lighted scene to main canvas
  args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :lighted_scene }

  # render lights and scene render_targets as a mini map
  args.outputs.primitives  << { x: 16,      y: 600, w: 160, h: 90, r: 255, g: 255, b: 255, path: :solid }
  args.outputs.primitives  << { x: 16,      y: 600, w: 160, h: 90, path: :lights }
  args.outputs.primitives  << { x: 16 + 80, y: 592, text: ":lights render_target", r: 255, g: 255, b: 255, size_enum: -3, alignment_enum: 1 }

  args.outputs.primitives  << { x: 16 + 160 + 16,      y: 600, w: 160, h: 90, r: 255, g: 255, b: 255, path: :solid }
  args.outputs.primitives  << { x: 16 + 160 + 16,      y: 600, w: 160, h: 90, path: :scene }
  args.outputs.primitives  << { x: 16 + 160 + 16 + 80, y: 592, text: ":scene render_target", r: 255, g: 255, b: 255, size_enum: -3, alignment_enum: 1 }

  args.outputs.primitives << { x: 640,
                               y: 720 - 32,
                               text: "swing angle: #{swinging_light_angle(args).to_sf}",
                               anchor_x: 0.5,
                               anchor_y: 0.5,
                               r: 128,
                               g: 128,
                               b: 128 }
end

def swinging_light_angle args
  # The duration for one full cycle of the swinging light.
  duration = 600

  # Calculate the start time by dividing the current tick count by the duration
  # and multiplying it by duration to align with the nearest duration start.
  start_at = Kernel.tick_count.idiv(duration) * duration

  # Calculate the swinging light percentage using a spline easing function.
  swinging_light_perc = Easing.spline(start_at,
                                      Kernel.tick_count,
                                      duration,
                                      [ # spline represents a movement of the percentage from:
                                        [-1.0, -1.0, -1.0, 0.0], # -1 to 0 (smooth start),
                                        [0.0, 1.0, 1.0, 1.0],    # 0 to 1 (smooth stop),
                                        [1.0, 1.0, 1.0, 0.0],    # 1 to 0 (smooth start),
                                        [0.0, -1.0, -1.0, -1.0], # 0 to -1 (smooth stop)
                                      ])

  # Return the angle of the swinging light based on the percentage calculated.
  # 45 degrees either going left or right
  45 * swinging_light_perc
end


DR.reset
