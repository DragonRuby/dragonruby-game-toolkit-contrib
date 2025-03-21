class Game
  attr_gtk

  def tick
    defaults
    calc
    render
  end

  def defaults
    # set rendering positions/properties
    state.cell_size     ||= 160
    state.left_margin   ||= (grid.w - 4 * state.cell_size) / 2
    state.bottom_margin ||= (grid.h - 4 * state.cell_size) / 2

    state.win_notification_duration ||= 180

    # if the board isn't initialized
    if !state.board || (state.win && state.won_at.elapsed_time > state.win_notification_duration)
      # generate a solvable board
      state.board = new_board

      # shuffle board until we have one that isn't already solved
      while solved_board?
        # difficulty increases with the number of wins
        state.win_count = if !state.win_count
                            0
                          else
                            state.win_count + 1
                          end

        # find the empty cell (the cell with the value 16) and swap it with a random neighbor
        # do this X times (win_count + 1 * 5) to make sure the board is scrambled
        shuffle_count = ((state.win_count + 1) * 5).clamp(10, 100)

        shuffle_count.times do
          empty_cell = board.find { |cell| cell.value == 16 }
          empty_cell_neighbors = neighbors empty_cell
          swap_with_empty empty_cell_neighbors.sample, empty_cell
        end
      end

      state.win = false
      state.won_at = nil
    end
  end

  def new_board
    # create a board with cells of the
    # following format:
    # {
    #   value: 1,
    #   loc: { row: 0, col: 0 },
    #   previous_loc: { row: 0, col: 0 },
    #   clicked_at: 0
    # }
    16.map_with_index do |i|
      { value: i + 1 }
    end.sort_by do |cell|
      cell.value
    end.map_with_index do |cell, index|
      row = 3 - index.idiv(4)
      col = index % 4
      cell.merge loc: { row: row, col: col },
                 previous_loc: { row: row, col: col },
                 clicked_at: -100
    end
  end

  def render
    outputs.sprites << board.map do |cell|
      # render the board centered in the middle of the screen
      prefab = cell_prefab cell
      prefab.merge x: state.left_margin + prefab.x, y: state.bottom_margin + prefab.y
    end

    # render the win message
    if state.won_at && state.won_at.elapsed_time < state.win_notification_duration
      # define a bezier spline that will be used to
      # fade in the win message stay visible for a little bit
      # then fade out
      spline = [
        [  0, 0.25, 0.75, 1.0],
        [1.0, 1.0,  1.0,  1.0],
        [1.0, 0.75, 0.25,   0]
      ]

      alpha_percentage = Easing.spline state.won_at,
                                       state.tick_count,
                                       state.win_notification_duration,
                                       spline

      outputs.sprites << {
        x: 0,
        y: grid.h.half - state.cell_size / 2,
        w: grid.w,
        h: state.cell_size,
        path: :pixel,
        r: 0,
        g: 0,
        b: 0,
        a: 255 * alpha_percentage,
      }

      outputs.labels << {
        x: grid.w.half,
        y: grid.h.half,
        text: "You won!",
        a: 255 * alpha_percentage,
        alignment_enum: 1,
        vertical_alignment_enum: 1,
        size_enum: (state.cell_size - 20) / 2,
        r: 255,
        g: 255,
        b: 255
      }
    end
  end

  def calc
    return if !inputs.mouse.click

    # determine which cell was clicked
    clicked_cell = board.find do |cell|
      mouse_rect = {
        x: inputs.mouse.x - state.left_margin,
        y: inputs.mouse.y - state.bottom_margin,
        w: 1,
        h: 1,
      }
      mouse_rect.intersect_rect? render_rect(cell.loc)
    end

    # return if no cell was clicked
    return if !clicked_cell

    # find the empty cell
    empty_cell = board.find { |cell| cell.value == 16 }

    # find the clicked cell's neighbors
    clicked_cell_neighbors = neighbors clicked_cell

    # return if the cell's neighbors doesn't include the empty cell
    return if !clicked_cell_neighbors.include?(empty_cell)

    # otherwise swap the clicked cell with the empty cell
    swap_with_empty clicked_cell, empty_cell

    # take note of the current tick count (which will be used for animation)
    clicked_cell.clicked_at = state.tick_count

    state.win = solved_board?

    state.won_at ||= state.tick_count if state.win
  end

  def solved_board?
    sorted_values = board.sort_by { |cell| (cell.loc.col + 1) + (16 - (cell.loc.row * 4)) }
                         .map { |cell| cell.value }

    sorted_values == (1..16).to_a
  end

  def swap_with_empty cell, empty
    # take not of the cell's current location (within previous_loc)
    cell.previous_loc = cell.loc

    # swap the cell's location with the empty cell's location and vice versa
    cell.loc, empty.loc = empty.loc, cell.loc
  end

  def cell_prefab cell
    # determine the percentage for the lerp that should be performed
    percentage = if cell.clicked_at
                   Easing.ease cell.clicked_at, state.tick_count, 15, :smooth_stop_quint, :flip
                 else
                   1
                 end

    # determine the cell's current render location
    cell_rect = render_rect cell.loc

    # determine the cell's previous render location
    previous_rect = render_rect cell.previous_loc

    # compute the difference between the current and previous render locations
    x = cell_rect.x + (previous_rect.x - cell_rect.x) * percentage
    y = cell_rect.y + (previous_rect.y - cell_rect.y) * percentage

    # return the cell prefab
    { x: x,
      y: y,
      w: state.cell_size,
      h: state.cell_size,
      path: "sprites/pieces/#{cell.value}.png" }
  end

  # helper method to determine the render location of a cell in local space
  # which excludes the margins
  def render_rect loc
    {
      x: loc.col * state.cell_size,
      y: loc.row * state.cell_size,
      w: state.cell_size,
      h: state.cell_size,
    }
  end

  # helper methods to determine neighbors of a cell
  def neighbors cell
    [
      above_cell(cell),
      below_cell(cell),
      left_cell(cell),
      right_cell(cell),
    ].compact
  end

  def below_cell cell
    find_cell cell, -1, 0
  end

  def above_cell cell
    find_cell cell, 1, 0
  end

  def left_cell cell
    find_cell cell, 0, -1
  end

  def right_cell cell
    find_cell cell, 0, 1
  end

  def find_cell cell, d_row, d_col
    board.find do |other_cell|
      cell.loc.row == other_cell.loc.row + d_row &&
      cell.loc.col == other_cell.loc.col + d_col
    end
  end

  def board
    state.board
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

$gtk.reset
