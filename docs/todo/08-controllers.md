# Controllers

There are two controllers you have access to:

```
args.inputs.controller_one
args.inputs.controller_two
```

Determining if a key was down:

```
if args.inputs.controller_one.key_down.a
  puts 'The key was in the down state'
end
```

Determining if a key is being held:

```
if args.inputs.controller_one.key_held.a
  puts 'The key is being held'
end
```

Determining if a key is released:

```
if args.inputs.controller_one.key_up.a
  puts 'The key is being held'
end
```

# Truthy Keys

You can access all triggered keys through `thruthy_keys` on `keyboard`, `controller_one`, and `controller_two`.

This is how you would write all keys to a file. The game must be in the foreground and have focus for this data
to be recorded.

```
def tick args
    [
    [args.inputs.keyboard,       :keyboard],
    [args.inputs.controller_one, :controller_one],
    [args.inputs.controller_two, :controller_two]
  ].each do |input, name|
    if input.key_down.truthy_keys.length > 0
      args.gtk.write_file("app/#{name}_key_down_#{args.state.tick_count}", input.key_down.truthy_keys.to_s)
    end
  end
end
```

# List of keys:

```
args.inputs.controller_one.key_held.up
args.inputs.controller_one.key_held.down
args.inputs.controller_one.key_held.left
args.inputs.controller_one.key_held.right
args.inputs.controller_one.key_held.a
args.inputs.controller_one.key_held.b
args.inputs.controller_one.x
args.inputs.controller_one.y
args.inputs.controller_one.key_held.l1
args.inputs.controller_one.key_held.r1
args.inputs.controller_one.key_held.l2
args.inputs.controller_one.key_held.r2
args.inputs.controller_one.key_held.l3
args.inputs.controller_one.key_held.r3
args.inputs.controller_one.key_held.start
args.inputs.controller_one.key_held.select
args.inputs.controller_one.key_held.directional_up
args.inputs.controller_one.key_held.directional_down
args.inputs.controller_one.key_held.directional_left
args.inputs.controller_one.key_held.directional_right
args.inputs.controller_one.left_analog_x_raw,
args.inputs.controller_one.left_analog_y_raw,
args.inputs.controller_one.left_analog_x_perc,
args.inputs.controller_one.left_analog_y_perc,
args.inputs.controller_one.right_analog_x_raw,
args.inputs.controller_one.right_analog_y_raw,
args.inputs.controller_one.right_analog_x_perc,
args.inputs.controller_one.right_analog_y_perc
```
