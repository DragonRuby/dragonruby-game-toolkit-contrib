=begin

 Reminders:

 - args.outputs.lines: An array. The values generate a line.
   The parameters are [X1, Y1, X2, Y2, RED, GREEN, BLUE, ALPHA]
   For more information about lines, go to mygame/documentation/04-lines.md.

   In this sample app, we're using lines to create the grid lines that make
   a 64x64 grid.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

 - args.outputs.solids: An array. The values generate a solid.
   The parameters are [X, Y, WIDTH, HEIGHT, RED, GREEN, BLUE]
   NOTE: PARAMETERS ARE THE SAME FOR BORDERS!
   For more information about solids and borders, go to mygame/documentation/03-solids-and-borders.md.

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   For example, if we want to create a new button, we would declare it as a new entity and
   then define its properties. (Remember, you can use state to define ANY property and it will
   be retained across frames.)

 - num1.idiv(num2): Divides two numbers and returns an integer.

 - num1.fdiv(num2): Divides two numbers and returns a float (has a decimal).

 - args.click.point.(x|y): The x and y location of the mouse.
   For more information about the mouse, go to mygame/documentation/07-mouse.md.

 - Symbol (:): Ruby object with a name and an internal ID. Symbols are useful
   because with a given symbol name, you can refer to the same object throughout
   a Ruby program.

=end

# This sample app shows two buttons. A label outputs a message depending on
# which button has been pressed.

# https://twitter.com/hashtag/LOWREZJAM

###################################################################################
# YOUR GAME GOES HERE
###################################################################################

# Creates buttons using labels and borders and reacts accordingly based on which button is pressed.
def lowrez_tick args, lowrez_sprites, lowrez_labels, lowrez_borders, lowrez_solids, lowrez_mouse
  # args.state.show_gridlines = true

  # Creates a white label telling the player to press a button.
  # The message is initialized (only in the first frame)
  args.state.button_message ||= "press button!"
  lowrez_labels << [1, 1, args.state.button_message, 255, 255, 255]

  # Creates button one using a border and a label
  button_one_border = [1, 32, 63, 10, 255, 255, 255] # white border
  lowrez_borders   << button_one_border
  lowrez_labels    << [button_one_border.x + 2,
                       button_one_border.y + 2,
                       "button one", 255, 255, 255] # white label

  # Creates button two using a border and a label
  button_two_border = [1, 21, 63, 10, 255, 255, 255] # white border
  lowrez_borders   << button_two_border
  lowrez_labels    << [button_two_border.x + 2,
                       button_two_border.y + 2,
                       "button two", 255, 255, 255] # white label

  if args.state.last_button_clicked # if a button was clicked (that button is last_button_clicked)
    lowrez_solids << [args.state.last_button_clicked.rect, 127, 127, 127] # button turns shade of gray
  end

  if lowrez_mouse.click # if the mouse was clicked
    if lowrez_mouse.click.inside_rect? button_one_border # if mouse clicked inside button one's border
      args.state.button_message = "button one!" # button message is set
      args.state.last_button_clicked = button_one_border # button one is last button clicked
    elsif lowrez_mouse.click.inside_rect? button_two_border # if mouse clicked inside button two's border
      args.state.button_message = "button two!" # button message is set
      args.state.last_button_clicked = button_two_border # button two is last button clicked
    else # if mouse was clicked inside border of neither button
      args.state.button_message = "press button!" # button message is set
      args.state.last_button_clicked = nil # no button was last button clicked
    end
  end
end

###################################################################################
# YOU CAN PLAY AROUND WITH THE CODE BELOW, BUT USE CAUTION AS THIS IS WHAT EMULATES
# THE 64x64 CANVAS.
###################################################################################

# Sets values to produce 64x64 canvas.
# These values are not changed, which is why ||= is not used.
TINY_RESOLUTION       = 64
TINY_SCALE            = 720.fdiv(TINY_RESOLUTION) # original dimension of 720 is scaled down by 64
CENTER_OFFSET         = (1280 - 720).fdiv(2) # sets center
EMULATED_FONT_SIZE    = 20
EMULATED_FONT_X_ZERO  = 0 # increasing this value would shift labels to the right
EMULATED_FONT_Y_ZERO  = 46 # increasing shifts labels up, decreasing shifts labels down

# Creates empty collections, and calls methods needed for the game to run properly.
def tick args
  sprites = []
  labels = []
  borders = []
  solids = []
  mouse = emulate_lowrez_mouse args # calls method to set mouse to mouse's position
  args.state.show_gridlines = false # grid lines are not shown
  lowrez_tick args, sprites, labels, borders, solids, mouse # contains definitions (of buttons)
  render_gridlines_if_needed args # outputs grid lines if show_gridlines is true
  render_mouse_crosshairs args, mouse # outputs position of mouse using label
  emulate_lowrez_scene args, sprites, labels, borders, solids, mouse # emulates scene on screen
end

# Sets values based on the position of the mouse on the screen.
def emulate_lowrez_mouse args

  # Declares the mouse as a new entity and sets values for the x and y variables.
  args.state.new_entity_strict(:lowrez_mouse) do |m|
    # mouse's original coordinates are scaled down to match canvas
    # original coordinates were within 1280x720 dimensions
    m.x = args.mouse.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1
    m.y = args.mouse.y.idiv(TINY_SCALE)

    if args.mouse.click # if mouse is clicked
      m.click = [ # sets definition and stores mouse click's definition
        args.mouse.click.point.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1,
        args.mouse.click.point.y.idiv(TINY_SCALE)
      ]
      m.down = m.click # down stores click's value, which is mouse click's position
    else
      m.click = nil # if no click occurred, both click and down are empty (do not store any position)
      m.down = nil
    end

    if args.mouse.up # if mouse is up (not pressed or held down)
      m.up = [ # sets definition, stores mouse's position
        args.mouse.up.point.x.idiv(TINY_SCALE) - CENTER_OFFSET.idiv(TINY_SCALE) - 1,
        args.mouse.up.point.y.idiv(TINY_SCALE)
      ]
    else
      m.up = nil # if mouse is not in "up" state, up is empty (has no value)
    end
  end
end

# Outputs position of mouse on screen using white label
def render_mouse_crosshairs args, mouse
  return unless args.state.show_gridlines # return unless true (grid lines are showing)
  args.labels << [10, 25, "mouse: #{mouse.x} #{mouse.y}", 255, 255, 255] # string interpolation
end

#Emulates the low rez scene by adding solids, sprites, etc. to the appropriate collections
# and creating labels
def emulate_lowrez_scene args, sprites, labels, borders, solids, mouse
  args.render_target(:lowrez).solids  << [0, 0, 1280, 720] # sets black background for grid
  args.render_target(:lowrez).sprites << sprites # outputs sprites
  args.render_target(:lowrez).borders << borders # outputs borders
  args.render_target(:lowrez).solids  << solids # outputs solids

  # The font that is used is saved in the game's folder.
  # Without the .ttf file, the label would not be created correctly.
  args.outputs.primitives << labels.map do |l| # outputs all elements of labels collection as primitive
    as_label = l.label
    l.text.each_char.each_with_index.map do |char, i| # perform action on each character in labels collection
      # label definition
      # places space between characters
      # centered to fit within grid dimensions
      [CENTER_OFFSET + EMULATED_FONT_X_ZERO + (as_label.x * TINY_SCALE) + i * 5 * TINY_SCALE,
       EMULATED_FONT_Y_ZERO + (as_label.y * TINY_SCALE), char,
       EMULATED_FONT_SIZE, 0, as_label.r, as_label.g, as_label.b, as_label.a, 'dragonruby-gtk-4x4.ttf'].label
    end
  end

  # placed in center; width and height are scaled down to fit canvas
  # comment this line out and the grid's black background will not appear
  args.sprites    << [CENTER_OFFSET, 0, 1280 * TINY_SCALE, 720 * TINY_SCALE, :lowrez]

  args.primitives << [0, 0, CENTER_OFFSET, 720].solid # black background on left side of grid
  args.primitives << [1280 - CENTER_OFFSET, 0, CENTER_OFFSET, 720].solid # black on right side of grid
  args.primitives << [0, 0, 1280, 2].solid # black on bottom; change 2 to 200 and see what happens
end

def render_gridlines_if_needed args
  # if grid lines are showing and static_lines collection (which contains grid lines) is empty
  if args.state.show_gridlines && args.static_lines.length == 0
    # add to the collection by adding line definitions 65 times (because of 64x64 canvas)
    # placed at equal distance apart within grid dimensions
    args.static_lines << 65.times.map do |i|
      [
        # [starting x, starting y, ending x, ending y, red, green, blue]
        # Vertical lines have the same starting and ending x value.
        # To make the vertical grid lines look thicker and more prominent, two separators are
        # placed together one pixel apart (explains "+1" in x parameter) as one vertical grid line.
        [CENTER_OFFSET + i * TINY_SCALE + 1,  0,
         CENTER_OFFSET + i * TINY_SCALE + 1,  720,                128, 128, 128], # vertical line 1
        [CENTER_OFFSET + i * TINY_SCALE,      0,
         CENTER_OFFSET + i * TINY_SCALE,      720,                128, 128, 128], # vertical line 2
        # Horizontal lines have the same starting and ending y value.
        # The two horizontal separators that are considered one grid line are placed
        # one pixel apart (explains the "1 +" in the y parameter).
        # That is why there are four line definitions (distinguished by []) being added to static_lines.
        # Two vertical and two horizontal separators are added to create one vertical
        # and one horizontal grid line.
        [CENTER_OFFSET,                       0 + i * TINY_SCALE,
         CENTER_OFFSET + 720,                 0 + i * TINY_SCALE, 128, 128, 128], # horizontal line 1
        [CENTER_OFFSET,                       1 + i * TINY_SCALE,
         CENTER_OFFSET + 720,                 1 + i * TINY_SCALE, 128, 128, 128] # horizontal line 2
      ]
    end
  elsif !args.state.show_gridlines # if show_gridlines is false (grid lines are not showing)
    args.static_lines.clear # clear the collection so no grid lines are in it
  end
end
