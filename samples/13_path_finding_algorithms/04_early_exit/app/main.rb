# Comparison of a breadth first search with and without early exit
# Inspired by https://www.redblobgames.com/pathfinding/a-star/introduction.html

# Demonstrates the exploration difference caused by early exit
# Also demonstrates how breadth first search is used for path generation

# The left grid is a breadth first search without early exit
# The right grid is a breadth first search with early exit
# The red squares represent how far the search expanded
# The darker the red, the farther the search proceeded
# Comparison of the heat map reveals how much searching can be saved by early exit
# The white path shows path generation via breadth first search
class EarlyExitBreadthFirstSearch
  attr_gtk

  # This method is called every frame/tick
  # Every tick, the current state of the search is rendered on the screen,
  # User input is processed, and
  # The next step in the search is calculated
  def tick
    defaults
    # If the grid has not been searched
    if state.visited.empty?
      # Complete the search
      state.max_steps.times { step }
      # And calculate the path
      calc_path
    end
    render
    input
  end

  def defaults
    # Variables to edit the size and appearance of the grid
    # Freely customizable to user's liking
    grid.width     ||= 15
    grid.height    ||= 15
    grid.cell_size ||= 40
    grid.rect      ||= [0, 0, grid.width, grid.height]

    # At some step the animation will end,
    # and further steps won't change anything (the whole grid.widthill be explored)
    # This step is roughly the grid's width * height
    # When anim_steps equals max_steps no more calculations will occur
    # and the slider will be at the end
    state.max_steps  ||= args.state.grid.width * args.state.grid.height

    # The location of the star and walls of the grid
    # They can be modified to have a different initial grid
    # Walls are stored in a hash for quick look up when doing the search
    state.star   ||= [2, 8]
    state.target ||= [10, 5]
    state.walls  ||= {}

    # Variables that are used by the breadth first search
    # Storing cells that the search has visited, prevents unnecessary steps
    # Expanding the frontier of the search in order makes the search expand
    # from the center outward

    # Visited cells in the first grid
    state.visited               ||= {}
    # Visited cells in the second grid
    state.early_exit_visited    ||= {}
    # The cells from which the search is to expand
    state.frontier              ||= []
    # A hash of where each cell was expanded from
    # The key is a cell, and the value is the cell it came from
    state.came_from             ||= {}
    # Cells that are part of the path from the target to the star
    state.path                  ||= {}

    # What the user is currently editing on the grid
    # We store this value, because we want to remember the value even when
    # the user's cursor is no longer over what they're interacting with, but
    # they are still clicking down on the mouse.
    state.current_input ||= :none
  end

  # Draws everything onto the screen
  def render
    render_background
    render_heat_map
    render_walls
    render_path
    render_star
    render_target
    render_labels
  end

  # The methods below subdivide the task of drawing everything to the screen

  # Draws what the grid looks like with nothing on it
  def render_background
    render_unvisited
    render_grid_lines
  end

  # Draws both grids
  def render_unvisited
    outputs.solids << [scale_up(grid.rect), unvisited_color]
    outputs.solids << [early_exit_scale_up(grid.rect), unvisited_color]
  end

  # Draws grid lines to show the division of the grid into cells
  def render_grid_lines
    for x in 0..grid.width
      outputs.lines << vertical_line(x)
      outputs.lines << early_exit_vertical_line(x)
    end

    for y in 0..grid.height
      outputs.lines << horizontal_line(y)
      outputs.lines << early_exit_horizontal_line(y)
    end
  end

  # Easy way to draw vertical lines given an index
  def vertical_line column
    scale_up([column, 0, column, grid.height])
  end

  # Easy way to draw horizontal lines given an index
  def horizontal_line row
    scale_up([0, row, grid.width, row])
  end

  # Easy way to draw vertical lines given an index
  def early_exit_vertical_line column
    scale_up([column + grid.width + 1, 0, column + grid.width + 1, grid.height])
  end

  # Easy way to draw horizontal lines given an index
  def early_exit_horizontal_line row
    scale_up([grid.width + 1, row, grid.width + grid.width + 1, row])
  end

  # Draws the walls on both grids
  def render_walls
    state.walls.each_key do |wall|
      outputs.solids << [scale_up(wall), wall_color]
      outputs.solids << [early_exit_scale_up(wall), wall_color]
    end
  end

  # Renders the star on both grids
  def render_star
    outputs.sprites << [scale_up(state.star), 'star.png']
    outputs.sprites << [early_exit_scale_up(state.star), 'star.png']
  end

  # Renders the target on both grids
  def render_target
    outputs.sprites << [scale_up(state.target), 'target.png']
    outputs.sprites << [early_exit_scale_up(state.target), 'target.png']
  end

  # Labels the grids
  def render_labels
    outputs.labels << [200, 625, "Without early exit"]
    outputs.labels << [875, 625, "With early exit"]
  end

  # Renders the path based off of the state.path hash
  def render_path
    # If the star and target are disconnected there will only be one path
    # The path should not render in that case
    unless state.path.size == 1
      state.path.each_key do | cell |
        # Renders path on both grids
        outputs.solids << [scale_up(cell), path_color]
        outputs.solids << [early_exit_scale_up(cell), path_color]
      end
    end
  end

  # Calculates the path from the target to the star after the search is over
  # Relies on the came_from hash
  # Fills the state.path hash, which is later rendered on screen
  def calc_path
    endpoint = state.target
    while endpoint
      state.path[endpoint] = true
      endpoint = state.came_from[endpoint]
    end
  end

  # Representation of how far away visited cells are from the star
  # Replaces the render_visited method
  # Visually demonstrates the effectiveness of early exit for pathfinding
  def render_heat_map
    state.visited.each_key do | visited_cell |
      distance = (state.star.x - visited_cell.x).abs + (state.star.y - visited_cell.y).abs
      max_distance = grid.width + grid.height
      alpha = 255.to_i * distance.to_i / max_distance.to_i
      outputs.solids << [scale_up(visited_cell), red, alpha]
      # outputs.solids << [early_exit_scale_up(visited_cell), red, alpha]
    end

    state.early_exit_visited.each_key do | visited_cell |
      distance = (state.star.x - visited_cell.x).abs + (state.star.y - visited_cell.y).abs
      max_distance = grid.width + grid.height
      alpha = 255.to_i * distance.to_i / max_distance.to_i
      outputs.solids << [early_exit_scale_up(visited_cell), red, alpha]
    end
  end

  # Translates the given cell grid.width + 1 to the right and then scales up
  # Used to draw cells for the second grid
  # This method does not work for lines,
  # so separate methods exist for the grid lines
  def early_exit_scale_up(cell)
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

  # This method processes user input every tick
  # Any method with "1" is related to the first grid
  # Any method with "2" is related to the second grid
  def input
    # The program has to remember that the user is dragging an object
    # even when the mouse is no longer over that object
    # So detecting input and processing input is separate
    detect_input
    process_input
  end

  # Determines what the user is editing and stores the value
  # Storing the value allows the user to continue the same edit as long as the
  # mouse left click is held
  def detect_input
    # When the mouse is up, nothing is being edited
    if inputs.mouse.up
      state.current_input = :none
    # When the star in the no second grid is clicked
    elsif star_clicked?
      state.current_input = :star
    # When the star in the second grid is clicked
    elsif star2_clicked?
      state.current_input = :star2
    # When the target in the no second grid is clicked
    elsif target_clicked?
      state.current_input = :target
    # When the target in the second grid is clicked
    elsif target2_clicked?
      state.current_input = :target2
    # When a wall in the first grid is clicked
    elsif wall_clicked?
      state.current_input = :remove_wall
    # When a wall in the second grid is clicked
    elsif wall2_clicked?
      state.current_input = :remove_wall2
    # When the first grid is clicked
    elsif grid_clicked?
      state.current_input = :add_wall
    # When the second grid is clicked
    elsif grid2_clicked?
      state.current_input = :add_wall2
    end
  end

  # Processes click and drag based on what the user is currently dragging
  def process_input
    if state.current_input == :star
      input_star
    elsif state.current_input == :star2
      input_star2
    elsif state.current_input == :target
      input_target
    elsif state.current_input == :target2
      input_target2
    elsif state.current_input == :remove_wall
      input_remove_wall
    elsif state.current_input == :remove_wall2
      input_remove_wall2
    elsif state.current_input == :add_wall
      input_add_wall
    elsif state.current_input == :add_wall2
      input_add_wall2
    end
  end

  # Moves the star to the cell closest to the mouse in the first grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def input_star
    old_star = state.star.clone
    state.star = cell_closest_to_mouse
    unless old_star == state.star
      reset_search
    end
  end

  # Moves the star to the cell closest to the mouse in the second grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def input_star2
    old_star = state.star.clone
    state.star = cell_closest_to_mouse2
    unless old_star == state.star
      reset_search
    end
  end

  # Moves the target to the grid closest to the mouse in the first grid
  # Only reset_searchs the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def input_target
    old_target = state.target.clone
    state.target = cell_closest_to_mouse
    unless old_target == state.target
      reset_search
    end
  end

  # Moves the target to the cell closest to the mouse in the second grid
  # Only reset_searchs the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def input_target2
    old_target = state.target.clone
    state.target = cell_closest_to_mouse2
    unless old_target == state.target
      reset_search
    end
  end

  # Removes walls in the first grid that are under the cursor
  def input_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if mouse_inside_grid?
      if state.walls.has_key?(cell_closest_to_mouse)
        state.walls.delete(cell_closest_to_mouse)
        reset_search
      end
    end
  end

  # Removes walls in the second grid that are under the cursor
  def input_remove_wall2
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if mouse_inside_grid2?
      if state.walls.has_key?(cell_closest_to_mouse2)
        state.walls.delete(cell_closest_to_mouse2)
        reset_search
      end
    end
  end

  # Adds a wall in the first grid in the cell the mouse is over
  def input_add_wall
    if mouse_inside_grid?
      unless state.walls.has_key?(cell_closest_to_mouse)
        state.walls[cell_closest_to_mouse] = true
        reset_search
      end
    end
  end


  # Adds a wall in the second grid in the cell the mouse is over
  def input_add_wall2
    if mouse_inside_grid2?
      unless state.walls.has_key?(cell_closest_to_mouse2)
        state.walls[cell_closest_to_mouse2] = true
        reset_search
      end
    end
  end

  # Whenever the user edits the grid,
  # The search has to be reset_searchd upto the current step
  # with the current grid as the initial state of the grid
  def reset_search
    # Reset_Searchs the search
    state.frontier  = []
    state.visited   = {}
    state.early_exit_visited   = {}
    state.came_from = {}
    state.path      = {}
  end

  # Moves the search forward one step
  def step
    # The setup to the search
    # Runs once when there are no visited cells
    if state.visited.empty?
      state.visited[state.star] = true
      state.early_exit_visited[state.star] = true
      state.frontier << state.star
      state.came_from[state.star] = nil
    end

    # A step in the search
    unless state.frontier.empty?
      # Takes the next frontier cell
      new_frontier = state.frontier.shift
      # For each of its neighbors
      adjacent_neighbors(new_frontier).each do |neighbor|
        # That have not been visited and are not walls
        unless state.visited.has_key?(neighbor) || state.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited in the first grid
          state.visited[neighbor] = true
          # Unless the target has been visited
          unless state.visited.has_key?(state.target)
            # Mark the neighbor as visited in the second grid as well
            state.early_exit_visited[neighbor] = true
          end

          # Add the neighbor to the frontier and remember which cell it came from
          state.frontier << neighbor
          state.came_from[neighbor] = new_frontier
        end
      end
    end
  end


  # Returns a list of adjacent cells
  # Used to determine what the next cells to be added to the frontier are
  def adjacent_neighbors(cell)
    neighbors = []

    # Gets all the valid neighbors into the array
    # From southern neighbor, clockwise
    neighbors << [cell.x, cell.y - 1] unless cell.y == 0
    neighbors << [cell.x - 1, cell.y] unless cell.x == 0
    neighbors << [cell.x, cell.y + 1] unless cell.y == grid.height - 1
    neighbors << [cell.x + 1, cell.y] unless cell.x == grid.width - 1

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
    x = grid.width - 1 if x > grid.width - 1
    y = grid.height - 1 if y > grid.height - 1
    # Return closest cell
    [x, y]
  end

  # Signal that the user is going to be moving the star from the first grid
  def star_clicked?
    inputs.mouse.down && inputs.mouse.point.inside_rect?(scale_up(state.star))
  end

  # Signal that the user is going to be moving the star from the second grid
  def star2_clicked?
    inputs.mouse.down && inputs.mouse.point.inside_rect?(early_exit_scale_up(state.star))
  end

  # Signal that the user is going to be moving the target from the first grid
  def target_clicked?
    inputs.mouse.down && inputs.mouse.point.inside_rect?(scale_up(state.target))
  end

  # Signal that the user is going to be moving the target from the second grid
  def target2_clicked?
    inputs.mouse.down && inputs.mouse.point.inside_rect?(early_exit_scale_up(state.target))
  end

  # Signal that the user is going to be removing walls from the first grid
  def wall_clicked?
    inputs.mouse.down && mouse_inside_wall?
  end

  # Signal that the user is going to be removing walls from the second grid
  def wall2_clicked?
    inputs.mouse.down && mouse_inside_wall2?
  end

  # Signal that the user is going to be adding walls from the first grid
  def grid_clicked?
    inputs.mouse.down && mouse_inside_grid?
  end

  # Signal that the user is going to be adding walls from the second grid
  def grid2_clicked?
    inputs.mouse.down && mouse_inside_grid2?
  end

  # Returns whether the mouse is inside of a wall in the first grid
  # Part of the condition that checks whether the user is removing a wall
  def mouse_inside_wall?
    state.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(scale_up(wall))
    end

    false
  end

  # Returns whether the mouse is inside of a wall in the second grid
  # Part of the condition that checks whether the user is removing a wall
  def mouse_inside_wall2?
    state.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(early_exit_scale_up(wall))
    end

    false
  end

  # Returns whether the mouse is inside of the first grid
  # Part of the condition that checks whether the user is adding a wall
  def mouse_inside_grid?
    inputs.mouse.point.inside_rect?(scale_up(grid.rect))
  end

  # Returns whether the mouse is inside of the second grid
  # Part of the condition that checks whether the user is adding a wall
  def mouse_inside_grid2?
    inputs.mouse.point.inside_rect?(early_exit_scale_up(grid.rect))
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

  # Makes code more concise
  def grid
    state.grid
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

  # Every tick, new args are passed, and the Breadth First Search tick is called
  $early_exit_breadth_first_search ||= EarlyExitBreadthFirstSearch.new
  $early_exit_breadth_first_search.args = args
  $early_exit_breadth_first_search.tick
end


def reset
  $early_exit_breadth_first_search = nil
end
