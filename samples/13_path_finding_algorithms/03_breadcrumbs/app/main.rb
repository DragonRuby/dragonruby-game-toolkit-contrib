class Breadcrumbs
  attr_gtk

  # This method is called every frame/tick
  # Every tick, the current state of the search is rendered on the screen,
  # User input is processed, and
  # The next step in the search is calculated
  def tick
    defaults
    # If the grid has not been searched
    if search.came_from.empty?
      calc
      # Calc Path
    end
    render
    input
  end

  def defaults
    # Variables to edit the size and appearance of the grid
    # Freely customizable to user's liking
    grid.width     ||= 30
    grid.height    ||= 15
    grid.cell_size ||= 40
    grid.rect      ||= [0, 0, grid.width, grid.height]

    # The location of the star and walls of the grid
    # They can be modified to have a different initial grid
    # Walls are stored in a hash for quick look up when doing the search
    grid.star   ||= [2, 8]
    grid.target ||= [10, 5]
    grid.walls  ||= {
      [3, 3] => true,
      [3, 4] => true,
      [3, 5] => true,
      [3, 6] => true,
      [3, 7] => true,
      [3, 8] => true,
      [3, 9] => true,
      [3, 10] => true,
      [3, 11] => true,
      [4, 3] => true,
      [4, 4] => true,
      [4, 5] => true,
      [4, 6] => true,
      [4, 7] => true,
      [4, 8] => true,
      [4, 9] => true,
      [4, 10] => true,
      [4, 11] => true,
      [13, 0] => true,
      [13, 1] => true,
      [13, 2] => true,
      [13, 3] => true,
      [13, 4] => true,
      [13, 5] => true,
      [13, 6] => true,
      [13, 7] => true,
      [13, 8] => true,
      [13, 9] => true,
      [13, 10] => true,
      [14, 0] => true,
      [14, 1] => true,
      [14, 2] => true,
      [14, 3] => true,
      [14, 4] => true,
      [14, 5] => true,
      [14, 6] => true,
      [14, 7] => true,
      [14, 8] => true,
      [14, 9] => true,
      [14, 10] => true,
      [21, 8] => true,
      [21, 9] => true,
      [21, 10] => true,
      [21, 11] => true,
      [21, 12] => true,
      [21, 13] => true,
      [21, 14] => true,
      [22, 8] => true,
      [22, 9] => true,
      [22, 10] => true,
      [22, 11] => true,
      [22, 12] => true,
      [22, 13] => true,
      [22, 14] => true,
      [23, 8] => true,
      [23, 9] => true,
      [24, 8] => true,
      [24, 9] => true,
      [25, 8] => true,
      [25, 9] => true,
    }

    # Variables that are used by the breadth first search
    # Storing cells that the search has visited, prevents unnecessary steps
    # Expanding the frontier of the search in order makes the search expand
    # from the center outward

    # The cells from which the search is to expand
    search.frontier              ||= []
    # A hash of where each cell was expanded from
    # The key is a cell, and the value is the cell it came from
    search.came_from             ||= {}
    # Cells that are part of the path from the target to the star
    search.path                  ||= {}

    # What the user is currently editing on the grid
    # We store this value, because we want to remember the value even when
    # the user's cursor is no longer over what they're interacting with, but
    # they are still clicking down on the mouse.
    state.current_input ||= :none
  end

  def calc
    # Setup the search to start from the star
    search.frontier << grid.star
    search.came_from[grid.star] = nil

    # Until there are no more cells to expand from
    until search.frontier.empty?
      # Takes the next frontier cell
      new_frontier = search.frontier.shift
      # For each of its neighbors
      adjacent_neighbors(new_frontier).each do |neighbor|
        # That have not been visited and are not walls
        unless search.came_from.has_key?(neighbor) || grid.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited in the first grid
          # Unless the target has been visited
          # Add the neighbor to the frontier and remember which cell it came from
          search.frontier << neighbor
          search.came_from[neighbor] = new_frontier
        end
      end
    end
  end


  # Draws everything onto the screen
  def render
    render_background
    # render_heat_map
    render_walls
    # render_path
    # render_labels
    render_arrows
    render_star
    render_target
    unless grid.walls.has_key?(grid.target)
      render_trail
    end
  end

  def render_trail(current_cell=grid.target)
    return if current_cell == grid.star
    parent_cell = search.came_from[current_cell]
    if current_cell && parent_cell
      outputs.lines << [(current_cell.x + 0.5) * grid.cell_size, (current_cell.y + 0.5) * grid.cell_size,
      (parent_cell.x + 0.5) * grid.cell_size, (parent_cell.y + 0.5) * grid.cell_size, purple]

    end
    render_trail(parent_cell)
  end

  def render_arrows
    search.came_from.each do |child, parent|
      if parent && child
        arrow_cell = [(child.x + parent.x) / 2, (child.y + parent.y) / 2]
        if parent.x > child.x # If the parent cell is to the right of the child cell
          outputs.sprites << [scale_up(arrow_cell), 'arrow.png', 0] # Point the arrow to the right
        elsif parent.x < child.x # If the parent cell is to the right of the child cell
          outputs.sprites << [scale_up(arrow_cell), 'arrow.png', 180] # Point the arrow to the right
        elsif parent.y > child.y # If the parent cell is to the right of the child cell
          outputs.sprites << [scale_up(arrow_cell), 'arrow.png', 90] # Point the arrow to the right
        elsif parent.y < child.y # If the parent cell is to the right of the child cell
          outputs.sprites << [scale_up(arrow_cell), 'arrow.png', 270] # Point the arrow to the right
        end
      end
    end
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
  end

  # Draws grid lines to show the division of the grid into cells
  def render_grid_lines
    for x in 0..grid.width
      outputs.lines << vertical_line(x)
    end

    for y in 0..grid.height
      outputs.lines << horizontal_line(y)
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

  # Draws the walls on both grids
  def render_walls
    grid.walls.each_key do |wall|
      outputs.solids << [scale_up(wall), wall_color]
    end
  end

  # Renders the star on both grids
  def render_star
    outputs.sprites << [scale_up(grid.star), 'star.png']
  end

  # Renders the target on both grids
  def render_target
    outputs.sprites << [scale_up(grid.target), 'target.png']
  end

  # Labels the grids
  def render_labels
    outputs.labels << [200, 625, "Without early exit"]
  end

  # Renders the path based off of the search.path hash
  def render_path
    # If the star and target are disconnected there will only be one path
    # The path should not render in that case
    unless search.path.size == 1
      search.path.each_key do | cell |
        # Renders path on both grids
        outputs.solids << [scale_up(cell), path_color]
      end
    end
  end

  # Calculates the path from the target to the star after the search is over
  # Relies on the came_from hash
  # Fills the search.path hash, which is later rendered on screen
  def calc_path
    endpoint = grid.target
    while endpoint
      search.path[endpoint] = true
      endpoint = search.came_from[endpoint]
    end
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
    # detect_input
    # process_input
    if inputs.mouse.up
      state.current_input = :none
    elsif star_clicked?
      state.current_input = :star
    end

    if mouse_inside_grid?
      unless grid.target == cell_closest_to_mouse
        grid.target = cell_closest_to_mouse
      end
      if state.current_input == :star
        unless grid.star == cell_closest_to_mouse
          grid.star = cell_closest_to_mouse
        end
      end
    end
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
    # When the target in the no second grid is clicked
    elsif target_clicked?
      state.current_input = :target
    # When a wall in the first grid is clicked
    elsif wall_clicked?
      state.current_input = :remove_wall
    # When the first grid is clicked
    elsif grid_clicked?
      state.current_input = :add_wall
    end
  end

  # Processes click and drag based on what the user is currently dragging
  def process_input
    if state.current_input == :star
      input_star
    elsif state.current_input == :target
      input_target
    elsif state.current_input == :remove_wall
      input_remove_wall
    elsif state.current_input == :add_wall
      input_add_wall
    end
  end

  # Moves the star to the cell closest to the mouse in the first grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def input_star
    old_star = grid.star.clone
    grid.star = cell_closest_to_mouse
    unless old_star == grid.star
      reset_search
    end
  end

  # Moves the target to the grid closest to the mouse in the first grid
  # Only reset_searchs the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def input_target
    old_target = grid.target.clone
    grid.target = cell_closest_to_mouse
    unless old_target == grid.target
      reset_search
    end
  end

  # Removes walls in the first grid that are under the cursor
  def input_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if mouse_inside_grid?
      if grid.walls.has_key?(cell_closest_to_mouse)
        grid.walls.delete(cell_closest_to_mouse)
        reset_search
      end
    end
  end

  # Adds a wall in the first grid in the cell the mouse is over
  def input_add_wall
    if mouse_inside_grid?
      unless grid.walls.has_key?(cell_closest_to_mouse)
        grid.walls[cell_closest_to_mouse] = true
        reset_search
      end
    end
  end


  # Whenever the user edits the grid,
  # The search has to be reset_searchd upto the current step
  # with the current grid as the initial state of the grid
  def reset_search
    # Reset_Searchs the search
    search.frontier  = []
    search.came_from = {}
    search.path      = {}
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
    distance_x = (grid.star.x - x).abs
    distance_y = (grid.star.y - y).abs

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

  # Signal that the user is going to be moving the star from the first grid
  def star_clicked?
    inputs.mouse.down && inputs.mouse.point.inside_rect?(scale_up(grid.star))
  end

  # Signal that the user is going to be moving the target from the first grid
  def target_clicked?
    inputs.mouse.down && inputs.mouse.point.inside_rect?(scale_up(grid.target))
  end

  # Signal that the user is going to be adding walls from the first grid
  def grid_clicked?
    inputs.mouse.down && mouse_inside_grid?
  end

  # Returns whether the mouse is inside of the first grid
  # Part of the condition that checks whether the user is adding a wall
  def mouse_inside_grid?
    inputs.mouse.point.inside_rect?(scale_up(grid.rect))
  end

  # These methods provide handy aliases to colors

  # Light brown
  def unvisited_color
    [221, 212, 213]
    # [255, 255, 255]
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

  def purple
    [149, 64, 191]
  end

  # Makes code more concise
  def grid
    state.grid
  end

  def search
    state.search
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
  $breadcrumbs ||= Breadcrumbs.new
  $breadcrumbs.args = args
  $breadcrumbs.tick
end


def reset
  $breadcrumbs = nil
end

 #  # Representation of how far away visited cells are from the star
 #  # Replaces the render_visited method
 #  # Visually demonstrates the effectiveness of early exit for pathfinding
 #  def render_heat_map
 #    # THIS CODE NEEDS SOME FIXING DUE TO REFACTORING
 #    search.came_from.each_key do | cell |
 #      distance = (grid.star.x - visited_cell.x).abs + (state.star.y - visited_cell.y).abs
 #      max_distance = grid.width + grid.height
 #      alpha = 255.to_i * distance.to_i / max_distance.to_i
 #      outputs.solids << [scale_up(visited_cell), red, alpha]
 #      # outputs.solids << [early_exit_scale_up(visited_cell), red, alpha]
 #    end
 #  end
