class Game
  attr_gtk

  def tick
    grid.origin_center!
    defaults
    outputs.background_color = [0, 0, 0]
    args.outputs.sprites << state.enemies.map { |e| enemy_prefab e }

    if gtk.platform? :macos
      args.outputs.borders << hmap(x: -150,
                                   y: -220,
                                   w: 300, h: 130, r: 255, g: 255, b: 255)
    end
  end

  def defaults
    state.enemy_sprite_size = 64
    state.row_size = 16
    state.max_rows = 20
    state.enemies ||= 160.map_with_index do |i|
      x = i % 16
      y = i.idiv 16
      hmap row: y, col: x
    end
  end

  def enemy_prefab enemy
    if enemy.row > state.max_rows
      raise "#{enemy}"
    end
    relative_row = enemy.row + 1
    z = 50 - relative_row * 10
    x = (enemy.col * state.enemy_sprite_size) - (state.enemy_sprite_size * state.row_size).idiv(2)
    enemy_sprite(x, enemy.row * 10, z, enemy)
  end

  def enemy_sprite x, y, z, meta
    index = 0.frame_index count: 2, hold_for: 50, repeat: true
    pmap(x: x, y: y, z: z, w: state.enemy_sprite_size, h: state.enemy_sprite_size, path: 'sprites/enemy.png', source_x: 128 * index, source_y: 0, source_w: 128, source_h: 128, meta: meta)
  end

  def pmap opts
    if gtk.platform? :macos
      if opts.z >= 60
        return nil
      elsif (opts.z * 8) > 1000
        return nil
      elsif opts.z <= 60
        scale = (1000 - opts.z * 8).fdiv(1000)
        hscale = 0.5 * scale ** 6
        vscale = scale
        w = (state.enemy_sprite_size * 0.5) * hscale
        h = (state.enemy_sprite_size * 0.5) * hscale

        transform_x = opts.x * 0.5
        x = transform_x * hscale

        y_magnitude = 0.45
        transform_y = opts.y * y_magnitude
        y = (-transform_y * vscale ** 5.5) + 50 * y_magnitude

        return opts.merge! x: x, y: y, w: w, h: h
      else
        raise "#{opts}"
        return nil
      end
    else
      return opts.merge! y: opts.y - 55
    end
  end
end

$game = Game.new

def tick_game args
  $game.args = args
  $game.tick
end

$gtk.reset
