class Game
  attr_gtk

  attr :shooting_ball, :launch_angle

  def initialize
    @launch_angle = 90
    @aim_retical = new_ball
    @aim_retical.dx = @launch_angle.vector_x
    @aim_retical.dy = @launch_angle.vector_y
    @current_shot = new_ball
    @balls = []
    @snap_locations = 20.flat_map do |x|
      10.map do |y|
        offset = 32
        offset -= 32 if y.even?
        next if x * 64 + offset + 64 > 1280
        { x: x * 64 + offset, y: 720 - (y * 64), w: 64, h: 64 }
      end
    end.compact
  end

  def new_ball
    { x: 640 - 32, y: 0, w: 64, h: 64, dx: 0, dy: 0, speed: 15 }
  end

  def tick_ball ball
    ball.x += ball.dx * ball.speed

    if ball.x > 1280 - ball.w
      diff = ball.x - (1280 - ball.w)
      ball.dx *= -1
      ball.x = 1280 - ball.w
      ball.x += diff.abs * ball.dx.sign
    elsif ball.x < 0
      diff = ball.x
      ball.dx *= -1
      ball.x = 0
      ball.x += diff.abs * ball.dx.sign
    end

    ball.y += ball.dy * ball.speed
    if ball.y > 720 - ball.h
      ball.dy = 0
      ball.dx = 0
      ball.y = 720 - ball.h
    end
  end

  def find_ball_collision ball
    collision = @balls.find do |b|
      Geometry.intersect_rect?(ball, b) && Geometry.distance(ball, b) < 64
    end

    if collision
      find_snap_location ball
    else
      nil
    end
  end

  def find_snap_location ball
    @snap_locations.find_all do |loc|
      Geometry.intersect_rect?(ball, loc)
    end.sort_by do |loc|
      [Geometry.distance(ball, loc), loc[:y], -loc[:x]]
    end.first
  end

  def find_ceiling_collision ball
    if ball.y + ball.h >= 720
      find_snap_location ball
    else
      nil
    end
  end

  def find_collision ball
    find_ball_collision(ball) || find_ceiling_collision(ball)
  end

  def tick_current_shot
    tick_ball @current_shot
    collision = find_collision @current_shot

    if collision
      @current_shot.dx = 0
      @current_shot.dy = 0
      @current_shot.target_x = collision.x
      @current_shot.target_y = collision.y
      @balls << @current_shot
      @current_shot = new_ball
    end
  end

  def tick_aim_retical
    tick_ball @aim_retical

    collision_aim = find_collision @aim_retical

    if collision_aim
      @aim_retical = new_ball
      @aim_retical.dx = @launch_angle.cos
      @aim_retical.dy = @launch_angle.sin
    end
  end

  def tick
    if inputs.keyboard.key_down.j || inputs.keyboard.key_down.space
      vec = Geometry.angle_vector @launch_angle
      @current_shot.dx = vec.x
      @current_shot.dy = vec.y
    end

    if inputs.keyboard.l || inputs.keyboard.right
      @launch_angle -= 1
    elsif inputs.keyboard.h || inputs.keyboard.left
      @launch_angle += 1
    end

    @launch_angle = @launch_angle.clamp(10, 170)

    tick_current_shot
    tick_aim_retical

    @balls.each do |b|
      b.target_x ||= b.x
      b.target_y ||= b.y
      b.x = b.x.lerp(b.target_x, 0.8, tolerance: 1)
      b.y = b.y.lerp(b.target_y, 0.8, tolerance: 1)
    end

    outputs.sprites << {
      x: 640,
      y: 0,
      w: 128,
      h: 64,
      path: "sprites/square/blue.png",
      angle_anchor_x: 0,
      angle_anchor_y: 0.5,
      angle: @launch_angle
    }

    outputs.sprites << ball_prefab(@aim_retical).merge(a: 50)
    outputs.sprites << ball_prefab(@current_shot)
    outputs.sprites << @balls.map do |b|
      ball_prefab b
    end

    outputs.sprites << @snap_locations.map do |loc|
      {
        **loc,
        path: "sprites/square/white.png",
        a: 50
      }
    end

    trajectory = { x: 640, y: 32, x2: 640 + @launch_angle.cos * 1280, y2: 0 + @launch_angle.sin * 1280 }
    outputs.lines << trajectory
  end

  def ball_prefab ball
    {
      **ball,
      path: "sprites/circle/blue.png"
    }
  end
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
