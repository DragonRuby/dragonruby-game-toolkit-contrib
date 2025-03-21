class Game
  attr_gtk

  def initialize
    @level_scene = LevelScene.new
    @shop_scene = ShopScene.new
  end

  def tick
    defaults
    current_scene.args = args
    current_scene.tick
    if state.next_scene
      state.scene = state.next_scene
      state.scene_at = Kernel.tick_count
      state.next_scene = nil
    end
  end

  def current_scene
    if state.scene == :level
      @level_scene
    elsif state.scene == :shop
      @shop_scene
    end
  end

  def defaults
    state.shield ||= 10
    state.assembly_points ||= 4
    state.scene ||= :level
    state.bullets ||= []
    state.enemies ||= []
    state.bullet_speed ||= 5
    state.turret_position ||= { x: 640, y: 0 }
    state.blaster_spread ||= 1
    state.blaster_rate ||= 60
    state.level ||= 1
    state.bullet_damage ||= 1
    state.enemy_spawn_rate ||= 120
    state.enemy_min_health ||= 1
    state.enemy_health_range ||= 2
    state.enemies_to_spawn ||= 5
    state.enemies_spawned ||= 0
    state.enemy_dy ||= -0.2
  end
end

class ShopScene
  attr_gtk

  def activate
    state.module_selected = nil
    state.available_module_1 = :blaster_spread
    state.available_module_2 = :bullet_damage
    state.available_module_3 = if state.blaster_rate > 3
                                 :blaster_rate
                               else
                                 nil
                               end
  end

  def tick
    if state.scene_at == Kernel.tick_count - 1
      activate
    end

    state.next_wave_button ||= layout.rect(row: 0, col: 20, w: 4, h: 2)
    state.module_1_button  ||= layout.rect(row: 10, col: 0, w: 8, h: 2)
    state.module_2_button  ||= layout.rect(row: 10, col: 8, w: 8, h: 2)
    state.module_3_button  ||= layout.rect(row: 10, col: 16, w: 8, h: 2)

    calc
    render
  end

  def increase_difficulty_and_start_level
    state.next_scene = :level
    state.enemies_spawned = 0
    state.enemies = []
    state.level += 1
    state.enemy_spawn_rate = (state.enemy_spawn_rate * 0.95).to_i
    state.enemy_min_health = (state.enemy_min_health * 1.1).to_i + 1
    state.enemy_health_range = state.enemy_min_health * 2
    state.enemies_to_spawn = (state.enemies_to_spawn * 1.1).to_i + 2
    state.enemy_dy *= 1.05
  end

  def calc
    if state.module_selected
      if inputs.mouse.click && inputs.mouse.click.point.inside_rect?(state.next_wave_button)
        increase_difficulty_and_start_level
      end
    else
      if inputs.mouse.click && inputs.mouse.click.point.inside_rect?(state.module_1_button)
        perform_upgrade state.available_module_1
        state.available_module_1 = nil
        state.module_selected = true
      elsif inputs.mouse.click && inputs.mouse.click.point.inside_rect?(state.module_2_button)
        perform_upgrade state.available_module_2
        state.available_module_2 = nil
        state.module_selected = true
      elsif inputs.mouse.click && inputs.mouse.click.point.inside_rect?(state.module_3_button)
        perform_upgrade state.available_module_3
        state.available_module_3 = nil
        state.module_selected = true
      end
    end
  end

  def perform_upgrade module_name
    return if state.module_selected
    if module_name == :bullet_damage
      state.bullet_damage += 1
    elsif module_name == :blaster_rate
      state.blaster_rate = (state.blaster_rate * 0.85).to_i
      state.blaster_rate = 3 if state.blaster_rate < 3
    elsif module_name == :blaster_spread
      state.blaster_spread += 2
    else
      raise "perform_upgade: Unknown module: #{module_name}"
    end
  end

  def render
    outputs.background_color = [0, 0, 0]
    # outputs.primitives << layout.debug_primitives.map { |p| p.merge a: 80 }

    outputs.labels << layout.rect(row: 0, col: 11, w: 2, h: 1)
                            .center
                            .merge(text: "Select Upgrade", anchor_x: 0.5, anchor_y: 0.5, size_px: 50, r: 255, g: 255, b: 255)

    if state.module_selected
      outputs.primitives << button_prefab(state.next_wave_button, "Next Wave", a: 255)
    end

    a = if state.module_selected
          80
        else
          255
        end

    outputs.primitives << button_prefab(state.module_1_button, state.available_module_1, a: a)
    outputs.primitives << button_prefab(state.module_2_button, state.available_module_2, a: a)
    outputs.primitives << button_prefab(state.module_3_button, state.available_module_3, a: a)
  end

  def button_prefab rect, text, a: 255
    return nil if !text
    [
      rect.merge(path: :solid, r: 255, g: 255, b: 255, a: a),
      Geometry.center(rect).merge(text: text.gsub("_", " "), anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 0, size_px: rect.h.idiv(4))
    ]
  end
end

class LevelScene
  attr_gtk

  def tick
    if inputs.keyboard.key_down.g
      state.enemies_spawned = state.enemies_to_spawn
      state.enemies = []
    elsif inputs.keyboard.key_down.forward_slash
      roll = rand
      if roll < 0.33
        state.bullet_damage += 1
        GTK.notify_extended! message: "bullet damage increased: #{state.bullet_damage}", env: :prod
      elsif roll < 0.66
        if state.blaster_rate > 3
          state.blaster_rate = (state.blaster_rate * 0.85).to_i
          state.blaster_rate = 3 if state.blaster_rate < 3
          GTK.notify_extended! message: "blaster rate upgraded: #{state.blaster_rate}", env: :prod
        else
          GTK.notify_extended! message: "blaster rate already at fastest.", env: :prod
        end
      else
        state.blaster_spread += 2
        GTK.notify_extended! message: "blaster spread increased: #{state.blaster_spread}", env: :prod
      end
    end

    calc
    render
  end

  def calc
    calc_bullets
    calc_enemies
    calc_bullet_hits
    calc_enemy_push_back
    calc_deaths
  end

  def calc_deaths
    state.enemies.reject! { |e| e.hp <= 0 }
    state.bullets.reject! { |b| b.dead_at }
  end

  def enemy_prefab enemy
    b = (enemy.hp / (state.enemy_min_health + state.enemy_health_range)) * 255
    [
      enemy.merge(path: :solid, r: 128, g: 0, b: b),
      Geometry.center(enemy).merge(text: enemy.hp, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255, size_px: enemy.h * 0.5)
    ]
  end

  def render
    outputs.background_color = [0, 0, 0]
    level_completion_perc = (state.enemies_spawned - state.enemies.length).fdiv(state.enemies_to_spawn)
    outputs.primitives << { x: 30, y: 30.from_top, text: "Wave: #{state.level} (#{(level_completion_perc * 100).to_i}% complete)", r: 255, g: 255, b: 255 }
    outputs.primitives << { x: 30, y: 60.from_top, text: "Press G to skip to end of the current wave.", r: 255, g: 255, b: 255 }
    outputs.primitives << { x: 30, y: 90.from_top, text: "Press / to get a random upgrade immediately.", r: 255, g: 255, b: 255 }

    outputs.sprites << state.bullets.map do |b|
      b.merge w: 10, h: 10, path: :solid, r: 0, g: 255, b: 255
    end

    outputs.primitives << state.enemies.map { |e| enemy_prefab e }
  end

  def calc_bullets
    if Kernel.tick_count.zmod? state.blaster_rate
      bullet_count = state.blaster_spread
      min_degrees = state.blaster_spread.idiv(2) * -2
      bullet_count.times do |i|
        degree_offset = min_degrees + (i * 2)
        state.bullets << { x: 640,
                           y: 0,
                           dy: (attack_angle + degree_offset).vector_y * state.bullet_speed,
                           dx: (attack_angle + degree_offset).vector_x * state.bullet_speed }
      end
    end

    state.bullets.each do |b|
      b.x += b.dx
      b.y += b.dy
    end

    state.bullets.reject! { |b| b.y < 0 || b.y > 720 || b.x > 1280 || b.x < 0 }
  end

  def calc_enemies
    if Kernel.tick_count.zmod?(state.enemy_spawn_rate) && state.enemies_spawned < state.enemies_to_spawn
      state.enemies_spawned += 1
      x = rand(1280 - 96) + 48
      y = 720
      hp = state.enemy_min_health + rand(state.enemy_health_range)
      state.enemies << { x: x,
                         y: y,
                         w: 48,
                         h: 48,
                         push_back_x: 0,
                         push_back_y: 0,
                         spawn_at: Kernel.tick_count,
                         dy: state.enemy_dy,
                         start_hp: hp,
                         hp: hp }
    end

    state.enemies.each do |e|
      if e.y + e.h > 720
        e.y -= (((e.y + e.h) - 720) / e.h) * 10
      end

      e.y += e.dy

      if e.x < 0 && e.push_back_x < 0
        e.push_back_x = e.push_back_x.abs
      elsif (e.x + e.w) > 1280 && e.push_back_x > 0
        e.push_back_x = e.push_back_x.abs * -1
      end

      e.x += e.push_back_x
      e.y += e.push_back_y

      e.push_back_x *= 0.9
      e.push_back_y *= 0.9
    end

    state.enemies.reject! { |e| e.y < 0 }

    if state.enemies.empty? && state.enemies_spawned >= state.enemies_to_spawn
      state.next_scene = :shop
      state.bullets.clear
    end
  end

  def calc_bullet_hits
    state.bullets.each do |b|
      state.enemies.each do |e|
        if Geometry.intersect_rect? b.merge(w: 4, h: 4, anchor_x: 0.5, anchor_x: 0.5), e
          e.hp -= state.bullet_damage
          push_back_angle = Geometry.angle b, geometry.center(e)
          push_back_x = push_back_angle.vector_x * state.bullet_damage * 0.1
          push_back_y = push_back_angle.vector_y * state.bullet_damage * 0.1
          e.push_back_x += push_back_x
          e.push_back_y += push_back_y
          e.hit_at = Kernel.tick_count
          b.dead_at = Kernel.tick_count
        end
      end
    end
  end

  def calc_enemy_push_back
    state.enemies.sort_by { |e| -e.y }.each do |e|
      has_pushed_back = false
      other_enemies = Geometry.find_all_intersect_rect e, state.enemies
      other_enemies.each do |e2|
        next if e == e2
        push_back_angle = Geometry.angle geometry.center(e), geometry.center(e2)
        e2.push_back_x += (e.push_back_x).fdiv(other_enemies.length) * 0.7
        e2.push_back_y += (e.push_back_y).fdiv(other_enemies.length) * 0.7
        has_pushed_back = true
      end

      if has_pushed_back
        e.push_back_x *= 0.2
        e.push_back_y *= 0.2
      end
    end
  end

  def attack_angle
    Geometry.angle state.turret_position, inputs.mouse
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset
  $game = nil
end

GTK.reset
