def hotspot_top
  [4, 61, 56, 3]
end

def hotspot_bottom
  [4, 0, 56, 3]
end

def hotspot_top_right
  [62, 35, 3, 25]
end

def hotspot_bottom_right
  [62, 0, 3, 25]
end

def storyline_history_include? args, text
  args.state.storyline_history.any? { |s| s.gsub("-", "").gsub(" ", "").include? text.gsub("-", "").gsub(" ", "") }
end

def blinking_light_side_of_home_render args, lowrez_sprites, lowrez_labels, lowrez_solids
  lowrez_sprites << [48, 44, 5, 5, 'sprites/square.png', 0,  50 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [49, 45, 3, 3, 'sprites/square.png', 0, 100 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [50, 46, 1, 1, 'sprites/square.png', 0, 255 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
end

def blinking_light_mountain_pass_render args, lowrez_sprites, lowrez_labels, lowrez_solids
  lowrez_sprites << [18, 47, 5, 5, 'sprites/square.png', 0,  50 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [19, 48, 3, 3, 'sprites/square.png', 0, 100 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [20, 49, 1, 1, 'sprites/square.png', 0, 255 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
end

def blinking_light_path_to_observatory_render args, lowrez_sprites, lowrez_labels, lowrez_solids
  lowrez_sprites << [0, 26, 5, 5, 'sprites/square.png', 0,  50 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [1, 27, 3, 3, 'sprites/square.png', 0, 100 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [2, 28, 1, 1, 'sprites/square.png', 0, 255 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
end

def blinking_light_observatory_render args, lowrez_sprites, lowrez_labels, lowrez_solids
  lowrez_sprites << [23, 59, 5, 5, 'sprites/square.png', 0,  50 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [24, 60, 3, 3, 'sprites/square.png', 0, 100 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [25, 61, 1, 1, 'sprites/square.png', 0, 255 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
end

def blinking_light_inside_observatory_render args, lowrez_sprites, lowrez_labels, lowrez_solids
  lowrez_sprites << [30, 30, 5, 5, 'sprites/square.png', 0,  50 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [31, 31, 3, 3, 'sprites/square.png', 0, 100 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
  lowrez_sprites << [32, 32, 1, 1, 'sprites/square.png', 0, 255 * (args.state.tick_count % 50).fdiv(50), 0, 255, 0]
end

def decision_graph context_message, context_action, context_result_one, context_result_two, context_result_three = [], context_result_four = []
  result_one_scene, result_one_label, result_one_text = context_result_one
  result_two_scene, result_two_label, result_two_text = context_result_two
  result_three_scene, result_three_label, result_three_text = context_result_three
  result_four_scene, result_four_label, result_four_text = context_result_four

  top_level_hash = {
    background: 'sprites/decision.png',
    fade: 60,
    player: [20, 36],
    storylines: [ ],
    scenes: [ ]
  }

  confirmation_result_one_hash = {
    background: 'sprites/decision.png',
    scenes: [ ],
    storylines: [ ]
  }

  confirmation_result_two_hash = {
    background: 'sprites/decision.png',
    scenes: [ ],
    storylines: [ ]
  }

  confirmation_result_three_hash = {
    background: 'sprites/decision.png',
    scenes: [ ],
    storylines: [ ]
  }

  confirmation_result_four_hash = {
    background: 'sprites/decision.png',
    scenes: [ ],
    storylines: [ ]
  }

  top_level_hash[:storylines] << [ 5, 35, 4, 4, context_message]
  top_level_hash[:storylines] << [20, 35, 4, 4, context_action]

  confirmation_result_one_hash[:scenes]       << [20, 35, 4, 4, top_level_hash]
  confirmation_result_one_hash[:scenes]       << [60, 50, 4, 4, result_one_scene]
  confirmation_result_one_hash[:storylines]   << [40, 50, 4, 4, "#{result_one_label}: \"#{result_one_text}\""]
  confirmation_result_one_hash[:scenes]       << [40, 40, 4, 4, confirmation_result_four_hash] if result_four_scene
  confirmation_result_one_hash[:scenes]       << [40, 30, 4, 4, confirmation_result_three_hash] if result_three_scene
  confirmation_result_one_hash[:scenes]       << [40, 20, 4, 4, confirmation_result_two_hash]

  confirmation_result_two_hash[:scenes]       << [20, 35, 4, 4, top_level_hash]
  confirmation_result_two_hash[:scenes]       << [40, 50, 4, 4, confirmation_result_one_hash]
  confirmation_result_two_hash[:scenes]       << [40, 40, 4, 4, confirmation_result_four_hash] if result_four_scene
  confirmation_result_two_hash[:scenes]       << [40, 30, 4, 4, confirmation_result_three_hash] if result_three_scene
  confirmation_result_two_hash[:scenes]       << [60, 20, 4, 4, result_two_scene]
  confirmation_result_two_hash[:storylines]   << [40, 20, 4, 4, "#{result_two_label}: \"#{result_two_text}\""]

  confirmation_result_three_hash[:scenes]     << [20, 35, 4, 4, top_level_hash]
  confirmation_result_three_hash[:scenes]     << [40, 50, 4, 4, confirmation_result_one_hash]
  confirmation_result_three_hash[:scenes]     << [40, 40, 4, 4, confirmation_result_four_hash]
  confirmation_result_three_hash[:scenes]     << [60, 30, 4, 4, result_three_scene]
  confirmation_result_three_hash[:storylines] << [40, 30, 4, 4, "#{result_three_label}: \"#{result_three_text}\""]
  confirmation_result_three_hash[:scenes]     << [40, 20, 4, 4, confirmation_result_two_hash]

  confirmation_result_four_hash[:scenes]      << [20, 35, 4, 4, top_level_hash]
  confirmation_result_four_hash[:scenes]      << [40, 50, 4, 4, confirmation_result_one_hash]
  confirmation_result_four_hash[:scenes]      << [60, 40, 4, 4, result_four_scene]
  confirmation_result_four_hash[:storylines]  << [40, 40, 4, 4, "#{result_four_label}: \"#{result_four_text}\""]
  confirmation_result_four_hash[:scenes]      << [40, 30, 4, 4, confirmation_result_three_hash]
  confirmation_result_four_hash[:scenes]      << [40, 20, 4, 4, confirmation_result_two_hash]

  top_level_hash[:scenes]     << [40, 50, 4, 4, confirmation_result_one_hash]
  top_level_hash[:scenes]     << [40, 40, 4, 4, confirmation_result_four_hash] if result_four_scene
  top_level_hash[:scenes]     << [40, 30, 4, 4, confirmation_result_three_hash] if result_three_scene
  top_level_hash[:scenes]     << [40, 20, 4, 4, confirmation_result_two_hash]

  top_level_hash
end

def ship_control_hotspot offset_x, offset_y, a, b, c, d
  results = []
  results << [ 6 + offset_x, 0 + offset_y, 4, 4, a]  if a
  results << [ 1 + offset_x, 5 + offset_y, 4, 4, b]  if b
  results << [ 6 + offset_x, 5 + offset_y, 4, 4, c]  if c
  results << [ 11 + offset_x, 5 + offset_y, 4, 4, d] if d
  results
end

def reload_current_scene
  if $gtk.args.state.last_hotspot_scene
    set_scene $gtk.args, send($gtk.args.state.last_hotspot_scene, $gtk.args)
    tick $gtk.args
  elsif respond_to? :set_scene
    set_scene $gtk.args, (replied_to_serenity_alive_firmly $gtk.args)
    tick $gtk.args
  end
  $gtk.console.close
end
