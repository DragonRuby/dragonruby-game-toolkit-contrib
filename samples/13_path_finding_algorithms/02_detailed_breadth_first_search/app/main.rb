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

# This search numbers the order in which new cells are explored
# The next cell from where the search will continue is highlighted yellow
# And the cells that will be considered for expansion are in semi-transparent green

# The star can be moved by clicking and dragging
# Walls can be added and removed by clicking and dragging

class DetailedBreadthFirstSearch
  attr_gtk

  def initialize(args)
    # Variables to edit the size and appearance of the grid
    # Freely customizable to user's liking
    args.state.grid.width     = 9
    args.state.grid.height    = 4
    args.state.grid.cell_size = 90

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

    # The location of the star and walls of the grid
    # They can be modified to have a different initial grid
    # Walls are stored in a hash for quick look up when doing the search
    args.state.star       = [3, 2]
    args.state.walls      = {}    

    # Variables that are used by the breadth first search
    # Storing cells that the search has visited, prevents unnecessary steps
    # Expanding the frontier of the search in order makes the search expand
    # from the center outward
    args.state.visited    = {}
    args.state.frontier   = []
    args.state.cell_numbers = []



    # What the user is currently editing on the grid
    # Possible values are: :none, :slider, :star, :remove_wall, :add_wall

    # We store this value, because we want to remember the value even when
    # the user's cursor is no longer over what they're interacting with, but
    # they are still clicking down on the mouse.
    args.state.click_and_drag = :none 

    # The x, y, w, h values for the buttons
    # Allow easy movement of the buttons location
    # A centralized location to get values to detect input and draw the buttons
    # Editing these values might mean needing to edit the label offsets
    # which can be found in the appropriate render button methods
    args.state.buttons.left  = [450, 600, 160, 50]
    args.state.buttons.right = [610, 600, 160, 50]

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
  def tick
    render 
    input  
  end

  # This method is called from tick and renders everything every tick
  def render
    render_buttons
    render_slider

    render_background       
    render_visited 
    render_frontier
    render_walls
    render_star

    render_highlights
    render_cell_numbers
  end

  # The methods below subdivide the task of drawing everything to the screen

  # Draws the buttons that move the search backward or forward
  # These buttons are rendered so the user knows where to click to move the search
  def render_buttons
    render_left_button
    render_right_button
  end

  # Renders the button which steps the search backward
  # Shows the user where to click to move the search backward
  def render_left_button
    # Draws the gray button, and a black border
    # The border separates the buttons visually
    outputs.solids  << [buttons.left, gray]
    outputs.borders << [buttons.left, black]

    # Renders an explanatory label in the center of the button
    # Explains to the user what the button does
    label_x = buttons.left.x + 05
    label_y = buttons.left.y + 35
    outputs.labels  << [label_x, label_y, "< Step backward"]
  end

  # Renders the button which steps the search forward
  # Shows the user where to click to move the search forward
  def render_right_button
    # Draws the gray button, and a black border
    # The border separates the buttons visually
    outputs.solids  << [buttons.right, gray]
    outputs.borders << [buttons.right, black]

    # Renders an explanatory label in the center of the button
    # Explains to the user what the button does
    label_x = buttons.right.x + 10
    label_y = buttons.right.y + 35
    outputs.labels  << [label_x, label_y, "Step forward >"]
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
  # Which is a bunch of unvisited cells
  # Drawn first so other things can draw on top of it
  def render_background
    render_unvisited  

    # The grid lines make the cells appear separate
    render_grid_lines 
  end

  # Draws a rectangle the size of the entire grid to represent unvisited cells
  # Unvisited cells are the default cell
  def render_unvisited
    background = [0, 0, grid.width, grid.height]
    outputs.solids << [scale_up(background), unvisited_color]
  end

  # Draws grid lines to show the division of the grid into cells
  def render_grid_lines
    for x in 0..grid.width
      outputs.lines << [scale_up(vertical_line(x)), grid_line_color]
    end

    for y in 0..grid.height
      outputs.lines << [scale_up(horizontal_line(y)), grid_line_color]
    end
  end

  # Easy way to get a vertical line given an index
  def vertical_line column
    [column, 0, column, grid.height] 
  end

  # Easy way to get a horizontal line given an index
  def horizontal_line row
    [0, row, grid.width, row]
  end

  # Draws the area that is going to be searched from
  # The frontier is the most outward parts of the search
  def render_frontier
    state.frontier.each do |cell| 
      outputs.solids << [scale_up(cell), frontier_color]
    end
  end

  # Draws the walls
  def render_walls
    state.walls.each_key do |wall|
      outputs.solids << [scale_up(wall), wall_color]
    end
  end

  # Renders cells that have been searched in the appropriate color
  def render_visited
    state.visited.each_key do |cell| 
      outputs.solids << [scale_up(cell), visited_color]
    end
  end

  # Renders the star
  def render_star
    outputs.sprites << [scale_up(state.star), 'star.png']
  end 

  # Cells have a number rendered in them based on when they were explored
  # This is based off of their index in the cell_numbers array
  # Cells are added to this array the same time they are added to the frontier array
  def render_cell_numbers
    state.cell_numbers.each_with_index do |cell, index|
      # Math that approx centers the number in the cell
      label_x = (cell.x * grid.cell_size) + grid.cell_size / 2 - 5
      label_y = (cell.y * grid.cell_size) + (grid.cell_size / 2) + 5

      outputs.labels << [label_x, label_y, (index + 1).to_s]
    end
  end

  # The next frontier to be expanded is highlighted yellow
  # Its adjacent non-wall neighbors have their border highlighted green
  # This is to show the user how the search expands
  def render_highlights
    return if state.frontier.empty?

    # Highlight the next frontier to be expanded yellow
    next_frontier = state.frontier[0]
    outputs.solids << [scale_up(next_frontier), highlighter_yellow]

    # Neighbors have a semi-transparent green layer over them
    # Unless the neighbor is a wall
    adjacent_neighbors(next_frontier).each do |neighbor|
      unless state.walls.has_key?(neighbor)
        outputs.solids << [scale_up(neighbor), highlighter_green, 70]
      end
    end
  end


  # Cell Size is used when rendering to allow the grid to be scaled up or down
  # Cells in the frontier array and visited hash and walls hash are stored as x & y
  # Scaling up cells and lines when rendering allows omitting of width and height
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
    # Processes inputs for the buttons
    input_buttons

    # Detects which if any click and drag input is occurring
    detect_click_and_drag          

    # Does the appropriate click and drag input based on the click_and_drag variable
    process_click_and_drag         
  end

  # Detects and Process input for each button
  def input_buttons
    input_left_button 
    input_right_button     
  end

  # Checks if the previous step button is clicked
  # If it is, it pauses the animation and moves the search one step backward
  def input_left_button 
    if left_button_clicked?
      unless state.anim_steps == 0
        state.anim_steps -= 1
        recalculate
      end
    end
  end

  # Checks if the next step button is clicked
  # If it is, it pauses the animation and moves the search one step forward
  def input_right_button
    if right_button_clicked?
      unless state.anim_steps == state.max_steps
        state.anim_steps += 1           
        # Although normally recalculate would be called here
        # because the right button only moves the search forward
        # We can just do that
        calc
      end
    end
  end

  # Whenever the user edits the grid,
  # The search has to be recalculated upto the current step

  def recalculate
    # Resets the search
    state.frontier = [] 
    state.visited = {} 
    state.cell_numbers = []

    # Moves the animation forward one step at a time
    state.anim_steps.times { calc } 
  end


  # Determines what the user is clicking and planning on dragging
  # Click and drag input is initiated by a click on the appropriate item
  # and ended by mouse up
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

  # Processes input based on what the user is currently dragging
  def process_click_and_drag
    if state.click_and_drag == :slider          
      input_slider                          
    elsif state.click_and_drag == :star         
      input_star                            
    elsif state.click_and_drag == :remove_wall  
      input_remove_wall                     
    elsif state.click_and_drag == :add_wall     
      input_add_wall                        
    end
  end

  # This method is called when the user is dragging the slider
  # It moves the current animation step to the point represented by the slider
  def input_slider
    mouse_x = inputs.mouse.point.x

    # Bounds the mouse_x to the closest x value on the slider line
    mouse_x = slider.x if mouse_x < slider.x 
    mouse_x = slider.x + slider.w if mouse_x > slider.x + slider.w 

    # Sets the current search step to the one represented by the mouse x value
    # The slider's circle moves due to the render_slider method using anim_steps
    state.anim_steps = ((mouse_x - slider.x) / slider.spacing).to_i

    recalculate 
  end

  # Moves the star to the grid closest to the mouse
  # Only recalculates the search if the star changes position
  # Called whenever the user is dragging the star 
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
    # Adds a wall to the hash
    # We can use the grid closest to mouse, because the cursor is inside the grid
    if mouse_inside_grid? 
      unless state.walls.has_key?(cell_closest_to_mouse)
        state.walls[cell_closest_to_mouse] = true 
        recalculate 
      end
    end
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

          # Also assign them a frontier number
          state.cell_numbers << neighbor
        end
      end
    end
  end
  

  # Returns a list of adjacent cells
  # Used to determine what the next cells to be added to the frontier are
  def adjacent_neighbors cell
    neighbors = [] 

    neighbors << [cell.x, cell.y + 1] unless cell.y == grid.height - 1 
    neighbors << [cell.x + 1, cell.y] unless cell.x == grid.width - 1 
    neighbors << [cell.x, cell.y - 1] unless cell.y == 0 
    neighbors << [cell.x - 1, cell.y] unless cell.x == 0 

    neighbors 
  end

  # When the user grabs the star and puts their cursor to the far right
  # and moves up and down, the star is supposed to move along the grid as well
  # Finding the grid closest to the mouse helps with this
  def cell_closest_to_mouse
    x = (inputs.mouse.point.x / grid.cell_size).to_i 
    y = (inputs.mouse.point.y / grid.cell_size).to_i 
    x = grid.width - 1 if x > grid.width - 1 
    y = grid.height - 1 if y > grid.height - 1 
    [x, y] 
  end


  # These methods detect when the buttons are clicked
  def left_button_clicked?
    (inputs.mouse.up && inputs.mouse.point.inside_rect?(buttons.left)) || inputs.keyboard.key_up.left
  end

  def right_button_clicked?
    (inputs.mouse.up && inputs.mouse.point.inside_rect?(buttons.right)) || inputs.keyboard.key_up.right
  end

  # Signal that the user is going to be moving the slider
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
      return true if inputs.mouse.point.inside_rect?(scale_up(wall))
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

  # Next frontier to be expanded
  def highlighter_yellow
    [214, 231, 125]
  end

  # The neighbors of the next frontier to be expanded
  def highlighter_green
    [65, 191, 127]
  end

  # Button background
  def gray
    [190, 190, 190]
  end

  # Button outline
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


def tick args
  # Pressing r resets the program
  if args.inputs.keyboard.key_down.r
    args.gtk.reset
    reset
    return
  end

  $detailed_breadth_first_search ||= DetailedBreadthFirstSearch.new(args)
  $detailed_breadth_first_search.args = args
  $detailed_breadth_first_search.tick
end


def reset
  $detailed_breadth_first_search = nil
end
