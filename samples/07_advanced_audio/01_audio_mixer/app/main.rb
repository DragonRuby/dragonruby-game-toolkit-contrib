# these are the properties that you can sent on args.audio
def spawn_new_sound args, name, path
  # Spawn randomly in an area that won't be covered by UI.
  screenx = (rand * 600.0) + 200.0
  screeny = (rand * 400.0) + 100.0

  id = new_sound_id! args
  # you can hang anything on the audio hashes you want, so we store the
  #  actual screen position in here for convenience.
  args.audio[id] = {
    name: name,
    input: path,
    screenx: screenx,
    screeny: screeny,
    x: ((screenx / 1279.0) * 2.0) - 1.0,  # scale to -1.0 - 1.0 range
    y: ((screeny / 719.0) * 2.0) - 1.0,   # scale to -1.0 - 1.0 range
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    looping: true,
    paused: false
  }

  args.state.selected = id
end

# these are values you can change on the ~args.audio~ data structure
def input_panel args
  return unless args.state.panel
  return if args.state.dragging

  audio_entry = args.audio[args.state.selected]
  results = args.state.panel

  if args.state.mouse_state == :held && args.inputs.mouse.position.inside_rect?(results.pitch_slider_rect.rect)
    audio_entry.pitch = 2.0 * ((args.inputs.mouse.x - results.pitch_slider_rect.x).to_f / (results.pitch_slider_rect.w - 1.0))
  elsif args.state.mouse_state == :held && args.inputs.mouse.position.inside_rect?(results.playtime_slider_rect.rect)
    audio_entry.playtime = audio_entry.length_ * ((args.inputs.mouse.x - results.playtime_slider_rect.x).to_f / (results.playtime_slider_rect.w - 1.0))
  elsif args.state.mouse_state == :held && args.inputs.mouse.position.inside_rect?(results.gain_slider_rect.rect)
    audio_entry.gain = (args.inputs.mouse.x - results.gain_slider_rect.x).to_f / (results.gain_slider_rect.w - 1.0)
  elsif args.inputs.mouse.click && args.inputs.mouse.position.inside_rect?(results.looping_checkbox_rect.rect)
    audio_entry.looping = !audio_entry.looping
  elsif args.inputs.mouse.click && args.inputs.mouse.position.inside_rect?(results.paused_checkbox_rect.rect)
    audio_entry.paused = !audio_entry.paused
  elsif args.inputs.mouse.click && args.inputs.mouse.position.inside_rect?(results.delete_button_rect.rect)
    args.audio.delete args.state.selected
  end
end

def render_sources args
  args.outputs.primitives << args.audio.keys.map do |k|
    s = args.audio[k]

    isselected = (k == args.state.selected)

    color = isselected ? [ 0, 255, 0, 255 ] : [ 0, 0, 255, 255 ]
    [
      [s.screenx, s.screeny, args.state.boxsize, args.state.boxsize, *color].solid,

      {
        x: s.screenx + args.state.boxsize.half,
        y: s.screeny,
        text: s.name,
        r: 255,
        g: 255,
        b: 255,
        alignment_enum: 1
      }.label!
    ]
  end
end

def playtime_str t
  return "" unless t
  minutes = (t / 60.0).floor
  seconds = t - (minutes * 60.0).to_f
  return minutes.to_s + ':' + seconds.floor.to_s + ((seconds - seconds.floor).to_s + "000")[1..3]
end

def label_with_drop_shadow x, y, text
  [
    { x: x + 1, y: y + 1, text: text, vertical_alignment_enum: 1, alignment_enum: 1, r:   0, g:   0, b:   0 }.label!,
    { x: x + 2, y: y + 0, text: text, vertical_alignment_enum: 1, alignment_enum: 1, r:   0, g:   0, b:   0 }.label!,
    { x: x + 0, y: y + 1, text: text, vertical_alignment_enum: 1, alignment_enum: 1, r: 200, g: 200, b: 200 }.label!
  ]
end

def check_box opts = {}
  checkbox_template = opts.args.layout.rect(w: 0.5, h: 0.5, col: 2)
  final_rect = checkbox_template.center_inside_rect_y(opts.args.layout.rect(row: opts.row, col: opts.col))
  color = { r:   0, g:   0, b:   0 }
  color = { r: 255, g: 255, b: 255 } if opts.checked

  {
    rect: final_rect,
    primitives: [
      (final_rect.to_solid color)
    ]
  }
end

def progress_bar opts = {}
  outer_rect  = opts.args.layout.rect(row: opts.row, col: opts.col, w: 5, h: 1)
  color = opts.percentage * 255
  baseline_progress_bar = opts.args
                              .layout
                              .rect(w: 5, h: 0.5)

  final_rect = baseline_progress_bar.center_inside_rect(outer_rect)
  center = final_rect.rect_center_point

  {
    rect: final_rect,
    primitives: [
      final_rect.merge(r: color, g: color, b: color, a: 128).solid!,
      label_with_drop_shadow(center.x, center.y, opts.text)
    ]
  }
end

def panel_primitives args, audio_entry
  results = { primitives: [] }

  return results unless audio_entry

  # this uses DRGTK's layout apis to layout the controls
  # imagine the screen is split into equal cells (24 cells across, 12 cells up and down)
  # args.layout.rect returns a hash which we merge values with to create primitives
  # using args.layout.rect removes the need for pixel pushing

  # args.outputs.debug << args.layout.debug_primitives(r: 255, g: 255, b: 255)

  white_color = { r: 255, g: 255, b: 255 }
  label_style = white_color.merge(vertical_alignment_enum: 1)

  # panel background
  results.primitives << args.layout.rect(row: 0, col: 0, w: 7, h: 6, include_col_gutter: true, include_row_gutter: true)
                                   .border!(r: 255, g: 255, b: 255)

  # title
  results.primitives << args.layout.point(row: 0, col: 3.5, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text:           "Source #{args.state.selected} (#{args.audio[args.state.selected].name})",
                                          size_enum:      3,
                                          alignment_enum: 1)

  # seperator line
  results.primitives << args.layout.rect(row: 1, col: 0, w: 7, h: 0)
                                   .line!(white_color)

  # screen location
  results.primitives << args.layout.point(row: 1.0, col: 0, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "screen:")

  results.primitives << args.layout.point(row: 1.0, col: 2, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "(#{audio_entry.screenx.to_i}, #{audio_entry.screeny.to_i})")

  # position
  results.primitives << args.layout.point(row: 1.5, col: 0, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "position:")

  results.primitives << args.layout.point(row: 1.5, col: 2, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "(#{audio_entry[:x].round(5).to_s[0..6]}, #{audio_entry[:y].round(5).to_s[0..6]})")

  results.primitives << args.layout.point(row: 2.0, col: 0, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "pitch:")

  results.pitch_slider_rect = progress_bar(row: 2.0, col: 2,
                                           percentage: audio_entry.pitch / 2.0,
                                           text: "#{audio_entry.pitch.to_sf}",
                                           args: args)

  results.primitives << results.pitch_slider_rect.primitives

  results.primitives << args.layout.point(row: 2.5, col: 0, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "playtime:")

  results.playtime_slider_rect = progress_bar(args: args,
                                              row:  2.5,
                                              col:  2,
                                              percentage: (audio_entry.playtime || 1) / (audio_entry.length_ || 1),
                                              text: "#{playtime_str(audio_entry.playtime)} / #{playtime_str(audio_entry.length_)}")

  results.primitives << results.playtime_slider_rect.primitives

  results.primitives << args.layout.point(row: 3.0, col: 0, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "gain:")

  results.gain_slider_rect = progress_bar(args: args,
                                          row:  3.0,
                                          col:  2,
                                          percentage: audio_entry.gain,
                                          text: "#{audio_entry.gain.to_sf}")

  results.primitives << results.gain_slider_rect.primitives


  results.primitives << args.layout.point(row: 3.5, col: 0, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "looping:")

  checkbox_template = args.layout.rect(w: 0.5, h: 0.5, col: 2)

  results.looping_checkbox_rect = check_box(args: args, row: 3.5, col: 2, checked: audio_entry.looping)
  results.primitives << results.looping_checkbox_rect.primitives

  results.primitives << args.layout.point(row: 4.0, col: 0, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "paused:")

  checkbox_template = args.layout.rect(w: 0.5, h: 0.5, col: 2)

  results.paused_checkbox_rect = check_box(args: args, row: 4.0, col: 2, checked: !audio_entry.paused)
  results.primitives << results.paused_checkbox_rect.primitives

  results.delete_button_rect = { rect: args.layout.rect(row: 5, col: 0, w: 7, h: 1) }

  results.primitives << results.delete_button_rect.to_solid(r: 180)

  results.primitives << args.layout.point(row: 5, col: 3.5, row_anchor: 0.5)
                                   .merge(label_style)
                                   .merge(text: "DELETE", alignment_enum: 1)

  return results
end

def render_panel args
  args.state.panel = nil
  audio_entry = args.audio[args.state.selected]
  return unless audio_entry

  mouse_down = (args.state.mouse_held >= 0)
  args.state.panel = panel_primitives args, audio_entry
  args.outputs.primitives << args.state.panel.primitives
end

def new_sound_id! args
  args.state.sound_id ||= 0
  args.state.sound_id  += 1
  args.state.sound_id
end

def render_launcher args
  args.outputs.primitives << args.state.spawn_sound_buttons.map(&:primitives)
end

def render_ui args
  render_launcher args
  render_panel args
end

def tick args
  defaults args
  render args
  input args
end

def input args
  if !args.audio[args.state.selected]
    args.state.selected = nil
    args.state.dragging = nil
  end

  # spawn button and node interaction
  if args.inputs.mouse.click
    spawn_sound_button = args.state.spawn_sound_buttons.find { |b| args.inputs.mouse.inside_rect? b.rect }

    audio_click_key, audio_click_value = args.audio.find do |k, v|
      args.inputs.mouse.inside_rect? [v.screenx, v.screeny, args.state.boxsize, args.state.boxsize]
    end

    if spawn_sound_button
      args.state.selected = nil
      spawn_new_sound args, spawn_sound_button.name, spawn_sound_button.path
    elsif audio_click_key
      args.state.selected = audio_click_key
    end
  end

  if args.state.mouse_state == :held && args.state.selected
    v = args.audio[args.state.selected]
    if args.inputs.mouse.inside_rect? [v.screenx, v.screeny, args.state.boxsize, args.state.boxsize]
      args.state.dragging = args.state.selected
    end

    if args.state.dragging
      s = args.audio[args.state.selected]
      # you can hang anything on the audio hashes you want, so we store the
      #  actual screen position so it doesn't scale weirdly vs your mouse.
      s.screenx = args.inputs.mouse.x - (args.state.boxsize / 2)
      s.screeny = args.inputs.mouse.y - (args.state.boxsize / 2)

      s.screeny = 50 if s.screeny < 50
      s.screeny = (719 - args.state.boxsize) if s.screeny > (719 - args.state.boxsize)
      s.screenx = 0 if s.screenx < 0
      s.screenx = (1279 - args.state.boxsize) if s.screenx > (1279 - args.state.boxsize)

      s.x = ((s.screenx / 1279.0) * 2.0) - 1.0  # scale to -1.0 - 1.0 range
      s.y = ((s.screeny / 719.0) * 2.0) - 1.0   # scale to -1.0 - 1.0 range
    end
  elsif args.state.mouse_state == :released
    args.state.dragging = nil
  end

  input_panel args
end

def defaults args
  args.state.mouse_state      ||= :released
  args.state.dragging_source  ||= false
  args.state.selected         ||= 0
  args.state.next_sound_index ||= 0
  args.state.boxsize          ||= 30
  args.state.sound_files      ||= [
    { name: :tada,   path: "sounds/tada.wav"   },
    { name: :splash, path: "sounds/splash.wav" },
    { name: :drum,   path: "sounds/drum.mp3"   },
    { name: :spring, path: "sounds/spring.wav" },
    { name: :music,  path: "sounds/music.ogg"  }
  ]

  # generate buttons based off the sound collection above
  args.state.spawn_sound_buttons ||= begin
    # create a group of buttons
    # column centered (using col_offset to calculate the column offset)
    # where each item is 2 columns apart
    rects = args.layout.rect_group row:   11,
                                   col_offset: {
                                     count: args.state.sound_files.length,
                                     w:     2
                                   },
                                   dcol:  2,
                                   w:     2,
                                   h:     1,
                                   group: args.state.sound_files

    # now that you have the rects
    # construct the metadata for the buttons
    rects.map do |rect|
      {
        rect: rect,
        name: rect.name,
        path: rect.path,
        primitives: [
          rect.to_border(r: 255, g: 255, b: 255),
          rect.to_label(x: rect.center_x,
                        y: rect.center_y,
                        text: "#{rect.name}",
                        alignment_enum: 1,
                        vertical_alignment_enum: 1,
                        r: 255, g: 255, b: 255)
        ]
      }
    end
  end

  if args.inputs.mouse.up
    args.state.mouse_state = :released
    args.state.dragging_source = false
  elsif args.inputs.mouse.down
    args.state.mouse_state = :held
  end

  args.outputs.background_color = [ 0, 0, 0, 255 ]
end

def render args
  render_ui args
  render_sources args
end
