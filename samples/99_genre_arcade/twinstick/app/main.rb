class Game
  attr_gtk

  def initialize args
    @on_screen_gamepad_left = OnScreenGamepad.new args.inputs, side: :left
    @on_screen_gamepad_right = OnScreenGamepad.new args.inputs, side: :right
    reset_game
  end

  def reset_game
    @player = { x: 600, y: 320, w: 80, h: 80,
                path: 'sprites/circle/solid.png',
                vx: 0,
                vy: 0,
                health: 10,
                health_perc: 1.0,
                cooldown: 0,
                score: 0 }
    @spawn_timer = 120
    @enemies = []
    @bullets = []
  end

  def tick
    @on_screen_gamepad_left.tick
    @on_screen_gamepad_right.tick
    spawn_enemies
    kill_enemies
    move_enemies
    move_bullets
    move_player
    fire_player
    render
    calc_game_over
  end

  def calc_game_over
    if @player.health < 0
      reset_game
    end
  end

  def render
    outputs.background_color = [30, 30, 30]

    outputs.primitives << [@player, @enemies, @bullets]

    progress_bar = Geometry.rect(
      x: @player.x + 40,
      y: @player.y + 80 + 32,
      w: 256,
      h: 32,
      anchor_x: 0.5,
      anchor_y: 0.5,
    ).merge(r: 0, g: 0, b: 0, path: :solid)

    health_area = Geometry.zoom_rect(rect: progress_bar, px: -8)
    current_health = { **health_area, w: health_area.w * @player.health_perc }

    outputs.primitives << progress_bar
    outputs.primitives << health_area.merge(r: 255, g: 255, b: 255, path: :solid)
    outputs.primitives << current_health.merge(r: 80, g: 155, b: 80, path: :solid)

    if DR.platform?(:touch)
      outputs.primitives << { x: 640, y: 720, text: "Finger on left side of screen to move. Finger on right side of screen to shoot.", anchor_x: 0.5, anchor_y: 1.5, r: 255, g: 255, b: 255 }
    elsif inputs.last_active == :keyboard || inputs.last_active == :mouse
      outputs.primitives << { x: 640, y: 720, text: "WASD to move, Arrow Keys to shoot.", anchor_x: 0.5, anchor_y: 1.5, r: 255, g: 255, b: 255 }
    elsif inputs.last_active == :controller
      outputs.primitives << { x: 640, y: 720, text: "Left Analog to move, Right Analog to shoot.", anchor_x: 0.5, anchor_y: 1.5, r: 255, g: 255, b: 255 }
    end

    outputs.primitives << @on_screen_gamepad_left.primitives
    outputs.primitives << @on_screen_gamepad_right.primitives
  end

  def health_progress_bar_primitives

  end

  def spawn_enemies
    should_spawn_enemy ||= Kernel.tick_count == 0
    should_spawn_enemy ||= Kernel.tick_count.zmod?(@spawn_timer.clamp(30, 120))
    return if !should_spawn_enemy

    angle = rand 360
    @enemies << {
      x: 600 + angle.vector_x * 800,
      y: 320 + angle.vector_y * 800,
      w: 80, h: 80, path: "sprites/circle/solid.png",
      r: 128 + rand(128), g: 128 + rand(128), b: 128 + rand(128)
    }
  end

  def kill_enemies
    enemy_collision = Geometry.find_intersect_rect(@player, @enemies)
    if enemy_collision
      @enemies.delete enemy_collision
      @player.health -= 1
    end

    @bullets.each do |bullet|
      bullet_collision = Geometry.find_intersect_rect(bullet, @enemies)
      next if !bullet_collision

      @enemies.delete bullet_collision
      bullet.kills ||= 0
      bullet.kills += 1
      @player.score += bullet.kills
      @spawn_timer -= bullet.kills * 2
      @player.health += 1 if @player.health < 10 && bullet.kills > 1
    end

    @player.health_perc = @player.health_perc.lerp(@player.health.fdiv(10), 0.1)
  end

  def move_enemies
    @enemies.each do |enemy|
      angle = Geometry.angle @player, enemy
      enemy.x -= angle.vector_x * 2.5
      enemy.y -= angle.vector_y * 2.5
    end
  end

  def move_bullets
    @bullets.each do |bullet|
      bullet.x += bullet.vx
      bullet.y += bullet.vy
    end

    @bullets.reject! do |bullet|
      bullet.x < -20 || bullet.y < -20 || bullet.x > 1300 || bullet.y > 740
    end
  end

  def move_player
    @player.vx = @player.vx * 0.9
    @player.vy = @player.vy * 0.9

    @player.x += @player.vx
    @player.y += @player.vy
    @player.x = @player.x.clamp 0, 1200
    @player.y = @player.y.clamp 0, 640

    dir = inputs.keyboard.directional_vector_wasd ||
          inputs.controller_one.directional_vector_left_analog_cardinal ||
          @on_screen_gamepad_left.dpad_vector

    return if !dir

    @player.vx += dir.x * 0.75
    @player.vy += dir.y * 0.75
  end

  def fire_player
    @player.cooldown -= 1

    return if @player.cooldown > 0

    dir = inputs.keyboard.directional_vector_arrow ||
          inputs.controller_one.directional_vector_right_analog_cardinal ||
          @on_screen_gamepad_right.dpad_vector

    return if !dir

    @bullets << {
      x: @player.x + 30 + 40 * dir.x,
      y: @player.y + 30 + 40 * dir.y,
      w: 20, h: 20, path: "sprites/circle/solid.png", r: 232, g: 232, b: 232,
      vx: dir.x * 10 + @player.vx / 7.5, vy: dir.y * 10 + @player.vy / 7.5
    }

    @player.cooldown = 30
  end
end

module Main
  def tick args
    @game ||= Game.new args
    @game.args = args
    @game.tick
  end

  def reset args
    @game = nil
  end
end

# On screen game pad implementation from DragonRuby's sample code
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


GTK.reset
