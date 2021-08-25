=begin

APIs listing that haven't been encountered in a previous sample apps:

- args.inputs.keyboard.key_up.KEY: The value of the properties will be set
  to the frame  that the key_up event occurred (the frame correlates
  to args.state.tick_count). Otherwise the value will be nil. For a
  full listing of keys, take a look at mygame/documentation/06-keyboard.md.
- args.state.PROPERTY: The state property on args is a dynamic
  structure. You can define ANY property here with ANY type of
  arbitrary nesting. Properties defined on args.state will be retained
  across frames. If you attempt access a property that doesn't exist
  on args.state, it will simply return nil (no exception will be thrown).

=end

# Along with outputs, inputs are also an essential part of video game development
# DragonRuby can take input from keyboards, mouse, and controllers.
# This sample app will cover keyboard input.

# args.inputs.keyboard.key_up.a will check to see if the a key has been pressed
# This will work with the other keys as well


def tick args
  tick_instructions args, "Sample app shows how keyboard events are registered and accessed.", 360
  # Notice how small_font accounts for all the remaining parameters
  args.outputs.labels << { x: 460, y: row_to_px(args, 0), text: "Current game time: #{args.state.tick_count}", size_enum: -1 }
  args.outputs.labels << { x: 460, y: row_to_px(args, 2), text: "Keyboard input: args.inputs.keyboard.key_up.h", size_enum: -1 }
  args.outputs.labels << { x: 460, y: row_to_px(args, 3), text: "Press \"h\" on the keyboard.", size_enum: -1 }

  # Input on a specifc key can be found through args.inputs.keyboard.key_up followed by the key
  if args.inputs.keyboard.key_up.h
    args.state.h_pressed_at = args.state.tick_count
  end

  # This code simplifies to if args.state.h_pressed_at has not been initialized, set it to false
  args.state.h_pressed_at ||= false

  if args.state.h_pressed_at
    args.outputs.labels << { x: 460, y: row_to_px(args, 4), text: "\"h\" was pressed at time: #{args.state.h_pressed_at}", size_enum: -1 }
  else
    args.outputs.labels << { x: 460, y: row_to_px(args, 4), text: "\"h\" has never been pressed.", size_enum: -1 }
  end

  tick_help_text args
end

def row_to_px args, row_number, y_offset = 20
  # This takes a row_number and converts it to pixels DragonRuby understands.
  # Row 0 starts 5 units below the top of the grid
  # Each row afterward is 20 units lower
  args.grid.top - 5 - (y_offset * row_number)
end

# Don't worry about understanding the code within this method just yet.
# This method shows you the help text within the game.
def tick_help_text args
  return unless args.state.h_pressed_at

  args.state.key_value_history      ||= {}
  args.state.key_down_value_history ||= {}
  args.state.key_held_value_history ||= {}
  args.state.key_up_value_history   ||= {}

  if (args.inputs.keyboard.key_down.truthy_keys.length > 0 ||
      args.inputs.keyboard.key_held.truthy_keys.length > 0 ||
      args.inputs.keyboard.key_up.truthy_keys.length > 0)
    args.state.help_available = true
    args.state.no_activity_debounce = nil
  else
    args.state.no_activity_debounce ||= 5.seconds
    args.state.no_activity_debounce -= 1
    if args.state.no_activity_debounce <= 0
      args.state.help_available = false
      args.state.key_value_history        = {}
      args.state.key_down_value_history   = {}
      args.state.key_held_value_history   = {}
      args.state.key_up_value_history     = {}
    end
  end

  args.outputs.labels << { x: 10, y: row_to_px(args, 6), text: "This is the api for the keys you've pressed:", size_enum: -1, r: 180 }

  if !args.state.help_available
    args.outputs.labels << [10, row_to_px(args, 7),  "Press a key and I'll show code to access the key and what value will be returned if you used the code.", small_font]
    return
  end

  args.outputs.labels << { x: 10 , y: row_to_px(args, 7), text: "args.inputs.keyboard",          size_enum: -2 }
  args.outputs.labels << { x: 330, y: row_to_px(args, 7), text: "args.inputs.keyboard.key_down", size_enum: -2 }
  args.outputs.labels << { x: 650, y: row_to_px(args, 7), text: "args.inputs.keyboard.key_held", size_enum: -2 }
  args.outputs.labels << { x: 990, y: row_to_px(args, 7), text: "args.inputs.keyboard.key_up",   size_enum: -2 }

  fill_history args, :key_value_history,      :down_or_held, nil
  fill_history args, :key_down_value_history, :down,        :key_down
  fill_history args, :key_held_value_history, :held,        :key_held
  fill_history args, :key_up_value_history,   :up,          :key_up

  render_help_labels args, :key_value_history,      :down_or_held, nil,      10
  render_help_labels args, :key_down_value_history, :down,        :key_down, 330
  render_help_labels args, :key_held_value_history, :held,        :key_held, 650
  render_help_labels args, :key_up_value_history,   :up,          :key_up,   990
end

def fill_history args, history_key, state_key, keyboard_method
  fill_single_history args, history_key, state_key, keyboard_method, :raw_key
  fill_single_history args, history_key, state_key, keyboard_method, :char
  args.inputs.keyboard.keys[state_key].each do |key_name|
    fill_single_history args, history_key, state_key, keyboard_method, key_name
  end
end

def fill_single_history args, history_key, state_key, keyboard_method, key_name
  current_value = args.inputs.keyboard.send(key_name)
  if keyboard_method
    current_value = args.inputs.keyboard.send(keyboard_method).send(key_name)
  end
  args.state.as_hash[history_key][key_name] ||= []
  args.state.as_hash[history_key][key_name] << current_value
  args.state.as_hash[history_key][key_name] = args.state.as_hash[history_key][key_name].reverse.uniq.take(3).reverse
end

def render_help_labels args, history_key, state_key, keyboard_method, x
  idx = 8
  args.outputs.labels << args.state
                           .as_hash[history_key]
                           .keys
                           .reverse
                           .map
                           .with_index do |k, i|
    v = args.state.as_hash[history_key][k]
    current_value = args.inputs.keyboard.send(k)
    if keyboard_method
      current_value = args.inputs.keyboard.send(keyboard_method).send(k)
    end
    idx += 2
    [
      { x: x, y: row_to_px(args, idx + 0, 16), text: "    .#{k} is #{current_value || "nil"}", size_enum: -2 },
      { x: x, y: row_to_px(args, idx + 1, 16), text: "       was #{v}", size_enum: -2 }
    ]
  end
end


def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << { x: 0,   y: y - 50, w: 1280, h: 60 }.solid!
  args.outputs.debug << { x: 640, y: y,      text: text,
                          size_enum: 1, alignment_enum: 1, r: 255, g: 255, b: 255 }.label!
  args.outputs.debug << { x: 640, y: y - 25, text: "(click to dismiss instructions)",
                          size_enum: -2, alignment_enum: 1, r: 255, g: 255, b: 255 }.label!
end
