class Game
  attr_gtk

  def tick
    defaults
    render
    input
    calc
  end

  def defaults
    outputs.background_color = [219, 208, 191]
    player.x        ||= 634
    player.y        ||= 153
    player.angle    ||= 90
    player.distance ||= arena_radius
    target.x        ||= 634
    target.y        ||= 359
  end

  def render
    outputs[:scene].sprites << ([0, 0, 933, 700, 'sprites/arena.png'].center_inside_rect grid.rect)
    outputs[:scene].sprites << target_sprite
    outputs[:scene].sprites << player_sprite
    outputs.sprites << scene
  end

  def target_sprite
    {
      x: target.x, y: target.y,
      w: 10, h: 10,
      path: 'sprites/square/black.png'
    }.anchor_rect 0.5, 0.5
  end

  def input
    if inputs.up && player.distance > 30
      player.distance -= 2
    elsif inputs.down && player.distance < 200
      player.distance += 2
    end

    player.angle += inputs.left_right * -1
  end

  def calc
    player.x = target.x + ((player.angle *  1).vector_x player.distance)
    player.y = target.y + ((player.angle * -1).vector_y player.distance)
  end

  def player_sprite
    {
      x: player.x,
      y: player.y,
      w: 50,
      h: 100,
      path: 'sprites/player.png',
      angle: (player.angle * -1) + 90
    }.anchor_rect 0.5, 0
  end

  def center_map
    { x: 634, y: 359 }
  end

  def zoom_factor_single
    2 - ((args.geometry.distance player, center_map).fdiv arena_radius)
  end

  def zoom_factor
    zoom_factor_single ** 2
  end

  def arena_radius
    206
  end

  def scene
    {
      x:    (640 - player.x) + (640 - (640 * zoom_factor)),
      y:    (360 - player.y - (75 * zoom_factor)) + (320 - (320 * zoom_factor)),
      w:    1280 * zoom_factor,
      h:     720 * zoom_factor,
      path: :scene,
      angle: player.angle - 90,
      angle_anchor_x: (player.x.fdiv 1280),
      angle_anchor_y: (player.y.fdiv 720)
    }
  end

  def player
    state.player
  end

  def target
    state.target
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

$gtk.reset
