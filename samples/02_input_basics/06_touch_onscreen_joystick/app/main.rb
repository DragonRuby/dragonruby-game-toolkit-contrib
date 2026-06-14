class OnScreenGamepad
  attr :inputs, :directional_vector, :directional_angle, :dpad_vector

  def initialize inputs, side: :left
    @side = side
    @inputs = inputs
  end

  def tick
    if finger
      @joystick ||= {
        center: { x: inputs.mouse.x, y: inputs.mouse.y },
        a: 0
      }
      @joystick.distance = Geometry.distance(inputs.mouse, @joystick.center)
      @joystick.angle = Geometry.angle(inputs.mouse, @joystick.center)
      @joystick.vector = @joystick.angle.to_vector
      if @joystick.distance > 160
        @joystick.center.x = @joystick.center.x.lerp(finger.x + @joystick.vector.x * 160, 0.1)
        @joystick.center.y = @joystick.center.y.lerp(finger.y + @joystick.vector.y * 160, 0.1)
      end

      perc = @joystick.distance.clamp(0, 48).fdiv(48)
      @directional_angle = (@joystick.angle + 180) % 360

      @directional_vector = {
        x: @directional_angle.to_vector.x * perc ** 4,
        y: @directional_angle.to_vector.y * perc ** 4,
      }

      if perc > 0.8
        @dpad_vector = {
          x: Geometry.angle_cardinal_vec2(@directional_angle).x,
          y: Geometry.angle_cardinal_vec2(@directional_angle).y,
        }
      else
        @dpad_vector = nil
      end

      @joystick.a = @joystick.a.lerp(128, 0.01)
    elsif @joystick
      @joystick.a = @joystick.a.lerp(0, 0.25)
      @directional_vector = nil
      @dpad_vector = nil
      @joystick = nil if @joystick.a < 1
    end
  end

  def joystick_primitive
    return nil if !@joystick
    {
      **@joystick.center,
      w: 64,
      h: 64,
      path: "sprites/circle/solid.png",
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 255,
      g: 255,
      b: 255,
      a: @joystick.a
    }
  end

  def finger
    if @side == :left
      inputs.finger_left
    else
      inputs.finger_right
    end
  end

  def direction_indicator_primitive
    return nil if !finger
    return nil if !@joystick

    joystick_center = if @joystick.distance > 48
                        { x: @joystick.center.x + 48 * -@joystick.vector.x,
                          y: @joystick.center.y + 48 * -@joystick.vector.y }
                      else
                        finger
                      end

    {
      x: joystick_center.x,
      y: joystick_center.y,
      w: 16,
      h: 16,
      path: "sprites/circle/solid.png",
      r: 255,
      g: 0,
      b: 0,
      a: @joystick.a,
      anchor_x: 0.5,
      anchor_y: 0.5
    }
  end

  def primitives
    [
      joystick_primitive,
      direction_indicator_primitive
    ]
  end
end

class Game
  attr_dr

  def initialize args
    @player = { x: 640 - 16, y: 360 - 16, w: 32, h: 32, path: "sprites/circle/solid.png", r: 0, g: 128, b: 128 }
    @on_screen_gamepad = OnScreenGamepad.new args.inputs
  end

  def tick
    @on_screen_gamepad.tick
    if @on_screen_gamepad.directional_vector
      @player.x += @on_screen_gamepad.directional_vector.x * 4
      @player.y += @on_screen_gamepad.directional_vector.y * 4
    end

    outputs.background_color = [30, 30, 30]
    outputs.primitives << primitives
  end

  def primitives
    [
      @on_screen_gamepad.primitives,
      @player
    ]
  end
end

def self.boot args
  args.state = {}
end

def self.tick args
  $game ||= Game.new args
  $game.args = args
  $game.tick
end

def self.reset args
  $game = nil
end

DR.reset
