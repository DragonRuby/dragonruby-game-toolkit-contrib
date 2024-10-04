def tick args
  args.state.properties = [
    { name: "Top Level properties" },
    { name: "mouse.x", value: args.inputs.mouse.x },
    { name: "mouse.y", value: args.inputs.mouse.y },
    { name: "mouse.wheel", value: args.inputs.mouse.wheel },
    { name: "mouse.moved", value: args.inputs.mouse.moved },
    { name: "mouse.moved_at", value: args.inputs.mouse.moved_at },
    { name: "mouse.click", value: args.inputs.mouse.click },
    { name: "mouse.click_at", value: args.inputs.mouse.click_at },
    { name: "mouse.held", value: args.inputs.mouse.held },
    { name: "mouse.held_at", value: args.inputs.mouse.held_at },
    { name: "mouse.up", value: args.inputs.mouse.up },
    { name: "mouse.up_at", value: args.inputs.mouse.up_at },
    { name: "" },
    { name: "Keys" },
    { name: "mouse.key_down.left", value: args.inputs.mouse.key_down.left },
    { name: "mouse.key_held.left", value: args.inputs.mouse.key_held.left },
    { name: "mouse.key_up.left", value: args.inputs.mouse.key_up.left },
    { name: "mouse.key_down.right", value: args.inputs.mouse.key_down.right },
    { name: "mouse.key_held.right", value: args.inputs.mouse.key_held.right },
    { name: "mouse.key_up.right", value: args.inputs.mouse.key_up.right },
    { name: "mouse.button_bits.to_s(2)", value: args.inputs.mouse.button_bits.to_s(2) },
    { name: "mouse.button_left", value: args.inputs.mouse.button_left },
    { name: "mouse.button_right", value: args.inputs.mouse.button_right },
    { name: "" },
    { name: "Buttons" },
    { name: "mouse.button_bits", value: args.inputs.mouse.button_bits.to_s(2) },
    { name: "mouse.button_left", value: args.inputs.mouse.button_left },
    { name: "mouse.buttons.left.click", value: args.inputs.mouse.buttons.left.click },
    { name: "mouse.buttons.left.click_at", value: args.inputs.mouse.buttons.left.click_at },
    { name: "mouse.buttons.left.held", value: args.inputs.mouse.buttons.left.held },
    { name: "mouse.buttons.left.held_at", value: args.inputs.mouse.buttons.left.held_at },
    { name: "mouse.buttons.left.up", value: args.inputs.mouse.buttons.left.up },
    { name: "mouse.buttons.left.up_at", value: args.inputs.mouse.buttons.left.up_at },
    { name: "mouse.buttons.left.buffered_click", value: args.inputs.mouse.buttons.left.buffered_click },
    { name: "mouse.buttons.left.buffered_held", value: args.inputs.mouse.buttons.left.buffered_held },
    { name: "mouse.button_right", value: args.inputs.mouse.button_left },
    { name: "mouse.buttons.right.click", value: args.inputs.mouse.buttons.right.click },
    { name: "mouse.buttons.right.click_at", value: args.inputs.mouse.buttons.right.click_at },
    { name: "mouse.buttons.right.held", value: args.inputs.mouse.buttons.right.held },
    { name: "mouse.buttons.right.held_at", value: args.inputs.mouse.buttons.right.held_at },
    { name: "mouse.buttons.right.up", value: args.inputs.mouse.buttons.right.up },
    { name: "mouse.buttons.right.up_at", value: args.inputs.mouse.buttons.right.up_at },
    { name: "mouse.buttons.right.buffered_click", value: args.inputs.mouse.buttons.right.buffered_click },
    { name: "mouse.buttons.right.buffered_held", value: args.inputs.mouse.buttons.right.buffered_held },
  ]

  args.outputs.primitives << args.state.highlight_fx

  args.outputs.labels << args.state.properties.map_with_index do |property, i|
    text = if property.key?(:value)
             "#{property.name}: #{property.value.inspect}"
           else
             property.name
           end
    {
      x: 16,
      y: 720 - 8 - i * 16,
      text: text,
      size_px: 14
    }
  end
end
