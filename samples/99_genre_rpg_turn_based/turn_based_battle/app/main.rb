def tick args
  args.state.phase ||= :selecting_top_level_action
  args.state.potential_action ||= :attack
  args.state.currently_acting_hero_index ||= 0
  args.state.enemies ||= [
    { name: "Goblin A" },
    { name: "Goblin B" },
    { name: "Goblin C" }
  ]

  args.state.heroes ||= [
    { name: "Hero A" },
    { name: "Hero B" },
    { name: "Hero C" }
  ]

  args.state.potential_enemy_index ||= 0

  if args.state.phase == :selecting_top_level_action
    if args.inputs.keyboard.key_down.down
      case args.state.potential_action
      when :attack
        args.state.potential_action = :special
      when :special
        args.state.potential_action = :magic
      when :magic
        args.state.potential_action = :items
      when :items
        args.state.potential_action = :items
      end
    elsif args.inputs.keyboard.key_down.up
      case args.state.potential_action
      when :attack
        args.state.potential_action = :attack
      when :special
        args.state.potential_action = :attack
      when :magic
        args.state.potential_action = :special
      when :items
        args.state.potential_action = :magic
      end
    end

    if args.inputs.keyboard.key_down.enter
      args.state.selected_action = args.state.potential_action
      args.state.next_phase = :selecting_target
    end
  end

  if args.state.phase == :selecting_target
    if args.inputs.keyboard.key_down.left
      select_previous_live_enemy args
    elsif args.inputs.keyboard.key_down.right
      select_next_live_enemy args
    end

    args.state.potential_enemy_index = args.state.potential_enemy_index.clamp(0, args.state.enemies.length - 1)

    if args.inputs.keyboard.key_down.enter
      args.state.enemies[args.state.potential_enemy_index].dead = true
      args.state.potential_enemy_index = args.state.enemies.find_index { |e| !e.dead }
      args.state.selected_action = nil
      args.state.potential_action = :attack
      args.state.next_phase = :selecting_top_level_action
      args.state.currently_acting_hero_index += 1
      if args.state.currently_acting_hero_index >= args.state.heroes.length
        args.state.currently_acting_hero_index = 0
      end
    end
  end

  if args.state.next_phase
    args.state.phase = args.state.next_phase
    args.state.next_phase = nil
  end

  render_actions_menu args
  render_enemies args
  render_heroes args
  render_hero_statuses args
end

def select_next_live_enemy args
  next_target_index = args.state.enemies.find_index.with_index { |e, i| !e.dead && i > args.state.potential_enemy_index }
  if next_target_index
    args.state.potential_enemy_index = next_target_index
  end
end

def select_previous_live_enemy args
  args.state.potential_enemy_index -= 1
  if args.state.potential_enemy_index < 0
    args.state.potential_enemy_index = 0
  elsif args.state.enemies[args.state.potential_enemy_index].dead
    select_previous_live_enemy args
  end
end

def render_actions_menu args
  args.outputs.borders << args.layout.rect(row:  8, col: 0, w: 4, h: 4, include_row_gutter: true, include_col_gutter: true)
  if !args.state.selected_action
    selected_rect = if args.state.potential_action == :attack
                      args.layout.rect(row:  8, col: 0, w: 4, h: 1)
                    elsif args.state.potential_action == :special
                      args.layout.rect(row:  9, col: 0, w: 4, h: 1)
                    elsif args.state.potential_action == :magic
                      args.layout.rect(row: 10, col: 0, w: 4, h: 1)
                    elsif args.state.potential_action == :items
                      args.layout.rect(row: 11, col: 0, w: 4, h: 1)
                    end

    args.outputs.solids  << selected_rect.merge(r: 200, g: 200, b: 200)
  end

  args.outputs.borders << args.layout.rect(row:  8, col: 0, w: 4, h: 1)
  args.outputs.labels  << args.layout.rect(row:  8, col: 0, w: 4, h: 1).center.merge(text: "Attack", vertical_alignment_enum: 1, alignment_enum: 1)

  args.outputs.borders << args.layout.rect(row:  9, col: 0, w: 4, h: 1)
  args.outputs.labels  << args.layout.rect(row:  9, col: 0, w: 4, h: 1).center.merge(text: "Special", vertical_alignment_enum: 1, alignment_enum: 1)

  args.outputs.borders << args.layout.rect(row: 10, col: 0, w: 4, h: 1)
  args.outputs.labels  << args.layout.rect(row: 10, col: 0, w: 4, h: 1).center.merge(text: "Magic", vertical_alignment_enum: 1, alignment_enum: 1)

  args.outputs.borders << args.layout.rect(row: 11, col: 0, w: 4, h: 1)
  args.outputs.labels  << args.layout.rect(row: 11, col: 0, w: 4, h: 1).center.merge(text: "Items", vertical_alignment_enum: 1, alignment_enum: 1)
end

def render_enemies args
  args.outputs.primitives << args.state.enemies.map_with_index do |e, i|
    if e.dead
      nil
    elsif i == args.state.potential_enemy_index && args.state.phase == :selecting_target
      [
        args.layout.rect(row: 1, col: 9 + i * 2, w: 2, h: 2).solid!(r: 200, g: 200, b: 200),
        args.layout.rect(row: 1, col: 9 + i * 2, w: 2, h: 2).border!,
        args.layout.rect(row: 1, col: 9 + i * 2, w: 2, h: 2).center.label!(text: "#{e.name}", vertical_alignment_enum: 1, alignment_enum: 1)
      ]
    else
      [
        args.layout.rect(row: 1, col: 9 + i * 2, w: 2, h: 2).border!,
        args.layout.rect(row: 1, col: 9 + i * 2, w: 2, h: 2).center.label!(text: "#{e.name}", vertical_alignment_enum: 1, alignment_enum: 1)
      ]
    end
  end
end

def render_heroes args
  args.outputs.primitives << args.state.heroes.map_with_index do |h, i|
    if i == args.state.currently_acting_hero_index
      [
        args.layout.rect(row: 5, col: 9 + i * 2, w: 2, h: 2).solid!(r: 200, g: 200, b: 200),
        args.layout.rect(row: 5, col: 9 + i * 2, w: 2, h: 2).border!,
        args.layout.rect(row: 5, col: 9 + i * 2, w: 2, h: 2).center.label!(text: "#{h.name}", vertical_alignment_enum: 1, alignment_enum: 1)
      ]
    else
      [
        args.layout.rect(row: 5, col: 9 + i * 2, w: 2, h: 2).border!,
        args.layout.rect(row: 5, col: 9 + i * 2, w: 2, h: 2).center.label!(text: "#{h.name}", vertical_alignment_enum: 1, alignment_enum: 1)
      ]
    end
  end
end

def render_hero_statuses args
  args.outputs.borders << args.layout.rect(row: 8, col: 4, w: 20, h: 4, include_col_gutter: true, include_row_gutter: true)
end

$gtk.reset
