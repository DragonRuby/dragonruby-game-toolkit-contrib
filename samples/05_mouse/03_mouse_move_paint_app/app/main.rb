# This sample app shows an empty grid that the user can paint on.
# To paint, the user must keep their mouse presssed and drag it around the grid.
# The "clear" button allows users to clear the grid so they can start over.
class Game
  attr_dr

  # Runs methods necessary for the game to function properly.
  def tick
    tick_draw
    render_title
    render_grid
    render_button
  end

  # Prints the title onto the screen by using a label.
  # Also separates the title from the grid with a line as a horizontal separator.
  def render_title
    args.outputs.labels << { x: 640, y: 700, text: 'Paint!', anchor_x: 0.5, anchor_y: 0.5 }
    args.outputs.labels << { x: 640, y: 700, text: 'Click/hold left mouse button: Draw. Click/hold right mouse button: Delete.', anchor_x: 0.5, anchor_y: 1.5 }
    outputs.lines << horizontal_separator(660, 0, 1280)
  end

  # Sets the starting position, ending position, and color for the horizontal separator.
  # The starting and ending positions have the same y values.
  def horizontal_separator y, x, x2
    { x: x, y: y, x2: x2, y2: y, r: 150, g: 150, b: 150 }
  end

  # Sets the starting position, ending position, and color for the vertical separator.
  # The starting and ending positions have the same x values.
  def vertical_separator x, y, y2
    { x: x, y: y, x2: x, y2: y2, r: 150, g: 150, b: 150 }
  end

  # Outputs a border and a grid containing empty squares onto the screen.
  def render_grid
    # Sets the x, y, height, and width of the grid.
    # There are 31 horizontal lines and 31 vertical lines in the grid.
    # Feel free to count them yourself before continuing!
    x, y, h, w = 640 - 500/2, 640 - 500, 500, 500 # calculations done so the grid appears in screen's center
    lines_h = 31
    lines_v = 31

    # Sets values for the grid's border, grid lines, and filled squares.
    # The filled_squares variable is initially set to an empty array.
    state.grid_border ||= { x: x, y: y, w: w, h: h } # definition of grid's outer border
    state.grid_lines ||= draw_grid(x, y, w, h, lines_h, lines_v) # calls draw_grid method
    state.filled_squares ||= [] # there are no filled squares until the user fills them in

    # Outputs the grid lines, border, and filled squares onto the screen.
    outputs.lines << state.grid_lines
    outputs.borders << state.grid_border
    outputs.sprites << state.filled_squares
  end

  # Draws the grid by adding in vertical and horizontal separators.
  def draw_grid x, y, h, w, lines_h, lines_v
    # The grid starts off empty.
    grid = []

    # Calculates the placement and adds horizontal lines or separators into the grid.
    curr_y = y # start at the bottom of the box
    dist_y = h / (lines_h + 1) # finds distance to place horizontal lines evenly throughout 500 height of grid
    lines_h.times do
      curr_y += dist_y # increment curr_y by the distance between the horizontal lines
      grid << horizontal_separator(curr_y, x, x + w - 1) # add a separator into the grid
    end

    # Calculates the placement and adds vertical lines or separators into the grid.
    curr_x = x # now start at the left of the box
    dist_x = w / (lines_v + 1) # finds distance to place vertical lines evenly throughout 500 width of grid
    lines_v.times do
      curr_x += dist_x # increment curr_x by the distance between the vertical lines
      grid << vertical_separator(curr_x, y + 1, y  + h) # add separator
    end

    # paint_grid uses a hash to assign values to keys.
    state.paint_grid ||= {
      x: x,
      y: y,
      h: h,
      w: w,
      lines_h: lines_h,
      lines_v: lines_v,
      dist_x: dist_x,
      dist_y: dist_y
    }

    return grid
  end

  # Draw squares on left click/held, delete squares on right click/held
  def tick_draw
    return if !Geometry.inside_rect?(inputs.mouse, state.grid_border)

    point = {
      x: inputs.mouse.x,
      y: inputs.mouse.y,
    }

    point.x -= state.paint_grid.x # subtracts the value assigned to the "x" key in the paint_grid hash
    point.y -= state.paint_grid.y # subtracts the value assigned to the "y" key in the paint_grid hash

    # Remove code following the .floor and see what happens when you try to fill in grid squares
    point.x = (point.x / state.paint_grid.dist_x).floor * state.paint_grid.dist_x
    point.y = (point.y / state.paint_grid.dist_y).floor * state.paint_grid.dist_y

    point.x += state.paint_grid.x
    point.y += state.paint_grid.y

    # Sets definition of a grid box, meaning its x, y, width, and height.
    # Floor is called on the point.x and point.y variables.
    # Ceil method is called on values of the distance hash keys, setting the width and height of a box.
    grid_box = {
      x: point.x.floor,
      y: point.y.floor,
      w: state.paint_grid.dist_x.ceil,
      h: state.paint_grid.dist_y.ceil,
      r: 0, g: 0, b: 0,
      path: :solid
    }

    if inputs.mouse.left
      if !state.filled_squares.include?(grid_box) # if grid box is already filled in
        state.filled_squares << grid_box # otherwise, box is filled in and added to filled_squares
      end
    elsif inputs.mouse.right
      if state.filled_squares.include?(grid_box) # if grid box is already filled in
        state.filled_squares.delete grid_box # otherwise, box is filled in and added to filled_squares
      end
    end
  end

  # Creates and outputs a "Clear" button on the screen using a label and a border.
  # If the button is clicked, the filled squares are cleared, making the filled_squares collection empty.
  def render_button
    x, y, w, h = 390, 50, 240, 50
    state.clear_button ||= {
      label: {
        x: x + w / 2,
        y: y + h / 2,
        text: "Clear",
        anchor_x: 0.5,
        anchor_y: 0.5
      },
      border: { x: x, y: y, w: w, h: h, primitive_marker: :border }
    }

    # If the mouse is clicked inside the borders of the clear button,
    # the filled_squares collection is emptied and the squares are cleared.
    if inputs.mouse.click && Geometry.inside_rect?(inputs.mouse, state.clear_button.border)
      state.clear_button.clicked_at = Kernel.tick_count
      state.filled_squares.clear
    end

    outputs.primitives << state.clear_button.label
    outputs.primitives << state.clear_button.border

    # When the clear button is clicked, the color of the button changes
    # and the transparency changes, as well. If you change the time from
    # 0.25.seconds to 1.25.seconds or more, the change will last longer.
    if state.clear_button.clicked_at
      perc = Easing.smooth_stop(start_at: state.clear_button.clicked_at,
                                duration: 0.25.seconds,
                                tick_count: Kernel.tick_count,
                                flip: true)
      outputs.sprites << {
        x: x,
        y: y,
        w: w,
        h: h,
        path: :solid,
        r: 0,
        g: 180,
        b: 80,
        a: 255 * perc
      }
    end
  end
end

module Main
  def tick args
    @game ||= Game.new
    @game.args = args
    @game.tick
  end

  def reset args
    @game = nil
  end
end

DR.reset
