class Game
  attr_gtk

  def tick
    grid.origin_center!
    defaults
    state.angle_shift_x ||= 180
    state.angle_shift_y ||= 180

    if inputs.controller_one.right_analog_y_perc.round(2) != 0.00
      args.state.star_distance += (inputs.controller_one.right_analog_y_perc * 0.25) ** 2 * inputs.controller_one.right_analog_y_perc.sign
      state.star_distance = state.star_distance.clamp(state.min_star_distance, state.max_star_distance)
      state.star_sprites = calc_star_primitives
    elsif inputs.controller_one.down
      args.state.star_distance += (1.0 * 0.25) ** 2
      state.star_distance = state.star_distance.clamp(state.min_star_distance, state.max_star_distance)
      state.star_sprites = calc_star_primitives
    elsif inputs.controller_one.up
      args.state.star_distance -= (1.0 * 0.25) ** 2
      state.star_distance = state.star_distance.clamp(state.min_star_distance, state.max_star_distance)
      state.star_sprites = calc_star_primitives
    end

    render
  end

  def calc_star_primitives
    args.state.stars.map do |s|
      w = (32 * state.star_distance).clamp(1, 32)
      h = (32 * state.star_distance).clamp(1, 32)
      x = (state.max.x * state.star_distance) * s.xr
      y = (state.max.y * state.star_distance) * s.yr
      z = state.center.z + (state.max.z * state.star_distance * 10 * s.zr)

      angle_x = Math.atan2(z - 600, y).to_degrees + 90
      angle_y = Math.atan2(z - 600, x).to_degrees + 90

      draw_x = x - w.half
      draw_y = y - 40 - h.half
      draw_z = z

      { x: draw_x,
        y: draw_y,
        z: draw_z,
        b: 255,
        w: w,
        h: h,
        angle_x: angle_x,
        angle_y: angle_y,
        path: 'sprites/star.png' }
    end
  end

  def render
    outputs.background_color = [0, 0, 0]
    if state.star_distance <= 1.0
      text_alpha = (1 - state.star_distance) * 255
      args.outputs.labels << { x: 0, y: 50, text: "Let there be light.", r: 255, g: 255, b: 255, size_enum: 1, alignment_enum: 1, a: text_alpha }
      args.outputs.labels << { x: 0, y: 25, text: "(right analog: up/down)", r: 255, g: 255, b: 255, size_enum: -2, alignment_enum: 1, a: text_alpha }
    end

    args.outputs.sprites << state.star_sprites
  end

  def random_point
    r = { xr: 2.randomize(:ratio) - 1,
          yr: 2.randomize(:ratio) - 1,
          zr: 2.randomize(:ratio) - 1 }
    if (r.xr ** 2 + r.yr ** 2 + r.zr ** 2) > 1.0
      return random_point
    else
      return r
    end
  end

  def defaults
    state.max_star_distance ||= 100
    state.min_star_distance ||= 0.001
    state.star_distance     ||= 0.001
    state.star_angle        ||= 0

    state.center.x       ||= 0
    state.center.y       ||= 0
    state.center.z       ||= 30
    state.max.x          ||= 640
    state.max.y          ||= 640
    state.max.z          ||= 50

    state.stars ||= 1500.map do
      random_point
    end

    state.star_sprites ||= calc_star_primitives
  end
end

$game = Game.new

def tick_game args
  $game.args = args
  $game.tick
end

GTK.reset
