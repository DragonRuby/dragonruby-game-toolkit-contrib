def tick args
  args.state.output_cycle ||= :top_level

  args.outputs.background_color = [0, 0, 0]
  args.outputs.solids << [0, 0, 1280, 720, 255, 255, 255]
  if args.state.output_cycle == :top_level
    render_main args
  else
    render_scene args
  end

  # cycle between labels in top level args.outputs
  # and labels inside of render target
  if args.state.tick_count.zmod? 300
    if args.state.output_cycle == :top_level
      args.state.output_cycle = :render_target
    else
      args.state.output_cycle = :top_level
    end
  end
end

def render_main args
  # center line
  args.outputs.lines   << { x:   0, y: 360, x2: 1280, y2: 360 }
  args.outputs.lines   << { x: 640, y:   0, x2:  640, y2: 720 }

  # horizontal ruler
  args.outputs.lines   << { x:   0, y: 370, x2: 1280, y2: 370 }
  args.outputs.lines   << { x:   0, y: 351, x2: 1280, y2: 351 }

  # vertical ruler
  args.outputs.lines   << { x:  575, y: 0, x2: 575, y2: 720 }
  args.outputs.lines   << { x:  701, y: 0, x2: 701, y2: 720 }

  args.outputs.sprites << { x: 640 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square/blue.png", a: 128 }
  args.outputs.labels  << { x:  640, y:   0, text: "(bottom)",  alignment_enum: 1, vertical_alignment_enum: 0 }
  args.outputs.labels  << { x:  640, y: 425, text: "top_level", alignment_enum: 1, vertical_alignment_enum: 1 }
  args.outputs.labels  << { x:  640, y: 720, text: "(top)",     alignment_enum: 1, vertical_alignment_enum: 2 }
  args.outputs.labels  << { x:    0, y: 360, text: "(left)",    alignment_enum: 0, vertical_alignment_enum: 1 }
  args.outputs.labels  << { x: 1280, y: 360, text: "(right)",   alignment_enum: 2, vertical_alignment_enum: 1 }
end

def render_scene args
  args.outputs[:scene].background_color = [255, 255, 255, 0]

  # center line
  args.outputs[:scene].lines   << { x:   0, y: 360, x2: 1280, y2: 360 }
  args.outputs[:scene].lines   << { x: 640, y:   0, x2:  640, y2: 720 }

  # horizontal ruler
  args.outputs[:scene].lines   << { x:   0, y: 370, x2: 1280, y2: 370 }
  args.outputs[:scene].lines   << { x:   0, y: 351, x2: 1280, y2: 351 }

  # vertical ruler
  args.outputs[:scene].lines   << { x:  575, y: 0, x2: 575, y2: 720 }
  args.outputs[:scene].lines   << { x:  701, y: 0, x2: 701, y2: 720 }

  args.outputs[:scene].sprites << { x: 640 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square/blue.png", a: 128, blendmode_enum: 0 }
  args.outputs[:scene].labels  << { x:  640, y:   0, text: "(bottom)",      alignment_enum: 1, vertical_alignment_enum: 0, blendmode_enum: 0 }
  args.outputs[:scene].labels  << { x:  640, y: 425, text: "render target", alignment_enum: 1, vertical_alignment_enum: 1, blendmode_enum: 0 }
  args.outputs[:scene].labels  << { x:  640, y: 720, text: "(top)",         alignment_enum: 1, vertical_alignment_enum: 2, blendmode_enum: 0 }
  args.outputs[:scene].labels  << { x:    0, y: 360, text: "(left)",        alignment_enum: 0, vertical_alignment_enum: 1, blendmode_enum: 0 }
  args.outputs[:scene].labels  << { x: 1280, y: 360, text: "(right)",       alignment_enum: 2, vertical_alignment_enum: 1, blendmode_enum: 0 }

  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
end
