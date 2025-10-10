def tick args
  baseline_label_w = 440
  baseline_label_h = 60

  # define a render target that contains a label with a background
  # this is a baseline texture and is done only on startup
  # (the render target will be cached and can be reused)
  if Kernel.tick_count == 0
    # set the render target width and height to match the label
    args.outputs[:baseline_label].w = baseline_label_w
    args.outputs[:baseline_label].h = baseline_label_h

    # render the label within the baseline_label render target
    args.outputs[:baseline_label].labels << { x: baseline_label_w / 2,
                                              y: baseline_label_h / 2,
                                              text: "label in render target",
                                              size_px: 40,
                                              r: 255, g: 255, b: 255,
                                              anchor_x: 0.5,
                                              anchor_y: 0.5 }

    # render a solid background for the label
    args.outputs[:baseline_label].sprites << { x: 0,
                                               y: 0,
                                               w: baseline_label_w,
                                               h: baseline_label_h,
                                               path: :solid,
                                               r: 30,
                                               g: 30,
                                               b: 30 }
  end

  # compute the scaling of the label based on the tick count for animation
  label_scale_percentage = Math.sin((Kernel.tick_count % 360).to_radians)
  label_scale_w = baseline_label_w + label_scale_percentage * baseline_label_w / 2
  label_scale_h = baseline_label_h + label_scale_percentage * baseline_label_h / 2

  # create a render target representing the scaled label for this frame
  args.outputs[:scaled_label].w = label_scale_w
  args.outputs[:scaled_label].h = label_scale_h
  args.outputs[:scaled_label] << { x: 0,
                                   y: 0,
                                   w: label_scale_w,
                                   h: label_scale_h,
                                   path: :baseline_label }

  # add the scaled_label ts to outputs
  args.outputs.sprites << { x: 640,
                            y: 360,
                            w: label_scale_w,
                            h: label_scale_h,
                            anchor_x: 0.5,
                            anchor_y: 0.5,
                            angle: Kernel.tick_count,
                            path: :scaled_label }
end
