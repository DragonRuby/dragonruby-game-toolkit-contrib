def boot args
  GTK.dlopen "ext"
end

def tick args
  args.state.mode ||= :stopped

  if args.inputs.keyboard.key_down.enter
    if args.state.mode == :stopped
      args.state.mode = :running
      Worker.start_printing
    else
      args.state.mode = :stopped
      Worker.stop_printing
    end
  end

  args.outputs.labels << {
    x: 640,
    y: 680,
    text: "Press Enter to start/stop printing",
    anchor_x: 0.5,
    anchor_y: 0.5,
  }

  args.outputs.labels << {
    x: 640,
    y: 360,
    text: "Printing is #{args.state.mode}",
    anchor_x: 0.5,
    anchor_y: 0.5,
  }
end
