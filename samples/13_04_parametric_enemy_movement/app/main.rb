def new_star args
  { x: 1280.randomize(:ratio),
    starting_y: 800,
    distance_to_travel: 900 + 100.randomize(:ratio),
    duration: 100.randomize(:ratio) + 60,
    created_at: args.state.tick_count,
    max_alpha: 128.randomize(:ratio) + 128,
    b: 255.randomize(:ratio),
    g: 200.randomize(:ratio),
    w: 1.randomize(:ratio) + 1,
    h: 1.randomize(:ratio) + 1 }
end

def new_enemy args
  { x: 1280.randomize(:ratio),
    starting_y: 800,
    distance_to_travel: -900,
    duration: 60.randomize(:ratio) + 180,
    created_at: args.state.tick_count,
    w: 32,
    h: 32,
    fire_rate: (30.randomize(:ratio) + (60 - args.state.score)).to_i }
end

def new_bullet args, starting_x, starting_y, enemy_speed
  { x: starting_x,
    starting_y: starting_y,
    distance_to_travel: -900,
    created_at: args.state.tick_count,
    duration: 900 / (enemy_speed.abs + 2.0 + (5.0 * args.state.score.fdiv(100))).abs,
    w: 5,
    h: 5 }
end

def new_player_bullet args, starting_x, starting_y, player_speed
  { x: starting_x,
    starting_y: starting_y,
    distance_to_travel: 900,
    created_at: args.state.tick_count,
    duration: 900 / (player_speed + 2.0),
    w: 5,
    h: 5 }
end

def defaults args
  args.outputs.background_color  = [0, 0, 0]
  args.state.score             ||= 0
  args.state.stars             ||= []
  args.state.enemies           ||= []
  args.state.bullets           ||= []
  args.state.player_bullets    ||= []
  args.state.max_stars           = 50
  args.state.max_enemies         = 10
  args.state.player.x          ||= 640
  args.state.player.y          ||= 100
  args.state.player.w          ||= 32
  args.state.player.h          ||= 32

  if args.state.tick_count == 0
    args.state.stars.clear
    args.state.max_stars.times do
      s = new_star args
      s[:created_at] += s[:duration].randomize(:ratio)
      args.state.stars << s
    end
  end

  if args.state.tick_count == 0
    args.state.enemies.clear
    args.state.max_enemies.times do
      s = new_enemy args
      s[:created_at] += s[:duration].randomize(:ratio)
      args.state.enemies << s
    end
  end
end

def input args
  if args.inputs.keyboard.left
    args.state.player.x -= 5
  elsif args.inputs.keyboard.right
    args.state.player.x += 5
  end

  if args.inputs.keyboard.up
    args.state.player.y += 5
  elsif args.inputs.keyboard.down
    args.state.player.y -= 5
  end

  if args.inputs.keyboard.key_down.space
    args.state.player_bullets << new_player_bullet(args,
                                                   args.state.player.x + args.state.player.w.half,
                                                   args.state.player.y + args.state.player.h, 5)
  end

  args.state.player.y = args.state.player.y.greater(0).lesser(720 - args.state.player.w)
  args.state.player.x = args.state.player.x.greater(0).lesser(1280 - args.state.player.h)
end

def completed? entity
  (entity[:created_at] + entity[:duration]).elapsed_time > 0
end

def calc_stars args
  if (stars_to_add = args.state.max_stars - args.state.stars.length) > 0
    stars_to_add.times { args.state.stars << new_star(args) }
  end
  args.state.stars = args.state.stars.reject { |s| completed? s }
end

def move_enemies args
  if (enemies_to_add = args.state.max_enemies - args.state.enemies.length) > 0
    enemies_to_add.times { args.state.enemies << new_enemy(args) }
  end

  args.state.enemies = args.state.enemies.reject { |s| completed? s }
end

def move_bullets args
  args.state.enemies.each do |e|
    if args.state.tick_count.mod_zero?(e[:fire_rate])
      args.state.bullets << new_bullet(args, e[:x] + e[:w].half, current_y(e), e[:distance_to_travel] / e[:duration])
    end
  end

  args.state.bullets = args.state.bullets.reject { |s| completed? s }
  args.state.player_bullets = args.state.player_bullets.reject { |s| completed? s }
end

def intersect? entity_one, entity_two
  entity_one.merge(y: current_y(entity_one))
            .intersect_rect? entity_two.merge(y: current_y(entity_two))
end

def kill args
  bullets_hitting_enemies = []
  dead_bullets = []
  dead_enemies = []

  args.state.player_bullets.each do |b|
    args.state.enemies.each do |e|
      if intersect? b, e
        dead_bullets << b
        dead_enemies << e
      end
    end
  end

  args.state.score += dead_enemies.length

  args.state.player_bullets.reject! { |b| dead_bullets.include? b }
  args.state.enemies.reject! { |e| dead_enemies.include? e }

  dead = args.state.bullets.any? do |b|
    [args.state.player.x,
     args.state.player.y,
     args.state.player.w,
     args.state.player.h].intersect_rect? b.merge(y: current_y(b))
  end
  return unless dead
  args.gtk.reset
  defaults args
end

def calc args
  calc_stars args
  move_enemies args
  move_bullets args
  kill args
end

def current_y entity
  entity[:starting_y] + (entity[:distance_to_travel] * entity[:created_at].ease(entity[:duration], :identity))
end

def render args
  args.outputs.solids << args.state.stars.map do |s|
    [s[:x],
     current_y(s),
     s[:w], s[:h], 0, s[:g], s[:b], s[:max_alpha] * s[:created_at].ease(20, :identity)]
  end

  args.outputs.borders << args.state.enemies.map do |s|
    [s[:x],
     current_y(s),
     s[:w], s[:h], 255, 0, 0]
  end

  args.outputs.borders << args.state.bullets.map do |b|
    [b[:x],
     current_y(b),
     b[:w], b[:h], 255, 0, 0]
  end

  args.outputs.borders << args.state.player_bullets.map do |b|
    [b[:x],
     current_y(b),
     b[:w], b[:h], 255, 255, 255]
  end

  args.borders << [args.state.player.x,
                   args.state.player.y,
                   args.state.player.w,
                   args.state.player.h, 255, 255, 255]
end

def tick args
  defaults args
  input args
  calc args
  render args
end
