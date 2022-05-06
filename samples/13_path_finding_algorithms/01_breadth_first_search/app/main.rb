# A visual demonstration of a breadth first search
# Inspired by https://www.redblobgames.com/pathfinding/a-star/introduction.html

# An animation that can respond to user input in real time

# A breadth first search expands in all directions one step at a time
# The frontier is a queue of cells to be expanded from
# The visited hash allows quick lookups of cells that have been expanded from
# The walls hash allows quick lookup of whether a cell is a wall

# The breadth first search starts by adding the red star to the frontier array
# and marking it as visited
# Each step a cell is removed from the front of the frontier array (queue)
# Unless the neighbor is a wall or visited, it is added to the frontier array
# The neighbor is then marked as visited

# The frontier is blue
# Visited cells are light brown
# Walls are camo green
# Even when walls are visited, they will maintain their wall color

# The star can be moved by clicking and dragging
# Walls can be added and removed by clicking and dragging

class BreadthFirstSearch
  attr_gtk

  def initialize(args)
    # Variables to edit the size and appearance of the grid
    # Freely customizable to user's liking
    args.state.grid.width     = 30
    args.state.grid.height    = 15
    args.state.grid.cell_size = 40

    # Stores which step of the animation is being rendered
    # When the user moves the star or messes with the walls,
    # the breadth first search is recalculated up to this step
    args.state.anim_steps = 0

    # At some step the animation will end,
    # and further steps won't change anything (the whole grid will be explored)
    # This step is roughly the grid's width * height
    # When anim_steps equals max_steps no more calculations will occur
    # and the slider will be at the end
    args.state.max_steps  = args.state.grid.width * args.state.grid.height

    # Whether the animation should play or not
    # If true, every tick moves anim_steps forward one
    # Pressing the stepwise animation buttons will pause the animation
    args.state.play       = true

    # The location of the star and walls of the grid
    # They can be modified to have a different initial grid
    # Walls are stored in a hash for quick look up when doing the search
    args.state.star       = [0, 0]
    args.state.walls      = {
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
    args.state.visited    = {}
    args.state.frontier   = []


    # What the user is currently editing on the grid
    # Possible values are: :none, :slider, :star, :remove_wall, :add_wall

    # We store this value, because we want to remember the value even when
    # the user's cursor is no longer over what they're interacting with, but
    # they are still clicking down on the mouse.
    args.state.click_and_drag = :none

    # Store the rects of the buttons that control the animation
    # They are here for user customization
    # Editing these might require recentering the text inside them
    # Those values can be found in the render_button methods
    args.state.buttons.left   = [450, 600, 50, 50]
    args.state.buttons.center = [500, 600, 200, 50]
    args.state.buttons.right  = [700, 600, 50, 50]

    # The variables below are related to the slider
    # They allow the user to customize them
    # They also give a central location for the render and input methods to get
    # information from
    # x & y are the coordinates of the leftmost part of the slider line
    args.state.slider.x = 400
    args.state.slider.y = 675
    # This is the width of the line
    args.state.slider.w = 360
    # This is the offset for the circle
    # Allows the center of the circle to be on the line,
    # as opposed to the upper right corner
    args.state.slider.offset = 20
    # This is the spacing between each of the notches on the slider
    # Notches are places where the circle can rest on the slider line
    # There needs to be a notch for each step before the maximum number of steps
    args.state.slider.spacing = args.state.slider.w.to_f / args.state.max_steps.to_f
  end

  # This method is called every frame/tick
  # Every tick, the current state of the search is rendered on the screen,
  # User input is processed, and
  # The next step in the search is calculated
  def tick
    render
    input
    # If animation is playing, and max steps have not been reached
    # Move the search a step forward
    if state.play && state.anim_steps < state.max_steps
      # Variable that tells the program what step to recalculate up to
      state.anim_steps += 1
      calc
    end
  end

  # Draws everything onto the screen
  def render
    render_buttons
    render_slider

    render_background
    render_visited
    render_frontier
    render_walls
    render_star
  end

  # The methods below subdivide the task of drawing everything to the screen

  # Draws the buttons that control the animation step and state
  def render_buttons
    render_left_button
    render_center_button
    render_right_button
  end

  # Draws the button which steps the search backward
  # Shows the user where to click to move the search backward
  def render_left_button
    # Draws the gray button, and a black border
    # The border separates the buttons visually
    outputs.solids  << [buttons.left, gray]
    outputs.borders << [buttons.left, black]

    # Renders an explanatory label in the center of the button
    # Explains to the user what the button does
    # If the button size is changed, the label might need to be edited as well
    # to keep the label in the center of the button
    label_x = buttons.left.x + 20
    label_y = buttons.left.y + 35
    outputs.labels  << [label_x, label_y, "<"]
  end

  def render_center_button
    # Draws the gray button, and a black border
    # The border separates the buttons visually
    outputs.solids  << [buttons.center, gray]
    outputs.borders << [buttons.center, black]

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
    # Draws the gray button, and a black border
    # The border separates the buttons visually
    outputs.solids  << [buttons.right, gray]
    outputs.borders << [buttons.right, black]

    # Renders an explanatory label in the center of the button
    # Explains to the user what the button does
    label_x = buttons.right.x + 20
    label_y = buttons.right.y + 35
    outputs.labels  << [label_x, label_y, ">"]
  end

  # Draws the slider so the user can move it and see the progress of the search
  def render_slider
    # Using primitives hides the line under the white circle of the slider
    # Draws the line
    outputs.primitives << [slider.x, slider.y, slider.x + slider.w, slider.y].line
    # The circle needs to be offset so that the center of the circle
    # overlaps the line instead of the upper right corner of the circle
    # The circle's x value is also moved based on the current seach step
    circle_x = (slider.x - slider.offset) + (state.anim_steps * slider.spacing)
    circle_y = (slider.y - slider.offset)
    circle_rect = [circle_x, circle_y, 37, 37]
    outputs.primitives << [circle_rect, 'circle-white.png'].sprite
  end

  # Draws what the grid looks like with nothing on it
  def render_background
    render_unvisited
    render_grid_lines
  end

  # Draws a rectangle the size of the entire grid to represent unvisited cells
  def render_unvisited
    outputs.solids << [scale_up([0, 0, grid.width, grid.height]), unvisited_color]
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

  # Draws the area that is going to be searched from
  # The frontier is the most outward parts of the search
  def render_frontier
    outputs.solids << state.frontier.map do |cell|
      [scale_up([cell.x, cell.y]), frontier_color]
    end
  end

  # Draws the walls
  def render_walls
    outputs.solids << state.walls.map do |wall|
      [scale_up([wall.x, wall.y]), wall_color]
    end
  end

  # Renders cells that have been searched in the appropriate color
  def render_visited
    outputs.solids << state.visited.map do |cell|
      [scale_up([cell.x, cell.y]), visited_color]
    end
  end

  # Renders the star
  def render_star
    outputs.sprites << [scale_up(state.star), 'star.png']
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
  # This method allows the user to use the buttons, slider, and edit the grid
  # There are 2 types of input:
  #   Button Input
  #   Click and Drag Input
  #
  #   Button Input is used for the backward step and forward step buttons
  #   Input is detected by mouse up within the bounds of the rect
  #
  #   Click and Drag Input is used for moving the star, adding walls,
  #   removing walls, and the slider
  #
  #   When the mouse is down on the star, the click_and_drag variable is set to :star
  #   While click_and_drag equals :star, the cursor's position is used to calculate the
  #   appropriate drag behavior
  #
  #   When the mouse goes up click_and_drag is set to :none
  #
  #   A variable has to be used because the star has to continue being edited even
  #   when the cursor is no longer over the star
  #
  #   Similar things occur for the other Click and Drag inputs
  def input
    # Checks whether any of the buttons are being clicked
    input_buttons

    # The detection and processing of click and drag inputs are separate
    # The program has to remember that the user is dragging an object
    # even when the mouse is no longer over that object
    detect_click_and_drag
    process_click_and_drag
  end

  # Detects and Process input for each button
  def input_buttons
    input_left_button
    input_center_button
    input_next_step_button
  end

  # Checks if the previous step button is clicked
  # If it is, it pauses the animation and moves the search one step backward
  def input_left_button
    if left_button_clicked?
      state.play = false
      state.anim_steps -= 1
      recalculate
    end
  end

  # Controls the play/pause button
  # Inverses whether the animation is playing or not when clicked
  def input_center_button
    if center_button_clicked? or inputs.keyboard.key_down.space
      state.play = !state.play
    end
  end

  # Checks if the next step button is clicked
  # If it is, it pauses the animation and moves the search one step forward
  def input_next_step_button
    if right_button_clicked?
      state.play = false
      state.anim_steps += 1
      calc
    end
  end

  # Determines what the user is editing and stores the value
  # Storing the value allows the user to continue the same edit as long as the
  # mouse left click is held
  def detect_click_and_drag
    if inputs.mouse.up
      state.click_and_drag = :none
    elsif star_clicked?
      state.click_and_drag = :star
    elsif wall_clicked?
      state.click_and_drag = :remove_wall
    elsif grid_clicked?
      state.click_and_drag = :add_wall
    elsif slider_clicked?
      state.click_and_drag = :slider
    end
  end

  # Processes click and drag based on what the user is currently dragging
  def process_click_and_drag
    if state.click_and_drag == :star
      input_star
    elsif state.click_and_drag == :remove_wall
      input_remove_wall
    elsif state.click_and_drag == :add_wall
      input_add_wall
    elsif state.click_and_drag == :slider
      input_slider
    end
  end

  # Moves the star to the grid closest to the mouse
  # Only recalculates the search if the star changes position
  # Called whenever the user is editing the star (puts mouse down on star)
  def input_star
    old_star = state.star.clone
    state.star = cell_closest_to_mouse
    unless old_star == state.star
      recalculate
    end
  end

  # Removes walls that are under the cursor
  def input_remove_wall
    # The mouse needs to be inside the grid, because we only want to remove walls
    # the cursor is directly over
    # Recalculations should only occur when a wall is actually deleted
    if mouse_inside_grid?
      if state.walls.has_key?(cell_closest_to_mouse)
        state.walls.delete(cell_closest_to_mouse)
        recalculate
      end
    end
  end

  # Adds walls at cells under the cursor
  def input_add_wall
    if mouse_inside_grid?
      unless state.walls.has_key?(cell_closest_to_mouse)
        state.walls[cell_closest_to_mouse] = true
        recalculate
      end
    end
  end

  # This method is called when the user is editing the slider
  # It pauses the animation and moves the white circle to the closest integer point
  # on the slider
  # Changes the step of the search to be animated
  def input_slider
    state.play = false
    mouse_x = inputs.mouse.point.x

    # Bounds the mouse_x to the closest x value on the slider line
    mouse_x = slider.x if mouse_x < slider.x
    mouse_x = slider.x + slider.w if mouse_x > slider.x + slider.w

    # Sets the current search step to the one represented by the mouse x value
    # The slider's circle moves due to the render_slider method using anim_steps
    state.anim_steps = ((mouse_x - slider.x) / slider.spacing).to_i

    recalculate
  end

  # Whenever the user edits the grid,
  # The search has to be recalculated upto the current step
  # with the current grid as the initial state of the grid
  def recalculate
    # Resets the search
    state.frontier = []
    state.visited = {}

    # Moves the animation forward one step at a time
    state.anim_steps.times { calc }
  end


  # This method moves the search forward one step
  # When the animation is playing it is called every tick
  # And called whenever the current step of the animation needs to be recalculated

  # Moves the search forward one step
  # Parameter called_from_tick is true if it is called from the tick method
  # It is false when the search is being recalculated after user editing the grid
  def calc

    # The setup to the search
    # Runs once when the there is no frontier or visited cells
    if state.frontier.empty? && state.visited.empty?
      state.frontier << state.star
      state.visited[state.star] = true
    end

    # A step in the search
    unless state.frontier.empty?
      # Takes the next frontier cell
      new_frontier = state.frontier.shift
      # For each of its neighbors
      adjacent_neighbors(new_frontier).each do |neighbor|
        # That have not been visited and are not walls
        unless state.visited.has_key?(neighbor) || state.walls.has_key?(neighbor)
          # Add them to the frontier and mark them as visited
          state.frontier << neighbor
          state.visited[neighbor] = true
        end
      end
    end
  end


  # Returns a list of adjacent cells
  # Used to determine what the next cells to be added to the frontier are
  def adjacent_neighbors(cell)
    neighbors = []

    neighbors << [cell.x, cell.y + 1] unless cell.y == grid.height - 1
    neighbors << [cell.x + 1, cell.y] unless cell.x == grid.width - 1
    neighbors << [cell.x, cell.y - 1] unless cell.y == 0
    neighbors << [cell.x - 1, cell.y] unless cell.x == 0

    neighbors
  end

  # When the user grabs the star and puts their cursor to the far right
  # and moves up and down, the star is supposed to move along the grid as well
  # Finding the cell closest to the mouse helps with this
  def cell_closest_to_mouse
    # Closest cell to the mouse
    x = (inputs.mouse.point.x / grid.cell_size).to_i
    y = (inputs.mouse.point.y / grid.cell_size).to_i
    # Bound x and y to the grid
    x = grid.width - 1 if x > grid.width - 1
    y = grid.height - 1 if y > grid.height - 1
    # Return closest cell
    [x, y]
  end

  # These methods detect when the buttons are clicked
  def left_button_clicked?
    inputs.mouse.up && inputs.mouse.point.inside_rect?(buttons.left)
  end

  def center_button_clicked?
    inputs.mouse.up && inputs.mouse.point.inside_rect?(buttons.center)
  end

  def right_button_clicked?
    inputs.mouse.up && inputs.mouse.point.inside_rect?(buttons.right)
  end

  # Signal that the user is going to be moving the slider
  # Is the mouse down on the circle of the slider?
  def slider_clicked?
    circle_x = (slider.x - slider.offset) + (state.anim_steps * slider.spacing)
    circle_y = (slider.y - slider.offset)
    circle_rect = [circle_x, circle_y, 37, 37]
    inputs.mouse.down && inputs.mouse.point.inside_rect?(circle_rect)
  end

  # Signal that the user is going to be moving the star
  def star_clicked?
    inputs.mouse.down && inputs.mouse.point.inside_rect?(scale_up(state.star))
  end

  # Signal that the user is going to be removing walls
  def wall_clicked?
    inputs.mouse.down && mouse_inside_a_wall?
  end

  # Signal that the user is going to be adding walls
  def grid_clicked?
    inputs.mouse.down && mouse_inside_grid?
  end

  # Returns whether the mouse is inside of a wall
  # Part of the condition that checks whether the user is removing a wall
  def mouse_inside_a_wall?
    state.walls.each_key do | wall |
      return true if inputs.mouse.point.inside_rect?(scale_up([wall.x, wall.y]))
    end

    false
  end

  # Returns whether the mouse is inside of a grid
  # Part of the condition that checks whether the user is adding a wall
  def mouse_inside_grid?
    inputs.mouse.point.inside_rect?(scale_up([0, 0, grid.width, grid.height]))
  end


  # These methods provide handy aliases to colors

  # Light brown
  def unvisited_color
    [221, 212, 213]
  end

  # Black
  def grid_line_color
    [255, 255, 255]
  end

  # Dark Brown
  def visited_color
    [204, 191, 179]
  end

  # Blue
  def frontier_color
    [103, 136, 204]
  end

  # Camo Green
  def wall_color
    [134, 134, 120]
  end

  # Button Background
  def gray
    [190, 190, 190]
  end

  # Button Outline
  def black
    [0, 0, 0]
  end

  # These methods make the code more concise
  def grid
    state.grid
  end

  def buttons
    state.buttons
  end

  def slider
    state.slider
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
  $breadth_first_search ||= BreadthFirstSearch.new(args)
  $breadth_first_search.args = args
  $breadth_first_search.tick
end


def reset
  $breadth_first_search = nil
end
