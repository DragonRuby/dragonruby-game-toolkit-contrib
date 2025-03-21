def tick args
  # create three buttons
  args.state.button_1 ||= { x: 0, y: 640, w: 100, h: 50 }
  args.state.button_1_label ||= { x: 50,
                                  y: 665,
                                  text: "button 1",
                                  anchor_x: 0.5,
                                  anchor_y: 0.5 }

  args.state.button_2 ||= { x: 104, y: 640, w: 100, h: 50 }
  args.state.button_2_label ||= { x: 154,
                                  y: 665,
                                  text: "button 2",
                                  anchor_x: 0.5,
                                  anchor_y: 0.5 }

  args.state.button_3 ||= { x: 208, y: 640, w: 100, h: 50 }
  args.state.button_3_label ||= { x: 258,
                                  y: 665,
                                  text: "button 3",
                                  anchor_x: 0.5,
                                  anchor_y: 0.5 }

  # create a label
  args.state.label_hello_world ||= { x: 640,
                                     y: 360,
                                     text: "hello world",
                                     anchor_x: 0.5,
                                     anchor_y: 0.5 }

  args.outputs.borders << args.state.button_1
  args.outputs.labels  << args.state.button_1_label

  args.outputs.borders << args.state.button_2
  args.outputs.labels  << args.state.button_2_label

  args.outputs.borders << args.state.button_3
  args.outputs.labels  << args.state.button_3_label

  args.outputs.labels  << args.state.label_hello_world

  # args.outputs.a11y is cleared every tick, internally the key
  # of the dictionary value is used to reference the interactable element.
  # the key can be a symbol or a string (everything get's converted to strings
  # beind the scenes)

  # =======================================
  # from the Console run GTK.a11y_enable!
  # ctrl+r will disable a11y (or you can run GTK.a11y_disable! in the console)
  # =======================================

  # with the a11y emulation enabled, you can only use left arrow, right arrow, and enter
  # when you press enter, DR converts the location to a mouse click
  args.outputs.a11y[:button_1] = {
    a11y_text: "button 1",
    a11y_trait: :button,
    x: args.state.button_1.x,
    y: args.state.button_1.y,
    w: args.state.button_1.w,
    h: args.state.button_1.h
  }

  args.outputs.a11y[:button_2] = {
    a11y_text: "button 2",
    a11y_trait: :button,
    x: args.state.button_2.x,
    y: args.state.button_2.y,
    w: args.state.button_2.w,
    h: args.state.button_2.h
  }

  args.outputs.a11y[:button_3] = {
    a11y_text: "button 3",
    a11y_trait: :button,
    x: args.state.button_3.x,
    y: args.state.button_3.y,
    w: args.state.button_3.w,
    h: args.state.button_3.h
  }

  args.outputs.a11y[:label_hello] = {
    a11y_text: "hello world",
    a11y_trait: :label,
    x: args.state.label_hello_world.x,
    y: args.state.label_hello_world.y,
    anchor_x: 0.5,
    anchor_y: 0.5,
  }

  # flash a notification for each respective button
  if args.inputs.mouse.click && args.inputs.mouse.inside_rect?(args.state.button_1)
    GTK.notify_extended! message: "Button 1 clicked", a: 255
    # you can use a11y to speak information
    args.outputs.a11y["notify button clicked"] = {
      a11y_text: "button 1 clicked",
      a11y_trait: :notification
    }
  end

  if args.inputs.mouse.click && args.inputs.mouse.inside_rect?(args.state.button_2)
    GTK.notify_extended! message: "Button 2 clicked", a: 255
  end

  if args.inputs.mouse.click && args.inputs.mouse.inside_rect?(args.state.button_3)
    GTK.notify_extended! message: "Button 3 clicked", a: 255
    # you can also use a11y to redirect focus to another control
    args.outputs.a11y["notify button clicked"] = {
      a11y_trait: :notification,
      a11y_notification_target: :label_hello
    }
  end
end

GTK.reset
