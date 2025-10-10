class Sudoku
  def initialize
    @square_lookup = {}
    @candidates_cache = {}
    9.each do |row|
      @square_lookup[row] ||= {}
      9.each do |col|
        @square_lookup[row][col] = { row: row, col: col, value: nil }
      end
    end
    @move_history = []
    @one_to_nine = (1..9).to_a
  end

  def undo!
    return if @move_history.empty?
    last_move = @move_history.pop_back
    set_value(row: last_move.row, col: last_move.col, value: last_move.value, record_history: false)
  end

  def empty_squares
    @square_lookup.keys
                  .flat_map { |k| @square_lookup[k].values }
                  .sort_by  { |s| [s.row, s.col] }
                  .find_all { |s| !s.value }
                  .map      { |s| { row: s.row, col: s.col } }
  end

  def get_value(row:, col:)
    @square_lookup[row][col].value
  end

  def set_value(row:, col:, value:, record_history: true)
    @move_history << { row: row, col: col, value: @square_lookup[row][col].value } if record_history
    @square_lookup[row][col].value = value
    @candidates_cache = {}
  end

  def __candidates_uncached__(row:, col:)
    used_values = relations(row: row, col: col).map { |s| s[:value] }
                                               .compact
                                               .uniq
    @one_to_nine - used_values
  end

  def candidates(row:, col:)
    return @candidates_cache[row][col] if @candidates_cache.dig(row, col)
    @candidates_cache[row] ||= {}
    @candidates_cache[row][col] ||= __candidates_uncached__(row: row, col: col)
    candidates(row: row, col: col)
  end

  def square_lookup
    @square_lookup.keys
                  .flat_map { |k| @square_lookup[k].values }
                  .sort_by  { |s| [s.row, s.col] }
  end

  def single_candidates
    singles = []
    squares.map { |s| Hash[row: s.row,
                           col: s.col,
                           candidates: candidates(row: s.row, col: s.col)] }
           .find_all { |s| s.candidates.length == 1 }
           .map { |s| { row: s.row, col: s.col, value: s.candidates.first } }
  end

  def relations(row:, col:)
    related = []

    9.each do |c|
      related << { **@square_lookup[row][c] } if c != col
    end

    9.each do |r|
      related << { **@square_lookup[r][col] } if r != row
    end

    box_start_row = (row.idiv 3) * 3
    box_start_col = (col.idiv 3) * 3
    3.each do |r_offset|
      3.each do |c_offset|
        r = box_start_row + r_offset
        c = box_start_col + c_offset
        related << { **@square_lookup[r][c] } if r != row && c != col
      end
    end

    related.uniq
  end
end

class Game
  attr_gtk

  attr :sudoku

  PARTITION_BG_COLOR = { r: 96, g: 156, b: 156 }
  PARTITION_OUTER_BG_COLOR = { r: 232, g: 232, b: 232 }
  BACKGROUND_COLOR = [30, 30, 30]
  SELECTED_RECT_COLOR = { r: 255, a: 128 }
  HOVERED_RECT_COLOR = { r: 255, g: 255, b: 255, a: 128 }
  CANDIDATE_COLOR = { r: 0, g: 0, b: 0 }
  NON_CANDIDATE_COLOR = { r: 200, g: 200, b: 200 }
  EMPTY_SQUARE_COLOR = { r: 128, g: 32, b: 32 }
  FILLED_SQUARE_COLOR = { r: 32, g: 64, b: 32 }
  SINGLE_CANDIDATE_DOT_COLOR = { r: 96, g: 255, b: 255 }
  MULTIPLE_CANDIDATE_DOT_COLOR = { r: 96, g: 128, b: 128 }
  LABEL_COLOR = { r: 255, g: 255, b: 255 }

  def initialize
    @sudoku = Sudoku.new
    @board = {}
    board_rects.each do |rect|
      @board[rect.row] ||= {}
      @board[rect.row][rect.col] = rect
    end

    @partition_bgs = 3.flat_map do |row|
      3.map do |col|
        Layout.rect(row: row * 3 + 1.5, col: col * 3 + 7.5, w: 3, h: 3)
              .merge(path: :solid, **PARTITION_BG_COLOR)
      end
    end

    @partition_outer_bgs = 3.flat_map do |row|
      3.map do |col|
        Layout.rect(row: row * 3 + 1.5, col: col * 3 + 7.5, w: 3, h: 3, include_row_gutter: true, include_col_gutter: true)
              .merge(path: :solid, **PARTITION_OUTER_BG_COLOR)
      end
    end

    @number_selection_rects = {
      rects: 10.map do |col|
        n = if col == 9
              nil
            else
              col + 1
            end
        Layout.rect(row: 0, col: 7 + col, w: 1, h: 1)
              .merge(number: n)
      end
    }
  end

  def tick
    @hovered_rect = find_square(inputs.mouse.x, inputs.mouse.y)

    input_click_square
    input_click_number

    outputs.background_color = BACKGROUND_COLOR
    outputs.primitives << board_prefab

    outputs.primitives << number_selection_prefab
    outputs.primitives << @selected_rect&.merge(path: :solid, **SELECTED_RECT_COLOR)
    outputs.primitives << @hovered_rect&.merge(path: :solid, **HOVERED_RECT_COLOR)
  end

  def input_click_square
    return if !@hovered_rect
    return if !inputs.mouse.click

    @selected_rect = @hovered_rect
    @select_number_shown_at = Kernel.tick_count
    @select_number_shown = true
  end

  def input_click_number
    return if !@select_number_shown

    if inputs.mouse.click || inputs.keyboard.key_down.char
      selected_number = if inputs.keyboard.key_down.char
                          n = inputs.keyboard.key_down.char.to_i
                          if n == 0
                            { number: nil}
                          else
                            { number: n }
                          end
                        else
                          @number_selection_rects.rects.find do |r|
                            Geometry.inside_rect?({ x: inputs.mouse.x, y: inputs.mouse.y, w: 1, h: 1 }, r)
                          end
                        end

      if selected_number
        @sudoku.set_value(row: @selected_rect.row, col: @selected_rect.col, value: selected_number.number)
        @selected_rect = nil
        @select_number_shown = false
        @select_number_shown_at = nil
      end
    end
  end

  def number_selection_prefab
    return nil if !@select_number_shown

    candidates = @sudoku.candidates(row: @selected_rect.row, col: @selected_rect.col)

    outputs.primitives << @number_selection_rects.rects.map do |r|
      color = if candidates.include?(r.number)
                CANDIDATE_COLOR
              else
                NON_CANDIDATE_COLOR
              end
      [
        r.merge(path: :solid),
        r.center.merge(text: r.number, anchor_x: 0.5, anchor_y: 0.5, **color)
      ]
    end
  end

  def board_rects
    9.flat_map do |row|
      9.map do |col|
        Layout.rect(row: row + 1.5, col: col + 7.5, w: 1, h: 1)
              .merge(row: row, col: col)
      end
    end
  end

  def square_mark_prefabs rect
    one_third_w = rect.w.fdiv 3
    one_third_h = rect.h.fdiv 3
    {
      1 => { x: rect.x + one_third_w * 0.5, y: rect.y + one_third_h * 2.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 },
      2 => { x: rect.x + one_third_w * 1.5, y: rect.y + one_third_h * 2.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 },
      3 => { x: rect.x + one_third_w * 2.5, y: rect.y + one_third_h * 2.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 },
      4 => { x: rect.x + one_third_w * 0.5, y: rect.y + one_third_h * 1.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 },
      5 => { x: rect.x + one_third_w * 1.5, y: rect.y + one_third_h * 1.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 },
      6 => { x: rect.x + one_third_w * 2.5, y: rect.y + one_third_h * 1.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 },
      7 => { x: rect.x + one_third_w * 0.5, y: rect.y + one_third_h * 0.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 },
      8 => { x: rect.x + one_third_w * 1.5, y: rect.y + one_third_h * 0.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 },
      9 => { x: rect.x + one_third_w * 2.5, y: rect.y + one_third_h * 0.5, w: 4, h: 4, anchor_x: 0.5, anchor_y: 0.5 }
    }
  end

  def find_square(mouse_x, mouse_y)
    mouse_rect = { x: mouse_x, y: mouse_y, w: 1, h: 1 }
    @board.each do |row, cols|
      cols.each do |col, rect|
        if Geometry.inside_rect?(mouse_rect, rect)
          return rect.merge(row: row, col: col)
        end
      end
    end

    nil
  end

  def square_prefabs
    @board.keys.flat_map do |row|
      @board[row].keys.map do |col|
        square_prefab(row: row, col: col)
      end
    end
  end

  def board_prefab
    @partition_outer_bgs + @partition_bgs + square_prefabs
  end

  def square_prefab(row:, col:)
    rect = @board[row][col]
    value = @sudoku.get_value(row: row, col: col)
    candidates = @sudoku.candidates(row: row, col: col)

    bg_color = if !value && candidates.empty?
                 EMPTY_SQUARE_COLOR
               else
                 FILLED_SQUARE_COLOR
               end

    label = if value
              {
                x: rect.center.x,
                y: rect.center.y,
                text: value,
                anchor_x: 0.5,
                anchor_y: 0.5,
                **LABEL_COLOR
              }
            else
              nil
            end

    dot_color = if candidates.length == 1
                  SINGLE_CANDIDATE_DOT_COLOR
                else
                  MULTIPLE_CANDIDATE_DOT_COLOR
                end

    dots = if value
             []
           else
             square_mark_prefabs(rect).find_all { |n, r| candidates.include?(n) }
                                      .map { |n, r| r.merge(path: :solid, **dot_color) }
           end

    [
      rect.merge(path: :solid, **bg_color),
      label,
      dots
    ]
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

GTK.reset
