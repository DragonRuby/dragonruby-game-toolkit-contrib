# This program is inspired by https://www.redblobgames.com/pathfinding/a-star/introduction.html

# This time the heuristic search still explored less of the grid, hence finishing faster.
# However, it did not find the shortest path between the star and the target.

# The only difference between this app and Heuristic is the change of the starting position.

class Heuristic_With_Walls
  attr_gtk

  def tick
    defaults
    render
    input
    # If animation is playing, and max steps have not been reached
    # Move the search a step forward
    if state.play && state.current_step < state.max_steps
      # Variable that tells the program what step to recalculate up to
      state.current_step += 1
      move_searches_one_step_forward
    end
  end

  def defaults
    # Variables to edit the size and appearance of the grid
    # Freely customizable to user's liking
    grid.width     ||= 15
    grid.height    ||= 15
    grid.cell_size ||= 40
    grid.rect      ||= [0, 0, grid.width, grid.height]

    grid.star      ||= [0, 2]
    grid.target    ||= [14, 12]
    grid.walls     ||= {}
    # There are no hills in the Heuristic Search Demo

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
    bfs.came_from  ||= {}
    bfs.frontier   ||= []
    bfs.path       ||= []

    heuristic.came_from ||= {}
    heuristic.frontier  ||= []
    heuristic.path      ||= []

    # Stores which step of the animation is being rendered
    # When the user moves the star or messes with the walls,
    # the searches are recalculated up to this step

    # Unless the current step has a value
    unless state.current_step
      # Set the current step to 10
      state.current_step = 10
      # And calculate the searches up to step 10
      recalculate_searches
    end

    # At some step the animation will end,
    # and further steps won't change anything (the whole grid will be explored)
    # This step is roughly the grid's width * height
    # When anim_steps equals max_steps no more calculations will occur
    # and the slider will be at the end
    state.max_steps = grid.width * grid.height

    # Whether the animation should play or not
    # If true, every tick moves anim_steps forward one
    # Pressing the stepwise animation buttons will pause the animation
    # An if statement instead of the ||= operator is used for assigning a boolean value.
    # The || operator does not differentiate between nil and false.
    if state.play == nil
      state.play = false
    end

    # Store the rects of the buttons that control the animation
    # They are here for user customization
    # Editing these might require recentering the text inside them
    # Those values can be found in the render_button methods
    buttons.left   = [470, 600, 50, 50]
    buttons.center = [520, 600, 200, 50]
    buttons.right  = [720, 600, 50, 50]

    # The variables below are related to the slider
    # They allow the user to customize them
    # They also give a central location for the render and input methods to get
    # information from
    # x & y are the coordinates of the leftmost part of the slider line
    slider.x = 440
    slider.y = 675
    # This is the width of the line
    slider.w = 360
    # This is the offset for the circle
    # Allows the center of the circle to be on the line,
    # as opposed to the upper right corner
    slider.offset = 20
    # This is the spacing between each of the notches on the slider
    # Notches are places where the circle can rest on the slider line
    # There needs to be a notch for each step before the maximum number of steps
    slider.spacing = slider.w.to_f / state.max_steps.to_f
  end

  # All methods with render draw stuff on the screen
  # UI has buttons, the slider, and labels
  # The search specific rendering occurs in the respective methods
  def render
    render_ui
    render_bfs
    render_heuristic
  end

  def render_ui
    render_buttons
    render_slider
    render_labels
  end

  def render_buttons
    render_left_button
    render_center_button
    render_right_button
  end

  def render_bfs
    render_bfs_grid
    render_bfs_star
    render_bfs_target
    render_bfs_visited
    render_bfs_walls
    render_bfs_frontier
    render_bfs_path
  end

  def render_heuristic
    render_heuristic_grid
    render_heuristic_star
    render_heuristic_target
    render_heuristic_visited
    render_heuristic_walls
    render_heuristic_frontier
    render_heuristic_path
  end

  # This method handles user input every tick
  def input
    # Check and handle button input
    input_buttons

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
    if mouse_over_slider?
      state.user_input = :slider
    # If the mouse is over the star in the first grid
    elsif bfs_mouse_over_star?
      # The user is editing the star from the first grid
      state.user_input = :bfs_star
    # If the mouse is over the star in the second grid
    elsif heuristic_mouse_over_star?
      # The user is editing the star from the second grid
      state.user_input = :heuristic_star
    # If the mouse is over the target in the first grid
    elsif bfs_mouse_over_target?
      # The user is editing the target from the first grid
      state.user_input = :bfs_target
    # If the mouse is over the target in the second grid
    elsif heuristic_mouse_over_target?
      # The user is editing the target from the second grid
      state.user_input = :heuristic_target
    # If the mouse is over a wall in the first grid
    elsif bfs_mouse_over_wall?
      # The user is removing a wall from the first grid
      state.user_input = :bfs_remove_wall
    # If the mouse is over a wall in the second grid
    elsif heuristic_mouse_over_wall?
      # The user is removing a wall from the second grid
      state.user_input = :heuristic_remove_wall
    # If the mouse is over the first grid
    elsif bfs_mouse_over_grid?
      # The user is adding a wall from the first grid
      state.user_input = :bfs_add_wall
    # If the mouse is over the second grid
    elsif heuristic_mouse_over_grid?
      # The user is adding a wall from the second grid
      state.user_input = :heuristic_add_wall
    end
  end

  # Processes click and drag based on what the user is currently dragging
  def process_input
    if state.user_input == :slider
      process_input_slider
    elsif state.user_input == :bfs_star
      process_input_bfs_star
    elsif state.user_input == :heuristic_star
      process_input_heuristic_star
    elsif state.user_input == :bfs_target
      process_input_bfs_target
    elsif state.user_input == :heuristic_target
      process_input_heuristic_target
    elsif state.user_input == :bfs_remove_wall
      process_input_bfs_remove_wall
    elsif state.user_input == :heuristic_remove_wall
      process_input_heuristic_remove_wall
    elsif state.user_input == :bfs_add_wall
      process_input_bfs_add_wall
    elsif state.user_input == :heuristic_add_wall
      process_input_heuristic_add_wall
    end
  end

  def render_slider
    # Using primitives hides the line under the white circle of the slider
    # Draws the line
    outputs.primitives << [slider.x, slider.y, slider.x + slider.w, slider.y].line
    # The circle needs to be offset so that the center of the circle
    # overlaps the line instead of the upper right corner of the circle
    # The circle's x value is also moved based on the current seach step
    circle_x = (slider.x - slider.offset) + (state.current_step * slider.spacing)
    circle_y = (slider.y - slider.offset)
    circle_rect = [circle_x, circle_y, 37, 37]
    outputs.primitives << [circle_rect, 'circle-white.png'].sprite
  end

  def render_labels
    outputs.labels << [205, 625, "Breadth First Search"]
    outputs.labels << [820, 625, "Heuristic Best-First Search"]
  end

  def render_left_button
    # Draws the button_color button, and a black border
    # The border separates the buttons visually
    outputs.solids  << [buttons.left, button_color]
    outputs.borders << [buttons.left]

    # Renders an explanatory label in the center of the button
    # Explains to the user what the button does
    # If the button size is changed, the label might need to be edited as well
    # to keep the label in the center of the button
    label_x = buttons.left.x + 20
    label_y = buttons.left.y + 35
    outputs.labels  << [label_x, label_y, "<"]
  end

  def render_center_button
    # Draws the button_color button, and a black border
    # The border separates the buttons visually
    outputs.solids  << [buttons.center, button_color]
    outputs.borders << [buttons.center]

    # Renders an explanatory label in the center of the button
    # Explains to the user what the button does
    # If the button size is changed, the label might need to be edited as well
    # to keep the label in the center of the button
    label_x    = buttons.center.x + 37
    label_y    = buttons.center.y + 35
    label_text = state.play ? "Pause Animation" : "Play Animation"
    outputs.labels << [label_x, label_y, label_text]
  end

  def render_right_button
    # Draws the button_color button, and a black border
    # The border separates the buttons visually
    outputs.solids  << [buttons.right, button_color]
    outputs.borders << [buttons.right]

    # Renders an explanatory label in the center of the button
    # Explains to the user what the button does
    label_x = buttons.right.x + 20
    label_y = buttons.right.y + 35
    outputs.labels  << [label_x, label_y, ">"]
  end

  def render_bfs_grid
    # A large rect the size of the grid
    outputs.solids << [bfs_scale_up(grid.rect), default_color]

    # The vertical grid lines
    for x in 0..grid.width
      outputs.lines << bfs_vertical_line(x)
    end

    # The horizontal grid lines
    for y in 0..grid.height
      outputs.lines << bfs_horizontal_line(y)
    end
  end

  def render_heuristic_grid
    # A large rect the size of the grid
    outputs.solids << [heuristic_scale_up(grid.rect), default_color]

    # The vertical grid lines
    for x in 0..grid.width
      outputs.lines << heuristic_vertical_line(x)
    end

    # The horizontal grid lines
    for y in 0..grid.height
      outputs.lines << heuristic_horizontal_line(y)
    end
  end

  # Returns a vertical line for a column of the first grid
  def bfs_vertical_line column
    bfs_scale_up([column, 0, column, grid.height])
  end

  # Returns a horizontal line for a column of the first grid
  def bfs_horizontal_line row
    bfs_scale_up([0, row, grid.width, row])
  end

  # Returns a vertical line for a column of the second grid
  def heuristic_vertical_line column
    bfs_scale_up([column + grid.width + 1, 0, column + grid.width + 1, grid.height])
  end

  # Returns a horizontal line for a column of the second grid
  def heuristic_horizontal_line row
    bfs_scale_up([grid.width + 1, row, grid.width + grid.width + 1, row])
  end

  # Renders the star on the first grid
  def render_bfs_star
    outputs.sprites << [bfs_scale_up(grid.star), 'star.png']
  end

  # Renders the star on the second grid
  def render_heuristic_star
    outputs.sprites << [heuristic_scale_up(grid.star), 'star.png']
  end

  # Renders the target on the first grid
  def render_bfs_target
    outputs.sprites << [bfs_scale_up(grid.target), 'target.png']
  end

  # Renders the target on the second grid
  def render_heuristic_target
    outputs.sprites << [heuristic_scale_up(grid.target), 'target.png']
  end

  # Renders the walls on the first grid
  def render_bfs_walls
    grid.walls.each_key do | wall |
      outputs.solids << [bfs_scale_up(wall), wall_color]
    end
  end

  # Renders the walls on the second grid
  def render_heuristic_walls
    grid.walls.each_key do | wall |
      outputs.solids << [heuristic_scale_up(wall), wall_color]
    end
  end

  # Renders the visited cells on the first grid
  def render_bfs_visited
    bfs.came_from.each_key do | visited_cell |
      outputs.solids << [bfs_scale_up(visited_cell), visited_color]
    end
  end

  # Renders the visited cells on the second grid
  def render_heuristic_visited
    heuristic.came_from.each_key do | visited_cell |
      outputs.solids << [heuristic_scale_up(visited_cell), visited_color]
    end
  end

  # Renders the frontier cells on the first grid
  def render_bfs_frontier
    bfs.frontier.each do | frontier_cell |
      outputs.solids << [bfs_scale_up(frontier_cell), frontier_color, 200]
    end
  end

  # Renders the frontier cells on the second grid
  def render_heuristic_frontier
    heuristic.frontier.each do | frontier_cell |
      outputs.solids << [heuristic_scale_up(frontier_cell), frontier_color, 200]
    end
  end

  # Renders the path found by the breadth first search on the first grid
  def render_bfs_path
    bfs.path.each do | path |
      outputs.solids << [bfs_scale_up(path), path_color]
    end
  end

  # Renders the path found by the heuristic search on the second grid
  def render_heuristic_path
    heuristic.path.each do | path |
      outputs.solids << [heuristic_scale_up(path), path_color]
    end
  end

  # Returns the rect for the path between two cells based on their relative positions
  def get_path_between(cell_one, cell_two)
    path = nil

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
  def bfs_scale_up(cell)
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
  def heuristic_scale_up(cell)
    # Prevents the original value of cell from being edited
    cell = cell.clone
    # Translates the cell to the second grid equivalent
    cell.x += grid.width + 1
    # Proceeds as if scaling up for the first grid
    bfs_scale_up(cell)
  end

  # Checks and handles input for the buttons
  # Called when the mouse is lifted
  def input_buttons
    input_left_button
    input_center_button
    input_right_button
  end

  # Checks if the previous step button is clicked
  # If it is, it pauses the animation and moves the search one step backward
  def input_left_button
    if left_button_clicked?
      state.play = false
      state.current_step -= 1
      recalculate_searches
    end
  end

  # Controls the play/pause button
  # Inverses whether the animation is playing or not when clicked
  def input_center_button
    if center_button_clicked? || inputs.keyboard.key_down.space
      state.play = !state.play
    end
  end

  # Checks if the next step button is clicked
  # If it is, it pauses the animation and moves the search one step forward
  def input_right_button
    if right_button_clicked?
      state.play = false
      state.current_step += 1
      move_searches_one_step_forward
    end
  end

  # These methods detect when the buttons are clicked
  def left_button_clicked?
    inputs.mouse.point.inside_rect?(buttons.left) && inputs.mouse.up
  end

  def center_button_clicked?
    inputs.mouse.point.inside_rect?(buttons.center) && inputs.mouse.up
  end

  def right_button_clicked?
    inputs.mouse.point.inside_rect?(buttons.right) && inputs.mouse.up
  end


  # Signal that the user is going to be moving the slider
  # Is the mouse over the circle of the slider?
  def mouse_over_slider?
    circle_x = (slider.x - slider.offset) + (state.current_step * slider.spacing)
    circle_y = (slider.y - slider.offset)
    circle_rect = [circle_x, circle_y, 37, 37]
    inputs.mouse.point.inside_rect?(circle_rect)
  end

  # Signal that the user is going to be moving the star from the first grid
  def bfs_mouse_over_star?
    inputs.mouse.point.inside_rect?(bfs_scale_up(grid.star))
  end

  # Signal that the user is going to be moving the star from the second grid
  def heuristic_mouse_over_star?
    inputs.mouse.point.inside_rect?(heuristic_scale_up(grid.star))
  end

  # Signal that the user is going to be moving the target from the first grid
  def bfs_mouse_over_target?
    inputs.mouse.point.inside_rect?(bfs_scale_up(grid.target))
  end

  # Signal that the user is going to be moving the target from the second grid
  def heuristic_mouse_over_target?
    inputs.mouse.point.inside_rect?(heuristic_scale_up(grid.target))
  end

  # Signal that the user is going to be removing walls from the first grid
  def bfs_mouse_over_wall?
    grid.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(bfs_scale_up(wall))
    end

    false
  end

  # Signal that the user is going to be removing walls from the second grid
  def heuristic_mouse_over_wall?
    grid.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(heuristic_scale_up(wall))
    end

    false
  end

  # Signal that the user is going to be adding walls from the first grid
  def bfs_mouse_over_grid?
    inputs.mouse.point.inside_rect?(bfs_scale_up(grid.rect))
  end

  # Signal that the user is going to be adding walls from the second grid
  def heuristic_mouse_over_grid?
    inputs.mouse.point.inside_rect?(heuristic_scale_up(grid.rect))
  end

  # This method is called when the user is editing the slider
  # It pauses the animation and moves the white circle to the closest integer point
  # on the slider
  # Changes the step of the search to be animated
  def process_input_slider
    state.play = false
    mouse_x = inputs.mouse.point.x

    # Bounds the mouse_x to the closest x value on the slider line
    mouse_x = slider.x if mouse_x < slider.x
    mouse_x = slider.x + slider.w if mouse_x > slider.x + slider.w

    # Sets the current search step to the one represented by the mouse x value
    # The slider's circle moves due to the render_slider method using anim_steps
    state.current_step = ((mouse_x - slider.x) / slider.spacing).to_i

    recalculate_searches
  end

  # Moves the star to the cell closest to the mouse in the first grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def process_input_bfs_star
    old_star = grid.star.clone
    unless bfs_cell_closest_to_mouse == grid.target
      grid.star = bfs_cell_closest_to_mouse
    end
    unless old_star == grid.star
      recalculate_searches
    end
  end

  # Moves the star to the cell closest to the mouse in the second grid
  # Only resets the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def process_input_heuristic_star
    old_star = grid.star.clone
    unless heuristic_cell_closest_to_mouse == grid.target
      grid.star = heuristic_cell_closest_to_mouse
    end
    unless old_star == grid.star
      recalculate_searches
    end
  end

  # Moves the target to the grid closest to the mouse in the first grid
  # Only recalculate_searchess the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def process_input_bfs_target
    old_target = grid.target.clone
    unless bfs_cell_closest_to_mouse == grid.star
      grid.target = bfs_cell_closest_to_mouse
    end
    unless old_target == grid.target
      recalculate_searches
    end
  end

  # Moves the target to the cell closest to the mouse in the second grid
  # Only recalculate_searchess the search if the target changes position
  # Called whenever the user is editing the target (puts mouse down on target)
  def process_input_heuristic_target
    old_target = grid.target.clone
    unless heuristic_cell_closest_to_mouse == grid.star
      grid.target = heuristic_cell_closest_to_mouse
    end
    unless old_target == grid.target
      recalculate_searches
    end
  end

  # Removes walls in the first grid that are under the cursor
  def process_input_bfs_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if bfs_mouse_over_grid?
      if grid.walls.has_key?(bfs_cell_closest_to_mouse)
        grid.walls.delete(bfs_cell_closest_to_mouse)
        recalculate_searches
      end
    end
  end

  # Removes walls in the second grid that are under the cursor
  def process_input_heuristic_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if heuristic_mouse_over_grid?
      if grid.walls.has_key?(heuristic_cell_closest_to_mouse)
        grid.walls.delete(heuristic_cell_closest_to_mouse)
        recalculate_searches
      end
    end
  end
  # Adds a wall in the first grid in the cell the mouse is over
  def process_input_bfs_add_wall
    if bfs_mouse_over_grid?
      unless grid.walls.has_key?(bfs_cell_closest_to_mouse)
        grid.walls[bfs_cell_closest_to_mouse] = true
        recalculate_searches
      end
    end
  end

  # Adds a wall in the second grid in the cell the mouse is over
  def process_input_heuristic_add_wall
    if heuristic_mouse_over_grid?
      unless grid.walls.has_key?(heuristic_cell_closest_to_mouse)
        grid.walls[heuristic_cell_closest_to_mouse] = true
        recalculate_searches
      end
    end
  end

  # When the user grabs the star and puts their cursor to the far right
  # and moves up and down, the star is supposed to move along the grid as well
  # Finding the cell closest to the mouse helps with this
  def bfs_cell_closest_to_mouse
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
  def heuristic_cell_closest_to_mouse
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

  def recalculate_searches
    # Reset the searches
    bfs.came_from    = {}
    bfs.frontier     = []
    bfs.path         = []
    heuristic.came_from = {}
    heuristic.frontier  = []
    heuristic.path      = []

    # Move the searches forward to the current step
    state.current_step.times { move_searches_one_step_forward }
  end

  def move_searches_one_step_forward
    bfs_one_step_forward
    heuristic_one_step_forward
  end

  def bfs_one_step_forward
    return if bfs.came_from.has_key?(grid.target)

    # Only runs at the beginning of the search as setup.
    if bfs.came_from.empty?
      bfs.frontier << grid.star
      bfs.came_from[grid.star] = nil
    end

    # A step in the search
    unless bfs.frontier.empty?
      # Takes the next frontier cell
      new_frontier = bfs.frontier.shift
      # For each of its neighbors
      adjacent_neighbors(new_frontier).each do |neighbor|
        # That have not been visited and are not walls
        unless bfs.came_from.has_key?(neighbor) || grid.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited
          bfs.frontier << neighbor
          bfs.came_from[neighbor] = new_frontier
        end
      end
    end

    # Sort the frontier so that cells that are in a zigzag pattern are prioritized over those in an line
    # Comment this line and let a path generate to see the difference
    bfs.frontier = bfs.frontier.sort_by {| cell | proximity_to_star(cell) }

    # If the search found the target
    if bfs.came_from.has_key?(grid.target)
      # Calculate the path between the target and star
      bfs_calc_path
    end
  end

  # Calculates the path between the target and star for the breadth first search
  # Only called when the breadth first search finds the target
  def bfs_calc_path
    # Start from the target
    endpoint = grid.target
    # And the cell it came from
    next_endpoint = bfs.came_from[endpoint]
    while endpoint and next_endpoint
      # Draw a path between these two cells and store it
      path = get_path_between(endpoint, next_endpoint)
      bfs.path << path
      # And get the next pair of cells
      endpoint = next_endpoint
      next_endpoint = bfs.came_from[endpoint]
      # Continue till there are no more cells
    end
  end

  # Moves the heuristic search forward one step
  # Can be called from tick while the animation is playing
  # Can also be called when recalculating the searches after the user edited the grid
  def heuristic_one_step_forward
    # Stop the search if the target has been found
    return if heuristic.came_from.has_key?(grid.target)

    # If the search has not begun
    if heuristic.came_from.empty?
      # Setup the search to begin from the star
      heuristic.frontier << grid.star
      heuristic.came_from[grid.star] = nil
    end

    # One step in the heuristic search

    # Unless there are no more cells to explore from
    unless heuristic.frontier.empty?
      # Get the next cell to explore from
      new_frontier = heuristic.frontier.shift
      # For each of its neighbors
      adjacent_neighbors(new_frontier).each do |neighbor|
        # That have not been visited and are not walls
        unless heuristic.came_from.has_key?(neighbor) || grid.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited
          heuristic.frontier << neighbor
          heuristic.came_from[neighbor] = new_frontier
        end
      end
    end

    # Sort the frontier so that cells that are in a zigzag pattern are prioritized over those in an line
    heuristic.frontier = heuristic.frontier.sort_by {| cell | proximity_to_star(cell) }
    # Sort the frontier so cells that are close to the target are then prioritized
    heuristic.frontier = heuristic.frontier.sort_by {| cell | heuristic_heuristic(cell)  }

    # If the search found the target
    if heuristic.came_from.has_key?(grid.target)
      # Calculate the path between the target and star
      heuristic_calc_path
    end
  end

  # Returns one-dimensional absolute distance between cell and target
  # Returns a number to compare distances between cells and the target
  def heuristic_heuristic(cell)
    (grid.target.x - cell.x).abs + (grid.target.y - cell.y).abs
  end

  # Calculates the path between the target and star for the heuristic search
  # Only called when the heuristic search finds the target
  def heuristic_calc_path
    # Start from the target
    endpoint = grid.target
    # And the cell it came from
    next_endpoint = heuristic.came_from[endpoint]
    while endpoint and next_endpoint
      # Draw a path between these two cells and store it
      path = get_path_between(endpoint, next_endpoint)
      heuristic.path << path
      # And get the next pair of cells
      endpoint = next_endpoint
      next_endpoint = heuristic.came_from[endpoint]
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

  def buttons
    state.buttons
  end

  def slider
    state.slider
  end

  def bfs
    state.bfs
  end

  def heuristic
    state.heuristic
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

  def frontier_color
    [103, 136, 204] # Blue
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
  $heuristic_with_walls ||= Heuristic_With_Walls.new
  $heuristic_with_walls.args = args
  $heuristic_with_walls.tick
end


def reset
  $heuristic_with_walls = nil
end
