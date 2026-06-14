module Main
  def tick
    defaults
    input
    render
  end

  # these are the properties that you can sent on audio
  def spawn_new_sound  name, path
    # Spawn randomly in an area that won't be covered by UI.
    screenx = (rand * 600.0) + 200.0
    screeny = (rand * 400.0) + 100.0

    id = new_sound_id!
    # you can hang anything on the audio hashes you want, so we store the
    #  actual screen position in here for convenience.
    audio[id] = {
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

    state.selected = id
  end

  # these are values you can change on the ~audio~ data structure
  def input_panel
    return unless state.panel
    return if state.dragging

    audio_entry = audio[state.selected]
    results = state.panel

    if state.mouse_state == :held && inputs.mouse.position.inside_rect?(results.pitch_slider_rect.rect)
      audio_entry.pitch = 2.0 * ((inputs.mouse.x - results.pitch_slider_rect.rect.x).to_f / (results.pitch_slider_rect.rect.w - 1.0))
    elsif state.mouse_state == :held && inputs.mouse.position.inside_rect?(results.playtime_slider_rect.rect)
      audio_entry.playtime = audio_entry.length_ * ((inputs.mouse.x - results.playtime_slider_rect.rect.x).to_f / (results.playtime_slider_rect.rect.w - 1.0))
    elsif state.mouse_state == :held && inputs.mouse.position.inside_rect?(results.gain_slider_rect.rect)
      audio_entry.gain = (inputs.mouse.x - results.gain_slider_rect.rect.x).to_f / (results.gain_slider_rect.rect.w - 1.0)
    elsif inputs.mouse.click && inputs.mouse.position.inside_rect?(results.looping_checkbox_rect.rect)
      audio_entry.looping = !audio_entry.looping
    elsif inputs.mouse.click && inputs.mouse.position.inside_rect?(results.paused_checkbox_rect.rect)
      audio_entry.paused = !audio_entry.paused
    elsif inputs.mouse.click && inputs.mouse.position.inside_rect?(results.delete_button_rect.rect)
      audio.delete state.selected
    end
  end

  def render_sources
    outputs.primitives << audio.keys.map do |k|
      s = audio[k]

      isselected = (k == state.selected)

      color = isselected ? { r: 0, g: 255, b: 0, a: 255 } : { r: 0, g: 0, b: 255, a: 255 }
      [
        {
          x: s.screenx,
          y: s.screeny,
          w: state.boxsize,
          h: state.boxsize,
          path: :solid,
          **color
        },
        {
          x: s.screenx + state.boxsize.half,
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
    checkbox_template = Layout.rect(w: 0.5, h: 0.5, col: 2)
    final_rect = checkbox_template.center_inside_rect_y(Layout.rect(row: opts.row, col: opts.col))
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
    outer_rect  = Layout.rect(row: opts.row, col: opts.col, w: 5, h: 1)
    color = opts.percentage * 255
    baseline_progress_bar = Layout.rect(w: 5, h: 0.5)

    final_rect = baseline_progress_bar.center_inside_rect(outer_rect)
    center = Geometry.rect_center_point(final_rect)

    {
      rect: final_rect,
      primitives: [
        final_rect.merge(r: color, g: color, b: color, a: 128).solid!,
        label_with_drop_shadow(center.x, center.y, opts.text)
      ]
    }
  end

  def panel_primitives  audio_entry
    results = { primitives: [] }

    return results unless audio_entry

    # this uses DRDR's layout apis to layout the controls
    # imagine the screen is split into equal cells (24 cells across, 12 cells up and down)
    # Layout.rect returns a hash which we merge values with to create primitives
    # using Layout.rect removes the need for pixel pushing

    # outputs.debug << Layout.debug_primitives(r: 255, g: 255, b: 255)

    white_color = { r: 255, g: 255, b: 255 }
    label_style = white_color.merge(vertical_alignment_enum: 1)

    # panel background
    results.primitives << Layout.rect(row: 0, col: 0, w: 7, h: 6, include_col_gutter: true, include_row_gutter: true)
                                .border!(r: 255, g: 255, b: 255)

    # title
    results.primitives << Layout.rect(row: 0, col: 0, h: 1, w: 7)
                                .center
                                .merge(label_style)
                                .merge(text: "Source #{state.selected} (#{audio[state.selected].name})",
                                       size_px:      26,
                                       anchor_x: 0.5, anchor_y: 0.5)

    # seperator line
    results.primitives << Layout.rect(row: 1, col: 0, w: 7, h: 0)
                                .line!(white_color)

    # screen location
    results.primitives << Layout.point(row: 1.0, col: 0, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "screen:")

    results.primitives << Layout.point(row: 1.0, col: 2, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "(#{audio_entry.screenx.to_i}, #{audio_entry.screeny.to_i})")

    # position
    results.primitives << Layout.point(row: 1.5, col: 0, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "position:")

    results.primitives << Layout.point(row: 1.5, col: 2, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "(#{audio_entry[:x].round(5).to_s[0..6]}, #{audio_entry[:y].round(5).to_s[0..6]})")

    results.primitives << Layout.point(row: 2.0, col: 0, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "pitch:")

    results.pitch_slider_rect = progress_bar(row: 2.0, col: 2,
                                             percentage: audio_entry.pitch / 2.0,
                                             text: "#{audio_entry.pitch.to_sf}")

    results.primitives << results.pitch_slider_rect.primitives

    results.primitives << Layout.point(row: 2.5, col: 0, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "playtime:")

    results.playtime_slider_rect = progress_bar(row:  2.5,
                                                col:  2,
                                                percentage: (audio_entry.playtime || 1) / (audio_entry.length_ || 1),
                                                text: "#{playtime_str(audio_entry.playtime)} / #{playtime_str(audio_entry.length_)}")

    results.primitives << results.playtime_slider_rect.primitives

    results.primitives << Layout.point(row: 3.0, col: 0, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "gain:")

    results.gain_slider_rect = progress_bar(row:  3.0,
                                            col:  2,
                                            percentage: audio_entry.gain,
                                            text: "#{audio_entry.gain.to_sf}")

    results.primitives << results.gain_slider_rect.primitives


    results.primitives << Layout.point(row: 3.5, col: 0, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "looping:")

    checkbox_template = Layout.rect(w: 0.5, h: 0.5, col: 2)

    results.looping_checkbox_rect = check_box(row: 3.5, col: 2, checked: audio_entry.looping)
    results.primitives << results.looping_checkbox_rect.primitives

    results.primitives << Layout.point(row: 4.0, col: 0, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "paused:")

    checkbox_template = Layout.rect(w: 0.5, h: 0.5, col: 2)

    results.paused_checkbox_rect = check_box(row: 4.0, col: 2, checked: audio_entry.paused)
    results.primitives << results.paused_checkbox_rect.primitives

    results.delete_button_rect = { rect: Layout.rect(row: 5, col: 0, w: 7, h: 1) }

    results.primitives << results.delete_button_rect.rect.to_solid(r: 180)

    results.primitives << Layout.point(row: 5, col: 3.5, row_anchor: 0.5)
                                .merge(label_style)
                                .merge(text: "DELETE", alignment_enum: 1)

    return results
  end

  def render_panel
    state.panel = nil
    audio_entry = audio[state.selected]
    return unless audio_entry

    state.panel = panel_primitives  audio_entry
    outputs.primitives << state.panel.primitives
  end

  def new_sound_id!
    state.sound_id ||= 0
    state.sound_id  += 1
    state.sound_id
  end

  def render_launcher
    outputs.primitives << state.spawn_sound_buttons.map(&:primitives)
  end

  def render_ui
    render_launcher
    render_panel
  end

  def input
    if !audio[state.selected]
      state.selected = nil
      state.dragging = nil
    end

    # spawn button and node interaction
    if inputs.mouse.click
      spawn_sound_button = state.spawn_sound_buttons.find { |b| inputs.mouse.inside_rect? b.rect }

      audio_click_key, audio_click_value = audio.find do |k, v|
        inputs.mouse.inside_rect? x: v.screenx, y: v.screeny, w: state.boxsize, h: state.boxsize
      end

      if spawn_sound_button
        state.selected = nil
        spawn_new_sound  spawn_sound_button.name, spawn_sound_button.path
      elsif audio_click_key
        state.selected = audio_click_key
      end
    end

    if state.mouse_state == :held && state.selected
      v = audio[state.selected]
      if inputs.mouse.inside_rect? x: v.screenx, y: v.screeny, w: state.boxsize, h: state.boxsize
        state.dragging = state.selected
      end

      if state.dragging
        s = audio[state.selected]
        # you can hang anything on the audio hashes you want, so we store the
        #  actual screen position so it doesn't scale weirdly vs your mouse.
        s.screenx = inputs.mouse.x - (state.boxsize / 2)
        s.screeny = inputs.mouse.y - (state.boxsize / 2)

        s.screeny = 50 if s.screeny < 50
        s.screeny = (719 - state.boxsize) if s.screeny > (719 - state.boxsize)
        s.screenx = 0 if s.screenx < 0
        s.screenx = (1279 - state.boxsize) if s.screenx > (1279 - state.boxsize)

        s.x = ((s.screenx / 1279.0) * 2.0) - 1.0  # scale to -1.0 - 1.0 range
        s.y = ((s.screeny / 719.0) * 2.0) - 1.0   # scale to -1.0 - 1.0 range
      end
    elsif state.mouse_state == :released
      state.dragging = nil
    end

    input_panel
  end

  def defaults
    state.mouse_state      ||= :released
    state.dragging_source  ||= false
    state.selected         ||= 0
    state.next_sound_index ||= 0
    state.boxsize          ||= 30
    state.sound_files      ||= [
      { name: :tada,   path: "sounds/tada.wav"   },
      { name: :splash, path: "sounds/splash.wav" },
      { name: :drum,   path: "sounds/drum.mp3"   },
      { name: :spring, path: "sounds/spring.wav" },
      { name: :music,  path: "sounds/music.ogg"  }
    ]

    # generate buttons based off the sound collection above
    state.spawn_sound_buttons ||= begin
                                         # create a group of buttons
                                         # column centered (using col_offset to calculate the column offset)
                                         # where each item is 2 columns apart
                                         rects = Layout.rect_group row:   11,
                                                                   col_offset: {
                                                                     count: state.sound_files.length,
                                                                     w:     2
                                                                   },
                                                                   dcol:  2,
                                                                   w:     2,
                                                                   h:     1,
                                                                   group: state.sound_files

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

    if inputs.mouse.up
      state.mouse_state = :released
      state.dragging_source = false
    elsif inputs.mouse.down
      state.mouse_state = :held
    end

    outputs.background_color = [30, 30, 30]
  end

  def render
    render_ui
    render_sources
  end
end
