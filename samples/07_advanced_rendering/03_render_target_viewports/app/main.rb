=begin

 APIs listing that haven't been encountered in previous sample apps:

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   For example, if we want to create a new button, we would declare it as a new entity and
   then define its properties. (Remember, you can use state to define ANY property and it will
   be retained across frames.)

   If you have a solar system and you're creating args.state.sun and setting its image path to an
   image in the sprites folder, you would do the following:
   (See samples/99_sample_nddnug_workshop for more details.)

   args.state.sun ||= args.state.new_entity(:sun) do |s|
   s.path = 'sprites/sun.png'
   end

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

   For example, if we have a variable
   name = "Ruby"
   then the line
   puts "How are you, #{name}?"
   would print "How are you, Ruby?" to the console.
   (Remember, string interpolation only works with double quotes!)

 - Ternary operator (?): Similar to if statement; first evalulates whether a statement is
   true or false, and then executes a command depending on that result.
   For example, if we had a variable
   grade = 75
   and used the ternary operator in the command
   pass_or_fail = grade > 65 ? "pass" : "fail"
   then the value of pass_or_fail would be "pass" since grade's value was greater than 65.

 Reminders:

 - args.grid.(left|right|top|bottom): Pixel value for the boundaries of the virtual
   720 p screen (Dragon Ruby Game Toolkits's virtual resolution is always 1280x720).

 - Numeric#shift_(left|right|up|down): Shifts the Numeric in the correct direction
   by adding or subracting.

 - ARRAY#inside_rect?: An array with at least two values is considered a point. An array
   with at least four values is considered a rect. The inside_rect? function returns true
   or false depending on if the point is inside the rect.

 - ARRAY#intersect_rect?: Returns true or false depending on if the two rectangles intersect.

 - args.inputs.mouse.click: This property will be set if the mouse was clicked.
   For more information about the mouse, go to mygame/documentation/07-mouse.md.

 - args.inputs.keyboard.key_up.KEY: The value of the properties will be set
   to the frame  that the key_up event occurred (the frame correlates
   to args.state.tick_count).
   For more information about the keyboard, go to mygame/documentation/06-keyboard.md.

 - args.state.labels:
   The parameters for a label are
   1. the position (x, y)
   2. the text
   3. the size
   4. the alignment
   5. the color (red, green, and blue saturations)
   6. the alpha (or transparency)
   For more information about labels, go to mygame/documentation/02-labels.md.

 - args.state.lines:
   The parameters for a line are
   1. the starting position (x, y)
   2. the ending position (x2, y2)
   3. the color (red, green, and blue saturations)
   4. the alpha (or transparency)
   For more information about lines, go to mygame/documentation/04-lines.md.

 - args.state.solids (and args.state.borders):
   The parameters for a solid (or border) are
   1. the position (x, y)
   2. the width (w)
   3. the height (h)
   4. the color (r, g, b)
   5. the alpha (or transparency)
   For more information about solids and borders, go to mygame/documentation/03-solids-and-borders.md.

 - args.state.sprites:
   The parameters for a sprite are
   1. the position (x, y)
   2. the width (w)
   3. the height (h)
   4. the image path
   5. the angle
   6. the alpha (or transparency)
   For more information about sprites, go to mygame/documentation/05-sprites.md.
=end

# This sample app shows different objects that can be used when making games, such as labels,
# lines, sprites, solids, buttons, etc. Each demo section shows how these objects can be used.

# Also note that state.tick_count refers to the passage of time, or current frame.

class TechDemo
  attr_accessor :inputs, :state, :outputs, :grid, :args

  # Calls all methods necessary for the app to run properly.
  def tick
    labels_tech_demo
    lines_tech_demo
    solids_tech_demo
    borders_tech_demo
    sprites_tech_demo
    keyboards_tech_demo
    controller_tech_demo
    mouse_tech_demo
    point_to_rect_tech_demo
    rect_to_rect_tech_demo
    button_tech_demo
    export_game_state_demo
    window_state_demo
    render_seperators
  end

  # Shows output of different kinds of labels on the screen
  def labels_tech_demo
    outputs.labels << [grid.left.shift_right(5), grid.top.shift_down(5), "This is a label located at the top left."]
    outputs.labels << [grid.left.shift_right(5), grid.bottom.shift_up(30), "This is a label located at the bottom left."]
    outputs.labels << [ 5, 690, "Labels (x, y, text, size, align, r, g, b, a)"]
    outputs.labels << [ 5, 660, "Smaller label.",  -2]
    outputs.labels << [ 5, 630, "Small label.",    -1]
    outputs.labels << [ 5, 600, "Medium label.",    0]
    outputs.labels << [ 5, 570, "Large label.",     1]
    outputs.labels << [ 5, 540, "Larger label.",    2]
    outputs.labels << [300, 660, "Left aligned.",    0, 2]
    outputs.labels << [300, 640, "Center aligned.",  0, 1]
    outputs.labels << [300, 620, "Right aligned.",   0, 0]
    outputs.labels << [175, 595, "Red Label.",       0, 0, 255,   0,   0]
    outputs.labels << [175, 575, "Green Label.",     0, 0,   0, 255,   0]
    outputs.labels << [175, 555, "Blue Label.",      0, 0,   0,   0, 255]
    outputs.labels << [175, 535, "Faded Label.",     0, 0,   0,   0,   0, 128]
  end

  # Shows output of lines on the screen
  def lines_tech_demo
    outputs.labels << [5, 500, "Lines (x, y, x2, y2, r, g, b, a)"]
    outputs.lines  << [5, 450, 100, 450]
    outputs.lines  << [5, 430, 300, 430]
    outputs.lines  << [5, 410, 300, 410, state.tick_count % 255, 0, 0, 255] # red saturation changes
    outputs.lines  << [5, 390 - state.tick_count % 25, 300, 390, 0, 0, 0, 255] # y position changes
    outputs.lines  << [5 + state.tick_count % 200, 360, 300, 360, 0, 0, 0, 255] # x position changes
  end

  # Shows output of different kinds of solids on the screen
  def solids_tech_demo
    outputs.labels << [  5, 350, "Solids (x, y, w, h, r, g, b, a)"]
    outputs.solids << [ 10, 270, 50, 50]
    outputs.solids << [ 70, 270, 50, 50, 0, 0, 0]
    outputs.solids << [130, 270, 50, 50, 255, 0, 0]
    outputs.solids << [190, 270, 50, 50, 255, 0, 0, 128]
    outputs.solids << [250, 270, 50, 50, 0, 0, 0, 128 + state.tick_count % 128] # transparency changes
  end

  # Shows output of different kinds of borders on the screen
  # The parameters for a border are the same as the parameters for a solid
  def borders_tech_demo
    outputs.labels <<  [  5, 260, "Borders (x, y, w, h, r, g, b, a)"]
    outputs.borders << [ 10, 180, 50, 50]
    outputs.borders << [ 70, 180, 50, 50, 0, 0, 0]
    outputs.borders << [130, 180, 50, 50, 255, 0, 0]
    outputs.borders << [190, 180, 50, 50, 255, 0, 0, 128]
    outputs.borders << [250, 180, 50, 50, 0, 0, 0, 128 + state.tick_count % 128] # transparency changes
  end

  # Shows output of different kinds of sprites on the screen
  def sprites_tech_demo
    outputs.labels <<  [   5, 170, "Sprites (x, y, w, h, path, angle, a)"]
    outputs.sprites << [  10, 40, 128, 101, 'dragonruby.png']
    outputs.sprites << [ 150, 40, 128, 101, 'dragonruby.png', state.tick_count % 360] # angle changes
    outputs.sprites << [ 300, 40, 128, 101, 'dragonruby.png', 0, state.tick_count % 255] # transparency changes
  end

  # Holds size, alignment, color (black), and alpha (transparency) parameters
  # Using small_font as a parameter accounts for all remaining parameters
  # so they don't have to be repeatedly typed
  def small_font
    [-2, 0, 0, 0, 0, 255]
  end

  # Sets position of each row
  # Converts given row value to pixels that DragonRuby understands
  def row_to_px row_number

    # Row 0 starts 5 units below the top of the grid.
    # Each row afterward is 20 units lower.
    grid.top.shift_down(5).shift_down(20 * row_number)
  end

  # Uses labels to output current game time (passage of time), and whether or not "h" was pressed
  # If "h" is pressed, the frame is output when the key_up event occurred
  def keyboards_tech_demo
    outputs.labels << [460, row_to_px(0), "Current game time: #{state.tick_count}", small_font]
    outputs.labels << [460, row_to_px(2), "Keyboard input: inputs.keyboard.key_up.h", small_font]
    outputs.labels << [460, row_to_px(3), "Press \"h\" on the keyboard.", small_font]

    if inputs.keyboard.key_up.h # if "h" key_up event occurs
      state.h_pressed_at = state.tick_count # frame it occurred is stored
    end

    # h_pressed_at is initially set to false, and changes once the user presses the "h" key.
    state.h_pressed_at ||= false

    if state.h_pressed_at # if h is pressed (pressed_at has a frame number and is no longer false)
      outputs.labels << [460, row_to_px(4), "\"h\" was pressed at time: #{state.h_pressed_at}", small_font]
    else # otherwise, label says "h" was never pressed
      outputs.labels << [460, row_to_px(4), "\"h\" has never been pressed.", small_font]
    end

    # border around keyboard input demo section
    outputs.borders << [455, row_to_px(5), 360, row_to_px(2).shift_up(5) - row_to_px(5)]
  end

  # Sets definition for a small label
  # Makes it easier to position labels in respect to the position of other labels
  def small_label x, row, message
    [x, row_to_px(row), message, small_font]
  end

  # Uses small labels to show whether the "a" button on the controller is down, held, or up.
  # y value of each small label is set by calling the row_to_px method
  def controller_tech_demo
    x = 460
    outputs.labels << small_label(x, 6, "Controller one input: inputs.controller_one")
    outputs.labels << small_label(x, 7, "Current state of the \"a\" button.")
    outputs.labels << small_label(x, 8, "Check console window for more info.")

    if inputs.controller_one.key_down.a # if "a" is in "down" state
      outputs.labels << small_label(x, 9, "\"a\" button down: #{inputs.controller_one.key_down.a}")
      puts "\"a\" button down at #{inputs.controller_one.key_down.a}" # prints frame the event occurred
    elsif inputs.controller_one.key_held.a # if "a" is held down
      outputs.labels << small_label(x, 9, "\"a\" button held: #{inputs.controller_one.key_held.a}")
    elsif inputs.controller_one.key_up.a # if "a" is in up state
      outputs.labels << small_label(x, 9, "\"a\" button up: #{inputs.controller_one.key_up.a}")
      puts "\"a\" key up at #{inputs.controller_one.key_up.a}"
    else # if no event has occurred
      outputs.labels << small_label(x, 9, "\"a\" button state is nil.")
    end

    # border around controller input demo section
    outputs.borders << [455, row_to_px(10), 360, row_to_px(6).shift_up(5) - row_to_px(10)]
  end

  # Outputs when the mouse was clicked, as well as the coordinates on the screen
  # of where the click occurred
  def mouse_tech_demo
    x = 460

    outputs.labels << small_label(x, 11, "Mouse input: inputs.mouse")

    if inputs.mouse.click # if click has a value and is not nil
      state.last_mouse_click = inputs.mouse.click # coordinates of click are stored
    end

    if state.last_mouse_click # if mouse is clicked (has coordinates as value)
      # outputs the time (frame) the click occurred, as well as how many frames have passed since the event
      outputs.labels << small_label(x, 12, "Mouse click happened at: #{state.last_mouse_click.created_at}, #{state.last_mouse_click.created_at_elapsed}")
      # outputs coordinates of click
      outputs.labels << small_label(x, 13, "Mouse click location: #{state.last_mouse_click.point.x}, #{state.last_mouse_click.point.y}")
    else # otherwise if the mouse has not been clicked
      outputs.labels << small_label(x, 12, "Mouse click has not occurred yet.")
      outputs.labels << small_label(x, 13, "Please click mouse.")
    end
  end

  # Outputs whether a mouse click occurred inside or outside of a box
  def point_to_rect_tech_demo
    x = 460

    outputs.labels << small_label(x, 15, "Click inside the blue box maybe ---->")

    box = [765, 370, 50, 50, 0, 0, 170] # blue box
    outputs.borders << box

    if state.last_mouse_click # if the mouse was clicked
      if state.last_mouse_click.point.inside_rect? box # if mouse clicked inside box
        outputs.labels << small_label(x, 16, "Mouse click happened inside the box.")
      else # otherwise, if mouse was clicked outside the box
        outputs.labels << small_label(x, 16, "Mouse click happened outside the box.")
      end
    else # otherwise, if was not clicked at all
      outputs.labels << small_label(x, 16, "Mouse click has not occurred yet.") # output if the mouse was not clicked
    end

    # border around mouse input demo section
    outputs.borders << [455, row_to_px(14), 360, row_to_px(11).shift_up(5) - row_to_px(14)]
  end

  # Outputs a red box onto the screen. A mouse click from the user inside of the red box will output
  # a smaller box. If two small boxes are inside of the red box, it will be determined whether or not
  # they intersect.
  def rect_to_rect_tech_demo
    x = 460

    outputs.labels << small_label(x, 17.5, "Click inside the red box below.") # label with instructions
    red_box = [460, 250, 355, 90, 170, 0, 0] # definition of the red box
    outputs.borders << red_box # output as a border (not filled in)

    # If the mouse is clicked inside the red box, two collision boxes are created.
    if inputs.mouse.click
      if inputs.mouse.click.point.inside_rect? red_box
        if !state.box_collision_one # if the collision_one box does not yet have a definition
          # Subtracts 25 from the x and y positions of the click point in order to make the click point the center of the box.
          # You can try deleting the subtraction to see how it impacts the box placement.
          state.box_collision_one = [inputs.mouse.click.point.x - 25, inputs.mouse.click.point.y - 25, 50, 50, 180, 0,   0, 180]  # sets definition
        elsif !state.box_collision_two # if collision_two does not yet have a definition
          state.box_collision_two = [inputs.mouse.click.point.x - 25, inputs.mouse.click.point.y - 25, 50, 50,   0, 0, 180, 180] # sets definition
        else
          state.box_collision_one = nil # both boxes are empty
          state.box_collision_two = nil
        end
      end
    end

    # If collision boxes exist, they are output onto screen inside the red box as solids
    if state.box_collision_one
      outputs.solids << state.box_collision_one
    end

    if state.box_collision_two
      outputs.solids << state.box_collision_two
    end

    # Outputs whether or not the two collision boxes intersect.
    if state.box_collision_one && state.box_collision_two # if both collision_boxes are defined (and not nil or empty)
      if state.box_collision_one.intersect_rect? state.box_collision_two # if the two boxes intersect
        outputs.labels << small_label(x, 23.5, 'The boxes intersect.')
      else # otherwise, if the two boxes do not intersect
        outputs.labels << small_label(x, 23.5, 'The boxes do not intersect.')
      end
    else
      outputs.labels << small_label(x, 23.5, '--') # if the two boxes are not defined (are nil or empty), this label is output
    end
  end

  # Creates a button and outputs it onto the screen using labels and borders.
  # If the button is clicked, the color changes to make it look faded.
  def button_tech_demo
    x, y, w, h = 460, 160, 300, 50
    state.button        ||= state.new_entity(:button_with_fade)

    # Adds w.half to x and h.half + 10 to y in order to display the text inside the button's borders.
    state.button.label  ||= [x + w.half, y + h.half + 10, "click me and watch me fade", 0, 1]
    state.button.border ||= [x, y, w, h]

    if inputs.mouse.click && inputs.mouse.click.point.inside_rect?(state.button.border) # if mouse is clicked, and clicked inside button's border
      state.button.clicked_at = inputs.mouse.click.created_at # stores the time the click occurred
    end

    outputs.labels << state.button.label
    outputs.borders << state.button.border

    if state.button.clicked_at # if button was clicked (variable has a value and is not nil)

      # The appearance of the button changes for 0.25 seconds after the time the button is clicked at.
      # The color changes (rgb is set to 0, 180, 80) and the transparency gradually changes.
      # Change 0.25 to 1.25 and notice that the transparency takes longer to return to normal.
      outputs.solids << [x, y, w, h, 0, 180, 80, 255 * state.button.clicked_at.ease(0.25.seconds, :flip)]
    end
  end

  # Creates a new button by declaring it as a new entity, and sets values.
  def new_button_prefab x, y, message
    w, h = 300, 50
    button        = state.new_entity(:button_with_fade)
    button.label  = [x + w.half, y + h.half + 10, message, 0, 1] # '+ 10' keeps label's text within button's borders
    button.border = [x, y, w, h] # sets border definition
    button
  end

  # If the mouse has been clicked and the click's location is inside of the button's border, that means
  # that the button has been clicked. This method returns a boolean value.
  def button_clicked? button
    inputs.mouse.click && inputs.mouse.click.point.inside_rect?(button.border)
  end

  # Determines if button was clicked, and changes its appearance if it is clicked
  def tick_button_prefab button
    outputs.labels << button.label # outputs button's label and border
    outputs.borders << button.border

    if button_clicked? button # if button is clicked
      button.clicked_at = inputs.mouse.click.created_at # stores the time that the button was clicked
    end

    if button.clicked_at # if clicked_at has a frame value and is not nil
      # button is output; color changes and transparency changes for 0.25 seconds after click occurs
      outputs.solids << [button.border.x, button.border.y, button.border.w, button.border.h,
                         0, 180, 80, 255 * button.clicked_at.ease(0.25.seconds, :flip)] # transparency changes for 0.25 seconds
    end
  end

  # Exports the app's game state if the export button is clicked.
  def export_game_state_demo
    state.export_game_state_button ||= new_button_prefab(460, 100, "click to export app state")
    tick_button_prefab(state.export_game_state_button) # calls method to output button
    if button_clicked? state.export_game_state_button # if the export button is clicked
      args.gtk.export! "Exported from clicking the export button in the tech demo." # the export occurs
    end
  end

  # The mouse and keyboard focus are set to "yes" when the Dragonruby window is the active window.
  def window_state_demo
    m = $gtk.args.inputs.mouse.has_focus ? 'Y' : 'N' # ternary operator (similar to if statement)
    k = $gtk.args.inputs.keyboard.has_focus ? 'Y' : 'N'
    outputs.labels << [460, 20, "mouse focus: #{m}   keyboard focus: #{k}", small_font]
  end

  #Sets values for the horizontal separator (divides demo sections)
  def horizontal_seperator y, x, x2
    [x, y, x2, y, 150, 150, 150]
  end

  #Sets the values for the vertical separator (divides demo sections)
  def vertical_seperator x, y, y2
    [x, y, x, y2, 150, 150, 150]
  end

  # Outputs vertical and horizontal separators onto the screen to separate each demo section.
  def render_seperators
    outputs.lines << horizontal_seperator(505, grid.left, 445)
    outputs.lines << horizontal_seperator(353, grid.left, 445)
    outputs.lines << horizontal_seperator(264, grid.left, 445)
    outputs.lines << horizontal_seperator(174, grid.left, 445)

    outputs.lines << vertical_seperator(445, grid.top, grid.bottom)

    outputs.lines << horizontal_seperator(690, 445, 820)
    outputs.lines << horizontal_seperator(426, 445, 820)

    outputs.lines << vertical_seperator(820, grid.top, grid.bottom)
  end
end

$tech_demo = TechDemo.new

def tick args
  $tech_demo.inputs = args.inputs
  $tech_demo.state = args.state
  $tech_demo.grid = args.grid
  $tech_demo.args = args
  $tech_demo.outputs = args.render_target(:mini_map)
  $tech_demo.tick
  args.outputs.labels  << [830, 715, "Render target:", [-2, 0, 0, 0, 0, 255]]
  args.outputs.sprites << [0, 0, 1280, 720, :mini_map]
  args.outputs.sprites << [830, 300, 675, 379, :mini_map]
  tick_instructions args, "Sample app shows all the rendering apis available."
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
