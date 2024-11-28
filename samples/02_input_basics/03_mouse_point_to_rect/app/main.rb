=begin
- Example usage of Hash#inside_rect? to determine if a mouse click happened
  inside of a box.
  ```
  rect_1 = { x: 100, y: 100, w:   1, h:   1 }
  rect_2 = { x:   0, y:   0, w: 500, h: 500 }
  result = rect_1.inside_rect? rect_2
  ```
=end
def tick args
  # initialize the rectangle
  args.state.box ||= { x: 785, y: 370, w: 50, h: 50, r: 0, g: 0, b: 170 }

  # store the mouse click and the frame the click occurred
  # and whether it was inside or outside the box
  if args.inputs.mouse.click
    args.state.last_mouse_click = args.inputs.mouse.click
    args.state.last_mouse_click_at = Kernel.tick_count
    if args.state.last_mouse_click.inside_rect? args.state.box
      args.state.was_inside_rect = true
    else
      args.state.was_inside_rect = false
    end
  end

  # render
  args.outputs.labels << { x: 640, y: 700, anchor_x: 0.5, anchor_y: 0.5, text: "Sample app shows how to determine if a click happened inside a rectangle." }
  args.outputs.labels << { x: 340, y: 420, text:  "Click inside (or outside) the blue box ---->" }

  args.outputs.borders << args.state.box

  if args.state.last_mouse_click
    if args.state.was_inside_rect
      args.outputs.labels << { x: 810,
                               y: 340,
                               anchor_x: 0.5,
                               anchor_y: 0.5,
                               text: "Mouse click happened *inside* the box [frame #{args.state.last_mouse_click_at}]." }
    else
      args.outputs.labels << { x: 810,
                               y: 340,
                               anchor_x: 0.5,
                               anchor_y: 0.5,
                               text: "Mouse click happened *outside* the box [frame #{args.state.last_mouse_click_at}]." }
    end
  else
    args.outputs.labels << { x: 810,
                             y: 340,
                             anchor_x: 0.5,
                             anchor_y: 0.5,
                             text: "Waiting for mouse click..." }
  end
end
