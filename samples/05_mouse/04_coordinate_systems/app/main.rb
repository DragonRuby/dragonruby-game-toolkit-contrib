=begin

 APIs listing that haven't been encountered in previous sample apps:

 - args.inputs.mouse.click.position: Coordinates of the mouse's position on the screen.
   Unlike args.inputs.mouse.click.point, the mouse does not need to be pressed down for
   position to know the mouse's coordinates.
   For more information about the mouse, go to mygame/documentation/07-mouse.md.

 Reminders:

 - args.inputs.mouse.click: This property will be set if the mouse was clicked.

 - args.inputs.mouse.click.point.(x|y): The x and y location of the mouse.

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

   In this sample app, string interpolation is used to show the current position of the mouse
   in a label.

 - args.outputs.labels: An array that generates a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGN, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

 - args.outputs.solids: An array that generates a solid.
   The parameters are [X, Y, WIDTH, HEIGHT, RED, GREEN, BLUE, ALPHA]
   For more information about solids, go to mygame/documentation/03-solids-and-borders.md.

 - args.outputs.lines: An array that generates a line.
   The parameters are [X, Y, X2, Y2, RED, GREEN, BLUE, ALPHA]
   For more information about lines, go to mygame/documentation/04-lines.md.

=end

# This sample app shows a coordinate system or grid. The user can move their mouse around the screen and the
# coordinates of their position on the screen will be displayed. Users can choose to view one quadrant or
# four quadrants by pressing the button.

def tick args

  # The addition and subtraction in the first two parameters of the label and solid
  # ensure that the outputs don't overlap each other. Try removing them and see what happens.
  pos = args.inputs.mouse.position # stores coordinates of mouse's position
  args.outputs.labels << [pos.x + 10, pos.y + 10, "#{pos}"] # outputs label of coordinates
  args.outputs.solids << [pos.x -  2, pos.y - 2, 5, 5] # outputs small blackk box placed where mouse is hovering

  button = [0, 0, 370, 50] # sets definition of toggle button
  args.outputs.borders << button # outputs button as border (not filled in)
  args.outputs.labels << [10, 35, "click here toggle coordinate system"] # label of button
  args.outputs.lines << [    0, -720,    0, 720] # vertical line dividing quadrants
  args.outputs.lines << [-1280,    0, 1280,   0] # horizontal line dividing quadrants

  if args.inputs.mouse.click # if the user clicks the mouse
    pos = args.inputs.mouse.click.point # pos's value is point where user clicked (coordinates)
    if pos.inside_rect? button # if the click occurred inside the button
      if args.grid.name == :bottom_left # if the grid shows bottom left as origin
        args.grid.origin_center! # origin will be shown in center
      else
        args.grid.origin_bottom_left! # otherwise, the view will change to show bottom left as origin
      end
    end
  end

  tick_instructions args, "Sample app shows the two supported coordinate systems in Game Toolkit."
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
