class DuelingSpaceships
  attr_gtk

  def tick
    defaults
    render
    calc
    input
  end

  def defaults
    outputs.background_color = [0, 0, 0]
    state.ship_blue       ||= new_blue_ship
    state.ship_red        ||= new_red_ship
    state.flames          ||= []
    state.bullets         ||= []
    state.ship_blue_score ||= 0
    state.ship_red_score  ||= 0
    state.stars           ||= 100.map do
      (rand + 2).yield_self do |size|
        { x: grid.w_half.randomize(:sign, :ratio),
          y: grid.h_half.randomize(:sign, :ratio),
          w: size,
          h: size,
          r: 128 + 128 * rand,
          g: 255,
          b: 255,
          path: :solid }
      end
    end
  end

  def new_ship x:, y:, angle:, path:, bullet_path:, color:;
    { x: x, y: y, w: 66, h: 66,
      dy: 0, dx: 0,
      anchor_x: 0.5, anchor_y: 0.5,
      damage: 0,
      dead: false,
      angle: angle,
      a: 255,
      path: path,
      bullet_sprite_path: bullet_path,
      color: color,
      created_at: Kernel.tick_count,
      last_bullet_at: 0,
      fire_rate: 10 }
  end

  def new_red_ship
    new_ship x: 400,
             y: 250.randomize(:sign, :ratio),
             angle: 180, path: 'sprites/ship_red.png',
             bullet_path: 'sprites/red_bullet.png',
             color: { r: 255, g: 90, b: 90 }
  end

  def new_blue_ship
    new_ship x: -400,
             y: 250.randomize(:sign, :ratio),
             angle: 0,
             path: 'sprites/ship_blue.png',
             bullet_path: 'sprites/blue_bullet.png',
             color: { r: 110, g: 140, b: 255 }
  end

  def render
    render_instructions
    render_score
    render_universe
    render_flames
    render_ships
    render_bullets
  end

  def render_ships
    outputs.primitives << ship_prefab(state.ship_blue)
    outputs.primitives << ship_prefab(state.ship_red)
  end

  def render_instructions
    return if state.ship_blue.dx  > 0  || state.ship_blue.dy > 0  ||
              state.ship_red.dx   > 0  || state.ship_red.dy  > 0  ||
              state.flames.length > 0

    outputs.labels << { x: grid.left.shift_right(30),
                        y: grid.bottom.shift_up(30),
                        text: "Two gamepads needed to play. R1 to accelerate. Left and right on D-PAD to turn ship. Hold A to shoot. Press B to drop mines.",
                        r: 255, g: 255, b: 255 }
  end

  def calc
    calc_flames
    calc_ships
    calc_bullets
    calc_winner
  end

  def input
    input_accelerate
    input_turn
    input_bullets_and_mines
  end

  def render_score
    outputs.labels << { x: grid.left.shift_right(80),
                        y: grid.top.shift_down(40),
                        text: state.ship_blue_score,
                        size_enum: 30,
                        alignment_enum: 1, **state.ship_blue.color }

    outputs.labels << { x: grid.right.shift_left(80),
                        y: grid.top.shift_down(40),
                        text: state.ship_red_score,
                        size_enum: 30,
                        alignment_enum: 1, **state.ship_red.color }
  end

  def render_universe
    args.outputs.background_color = [0, 0, 0]
    outputs.sprites << state.stars
  end

  def apply_round_finished_alpha entity
    return entity unless state.round_finished_at
    entity.merge(a: (entity.a || 0) * state.round_finished_at.ease(2.seconds, :flip))
  end

  def ship_prefab ship
    [
      apply_round_finished_alpha(**ship,
                                 a: ship.dead ? 0 : 255 * ship.created_at.ease(2.seconds)),

      apply_round_finished_alpha(x: ship.x,
                                 y: ship.y + 100,
                                 text: "." * (5 - ship.damage.clamp(0, 5)),
                                 size_enum: 20,
                                 alignment_enum: 1,
                                 **ship.color)
    ]
  end

  def render_flames
    outputs.sprites << state.flames.map do |flame|
      apply_round_finished_alpha(flame.merge(a: 255 * flame.created_at.ease(flame.lifetime, :flip)))
    end
  end

  def render_bullets
    outputs.sprites << state.bullets.map do |b|
      apply_round_finished_alpha(b.merge(a: 255 * b.owner.created_at.ease(2.seconds)))
    end
  end

  def wrap_location! location
    location.merge! x: location.x.clamp_wrap(grid.left, grid.right),
                    y: location.y.clamp_wrap(grid.bottom, grid.top)
  end

  def calc_flames
    state.flames =
      state.flames
           .reject { |p| p.created_at.elapsed_time > p.lifetime }
           .map do |p|
             p.speed *= 0.9
             p.y += p.angle.vector_y(p.speed)
             p.x += p.angle.vector_x(p.speed)
             wrap_location! p
           end
  end

  def all_ships
    [state.ship_blue, state.ship_red]
  end

  def alive_ships
    all_ships.reject { |s| s.dead }
  end

  def calc_bullet bullet
    bullet.y += bullet.angle.vector_y(bullet.speed)
    bullet.x += bullet.angle.vector_x(bullet.speed)
    wrap_location! bullet
    explode_bullet! bullet, particle_count: 5 if bullet.created_at.elapsed_time > bullet.lifetime
    return if bullet.exploded
    return if state.round_finished
    alive_ships.each do |s|
      if s != bullet.owner && s.intersect_rect?(bullet)
        explode_bullet! bullet, particle_count: 10
        s.damage += 1
      end
    end
  end

  def calc_bullets
    state.bullets.each    { |b| calc_bullet b }
    state.bullets.reject! { |b| b.exploded }
  end

  def new_flame x:, y:, angle:, a:, lifetime:, speed:;
    { angle: angle,
      speed: speed,
      lifetime: lifetime,
      path: 'sprites/flame.png',
      x: x,
      y: y,
      w: 6,
      h: 6,
      anchor_x: 0.5,
      anchor_y: 0.5,
      created_at: Kernel.tick_count,
      a: a }
  end

  def create_explosion! source:, particle_count:, max_speed:, lifetime:;
    state.flames.concat(particle_count.map do
                          new_flame x: source.x,
                                    y: source.y,
                                    speed: max_speed * rand,
                                    angle: 360 * rand,
                                    lifetime: lifetime,
                                    a: source.a
                        end)
  end

  def explode_bullet! bullet, particle_count: 5
    bullet.exploded = true
    create_explosion! source: bullet,
                      particle_count: particle_count,
                      max_speed: 5,
                      lifetime: 10
  end

  def calc_ship ship
    ship.x += ship.dx
    ship.y += ship.dy
    wrap_location! ship
  end

  def calc_ships
    all_ships.each { |s| calc_ship s }
    return if all_ships.any? { |s| s.dead }
    return if state.round_finished
    return unless state.ship_blue.intersect_rect?(state.ship_red)
    state.ship_blue.damage = 5
    state.ship_red.damage  = 5
  end

  def create_thruster_flames! ship
    state.flames << new_flame(x: ship.x - ship.angle.vector_x(40) + 5.randomize(:sign, :ratio),
                              y: ship.y - ship.angle.vector_y(40) + 5.randomize(:sign, :ratio),
                              angle: ship.angle + 180 + 60.randomize(:sign, :ratio),
                              speed: 5.randomize(:ratio),
                              a: 255 * ship.created_at.elapsed_time.ease(2.seconds),
                              lifetime: 30)
  end

  def input_accelerate_ship should_move_ship, ship
    return if ship.dead

    should_move_ship &&= (ship.dx + ship.dy).abs < 5

    if should_move_ship
      create_thruster_flames! ship
      ship.dx += ship.angle.vector_x 0.050
      ship.dy += ship.angle.vector_y 0.050
    else
      ship.dx *= 0.99
      ship.dy *= 0.99
    end
  end

  def input_accelerate
    input_accelerate_ship inputs.controller_one.key_held.r1 || inputs.keyboard.up, state.ship_blue
    input_accelerate_ship inputs.controller_two.key_held.r1, state.ship_red
  end

  def input_turn_ship direction, ship
    ship.angle -= 3 * direction
  end

  def input_turn
    input_turn_ship inputs.controller_one.left_right + inputs.keyboard.left_right, state.ship_blue
    input_turn_ship inputs.controller_two.left_right, state.ship_red
  end

  def new_bullet x:, y:, ship:, angle:, speed:, lifetime:;
    { owner: ship,
      angle: angle,
      speed: speed,
      lifetime: lifetime,
      created_at: Kernel.tick_count,
      path: ship.bullet_sprite_path,
      anchor_x: 0.5,
      anchor_y: 0.5,
      w: 10,
      h: 10,
      x: x,
      y: y }
  end

  def input_bullet create_bullet, ship
    return unless create_bullet
    return if ship.dead
    return if ship.last_bullet_at.elapsed_time < ship.fire_rate

    ship.last_bullet_at = Kernel.tick_count

    state.bullets << new_bullet(x: ship.x + ship.angle.vector_x * 32,
                                y: ship.y + ship.angle.vector_y * 32,
                                ship: ship,
                                angle: ship.angle,
                                speed: 5 + ship.dx * ship.angle.vector_x + ship.dy * ship.angle.vector_y,
                                lifetime: 120)
  end

  def input_mine create_mine, ship
    return unless create_mine
    return if ship.dead

    state.bullets << new_bullet(x: ship.x + ship.angle.vector_x * -50,
                                y: ship.y + ship.angle.vector_y * -50,
                                ship: ship,
                                angle: 360.randomize(:sign, :ratio),
                                speed: 0.02,
                                lifetime: 600)
  end

  def input_bullets_and_mines
    return if state.bullets.length > 100

    input_bullet(inputs.controller_one.key_held.a || inputs.keyboard.key_held.space,
                 state.ship_blue)

    input_mine(inputs.controller_one.key_down.b || inputs.keyboard.key_down.down,
               state.ship_blue)

    input_bullet(inputs.controller_two.key_held.a, state.ship_red)

    input_mine(inputs.controller_two.key_down.b, state.ship_red)
  end

  def calc_kill_ships
    alive_ships.find_all { |s| s.damage >= 5 }
               .each do |s|
                 s.dead = true
                 create_explosion! source: s,
                                   particle_count: 20,
                                   max_speed: 20,
                                   lifetime: 30
               end
  end

  def calc_score
    return if state.round_finished
    return if alive_ships.length > 1

    if alive_ships.first == state.ship_red
      state.ship_red_score += 1
    elsif alive_ships.first == state.ship_blue
      state.ship_blue_score += 1
    end

    state.round_finished = true
  end

  def calc_reset_ships
    return unless state.round_finished
    state.round_finished_at ||= Kernel.tick_count
    return if state.round_finished_at.elapsed_time <= 2.seconds
    start_new_round!
  end

  def start_new_round!
    state.ship_blue = new_blue_ship
    state.ship_red  = new_red_ship
    state.round_finished = false
    state.round_finished_at = nil
    state.flames.clear
    state.bullets.clear
  end

  def calc_winner
    calc_kill_ships
    calc_score
    calc_reset_ships
  end
end

$dueling_spaceship = DuelingSpaceships.new

def tick args
  args.grid.origin_center!
  $dueling_spaceship.args = args
  $dueling_spaceship.tick
end
