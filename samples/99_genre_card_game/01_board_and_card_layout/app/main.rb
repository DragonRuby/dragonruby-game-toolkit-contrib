class Game
  attr_gtk

  attr :enemy

  def tick
    defaults
    calc
    render
  end

  def calc
    @enemy.hp_perc ||= @enemy.hp / @enemy.max_hp
    @enemy.hp_perc = @enemy.hp_perc.lerp(@enemy.hp / @enemy.max_hp, 0.2)
    @enemy.dead = @enemy.action == :dying || @enemy.action == :dead
    if inputs.keyboard.key_down.space && !@enemy.dead
      @enemy.hp -= 1
      @enemy.hp = @enemy.hp.clamp(0, @enemy.max_hp)
      if @enemy.hp <= 0
        @enemy.action = :dying
        @enemy.action_at = Kernel.tick_count
      end
    end

    if @enemy.action == :dying && @enemy.action_at.elapsed_time > 30
      @enemy.action = :dead
      @enemy.action_at = Kernel.tick_count
    end
  end

  def defaults
    @enemy ||= {
      id: :hello_world,
      max_hp: 3,
      hp: 3,
      name: "Hello World",
      image: "sprites/square/blue.png",
      action: :idle
    }

    @player ||= {
      hp: 20,
      max_hp: 20,
      draw_pile: [
        {
          id: :whimpy_punch,
          quality: :new,
          name: "Punch",
          desciption: "Punch enemy",
          max_hp: 20,
          hp: 20,
          degrade_description: ""
        }
      ],
      hand: []
    }

    @skip_turn_button_rect ||= Layout.rect(row: 10, col: 20, w: 4, h: 2)
  end

  def render
    outputs.background_color = [0, 0, 0]
    outputs.primitives << draw_pile_prefab
    outputs.primitives << hand_prefab
    outputs.primitives << health_prefab
    outputs.primitives << skip_turn_prefab
    outputs.primitives << enemy_prefab
    outputs.primitives << Layout.rect(row: 6, col: 9, w: 6, h: 2)
                                .center
                                .merge(text: "Press space to attack.",
                                       anchor_x: 0.5,
                                       anchor_y: 0.5,
                                       size_px: 30,
                                       r: 255,
                                       g: 255,
                                       b: 255)
    # outputs.primitives << Layout.debug_primitives(invert_colors: true)
  end

  def progress_bar_prefab rect:, perc:;
    if perc.round(1) > 0
      [
        { x: rect.x, y: rect.y, w: rect.w, h: rect.h, path: :solid },
        { x: rect.x + 4, y: rect.y + 4, w: rect.w * perc - 8, h: rect.h - 8, path: :solid, r: 0, g: 80, b: 0 }
      ]
    else
      [
        { x: rect.x, y: rect.y, w: rect.w, h: rect.h, path: :solid },
      ]
    end
  end

  def enemy_prefab
    layout_config = { safe_area: false, origin: :bottom_left }

    e = @enemy
    return nil if @enemy.action == :dead && @enemy.action_at.elapsed_time > 60

    card_rect  = Layout.rect(w: 0, col: 0, w: 4, h: 6, include_row_gutter: true, include_col_gutter: true, **layout_config)
    name_loc   = Layout.rect(row: 0, col: 0, w: 4, h: 1, **layout_config).center
    image_rect = Layout.rect(row: 2.25, col: 0.25, w: 3.5, h: 3.5, **layout_config)
    hp_rect    = Layout.rect(row: 1, col: 0, w: 4, h: 1, **layout_config)

    outputs[:enemy].w = card_rect.w
    outputs[:enemy].h = card_rect.h
    outputs[:enemy].primitives << card_rect.merge(path: :solid, r: 40, g: 40, b: 40)
    outputs[:enemy].primitives << name_loc.merge(text: @enemy.name, anchor_x: 0.5, anchor_y: 0.5, size_px: 30, r: 255, g: 255, b: 255)
    outputs[:enemy].primitives << image_rect.merge(path: @enemy.image)
    outputs[:enemy].primitives << progress_bar_prefab(rect: hp_rect, perc: @enemy.hp_perc)

    if @enemy.action == :dead
      enemy_a = Easing.smooth_stop(start_at: @enemy.action_at,
                                   duration: 60,
                                   tick_count: Kernel.tick_count,
                                   power: 3,
                                   flip: true) * 255
      enemy_angle = @enemy.action_at.elapsed_time * 10
      enemy_scale = 1 - @enemy.action_at.elapsed_time / 60
    else
      enemy_a = 255
      enemy_angle = 0
      enemy_scale = 1
    end

    Layout.rect(row: 0, col: 10, w: 4, h: 6, include_row_gutter: true, include_col_gutter: true)
          .merge(path: :enemy, a: enemy_a, angle: enemy_angle)
          .scale_rect(enemy_scale, enemy_scale)
  end

  def health_prefab
    progress_bar_prefab rect: Layout.rect(row: 8, col: 20, w: 4, h: 1), perc: @player.hp / @player.max_hp
  end

  def button_prefab rect:, text:;
    [
      rect.merge(path: :solid, r: 255, g: 255, b: 255),
      rect.center.merge(text: text, size_px: 30, r: 0, g: 0, b: 0, anchor_x: 0.5, anchor_y: 0.5)
    ]
  end

  def skip_turn_prefab
    button_prefab rect: @skip_turn_button_rect, text: "Skip Turn"
  end

  def hand_prefab
    [
      Layout.rect(row: 8, col: 4.5, w: 3, h: 4).merge(path: :solid, r: 255, g: 255, b: 255),
      Layout.rect(row: 8, col: 7.5, w: 3, h: 4).merge(path: :solid, r: 255, g: 255, b: 255),
      Layout.rect(row: 8, col: 10.5, w: 3, h: 4).merge(path: :solid, r: 255, g: 255, b: 255),
      Layout.rect(row: 8, col: 13.5, w: 3, h: 4).merge(path: :solid, r: 255, g: 255, b: 255),
      Layout.rect(row: 8, col: 16.5, w: 3, h: 4).merge(path: :solid, r: 255, g: 255, b: 255),
    ]
  end

  def draw_pile_prefab
    [
      Layout.rect(row: 8, col: 0, w: 3, h: 4).merge(path: :solid, r: 255, g: 255, b: 255)
    ]
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

GTK.reset
