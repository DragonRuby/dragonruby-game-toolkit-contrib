class Game
  attr_gtk

  def initialize
    # rng is sent to Random so that everyone gets the same levels
    @rng = Random.new 100

    @solved_board = (1..16).to_a

    # rendering size of the cell
    @cell_size = 128

    # compute left and right margins based on cell size
    @left_margin = (Grid.w - 4 * @cell_size) / 2
    @bottom_margin = (Grid.h - 4 * @cell_size) / 2

    # how long notifications should be displayed
    @notification_duration = 110

    # frame that the player won
    @completed_at = nil

    # number of times the player won
    @win_count = 0

    # spline that represents fade in and fade out of notifications
    @notification_spline = [
      [  0, 0.25, 0.75, 1.0],
      [1.0, 1.0,  1.0,  1.0],
      [1.0, 0.75, 0.25,   0]
    ]

    # current moves the player has taken on level
    @current_move_count = 0

    # move history so that undos decreases the move count
    @move_history = []

    # create a new shuffed board
    new_suffled_board!
  end

  def tick
    calc
    render
  end

  def new_suffled_board!
    # set the board to a new board
    @board = new_board

    # while the board is in a solved state
    while solved_board?
      # difficulty increases with the number of wins
      # find the empty cell (the cell with the value 16) and swap it with a random neighbor
      # do this X times (win_count + 1 * 5) to make sure the board is scrambled
      @shuffle_count = ((@win_count + 1) * 2).clamp(7, 100).to_i

      # neighbor to exclude to better shuffle the board
      exclude_neighor = nil
      @shuffle_count.times do
        # get candidate neighbors based off of neighbors of the empty cell
        # exclude the neighbor that is the mirror of the last selected neighbor
        shuffle_candidates = empty_cell_neighbors.reject do |neighbor|
          neighbor.relative_location == exclude_neighor&.mirror_location ||
          neighbor.mirror_location == exclude_neighor&.relative_location
        end

        # select a random neighbor based off of the candidate size and RNG
        selected_neighbor = shuffle_candidates[@rng.rand(shuffle_candidates.length)]

        # if the number of candidates is greater than 2, then update the exclude neighbor
        exclude_neighor = if shuffle_candidates.length >= 2
                            selected_neighbor
                          else
                            nil
                          end

        # shuffle the board by swapping the empty cell with the selected candidate
        swap_with_empty selected_neighbor.cell, empty_cell
      end
    end

    # after shuffling, reset the current move count
    @max_move_count = (@shuffle_count * 1.1).to_i

    # capture the current board state so that the player can try again (game over)
    @try_again_board = @board.copy
    @started_at = Kernel.tick_count

    # reset the completed_at time
    @completed_at = nil

    # clear the move history
    @move_history.clear
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
    # render the current level and current move count (and max move count)
    outputs.labels << { x: 640, y: 720 - 64, anchor_x: 0.5, anchor_y: 0.5, text: "Level: #{@win_count + 1}", size_px: 64 }
    outputs.labels << { x: 640, y: 64, anchor_x: 0.5, anchor_y: 0.5, text: "Moves: #{@current_move_count} (#{@max_move_count})", size_px: 64 }

    # render each cell
    outputs.sprites << @board.map do |cell|
      # render the board centered in the middle of the screen
      prefab = cell_prefab cell
      prefab.merge x: @left_margin + prefab.x, y: @bottom_margin + prefab.y
    end

    # if the game has just started, display the notification of how many moves the player has to complete the level
    if @started_at && @started_at.elapsed_time < @notification_duration
      alpha_percentage = Easing.spline @started_at,
                                       Kernel.tick_count,
                                       @notification_duration,
                                       @notification_spline

      outputs.primitives << notification_prefab( "Complete in #{@max_move_count} or less.", alpha_percentage)
    end

    # if the game is completed, display the notification based on whether the player won or lost
    if @completed_at && @completed_at.elapsed_time < @notification_duration
      alpha_percentage = Easing.spline @completed_at,
                                       Kernel.tick_count,
                                       @notification_duration,
                                       @notification_spline

      message = if @current_move_count <= @max_move_count
                  "You won!"
                else
                  "Try again!"
                end

      outputs.primitives << notification_prefab(message, alpha_percentage)
    end
  end

  # notification prefab that displays a message in the center of the screen
  def notification_prefab text, alpha_percentage
    [
      {
        x: 0,
        y: grid.h.half - @cell_size / 2,
        w: grid.w,
        h: @cell_size,
        path: :pixel,
        r: 0,
        g: 0,
        b: 0,
        a: 255 * alpha_percentage,
      },
      {
        x: grid.w.half,
        y: grid.h.half,
        text: text,
        a: 255 * alpha_percentage,
        anchor_x: 0.5,
        anchor_y: 0.5,
        size_px: 80,
        r: 255,
        g: 255,
        b: 255
      }
    ]
  end

  def calc
    # set the completed_at time if the board is solved
    @completed_at ||= Kernel.tick_count if solved_board?

    # if the game is completed, then reset the board to either a new shuffled board or the try again board
    if @completed_at && @completed_at.elapsed_time > @notification_duration
      @completed_at = nil

      # if the player has not exceeded the max move count, then reset the board to a new shuffled board
      if @current_move_count <= @max_move_count
        new_suffled_board!
        @win_count ||= 0
        @win_count += 1
        @current_move_count = 0
      else
        # otherwise reset the board to the try again board
        @board = @try_again_board.copy
        @current_move_count = 0
      end
    end

    # don't process any input if the game is completed
    return if @completed_at

    # select the cell based on mouse, keyboard, or controller input
    selected_cell = if inputs.mouse.click
                      @board.find do |cell|
                        mouse_rect = {
                          x: inputs.mouse.x - @left_margin,
                          y: inputs.mouse.y - @bottom_margin,
                          w: 1,
                          h: 1,
                        }
                        mouse_rect.intersect_rect? render_rect(cell.loc)
                      end
                    elsif inputs.key_down.left || inputs.controller_one.key_down.x
                      empty_cell_neighbors.find { |n| n.relative_location == :left }&.cell
                    elsif inputs.key_down.right || inputs.controller_one.key_down.b
                      empty_cell_neighbors.find { |n| n.relative_location == :right }&.cell
                    elsif inputs.key_down.up || inputs.controller_one.key_down.y
                      empty_cell_neighbors.find { |n| n.relative_location == :above }&.cell
                    elsif inputs.key_down.down || inputs.controller_one.key_down.a
                      empty_cell_neighbors.find { |n| n.relative_location == :below }&.cell
                    end

    # if no cell is selected, then return
    return if !selected_cell

    # find the clicked cell's neighbors
    clicked_cell_neighbors = neighbors selected_cell

    # return if the cell's neighbors doesn't include the empty cell
    return if !clicked_cell_neighbors.map { |c| c.cell }.include?(empty_cell)

    # set when the cell was clicked so that animation can be performed
    selected_cell.clicked_at = Kernel.tick_count

    # capture the before and after swap locations so that undo can be performed
    before_swap = empty_cell.loc.copy
    swap_with_empty selected_cell, empty_cell
    after_swap = empty_cell.loc.copy
    @move_history.push_front({ before: before_swap, after: after_swap })

    frt_history = @move_history[0]
    snd_history = @move_history[1]

    # check if the last move was a reverse of the previous move, if so then decrease the move count
    if frt_history && snd_history && frt_history.after == snd_history.before && frt_history.before == snd_history.after
      @move_history.pop_front
      @move_history.pop_front
      @current_move_count -= 1
    else
      # otherwise increase the move count
      @current_move_count += 1
    end
  end

  def solved_board?
    # sort the board by the cell's location and map the values (which will be 1 to 16)
    sorted_values = @board.sort_by { |cell| (cell.loc.col + 1) + (16 - (cell.loc.row * 4)) }
                          .map { |cell| cell.value }

    # check if the sorted values are equal to the expected values (1 to 16)
    sorted_values == @solved_board
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
                   Easing.smooth_stop start_at: cell.clicked_at, duration: 15, tick_count: Kernel.tick_count, power: 5, flip: true
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
      w: @cell_size,
      h: @cell_size,
      path: "sprites/pieces/#{cell.value}.png" }
  end

  # helper method to determine the render location of a cell in local space
  # which excludes the margins
  def render_rect loc
    {
      x: loc.col * @cell_size,
      y: loc.row * @cell_size,
      w: @cell_size,
      h: @cell_size,
    }
  end

  # helper methods to determine neighbors of a cell
  def neighbors cell
    [
      { mirror_location: :below, relative_location: :above, cell: above_cell(cell) },
      { mirror_location: :above, relative_location: :below, cell: below_cell(cell) },
      { mirror_location: :right, relative_location:  :left, cell: left_cell(cell)  },
      { mirror_location: :left,  relative_location: :right, cell: right_cell(cell) },
    ].reject { |neighbor| !neighbor.cell }
  end

  def empty_cell
    @board.find { |cell| cell.value == 16 }
  end

  def empty_cell_neighbors
    neighbors empty_cell
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
    @board.find do |other_cell|
      cell.loc.row == other_cell.loc.row + d_row &&
      cell.loc.col == other_cell.loc.col + d_col
    end
  end
end

def boot args
  args.state ||= {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
  args.state = {}
end

# GTK.reset
