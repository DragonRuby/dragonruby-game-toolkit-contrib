=begin

 APIs listing that haven't been encountered in previous sample apps:

 - lambda: A way to define a block and its parameters with special syntax.
   For example, the syntax of lambda looks like this:
   my_lambda = -> { puts "This is my lambda" }

 Reminders:
 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.

 - ARRAY#inside_rect?: Returns whether or not the point is inside a rect.

 - product: Returns an array of all combinations of elements from all arrays.

 - find: Finds all elements of a collection that meet requirements.

 - abs: Returns the absolute value.

=end

# This sample app allows the player to move around in the dungeon, which becomes more or less visible
# depending on the player's location, and also has enemies.

class Game
  attr_accessor :args, :state, :inputs, :outputs, :grid

  # Calls all the methods needed for the game to run properly.
  def tick
    defaults
    render_canvas
    render_dungeon
    render_player
    render_enemies
    print_cell_coordinates
    calc_canvas
    input_move
    input_click_map
  end

  # Sets default values and initializes variables
  def defaults
    outputs.background_color = [0, 0, 0] # black background

    # Initializes empty canvas, dungeon, and enemies collections.
    state.canvas   ||= []
    state.dungeon  ||= []
    state.enemies  ||= []

    # If state.area doesn't have value, load_area_one and derive_dungeon_from_area methods are called
    if !state.area
      load_area_one
      derive_dungeon_from_area

      # Changing these values will change the position of player
      state.x = 7
      state.y = 5

      # Creates new enemies, sets their values, and adds them to the enemies collection.
      state.enemies << state.new_entity(:enemy) do |e| # declares each enemy as new entity
        e.x           = 13 # position
        e.y           = 5
        e.previous_hp = 3
        e.hp          = 3
        e.max_hp      = 3
        e.is_dead     = false # the enemy is alive
      end

      update_line_of_sight # updates line of sight by adding newly visible cells
    end
  end

  # Adds elements into the state.area collection
  # The dungeon is derived using the coordinates of this collection
  def load_area_one
    state.area ||= []
    state.area << [8, 6]
    state.area << [7, 6]
    state.area << [7, 7]
    state.area << [8, 9]
    state.area << [7, 8]
    state.area << [7, 9]
    state.area << [6, 4]
    state.area << [7, 3]
    state.area << [7, 4]
    state.area << [6, 5]
    state.area << [7, 5]
    state.area << [8, 5]
    state.area << [8, 4]
    state.area << [1, 1]
    state.area << [0, 1]
    state.area << [0, 2]
    state.area << [1, 2]
    state.area << [2, 2]
    state.area << [2, 1]
    state.area << [2, 3]
    state.area << [1, 3]
    state.area << [1, 4]
    state.area << [2, 4]
    state.area << [2, 5]
    state.area << [1, 5]
    state.area << [2, 6]
    state.area << [3, 6]
    state.area << [4, 6]
    state.area << [4, 7]
    state.area << [4, 8]
    state.area << [5, 8]
    state.area << [5, 9]
    state.area << [6, 9]
    state.area << [7, 10]
    state.area << [7, 11]
    state.area << [7, 12]
    state.area << [7, 12]
    state.area << [7, 13]
    state.area << [8, 13]
    state.area << [9, 13]
    state.area << [10, 13]
    state.area << [11, 13]
    state.area << [12, 13]
    state.area << [12, 12]
    state.area << [8, 12]
    state.area << [9, 12]
    state.area << [10, 12]
    state.area << [11, 12]
    state.area << [12, 11]
    state.area << [13, 11]
    state.area << [13, 10]
    state.area << [13, 9]
    state.area << [13, 8]
    state.area << [13, 7]
    state.area << [13, 6]
    state.area << [12, 6]
    state.area << [14, 6]
    state.area << [14, 5]
    state.area << [13, 5]
    state.area << [12, 5]
    state.area << [12, 4]
    state.area << [13, 4]
    state.area << [14, 4]
    state.area << [1, 6]
    state.area << [6, 6]
  end

  # Starts with an empty dungeon collection, and adds dungeon cells into it.
  def derive_dungeon_from_area
    state.dungeon = [] # starts as empty collection

    state.area.each do |a| # for each element of the area collection
      state.dungeon << state.new_entity(:dungeon_cell) do |d| # declares each dungeon cell as new entity
        d.x = a.x # dungeon cell position using coordinates from area
        d.y = a.y
        d.is_visible = false # cell is not visible
        d.alpha = 0 # not transparent at all
        d.border = [left_margin   + a.x * grid_size,
                    bottom_margin + a.y * grid_size,
                    grid_size,
                    grid_size,
                    *blue,
                    255] # sets border definition for dungeon cell
        d # returns dungeon cell
      end
    end
  end

  def left_margin
    40  # sets left margin
  end

  def bottom_margin
    60 # sets bottom margin
  end

  def grid_size
    40 # sets size of grid square
  end

  # Updates the line of sight by calling the thick_line_of_sight method and
  # adding dungeon cells to the newly_visible collection
  def update_line_of_sight
    variations = [-1, 0, 1]
    # creates collection of newly visible dungeon cells
    newly_visible = variations.product(variations).flat_map do |rise, run| # combo of all elements
      thick_line_of_sight state.x, state.y, rise, run, 15, # calls thick_line_of_sight method
                          lambda { |x, y| dungeon_cell_exists? x, y } # checks whether or not cell exists
    end.uniq# removes duplicates

    state.dungeon.each do |d| # perform action on each element of dungeons collection
      d.is_visible = newly_visible.find { |v| v.x == d.x && v.y == d.y } # finds match inside newly_visible collection
    end
  end

  #Returns a boolean value
  def dungeon_cell_exists? x, y
    # Finds cell coordinates inside dungeon collection to determine if dungeon cell exists
    state.dungeon.find { |d| d.x == x && d.y == y }
  end

  # Calls line_of_sight method to add elements to result collection
  def thick_line_of_sight start_x, start_y, rise, run, distance, cell_exists_lambda
    result = []
    result += line_of_sight start_x, start_y, rise, run, distance, cell_exists_lambda
    result += line_of_sight start_x - 1, start_y, rise, run, distance, cell_exists_lambda # one left
    result += line_of_sight start_x + 1, start_y, rise, run, distance, cell_exists_lambda # one right
    result
  end

  # Adds points to the result collection to create the player's line of sight
  def line_of_sight start_x, start_y, rise, run, distance, cell_exists_lambda
    result = [] # starts as empty collection
    points = points_on_line start_x, start_y, rise, run, distance # calls points_on_line method
    points.each do |p| # for each point in collection
      if cell_exists_lambda.call(p.x, p.y) # if the cell exists
        result << p # add it to result collection
      else # if cell does not exist
        return result # return result collection as it is
      end
    end

    result # return result collection
  end

  # Finds the coordinates of the points on the line by performing calculations
  def points_on_line start_x, start_y, rise, run, distance
    distance.times.map do |i| # perform an action
      [start_x + run * i, start_y + rise * i] # definition of point
    end
  end

  def render_canvas
    return
    outputs.borders << state.canvas.map do |c| # on each element of canvas collection
      c.border # outputs border
    end
  end

  # Outputs the dungeon cells.
  def render_dungeon
    outputs.solids << [0, 0, grid.w, grid.h] # outputs black background for grid

    # Sets the alpha value (opacity) for each dungeon cell and calls the cell_border method.
    outputs.borders << state.dungeon.map do |d| # for each element in dungeon collection
      d.alpha += if d.is_visible # if cell is visible
                 255.fdiv(30) # increment opacity (transparency)
               else # if cell is not visible
                 255.fdiv(600) * -1 # decrease opacity
               end
      d.alpha = d.alpha.cap_min_max(0, 255)
      cell_border d.x, d.y, [*blue, d.alpha] # sets blue border using alpha value
    end.reject_nil
  end

  # Sets definition of a cell border using the parameters
  def cell_border x, y, color = nil
    [left_margin   + x * grid_size,
    bottom_margin + y * grid_size,
    grid_size,
    grid_size,
    *color]
  end

  # Sets the values for the player and outputs it as a label
  def render_player
    outputs.labels << [grid_x(state.x) + 20, # positions "@" text in center of grid square
                     grid_y(state.y) + 35,
                     "@", # player is represented by a white "@" character
                     1, 1, *white]
  end

  def grid_x x
    left_margin + x * grid_size # positions horizontally on grid
  end

  def grid_y y
    bottom_margin + y * grid_size # positions vertically on grid
  end

  # Outputs enemies onto the screen.
  def render_enemies
    state.enemies.map do |e| # for each enemy in the collection
      alpha = 255 # set opacity (full transparency)

      # Outputs an enemy using a label.
      outputs.labels << [
                   left_margin + 20 +  e.x * grid_size, # positions enemy's "r" text in center of grid square
                   bottom_margin + 35 + e.y * grid_size,
                   "r", # enemy's text
                   1, 1, *white, alpha]

      # Creates a red border around an enemy.
      outputs.borders << [grid_x(e.x), grid_y(e.y), grid_size, grid_size, *red]
    end
  end

  #White labels are output for the cell coordinates of each element in the dungeon collection.
  def print_cell_coordinates
    return unless state.debug
    state.dungeon.each do |d|
      outputs.labels << [grid_x(d.x) + 2,
                         grid_y(d.y) - 2,
                         "#{d.x},#{d.y}",
                         -2, 0, *white]
    end
  end

  # Adds new elements into the canvas collection and sets their values.
  def calc_canvas
    return if state.canvas.length > 0 # return if canvas collection has at least one element
    15.times do |x| # 15 times perform an action
      15.times do |y|
        state.canvas << state.new_entity(:canvas) do |c| # declare canvas element as new entity
          c.x = x # set position
          c.y = y
          c.border = [left_margin   + x * grid_size,
                      bottom_margin + y * grid_size,
                      grid_size,
                      grid_size,
                      *white, 30] # sets border definition
        end
      end
    end
  end

  # Updates x and y values of the player, and updates player's line of sight
  def input_move
    x, y, x_diff, y_diff = input_target_cell

    return unless dungeon_cell_exists? x, y # player can't move there if a dungeon cell doesn't exist in that location
    return if enemy_at x, y # player can't move there if there is an enemy in that location

    state.x += x_diff # increments x by x_diff (so player moves left or right)
    state.y += y_diff # same with y and y_diff ( so player moves up or down)
    update_line_of_sight # updates visible cells
  end

  def enemy_at x, y
    # Finds if coordinates exist in enemies collection and enemy is not dead
    state.enemies.find { |e| e.x == x && e.y == y && !e.is_dead }
  end

  #M oves the user based on their keyboard input and sets values for target cell
  def input_target_cell
    if inputs.keyboard.key_down.up # if "up" key is in "down" state
      [state.x, state.y + 1,  0,  1] # user moves up
    elsif inputs.keyboard.key_down.down # if "down" key is pressed
      [state.x, state.y - 1,  0, -1] # user moves down
    elsif inputs.keyboard.key_down.left # if "left" key is pressed
      [state.x - 1, state.y, -1,  0] # user moves left
    elsif inputs.keyboard.key_down.right # if "right" key is pressed
      [state.x + 1, state.y,  1,  0] # user moves right
    else
      nil  # otherwise, empty
    end
  end

  # Goes through the canvas collection to find if the mouse was clicked inside of the borders of an element.
  def input_click_map
    return unless inputs.mouse.click # return unless the mouse is clicked
    canvas_entry = state.canvas.find do |c| # find element from canvas collection that meets requirements
      inputs.mouse.click.inside_rect? c.border # find border that mouse was clicked inside of
    end
    puts canvas_entry # prints canvas_entry value
  end

  # Sets the definition of a label using the parameters.
  def label text, x, y, color = nil
    color ||= white # color is initialized to white
    [x, y, text, 1, 1, *color] # sets label definition
  end

  def green
    [60, 200, 100] # sets color saturation to shade of green
  end

  def blue
    [50, 50, 210] # sets color saturation to shade of blue
  end

  def white
    [255, 255, 255] # sets color saturation to white
  end

  def red
    [230, 80, 80] # sets color saturation to shade of red
  end

  def orange
    [255, 80, 60] # sets color saturation to shade of orange
  end

  def pink
    [255, 0, 200] # sets color saturation to shade of pink
  end

  def gray
    [75, 75, 75] # sets color saturation to shade of gray
  end

  # Recolors the border using the parameters.
  def recolor_border border, r, g, b
    border[4] = r
    border[5] = g
    border[6] = b
    border
  end

  # Returns a boolean value.
  def visible? cell
    # finds cell's coordinates inside visible_cells collections to determine if cell is visible
    state.visible_cells.find { |c| c.x == cell.x && c.y == cell.y}
  end

  # Exports dungeon by printing dungeon cell coordinates
  def export_dungeon
    state.dungeon.each do |d| # on each element of dungeon collection
      puts "state.dungeon << [#{d.x}, #{d.y}]" # prints cell coordinates
    end
  end

  def distance_to_cell cell
    distance_to state.x, cell.x, state.y, cell.y # calls distance_to method
  end

  def distance_to from_x, x, from_y, y
    (from_x - x).abs + (from_y - y).abs # finds distance between two cells using coordinates
  end
end

$game = Game.new

def tick args
  $game.args    = args
  $game.state   = args.state
  $game.inputs  = args.inputs
  $game.outputs = args.outputs
  $game.grid    = args.grid
  $game.tick
end
