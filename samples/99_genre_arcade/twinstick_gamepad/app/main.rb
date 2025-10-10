class Game
  attr_gtk

  def defaults
    state.player ||= { x: 640,
                       y: 360,
                       w: 80,
                       h: 80,
                       dx: 0,
                       dy: 0,
                       max_speed: 5,
                       anchor_x: 0.5,
                       anchor_y: 0.5,
                       angle: 0 }
    state.bullets ||= []
  end

  def tick
    defaults
    calc
    render
  end

  def calc
    calc_player
    calc_bullets
  end

  def calc_player
    if firing_active?
      player.angle_delta = Geometry.angle_delta player.angle,
                                                fire_angle

      player.angle += player.angle_delta * 0.25

      player.last_fired_at ||= 0

      if player.last_fired_at.elapsed_time > 10
        state.bullets << {
          x: player.x,
          y: player.y,
          w: 10,
          h: 10,
          anchor_x: 0.5,
          anchor_y: 0.5,
          angle: player.angle,
          dx: player.angle.vector_x * 10,
          dy: player.angle.vector_y * 10,
          created_at: Kernel.tick_count
        }

        player.last_fired_at = Kernel.tick_count
      end
    end

    if movement_active?
      angle = movement_angle

      player.dx += angle.vector_x * player.max_speed * 0.1
      player.dx  = player.dx.clamp(-player.max_speed, player.max_speed)
      player.dy += angle.vector_y * player.max_speed * 0.1
      player.dy  = player.dy.clamp(-player.max_speed, player.max_speed)
    end

    player.x  += player.dx
    player.y  += player.dy
    player.dx *= 0.9
    player.dy *= 0.9
  end

  def calc_bullets
    state.bullets.each do |bullet|
      bullet.x += bullet.dx
      bullet.y += bullet.dy
    end

    state.bullets.reject! do |bullet|
      bullet.created_at.elapsed_time > 120
    end
  end

  def render
    outputs.primitives << state.bullets.map do |bullet|
      bullet.merge(path: "sprites/circle/red.png")
    end

    outputs.primitives << player.merge(path: "sprites/circle/blue.png")
  end

  def player
    state.player
  end

  def movement_active?
    inputs.controller_one
          .left_analog_active?(threshold_perc: 0.5) ||
    inputs.keyboard.w_scancode ||
    inputs.keyboard.s_scancode ||
    inputs.keyboard.a_scancode ||
    inputs.keyboard.d_scancode
  end

  def firing_active?
    inputs.controller_one
          .right_analog_active?(threshold_perc: 0.5) ||
    inputs.keyboard.up_arrow   ||
    inputs.keyboard.down_arrow ||
    inputs.keyboard.left_arrow ||
    inputs.keyboard.right_arrow
  end

  def fire_angle
    if inputs.controller_one.right_analog_active?(threshold_perc: 0.5)
      (inputs.controller_one.right_analog_angle + 22).ifloor(45)
    elsif inputs.keyboard.up_arrow && inputs.keyboard.right_arrow
      45
    elsif inputs.keyboard.up_arrow && inputs.keyboard.left_arrow
      135
    elsif inputs.keyboard.down_arrow && inputs.keyboard.left_arrow
      225
    elsif inputs.keyboard.down_arrow && inputs.keyboard.right_arrow
      315
    elsif inputs.keyboard.up_arrow
      90
    elsif inputs.keyboard.down_arrow
      270
    elsif inputs.keyboard.left_arrow
      180
    elsif inputs.keyboard.right_arrow
      0
    end
  end

  def movement_angle
    if inputs.controller_one.left_analog_active?(threshold_perc: 0.5)
      inputs.controller_one.left_analog_angle
    elsif inputs.keyboard.w_scancode && inputs.keyboard.d_scancode
      45
    elsif inputs.keyboard.w_scancode && inputs.keyboard.a_scancode
      135
    elsif inputs.keyboard.s_scancode && inputs.keyboard.a_scancode
      225
    elsif inputs.keyboard.s_scancode && inputs.keyboard.d_scancode
      315
    elsif inputs.keyboard.w_scancode
      90
    elsif inputs.keyboard.s_scancode
      270
    elsif inputs.keyboard.a_scancode
      180
    elsif inputs.keyboard.d_scancode
      0
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
