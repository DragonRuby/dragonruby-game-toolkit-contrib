require 'app/require.rb'

def defaults args
  args.outputs.background_color = [0, 0, 0]
  args.state.last_story_line_text ||= ""
  args.state.scene_history ||= []
  args.state.storyline_history ||= []
  args.state.word_delay ||= 8
  if args.state.tick_count == 0
    args.gtk.stop_music
    args.outputs.sounds << 'sounds/static-loop.ogg'
  end

  if args.state.last_story_line_text
    lines = args.state
                .last_story_line_text
                .gsub("-", "")
                .gsub("~", "")
                .wrapped_lines(50)

    args.outputs.labels << lines.map_with_index { |l, i| [690, 200 - (i * 25), l, 1, 0, 255, 255, 255] }
  elsif args.state.storyline_history[-1]
    lines = args.state
                .storyline_history[-1]
                .gsub("-", "")
                .gsub("~", "")
                .wrapped_lines(50)

    args.outputs.labels << lines.map_with_index { |l, i| [690, 200 - (i * 25), l, 1, 0, 255, 255, 255] }
  end

  return if args.state.current_scene
  set_scene(args, day_one_beginning(args))
end

def inputs_move_player args
  if args.state.scene_changed_at.elapsed_time > 5
    if args.keyboard.down  || args.keyboard.s || args.keyboard.j
      args.state.player.y -= 0.25
    elsif args.keyboard.up || args.keyboard.w || args.keyboard.k
      args.state.player.y += 0.25
    end

    if args.keyboard.left     || args.keyboard.a  || args.keyboard.h
      args.state.player.x -= 0.25
    elsif args.keyboard.right || args.keyboard.d  || args.keyboard.l
      args.state.player.x += 0.25
    end

    args.state.player.y = 60 if args.state.player.y > 63
    args.state.player.y =  0 if args.state.player.y < -3
    args.state.player.x = 60 if args.state.player.x > 63
    args.state.player.x =  0 if args.state.player.x < -3
  end
end

def null_or_empty? ary
  return true unless ary
  return true if ary.length == 0
  return false
end

def calc_storyline_hotspot args
  hotspots = args.state.storylines.find_all do |hs|
    args.state.player.inside_rect?(hs.shift_rect(-2, 0))
  end

  if !null_or_empty?(hotspots) && !args.state.inside_storyline_hotspot
    _, _, _, _, storyline = hotspots.first
    queue_storyline_text(args, storyline)
    args.state.inside_storyline_hotspot = true
  elsif null_or_empty?(hotspots)
    args.state.inside_storyline_hotspot = false

    args.state.storyline_queue_empty_at ||= args.state.tick_count
    args.state.is_storyline_dialog_active = false
    args.state.scene_storyline_queue.clear
  end
end

def calc_scenes args
  hotspots = args.state.scenes.find_all do |hs|
    args.state.player.inside_rect?(hs.shift_rect(-2, 0))
  end

  if !null_or_empty?(hotspots) && !args.state.inside_scene_hotspot
    _, _, _, _, scene_method_or_hash = hotspots.first
    if scene_method_or_hash.is_a? Symbol
      set_scene(args, send(scene_method_or_hash, args))
      args.state.last_hotspot_scene = scene_method_or_hash
      args.state.scene_history << scene_method_or_hash
    else
      set_scene(args, scene_method_or_hash)
    end
    args.state.inside_scene_hotspot = true
  elsif null_or_empty?(hotspots)
    args.state.inside_scene_hotspot = false
  end
end

def null_or_whitespace? word
  return true if !word
  return true if word.strip.length == 0
  return false
end

def calc_storyline_presentation args
  return unless args.state.tick_count > args.state.next_storyline
  return unless args.state.scene_storyline_queue
  next_storyline = args.state.scene_storyline_queue.shift
  if null_or_whitespace? next_storyline
    args.state.storyline_queue_empty_at ||= args.state.tick_count
    args.state.is_storyline_dialog_active = false
    return
  end
  args.state.storyline_to_show = next_storyline
  args.state.is_storyline_dialog_active = true
  args.state.storyline_queue_empty_at = nil
  if next_storyline.end_with?(".") || next_storyline.end_with?("!") || next_storyline.end_with?("?") || next_storyline.end_with?("\"")
    args.state.next_storyline += 60
  elsif next_storyline.end_with?(",")
    args.state.next_storyline += 50
  elsif next_storyline.end_with?(":")
    args.state.next_storyline += 60
  else
    default_word_delay = 13 + args.state.word_delay - 8
    if next_storyline.gsub("-", "").gsub("~", "").length <= 4
      default_word_delay = 11 + args.state.word_delay - 8
    end
    number_of_syllabals = next_storyline.length - next_storyline.gsub("-", "").length
    args.state.next_storyline += default_word_delay + number_of_syllabals * (args.state.word_delay + 1)
  end
end

def inputs_reload_current_scene args
  return
  if args.inputs.keyboard.key_down.r!
    reload_current_scene
  end
end

def inputs_dismiss_current_storyline args
  if args.inputs.keyboard.key_down.x!
    args.state.scene_storyline_queue.clear
  end
end

def inputs_restart_game args
  if args.inputs.keyboard.exclamation_point
    args.gtk.reset_state
  end
end

def inputs_change_word_delay args
  if args.inputs.keyboard.key_down.plus || args.inputs.keyboard.key_down.equal_sign
    args.state.word_delay -= 2
    if args.state.word_delay < 0
      args.state.word_delay = 0
      # queue_storyline_text args, "Text speed at MAXIMUM. Geez, how fast do you read?"
    else
      # queue_storyline_text args, "Text speed INCREASED."
    end
  end

  if args.inputs.keyboard.key_down.hyphen || args.inputs.keyboard.key_down.underscore
    args.state.word_delay += 2
    # queue_storyline_text args, "Text speed DECREASED."
  end
end

def multiple_lines args, x, y, texts, size = 0, minimum_alpha = nil
  texts.each_with_index.map do |t, i|
    [x, y - i * (25 + size * 2), t, size, 0, 255, 255, 255, adornments_alpha(args, 255, minimum_alpha)]
  end
end

def lowrez_tick args, lowrez_sprites, lowrez_labels, lowrez_borders, lowrez_solids, lowrez_mouse
  # args.state.show_gridlines = true
  defaults args
  render_current_scene args, lowrez_sprites, lowrez_labels, lowrez_solids
  render_controller args, lowrez_borders
  lowrez_solids << [0, 0, 64, 64, 0, 0, 0]
  calc_storyline_presentation args
  calc_scenes args
  calc_storyline_hotspot args
  inputs_move_player args
  inputs_print_mouse_rect args, lowrez_mouse
  inputs_reload_current_scene args
  inputs_dismiss_current_storyline args
  inputs_change_word_delay args
  inputs_restart_game args
end

def render_controller args, lowrez_borders
  args.state.up_button    = [85, 40, 15, 15, 255, 255, 255]
  args.state.down_button  = [85, 20, 15, 15, 255, 255, 255]
  args.state.left_button  = [65, 20, 15, 15, 255, 255, 255]
  args.state.right_button = [105, 20, 15, 15, 255, 255, 255]
  lowrez_borders << args.state.up_button
  lowrez_borders << args.state.down_button
  lowrez_borders << args.state.left_button
  lowrez_borders << args.state.right_button
end

def inputs_print_mouse_rect args, lowrez_mouse
  if lowrez_mouse.up
    args.state.mouse_held = false
  elsif lowrez_mouse.click
    mouse_rect = [lowrez_mouse.x, lowrez_mouse.y, 1, 1]
    if args.state.up_button.intersect_rect? mouse_rect
      args.state.player.y += 1
    end

    if args.state.down_button.intersect_rect? mouse_rect
      args.state.player.y -= 1
    end

    if args.state.left_button.intersect_rect? mouse_rect
      args.state.player.x -= 1
    end

    if args.state.right_button.intersect_rect? mouse_rect
      args.state.player.x += 1
    end
    args.state.mouse_held = true
  elsif args.state.mouse_held
    mouse_rect = [lowrez_mouse.x, lowrez_mouse.y, 1, 1]
    if args.state.up_button.intersect_rect? mouse_rect
      args.state.player.y += 0.25
    end

    if args.state.down_button.intersect_rect? mouse_rect
      args.state.player.y -= 0.25
    end

    if args.state.left_button.intersect_rect? mouse_rect
      args.state.player.x -= 0.25
    end

    if args.state.right_button.intersect_rect? mouse_rect
      args.state.player.x += 0.25
    end
  end

  if lowrez_mouse.click
    dx = lowrez_mouse.click.x - args.state.previous_mouse_click.x
    dy = lowrez_mouse.click.y - args.state.previous_mouse_click.y
    x, y, w, h = args.state.previous_mouse_click.x, args.state.previous_mouse_click.y, dx, dy
    puts "x #{lowrez_mouse.click.x}, y: #{lowrez_mouse.click.y}"
    if args.state.previous_mouse_click

      if dx < 0 && dx < 0
        x = x + w
        w = w.abs
        y = y + h
        h = h.abs
      end

      w += 1
      h += 1

      args.state.previous_mouse_click = nil
    else
      args.state.previous_mouse_click = lowrez_mouse.click
      square_x, square_y = lowrez_mouse.click
    end
  end
end

def try_centering! word
  word ||= ""
  just_word = word.gsub("-", "").gsub(",", "").gsub(".", "").gsub("'", "").gsub('""', "\"-\"")
  return word if just_word.strip.length == 0
  return word if just_word.include? "~"
  return "~#{word}" if just_word.length <= 2
  if just_word.length.mod_zero? 2
    center_index = just_word.length.idiv(2) - 1
  else
    center_index = (just_word.length - 1).idiv(2)
  end
  return "#{word[0..center_index - 1]}~#{word[center_index]}#{word[center_index + 1..-1]}"
end

def queue_storyline args, scene
  queue_storyline_text args, scene[:storyline]
end

def queue_storyline_text args, text
  args.state.last_story_line_text = text
  args.state.storyline_history << text if text
  words = (text || "").split(" ")
  words = words.map { |w| try_centering! w }
  args.state.scene_storyline_queue = words
  if args.state.scene_storyline_queue.length != 0
    args.state.scene_storyline_queue.unshift "~$--"
    args.state.storyline_to_show = "~."
  else
    args.state.storyline_to_show = ""
  end
  args.state.scene_storyline_queue << ""
  args.state.next_storyline = args.state.tick_count
end

def set_scene args, scene
  args.state.current_scene = scene
  args.state.background = scene[:background] ||  'sprites/todo.png'
  args.state.scene_fade = scene[:fade] || 0
  args.state.scenes = (scene[:scenes] || []).reject { |s| !s }
  args.state.scene_render_override = scene[:render_override]
  args.state.storylines = (scene[:storylines] || []).reject { |s| !s }
  args.state.scene_changed_at = args.state.tick_count
  if scene[:player]
    args.state.player = scene[:player]
  end
  args.state.inside_scene_hotspot = false
  args.state.inside_storyline_hotspot = false
  queue_storyline args, scene
end

def replay_storyline_rect
  [26, -1, 7, 4]
end

def labels_for_word word
  left_side_of_word = ""
  center_letter = ""
  right_side_of_word = ""

  if word[0] == "~"
    left_side_of_word = ""
    center_letter = word[1]
    right_side_of_word = word[2..-1]
  elsif word.length > 0
    left_side_of_word, right_side_of_word = word.split("~")
    center_letter = right_side_of_word[0]
    right_side_of_word = right_side_of_word[1..-1]
  end

  right_side_of_word = right_side_of_word.gsub("-", "")

  {
    left:   [29 - left_side_of_word.length * 4 - 1 * left_side_of_word.length, 2, left_side_of_word],
    center: [29, 2, center_letter, 255, 0, 0],
    right:  [34, 2, right_side_of_word]
  }
end

def render_scenes args, lowrez_sprites
  lowrez_sprites << args.state.scenes.flat_map do |hs|
    hotspot_square args, hs.x, hs.y, hs.w, hs.h
  end
end

def render_storylines args, lowrez_sprites
  lowrez_sprites << args.state.storylines.flat_map do |hs|
    hotspot_square args, hs.x, hs.y, hs.w, hs.h
  end
end

def adornments_alpha args, target_alpha = nil, minimum_alpha = nil
  return (minimum_alpha || 80) unless args.state.storyline_queue_empty_at
  target_alpha ||= 255
  target_alpha * args.state.storyline_queue_empty_at.ease(60)
end

def hotspot_square args, x, y, w, h
  if w >= 3 && h >= 3
    [
      [x + w.idiv(2) + 1, y, w.idiv(2), h, 'sprites/label-background.png', 0, adornments_alpha(args, 50), 23, 23, 23],
      [x, y, w.idiv(2), h, 'sprites/label-background.png', 0, adornments_alpha(args, 100), 223, 223, 223],
      [x + 1, y + 1, w - 2, h - 2, 'sprites/label-background.png', 0, adornments_alpha(args, 200), 40, 140, 40],
    ]
  else
    [
      [x, y, w, h, 'sprites/label-background.png', 0, adornments_alpha(args, 200), 0, 140, 0],
    ]
  end
end

def render_storyline_dialog args, lowrez_labels, lowrez_sprites
  return unless args.state.is_storyline_dialog_active
  return unless args.state.storyline_to_show
  labels = labels_for_word args.state.storyline_to_show
  if true # high rez version
    scale = 8.88
    offset = 45
    size = 25
    args.outputs.labels << [offset + labels[:left].x.-(1) * scale,
                            labels[:left].y * TINY_SCALE + 55,
                            labels[:left].text, size, 0, 0, 0, 0, 255,
                            'fonts/manaspc.ttf']
    center_text = labels[:center].text
    center_text = "|" if center_text == "$"
    args.outputs.labels << [offset + labels[:center].x * scale,
                            labels[:center].y * TINY_SCALE + 55,
                            center_text, size, 0, 255, 0, 0, 255,
                            'fonts/manaspc.ttf']
    args.outputs.labels << [offset + labels[:right].x * scale,
                            labels[:right].y * TINY_SCALE + 55,
                            labels[:right].text, size, 0, 0, 0, 0, 255,
                            'fonts/manaspc.ttf']
  else
    lowrez_labels << labels[:left]
    lowrez_labels << labels[:center]
    lowrez_labels << labels[:right]
  end
  args.state.is_storyline_dialog_active = true
  render_player args, lowrez_sprites
  lowrez_sprites <<  [0, 0, 64, 8, 'sprites/label-background.png']
end

def render_player args, lowrez_sprites
  lowrez_sprites << player_md_down(args, *args.state.player)
end

def render_adornments args, lowrez_sprites
  render_scenes args, lowrez_sprites
  render_storylines args, lowrez_sprites
  return if args.state.is_storyline_dialog_active
  lowrez_sprites << player_md_down(args, *args.state.player)
end

def global_alpha_percentage args, max_alpha = 255
  return 255 unless args.state.scene_changed_at
  return 255 unless args.state.scene_fade
  return 255 unless args.state.scene_fade > 0
  return max_alpha * args.state.scene_changed_at.ease(args.state.scene_fade)
end

def render_current_scene args, lowrez_sprites, lowrez_labels, lowrez_solids
  lowrez_sprites << [0, 0, 64, 64, args.state.background, 0, (global_alpha_percentage args)]
  if args.state.scene_render_override
    send args.state.scene_render_override, args, lowrez_sprites, lowrez_labels, lowrez_solids
  end
  storyline_to_show = args.state.storyline_to_show || ""
  render_adornments args, lowrez_sprites
  render_storyline_dialog args, lowrez_labels, lowrez_sprites

  if args.state.background == 'sprites/tribute-game-over.png'
    lowrez_sprites << [0, 0, 64, 11, 'sprites/label-background.png', 0, adornments_alpha(args, 200), 0, 0, 0]
    lowrez_labels << [9, 6, 'Return of', 255, 255, 255]
    lowrez_labels << [9, 1, ' Serenity', 255, 255, 255]
    if !args.state.ended
      args.gtk.stop_music
      args.outputs.sounds << 'sounds/music-loop.ogg'
      args.state.ended = true
    end
  end
end

def player_md_right args, x, y
  [x, y, 4, 11, 'sprites/player-right.png', 0, (global_alpha_percentage args)]
end

def player_md_left args, x, y
  [x, y, 4, 11, 'sprites/player-left.png', 0, (global_alpha_percentage args)]
end

def player_md_up args, x, y
  [x, y, 4, 11, 'sprites/player-up.png', 0, (global_alpha_percentage args)]
end

def player_md_down args, x, y
  [x, y, 4, 11, 'sprites/player-down.png', 0, (global_alpha_percentage args)]
end

def player_sm args, x, y
  [x, y, 3, 7, 'sprites/player-zoomed-out.png', 0, (global_alpha_percentage args)]
end

def player_xs args, x, y
  [x, y, 1, 4, 'sprites/player-zoomed-out.png', 0, (global_alpha_percentage args)]
end
