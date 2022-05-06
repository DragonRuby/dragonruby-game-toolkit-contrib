class OneBitLowrezPaint
  attr_gtk

  def tick
    outputs.background_color = [0, 0, 0]
    defaults
    render_instructions
    render_canvas
    render_buttons_frame_selection
    render_animation_frame_thumbnails
    render_animation
    input_mouse_click
    input_keyboard
    calc_auto_export
    calc_buttons_frame_selection
    calc_animation_frames
    process_queue_create_sprite
    process_queue_reset_sprite
    process_queue_update_rt_animation_frame
  end

  def defaults
    state.animation_frames_per_second = 12
    queues.create_sprite ||= []
    queues.reset_sprite ||= []
    queues.update_rt_animation_frame ||= []

    if !state.animation_frames
      state.animation_frames ||= []
      add_animation_frame_to_end
    end

    state.last_mouse_down ||= 0
    state.last_mouse_up   ||= 0

    state.buttons_frame_selection.left = 10
    state.buttons_frame_selection.top  = grid.top - 10
    state.buttons_frame_selection.size = 20

    defaults_canvas_sprite

    state.edit_mode ||= :drawing
  end

  def defaults_canvas_sprite
    rt_canvas.size   = 16
    rt_canvas.zoom   = 30
    rt_canvas.width  = rt_canvas.size * rt_canvas.zoom
    rt_canvas.height = rt_canvas.size * rt_canvas.zoom
    rt_canvas.sprite = { x: 0,
                         y: 0,
                         w: rt_canvas.width,
                         h: rt_canvas.height,
                         path: :rt_canvas }.center_inside_rect(x: 0, y: 0, w: 640, h: 720)

    return unless state.tick_count == 1

    outputs[:rt_canvas].width      = rt_canvas.width
    outputs[:rt_canvas].height     = rt_canvas.height
    outputs[:rt_canvas].sprites   << (rt_canvas.size + 1).map_with_index do |x|
      (rt_canvas.size + 1).map_with_index do |y|
        path = 'sprites/square-white.png'
        path = 'sprites/square-blue.png' if x == 7 || x == 8
        { x: x * rt_canvas.zoom,
          y: y * rt_canvas.zoom,
          w: rt_canvas.zoom,
          h: rt_canvas.zoom,
          path: path,
          a: 50 }
      end
    end
  end

  def render_instructions
    instructions = [
      "* Hotkeys:",
      "- d: hold to erase, release to draw.",
      "- a: add frame.",
      "- c: copy frame.",
      "- v: paste frame.",
      "- x: delete frame.",
      "- b: go to previous frame.",
      "- f: go to next frame.",
      "- w: save to ./canvas directory.",
      "- l: load from ./canvas."
    ]

    instructions.each.with_index do |l, i|
      outputs.labels << { x: 840, y: 500 - (i * 20), text: "#{l}",
                          r: 180, g: 180, b: 180, size_enum: 0 }
    end
  end

  def render_canvas
    return if state.tick_count.zero?
    outputs.sprites << rt_canvas.sprite
  end

  def render_buttons_frame_selection
    args.outputs.primitives << state.buttons_frame_selection.items.map_with_index do |b, i|
      label = { x: b.x + state.buttons_frame_selection.size.half,
                y: b.y,
                text: "#{i + 1}", r: 180, g: 180, b: 180,
                size_enum: -4, alignment_enum: 1 }.label!

      selection_border = b.merge(r: 40, g: 40, b: 40).border!

      if i == state.animation_frames_selected_index
        selection_border = b.merge(r: 40, g: 230, b: 200).border!
      end

      [selection_border, label]
    end
  end

  def render_animation_frame_thumbnails
    return if state.tick_count.zero?

    outputs[:current_animation_frame].width   = rt_canvas.size
    outputs[:current_animation_frame].height  = rt_canvas.size
    outputs[:current_animation_frame].solids <<  selected_animation_frame[:pixels].map_with_index do |f, i|
      { x: f.x,
        y: f.y,
        w: 1,
        h: 1, r: 255, g: 255, b: 255 }
    end

    outputs.sprites << rt_canvas.sprite.merge(path: :current_animation_frame)

    state.animation_frames.map_with_index do |animation_frame, animation_frame_index|
      outputs.sprites << state.buttons_frame_selection[:items][animation_frame_index][:inner_rect]
                              .merge(path: animation_frame[:rt_name])
    end
  end

  def render_animation
    sprite_index = 0.frame_index count: state.animation_frames.length,
                                 hold_for: 60 / state.animation_frames_per_second,
                                 repeat: true

    args.outputs.sprites << { x: 700 - 8,
                              y: 120,
                              w: 16,
                              h: 16,
                              path: (sprite_path sprite_index) }

    args.outputs.sprites << { x: 700 - 16,
                              y: 230,
                              w: 32,
                              h: 32,
                              path: (sprite_path sprite_index) }

    args.outputs.sprites << { x: 700 - 32,
                              y: 360,
                              w: 64,
                              h: 64,
                              path: (sprite_path sprite_index) }

    args.outputs.sprites << { x: 700 - 64,
                              y: 520,
                              w: 128,
                              h: 128,
                              path: (sprite_path sprite_index) }
  end

  def input_mouse_click
    if inputs.mouse.up
      state.last_mouse_up = state.tick_count
    elsif inputs.mouse.moved && user_is_editing?
      edit_current_animation_frame inputs.mouse.point
    end

    return unless inputs.mouse.click

    clicked_frame_button = state.buttons_frame_selection.items.find do |b|
      inputs.mouse.point.inside_rect? b
    end

    if (clicked_frame_button)
      state.animation_frames_selected_index = clicked_frame_button[:index]
    end

    if (inputs.mouse.point.inside_rect? rt_canvas.sprite)
      state.last_mouse_down = state.tick_count
      edit_current_animation_frame inputs.mouse.point
    end
  end

  def input_keyboard
    # w to save
    if inputs.keyboard.key_down.w
      t = Time.now
      state.save_description = "Time: #{t} (#{t.to_i})"
      gtk.serialize_state 'canvas/state.txt', state
      gtk.serialize_state "tmp/canvas_backups/#{t.to_i}/state.txt", state
      animation_frames.each_with_index do |animation_frame, i|
        queues.update_rt_animation_frame << { index: i,
                                              at: state.tick_count + i,
                                              queue_sprite_creation: true }
        queues.create_sprite << { index: i,
                                  at: state.tick_count + animation_frames.length + i,
                                  path_override: "tmp/canvas_backups/#{t.to_i}/sprite-#{i}.png" }
      end
      gtk.notify! "Canvas saved."
    end

    # l to load
    if inputs.keyboard.key_down.l
      args.state = gtk.deserialize_state 'canvas/state.txt'
      animation_frames.each_with_index do |a, i|
        queues.update_rt_animation_frame << { index: i,
                                              at: state.tick_count + i,
                                              queue_sprite_creation: true }
      end
      gtk.notify! "Canvas loaded."
    end

    # d to go into delete mode, release to paint
    if inputs.keyboard.key_held.d
      state.edit_mode = :erasing
      gtk.notify! "Erasing." if inputs.keyboard.key_held.d == (state.tick_count - 1)
    elsif inputs.keyboard.key_up.d
      state.edit_mode = :drawing
      gtk.notify! "Drawing."
    end

    # a to add a frame to the end
    if inputs.keyboard.key_down.a
      queues.create_sprite << { index: state.animation_frames_selected_index,
                                at: state.tick_count }
      queues.create_sprite << { index: state.animation_frames_selected_index + 1,
                                at: state.tick_count }
      add_animation_frame_to_end
      gtk.notify! "Frame added to end."
    end

    # c or t to copy
    if (inputs.keyboard.key_down.c || inputs.keyboard.key_down.t)
      state.clipboard = [selected_animation_frame[:pixels]].flatten
      gtk.notify! "Current frame copied."
    end

    # v or q to paste
    if (inputs.keyboard.key_down.v || inputs.keyboard.key_down.q) && state.clipboard
      selected_animation_frame[:pixels] = [state.clipboard].flatten
      queues.update_rt_animation_frame << { index: state.animation_frames_selected_index,
                                            at: state.tick_count,
                                            queue_sprite_creation: true }
      gtk.notify! "Pasted."
    end

    # f to go forward/next frame
    if (inputs.keyboard.key_down.f)
      if (state.animation_frames_selected_index == (state.animation_frames.length - 1))
        state.animation_frames_selected_index = 0
      else
        state.animation_frames_selected_index += 1
      end
      gtk.notify! "Next frame."
    end

    # b to go back/previous frame
    if (inputs.keyboard.key_down.b)
      if (state.animation_frames_selected_index == 0)
        state.animation_frames_selected_index = state.animation_frames.length - 1
      else
        state.animation_frames_selected_index -= 1
      end
      gtk.notify! "Previous frame."
    end

    # x to delete frame
    if (inputs.keyboard.key_down.x) && animation_frames.length > 1
      state.clipboard = selected_animation_frame[:pixels]
      state.animation_frames = animation_frames.find_all { |v| v[:index] != state.animation_frames_selected_index }
      if state.animation_frames_selected_index >= state.animation_frames.length
        state.animation_frames_selected_index = state.animation_frames.length - 1
      end
      gtk.notify! "Frame deleted."
    end
  end

  def calc_auto_export
    return if user_is_editing?
    return if state.last_mouse_up.elapsed_time != 30
    # auto export current animation frame if there is no editing for 30 ticks
    queues.create_sprite << { index: state.animation_frames_selected_index,
                              at: state.tick_count }
  end

  def calc_buttons_frame_selection
    state.buttons_frame_selection.items = animation_frames.length.map_with_index do |i|
      { x: state.buttons_frame_selection.left + i * state.buttons_frame_selection.size,
        y: state.buttons_frame_selection.top - state.buttons_frame_selection.size,
        inner_rect: {
          x: (state.buttons_frame_selection.left + 2) + i * state.buttons_frame_selection.size,
          y: (state.buttons_frame_selection.top - state.buttons_frame_selection.size + 2),
          w: 16,
          h: 16,
        },
        w: state.buttons_frame_selection.size,
        h: state.buttons_frame_selection.size,
        index: i }
    end
  end

  def calc_animation_frames
    animation_frames.each_with_index do |animation_frame, i|
      animation_frame[:index] = i
      animation_frame[:rt_name] = "animation_frame_#{i}"
    end
  end

  def process_queue_create_sprite
    sprites_to_create = queues.create_sprite
                              .find_all { |h| h[:at].elapsed? }

    queues.create_sprite = queues.create_sprite - sprites_to_create

    sprites_to_create.each do |h|
      export_animation_frame h[:index], h[:path_override]
    end
  end

  def process_queue_reset_sprite
    sprites_to_reset = queues.reset_sprite
                             .find_all { |h| h[:at].elapsed? }

    queues.reset_sprite -= sprites_to_reset

    sprites_to_reset.each { |h| gtk.reset_sprite (sprite_path h[:index]) }
  end

  def process_queue_update_rt_animation_frame
    animation_frames_to_update = queues.update_rt_animation_frame
                                       .find_all { |h| h[:at].elapsed? }

    queues.update_rt_animation_frame -= animation_frames_to_update

    animation_frames_to_update.each do |h|
      update_animation_frame_render_target animation_frames[h[:index]]

      if h[:queue_sprite_creation]
        queues.create_sprite << { index: h[:index],
                                  at: state.tick_count + 1 }
      end
    end
  end

  def update_animation_frame_render_target animation_frame
    return if !animation_frame

    outputs[animation_frame[:rt_name]].width   = state.rt_canvas.size
    outputs[animation_frame[:rt_name]].height  = state.rt_canvas.size
    outputs[animation_frame[:rt_name]].solids << animation_frame[:pixels].map do |f|
      { x: f.x,
        y: f.y,
        w: 1,
        h: 1, r: 255, g: 255, b: 255 }
    end
  end

  def animation_frames
    state.animation_frames
  end

  def add_animation_frame_to_end
    animation_frames << {
      index: animation_frames.length,
      pixels: [],
      rt_name: "animation_frame_#{animation_frames.length}"
    }

    state.animation_frames_selected_index = (animation_frames.length - 1)
    queues.update_rt_animation_frame << { index: state.animation_frames_selected_index,
                                          at: state.tick_count,
                                          queue_sprite_creation: true }
  end

  def sprite_path i
    "canvas/sprite-#{i}.png"
  end

  def export_animation_frame i, path_override = nil
    return if !state.animation_frames[i]

    outputs.screenshots << state.buttons_frame_selection
                                .items[i][:inner_rect]
                                .merge(path: path_override || (sprite_path i))

    outputs.screenshots << state.buttons_frame_selection
                                .items[i][:inner_rect]
                                .merge(path: "tmp/sprite_backups/#{Time.now.to_i}-sprite-#{i}.png")

    queues.reset_sprite << { index: i, at: state.tick_count }
  end

  def selected_animation_frame
    state.animation_frames[state.animation_frames_selected_index]
  end

  def edit_current_animation_frame point
    draw_area_point = (to_draw_area point)
    if state.edit_mode == :drawing && (!selected_animation_frame[:pixels].include? draw_area_point)
      selected_animation_frame[:pixels] << draw_area_point
      queues.update_rt_animation_frame << { index: state.animation_frames_selected_index,
                                            at: state.tick_count,
                                            queue_sprite_creation: !user_is_editing? }
    elsif state.edit_mode == :erasing && (selected_animation_frame[:pixels].include? draw_area_point)
      selected_animation_frame[:pixels] = selected_animation_frame[:pixels].reject { |p| p == draw_area_point }
      queues.update_rt_animation_frame << { index: state.animation_frames_selected_index,
                                            at: state.tick_count,
                                            queue_sprite_creation: !user_is_editing? }
    end
  end

  def user_is_editing?
    state.last_mouse_down > state.last_mouse_up
  end

  def to_draw_area point
    x, y = point
    x -= rt_canvas.sprite.x
    y -= rt_canvas.sprite.y
    { x: x.idiv(rt_canvas.zoom),
      y: y.idiv(rt_canvas.zoom) }
  end

  def rt_canvas
    state.rt_canvas ||= state.new_entity(:rt_canvas)
  end

  def queues
    state.queues ||= state.new_entity(:queues)
  end
end

$game = OneBitLowrezPaint.new

def tick args
  $game.args = args
  $game.tick
end

# $gtk.reset
