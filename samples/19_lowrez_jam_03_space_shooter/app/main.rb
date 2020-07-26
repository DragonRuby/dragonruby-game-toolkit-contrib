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

   In this sample app, labels are used to inform the player that they won the game.

 - args.outputs.sprites: An array. The values generate a sprite.
   The parameters are [X, Y, WIDTH, HEIGHT, IMAGE PATH, ANGLE, ALPHA, RED, GREEN, BLUE]
   For more information about sprites, go to mygame/documentation/05-sprites.md.

   In this sample app, sprites are used to generate ships and bullets.

 - args.outputs.solids: An array. The values generate a solid.
   The parameters are [X, Y, WIDTH, HEIGHT, RED, GREEN, BLUE]
   For more information about solids, go to mygame/documentation/03-solids-and-borders.md.

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   For example, if we want to create a new button, we would declare it as a new entity and
   then define its properties. (Remember, you can use state to define ANY property and it will
   be retained across frames.)

 - num1.idiv(num2): Divides two numbers and returns an integer.

 - num1.fdiv(num2): Divides two numbers and returns a float (has a decimal).

 - Symbol (:): Ruby object with a name and an internal ID. Symbols are useful
   because with a given symbol name, you can refer to the same object throughout
   a Ruby program.

 - args.keyboard.key_down.KEY: Determines if a key is in the "down" state or being pressed down.
   For more information about the keyboard, go to mygame/documentation/06-keyboard.md.

 - ARRAY#intersect_rect?: Returns true or false depending on if the two rectangles intersect.
   In this sample app, intersects_rect? is being used to determine whether or not a bullet
   hits (or intersects with) the enemy's ship.

 - to_i: Returns an integer representation of an object.

=end

# This sample app shows two ships, one for the player and one for the enemy.
# The goal is to shoot the enemy ship with a bullet.

# https://twitter.com/hashtag/LOWREZJAM

###################################################################################
# YOUR GAME GOES HERE
###################################################################################

# Calls methods needed to run the spaceship game properly.
def lowrez_tick args, lowrez_sprites, lowrez_labels, lowrez_borders, lowrez_solids, lowrez_mouse
  # args.state.show_gridlines = true

  if args.state.you_win # if player wins the game
    lowrez_tick_you_win args, lowrez_labels # a label will inform player that they won
  else # otherwise if the game is ongoing
    lowrez_move_bullets args # calls methods needed to run game
    lowrez_move_red_ship args
    lowrez_move_blue_ship args
    lowrez_render_game args, lowrez_sprites
  end
end

# Informs the player that they won the game using labels
def lowrez_tick_you_win args, lowrez_labels
  lowrez_labels << [10, 30, "You win!!", 255, 255, 255] # white labels
  lowrez_labels << [4, 24, "Press Enter", 255, 255, 255]

  if args.keyboard.key_down.enter # if player presses enter key
    args.state.you_win = false # the player has no longer won (because game resets)
    args.state.bullets.clear # bullets collection is emptied
    args.state.blue_ship_location = nil # ship locations are emptied
    args.state.red_ship_location = nil
  end
end

# Moves bullets on screen and determines if bullet hit the red (enemy) ship
def lowrez_move_bullets args

  # Initiates an empty bullets collection
  args.state.bullets ||= []

  # Changes vertical position of bullets on screen by incrementing their y value
  args.state.bullets.map do |b|
    b.y += 1
  end

  # Any bullet with a y value that exceeds screen dimensions is rejected from the collection
  # Vertical dimension is 64 (bullets higher than that have exceeded screen dimensions)
  args.state.bullets = args.state.bullets.reject { |b| b.y >= 64 }

  # Checks if any bullets hit the red (enemy) ship
  bullets_hit_red_ship = args.state.bullets.any? do |b|
    b_rect = [b.x, b.y, 1, 1] # sets bullet definition
    ship_rect = [args.state.red_ship_location.x, args.state.red_ship_location.y, 5, 5] # sets enemy definition
    b_rect.intersect_rect? ship_rect # checks for intersections between bullet and red enemy ship
  end

  if bullets_hit_red_ship == true # if bullet hits red enemy ship
    args.state.you_win = true # the player wins
  end
end

# Moves the red (enemy) ship on the screen
def lowrez_move_red_ship args

  # Initializes the red ship's position on the screen
  args.state.red_ship_location  ||=  [31, 58]

  # Moves the ship by changing its x value.
  if args.state.red_ship_location.x.to_i <= 1 # if ship moves too far left
    args.state.red_ship_location.x += 1 # moves right
  elsif args.state.red_ship_location.x.to_i >= 62 # if ship moves too far right
    args.state.red_ship_location.x -= 1 # moves left
  else # otherwise, if ship is within screen horizontal dimensions
    args.state.red_ship_location.x += rand * 1.randomize(:sign) # randomize x increment
  end
end

# Moves the blue ship on the screen
def lowrez_move_blue_ship args

  # Initializes the blue ship's position on the screen
  args.state.blue_ship_location ||= [0, 0]

  # Uses keyboard input from the player to move the blue ship.
  if args.keyboard.right # if right key is pressed
    args.state.blue_ship_location.x += 0.5 # increment x to move right
  elsif args.keyboard.left # if left key is pressed
    args.state.blue_ship_location.x -= 0.5 # decrement x to move left
  end

  # Shoots out bullets when the player presses the space bar
  if args.keyboard.key_down.space # if space bar is pressed
    args.state.bullets << [args.state.blue_ship_location.x + 2,
                           args.state.blue_ship_location.y + 3] # bullet is given location on screen
  end
end

# Sets the definition of the ships and bullets.
def lowrez_render_game args, lowrez_sprites
  lowrez_sprites << [args.state.blue_ship_location.x,
                     args.state.blue_ship_location.y,
                     5,
                     5,
                     'sprites/ship_blue.png'] # definition of player ship sprite

  lowrez_sprites << args.state.bullets.map do |b| # add to bullets collection
    [b.x, b.y, 1, 1, 'sprites/blue_bullet.png'] # definition of bullet
  end

  lowrez_sprites << [args.state.red_ship_location.x,
                     args.state.red_ship_location.y,
                     5,
                     5,
                     'sprites/ship_red.png',
                     180] # definition of enemy ship sprite
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
  args.state.show_gridlines = false # do not show grid lines
  lowrez_tick args, sprites, labels, borders, solids, mouse # contains definitions of objects
  render_gridlines_if_needed args # output grid lines if show_gridlines is true
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
      m.click = [ # sets definition and stores mouse click's definition (coordinates)
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

# Outputs the position of the mouse on the screen using a white label
def render_mouse_crosshairs args, mouse
  return unless args.state.show_gridlines # return unless true (grid lines are showing)
  args.labels << [10, 25, "mouse: #{mouse.x} #{mouse.y}", 255, 255, 255] # string interpolation
end

# Emulates the low rez scene by adding solids, sprites, etc. to the appropriate collections and creating labels
def emulate_lowrez_scene args, sprites, labels, borders, solids, mouse
  args.render_target(:lowrez).sprites << sprites # outputs sprites on screen

  # The font that is used is saved in the game's folder.
  # Without the .ttf file, the label would not be created correctly.
  args.outputs.labels << labels.map do |l| # outputs all elements of labels collection
    as_label = l.label
    l.text.each_char.each_with_index.map do |char, i| # perform action on each character in labels collection
      # label definition
      # places space between characters
      # centered to fit within grid dimensions
      [CENTER_OFFSET + EMULATED_FONT_X_ZERO + (as_label.x * TINY_SCALE) + i * 5 * TINY_SCALE,
       EMULATED_FONT_Y_ZERO + (as_label.y * TINY_SCALE), char,
       EMULATED_FONT_SIZE, 0, as_label.r, as_label.g, as_label.b, as_label.a, 'dragonruby-gtk-4x4.ttf']
    end
  end

  args.render_target(:lowrez).solids << [0, 0, 1280, 720] # black background
  args.sprites    << [CENTER_OFFSET, 0, 1280 * TINY_SCALE, 720 * TINY_SCALE, :lowrez] # sprites and background of grid
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
