=begin
 APIs listing that haven't been encountered in previous sample apps:

 - times: Performs an action a specific number of times.
   For example, if we said
   5.times puts "Hello DragonRuby",
   then we'd see the words "Hello DragonRuby" printed on the console 5 times.

 - split: Divides a string into substrings based on a delimiter.
   For example, if we had a command
   "DragonRuby is awesome".split(" ")
   then the result would be
   ["DragonRuby", "is", "awesome"] because the words are separated by a space delimiter.

 - join: Opposite of split; converts each element of array to a string separated by delimiter.
   For example, if we had a command
   ["DragonRuby","is","awesome"].join(" ")
   then the result would be
   "DragonRuby is awesome".

 Reminders:

 - to_s: Returns a string representation of an object.
   For example, if we had
   500.to_s
   the string "500" would be returned.
   Similar to to_i, which returns an integer representation of an object.

 - elapsed_time: How many frames have passed since the click event.

 - args.outputs.labels: An array. Values in the array generate labels on the screen.
   The parameters are: [X, Y, TEXT, SIZE, ALIGN, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

 - inputs.mouse.down: Determines whether or not the mouse is being pressed down.
   The position of the mouse when it is pressed down can be found using inputs.mouse.down.point.(x|y).

 - first: Returns the first element of the array.

 - num1.idiv(num2): Divides two numbers and returns an integer.

 - find_all: Finds all values that satisfy specific requirements.

 - ARRAY#intersect_rect?: Returns true or false depending on if two rectangles intersect.

 - reject: Removes elements from a collection if they meet certain requirements.

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

=end

MAP_FILE_PATH = 'app/map.txt' # the map.txt file in the app folder contains exported map

class MetroidvaniaStarter
  attr_accessor :grid, :inputs, :state, :outputs, :gtk

  # Calls methods needed to run the game properly.
  def tick
    defaults
    render
    calc
    process_inputs
  end

  # Sets all the default variables.
  # '||' states that initialization occurs only in the first frame.
  def defaults
    state.tile_size                = 64
    state.gravity                  = -0.2
    state.player_width             = 60
    state.player_height            = 64
    state.collision_tolerance      = 0.0
    state.previous_tile_size     ||= state.tile_size
    state.x                      ||= 0
    state.y                      ||= 800
    state.dy                     ||= 0
    state.dx                     ||= 0
    attempt_load_world_from_file
    state.world_lookup           ||= { }
    state.world_collision_rects  ||= []
    state.mode                   ||= :creating # alternates between :creating and :selecting for sprite selection
    state.select_menu            ||= [0, 720, 1280, 720]
    #=======================================IMPORTANT=======================================#
    # When adding sprites, please label them "image1.png", "image2.png", image3".png", etc.
    # Once you have done that, adjust "state.sprite_quantity" to how many sprites you have.
    #=======================================================================================#
    state.sprite_quantity        ||= 20 # IMPORTANT TO ALTER IF SPRITES ADDED IF YOU ADD MORE SPRITES
    state.sprite_coords          ||= []
    state.banner_coords          ||= [640, 680 + 720]
    state.sprite_selected        ||= 1
    state.map_saved_at           ||= 0

    # Sets all the cordinate values for the sprite selection screen into a grid
    # Displayed when 's' is pressed by player to access sprites
    if state.sprite_coords == [] # if sprite_coords is an empty array
      count = 1
      temp_x = 165 # sets a starting x and y position for display
      temp_y = 500 + 720
      state.sprite_quantity.times do # for the number of sprites you have
        state.sprite_coords += [[temp_x, temp_y, count]] # add element to sprite_coords array
        temp_x += 100 # increment temp_x
        count += 1 # increment count
        if temp_x > 1280 - (165 + 50) # if exceeding specific horizontal width on screen
          temp_x = 165 # a new row of sprites starts
          temp_y -= 75 # new row of sprites starts 75 units lower than the previous row
        end
      end
    end
  end

  # Places sprites
  def render

    # Sets the x, y, width, height, and image path for each sprite in the world collection.
    outputs.sprites << state.world.map do |x, y, sprite|
      [x * state.tile_size, # multiply by size so grid coordinates; pixel value of location
       y * state.tile_size,
       state.tile_size,
       state.tile_size,
       'sprites/image' + sprite.to_s + '.png'] # uses concatenation to create unique image path
    end

    # Outputs sprite for the player by setting x, y, width, height, and image path
    outputs.sprites << [state.x,
                        state.y,
                        state.player_width,
                        state.player_height,'sprites/player.png']

    # Outputs labels as primitives in top right of the screen
    outputs.primitives << [920, 700, 'Press \'s\' to access sprites.', 1, 0].label
    outputs.primitives << [920, 675, 'Click existing sprite to delete.', 1, 0].label

    outputs.primitives << [920, 640, '<- and -> to move.', 1, 0].label
    outputs.primitives << [920, 615, 'Press and hold space to jump.', 1, 0].label

    outputs.primitives << [920, 580, 'Press \'e\' to export current map.', 1, 0].label

    # if the map is saved and less than 120 frames have passed, the label is displayed
    if state.map_saved_at > 0 && state.map_saved_at.elapsed_time < 120
      outputs.primitives << [920, 555, 'Map has been exported!', 1, 0, 50, 100, 50].label
    end

    # If player hits 's', following appears
    if state.mode == :selecting
      # White background for sprite selection
      outputs.primitives << [state.select_menu, 255, 255, 255].solid

      # Select tile label at the top of the screen
      outputs.primitives << [state.banner_coords.x, state.banner_coords.y, "Select Sprite (sprites located in \"sprites\" folder)", 10, 1, 0, 0, 0, 255].label

      # Places sprites in locations calculated in the defaults function
      outputs.primitives << state.sprite_coords.map do |x, y, order|
        [x, y, 50, 50, 'sprites/image' + order.to_s + ".png"].sprite
      end
    end

    # Creates sprite following mouse to help indicate which sprite you have selected
    # 10 is subtracted from the mouse's x position so that the sprite is not covered by the mouse icon
    outputs.primitives << [inputs.mouse.position.x - 10, inputs.mouse.position.y,
                           10, 10, 'sprites/image' + state.sprite_selected.to_s + ".png"].sprite
  end

  # Calls methods that perform calculations
  def calc
    calc_in_game
    calc_sprite_selection
  end

  # Calls methods that perform calculations (if in creating mode)
  def calc_in_game
    return unless state.mode == :creating
    calc_world_lookup
    calc_player
  end

  def calc_world_lookup
    # If the tile size isn't equal to the previous tile size,
    # the previous tile size is set to the tile size,
    # and world_lookup hash is set to empty.
    if state.tile_size != state.previous_tile_size
      state.previous_tile_size = state.tile_size
      state.world_lookup = {}
    end

    # return if world_lookup is not empty or if world is empty
    return if state.world_lookup.keys.length > 0
    return unless state.world.length > 0

    # Searches through the world and finds the coordinates that exist
    state.world_lookup = {}
    state.world.each { |x, y| state.world_lookup[[x, y]] = true }

    # Assigns collision rects for every sprite drawn
    state.world_collision_rects =
      state.world_lookup
           .keys
           .map do |coord_x, coord_y|
             s = state.tile_size
             # Multiplying by s (the size of a tile) ensures that the rect is
             # placed exactly where you want it to be placed (causes grid to coordinate)
             # How many pixels horizontally across and vertically up and down
             x = s * coord_x
             y = s * coord_y
             {
               args:       [coord_x, coord_y],
               left_right: [x,     y + 4, s,     s - 6], # hash keys and values
               top:        [x + 4, y + 6, s - 8, s - 6],
               bottom:     [x + 1, y - 1, s - 2, s - 8],
             }
           end
  end

  # Calculates movement of player and calls methods that perform collision calculations
  def calc_player
    state.dy += state.gravity  # what goes up must come down because of gravity
    calc_box_collision
    calc_edge_collision
    state.y  += state.dy       # Since velocity is the change in position, the change in y increases by dy
    state.x  += state.dx       # Ditto line above but dx and x
    state.dx *= 0.8            # Scales dx down
  end

  # Calls methods that determine whether the player collides with any world_collision_rects.
  def calc_box_collision
    return unless state.world_lookup.keys.length > 0 # return unless hash has atleast 1 key
    collision_floor
    collision_left
    collision_right
    collision_ceiling
  end

  # Finds collisions between the bottom of the player's rect and the top of a world_collision_rect.
  def collision_floor
    return unless state.dy <= 0 # return unless player is going down or is as far down as possible
    player_rect = [state.x, next_y, state.tile_size, state.tile_size] # definition of player

    # Runs through all the sprites on the field and finds all intersections between player's
    # bottom and the top of a rect.
    floor_collisions = state.world_collision_rects
                         .find_all { |r| r[:top].intersect_rect?(player_rect, state.collision_tolerance) }
                         .first

    return unless floor_collisions # performs following changes if a collision has occurred
    state.y = floor_collisions[:top].top # y of player is set to the y of the colliding rect's top
    state.dy = 0 # no change in y because the player's path is blocked
  end

  # Finds collisions between the player's left side and the right side of a world_collision_rect.
  def collision_left
    return unless state.dx < 0 # return unless player is moving left
    player_rect = [next_x, state.y, state.tile_size, state.tile_size]

    # Runs through all the sprites on the field and finds all intersections between the player's left side
    # and the right side of a rect.
    left_side_collisions = state.world_collision_rects
                             .find_all { |r| r[:left_right].intersect_rect?(player_rect, state.collision_tolerance) }
                             .first

    return unless left_side_collisions # return unless collision occurred
    state.x = left_side_collisions[:left_right].right # sets player's x to the x of the colliding rect's right side
    state.dx = 0 # no change in x because the player's path is blocked
  end

  # Finds collisions between the right side of the player and the left side of a world_collision_rect.
  def collision_right
    return unless state.dx > 0 # return unless player is moving right
    player_rect = [next_x, state.y, state.tile_size, state.tile_size]

    # Runs through all the sprites on the field and finds all intersections between the  player's
    # right side and the left side of a rect.
    right_side_collisions = state.world_collision_rects
                              .find_all { |r| r[:left_right].intersect_rect?(player_rect, state.collision_tolerance) }
                              .first

    return unless right_side_collisions # return unless collision occurred
    state.x = right_side_collisions[:left_right].left - state.tile_size # player's x is set to the x of colliding rect's left side (minus tile size since x is the player's bottom left corner)
    state.dx = 0 # no change in x because the player's path is blocked
  end

  # Finds collisions between the top of the player's rect and the bottom of a world_collision_rect.
  def collision_ceiling
    return unless state.dy > 0 # return unless player is moving up
    player_rect = [state.x, next_y, state.player_width, state.player_height]

    # Runs through all the sprites on the field and finds all intersections between the player's top
    # and the bottom of a rect.
    ceil_collisions = state.world_collision_rects
                        .find_all { |r| r[:bottom].intersect_rect?(player_rect, state.collision_tolerance) }
                        .first

    return unless ceil_collisions # return unless collision occurred
    state.y = ceil_collisions[:bottom].y - state.tile_size # player's y is set to the y of the colliding rect's bottom (minus tile size)
    state.dy = 0 # no change in y because the player's path is blocked
  end

  # Makes sure the player remains within the screen's dimensions.
  def calc_edge_collision
    # Ensures that player doesn't fall below the map
    if next_y < 0 && state.dy < 0 # if player is moving down and is about to fall (next_y) below the map's scope
      state.y = 0 # 0 is the lowest the player can be while staying on the screen
      state.dy = 0
    # Ensures player doesn't go insanely high
    elsif next_y > 720 - state.tile_size && state.dy > 0 # if player is moving up, about to exceed map's scope
      state.y = 720 - state.tile_size # if we don't subtract tile_size, we won't be able to see the player on the screen
      state.dy = 0
    end

    # Ensures that player remains in the horizontal range its supposed to
    if state.x >= 1280 - state.tile_size && state.dx > 0 # if the player is moving too far right
      state.x = 1280 - state.tile_size # farthest right the player can be while remaining in the screen's scope
      state.dx = 0
    elsif state.x <= 0 && state.dx < 0 # if the player is moving too far left
      state.x = 0 # farthest left the player can be while remaining in the screen's scope
      state.dx = 0
    end
  end

  def calc_sprite_selection
    # Does the transition to bring down the select sprite screen
    if state.mode == :selecting && state.select_menu.y != 0
      state.select_menu.y = 0  # sets y position of select menu (shown when 's' is pressed)
      state.banner_coords.y = 680 # sets y position of Select Sprite banner
      state.sprite_coords = state.sprite_coords.map do |x, y, w, h|
        [x, y - 720, w, h] # sets definition of sprites (change '-' to '+' and the sprites can't be seen)
      end
    end

    # Does the transition to leave the select sprite screen
    if state.mode == :creating  && state.select_menu.y != 720
      state.select_menu.y = 720 # sets y position of select menu (menu is retreated back up)
      state.banner_coords.y = 1000 # sets y position of Select Sprite banner
      state.sprite_coords = state.sprite_coords.map do |x, y, w, h|
        [x, y + 720, w, h] # sets definition of all elements in collection
      end
    end
  end

  def process_inputs
    # If the state.mode is back and if the menu has retreated back up
    # call methods that process user inputs
    if state.mode == :creating
      process_inputs_player_movement
      process_inputs_place_tile
    end

    # For each sprite_coordinate added, check what sprite was selected
    if state.mode == :selecting
      state.sprite_coords.map do |x, y, order| # goes through all sprites in collection
        # checks that a specific sprite was pressed based on x, y position
        if inputs.mouse.down && # the && (and) sign means ALL statements must be true for the evaluation to be true
           inputs.mouse.down.point.x >= x      && # x is greater than or equal to sprite's x and
           inputs.mouse.down.point.x <= x + 50 && # x is less than or equal to 50 pixels to the right
           inputs.mouse.down.point.y >= y      && # y is greater than or equal to sprite's y
           inputs.mouse.down.point.y <= y + 50 # y is less than or equal to 50 pixels up
          state.sprite_selected = order # sprite is chosen
        end
      end
    end

    inputs_export_stage
    process_inputs_show_available_sprites
  end

  # Moves the player based on the keys they press on their keyboard
  def process_inputs_player_movement
    # Sets dx to 0 if the player lets go of arrow keys (player won't move left or right)
    if inputs.keyboard.key_up.right
      state.dx = 0
    elsif inputs.keyboard.key_up.left
      state.dx = 0
    end

    # Sets dx to 3 in whatever direction the player chooses when they hold down (or press) the left or right keys
    if inputs.keyboard.key_held.right
      state.dx =  3
    elsif inputs.keyboard.key_held.left
      state.dx = -3
    end

    # Sets dy to 5 to make the player ~fly~ when they press the space bar on their keyboard
    if inputs.keyboard.key_held.space
      state.dy = 5
    end
  end

  # Adds tile in the place the user holds down the mouse
  def process_inputs_place_tile
    if inputs.mouse.down # if mouse is pressed
      state.world_lookup = {}
      x, y = to_coord inputs.mouse.down.point # gets x, y coordinates for the grid

      # Checks if any coordinates duplicate (already exist in world)
      if state.world.any? { |existing_x, existing_y, n| existing_x == x && existing_y == y }
        #erases existing tile space by rejecting them from world
        state.world = state.world.reject do |existing_x, existing_y, n|
          existing_x == x && existing_y == y
        end
      else
        state.world << [x, y, state.sprite_selected] # If no duplicates, add the sprite
      end
    end
  end

  # Stores/exports world collection's info (coordinates, sprite number) into a file
  def inputs_export_stage
    if inputs.keyboard.key_down.e # if "e" is pressed
      export_string = state.world.map do |x, y, sprite_number| # stores world info in a string
        "#{x},#{y},#{sprite_number}"                           # using string interpolation
      end
      gtk.write_file(MAP_FILE_PATH, export_string.join("\n")) # writes string into a file
      state.map_saved_at = state.tick_count # frame number (passage of time) when the map was saved
    end
  end

  def process_inputs_show_available_sprites
    # Based on keyboard input, the entity (:creating and :selecting) switch
    if inputs.keyboard.key_held.s && state.mode == :creating # if "s" is pressed and currently creating
      state.mode = :selecting # will change to selecting
      inputs.keyboard.clear # VERY IMPORTANT! If not present, it'll flicker between on and off
    elsif inputs.keyboard.key_held.s && state.mode == :selecting # if "s" is pressed and currently selecting
      state.mode = :creating # will change to creating
      inputs.keyboard.clear # VERY IMPORTANT! If not present, it'll flicker between on and off
    end
  end

  # Loads the world collection by reading from the map.txt file in the app folder
  def attempt_load_world_from_file
    return if state.world # return if the world collection is already populated
    state.world ||= [] # initialized as an empty collection
    exported_world = gtk.read_file(MAP_FILE_PATH) # reads the file using the path mentioned at top of code
    return unless exported_world # return unless the file read was successful
    state.world = exported_world.each_line.map do |l| # perform action on each line of exported_world
        l.split(',').map(&:to_i) # calls split using ',' as a delimiter, and invokes .map on the collection,
                                 # calling to_i (converts to integers) on each element
    end
  end

  # Adds the change in y to y to determine the next y position of the player.
  def next_y
    state.y + state.dy
  end

  # Determines next x position of player
  def next_x
    if state.dx < 0 # if the player moves left
      return state.x - (state.tile_size - state.player_width) # subtracts since the change in x is negative (player is moving left)
    else
      return state.x + (state.tile_size - state.player_width) # adds since the change in x is positive (player is moving right)
    end
  end

  def to_coord point
    # Integer divides (idiv) point.x to turn into grid
    # Then, you can just multiply each integer by state.tile_size
    # later and huzzah. Grid coordinates
    [point.x.idiv(state.tile_size), point.y.idiv(state.tile_size)]
  end
end

$metroidvania_starter = MetroidvaniaStarter.new

def tick args
    $metroidvania_starter.grid    = args.grid
    $metroidvania_starter.inputs  = args.inputs
    $metroidvania_starter.state   = args.state
    $metroidvania_starter.outputs = args.outputs
    $metroidvania_starter.gtk     = args.gtk
    $metroidvania_starter.tick
end
