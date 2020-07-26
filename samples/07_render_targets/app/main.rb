def tick args
  # args.outputs.render_targets are really really powerful.
  # They essentially allow you to create a sprite programmatically and cache the result.

  # Create a render_target of a :block and a :gradient on tick zero.
  if args.state.tick_count == 0
    args.render_target(:block).solids << [0, 0, 1280, 100]

    # The gradient is actually just a collection of black solids with increasing
    # opacities.
    args.render_target(:gradient).solids << 90.map_with_index do |x|
      50.map_with_index do |y|
        [x * 15, y * 15, 15, 15, 0, 0, 0, (x * 3).fdiv(255) * 255]
      end
    end
  end

  # Take the :block render_target and present it horizontally centered.
  # Use a subsection of the render_targetd specified by source_x,
  # source_y, source_w, source_h.
  args.outputs.sprites << { x: 0,
                            y: 310,
                            w: 1280,
                            h: 100,
                            path: :block,
                            source_x: 0,
                            source_y: 0,
                            source_w: 1280,
                            source_h: 100 }

  # After rendering :block, render gradient on top of :block.
  args.outputs.sprites << [0, 0, 1280, 720, :gradient]

  args.outputs.labels  << [1270, 710, args.gtk.current_framerate, 0, 2, 255, 255, 255]
  tick_instructions args, "Sample app shows how to use render_targets (programmatically create cached sprites)."
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end

$gtk.reset
