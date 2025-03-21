class Game
  attr_gtk

  def tick
    outputs.labels << { x: 30, y: 30.from_top,
                        text: "left/right arrow keys to spin, up arrow to jump, ctrl+r to reset, click two points to place terrain" }
    defaults
    calc
    render
  end

  def defaults
    state.terrain ||= []

    state.player ||= { x: 100,
                       y: 640,
                       dx: 0,
                       dy: 0,
                       radius: 12,
                       drag: 0.05477,
                       gravity: 0.03,
                       entropy: 0.9,
                       angle: 0,
                       facing: 1,
                       angle_velocity: 0,
                       elasticity: 0.5 }

    state.grid_points ||= (1280.idiv(40) + 1).flat_map do |x|
      (720.idiv(40) + 1).map do |y|
        { x: x * 40,
          y: y * 40,
          w: 40,
          h: 40,
          anchor_x: 0.5,
          anchor_y: 0.5 }
      end
    end
  end

  def calc
    player.y = 720  if player.y < 0
    player.x = 1280 if player.x < 0
    player.x = 0    if player.x > 1280
    player.angle_velocity = player.angle_velocity.clamp(-30, 30)
    calc_edit_mode
    calc_play_mode
  end

  def calc_edit_mode
    state.current_grid_point = Geometry.find_intersect_rect(inputs.mouse, state.grid_points)
    calc_edit_mode_click
  end

  def calc_edit_mode_click
    return if !state.current_grid_point
    return if !inputs.mouse.click

    if !state.start_point
      state.start_point = state.current_grid_point
    else
      state.terrain << { x: state.start_point.x,
                         y: state.start_point.y,
                         x2: state.current_grid_point.x,
                         y2: state.current_grid_point.y }
      state.start_point = nil
    end
  end

  def calc_play_mode
    player.x += player.dx
    player.dy -= player.gravity
    player.y += player.dy
    player.angle += player.angle_velocity
    player.dy += player.dy * player.drag ** 2 * -1
    player.dx += player.dx * player.drag ** 2 * -1
    player.colliding = false
    player.colliding_with = nil

    if inputs.keyboard.key_down.up
      player.dy += 5 * player.angle.vector_y
      player.dx += 5 * player.angle.vector_x
    end
    player.angle_velocity += inputs.left_right * -1
    player.facing = if inputs.left_right == -1
                      -1
                    elsif inputs.left_right == 1
                      1
                    else
                      player.facing
                    end

    collisions = player_terrain_collisions
    collisions.each do |collision|
      collide! player, collision
    end

    if player.colliding_with
      roll! player, player.colliding_with
    end
  end

  def reflect_velocity! circle, line
    slope = Geometry.line_slope line, replace_infinity: 1000
    slope_angle = Geometry.line_angle line
    if slope_angle == 90 || slope_angle == 270
      circle.dx *= -circle.elasticity
    else
      circle.angle_velocity += slope * (circle.dx.abs + circle.dy.abs)
      vec = line.x2 - line.x, line.y2 - line.y
      len = Math.sqrt(vec.x**2 + vec.y**2)

      vec.x /= len
      vec.y /= len

      n = Geometry.vec2_normal vec

      v_dot_n = Geometry.vec2_dot_product({ x: circle.dx, y: circle.dy }, n)

      circle.dx = circle.dx - n.x * (2 * v_dot_n)
      circle.dy = circle.dy - n.y * (2 * v_dot_n)
      circle.dx *= circle.elasticity
      circle.dy *= circle.elasticity
      half_terminal_velocity = 10
      impact_intensity = (circle.dy.abs) / half_terminal_velocity
      impact_intensity = 1 if impact_intensity > 1

      final = (0.9 - 0.8 * impact_intensity)
      next_angular_velocity = circle.angle_velocity * final
      circle.angle_velocity *= final

      if (circle.dx.abs + circle.dy.abs) <= 0.2
        circle.dx = 0
        circle.dy = 0
        circle.angle_velocity *= 0.99
      end

      if circle.angle_velocity.abs <= 0.1
        circle.angle_velocity = 0
      end
    end
  end

  def position_on_line! circle, line
    circle.colliding = true
    point = Geometry.line_normal line, circle
    if point.y > circle.y
      circle.colliding_from_above = true
    else
      circle.colliding_from_above = false
    end

    circle.colliding_with = line

    if !Geometry.point_on_line? point, line
      distance_from_start_of_line = Geometry.distance_squared({ x: line.x, y: line.y }, point)
      distance_from_end_of_line = Geometry.distance_squared({ x: line.x2, y: line.y2 }, point)
      if distance_from_start_of_line < distance_from_end_of_line
        point = { x: line.x, y: line.y }
      else
        point = { x: line.x2, y: line.y2 }
      end
    end
    angle = Geometry.angle_to point, circle
    circle.y = point.y + angle.vector_y * (circle.radius)
    circle.x = point.x + angle.vector_x * (circle.radius)
  end

  def collide! circle, line
    return if !line
    position_on_line! circle, line
    reflect_velocity! circle, line
    next_player = { x: player.x + player.dx,
                    y: player.y + player.dy,
                    radius: player.radius }
  end

  def roll! circle, line
    slope_angle = Geometry.line_angle line
    return if slope_angle == 90 || slope_angle == 270

    ax = -circle.gravity * slope_angle.vector_y
    ay = -circle.gravity * slope_angle.vector_x

    if ax.abs < 0.05 && ay.abs < 0.05
      ax = 0
      ay = 0
    end

    friction_coefficient = 0.0001
    friction_force = friction_coefficient * circle.gravity * slope_angle.vector_x

    circle.dy += ay
    circle.dx += ax

    if circle.colliding_from_above
      circle.dx += circle.angle_velocity * slope_angle.vector_x * 0.1
      circle.dy += circle.angle_velocity * slope_angle.vector_y * 0.1
    else
      circle.dx += circle.angle_velocity * slope_angle.vector_x * -0.1
      circle.dy += circle.angle_velocity * slope_angle.vector_y * -0.1
    end

    if circle.dx != 0
      circle.dx -= friction_force * (circle.dx / circle.dx.abs)
    end

    if circle.dy != 0
      circle.dy -= friction_force * (circle.dy / circle.dy.abs)
    end
  end

  def player_terrain_collisions
    terrain.find_all do |terrain|
             Geometry.circle_intersect_line? player, terrain
           end
           .sort_by do |terrain|
             if player.facing == -1
               -terrain.x
             else
               terrain.x
             end
           end
  end

  def render
    render_current_grid_point
    render_preview_line
    render_grid_points
    render_terrain
    render_player
    render_player_terrain_collisions
  end

  def render_player_terrain_collisions
    collisions = player_terrain_collisions
    outputs.lines << collisions.map do |collision|
                       { x: collision.x,
                         y: collision.y,
                         x2: collision.x2,
                         y2: collision.y2,
                         r: 255,
                         g: 0,
                         b: 0 }
                     end
  end

  def render_current_grid_point
    return if state.game_mode == :play
    return if !state.current_grid_point
    outputs.sprites << state.current_grid_point
                            .merge(w: 8,
                                   h: 8,
                                   anchor_x: 0.5,
                                   anchor_y: 0.5,
                                   path: :solid,
                                   g: 0,
                                   r: 0,
                                   b: 0,
                                   a: 128)
  end

  def render_preview_line
    return if state.game_mode == :play
    return if !state.start_point
    return if !state.current_grid_point

    outputs.lines << { x: state.start_point.x,
                       y: state.start_point.y,
                       x2: state.current_grid_point.x,
                       y2: state.current_grid_point.y }
  end

  def render_grid_points
    outputs
      .sprites << state
                    .grid_points
                    .map do |point|
      point.merge w: 8,
                  h: 8,
                  anchor_x: 0.5,
                  anchor_y: 0.5,
                  path: :solid,
                  g: 255,
                  r: 255,
                  b: 255,
                  a: 128
    end
  end

  def render_terrain
    outputs.lines << state.terrain
  end

  def render_player
    outputs.sprites << player_prefab
  end

  def player_prefab
    flip_horizontally = player.facing == -1
    { x: player.x,
      y: player.y,
      w: player.radius * 2,
      h: player.radius * 2,
      angle: player.angle,
      anchor_x: 0.5,
      anchor_y: 0.5,
      path: "sprites/circle/blue.png" }
  end

  def player
    state.player
  end

  def terrain
    state.terrain
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $terrain = args.state.terrain
  $game = nil
end
