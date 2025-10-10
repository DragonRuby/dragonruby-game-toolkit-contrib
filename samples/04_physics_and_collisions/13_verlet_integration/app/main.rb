# https://www.youtube.com/watch?v=-GWTDhOQU6M
class Square
  attr :x, :y, :w, :h,
       :prev_x, :prev_y,
       :acceleration_x, :acceleration_y,
       :drag_x, :drag_y,
       :radius,
       :dx, :dy, :path, :start_acceleration_x, :start_acceleration_y

  def initialize(x:, y:, w:, h:, radius:, start_acceleration_x:, start_acceleration_y:, drag_x:, drag_y:)
    @x = x
    @y = y
    @w = w
    @h = h
    @radius = radius
    @start_acceleration_x = start_acceleration_x
    @start_acceleration_y = start_acceleration_y
    @acceleration_x = nil
    @acceleration_y = nil
    @drag_x = drag_x
    @drag_y = drag_y
    @path = "sprites/square/blue.png"
  end

  def tick dt
    @prev_x ||= @x
    @prev_y ||= @y
    if !@acceleration_x
      @acceleration_x = @start_acceleration_x
    else
      @acceleration_x = 0
    end

    if !@acceleration_y
      @acceleration_y = @start_acceleration_y
    else
      @acceleration_y = -0.25 * dt
    end

    if @y < 0
      @y = 0
    end

    if @x < 0
      @x = 0
    elsif (@x + @w) > 1280
      @x = 1280 - @w
    end

    dx = @x - @prev_x
    dy = @y - @prev_y
    dx += @acceleration_x * dt
    dy += @acceleration_y * dt
    dx *= @drag_x ** dt
    dy *= @drag_y ** dt

    @prev_x = @x
    @prev_y = @y
    @x += dx
    @y += dy
  end

  def prefab
    {x: @x, y: @y, w: @w, h: @h, path: @path,}
  end

  def center_x
    @x + @radius
  end

  def center_y
    @y + @radius
  end
end

class Game
  attr_gtk

  def initialize
    @squares = []
  end

  def render
    outputs.watch "FPS: #{GTK.current_framerate}"
    outputs.watch "Squares: #{@squares.length}"
    outputs.background_color = [30, 30, 30]
    outputs.primitives << @squares.map(&:prefab)
  end

  def calc_dt dt
    Array.each(@squares) do |object|
      object.tick dt
    end

    Geometry.each_intersect_rect(@squares, @squares) do |o_1, o_2|
      o_1_center_x = o_1.center_x
      o_1_center_y = o_1.center_y
      o_2_center_x = o_2.center_x
      o_2_center_y = o_2.center_y

      distance_x = o_1_center_x - o_2_center_x
      distance_y = o_1_center_y - o_2_center_y
      distance = Math.sqrt(distance_x * distance_x + distance_y * distance_y)

      if distance < o_1.radius + o_2.radius
        v_x = (o_2_center_x - o_1_center_x) / distance
        v_y = (o_2_center_y - o_1_center_y) / distance
        delta = o_1.radius + o_2.radius - distance

        o_1_dx = -0.75 * dt * delta * v_x * 0.5
        o_1_dy = -0.75 * dt * delta * v_y * 0.5
        o_1.x += o_1_dx
        o_1.y += o_1_dy

        o_2_dx = 0.75 * dt * delta * v_x * 0.5
        o_2_dy = 0.75 * dt * delta * v_y * 0.5
        o_2.x += o_2_dx
        o_2.y += o_2_dy
      end
    end
  end

  def calc
    if (inputs.mouse.click || inputs.mouse.held)
      mouse_x = inputs.mouse.x
      mouse_y = inputs.mouse.y

      angle = rand(360)
      acc_x = angle.vector_x * 20
      acc_y = angle.vector_y * 20

      @squares << Square.new(x: mouse_x - 8,
                             y: mouse_y - 8,
                             w: 16,
                             h: 16,
                             radius: 8,
                             start_acceleration_x: acc_x,
                             start_acceleration_y: acc_y,
                             drag_x: 0.95,
                             drag_y: 0.99)
    end

    calc_dt 0.5
    calc_dt 0.5
  end

  def tick
    calc
    render
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def sub_tick args
end

def reset args
  $game = nil
end

GTK.reset
