class Game
  attr_dr

  def initialize
    # generate available spaces that the player can move through
    @cells = 32.flat_map do |x_ordinal|
      18.map do |y_ordinal|
        {
          **Geometry.rect(x: x_ordinal * 40, y: y_ordinal * 40, w: 40, h: 40),
          x_ordinal: x_ordinal,
          y_ordinal: y_ordinal,
        }
      end
    end

    # track which spaces have walls in them
    @walls = []

    # player's position, size, and movement direction
    @player = {
      x: 20,
      y: 20,
      w: 40,
      h: 40,
      dx: 1,
      dy: 0,
      anchor_x: 0.5,
      anchor_y: 0.5,
      path: :solid,
      r: 128, g: 255, b: 128,
    }
  end

  def tick
    # toggle walls on mouse click
    if inputs.mouse.key_up.left
      cell = Geometry.find_intersect_rect(inputs.mouse, @cells)
      if cell
        if @walls.include?(cell)
          @walls.delete(cell)
        else
          @walls << cell
        end
      end
    end

    # move player based on arrow key input, but only if the player won't collide with a wall
    if inputs.up_down != 0
      # first check cells to see if the player is grid aligned
      collisions = Geometry.find_all_intersect_rect(
        { **@player, y: @player.y + inputs.up_down },
        @cells,
        tolerance: 0
      )

      # if the player is intersecting with exactly 2 cells, then they are grid aligned and we can check for wall collisions
      if collisions.length == 2
        # if neither of the cells the player is intersecting with have walls, then we can move the player
        if collisions.none? { |collision| @walls.include?(collision) }
          # update the player's movement direction based on the input
          @player.dy = inputs.up_down
          @player.dx = 0
        end
      end
    elsif inputs.left_right != 0
      collisions = Geometry.find_all_intersect_rect(
        { **@player, x: @player.x + inputs.left_right },
        @cells,
        tolerance: 0
      )

      if collisions.length == 2
        if collisions.none? { |collision| @walls.include?(collision) }
          @player.dy = 0
          @player.dx = inputs.left_right
        end
      end
    end

    # move the player based on their movement direction, but only if they won't collide with a wall
    @player.x += @player.dx * 2
    if Geometry.find_intersect_rect(@player, @walls)
      @player.x -= @player.dx * 2
    end
    @player.y += @player.dy * 2
    if Geometry.find_intersect_rect(@player, @walls)
      @player.y -= @player.dy * 2
    end

    # render the game
    outputs.background_color = [30, 30, 30]
    outputs.primitives << @cells.map do |cell|
      {
        **Geometry.zoom_rect(rect: cell, px: -1),
        path: :solid, r: 0, g: 0, b: 0, a: 128
      }
    end
    outputs.primitives << @walls.map do |cell|
      {
        **Geometry.zoom_rect(rect: cell, px: -1),
        path: :solid, r: 255, g: 255, b: 255, a: 128
      }
    end
    outputs.primitives << @player
    outputs.primitives << {
      x: 640, y: 360, text: "Click to add/remove walls. Use arrow keys to move.",
      anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255
    }
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

GTK.reset
