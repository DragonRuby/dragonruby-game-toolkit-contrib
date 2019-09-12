# Mouse

Determining current position of mouse:

```
args.inputs.mouse.x
args.inputs.mouse.y
```

Determining if the mouse has been clicked, and it's position. Note:
`click` and `down` are aliases for each other.

```
if args.inputs.mouse.click
  puts "click: #{args.inputs.mouse.click}"
  puts "x: #{args.inputs.mouse.click.point.x}"
  puts "y: #{args.inputs.mouse.click.point.y}"
end
```

Determining if the mouse button has been released:

```
if args.inputs.mouse.up
  puts "up: #{args.inputs.mouse.up}"
  puts "x: #{args.inputs.mouse.up.point.x}"
  puts "y: #{args.inputs.mouse.up.point.y}"
end
```

Determine which mouse button(s) have been clicked (also works for up):
```
if args.inputs.mouse.click
  puts "left: #{args.inputs.mouse.button_left}"
  puts "middle: #{args.inputs.mouse.button_middle}"
  puts "right: #{args.inputs.mouse.button_right}"
  puts "x1: #{args.inputs.mouse.button_x1}"
  puts "x2: #{args.inputs.mouse.button_x2}"
end
```

Determine if the mouse wheel is being used and its values for this tick:
```
if args.inputs.mouse.wheel
  puts "The wheel moved #{args.inputs.mouse.wheel.x} left/right"
  puts "The wheel moved #{args.inputs.mouse.wheel.y} up/down"
end
```
