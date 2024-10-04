# https://www.youtube.com/watch?v=D2M8jTtKi44

class Game
  attr_gtk

  def initialize
  end

  def defaults
    state.objects ||= []
  end

  def render
    outputs.watch "#{GTK.current_framerate} FPS"
    outputs.watch "#{state.objects.length}"
    outputs.primitives << state.objects
  end

  def calc_dt dt
    state.objects.each do |object|
      object.prev_x ||= object.x
      object.prev_y ||= object.y
      if !object.acceleration_x
        object.acceleration_x = object.start_acceleration_x
      else
        object.acceleration_x = 0
      end

      if !object.acceleration_y
        object.acceleration_y = object.start_acceleration_y
      else
        object.acceleration_y = -0.25 * dt
      end

      if object.y < 0
        object.y = 0
      end

      if object.x < 0
        object.x = 0
      elsif (object.x + object.w) > 1280
        object.x = 1280 - object.w
      end

      dx = object.x - object.prev_x
      dy = object.y - object.prev_y
      dx += object.acceleration_x * dt
      dy += object.acceleration_y * dt
      dx *= object.drag_x ** dt
      dy *= object.drag_y ** dt

      object.prev_x = object.x
      object.prev_y = object.y
      object.x += dx
      object.y += dy
    end

    Geometry.each_intersect_rect(state.objects, state.objects) do |o_1, o_2|
      o_1_center_x = o_1.x + o_1.radius
      o_1_center_y = o_1.y + o_1.radius
      o_2_center_x = o_2.x + o_2.radius
      o_2_center_y = o_2.y + o_2.radius

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
    if inputs.mouse.held || state.objects.length < 100
      angle = rand(360)
      acc_x = angle.vector_x * 20
      acc_y = angle.vector_y * 20
      mouse_x = if inputs.mouse.click || inputs.mouse.held
                  inputs.mouse.x
                else
                  640
                end

      mouse_y = if inputs.mouse.click || inputs.mouse.held
                  inputs.mouse.y
                else
                  540
                end

      color = [:red, :blue].sample

      state.objects << {
        x: mouse_x - 8,
        y: mouse_y - 8,
        w: 16,
        h: 16,
        radius: 8,
        path: "sprites/square/#{color}.png",
        start_acceleration_x: acc_x,
        start_acceleration_y: acc_y,
        acceleration_x: nil,
        acceleration_y: nil,
        drag_x: 0.95,
        drag_y: 0.99
      }
    end

    calc_dt 0.5
    calc_dt 0.5
  end

  def tick
    defaults
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
