=begin

 APIs listing that haven't been encountered in previous sample apps:

 - reverse: Returns a new string with the characters from original string in reverse order.
   For example, the command
   "dragonruby".reverse
   would return the string
   "yburnogard".
   Reverse is not only limited to strings, but can be applied to arrays and other collections.

 Reminders:

 - ARRAY#intersect_rect?: Returns true or false depending on if two rectangles intersect.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

=end

# This code shows a maze and uses input from the keyboard to move the user around the screen.
# The objective is to reach the goal.

# Sets values of tile size and player's movement speed
# Also creates tile or box for player and generates map
def tick args
  args.state.tile_size     = 80
  args.state.player_speed  = 4
  args.state.player      ||= tile(args, 7, 3, 0, 128, 180)
  generate_map args

  # Adds walls, goal, and player to args.outputs.solids so they appear on screen
  args.outputs.solids << args.state.walls
  args.outputs.solids << args.state.goal
  args.outputs.solids << args.state.player

  # If player's box intersects with goal, a label is output onto the screen
  if args.state.player.intersect_rect? args.state.goal
    args.outputs.labels << [30, 720 - 30, "You're a wizard Harry!!"] # 30 pixels lower than top of screen
  end

  move_player args, -1,  0 if args.inputs.keyboard.left # x position decreases by 1 if left key is pressed
  move_player args,  1,  0 if args.inputs.keyboard.right # x position increases by 1 if right key is pressed
  move_player args,  0,  1 if args.inputs.keyboard.up # y position increases by 1 if up is pressed
  move_player args,  0, -1 if args.inputs.keyboard.down # y position decreases by 1 if down is pressed
end

# Sets position, size, and color of the tile
def tile args, x, y, *color
  [x * args.state.tile_size, # sets definition for array using method parameters
   y * args.state.tile_size, # multiplying by tile_size sets x and y to correct position using pixel values
   args.state.tile_size,
   args.state.tile_size,
   *color]
end

# Creates map by adding tiles to the wall, as well as a goal (that the player needs to reach)
def generate_map args
  return if args.state.area

  # Creates the area of the map. There are 9 rows running horizontally across the screen
  # and 16 columns running vertically on the screen. Any spot with a "1" is not
  # open for the player to move into (and is green), and any spot with a "0" is available
  # for the player to move in.
  args.state.area = [
    [1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1,],
    [1, 1, 1, 2, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1,], # the "2" represents the goal
    [1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,],
    [1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,],
    [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,],
    [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1,],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  ].reverse # reverses the order of the area collection

  # By reversing the order, the way that the area appears above is how it appears
  # on the screen in the game. If we did not reverse, the map would appear inverted.

  #The wall starts off with no tiles.
  args.state.walls = []

  # If v is 1, a green tile is added to args.state.walls.
  # If v is 2, a black tile is created as the goal.
  args.state.area.map_2d do |y, x, v|
    if    v == 1
      args.state.walls << tile(args, x, y, 0, 255, 0) # green tile
    elsif v == 2 # notice there is only one "2" above because there is only one single goal
      args.state.goal   = tile(args, x, y, 0,   0, 0) # black tile
    end
  end
end

# Allows the player to move their box around the screen
def move_player args, *vector
  box = args.state.player.shift_rect(vector) # box is able to move at an angle

  # If the player's box hits a wall, it is not able to move further in that direction
  return if args.state.walls
                .any_intersect_rect?(box)

  # Player's box is able to move at angles (not just the four general directions) fast
  args.state.player =
    args.state.player
        .shift_rect(vector.x * args.state.player_speed, # if we don't multiply by speed, then
                    vector.y * args.state.player_speed) # the box will move extremely slow
end
