class Enemy
  attr :game, :x, :y, :w, :h, :ordinal_x, :ordinal_y, :action, :action_at

  def initialize(game:, x:, y:, w:, h:, ordinal_x:, ordinal_y:)
    @home_x = @x
    @home_y = @y
    @ordinal_x = ordinal_x
    @ordinal_y = ordinal_y
    @home_ordinal_x = @ordinal_x
    @home_ordinal_y = @ordinal_y
    @game = game
    @x = x
    @y = y
    @w = w
    @h = h
    @action = :idle
    @action_at = Kernel.tick_count
  end

  def tick
    case @action
    when :move_to_player
      tick_action_move_to_player
    when :finding_player
      tick_action_finding_player
    when :moving_to_player
      tick_action_moving_to_player
    when :move_to_home
      tick_action_move_to_home
    when :finding_home
      tick_action_finding_home
    when :moving_to_home
      tick_action_moving_to_home
    end
  end

  def primitives
    [
      {
        x: @x,
        y: @y,
        w: @w,
        h: @h,
        path: :solid,
        r: 255,
        g: 128,
        b: 128
      },
      Geometry.zoom_rect(rect: { x: @x, y: @y, w: @w, h: @h },
                         px: -4)
              .merge(path: :solid, r: 0, g: 0, b: 0, a: 128),
      {
        x: @x + @w / 2,
        y: @y + @h / 2,
        text: "#{@action}",
        anchor_x: 0.5,
        anchor_y: 0.5 - 0.5,
        r: 200,
        g: 200,
        b: 200,
        size_px: 12,
      },
      {
        x: @x + @w / 2,
        y: @y + @h / 2,
        text: "(#{@ordinal_x},#{@ordinal_y})",
        anchor_x: 0.5,
        anchor_y: 0.5 + 0.5,
        r: 200,
        g: 200,
        b: 200,
        size_px: 12,
      }
    ]
  end

  def action!(value)
    return if @action == value
    @action = value
    @action_at = @game.args.tick_count
  end

  def move_to_player!
    action!(:move_to_player)
  end

  def move_to_home!
    action!(:move_to_home)
  end

  def tick_action_move_to_home
    home_location = { ordinal_x: @ordinal_x, ordinal_y: @ordinal_y }
    end_location = { ordinal_x: @home_ordinal_x, ordinal_y: @home_ordinal_y }
    walls = @game.walls.map { |w| { ordinal_x: w.ordinal_x, ordinal_y: w.ordinal_y } }
    grid_w = 32
    grid_h = 18

    @astar = AStar.new(start_location: home_location,
                       end_location: end_location,
                       walls: walls,
                       grid_w: grid_w,
                       grid_h: grid_h)

    action!(:finding_home)

    @astar.start!
  end

  def tick_action_finding_home
    @astar.estimated_iterations_to_solve
          .fdiv(60)
          .ceil
          .times do
      if !@astar.complete?
        @astar.tick
      end
    end

    if @astar.complete?
      if @astar.path_found?
        @move_queue = @astar.path.dup
        action!(:moving_to_home)
      else
        action!(:idle)
      end
    end
  end

  def __move__ x, y
    @x = x
    @y = y
    @ordinal_x = @x.idiv(40)
    @ordinal_y = @y.idiv(40)
  end

  def tick_action_moving_to_home
    current_target = @move_queue.first
    current_target_rect = { x: current_target.ordinal_x * 40,
                            y: current_target.ordinal_y * 40,
                            w: 40,
                            h: 40 }
    angle = Geometry.angle(self, current_target_rect)
    distance = Geometry.distance(self, current_target_rect)
    speed = 4
    __move__(@x + angle.to_vector.x * speed, @y + angle.to_vector.y * speed)
    if distance <= speed
      @move_queue.pop_front
    end

    if @move_queue.empty?
      __move__(current_target.ordinal_x * 40, current_target.ordinal_y * 40)
      action!(:idle)
    end
  end

  def tick_action_move_to_player
    home_location = { ordinal_x: @ordinal_x, ordinal_y: @ordinal_y }
    end_location = { ordinal_x: @game.player.ordinal_x, ordinal_y: @game.player.ordinal_y }
    walls = @game.walls.map { |w| { ordinal_x: w.ordinal_x, ordinal_y: w.ordinal_y } }
    grid_w = 32
    grid_h = 18

    @astar = AStar.new(start_location: home_location,
                       end_location: end_location,
                       walls: walls,
                       grid_w: grid_w,
                       grid_h: grid_h)

    action!(:finding_player)

    @astar.start!
  end

  def tick_action_finding_player
    @astar.estimated_iterations_to_solve
          .fdiv(60)
          .ceil
          .times do
      if !@astar.complete?
        @astar.tick
      end
    end

    if @astar.complete?
      if @astar.path_found?
        @move_queue = @astar.path.dup
        action!(:moving_to_player)
      else
        action!(:idle)
      end
    end
  end

  def tick_action_moving_to_player
    current_target = @move_queue.first
    current_target_rect = { x: current_target.ordinal_x * 40,
                            y: current_target.ordinal_y * 40,
                            w: 40,
                            h: 40 }
    angle = Geometry.angle(self, current_target_rect)
    distance = Geometry.distance(self, current_target_rect)
    speed = 4
    __move__(@x + angle.to_vector.x * speed, @y + angle.to_vector.y * speed)

    if distance <= speed
      @move_queue.pop_front
    end

    if @move_queue.empty?
      __move__(current_target.ordinal_x * 40, current_target.ordinal_y * 40)
      action!(:idle)
    end
  end
end
