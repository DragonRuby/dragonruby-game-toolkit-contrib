# https://www.redblobgames.com/pathfinding/a-star/introduction.html
# Contributors
# - Sujay Vadlakonda: https://github.com/sujayvadlakonda
class PriorityQueue
  attr :ary

  def initialize &has_priority_block
    @ary = []
    @has_priority_block = has_priority_block
  end

  def heapify n, i
    top_priority = i
    l = 2 * i + 1
    r = 2 * i + 2

    top_priority = l if l < n && @has_priority_block.call(@ary[l], @ary[top_priority])
    top_priority = r if r < n && @has_priority_block.call(@ary[r], @ary[top_priority])

    return if top_priority == i

    @ary[i], @ary[top_priority] = @ary[top_priority], @ary[i]
    heapify n, top_priority
  end

  def insert n
    @ary.push_back n
    current = @ary.length - 1
    while current > 0
      parent = (current - 1) >> 1
      if @has_priority_block.call(@ary[current], @ary[parent])
        @ary[current], @ary[parent] = @ary[parent], @ary[current]
        current = parent
      else
        break
      end
    end
  end

  def extract
    l = @ary.length
    @ary[0], @ary[l - 1] = @ary[l - 1], @ary[0]
    result = @ary.pop_back
    heapify @ary.length, 0 if 0 < @ary.length
    result
  end

  def empty? = @ary.empty?
end

class AStar
  attr :frontier, :came_from, :path, :cost, :status,
       :start_location, :end_location, :walls

  def initialize(start_location:, end_location:, walls:, grid_size:)
    @grid_size = grid_size
    @start_location = start_location.slice(:ordinal_x, :ordinal_y)
    @end_location = end_location.slice(:ordinal_x, :ordinal_y)
    @walls = walls.map do |w|
      [w.slice(:ordinal_x, :ordinal_y), true ]
    end.to_h

    @directions = [
      { ordinal_x:  1, ordinal_y:  0 },
      { ordinal_x: -1, ordinal_y:  0 },
      { ordinal_x:  0, ordinal_y:  1 },
      { ordinal_x:  0, ordinal_y: -1 }
    ]

    @came_from = {}
    @path = []
    @cost = {}
    @status = :ready
    @frontier = PriorityQueue.new do |a, b|
      a_result = [@cost[a] + greedy_heuristic(a), proximity_to_start_location(a)]
      b_result = [@cost[b] + greedy_heuristic(b), proximity_to_start_location(b)]
      (a_result <=> b_result) == -1
    end
  end

  def start!
    @status = :solving
    @came_from[@start_location] = nil
    @cost[@start_location] = 0
    @frontier.insert @start_location
  end

  def tick
    tick_solve
    tick_generate_path
  end

  def tick_solve
    return if @status != :solving

    current_frontier = @frontier.extract
    new_locations = adjacent_locations(current_frontier)

    new_locations.find_all do |loc|
      !@came_from[loc] && !@walls[loc]
    end.each do |loc|
      @came_from[loc] = current_frontier
      @cost[loc] = (@cost[current_frontier] || 0) + 1
      @frontier.insert loc
    end

    if @frontier.empty? || @came_from[@end_location]
      if @came_from[@end_location]
        @status = :calculating_path
        @current_path_location = @end_location
      else
        @status = :complete
      end
    end
  end

  def greedy_heuristic(loc)
    (@end_location.ordinal_x - loc.ordinal_x).abs +
    (@end_location.ordinal_y - loc.ordinal_y).abs
  end

  def proximity_to_start_location(loc)
    distance_x = (@start_location.ordinal_x - loc.ordinal_x).abs
    distance_y = (@start_location.ordinal_y - loc.ordinal_y).abs

    if distance_x > distance_y
      return distance_x
    else
      return distance_y
    end
  end

  def tick_generate_path
    return if @status != :calculating_path
    @path << @current_path_location
    @current_path_location = @came_from[@current_path_location]
    if @current_path_location == @start_location
      @path << @current_path_location
      @status = :complete
    elsif !@current_path_location
      @status = :complete
    end
  end

  def adjacent_locations(location)
    @directions.map do |dir|
      {
        ordinal_x: location.ordinal_x + dir.ordinal_x,
        ordinal_y: location.ordinal_y + dir.ordinal_y
      }
    end.find_all do |loc|
      loc.ordinal_x.between?(0, @grid_size - 1) &&
      loc.ordinal_y.between?(0, @grid_size - 1)
    end
  end

  def path_found?
    !@path.empty?
  end
end

class Game
  attr_gtk

  def initialize
    @grid_size = 16
    @tile_size = 720 / @grid_size

    @walls = []
    @available_spots = @grid_size.flat_map do |ordinal_x|
      @grid_size.map do |ordinal_y|
        new_wall(ordinal_x: ordinal_x, ordinal_y: ordinal_y)
      end
    end

    @mode = :place_walls

    @buttons = [
      Layout.rect(row: 10, col: 14, w: 2, h: 2)
            .merge(mode: :place_walls, text: "place walls", m: :place_wall_clicked),
      Layout.rect(row: 10, col: 16, w: 2, h: 2)
            .merge(mode: :place_start_location, text: "set start location", m: :place_start_location_clicked),
      Layout.rect(row: 10, col: 18, w: 2, h: 2)
            .merge(mode: :place_end_location, text: "set end location", m: :place_end_location_clicked),
      Layout.rect(row: 10, col: 20, w: 2, h: 2)
            .merge(mode: :solving, text: "solve!", m: :solve_clicked),
      Layout.rect(row: 10, col: 22, w: 2, h: 2)
            .merge(mode: :reset, text: "reset!", m: :reset_clicked),
    ]
  end

  def new_wall(ordinal_x:, ordinal_y:)
    Geometry.rect_props(x: ordinal_x * @tile_size, y: ordinal_y * @tile_size, w: @tile_size, h: @tile_size)
            .merge(ordinal_x: ordinal_x, ordinal_y: ordinal_y)
  end

  def editing_disabled?
    return true if @mode == :solving
    return true if @mode == :complete
    return false
  end

  def place_wall_clicked
    return if editing_disabled?
    @mode = :place_walls
  end

  def place_start_location_clicked
    return if editing_disabled?
    @mode = :place_start_location
  end

  def place_end_location_clicked
    return if editing_disabled?
    @mode = :place_end_location
  end

  def solve_clicked
    return if editing_disabled?

    if !@start_location
      GTK.notify "Please set a start location"
      return
    elsif !@end_location
      GTK.notify "Please set an end location"
      return
    end

    @mode = :solving
    @astar ||= AStar.new(start_location: @start_location,
                          end_location: @end_location,
                          walls: @walls,
                          grid_size: @grid_size)

    @astar.start!
  end

  def reset_clicked
    return if @mode == :reset

    if @astar
      @astar = nil
    else
      @walls = []
      @start_location = nil
      @end_location = nil
    end

    @mode = :reset

    GTK.on_tick_count Kernel.tick_count + 15 do
      @mode = :place_walls
    end
  end

  def tick_solve
    return if @mode != :solving

    if inputs.keyboard.key_repeat.j
      @astar.tick
    end

    if @astar.status == :complete
      @mode = :complete
    end
  end

  def tick
    tick_buttons
    tick_place_walls
    tick_place_start_location
    tick_place_end_location
    tick_solve
    render
  end

  def tick_buttons
    return if !inputs.mouse.key_down.left

    button = @buttons.find do |b|
      Geometry.inside_rect?(inputs.mouse.rect, b)
    end

    send button.m if button
  end

  def wall_under_mouse
    @walls.find do |wall|
      Geometry.inside_rect?(inputs.mouse.rect, wall)
    end
  end

  def spot_under_mouse
    @available_spots.find do |spot|
      Geometry.inside_rect?(inputs.mouse.rect, spot)
    end
  end

  def tick_place_start_location
    return if @mode != :place_start_location
    return if !inputs.mouse.key_down.left

    clicked_wall = wall_under_mouse
    clicked_spot = spot_under_mouse

    if clicked_wall
      @walls.delete(clicked_wall)
    elsif @end_location && Geometry.inside_rect?(inputs.mouse.rect, @end_location)
      @end_location = nil
    elsif clicked_spot
      @start_location = { **clicked_spot }
    end
  end

  def tick_place_end_location
    return if @mode != :place_end_location
    return if !inputs.mouse.key_down.left

    clicked_wall = wall_under_mouse
    clicked_spot = spot_under_mouse

    if clicked_wall
      @walls.delete(clicked_wall)
    elsif @start_location && Geometry.inside_rect?(inputs.mouse.rect, @start_location)
      @start_location = nil
    elsif clicked_spot
      @end_location = { **clicked_spot }
    end
  end

  def tick_place_walls
    return if @mode != :place_walls
    return if !inputs.mouse.key_down.left

    clicked_wall = wall_under_mouse
    clicked_spot = spot_under_mouse

    if clicked_wall
      @walls.delete(clicked_wall)
    elsif @start_location && Geometry.inside_rect?(inputs.mouse.rect, @start_location)
      @start_location = nil
    elsif @end_location && Geometry.inside_rect?(inputs.mouse.rect, @end_location)
      @end_location = nil
    elsif clicked_spot
      @walls << { **clicked_spot }
    end
  end

  def mode_label
    text = case @mode
           when :place_walls
             "place walls"
           when :place_start_location
             "set start location"
           when :place_end_location
             "set end location"
           when :solving
             "solving mode (hold the J key)"
           when :complete
             "complete! path found? #{@astar.path_found?}"
           when :reset
             "resetting..."
           else
             "unknown mode #{@mode}"
           end

    Layout.rect(row: [0, 1], col: [14, 23])
          .center
          .merge(text: text, anchor_x: 0.5, anchor_y: 0.5, size_px: 32, r: 255, g: 255, b: 255)
  end

  def button_prefab button
    selection_rect = if button.mode == @mode
                       {
                         **button.center,
                         w: button.w - 8,
                         h: button.h - 8,
                         anchor_x: 0.5,
                         anchor_y: 0.5,
                         path: :solid,
                         r: 0,
                         b: 0,
                         g: 200,
                         a: 128
                       }
                     else
                       nil
                     end

    lines = String.wrapped_lines button.text, 9

    labels = String.line_anchors(lines.length)
                   .map_with_index do |anchor_y, line_index|
                     {
                       **button.center,
                       text: lines[line_index],
                       anchor_x: 0.5,
                       anchor_y: anchor_y
                     }
                   end

    [
      {
        **button,
        path: :solid,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
        primitive_marker: :sprite
      },
      selection_rect,
      labels
    ]
  end

  def cell_prefab(cell:, r:, g:, b:, a: 255, text: nil)
    {
      **cell.center,
      w: cell.w - 4,
      h: cell.h - 4,
      path: :solid,
      r: r,
      g: g,
      b: b,
      a: a,
      anchor_x: 0.5,
      anchor_y: 0.5,
    }
  end

  def render_map
    outputs.primitives << @available_spots.map do |spot|
      cell_prefab(cell: spot, r: 128, g: 128, b: 128, a: 128)
    end

    outputs.primitives << @walls.map do |wall|
      cell_prefab(cell: wall, r: 200, g: 96, b: 96, a: 255,)
    end

  end

  def render_ui
    outputs.primitives << mode_label

    outputs.primitives << @buttons.map do |button|
      button_prefab(button)
    end
  end

  def render_astar
    return if !@astar

    outputs.primitives << @astar.cost.map do |loc, cost|
      rect = Geometry.rect(x: loc.ordinal_x * @tile_size,
                           y: loc.ordinal_y * @tile_size,
                           w: @tile_size,
                           h: @tile_size)
      [
        { **rect.center, w: rect.w - 4, h: rect.h - 4,
          anchor_x: 0.5, anchor_y: 0.5,
          r: 232, g: 232, b: 232, path: :solid },
        { **rect.center, text: "#{cost.to_s}",
          anchor_x: 0.5, anchor_y: 0.5, size_px: 14 },
      ]
    end

    outputs.primitives << @astar.path.map do |loc|
      rect = Geometry.rect(x: loc.ordinal_x * @tile_size,
                           y: loc.ordinal_y * @tile_size,
                           w: @tile_size,
                           h: @tile_size)
      { **rect, r: 200, g: 200, b: 0, a: 128, path: :solid }
    end
  end

  def render
    outputs.background_color = [30, 30, 30]
    render_map
    render_ui
    render_astar
    render_start_and_end_locations
  end

  def render_start_and_end_locations
    if @start_location
      outputs.primitives << cell_prefab(cell: @start_location,
                                        r: 96, g: 96, b: 200, a: 255)
    end

    if @end_location
      outputs.primitives << cell_prefab(cell: @end_location,
                                        r: 96, g: 200, b: 96, a: 255)
    end
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

# GTK.reset

GTK.reset_and_replay "replay.txt", speed: 5
