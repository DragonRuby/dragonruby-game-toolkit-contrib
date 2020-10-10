=begin

 APIs listing that haven't been encountered in previous sample apps:

 - Floor: Method that returns an integer number smaller than or equal to the original with no decimal.

   For example, if we have a variable, a = 13.7, and we called floor on it, it would look like this...
   puts a.floor()
   which would print out 13.
   (There is also a ceil method, which returns an integer number greater than or equal to the original
   with no decimal. If we had called ceil on the variable a, the result would have been 14.)

 Reminders:

 - Hashes: Collection of unique keys and their corresponding values. The value can be found
   using their keys.

   For example, if we have a "numbers" hash that stores numbers in English as the
   key and numbers in Spanish as the value, we'd have a hash that looks like this...
   numbers = { "one" => "uno", "two" => "dos", "three" => "tres" }
   and on it goes.

   Now if we wanted to find the corresponding value of the "one" key, we could say
   puts numbers["one"]
   which would print "uno" to the console.

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   In this sample app, new_entity is used to create a new button that clears the grid.
   (Remember, you can use state to define ANY property and it will be retained across frames.)

 - args.inputs.mouse.click.point.(x|y): The x and y location of the mouse.

 - args.inputs.mouse.click.point.created_at: The frame the mouse click occurred in.

 - args.outputs.labels: An array. The values in the array generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGN, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

 - ARRAY#inside_rect?: Returns true or false depending on if the point is inside the rect.

=end

# This sample app shows an empty grid that the user can paint on.
# To paint, the user must keep their mouse presssed and drag it around the grid.
# The "clear" button allows users to clear the grid so they can start over.

class PaintApp
  attr_accessor :inputs, :state, :outputs, :grid, :args

  # Runs methods necessary for the game to function properly.
  def tick
    print_title
    add_grid
    check_click
    draw_buttons
  end

  # Prints the title onto the screen by using a label.
  # Also separates the title from the grid with a line as a horizontal separator.
  def print_title
    args.outputs.labels << [ 640, 700, 'Paint!', 0, 1 ]
    outputs.lines << horizontal_separator(660, 0, 1280)
  end

  # Sets the starting position, ending position, and color for the horizontal separator.
  # The starting and ending positions have the same y values.
  def horizontal_separator y, x, x2
    [x, y, x2, y, 150, 150, 150]
  end

  # Sets the starting position, ending position, and color for the vertical separator.
  # The starting and ending positions have the same x values.
  def vertical_separator x, y, y2
    [x, y, x, y2, 150, 150, 150]
  end

  # Outputs a border and a grid containing empty squares onto the screen.
  def add_grid

    # Sets the x, y, height, and width of the grid.
    # There are 31 horizontal lines and 31 vertical lines in the grid.
    # Feel free to count them yourself before continuing!
    x, y, h, w = 640 - 500/2, 640 - 500, 500, 500 # calculations done so the grid appears in screen's center
    lines_h = 31
    lines_v = 31

    # Sets values for the grid's border, grid lines, and filled squares.
    # The filled_squares variable is initially set to an empty array.
    state.grid_border ||= [ x, y, h, w ] # definition of grid's outer border
    state.grid_lines ||= draw_grid(x, y, h, w, lines_h, lines_v) # calls draw_grid method
    state.filled_squares ||= [] # there are no filled squares until the user fills them in

    # Outputs the grid lines, border, and filled squares onto the screen.
    outputs.lines.concat state.grid_lines
    outputs.borders << state.grid_border
    outputs.solids << state.filled_squares
  end

  # Draws the grid by adding in vertical and horizontal separators.
  def draw_grid x, y, h, w, lines_h, lines_v

    # The grid starts off empty.
    grid = []

    # Calculates the placement and adds horizontal lines or separators into the grid.
    curr_y = y # start at the bottom of the box
    dist_y = h / (lines_h + 1) # finds distance to place horizontal lines evenly throughout 500 height of grid
    lines_h.times do
      curr_y += dist_y # increment curr_y by the distance between the horizontal lines
      grid << horizontal_separator(curr_y, x, x + w - 1) # add a separator into the grid
    end

    # Calculates the placement and adds vertical lines or separators into the grid.
    curr_x = x # now start at the left of the box
    dist_x = w / (lines_v + 1) # finds distance to place vertical lines evenly throughout 500 width of grid
    lines_v.times do
      curr_x += dist_x # increment curr_x by the distance between the vertical lines
      grid << vertical_separator(curr_x, y + 1, y  + h) # add separator
    end

    # paint_grid uses a hash to assign values to keys.
    state.paint_grid ||= {"x" => x, "y" => y, "h" => h, "w" => w, "lines_h" => lines_h,
                          "lines_v" => lines_v, "dist_x" => dist_x,
                          "dist_y" => dist_y }

    return grid
  end

  # Checks if the user is keeping the mouse pressed down and sets the mouse_hold variable accordingly using boolean values.
  # If the mouse is up, the user cannot drag the mouse.
  def check_click
    if inputs.mouse.down #is mouse up or down?
      state.mouse_held = true # mouse is being held down
    elsif inputs.mouse.up # if mouse is up
    state.mouse_held = false # mouse is not being held down or dragged
      state.mouse_dragging = false
    end

    if state.mouse_held &&    # mouse needs to be down
      !inputs.mouse.click &&     # must not be first click
      ((inputs.mouse.previous_click.point.x - inputs.mouse.position.x).abs > 15) # Need to move 15 pixels before "drag"
      state.mouse_dragging = true
    end

    # If the user clicks their mouse inside the grid, the search_lines method is called with a click input type.
    if ((inputs.mouse.click) && (inputs.mouse.click.point.inside_rect? state.grid_border))
      search_lines(inputs.mouse.click.point, :click)

    # If the user drags their mouse inside the grid, the search_lines method is called with a drag input type.
    elsif ((state.mouse_dragging) && (inputs.mouse.position.inside_rect? state.grid_border))
      search_lines(inputs.mouse.position, :drag)
    end
  end

  # Sets the definition of a grid box and handles user input to fill in or clear grid boxes.
  def search_lines (point, input_type)
    point.x -= state.paint_grid["x"] # subtracts the value assigned to the "x" key in the paint_grid hash
    point.y -= state.paint_grid["y"] # subtracts the value assigned to the "y" key in the paint_grid hash

    # Remove code following the .floor and see what happens when you try to fill in grid squares
    point.x = (point.x / state.paint_grid["dist_x"]).floor * state.paint_grid["dist_x"]
    point.y = (point.y / state.paint_grid["dist_y"]).floor * state.paint_grid["dist_y"]

    point.x += state.paint_grid["x"]
    point.y += state.paint_grid["y"]

    # Sets definition of a grid box, meaning its x, y, width, and height.
    # Floor is called on the point.x and point.y variables.
    # Ceil method is called on values of the distance hash keys, setting the width and height of a box.
    grid_box = [ point.x.floor, point.y.floor, state.paint_grid["dist_x"].ceil, state.paint_grid["dist_y"].ceil ]

    if input_type == :click # if user clicks their mouse
      if state.filled_squares.include? grid_box # if grid box is already filled in
        state.filled_squares.delete grid_box # box is cleared and removed from filled_squares
      else
        state.filled_squares << grid_box # otherwise, box is filled in and added to filled_squares
      end
    elsif input_type == :drag # if user drags mouse
      unless state.filled_squares.include? grid_box # unless the grid box dragged over is already filled in
        state.filled_squares << grid_box # the box is filled in and added to filled_squares
      end
    end
  end

  # Creates and outputs a "Clear" button on the screen using a label and a border.
  # If the button is clicked, the filled squares are cleared, making the filled_squares collection empty.
  def draw_buttons
    x, y, w, h = 390, 50, 240, 50
    state.clear_button        ||= state.new_entity(:button_with_fade)

    # The x and y positions are set to display the label in the center of the button.
    # Try changing the first two parameters to simply x, y and see what happens to the text placement!
    state.clear_button.label  ||= [x + w.half, y + h.half + 10, "Clear", 0, 1] # placed in center of border
    state.clear_button.border ||= [x, y, w, h]

    # If the mouse is clicked inside the borders of the clear button,
    # the filled_squares collection is emptied and the squares are cleared.
    if inputs.mouse.click && inputs.mouse.click.point.inside_rect?(state.clear_button.border)
      state.clear_button.clicked_at = inputs.mouse.click.created_at # time (frame) the click occurred
      state.filled_squares.clear
      inputs.mouse.previous_click = nil
    end

    outputs.labels << state.clear_button.label
    outputs.borders << state.clear_button.border

    # When the clear button is clicked, the color of the button changes
    # and the transparency changes, as well. If you change the time from
    # 0.25.seconds to 1.25.seconds or more, the change will last longer.
    if state.clear_button.clicked_at
      outputs.solids << [x, y, w, h, 0, 180, 80, 255 * state.clear_button.clicked_at.ease(0.25.seconds, :flip)]
    end
  end
end

$paint_app = PaintApp.new

def tick args
  $paint_app.inputs = args.inputs
  $paint_app.state = args.state
  $paint_app.grid = args.grid
  $paint_app.args = args
  $paint_app.outputs = args.outputs
  $paint_app.tick
  tick_instructions args, "How to create a simple paint app. CLICK and HOLD to draw."
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
