def tick args
  defaults args
  render args
  input args
  process_audio_queue args
end

def defaults args
  args.state.sine_waves  ||= {}
  args.state.audio_queue ||= []
  args.state.buttons     ||= [
    (frequency_buttons args),
    (note_buttons args),
    (bell_buttons args)
  ].flatten
end

def frequency_buttons args
  [
    (button args,
            row: 4.0, col: 0, text: "300hz",
            frequency: 300,
            method_to_call: :play_sine_wave),
    (button args,
            row: 5.0, col: 0, text: "400hz",
            frequency: 400,
            method_to_call: :play_sine_wave),
    (button args,
            row: 6.0, col: 0, text: "500hz",
            frequency: 500,
            method_to_call: :play_sine_wave),
  ]
end

def play_sine_wave args, sender
  queue_sine_wave args,
                  frequency: sender[:frequency],
                  duration: 1.seconds,
                  fade_out: true
end


def note_buttons args
  [
    (button args,
            row: 1.5, col: 3, text: "C4",
            note: :c, octave: 4, method_to_call: :play_note),
    (button args,
            row: 2.5, col: 3, text: "D4",
            note: :d, octave: 4, method_to_call: :play_note),
    (button args,
            row: 3.5, col: 3, text: "E4",
            note: :e, octave: 4, method_to_call: :play_note),
    (button args,
            row: 4.5, col: 3, text: "F4",
            note: :f, octave: 4, method_to_call: :play_note),
    (button args,
            row: 5.5, col: 3, text: "G4",
            note: :g, octave: 4, method_to_call: :play_note),
    (button args,
            row: 6.5, col: 3, text: "A5",
            note: :a, octave: 5, method_to_call: :play_note),
    (button args,
            row: 7.5, col: 3, text: "B5",
            note: :b, octave: 5, method_to_call: :play_note),
    (button args,
            row: 8.5, col: 3, text: "C5",
            note: :c, octave: 5, method_to_call: :play_note),
  ]
end

def play_note args, sender
  queue_sine_wave args,
                  frequency: (frequency_for note:   sender[:note],
                                            octave: sender[:octave]),
                  duration: 1.seconds,
                  fade_out: true
end

def bell_buttons args
  [
    (button args,
            row: 1.5, col: 6, text: "Bell C4",
            note: :c, octave: 4, method_to_call: :play_bell),
    (button args,
            row: 2.5, col: 6, text: "Bell D4",
            note: :d, octave: 4, method_to_call: :play_bell),
    (button args,
            row: 3.5, col: 6, text: "Bell E4",
            note: :e, octave: 4, method_to_call: :play_bell),
    (button args,
            row: 4.5, col: 6, text: "Bell F4",
            note: :f, octave: 4, method_to_call: :play_bell),
    (button args,
            row: 5.5, col: 6, text: "Bell G4",
            note: :g, octave: 4, method_to_call: :play_bell),
    (button args,
            row: 6.5, col: 6, text: "Bell A5",
            note: :a, octave: 5, method_to_call: :play_bell),
    (button args,
            row: 7.5, col: 6, text: "Bell B5",
            note: :b, octave: 5, method_to_call: :play_bell),
    (button args,
            row: 8.5, col: 6, text: "Bell C5",
            note: :c, octave: 5, method_to_call: :play_bell),
  ]
end

def play_bell args, sender
  queue_bell args,
             frequency: (frequency_for note:   sender[:note],
                                       octave: sender[:octave]),
             duration: 2.seconds,
             fade_out: true
end

def render args
  args.outputs.borders << args.state.buttons.map { |b| b[:border] }
  args.outputs.labels  << args.state.buttons.map { |b| b[:label]  }
  args.outputs.labels  << args.layout
                              .rect(row: 0,
                                    col: 11.5)
                              .yield_self { |r| r.merge y: r.y + r.h }
                              .merge(text: "This is a Pro only feature. Click here to watch the YouTube video if you are on the Standard License.",
                                     alignment_enum: 1)
end

def input args
  args.state.buttons.each do |b|
    if args.inputs.mouse.click.inside_rect? b[:rect]
      parameter_string = (b.slice :frequency, :note, :octave).map { |k, v| "#{k}: #{v}" }.join ", "
      args.gtk.notify! "#{b[:method_to_call]} #{parameter_string}"
      send b[:method_to_call], args, b
    end
  end

  if args.inputs.mouse.click.inside_rect? (args.layout.rect(row: 0).yield_self { |r| r.merge y: r.y + r.h.half, h: r.h.half })
    args.gtk.openurl 'https://www.youtube.com/watch?v=zEzovM5jT-k&ab_channel=AmirRajan'
  end
end

def process_audio_queue args
  to_queue = args.state.audio_queue.find_all { |v| v[:queue_at] <= args.tick_count }
  args.state.audio_queue -= to_queue

  to_queue.each do |a|
    args.audio[a[:id]] = a
  end

  args.audio.each do |k, v|
    if v[:decay_rate]
      v[:gain] -= v[:decay_rate]
    end
  end

  sounds_to_stop = args.audio.find_all do |k, v|
    v[:stop_at] && args.state.tick_count >= v[:stop_at]
  end

  sounds_to_stop.each do |(k, v)|
    args.audio.delete k
  end
end

def graph_sine_wave args, sine_wave, frequency
  if args.state.tick_count != args.state.graphed_at
    args.outputs.static_lines.clear
    args.outputs.static_sprites.clear
  end

  r, g, b = frequency.to_i % 80, frequency.to_i % 128, frequency.to_i % 255
  center_row = args.layout.rect(row: 5, col: 9)
  x_scale    = 20
  y_scale    = 100
  max_points = 20

  points = sine_wave
  if sine_wave.length > max_points
    resolution = sine_wave.length.idiv max_points
    points = sine_wave.find_all
                      .with_index { |y, i| i % resolution == 0 }
  end

  args.outputs.static_lines << points.map_with_index do |y, x|
    next_y = points[x + 1]

    if next_y
      {
        x:  center_row.x + (x * x_scale),
        y:  center_row.y + center_row.h.half + y_scale * y,
        x2: center_row.x + ((x + 1) * x_scale),
        y2: center_row.y + center_row.h.half + y_scale * next_y,
        r:  r,
        g:  g,
        b:  b
      }
    end
  end

  args.outputs.static_sprites << points.map_with_index do |y, x|
    {
      x:  (center_row.x + (x * x_scale)) - 1,
      y:  (center_row.y + center_row.h.half + y_scale * y) - 1,
      w:  2,
      h:  2,
      path: 'sprites/square-black.png'
    }
  end

  args.state.graphed_at = args.state.tick_count
end

def defaults_period_sine_wave_for
  { frequency: 440, sample_rate: 48000 }
end

def sine_wave_for opts = { }
  opts = defaults_period_sine_wave_for.merge opts
  frequency   = opts[:frequency]
  sample_rate = opts[:sample_rate]
  period_size = (sample_rate.fdiv frequency).ceil
  period_size.map_with_index do |i|
    Math::sin((2.0 * Math::PI) / (sample_rate.to_f / frequency.to_f) * i)
  end.to_a
end

def generate_audio_data sine_wave, sample_rate
  sample_size = (sample_rate.fdiv (1000.fdiv 60)).ceil
  copy_count  = (sample_size.fdiv sine_wave.length).ceil
  sine_wave * copy_count
end

def defaults_queue_sine_wave
  { frequency: 440, duration: 60, gain: 1.0, fade_out: false, queue_in: 0 }
end

def queue_sine_wave args, opts = { }
  opts        = defaults_queue_sine_wave.merge opts
  decay_rate  = 0
  decay_rate  = 1.fdiv(opts[:duration]) * opts[:gain] if opts[:fade_out]
  frequency   = opts[:frequency]
  sample_rate = 48000

  audio_state = {
    id:               (new_id! args),
    frequency:        frequency,
    sample_rate:      48000,
    stop_at:          args.tick_count + opts[:queue_in] + opts[:duration],
    gain:             opts[:gain].to_f,
    queue_at:         args.state.tick_count + opts[:queue_in],
    decay_rate:       decay_rate,
    pitch:            1.0,
    looping:          true,
    paused:           false
  }

  sine_wave = sine_wave_for frequency: frequency, sample_rate: sample_rate
  args.state.sine_waves[frequency] ||= sine_wave_for frequency: frequency, sample_rate: sample_rate

  proc = lambda do
    generate_audio_data args.state.sine_waves[frequency], sample_rate
  end

  audio_state[:input] = [1, sample_rate, proc]
  graph_sine_wave args, sine_wave, frequency
  args.state.audio_queue << audio_state
end

def defaults_queue_bell
  { frequency: 440, duration: 1.seconds, queue_in: 0 }
end

def queue_bell args, opts = {}
  (bell_to_sine_waves (defaults_queue_bell.merge opts)).each { |b| queue_sine_wave args, b }
end

def bell_harmonics
  [
    { frequency_ratio: 0.5, duration_ratio: 1.00 },
    { frequency_ratio: 1.0, duration_ratio: 0.80 },
    { frequency_ratio: 2.0, duration_ratio: 0.60 },
    { frequency_ratio: 3.0, duration_ratio: 0.40 },
    { frequency_ratio: 4.2, duration_ratio: 0.25 },
    { frequency_ratio: 5.4, duration_ratio: 0.20 },
    { frequency_ratio: 6.8, duration_ratio: 0.15 }
  ]
end

def bell_to_sine_waves opts
  bell_harmonics.map do |b|
    {
      frequency: opts[:frequency] * b[:frequency_ratio],
      duration:  opts[:duration] * b[:duration_ratio],
      queue_in:  opts[:queue_in],
      gain:      (1.fdiv bell_harmonics.length),
      fade_out:  true
    }
  end
end

def defaults_frequency_for
  { note: :a, octave: 5, sharp:  false, flat:   false }
end

def frequency_for opts = {}
  opts = defaults_frequency_for.merge opts
  octave_offset_multiplier  = opts[:octave] - 5
  note = note_frequencies_octave_5[opts[:note]]
  if octave_offset_multiplier < 0
    note = note * 1 / (octave_offset_multiplier.abs + 1)
  elsif octave_offset_multiplier > 0
    note = note * (octave_offset_multiplier.abs + 1) / 1
  end
  note
end

def note_frequencies_octave_5
  {
    a: 440.0,
    a_sharp: 466.16, b_flat: 466.16,
    b: 493.88,
    c: 523.25,
    c_sharp: 554.37, d_flat: 587.33,
    d: 587.33,
    d_sharp: 622.25, e_flat: 659.25,
    e: 659.25,
    f: 698.25,
    f_sharp: 739.99, g_flat: 739.99,
    g: 783.99,
    g_sharp: 830.61, a_flat: 830.61
  }
end

def new_id! args
  args.state.audio_id ||= 0
  args.state.audio_id  += 1
end

def button args, opts
  button_def = opts.merge rect: (args.layout.rect (opts.merge w: 2, h: 1))

  button_def[:border] = button_def[:rect].merge r: 0, g: 0, b: 0

  font_size_enum = args.layout.font_relative_size_enum 0
  label_offset_x = 4
  label_offset_y = button_def[:rect].h.half + button_def[:rect].h.idiv(4)

  button_def[:label]  = button_def[:rect].merge text: opts[:text],
                                                size_enum: font_size_enum,
                                                x: button_def[:rect].x + label_offset_x,
                                                y: button_def[:rect].y + label_offset_y

  button_def
end

$gtk.reset
