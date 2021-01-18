def tick args
  args.state.base_columns   ||= 10.times.map { |n| 50 * n + 1280 / 2 - 5 * 50 + 5 }
  args.state.base_rows      ||= 5.times.map { |n| 50 * n + 720 - 5 * 50 }
  args.state.offset_columns = 10.times.map { |n| (n - 4.5) * Math.sin(Kernel.tick_count.to_radians) * 12 }
  args.state.offset_rows    = 5.map { 0 }
  args.state.columns        = 10.times.map { |i| args.state.base_columns[i] + args.state.offset_columns[i] }
  args.state.rows           = 5.times.map { |i| args.state.base_rows[i] + args.state.offset_rows[i] }
  args.state.explosions     ||= []
  args.state.enemies        ||= []
  args.state.score          ||= 0
  args.state.wave           ||= 0
  if args.state.enemies.empty?
    args.state.wave      += 1
    args.state.wave_root = Math.sqrt(args.state.wave)
    args.state.enemies   = make_enemies
  end
  args.state.player         ||= {x: 620, y: 80, w: 40, h: 40, path: 'sprites/circle-gray.png', angle: 90, cooldown: 0, alive: true}
  args.state.enemy_bullets  ||= []
  args.state.player_bullets ||= []
  args.state.lives          ||= 3
  args.state.missed_shots   ||= 0
  args.state.fired_shots    ||= 0

  update_explosions args
  update_enemy_positions args

  if args.inputs.left && args.state.player[:x] > (300 + 5)
    args.state.player[:x] -= 5
  end
  if args.inputs.right && args.state.player[:x] < (1280 - args.state.player[:w] - 300 - 5)
    args.state.player[:x] += 5
  end

  args.state.enemy_bullets.each do |bullet|
    bullet[:x] += bullet[:dx]
    bullet[:y] += bullet[:dy]
  end
  args.state.player_bullets.each do |bullet|
    bullet[:x] += bullet[:dx]
    bullet[:y] += bullet[:dy]
  end

  args.state.enemy_bullets  = args.state.enemy_bullets.find_all { |bullet| bullet[:y].between?(-16, 736) }
  args.state.player_bullets = args.state.player_bullets.find_all do |bullet|
    if bullet[:y].between?(-16, 736)
      true
    else
      args.state.missed_shots += 1
      false
    end
  end

  args.state.enemies = args.state.enemies.reject do |enemy|
    if args.state.player[:alive] && 1500 > (args.state.player[:x] - enemy[:x]) ** 2 + (args.state.player[:y] - enemy[:y]) ** 2
      args.state.explosions << {x: enemy[:x] + 4, y: enemy[:y] + 4, w: 32, h: 32, path: 'sprites/explosion-0.png', age: 0}
      args.state.explosions << {x: args.state.player[:x] + 4, y: args.state.player[:y] + 4, w: 32, h: 32, path: 'sprites/explosion-0.png', age: 0}
      args.state.player[:alive] = false
      true
    else
      false
    end
  end
  args.state.enemy_bullets.each do |bullet|
    if args.state.player[:alive] && 400 > (args.state.player[:x] - bullet[:x] + 12) ** 2 + (args.state.player[:y] - bullet[:y] + 12) ** 2
      args.state.explosions << {x: args.state.player[:x] + 4, y: args.state.player[:y] + 4, w: 32, h: 32, path: 'sprites/explosion-0.png', age: 0}
      args.state.player[:alive] = false
      bullet[:despawn]          = true
    end
  end
  args.state.enemies = args.state.enemies.reject do |enemy|
    args.state.player_bullets.any? do |bullet|
      if 400 > (enemy[:x] - bullet[:x] + 12) ** 2 + (enemy[:y] - bullet[:y] + 12) ** 2
        args.state.explosions << {x: enemy[:x] + 4, y: enemy[:y] + 4, w: 32, h: 32, path: 'sprites/explosion-0.png', age: 0}
        bullet[:despawn] = true
        args.state.score += 1000 * args.state.wave
        true
      else
        false
      end
    end
  end

  args.state.player_bullets = args.state.player_bullets.reject { |bullet| bullet[:despawn] }
  args.state.enemy_bullets  = args.state.enemy_bullets.reject { |bullet| bullet[:despawn] }

  args.state.player[:cooldown] -= 1
  if args.inputs.keyboard.key_held.space && args.state.player[:cooldown] <= 0 && args.state.player[:alive]
    args.state.player_bullets << {x: args.state.player[:x] + 12, y: args.state.player[:y] + 28, w: 16, h: 16, path: 'sprites/star.png', dx: 0, dy: 8}.sprite
    args.state.fired_shots       += 1
    args.state.player[:cooldown] = 10 + 20 / args.state.wave
  end
  args.state.enemies.each do |enemy|
    if Math.rand < 0.0005 + 0.0005 * args.state.wave && args.state.player[:alive] && enemy[:move_state] == :normal
      args.state.enemy_bullets << {x: enemy[:x] + 12, y: enemy[:y] - 8, w: 16, h: 16, path: 'sprites/star.png', dx: 0, dy: -3 - args.state.wave_root}.sprite
    end
  end

  args.outputs.background_color = [0, 0, 0]
  args.outputs.primitives << args.state.enemies.map do |enemy|
    [enemy[:x], enemy[:y], 40, 40, enemy[:path], -90].sprite
  end
  args.outputs.primitives << args.state.player if args.state.player[:alive]
  args.outputs.primitives << args.state.explosions
  args.outputs.primitives << args.state.player_bullets
  args.outputs.primitives << args.state.enemy_bullets
  accuracy = args.state.fired_shots.zero? ? 1 : (args.state.fired_shots - args.state.missed_shots) / args.state.fired_shots
  args.outputs.primitives << [
    [0, 0, 300, 720, 96, 0, 0].solid,
    [1280 - 300, 0, 300, 720, 96, 0, 0].solid,
    [1280 - 290, 60, "Wave     #{args.state.wave}", 255, 255, 255].label,
    [1280 - 290, 40, "Accuracy #{(accuracy * 100).floor}%", 255, 255, 255].label,
    [1280 - 290, 20, "Score    #{(args.state.score * accuracy).floor}", 255, 255, 255].label,
  ]
  args.outputs.primitives << args.state.lives.times.map do |n|
    [1280 - 290 + 50 * n, 80, 40, 40, 'sprites/circle-gray.png', 90].sprite
  end
  #args.outputs.debug << args.gtk.framerate_diagnostics_primitives

  if (!args.state.player[:alive]) && args.state.enemy_bullets.empty? && args.state.explosions.empty? && args.state.enemies.all? { |enemy| enemy[:move_state] == :normal }
    args.state.player[:alive] = true
    args.state.player[:x]     = 624
    args.state.player[:y]     = 80
    args.state.lives          -= 1
    if args.state.lives == -1
      args.state.clear!
    end
  end
end

def make_enemies
  enemies = []
  enemies += 10.times.map { |n| {x: Math.rand * 1280 * 2 - 640, y: Math.rand * 720 * 2 + 720, row: 0, col: n, path: 'sprites/circle-orange.png', move_state: :retreat} }
  enemies += 10.times.map { |n| {x: Math.rand * 1280 * 2 - 640, y: Math.rand * 720 * 2 + 720, row: 1, col: n, path: 'sprites/circle-orange.png', move_state: :retreat} }
  enemies += 8.times.map { |n| {x: Math.rand * 1280 * 2 - 640, y: Math.rand * 720 * 2 + 720, row: 2, col: n + 1, path: 'sprites/circle-blue.png', move_state: :retreat} }
  enemies += 8.times.map { |n| {x: Math.rand * 1280 * 2 - 640, y: Math.rand * 720 * 2 + 720, row: 3, col: n + 1, path: 'sprites/circle-blue.png', move_state: :retreat} }
  enemies += 4.times.map { |n| {x: Math.rand * 1280 * 2 - 640, y: Math.rand * 720 * 2 + 720, row: 4, col: n + 3, path: 'sprites/circle-green.png', move_state: :retreat} }
  enemies
end

def update_explosions args
  args.state.explosions.each do |explosion|
    explosion[:age]  += 0.5
    explosion[:path] = "sprites/explosion-#{explosion[:age].floor}.png"
  end
  args.state.explosions = args.state.explosions.reject { |explosion| explosion[:age] >= 7 }
end

def update_enemy_positions args
  args.state.enemies.each do |enemy|
    if enemy[:move_state] == :normal
      enemy[:x]          = args.state.columns[enemy[:col]]
      enemy[:y]          = args.state.rows[enemy[:row]]
      enemy[:move_state] = :dive if Math.rand < 0.0002 + 0.00005 * args.state.wave && args.state.player[:alive]
    elsif enemy[:move_state] == :dive
      enemy[:target_x] ||= args.state.player[:x]
      enemy[:target_y] ||= args.state.player[:y]
      dx               = enemy[:target_x] - enemy[:x]
      dy               = enemy[:target_y] - enemy[:y]
      vel              = Math.sqrt(dx * dx + dy * dy)
      speed_limit      = 2 + args.state.wave_root
      if vel > speed_limit
        dx /= vel / speed_limit
        dy /= vel / speed_limit
      end
      if vel < 1 || !args.state.player[:alive]
        enemy[:move_state] = :retreat
      end
      enemy[:x] += dx
      enemy[:y] += dy
    elsif enemy[:move_state] == :retreat
      enemy[:target_x] = args.state.columns[enemy[:col]]
      enemy[:target_y] = args.state.rows[enemy[:row]]
      dx               = enemy[:target_x] - enemy[:x]
      dy               = enemy[:target_y] - enemy[:y]
      vel              = Math.sqrt(dx * dx + dy * dy)
      speed_limit      = 2 + args.state.wave_root
      if vel > speed_limit
        dx /= vel / speed_limit
        dy /= vel / speed_limit
      elsif vel < 1
        enemy[:move_state] = :normal
        enemy[:target_x]   = nil
        enemy[:target_y]   = nil
      end
      enemy[:x] += dx
      enemy[:y] += dy
    end
  end
end
