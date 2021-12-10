# Demonstrates how Dijkstra's Algorithm allows movement costs to be considered

# Inspired by https://www.redblobgames.com/pathfinding/a-star/introduction.html

# The first grid is a breadth first search with an early exit.
# It shows a heat map of all the cells that were visited by the search and their relative distance.

# The second grid is an implementation of Dijkstra's algorithm.
# Light green cells have 5 times the movement cost of regular cells.
# The heat map will darken based on movement cost.

# Dark green cells are walls, and the search cannot go through them.
class Movement_Costs
  attr_gtk

  # This method is called every frame/tick
  # Every tick, the current state of the search is rendered on the screen,
  # User input is processed, and
  # The next step in the search is calculated
  def tick
    defaults
    render
    input
    calc
  end

  def defaults
    # Variables to edit the size and appearance of the grid
    # Freely customizable to user's liking
    grid.width     ||= 10
    grid.height    ||= 10
    grid.cell_size ||= 60
    grid.rect      ||= [0, 0, grid.width, grid.height]

    # The location of the star and walls of the grid
    # They can be modified to have a different initial grid
    # Walls are stored in a hash for quick look up when doing the search
    state.star   ||= [1, 5]
    state.target ||= [8, 4]
    state.walls  ||= {[1, 1] => true, [2, 1] => true, [3, 1] => true, [1, 2] => true, [2, 2] => true, [3, 2] => true}
    state.hills  ||= {
      [4, 1] => true,
      [5, 1] => true,
      [4, 2] => true,
      [5, 2] => true,
      [6, 2] => true,
      [4, 3] => true,
      [5, 3] => true,
      [6, 3] => true,
      [3, 4] => true,
      [4, 4] => true,
      [5, 4] => true,
      [6, 4] => true,
      [7, 4] => true,
      [3, 5] => true,
      [4, 5] => true,
      [5, 5] => true,
      [6, 5] => true,
      [7, 5] => true,
      [4, 6] => true,
      [5, 6] => true,
      [6, 6] => true,
      [7, 6] => true,
      [4, 7] => true,
      [5, 7] => true,
      [6, 7] => true,
      [4, 8] => true,
      [5, 8] => true,
    }

    # What the user is currently editing on the grid
    # We store this value, because we want to remember the value even when
    # the user's cursor is no longer over what they're interacting with, but
    # they are still clicking down on the mouse.
    state.user_input ||= :none

    # Values that are used for the breadth first search
    # Keeping track of what cells were visited prevents counting cells multiple times
    breadth_first_search.visited    ||= {}
    # The cells from which the breadth first search will expand
    breadth_first_search.frontier   ||= []
    # Keeps track of which cell all cells were searched from
    # Used to recreate the path from the target to the star
    breadth_first_search.came_from  ||= {}

    # Keeps track of the movement cost so far to be at a cell
    # Allows the costs of new cells to be quickly calculated
    # Also doubles as a way to check if cells have already been visited
    dijkstra_search.cost_so_far ||= {}
    # The cells from which the Dijkstra search will expand
    dijkstra_search.frontier    ||= []
    # Keeps track of which cell all cells were searched from
    # Used to recreate the path from the target to the star
    dijkstra_search.came_from   ||= {}
  end

  # Draws everything onto the screen
  def render
    render_background

    render_heat_maps

    render_star
    render_target
    render_hills
    render_walls

    render_paths
  end
  # The methods below subdivide the task of drawing everything to the screen

  # Draws what the grid looks like with nothing on it
  def render_background
    render_unvisited
    render_grid_lines
    render_labels
  end

  # Draws two rectangles the size of the grid in the default cell color
  # Used as part of the background
  def render_unvisited
    outputs.solids << [scale_up(grid.rect), unvisited_color]
    outputs.solids << [move_and_scale_up(grid.rect), unvisited_color]
  end

  # Draws grid lines to show the division of the grid into cells
  def render_grid_lines
    for x in 0..grid.width
      outputs.lines << vertical_line(x)
      outputs.lines << shifted_vertical_line(x)
    end

    for y in 0..grid.height
      outputs.lines << horizontal_line(y)
      outputs.lines << shifted_horizontal_line(y)
    end
  end

  # Easy way to draw vertical lines given an index for the first grid
  def vertical_line column
    scale_up([column, 0, column, grid.height])
  end

  # Easy way to draw horizontal lines given an index for the second grid
  def horizontal_line row
    scale_up([0, row, grid.width, row])
  end

  # Easy way to draw vertical lines given an index for the first grid
  def shifted_vertical_line column
    scale_up([column + grid.width + 1, 0, column + grid.width + 1, grid.height])
  end

  # Easy way to draw horizontal lines given an index for the second grid
  def shifted_horizontal_line row
    scale_up([grid.width + 1, row, grid.width + grid.width + 1, row])
  end

  # Labels the grids
  def render_labels
    outputs.labels << [175, 650, "Number of steps", 3]
    outputs.labels << [925, 650, "Distance", 3]
  end

  def render_paths
    render_breadth_first_search_path
    render_dijkstra_path
  end

  def render_heat_maps
    render_breadth_first_search_heat_map
    render_dijkstra_heat_map
  end

  # Renders the breadth first search on the first grid
  def render_breadth_first_search
  end

  # This heat map shows the cells explored by the breadth first search and how far they are from the star.
  def render_breadth_first_search_heat_map
    # For each cell explored
    breadth_first_search.visited.each_key do | visited_cell |
      # Find its distance from the star
      distance = (state.star.x - visited_cell.x).abs + (state.star.y - visited_cell.y).abs
      max_distance = grid.width + grid.height
      # Get it as a percent of the maximum distance and scale to 255 for use as an alpha value
      alpha = 255.to_i * distance.to_i / max_distance.to_i
      outputs.solids << [scale_up(visited_cell), red, alpha]
    end
  end

  def render_breadth_first_search_path
    # If the search found the target
    if breadth_first_search.visited.has_key?(state.target)
      # Start from the target
      endpoint = state.target
      # And the cell it came from
      next_endpoint = breadth_first_search.came_from[endpoint]
      while endpoint and next_endpoint
        # Draw a path between these two cells
        path = get_path_between(endpoint, next_endpoint)
        outputs.solids << [scale_up(path), path_color]
        # And get the next pair of cells
        endpoint = next_endpoint
        next_endpoint = breadth_first_search.came_from[endpoint]
        # Continue till there are no more cells
      end
    end
  end

  # Renders the Dijkstra search on the second grid
  def render_dijkstra
  end

  def render_dijkstra_heat_map
    dijkstra_search.cost_so_far.each do |visited_cell, cost|
      max_cost = (grid.width + grid.height) #* 5
      alpha = 255.to_i * cost.to_i / max_cost.to_i
      outputs.solids << [move_and_scale_up(visited_cell), red, alpha]
    end
  end

  def render_dijkstra_path
    # If the search found the target
    if dijkstra_search.came_from.has_key?(state.target)
      # Get the target and the cell it came from
      endpoint = state.target
      next_endpoint = dijkstra_search.came_from[endpoint]
      while endpoint and next_endpoint
        # Draw a path between them
        path = get_path_between(endpoint, next_endpoint)
        outputs.solids << [move_and_scale_up(path), path_color]

        # Shift one cell down the path
        endpoint = next_endpoint
        next_endpoint = dijkstra_search.came_from[endpoint]

        # Repeat till the end of the path
      end
    end
  end

  # Renders the star on both grids
  def render_star
    outputs.sprites << [scale_up(state.star), 'star.png']
    outputs.sprites << [move_and_scale_up(state.star), 'star.png']
  end

  # Renders the target on both grids
  def render_target
    outputs.sprites << [scale_up(state.target), 'target.png']
    outputs.sprites << [move_and_scale_up(state.target), 'target.png']
  end

  def render_hills
    state.hills.each_key do |hill|
      outputs.solids << [scale_up(hill), hill_color]
      outputs.solids << [move_and_scale_up(hill), hill_color]
    end
  end

  # Draws the walls on both grids
  def render_walls
    state.walls.each_key do |wall|
      outputs.solids << [scale_up(wall), wall_color]
      outputs.solids << [move_and_scale_up(wall), wall_color]
    end
  end

  def get_path_between(cell_one, cell_two)
    path = nil
    if cell_one.x == cell_two.x
      if cell_one.y < cell_two.y
        path = [cell_one.x + 0.3, cell_one.y + 0.3, 0.4, 1.4]
      else
        path = [cell_two.x + 0.3, cell_two.y + 0.3, 0.4, 1.4]
      end
    else
      if cell_one.x < cell_two.x
        path = [cell_one.x + 0.3, cell_one.y + 0.3, 1.4, 0.4]
      else
        path = [cell_two.x + 0.3, cell_two.y + 0.3, 1.4, 0.4]
      end
    end
    path
  end

  # Representation of how far away visited cells are from the star
  # Replaces the render_visited method
  # Visually demonstrates the effectiveness of early exit for pathfinding
  def render_breadth_first_search_heat_map
    breadth_first_search.visited.each_key do | visited_cell |
      distance = (state.star.x - visited_cell.x).abs + (state.star.y - visited_cell.y).abs
      max_distance = grid.width + grid.height
      alpha = 255.to_i * distance.to_i / max_distance.to_i
      outputs.solids << [scale_up(visited_cell), red, alpha]
    end
  end

  # Translates the given cell grid.width + 1 to the right and then scales up
  # Used to draw cells for the second grid
  # This method does not work for lines,
  # so separate methods exist for the grid lines
  def move_and_scale_up(cell)
    cell_clone = cell.clone
    cell_clone.x += grid.width + 1
    scale_up(cell_clone)
  end

  # In code, the cells are represented as 1x1 rectangles
  # When drawn, the cells are larger than 1x1 rectangles
  # This method is used to scale up cells, and lines
  # Objects are scaled up according to the grid.cell_size variable
  # This allows for easy customization of the visual scale of the grid
  def scale_up(cell)
    # Prevents the original value of cell from being edited
    cell = cell.clone

    # If cell is just an x and y coordinate
    if cell.size == 2
      # Add a width and height of 1
      cell << 1
      cell << 1
    end

    # Scale all the values up
    cell.map! { |value| value * grid.cell_size }

    # Returns the scaled up cell
    cell
  end

  # Handles user input every tick so the grid can be edited
  # Separate input detection and processing is needed
  # For example: Adding walls is started by clicking down on a hill,
  # but the mouse doesn't need to remain over hills to add walls
  def input
    # If the mouse was lifted this tick
    if inputs.mouse.up
      # Set current input to none
      state.user_input = :none
    end

    # If the mouse was clicked this tick
    if inputs.mouse.down
      # Determine what the user is editing and edit the state.user_input variable
      determine_input
    end

    # Process user input based on user_input variable and current mouse position
    process_input
  end

  # Determines what the user is editing and stores the value
  # This method is called the tick the mouse is clicked
  # Storing the value allows the user to continue the same edit as long as the
  # mouse left click is held
  def determine_input
    # If the mouse is over the star in the first grid
    if mouse_over_star?
      # The user is editing the star from the first grid
      state.user_input = :star
    # If the mouse is over the star in the second grid
    elsif mouse_over_star2?
      # The user is editing the star from the second grid
      state.user_input = :star2
    # If the mouse is over the target in the first grid
    elsif mouse_over_target?
      # The user is editing the target from the first grid
      state.user_input = :target
    # If the mouse is over the target in the second grid
    elsif mouse_over_target2?
      # The user is editing the target from the second grid
      state.user_input = :target2
    # If the mouse is over a wall in the first grid
    elsif mouse_over_wall?
      # The user is removing a wall from the first grid
      state.user_input = :remove_wall
    # If the mouse is over a wall in the second grid
    elsif mouse_over_wall2?
      # The user is removing a wall from the second grid
      state.user_input = :remove_wall2
    # If the mouse is over a hill in the first grid
    elsif mouse_over_hill?
      # The user is adding a wall from the first grid
      state.user_input = :add_wall
    # If the mouse is over a hill in the second grid
    elsif mouse_over_hill2?
      # The user is adding a wall from the second grid
      state.user_input = :add_wall2
    # If the mouse is over the first grid
    elsif mouse_over_grid?
      # The user is adding a hill from the first grid
      state.user_input = :add_hill
    # If the mouse is over the second grid
    elsif mouse_over_grid2?
      # The user is adding a hill from the second grid
      state.user_input = :add_hill2
    end
  end

  # Processes click and drag based on what the user is currently dragging
  def process_input
    if state.user_input == :star
      input_star
    elsif state.user_input == :star2
      input_star2
    elsif state.user_input == :target
      input_target
    elsif state.user_input == :target2
      input_target2
    elsif state.user_input == :remove_wall
      input_remove_wall
    elsif state.user_input == :remove_wall2
      input_remove_wall2
    elsif state.user_input == :add_hill
      input_add_hill
    elsif state.user_input == :add_hill2
      input_add_hill2
    elsif state.user_input == :add_wall
      input_add_wall
    elsif state.user_input == :add_wall2
      input_add_wall2
    end
  end

  # Calculates the two searches
  def calc
    # If the searches have not started
    if breadth_first_search.visited.empty?
      # Calculate the two searches
      calc_breadth_first
      calc_dijkstra
    end
  end


  def calc_breadth_first
    # Sets up the Breadth First Search
    breadth_first_search.visited[state.star]   = true
    breadth_first_search.frontier              << state.star
    breadth_first_search.came_from[state.star] = nil

    until breadth_first_search.frontier.empty?
      return if breadth_first_search.visited.has_key?(state.target)
      # A step in the search
      # Takes the next frontier cell
      new_frontier = breadth_first_search.frontier.shift
      # For each of its neighbors
      adjacent_neighbors(new_frontier).each do | neighbor |
        # That have not been visited and are not walls
        unless breadth_first_search.visited.has_key?(neighbor) || state.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited in the first grid
          breadth_first_search.visited[neighbor] = true
          breadth_first_search.frontier << neighbor
          # Remember which cell the neighbor came from
          breadth_first_search.came_from[neighbor] = new_frontier
        end
      end
    end
  end

  # Calculates the Dijkstra Search from the beginning to the end

  def calc_dijkstra
    # The initial values for the Dijkstra search
    dijkstra_search.frontier                << [state.star, 0]
    dijkstra_search.came_from[state.star]   = nil
    dijkstra_search.cost_so_far[state.star] = 0

    # Until their are no more cells to be explored
    until dijkstra_search.frontier.empty?
      # Get the next cell to be explored from
      # We get the first element of the array which is the cell. The second element is the priority.
      current = dijkstra_search.frontier.shift[0]

      # Stop the search if we found the target
      return if current == state.target

      # For each of the neighbors
      adjacent_neighbors(current).each do | neighbor |
        # Unless this cell is a wall or has already been explored.
        unless dijkstra_search.came_from.has_key?(neighbor) or state.walls.has_key?(neighbor)
          # Calculate the movement cost of getting to this cell and memo
          new_cost = dijkstra_search.cost_so_far[current] + cost(neighbor)
          dijkstra_search.cost_so_far[neighbor] = new_cost

          # Add this neighbor to the cells too be explored
          dijkstra_search.frontier << [neighbor, new_cost]
          dijkstra_search.came_from[neighbor] = current
        end
      end

      # Sort the frontier so exploration occurs that have a low cost so far.
      # My implementation of a priority queue
      dijkstra_search.frontier = dijkstra_search.frontier.sort_by {|cell, priority| priority}
    end
  end

  def cost(cell)
    if state.hills.has_key?(cell)
      return 5
    else
      return 1
    end
  end




  # Moves the star to the cell closest to the mouse in the first grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def input_star
    old_star = state.star.clone
    unless cell_closest_to_mouse == state.target
      state.star = cell_closest_to_mouse
    end
    unless old_star == state.star
      reset_search
    end
  end

  # Moves the star to the cell closest to the mouse in the second grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def input_star2
    old_star = state.star.clone
    unless cell_closest_to_mouse2 == state.target
      state.star = cell_closest_to_mouse2
    end
    unless old_star == state.star
      reset_search
    end
  end

  # Moves the target to the grid closest to the mouse in the first grid
  # Only reset_searchs the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def input_target
    old_target = state.target.clone
    unless cell_closest_to_mouse == state.star
      state.target = cell_closest_to_mouse
    end
    unless old_target == state.target
      reset_search
    end
  end

  # Moves the target to the cell closest to the mouse in the second grid
  # Only reset_searchs the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def input_target2
    old_target = state.target.clone
    unless cell_closest_to_mouse2 == state.star
      state.target = cell_closest_to_mouse2
    end
    unless old_target == state.target
      reset_search
    end
  end

  # Removes walls in the first grid that are under the cursor
  def input_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if mouse_over_grid?
      if state.walls.has_key?(cell_closest_to_mouse) or state.hills.has_key?(cell_closest_to_mouse)
        state.walls.delete(cell_closest_to_mouse)
        state.hills.delete(cell_closest_to_mouse)
        reset_search
      end
    end
  end

  # Removes walls in the second grid that are under the cursor
  def input_remove_wall2
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if mouse_over_grid2?
      if state.walls.has_key?(cell_closest_to_mouse2) or state.hills.has_key?(cell_closest_to_mouse2)
        state.walls.delete(cell_closest_to_mouse2)
        state.hills.delete(cell_closest_to_mouse2)
        reset_search
      end
    end
  end

  # Adds a hill in the first grid in the cell the mouse is over
  def input_add_hill
    if mouse_over_grid?
      unless state.hills.has_key?(cell_closest_to_mouse)
        state.hills[cell_closest_to_mouse] = true
        reset_search
      end
    end
  end


  # Adds a hill in the second grid in the cell the mouse is over
  def input_add_hill2
    if mouse_over_grid2?
      unless state.hills.has_key?(cell_closest_to_mouse2)
        state.hills[cell_closest_to_mouse2] = true
        reset_search
      end
    end
  end

  # Adds a wall in the first grid in the cell the mouse is over
  def input_add_wall
    if mouse_over_grid?
      unless state.walls.has_key?(cell_closest_to_mouse)
        state.hills.delete(cell_closest_to_mouse)
        state.walls[cell_closest_to_mouse] = true
        reset_search
      end
    end
  end

  # Adds a wall in the second grid in the cell the mouse is over
  def input_add_wall2
    if mouse_over_grid2?
      unless state.walls.has_key?(cell_closest_to_mouse2)
        state.hills.delete(cell_closest_to_mouse2)
        state.walls[cell_closest_to_mouse2] = true
        reset_search
      end
    end
  end

  # Whenever the user edits the grid,
  # The search has to be reset_searchd upto the current step
  # with the current grid as the initial state of the grid
  def reset_search
    breadth_first_search.visited    = {}
    breadth_first_search.frontier   = []
    breadth_first_search.came_from  = {}

    dijkstra_search.frontier    = []
    dijkstra_search.came_from   = {}
    dijkstra_search.cost_so_far = {}
  end



  # Returns a list of adjacent cells
  # Used to determine what the next cells to be added to the frontier are
  def adjacent_neighbors(cell)
    neighbors = []

    # Gets all the valid neighbors into the array
    # From southern neighbor, clockwise
    neighbors << [cell.x    , cell.y - 1] unless cell.y == 0
    neighbors << [cell.x - 1, cell.y    ] unless cell.x == 0
    neighbors << [cell.x    , cell.y + 1] unless cell.y == grid.height - 1
    neighbors << [cell.x + 1, cell.y    ] unless cell.x == grid.width - 1

    # Sorts the neighbors so the rendered path is a zigzag path
    # Cells in a diagonal direction are given priority
    # Comment this line to see the difference
    neighbors = neighbors.sort_by { |neighbor_x, neighbor_y|  proximity_to_star(neighbor_x, neighbor_y) }

    neighbors
  end

  # Finds the vertical and horizontal distance of a cell from the star
  # and returns the larger value
  # This method is used to have a zigzag pattern in the rendered path
  # A cell that is [5, 5] from the star,
  # is explored before over a cell that is [0, 7] away.
  # So, if possible, the search tries to go diagonal (zigzag) first
  def proximity_to_star(x, y)
    distance_x = (state.star.x - x).abs
    distance_y = (state.star.y - y).abs

    if distance_x > distance_y
      return distance_x
    else
      return distance_y
    end
  end

  # When the user grabs the star and puts their cursor to the far right
  # and moves up and down, the star is supposed to move along the grid as well
  # Finding the cell closest to the mouse helps with this
  def cell_closest_to_mouse
    # Closest cell to the mouse in the first grid
    x = (inputs.mouse.point.x / grid.cell_size).to_i
    y = (inputs.mouse.point.y / grid.cell_size).to_i
    # Bound x and y to the grid
    x = grid.width - 1 if x > grid.width - 1
    y = grid.height - 1 if y > grid.height - 1
    # Return closest cell
    [x, y]
  end

  # When the user grabs the star and puts their cursor to the far right
  # and moves up and down, the star is supposed to move along the grid as well
  # Finding the cell closest to the mouse in the second grid helps with this
  def cell_closest_to_mouse2
    # Closest cell grid to the mouse in the second
    x = (inputs.mouse.point.x / grid.cell_size).to_i
    y = (inputs.mouse.point.y / grid.cell_size).to_i
    # Translate the cell to the first grid
    x -= grid.width + 1
    # Bound x and y to the first grid
    x = 0 if x < 0
    y = 0 if y < 0
    x = grid.width - 1 if x > grid.width - 1
    y = grid.height - 1 if y > grid.height - 1
    # Return closest cell
    [x, y]
  end

  # Signal that the user is going to be moving the star from the first grid
  def mouse_over_star?
    inputs.mouse.point.inside_rect?(scale_up(state.star))
  end

  # Signal that the user is going to be moving the star from the second grid
  def mouse_over_star2?
    inputs.mouse.point.inside_rect?(move_and_scale_up(state.star))
  end

  # Signal that the user is going to be moving the target from the first grid
  def mouse_over_target?
    inputs.mouse.point.inside_rect?(scale_up(state.target))
  end

  # Signal that the user is going to be moving the target from the second grid
  def mouse_over_target2?
    inputs.mouse.point.inside_rect?(move_and_scale_up(state.target))
  end

  # Signal that the user is going to be removing walls from the first grid
  def mouse_over_wall?
    state.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(scale_up(wall))
    end

    false
  end

  # Signal that the user is going to be removing walls from the second grid
  def mouse_over_wall2?
    state.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(move_and_scale_up(wall))
    end

    false
  end

  # Signal that the user is going to be removing hills from the first grid
  def mouse_over_hill?
    state.hills.each_key do | hill |
      return true if inputs.mouse.point.inside_rect?(scale_up(hill))
    end

    false
  end

  # Signal that the user is going to be removing hills from the second grid
  def mouse_over_hill2?
    state.hills.each_key do | hill |
      return true if inputs.mouse.point.inside_rect?(move_and_scale_up(hill))
    end

    false
  end

  # Signal that the user is going to be adding walls from the first grid
  def mouse_over_grid?
    inputs.mouse.point.inside_rect?(scale_up(grid.rect))
  end

  # Signal that the user is going to be adding walls from the second grid
  def mouse_over_grid2?
    inputs.mouse.point.inside_rect?(move_and_scale_up(grid.rect))
  end

  # These methods provide handy aliases to colors

  # Light brown
  def unvisited_color
    [221, 212, 213]
  end

  # Camo Green
  def wall_color
    [134, 134, 120]
  end

  # Pastel White
  def path_color
    [231, 230, 228]
  end

  def red
    [255, 0, 0]
  end

  # A Green
  def hill_color
    [139, 173, 132]
  end

  # Makes code more concise
  def grid
    state.grid
  end

  def breadth_first_search
    state.breadth_first_search
  end

  def dijkstra_search
    state.dijkstra_search
  end
end

# Method that is called by DragonRuby periodically
# Used for updating animations and calculations
def tick args

  # Pressing r will reset the application
  if args.inputs.keyboard.key_down.r
    args.gtk.reset
    reset
    return
  end

  # Every tick, new args are passed, and the Dijkstra tick method is called
  $movement_costs ||= Movement_Costs.new
  $movement_costs.args = args
  $movement_costs.tick
end


def reset
  $movement_costs = nil
end
