# This program is inspired by https://www.redblobgames.com/pathfinding/a-star/introduction.html

# The A* Search works by incorporating both the distance from the starting point
# and the distance from the target in its heurisitic.

# It tends to find the correct (shortest) path even when the Greedy Best-First Search does not,
# and it explores less of the grid, and is therefore faster, than Dijkstra's Search.

class A_Star_Algorithm
  attr_gtk

  def tick
    defaults
    render
    input

    if dijkstra.came_from.empty?
      calc_searches
    end
  end

  def defaults
    # Variables to edit the size and appearance of the grid
    # Freely customizable to user's liking
    grid.width     ||= 15
    grid.height    ||= 15
    grid.cell_size ||= 27
    grid.rect      ||= [0, 0, grid.width, grid.height]

    grid.star      ||= [0, 2]
    grid.target    ||= [11, 13]
    grid.walls     ||= {
      [2, 2] => true,
      [3, 2] => true,
      [4, 2] => true,
      [5, 2] => true,
      [6, 2] => true,
      [7, 2] => true,
      [8, 2] => true,
      [9, 2] => true,
      [10, 2] => true,
      [11, 2] => true,
      [12, 2] => true,
      [12, 3] => true,
      [12, 4] => true,
      [12, 5] => true,
      [12, 6] => true,
      [12, 7] => true,
      [12, 8] => true,
      [12, 9] => true,
      [12, 10] => true,
      [12, 11] => true,
      [12, 12] => true,
      [5, 12] => true,
      [6, 12] => true,
      [7, 12] => true,
      [8, 12] => true,
      [9, 12] => true,
      [10, 12] => true,
      [11, 12] => true,
      [12, 12] => true
    }

    # What the user is currently editing on the grid
    # We store this value, because we want to remember the value even when
    # the user's cursor is no longer over what they're interacting with, but
    # they are still clicking down on the mouse.
    state.user_input ||= :none

    # These variables allow the breadth first search to take place
    # Came_from is a hash with a key of a cell and a value of the cell that was expanded from to find the key.
    # Used to prevent searching cells that have already been found
    # and to trace a path from the target back to the starting point.
    # Frontier is an array of cells to expand the search from.
    # The search is over when there are no more cells to search from.
    # Path stores the path from the target to the star, once the target has been found
    # It prevents calculating the path every tick.
    dijkstra.came_from   ||= {}
    dijkstra.cost_so_far ||= {}
    dijkstra.frontier    ||= []
    dijkstra.path        ||= []

    greedy.came_from ||= {}
    greedy.frontier  ||= []
    greedy.path      ||= []

    a_star.frontier  ||= []
    a_star.came_from ||= {}
    a_star.path      ||= []
  end

  # All methods with render draw stuff on the screen
  # UI has buttons, the slider, and labels
  # The search specific rendering occurs in the respective methods
  def render
    render_labels
    render_dijkstra
    render_greedy
    render_a_star
  end

  def render_labels
    outputs.labels << [150, 450, "Dijkstra's"]
    outputs.labels << [550, 450, "Greedy Best-First"]
    outputs.labels << [1025, 450, "A* Search"]
  end

  def render_dijkstra
    render_dijkstra_grid
    render_dijkstra_star
    render_dijkstra_target
    render_dijkstra_visited
    render_dijkstra_walls
    render_dijkstra_path
  end

  def render_greedy
    render_greedy_grid
    render_greedy_star
    render_greedy_target
    render_greedy_visited
    render_greedy_walls
    render_greedy_path
  end

  def render_a_star
    render_a_star_grid
    render_a_star_star
    render_a_star_target
    render_a_star_visited
    render_a_star_walls
    render_a_star_path
  end

  # This method handles user input every tick
  def input
    # If the mouse was lifted this tick
    if inputs.mouse.up
      # Set current input to none
      state.user_input = :none
    end

    # If the mouse was clicked this tick
    if inputs.mouse.down
      # Determine what the user is editing and appropriately edit the state.user_input variable
      determine_input
    end

    # Process user input based on user_input variable and current mouse position
    process_input
  end

  # Determines what the user is editing
  # This method is called when the mouse is clicked down
  def determine_input
    # If the mouse is over the star in the first grid
    if dijkstra_mouse_over_star?
      # The user is editing the star from the first grid
      state.user_input = :dijkstra_star
    # If the mouse is over the star in the second grid
    elsif greedy_mouse_over_star?
      # The user is editing the star from the second grid
      state.user_input = :greedy_star
    # If the mouse is over the star in the third grid
    elsif a_star_mouse_over_star?
      # The user is editing the star from the third grid
      state.user_input = :a_star_star
    # If the mouse is over the target in the first grid
    elsif dijkstra_mouse_over_target?
      # The user is editing the target from the first grid
      state.user_input = :dijkstra_target
    # If the mouse is over the target in the second grid
    elsif greedy_mouse_over_target?
      # The user is editing the target from the second grid
      state.user_input = :greedy_target
    # If the mouse is over the target in the third grid
    elsif a_star_mouse_over_target?
      # The user is editing the target from the third grid
      state.user_input = :a_star_target
    # If the mouse is over a wall in the first grid
    elsif dijkstra_mouse_over_wall?
      # The user is removing a wall from the first grid
      state.user_input = :dijkstra_remove_wall
    # If the mouse is over a wall in the second grid
    elsif greedy_mouse_over_wall?
      # The user is removing a wall from the second grid
      state.user_input = :greedy_remove_wall
    # If the mouse is over a wall in the third grid
    elsif a_star_mouse_over_wall?
      # The user is removing a wall from the third grid
      state.user_input = :a_star_remove_wall
    # If the mouse is over the first grid
    elsif dijkstra_mouse_over_grid?
      # The user is adding a wall from the first grid
      state.user_input = :dijkstra_add_wall
    # If the mouse is over the second grid
    elsif greedy_mouse_over_grid?
      # The user is adding a wall from the second grid
      state.user_input = :greedy_add_wall
    # If the mouse is over the third grid
    elsif a_star_mouse_over_grid?
      # The user is adding a wall from the third grid
      state.user_input = :a_star_add_wall
    end
  end

  # Processes click and drag based on what the user is currently dragging
  def process_input
    if state.user_input == :dijkstra_star
      process_input_dijkstra_star
    elsif state.user_input == :greedy_star
      process_input_greedy_star
    elsif state.user_input == :a_star_star
      process_input_a_star_star
    elsif state.user_input == :dijkstra_target
      process_input_dijkstra_target
    elsif state.user_input == :greedy_target
      process_input_greedy_target
    elsif state.user_input == :a_star_target
      process_input_a_star_target
    elsif state.user_input == :dijkstra_remove_wall
      process_input_dijkstra_remove_wall
    elsif state.user_input == :greedy_remove_wall
      process_input_greedy_remove_wall
    elsif state.user_input == :a_star_remove_wall
      process_input_a_star_remove_wall
    elsif state.user_input == :dijkstra_add_wall
      process_input_dijkstra_add_wall
    elsif state.user_input == :greedy_add_wall
      process_input_greedy_add_wall
    elsif state.user_input == :a_star_add_wall
      process_input_a_star_add_wall
    end
  end

  def render_dijkstra_grid
    # A large rect the size of the grid
    outputs.solids << [dijkstra_scale_up(grid.rect), default_color]

    # The vertical grid lines
    for x in 0..grid.width
      outputs.lines << dijkstra_vertical_line(x)
    end

    # The horizontal grid lines
    for y in 0..grid.height
      outputs.lines << dijkstra_horizontal_line(y)
    end
  end

  def render_greedy_grid
    # A large rect the size of the grid
    outputs.solids << [greedy_scale_up(grid.rect), default_color]

    # The vertical grid lines
    for x in 0..grid.width
      outputs.lines << greedy_vertical_line(x)
    end

    # The horizontal grid lines
    for y in 0..grid.height
      outputs.lines << greedy_horizontal_line(y)
    end
  end

  def render_a_star_grid
    # A large rect the size of the grid
    outputs.solids << [a_star_scale_up(grid.rect), default_color]

    # The vertical grid lines
    for x in 0..grid.width
      outputs.lines << a_star_vertical_line(x)
    end

    # The horizontal grid lines
    for y in 0..grid.height
      outputs.lines << a_star_horizontal_line(y)
    end
  end

  # Returns a vertical line for a column of the first grid
  def dijkstra_vertical_line column
    dijkstra_scale_up([column, 0, column, grid.height])
  end

  # Returns a horizontal line for a column of the first grid
  def dijkstra_horizontal_line row
    dijkstra_scale_up([0, row, grid.width, row])
  end

  # Returns a vertical line for a column of the second grid
  def greedy_vertical_line column
    dijkstra_scale_up([column + grid.width + 1, 0, column + grid.width + 1, grid.height])
  end

  # Returns a horizontal line for a column of the second grid
  def greedy_horizontal_line row
    dijkstra_scale_up([grid.width + 1, row, grid.width + grid.width + 1, row])
  end

  # Returns a vertical line for a column of the third grid
  def a_star_vertical_line column
    dijkstra_scale_up([column + (grid.width * 2) + 2, 0, column + (grid.width * 2) + 2, grid.height])
  end

  # Returns a horizontal line for a column of the third grid
  def a_star_horizontal_line row
    dijkstra_scale_up([(grid.width * 2) + 2, row, (grid.width * 2) + grid.width + 2, row])
  end

  # Renders the star on the first grid
  def render_dijkstra_star
    outputs.sprites << [dijkstra_scale_up(grid.star), 'star.png']
  end

  # Renders the star on the second grid
  def render_greedy_star
    outputs.sprites << [greedy_scale_up(grid.star), 'star.png']
  end

  # Renders the star on the third grid
  def render_a_star_star
    outputs.sprites << [a_star_scale_up(grid.star), 'star.png']
  end

  # Renders the target on the first grid
  def render_dijkstra_target
    outputs.sprites << [dijkstra_scale_up(grid.target), 'target.png']
  end

  # Renders the target on the second grid
  def render_greedy_target
    outputs.sprites << [greedy_scale_up(grid.target), 'target.png']
  end

  # Renders the target on the third grid
  def render_a_star_target
    outputs.sprites << [a_star_scale_up(grid.target), 'target.png']
  end

  # Renders the walls on the first grid
  def render_dijkstra_walls
    grid.walls.each_key do | wall |
      outputs.solids << [dijkstra_scale_up(wall), wall_color]
    end
  end

  # Renders the walls on the second grid
  def render_greedy_walls
    grid.walls.each_key do | wall |
      outputs.solids << [greedy_scale_up(wall), wall_color]
    end
  end

  # Renders the walls on the third grid
  def render_a_star_walls
    grid.walls.each_key do | wall |
      outputs.solids << [a_star_scale_up(wall), wall_color]
    end
  end

  # Renders the visited cells on the first grid
  def render_dijkstra_visited
    dijkstra.came_from.each_key do | visited_cell |
      outputs.solids << [dijkstra_scale_up(visited_cell), visited_color]
    end
  end

  # Renders the visited cells on the second grid
  def render_greedy_visited
    greedy.came_from.each_key do | visited_cell |
      outputs.solids << [greedy_scale_up(visited_cell), visited_color]
    end
  end

  # Renders the visited cells on the third grid
  def render_a_star_visited
    a_star.came_from.each_key do | visited_cell |
      outputs.solids << [a_star_scale_up(visited_cell), visited_color]
    end
  end

  # Renders the path found by the breadth first search on the first grid
  def render_dijkstra_path
    dijkstra.path.each do | path |
      outputs.solids << [dijkstra_scale_up(path), path_color]
    end
  end

  # Renders the path found by the greedy search on the second grid
  def render_greedy_path
    greedy.path.each do | path |
      outputs.solids << [greedy_scale_up(path), path_color]
    end
  end

  # Renders the path found by the a_star search on the third grid
  def render_a_star_path
    a_star.path.each do | path |
      outputs.solids << [a_star_scale_up(path), path_color]
    end
  end

  # Returns the rect for the path between two cells based on their relative positions
  def get_path_between(cell_one, cell_two)
    path = []

    # If cell one is above cell two
    if cell_one.x == cell_two.x and cell_one.y > cell_two.y
      # Path starts from the center of cell two and moves upward to the center of cell one
      path = [cell_two.x + 0.3, cell_two.y + 0.3, 0.4, 1.4]
    # If cell one is below cell two
    elsif cell_one.x == cell_two.x and cell_one.y < cell_two.y
      # Path starts from the center of cell one and moves upward to the center of cell two
      path = [cell_one.x + 0.3, cell_one.y + 0.3, 0.4, 1.4]
    # If cell one is to the left of cell two
    elsif cell_one.x > cell_two.x and cell_one.y == cell_two.y
      # Path starts from the center of cell two and moves rightward to the center of cell one
      path = [cell_two.x + 0.3, cell_two.y + 0.3, 1.4, 0.4]
    # If cell one is to the right of cell two
    elsif cell_one.x < cell_two.x and cell_one.y == cell_two.y
      # Path starts from the center of cell one and moves rightward to the center of cell two
      path = [cell_one.x + 0.3, cell_one.y + 0.3, 1.4, 0.4]
    end

    path
  end

  # In code, the cells are represented as 1x1 rectangles
  # When drawn, the cells are larger than 1x1 rectangles
  # This method is used to scale up cells, and lines
  # Objects are scaled up according to the grid.cell_size variable
  # This allows for easy customization of the visual scale of the grid
  # This method scales up cells for the first grid
  def dijkstra_scale_up(cell)
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

  # Translates the given cell grid.width + 1 to the right and then scales up
  # Used to draw cells for the second grid
  # This method does not work for lines,
  # so separate methods exist for the grid lines
  def greedy_scale_up(cell)
    # Prevents the original value of cell from being edited
    cell = cell.clone
    # Translates the cell to the second grid equivalent
    cell.x += grid.width + 1
    # Proceeds as if scaling up for the first grid
    dijkstra_scale_up(cell)
  end

  # Translates the given cell (grid.width + 1) * 2 to the right and then scales up
  # Used to draw cells for the third grid
  # This method does not work for lines,
  # so separate methods exist for the grid lines
  def a_star_scale_up(cell)
    # Prevents the original value of cell from being edited
    cell = cell.clone
    # Translates the cell to the second grid equivalent
    cell.x += grid.width + 1
    # Translates the cell to the third grid equivalent
    cell.x += grid.width + 1
    # Proceeds as if scaling up for the first grid
    dijkstra_scale_up(cell)
  end

  # Signal that the user is going to be moving the star from the first grid
  def dijkstra_mouse_over_star?
    inputs.mouse.point.inside_rect?(dijkstra_scale_up(grid.star))
  end

  # Signal that the user is going to be moving the star from the second grid
  def greedy_mouse_over_star?
    inputs.mouse.point.inside_rect?(greedy_scale_up(grid.star))
  end

  # Signal that the user is going to be moving the star from the third grid
  def a_star_mouse_over_star?
    inputs.mouse.point.inside_rect?(a_star_scale_up(grid.star))
  end

  # Signal that the user is going to be moving the target from the first grid
  def dijkstra_mouse_over_target?
    inputs.mouse.point.inside_rect?(dijkstra_scale_up(grid.target))
  end

  # Signal that the user is going to be moving the target from the second grid
  def greedy_mouse_over_target?
    inputs.mouse.point.inside_rect?(greedy_scale_up(grid.target))
  end

  # Signal that the user is going to be moving the target from the third grid
  def a_star_mouse_over_target?
    inputs.mouse.point.inside_rect?(a_star_scale_up(grid.target))
  end

  # Signal that the user is going to be removing walls from the first grid
  def dijkstra_mouse_over_wall?
    grid.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(dijkstra_scale_up(wall))
    end

    false
  end

  # Signal that the user is going to be removing walls from the second grid
  def greedy_mouse_over_wall?
    grid.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(greedy_scale_up(wall))
    end

    false
  end

  # Signal that the user is going to be removing walls from the third grid
  def a_star_mouse_over_wall?
    grid.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(a_star_scale_up(wall))
    end

    false
  end

  # Signal that the user is going to be adding walls from the first grid
  def dijkstra_mouse_over_grid?
    inputs.mouse.point.inside_rect?(dijkstra_scale_up(grid.rect))
  end

  # Signal that the user is going to be adding walls from the second grid
  def greedy_mouse_over_grid?
    inputs.mouse.point.inside_rect?(greedy_scale_up(grid.rect))
  end

  # Signal that the user is going to be adding walls from the third grid
  def a_star_mouse_over_grid?
    inputs.mouse.point.inside_rect?(a_star_scale_up(grid.rect))
  end

  # Moves the star to the cell closest to the mouse in the first grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def process_input_dijkstra_star
    old_star = grid.star.clone
    unless dijkstra_cell_closest_to_mouse == grid.target
      grid.star = dijkstra_cell_closest_to_mouse
    end
    unless old_star == grid.star
      reset_searches
    end
  end

  # Moves the star to the cell closest to the mouse in the second grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def process_input_greedy_star
    old_star = grid.star.clone
    unless greedy_cell_closest_to_mouse == grid.target
      grid.star = greedy_cell_closest_to_mouse
    end
    unless old_star == grid.star
      reset_searches
    end
  end

  # Moves the star to the cell closest to the mouse in the third grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def process_input_a_star_star
    old_star = grid.star.clone
    unless a_star_cell_closest_to_mouse == grid.target
      grid.star = a_star_cell_closest_to_mouse
    end
    unless old_star == grid.star
      reset_searches
    end
  end

  # Moves the target to the grid closest to the mouse in the first grid
  # Only reset_searchess the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def process_input_dijkstra_target
    old_target = grid.target.clone
    unless dijkstra_cell_closest_to_mouse == grid.star
      grid.target = dijkstra_cell_closest_to_mouse
    end
    unless old_target == grid.target
      reset_searches
    end
  end

  # Moves the target to the cell closest to the mouse in the second grid
  # Only reset_searchess the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def process_input_greedy_target
    old_target = grid.target.clone
    unless greedy_cell_closest_to_mouse == grid.star
      grid.target = greedy_cell_closest_to_mouse
    end
    unless old_target == grid.target
      reset_searches
    end
  end

  # Moves the target to the cell closest to the mouse in the third grid
  # Only reset_searchess the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def process_input_a_star_target
    old_target = grid.target.clone
    unless a_star_cell_closest_to_mouse == grid.star
      grid.target = a_star_cell_closest_to_mouse
    end
    unless old_target == grid.target
      reset_searches
    end
  end

  # Removes walls in the first grid that are under the cursor
  def process_input_dijkstra_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if dijkstra_mouse_over_grid?
      if grid.walls.has_key?(dijkstra_cell_closest_to_mouse)
        grid.walls.delete(dijkstra_cell_closest_to_mouse)
        reset_searches
      end
    end
  end

  # Removes walls in the second grid that are under the cursor
  def process_input_greedy_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if greedy_mouse_over_grid?
      if grid.walls.has_key?(greedy_cell_closest_to_mouse)
        grid.walls.delete(greedy_cell_closest_to_mouse)
        reset_searches
      end
    end
  end

  # Removes walls in the third grid that are under the cursor
  def process_input_a_star_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if a_star_mouse_over_grid?
      if grid.walls.has_key?(a_star_cell_closest_to_mouse)
        grid.walls.delete(a_star_cell_closest_to_mouse)
        reset_searches
      end
    end
  end

  # Adds a wall in the first grid in the cell the mouse is over
  def process_input_dijkstra_add_wall
    if dijkstra_mouse_over_grid?
      unless grid.walls.has_key?(dijkstra_cell_closest_to_mouse)
        grid.walls[dijkstra_cell_closest_to_mouse] = true
        reset_searches
      end
    end
  end

  # Adds a wall in the second grid in the cell the mouse is over
  def process_input_greedy_add_wall
    if greedy_mouse_over_grid?
      unless grid.walls.has_key?(greedy_cell_closest_to_mouse)
        grid.walls[greedy_cell_closest_to_mouse] = true
        reset_searches
      end
    end
  end

  # Adds a wall in the third grid in the cell the mouse is over
  def process_input_a_star_add_wall
    if a_star_mouse_over_grid?
      unless grid.walls.has_key?(a_star_cell_closest_to_mouse)
        grid.walls[a_star_cell_closest_to_mouse] = true
        reset_searches
      end
    end
  end

  # When the user grabs the star and puts their cursor to the far right
  # and moves up and down, the star is supposed to move along the grid as well
  # Finding the cell closest to the mouse helps with this
  def dijkstra_cell_closest_to_mouse
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
  def greedy_cell_closest_to_mouse
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

  # When the user grabs the star and puts their cursor to the far right
  # and moves up and down, the star is supposed to move along the grid as well
  # Finding the cell closest to the mouse in the third grid helps with this
  def a_star_cell_closest_to_mouse
    # Closest cell grid to the mouse in the second
    x = (inputs.mouse.point.x / grid.cell_size).to_i
    y = (inputs.mouse.point.y / grid.cell_size).to_i
    # Translate the cell to the first grid
    x -= (grid.width + 1) * 2
    # Bound x and y to the first grid
    x = 0 if x < 0
    y = 0 if y < 0
    x = grid.width - 1 if x > grid.width - 1
    y = grid.height - 1 if y > grid.height - 1
    # Return closest cell
    [x, y]
  end

  def reset_searches
    # Reset the searches
    dijkstra.came_from      = {}
    dijkstra.cost_so_far    = {}
    dijkstra.frontier       = []
    dijkstra.path           = []

    greedy.came_from = {}
    greedy.frontier  = []
    greedy.path      = []
    a_star.came_from = {}
    a_star.frontier  = []
    a_star.path      = []
  end

  def calc_searches
    calc_dijkstra
    calc_greedy
    calc_a_star
    # Move the searches forward to the current step
    # state.current_step.times { move_searches_one_step_forward }
  end

  def calc_dijkstra
    # Sets up the search to begin from the star
    dijkstra.frontier << grid.star
    dijkstra.came_from[grid.star] = nil
    dijkstra.cost_so_far[grid.star] = 0

    # Until the target is found or there are no more cells to explore from
    until dijkstra.came_from.has_key?(grid.target) or dijkstra.frontier.empty?
      # Take the next frontier cell. The first element is the cell, the second is the priority.
      new_frontier = dijkstra.frontier.shift#[0]
      # For each of its neighbors
      adjacent_neighbors(new_frontier).each do | neighbor |
        # That have not been visited and are not walls
        unless dijkstra.came_from.has_key?(neighbor) or grid.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited
          dijkstra.frontier << neighbor
          dijkstra.came_from[neighbor] = new_frontier
          dijkstra.cost_so_far[neighbor] = dijkstra.cost_so_far[new_frontier] + 1
        end
      end

      # Sort the frontier so that cells that are in a zigzag pattern are prioritized over those in an line
      # Comment this line and let a path generate to see the difference
      dijkstra.frontier = dijkstra.frontier.sort_by {| cell | proximity_to_star(cell) }
      dijkstra.frontier = dijkstra.frontier.sort_by {| cell | dijkstra.cost_so_far[cell] }
    end


    # If the search found the target
    if dijkstra.came_from.has_key?(grid.target)
      # Calculate the path between the target and star
      dijkstra_calc_path
    end
  end

  def calc_greedy
    # Sets up the search to begin from the star
    greedy.frontier << grid.star
    greedy.came_from[grid.star] = nil

    # Until the target is found or there are no more cells to explore from
    until greedy.came_from.has_key?(grid.target) or greedy.frontier.empty?
      # Take the next frontier cell
      new_frontier = greedy.frontier.shift
      # For each of its neighbors
      adjacent_neighbors(new_frontier).each do | neighbor |
        # That have not been visited and are not walls
        unless greedy.came_from.has_key?(neighbor) or grid.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited
          greedy.frontier << neighbor
          greedy.came_from[neighbor] = new_frontier
        end
      end
      # Sort the frontier so that cells that are in a zigzag pattern are prioritized over those in an line
      # Comment this line and let a path generate to see the difference
      greedy.frontier = greedy.frontier.sort_by {| cell | proximity_to_star(cell) }
      # Sort the frontier so cells that are close to the target are then prioritized
      greedy.frontier = greedy.frontier.sort_by {| cell | greedy_heuristic(cell)  }
    end


    # If the search found the target
    if greedy.came_from.has_key?(grid.target)
      # Calculate the path between the target and star
      greedy_calc_path
    end
  end

  def calc_a_star
    # Setup the search to start from the star
    a_star.came_from[grid.star] = nil
    a_star.cost_so_far[grid.star] = 0
    a_star.frontier << grid.star

    # Until there are no more cells to explore from or the search has found the target
    until a_star.frontier.empty? or a_star.came_from.has_key?(grid.target)
      # Get the next cell to expand from
      current_frontier = a_star.frontier.shift

      # For each of that cells neighbors
      adjacent_neighbors(current_frontier).each do | neighbor |
        # That have not been visited and are not walls
        unless a_star.came_from.has_key?(neighbor) or grid.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited
          a_star.frontier << neighbor
          a_star.came_from[neighbor] = current_frontier
          a_star.cost_so_far[neighbor] = a_star.cost_so_far[current_frontier] + 1
        end
      end

      # Sort the frontier so that cells that are in a zigzag pattern are prioritized over those in an line
      # Comment this line and let a path generate to see the difference
      a_star.frontier = a_star.frontier.sort_by {| cell | proximity_to_star(cell) }
      a_star.frontier = a_star.frontier.sort_by {| cell | a_star.cost_so_far[cell] + greedy_heuristic(cell) }
    end

    # If the search found the target
    if a_star.came_from.has_key?(grid.target)
      # Calculate the path between the target and star
      a_star_calc_path
    end
  end

  # Calculates the path between the target and star for the breadth first search
  # Only called when the breadth first search finds the target
  def dijkstra_calc_path
    # Start from the target
    endpoint = grid.target
    # And the cell it came from
    next_endpoint = dijkstra.came_from[endpoint]
    while endpoint and next_endpoint
      # Draw a path between these two cells and store it
      path = get_path_between(endpoint, next_endpoint)
      dijkstra.path << path
      # And get the next pair of cells
      endpoint = next_endpoint
      next_endpoint = dijkstra.came_from[endpoint]
      # Continue till there are no more cells
    end
  end

  # Returns one-dimensional absolute distance between cell and target
  # Returns a number to compare distances between cells and the target
  def greedy_heuristic(cell)
    (grid.target.x - cell.x).abs + (grid.target.y - cell.y).abs
  end

  # Calculates the path between the target and star for the greedy search
  # Only called when the greedy search finds the target
  def greedy_calc_path
    # Start from the target
    endpoint = grid.target
    # And the cell it came from
    next_endpoint = greedy.came_from[endpoint]
    while endpoint and next_endpoint
      # Draw a path between these two cells and store it
      path = get_path_between(endpoint, next_endpoint)
      greedy.path << path
      # And get the next pair of cells
      endpoint = next_endpoint
      next_endpoint = greedy.came_from[endpoint]
      # Continue till there are no more cells
    end
  end

  # Calculates the path between the target and star for the a_star search
  # Only called when the a_star search finds the target
  def a_star_calc_path
    # Start from the target
    endpoint = grid.target
    # And the cell it came from
    next_endpoint = a_star.came_from[endpoint]

    while endpoint and next_endpoint
      # Draw a path between these two cells and store it
      path = get_path_between(endpoint, next_endpoint)
      a_star.path << path
      # And get the next pair of cells
      endpoint = next_endpoint
      next_endpoint = a_star.came_from[endpoint]
      # Continue till there are no more cells
    end
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

    neighbors
  end

  # Finds the vertical and horizontal distance of a cell from the star
  # and returns the larger value
  # This method is used to have a zigzag pattern in the rendered path
  # A cell that is [5, 5] from the star,
  # is explored before over a cell that is [0, 7] away.
  # So, if possible, the search tries to go diagonal (zigzag) first
  def proximity_to_star(cell)
    distance_x = (grid.star.x - cell.x).abs
    distance_y = (grid.star.y - cell.y).abs

    if distance_x > distance_y
      return distance_x
    else
      return distance_y
    end
  end

  # Methods that allow code to be more concise. Subdivides args.state, which is where all variables are stored.
  def grid
    state.grid
  end

  def dijkstra
    state.dijkstra
  end

  def greedy
    state.greedy
  end

  def a_star
    state.a_star
  end

  # Descriptive aliases for colors
  def default_color
    [221, 212, 213] # Light Brown
  end

  def wall_color
    [134, 134, 120] # Camo Green
  end

  def visited_color
    [204, 191, 179] # Dark Brown
  end

  def path_color
    [231, 230, 228] # Pastel White
  end

  def button_color
    [190, 190, 190] # Gray
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
  $a_star_algorithm ||= A_Star_Algorithm.new
  $a_star_algorithm.args = args
  $a_star_algorithm.tick
end


def reset
  $a_star_algorithm = nil
end
