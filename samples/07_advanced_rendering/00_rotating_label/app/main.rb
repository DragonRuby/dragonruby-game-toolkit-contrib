def tick args
  # set the render target width and height to match the label
  args.outputs[:scene].w = 220
  args.outputs[:scene].h = 30


  # make the background transparent
  args.outputs[:scene].background_color = [255, 255, 255, 0]

  # set the blendmode of the label to 0 (no blending)
  # center it inside of the scene
  # set the vertical_alignment_enum to 1 (center)
  args.outputs[:scene].labels  << { x: 0,
                                    y: 15,
                                    text: "label in render target",
                                    blendmode_enum: 0,
                                    vertical_alignment_enum: 1 }

  # add a border to the render target
  args.outputs[:scene].borders << { x: 0,
                                    y: 0,
                                    w: args.outputs[:scene].w,
                                    h: args.outputs[:scene].h }

  # add the rendertarget to the main output as a sprite
  args.outputs.sprites << { x: 640 - args.outputs[:scene].w.half,
                            y: 360 - args.outputs[:scene].h.half,
                            w: args.outputs[:scene].w,
                            h: args.outputs[:scene].h,
                            angle: args.state.tick_count,
                            path: :scene }
end
