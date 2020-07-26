class DuelingSpaceships
  attr_accessor :state, :inputs, :outputs, :grid

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
      [rand.add(2).to_square(grid.w_half.randomize(:sign, :ratio),
                             grid.h_half.randomize(:sign, :ratio)),
       128 + 128.randomize(:ratio), 255, 255]
    end
  end

  def default_ship x, y, angle, sprite_path, bullet_sprite_path, color
    state.new_entity(:ship,
                    { x: x,
                      y: y,
                      dy: 0,
                      dx: 0,
                      damage: 0,
                      dead: false,
                      angle: angle,
                      max_alpha: 255,
                      sprite_path: sprite_path,
                      bullet_sprite_path: bullet_sprite_path,
                      color: color })
  end

  def new_red_ship
    default_ship(400, 250.randomize(:sign, :ratio),
                 180, 'sprites/ship_red.png', 'sprites/red_bullet.png',
                 [255, 90, 90])
  end

  def new_blue_ship
    default_ship(-400, 250.randomize(:sign, :ratio),
                 0, 'sprites/ship_blue.png', 'sprites/blue_bullet.png',
                 [110, 140, 255])
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
    update_ship_outputs(state.ship_blue)
    update_ship_outputs(state.ship_red)
    outputs.sprites << [state.ship_blue.sprite, state.ship_red.sprite]
    outputs.labels  << [state.ship_blue.label, state.ship_red.label]
  end

  def render_instructions
    return if state.ship_blue.dx  > 0  || state.ship_blue.dy > 0  ||
              state.ship_red.dx   > 0  || state.ship_red.dy  > 0  ||
              state.flames.length > 0

    outputs.labels << [grid.left.shift_right(30),
                       grid.bottom.shift_up(30),
                       "Two gamepads needed to play. R1 to accelerate. Left and right on D-PAD to turn ship. Hold A to shoot. Press B to drop mines.",
                       0, 0, 255, 255, 255]
  end

  def calc
    calc_thrusts
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
    outputs.labels << [grid.left.shift_right(80),
                       grid.top.shift_down(40),
                       state.ship_blue_score, 30, 1, state.ship_blue.color]

    outputs.labels << [grid.right.shift_left(80),
                       grid.top.shift_down(40),
                       state.ship_red_score,  30, 1, state.ship_red.color]
  end

  def render_universe
    return if outputs.static_solids.any?
    outputs.static_solids << grid.rect
    outputs.static_solids << state.stars
  end

  def apply_round_finished_alpha entity
    return entity unless state.round_finished_debounce
    entity.a *= state.round_finished_debounce.percentage_of(2.seconds)
    return entity
  end

  def update_ship_outputs ship, sprite_size = 66
    ship.sprite =
      apply_round_finished_alpha [sprite_size.to_square(ship.x, ship.y),
                                  ship.sprite_path,
                                  ship.angle,
                                  ship.dead ? 0 : 255 * ship.created_at.ease(2.seconds)].sprite
    ship.label =
      apply_round_finished_alpha [ship.x,
                                  ship.y + 100,
                                  "." * 5.minus(ship.damage).greater(0), 20, 1, ship.color, 255].label
  end

  def render_flames sprite_size = 6
    outputs.sprites << state.flames.map do |p|
      apply_round_finished_alpha [sprite_size.to_square(p.x, p.y),
                                  'sprites/flame.png', 0,
                                  p.max_alpha * p.created_at.ease(p.lifetime, :flip)].sprite
    end
  end

  def render_bullets sprite_size = 10
    outputs.sprites << state.bullets.map do |b|
      apply_round_finished_alpha [b.sprite_size.to_square(b.x, b.y),
                                  b.owner.bullet_sprite_path,
                                  0, b.max_alpha].sprite
    end
  end

  def wrap_location! location
    location.x = grid.left    if location.x > grid.right
    location.x = grid.right   if location.x < grid.left
    location.y = grid.top     if location.y < grid.bottom
    location.y = grid.bottom  if location.y > grid.top
    location
  end

  def calc_thrusts
    state.flames =
      state.flames
        .reject(&:old?)
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
    explode_bullet! bullet if bullet.old?
    return if bullet.exploded
    return if state.round_finished
    alive_ships.each do |s|
      if s != bullet.owner &&
         s.sprite.intersect_rect?(bullet.sprite_size.to_square(bullet.x, bullet.y))
        explode_bullet! bullet, 10, 5, 30
        s.damage += 1
      end
    end
  end

  def calc_bullets
    state.bullets.each    { |b| calc_bullet b }
    state.bullets.reject! { |b| b.exploded }
  end

  def create_explosion! type, entity, flame_count, max_speed, lifetime, max_alpha = 255
    flame_count.times do
      state.flames << state.new_entity(type,
                                     { angle: 360.randomize(:ratio),
                                       speed: max_speed.randomize(:ratio),
                                       lifetime: lifetime,
                                       x: entity.x,
                                       y: entity.y,
                                       max_alpha: max_alpha })
    end
  end

  def explode_bullet! bullet, flame_override = 5, max_speed = 5, lifetime = 10
    bullet.exploded = true
    create_explosion! :bullet_explosion,
                      bullet,
                      flame_override,
                      max_speed,
                      lifetime,
                      bullet.max_alpha
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
    return unless state.ship_blue.sprite.intersect_rect?(state.ship_red.sprite)
    state.ship_blue.damage = 5
    state.ship_red.damage  = 5
  end

  def create_thruster_flames! ship
    state.flames << state.new_entity(:ship_thruster,
                                   { angle: ship.angle + 180 + 60.randomize(:sign, :ratio),
                                     speed: 5.randomize(:ratio),
                                     max_alpha: 255 * ship.created_at_elapsed.percentage_of(2.seconds),
                                     lifetime: 30,
                                     x: ship.x - ship.angle.vector_x(40) + 5.randomize(:sign, :ratio),
                                     y: ship.y - ship.angle.vector_y(40) + 5.randomize(:sign, :ratio) })
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

  def input_bullet create_bullet, ship
    return unless create_bullet
    return if ship.dead

    state.bullets << state.new_entity(:ship_bullet,
                                    { owner: ship,
                                      angle: ship.angle,
                                      max_alpha: 255 * ship.created_at_elapsed.percentage_of(2.seconds),
                                      speed: 5 + ship.dx.mult(ship.angle.vector_x) + ship.dy.mult(ship.angle.vector_y),
                                      lifetime: 120,
                                      sprite_size: 10,
                                      x: ship.x + ship.angle.vector_x * 32,
                                      y: ship.y + ship.angle.vector_y * 32 })
  end

  def input_mine create_mine, ship
    return unless create_mine
    return if ship.dead

    state.bullets << state.new_entity(:ship_bullet,
                                    { owner: ship,
                                      angle: 360.randomize(:sign, :ratio),
                                      max_alpha: 255 * ship.created_at_elapsed.percentage_of(2.seconds),
                                      speed: 0.02,
                                      sprite_size: 10,
                                      lifetime: 600,
                                      x: ship.x + ship.angle.vector_x * -50,
                                      y: ship.y + ship.angle.vector_y * -50 })
  end

  def input_bullets_and_mines
    return if state.bullets.length > 100

    [
      [inputs.controller_one.key_held.a || inputs.keyboard.key_held.space,
       inputs.controller_one.key_down.b || inputs.keyboard.key_down.down,
       state.ship_blue],
      [inputs.controller_two.key_held.a, inputs.controller_two.key_down.b, state.ship_red]
    ].each do |a_held, b_down, ship|
      input_bullet(a_held && state.tick_count.mod_zero?(10).or(a_held == 0), ship)
      input_mine(b_down, ship)
    end
  end

  def calc_kill_ships
    alive_ships.find_all { |s| s.damage >= 5 }.each do |s|
      s.dead = true
      create_explosion! :ship_explosion, s, 20, 20, 30, s.max_alpha
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
    state.round_finished_debounce ||= 2.seconds
    state.round_finished_debounce -= 1
    return if state.round_finished_debounce > 0
    start_new_round!
  end

  def start_new_round!
    state.ship_blue = new_blue_ship
    state.ship_red  = new_red_ship
    state.round_finished = false
    state.round_finished_debounce = nil
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
  $dueling_spaceship.inputs  = args.inputs
  $dueling_spaceship.outputs = args.outputs
  $dueling_spaceship.state    = args.state
  $dueling_spaceship.grid    = args.grid
  $dueling_spaceship.tick
end
