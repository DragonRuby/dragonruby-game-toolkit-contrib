# https://www.redblobgames.com/pathfinding/a-star/introduction.html
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
       :start_location, :end_location, :walls, :estimated_iterations_to_solve

  def initialize(start_location:, end_location:, walls:, grid_w:, grid_h:)
    @grid_w = grid_w
    @grid_h = grid_h
    @estimated_iterations_to_solve = __estimated_iterations_to_solve__ @grid_w, @grid_h
    @start_location = start_location.slice(:ordinal_x, :ordinal_y)
    @end_location = end_location.slice(:ordinal_x, :ordinal_y)
    @walls = walls.map do |w|
      [w.slice(:ordinal_x, :ordinal_y), true ]
    end.to_h

    @directions = [
      { ordinal_x:  1, ordinal_y:  0 },
      { ordinal_x: -1, ordinal_y:  0 },
      { ordinal_x:  0, ordinal_y:  1 },
      { ordinal_x:  0, ordinal_y: -1 },
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
    if @start_location == @end_location
      @status = :complete
    end
  end

  def solve!
    start!
    tick while !complete?
  end

  def tick
    tick_solve
    tick_generate_path
  end

  def __estimated_iterations_to_solve__ w, h
    total_nodes = w * h
    avg_explored = total_nodes * 0.45  # ~45% of nodes explored on average
    neighbors    = 4                    # 4-directional movement
    (avg_explored * neighbors).round
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
      @path.reverse!
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
      loc.ordinal_x.between?(0, @grid_w - 1) &&
      loc.ordinal_y.between?(0, @grid_h - 1)
    end
  end

  def complete?
    @status == :complete
  end

  def path_found?
    !@path.empty?
  end
end
