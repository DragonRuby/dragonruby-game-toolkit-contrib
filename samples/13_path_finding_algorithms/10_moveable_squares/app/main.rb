class Game
  attr_gtk

  def tick
    defaults
    calc
    render
  end

  def defaults
    state.square_size ||= 16
    if !state.world
      state.world = {
        w: 80,
        h: 45,
        player: {
          x: 15,
          y: 15,
          speed: 6
        },
        walls: [
          { x: 16, y: 16 },
          { x: 15, y: 16 },
          { x: 14, y: 17 },
          { x: 14, y: 13 },
          { x: 15, y: 13 },
          { x: 16, y: 13 },
          { x: 17, y: 13 }
        ]
      }
    end
  end

  def calc
    player = world.player
    player.rect = { x: player.x * state.square_size, y: player.y * state.square_size, w: state.square_size, h: state.square_size }
    player.moveable_squares = entity_moveable_squares world.player
    if inputs.keyboard.key_down.plus
      state.world.player.speed += 1
    elsif inputs.keyboard.key_down.minus
      state.world.player.speed -= 1
      state.world.player.speed = 1 if state.world.player.speed < 1
    end

    mouse_ordinal_x = inputs.mouse.x.idiv state.square_size
    mouse_ordinal_y = inputs.mouse.y.idiv state.square_size

    if inputs.mouse.click
      if world.walls.any? { |enemy| enemy.x == mouse_ordinal_x && enemy.y == mouse_ordinal_y }
        world.walls.reject! { |enemy| enemy.x == mouse_ordinal_x && enemy.y == mouse_ordinal_y }
      else
        world.walls << { x: mouse_ordinal_x, y: mouse_ordinal_y, speed: 3 }
      end
    end

    state.hovered_square = world.player.moveable_squares.find do |square|
      mouse_ordinal_x == square.x && mouse_ordinal_y == square.y
    end
  end

  def render
    outputs.primitives << { x: 30, y: 30.from_top, text: "+/- to increase decrease movement radius." }
    outputs.primitives << { x: 30, y: 60.from_top, text: "click to add/remove wall." }
    outputs.primitives << { x: 30, y: 90.from_top, text: "FPS: #{GTK.current_framerate.to_sf}" }
    if Kernel.tick_count <= 1
      outputs[:world_grid].w = 1280
      outputs[:world_grid].h = 720
      outputs[:world_grid].primitives << state.world.w.flat_map do |x|
        state.world.h.map do |y|
          {
            x: x * state.square_size,
            y: y * state.square_size,
            w: state.square_size,
            h: state.square_size,
            r: 0,
            g: 0,
            b: 0,
            a: 128
          }.border!
        end
      end
    end

    outputs[:world_overlay].w = 1280
    outputs[:world_overlay].h = 720

    if state.hovered_square
      outputs[:world_overlay].primitives << path_to_square_prefab(state.hovered_square)
    end

    outputs[:world_overlay].primitives << world.player.moveable_squares.map do |square|
      square_prefab square, { r: 0, g: 0, b: 128, a: 128 }
    end

    outputs[:world_overlay].primitives << world.walls.map do |enemy|
      square_prefab enemy, { r: 128, g: 0, b: 0, a: 200 }
    end

    outputs[:world_overlay].primitives << square_prefab(world.player, { r: 0, g: 128, b: 0, a: 200 })

    outputs[:world].w = 1280
    outputs[:world].h = 720
    outputs[:world].primitives << { x: 0, y: 0, w: 1280, h: 720, path: :world_grid }
    outputs[:world].primitives << { x: 0, y: 0, w: 1280, h: 720, path: :world_overlay }
    outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :world }
  end

  def square_prefab square, color
    {
      x: square.x * state.square_size,
      y: square.y * state.square_size,
      w: state.square_size,
      h: state.square_size,
      **color,
      path: :solid
    }
  end

  def path_to_square_prefab moveable_square
    prefab = []
    color = { r: 0, g: 0, b: 128, a: 80 }
    if moveable_square
      prefab << square_prefab(moveable_square, color)
      prefab << path_to_square_prefab(moveable_square.source)
    end
    prefab
  end

  def world
    state.world
  end

  def entity_moveable_squares entity
    results = {}
    queue = {}
    queue[entity.x] ||= {}
    queue[entity.x][entity.y] = entity
    entity_moveable_squares_recur queue, results while !queue.empty?
    results.flat_map do |x, ys|
      ys.map do |y, value|
        value
      end
    end
  end

  def entity_moveable_squares_recur queue, results
    x, ys = queue.first
    return if !x
    return if !ys
    y, to_process = ys.first
    return if !to_process
    queue[to_process.x].delete y
    queue.delete x if queue[x].empty?
    return if results[to_process.x] && results[to_process.x] && results[to_process.x][to_process.y]

    neighbors = MoveableLocations.neighbors world, to_process
    neighbors.each do |neighbor|
      if !queue[neighbor.x] || !queue[neighbor.x][neighbor.y]
        queue[neighbor.x] ||= {}
        queue[neighbor.x][neighbor.y] = neighbor
      end
    end

    results[to_process.x] ||= {}
    results[to_process.x][to_process.y] = to_process
  end
end

class MoveableLocations
  class << self
    def neighbors world, square
      return [] if !square
      return [] if square.speed <= 0
      north_square = { x: square.x, y: square.y + 1, speed: square.speed - 1, source: square }
      south_square = { x: square.x, y: square.y - 1, speed: square.speed - 1, source: square }
      east_square  = { x: square.x + 1, y: square.y, speed: square.speed - 1, source: square }
      west_square  = { x: square.x - 1, y: square.y, speed: square.speed - 1, source: square }
      north_east_square = { x: square.x + 1, y: square.y + 1, speed: square.speed - 2, source: square }
      north_west_square = { x: square.x - 1, y: square.y + 1, speed: square.speed - 2, source: square }
      south_east_square = { x: square.x + 1, y: square.y - 1, speed: square.speed - 2, source: square }
      south_west_square = { x: square.x - 1, y: square.y - 1, speed: square.speed - 2, source: square }
      result = []
      north_available = valid? world, north_square
      south_available = valid? world, south_square
      east_available  = valid? world, east_square
      west_available  = valid? world, west_square
      north_east_available = valid? world, north_east_square
      north_west_available = valid? world, north_west_square
      south_east_available = valid? world, south_east_square
      south_west_available = valid? world, south_west_square
      result << north_square if north_available
      result << south_square if south_available
      result << east_square  if east_available
      result << west_square  if west_available
      result << north_east_square if north_available && east_available && north_east_available
      result << north_west_square if north_available && west_available && north_west_available
      result << south_east_square if south_available && east_available && south_east_available
      result << south_west_square if south_available && west_available && south_west_available
      result
    end

    def valid? world, square
      return false if !square
      return false if square.speed < 0
      return false if square.x < 0 || square.x >= world.w || square.y < 0 || square.y >= world.h
      return false if world.walls.any? { |enemy| enemy.x == square.x && enemy.y == square.y }
      return false if world.player.x == square.x && world.player.y == square.y
      return true
    end
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

GTK.reset
