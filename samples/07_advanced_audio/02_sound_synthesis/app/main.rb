begin # region: top level tick methods
  def tick args
    defaults args
    render args
    input args
    process_audio_queue args
  end

  def defaults args
    args.state.sine_waves      ||= {}
    args.state.square_waves    ||= {}
    args.state.saw_tooth_waves ||= {}
    args.state.triangle_waves  ||= {}
    args.state.audio_queue     ||= []
    args.state.buttons         ||= [
      (frequency_buttons args),
      (sine_wave_note_buttons args),
      (bell_buttons args),
      (square_wave_note_buttons args),
      (saw_tooth_wave_note_buttons args),
      (triangle_wave_note_buttons args),
    ].flatten
  end

  def render args
    args.outputs.borders << args.state.buttons.map { |b| b[:border] }
    args.outputs.labels  << args.state.buttons.map { |b| b[:label]  }
    args.outputs.labels  << args.layout
                              .rect(row: 0, col: 11.5)
                              .yield_self { |r| r.merge y: r.y + r.h }
                              .merge(text: "This is a Pro only feature. Click here to watch the YouTube video if you are on the Standard License.",
                                     alignment_enum: 1)
  end


  def input args
    args.state.buttons.each do |b|
      if args.inputs.mouse.click && (args.inputs.mouse.click.inside_rect? b[:rect])
        parameter_string = (b.slice :frequency, :note, :octave).map { |k, v| "#{k}: #{v}" }.join ", "
        args.gtk.notify! "#{b[:method_to_call]} #{parameter_string}"
        send b[:method_to_call], args, b
      end
    end

    if args.inputs.mouse.click && (args.inputs.mouse.click.inside_rect? (args.layout.rect(row: 0).yield_self { |r| r.merge y: r.y + r.h.half, h: r.h.half }))
      args.gtk.openurl 'https://www.youtube.com/watch?v=zEzovM5jT-k&ab_channel=AmirRajan'
    end
  end

  def process_audio_queue args
    to_queue = args.state.audio_queue.find_all { |v| v[:queue_at] <= args.tick_count }
    args.state.audio_queue -= to_queue
    to_queue.each { |a| args.audio[a[:id]] = a }

    args.audio.find_all { |k, v| v[:decay_rate] }
      .each     { |k, v| v[:gain] -= v[:decay_rate] }

    sounds_to_stop = args.audio
                       .find_all { |k, v| v[:stop_at] && args.state.tick_count >= v[:stop_at] }
                       .map { |k, v| k }

    sounds_to_stop.each { |k| args.audio.delete k }
  end
end

begin # region: button definitions, ui layout, callback functions
  def button args, opts
    button_def = opts.merge rect: (args.layout.rect (opts.merge w: 2, h: 1))

    button_def[:border] = button_def[:rect].merge r: 0, g: 0, b: 0

    label_offset_x = 5
    label_offset_y = 30

    button_def[:label]  = button_def[:rect].merge text: opts[:text],
                                                  size_enum: -2.5,
                                                  x: button_def[:rect].x + label_offset_x,
                                                  y: button_def[:rect].y + label_offset_y

    button_def
  end

  def play_sine_wave args, sender
    queue_sine_wave args,
                    frequency: sender[:frequency],
                    duration: 1.seconds,
                    fade_out: true
  end

  def play_note args, sender
    method_to_call = :queue_sine_wave
    method_to_call = :queue_square_wave    if sender[:type] == :square
    method_to_call = :queue_saw_tooth_wave if sender[:type] == :saw_tooth
    method_to_call = :queue_triangle_wave  if sender[:type] == :triangle
    method_to_call = :queue_bell           if sender[:type] == :bell

    send method_to_call, args,
         frequency: (frequency_for note: sender[:note], octave: sender[:octave]),
         duration: 1.seconds,
         fade_out: true
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

  def sine_wave_note_buttons args
    [
      (button args,
              row: 1.5, col: 2, text: "Sine C4",
              note: :c, octave: 4, type: :sine, method_to_call: :play_note),
      (button args,
              row: 2.5, col: 2, text: "Sine D4",
              note: :d, octave: 4, type: :sine, method_to_call: :play_note),
      (button args,
              row: 3.5, col: 2, text: "Sine E4",
              note: :e, octave: 4, type: :sine, method_to_call: :play_note),
      (button args,
              row: 4.5, col: 2, text: "Sine F4",
              note: :f, octave: 4, type: :sine, method_to_call: :play_note),
      (button args,
              row: 5.5, col: 2, text: "Sine G4",
              note: :g, octave: 4, type: :sine, method_to_call: :play_note),
      (button args,
              row: 6.5, col: 2, text: "Sine A5",
              note: :a, octave: 5, type: :sine, method_to_call: :play_note),
      (button args,
              row: 7.5, col: 2, text: "Sine B5",
              note: :b, octave: 5, type: :sine, method_to_call: :play_note),
      (button args,
              row: 8.5, col: 2, text: "Sine C5",
              note: :c, octave: 5, type: :sine, method_to_call: :play_note),
    ]
  end

  def square_wave_note_buttons args
    [
      (button args,
              row: 1.5, col: 6, text: "Square C4",
              note: :c, octave: 4, type: :square, method_to_call: :play_note),
      (button args,
              row: 2.5, col: 6, text: "Square D4",
              note: :d, octave: 4, type: :square, method_to_call: :play_note),
      (button args,
              row: 3.5, col: 6, text: "Square E4",
              note: :e, octave: 4, type: :square, method_to_call: :play_note),
      (button args,
              row: 4.5, col: 6, text: "Square F4",
              note: :f, octave: 4, type: :square, method_to_call: :play_note),
      (button args,
              row: 5.5, col: 6, text: "Square G4",
              note: :g, octave: 4, type: :square, method_to_call: :play_note),
      (button args,
              row: 6.5, col: 6, text: "Square A5",
              note: :a, octave: 5, type: :square, method_to_call: :play_note),
      (button args,
              row: 7.5, col: 6, text: "Square B5",
              note: :b, octave: 5, type: :square, method_to_call: :play_note),
      (button args,
              row: 8.5, col: 6, text: "Square C5",
              note: :c, octave: 5, type: :square, method_to_call: :play_note),
    ]
  end
  def saw_tooth_wave_note_buttons args
    [
      (button args,
              row: 1.5, col: 8, text: "Saw C4",
              note: :c, octave: 4, type: :saw_tooth, method_to_call: :play_note),
      (button args,
              row: 2.5, col: 8, text: "Saw D4",
              note: :d, octave: 4, type: :saw_tooth, method_to_call: :play_note),
      (button args,
              row: 3.5, col: 8, text: "Saw E4",
              note: :e, octave: 4, type: :saw_tooth, method_to_call: :play_note),
      (button args,
              row: 4.5, col: 8, text: "Saw F4",
              note: :f, octave: 4, type: :saw_tooth, method_to_call: :play_note),
      (button args,
              row: 5.5, col: 8, text: "Saw G4",
              note: :g, octave: 4, type: :saw_tooth, method_to_call: :play_note),
      (button args,
              row: 6.5, col: 8, text: "Saw A5",
              note: :a, octave: 5, type: :saw_tooth, method_to_call: :play_note),
      (button args,
              row: 7.5, col: 8, text: "Saw B5",
              note: :b, octave: 5, type: :saw_tooth, method_to_call: :play_note),
      (button args,
              row: 8.5, col: 8, text: "Saw C5",
              note: :c, octave: 5, type: :saw_tooth, method_to_call: :play_note),
    ]
  end

  def triangle_wave_note_buttons args
    [
      (button args,
              row: 1.5, col: 10, text: "Triangle C4",
              note: :c, octave: 4, type: :triangle, method_to_call: :play_note),
      (button args,
              row: 2.5, col: 10, text: "Triangle D4",
              note: :d, octave: 4, type: :triangle, method_to_call: :play_note),
      (button args,
              row: 3.5, col: 10, text: "Triangle E4",
              note: :e, octave: 4, type: :triangle, method_to_call: :play_note),
      (button args,
              row: 4.5, col: 10, text: "Triangle F4",
              note: :f, octave: 4, type: :triangle, method_to_call: :play_note),
      (button args,
              row: 5.5, col: 10, text: "Triangle G4",
              note: :g, octave: 4, type: :triangle, method_to_call: :play_note),
      (button args,
              row: 6.5, col: 10, text: "Triangle A5",
              note: :a, octave: 5, type: :triangle, method_to_call: :play_note),
      (button args,
              row: 7.5, col: 10, text: "Triangle B5",
              note: :b, octave: 5, type: :triangle, method_to_call: :play_note),
      (button args,
              row: 8.5, col: 10, text: "Triangle C5",
              note: :c, octave: 5, type: :triangle, method_to_call: :play_note),
    ]
  end

  def bell_buttons args
    [
      (button args,
              row: 1.5, col: 4, text: "Bell C4",
              note: :c, octave: 4, type: :bell, method_to_call: :play_note),
      (button args,
              row: 2.5, col: 4, text: "Bell D4",
              note: :d, octave: 4, type: :bell, method_to_call: :play_note),
      (button args,
              row: 3.5, col: 4, text: "Bell E4",
              note: :e, octave: 4, type: :bell, method_to_call: :play_note),
      (button args,
              row: 4.5, col: 4, text: "Bell F4",
              note: :f, octave: 4, type: :bell, method_to_call: :play_note),
      (button args,
              row: 5.5, col: 4, text: "Bell G4",
              note: :g, octave: 4, type: :bell, method_to_call: :play_note),
      (button args,
              row: 6.5, col: 4, text: "Bell A5",
              note: :a, octave: 5, type: :bell, method_to_call: :play_note),
      (button args,
              row: 7.5, col: 4, text: "Bell B5",
              note: :b, octave: 5, type: :bell, method_to_call: :play_note),
      (button args,
              row: 8.5, col: 4, text: "Bell C5",
              note: :c, octave: 5, type: :bell, method_to_call: :play_note),
    ]
  end
end

begin # region: wave generation
  begin # sine wave
    def defaults_sine_wave_for
      { frequency: 440, sample_rate: 48000 }
    end

    def sine_wave_for opts = {}
      opts = defaults_sine_wave_for.merge opts
      frequency   = opts[:frequency]
      sample_rate = opts[:sample_rate]
      period_size = (sample_rate.fdiv frequency).ceil
      period_size.map_with_index do |i|
        Math::sin((2.0 * Math::PI) / (sample_rate.to_f / frequency.to_f) * i)
      end.to_a
    end

    def defaults_queue_sine_wave
      { frequency: 440, duration: 60, gain: 1.0, fade_out: false, queue_in: 0 }
    end

    def queue_sine_wave args, opts = {}
      opts        = defaults_queue_sine_wave.merge opts
      frequency   = opts[:frequency]
      sample_rate = 48000

      sine_wave = sine_wave_for frequency: frequency, sample_rate: sample_rate
      args.state.sine_waves[frequency] ||= sine_wave_for frequency: frequency, sample_rate: sample_rate

      proc = lambda do
        generate_audio_data args.state.sine_waves[frequency], sample_rate
      end

      audio_state = new_audio_state args, opts
      audio_state[:input] = [1, sample_rate, proc]
      queue_audio args, audio_state: audio_state, wave: sine_wave
    end
  end

  begin # region: square wave
    def defaults_square_wave_for
      { frequency: 440, sample_rate: 48000 }
    end

    def square_wave_for opts = {}
      opts = defaults_square_wave_for.merge opts
      sine_wave = sine_wave_for opts
      sine_wave.map do |v|
        if v >= 0
          1.0
        else
          -1.0
        end
      end.to_a
    end

    def defaults_queue_square_wave
      { frequency: 440, duration: 60, gain: 0.3, fade_out: false, queue_in: 0 }
    end

    def queue_square_wave args, opts = {}
      opts        = defaults_queue_square_wave.merge opts
      frequency   = opts[:frequency]
      sample_rate = 48000

      square_wave = square_wave_for frequency: frequency, sample_rate: sample_rate
      args.state.square_waves[frequency] ||= square_wave_for frequency: frequency, sample_rate: sample_rate

      proc = lambda do
        generate_audio_data args.state.square_waves[frequency], sample_rate
      end

      audio_state = new_audio_state args, opts
      audio_state[:input] = [1, sample_rate, proc]
      queue_audio args, audio_state: audio_state, wave: square_wave
    end
  end

  begin # region: saw tooth wave
    def defaults_saw_tooth_wave_for
      { frequency: 440, sample_rate: 48000 }
    end

    def saw_tooth_wave_for opts = {}
      opts = defaults_saw_tooth_wave_for.merge opts
      sine_wave = sine_wave_for opts
      period_size = sine_wave.length
      sine_wave.map_with_index do |v, i|
        (((i % period_size).fdiv period_size) * 2) - 1
      end
    end

    def defaults_queue_saw_tooth_wave
      { frequency: 440, duration: 60, gain: 0.3, fade_out: false, queue_in: 0 }
    end

    def queue_saw_tooth_wave args, opts = {}
      opts        = defaults_queue_saw_tooth_wave.merge opts
      frequency   = opts[:frequency]
      sample_rate = 48000

      saw_tooth_wave = saw_tooth_wave_for frequency: frequency, sample_rate: sample_rate
      args.state.saw_tooth_waves[frequency] ||= saw_tooth_wave_for frequency: frequency, sample_rate: sample_rate

      proc = lambda do
        generate_audio_data args.state.saw_tooth_waves[frequency], sample_rate
      end

      audio_state = new_audio_state args, opts
      audio_state[:input] = [1, sample_rate, proc]
      queue_audio args, audio_state: audio_state, wave: saw_tooth_wave
    end
  end

  begin # region: triangle wave
    def defaults_triangle_wave_for
      { frequency: 440, sample_rate: 48000 }
    end

    def triangle_wave_for opts = {}
      opts = defaults_saw_tooth_wave_for.merge opts
      sine_wave = sine_wave_for opts
      period_size = sine_wave.length
      sine_wave.map_with_index do |v, i|
        ratio = (i.fdiv period_size)
        if ratio <= 0.5
          (ratio * 4) - 1
        else
          ratio -= 0.5
          1 - (ratio * 4)
        end
      end
    end

    def defaults_queue_triangle_wave
      { frequency: 440, duration: 60, gain: 1.0, fade_out: false, queue_in: 0 }
    end

    def queue_triangle_wave args, opts = {}
      opts        = defaults_queue_triangle_wave.merge opts
      frequency   = opts[:frequency]
      sample_rate = 48000

      triangle_wave = triangle_wave_for frequency: frequency, sample_rate: sample_rate
      args.state.triangle_waves[frequency] ||= triangle_wave_for frequency: frequency, sample_rate: sample_rate

      proc = lambda do
        generate_audio_data args.state.triangle_waves[frequency], sample_rate
      end

      audio_state = new_audio_state args, opts
      audio_state[:input] = [1, sample_rate, proc]
      queue_audio args, audio_state: audio_state, wave: triangle_wave
    end
  end

  begin # region: bell
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

    def defaults_bell_to_sine_waves
      { frequency: 440, duration: 1.seconds, queue_in: 0 }
    end

    def bell_to_sine_waves opts = {}
      opts = defaults_bell_to_sine_waves.merge opts
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
  end

  begin # audio entity construction
    def generate_audio_data sine_wave, sample_rate
      sample_size = (sample_rate.fdiv (1000.fdiv 60)).ceil
      copy_count  = (sample_size.fdiv sine_wave.length).ceil
      sine_wave * copy_count
    end

    def defaults_new_audio_state
      { frequency: 440, duration: 60, gain: 1.0, fade_out: false, queue_in: 0 }
    end

    def new_audio_state args, opts = {}
      opts        = defaults_new_audio_state.merge opts
      decay_rate  = 0
      decay_rate  = 1.fdiv(opts[:duration]) * opts[:gain] if opts[:fade_out]
      frequency   = opts[:frequency]
      sample_rate = 48000

      {
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
    end

    def queue_audio args, opts = {}
      graph_wave args, opts[:wave], opts[:audio_state][:frequency]
      args.state.audio_queue << opts[:audio_state]
    end

    def new_id! args
      args.state.audio_id ||= 0
      args.state.audio_id  += 1
    end

    def graph_wave args, wave, frequency
      if args.state.tick_count != args.state.graphed_at
        args.outputs.static_lines.clear
        args.outputs.static_sprites.clear
      end

      wave = wave

      r, g, b = frequency.to_i % 85,
                frequency.to_i % 170,
                frequency.to_i % 255

      starting_rect = args.layout.rect(row: 5, col: 13)
      x_scale    = 10
      y_scale    = 100
      max_points = 25

      points = wave
      if wave.length > max_points
        resolution = wave.length.idiv max_points
        points = wave.find_all.with_index { |y, i| (i % resolution == 0) }
      end

      args.outputs.static_lines << points.map_with_index do |y, x|
        next_y = points[x + 1]

        if next_y
          {
            x:  starting_rect.x + (x * x_scale),
            y:  starting_rect.y + starting_rect.h.half + y_scale * y,
            x2: starting_rect.x + ((x + 1) * x_scale),
            y2: starting_rect.y + starting_rect.h.half + y_scale * next_y,
            r:  r,
            g:  g,
            b:  b
          }
        end
      end

      args.outputs.static_sprites << points.map_with_index do |y, x|
        {
          x:  (starting_rect.x + (x * x_scale)) - 2,
          y:  (starting_rect.y + starting_rect.h.half + y_scale * y) - 2,
          w:  4,
          h:  4,
          path: 'sprites/square-white.png',
          r: r,
          g: g,
          b: b
        }
      end

      args.state.graphed_at = args.state.tick_count
    end
  end

  begin # region: musical note mapping
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
  end
end

$gtk.reset
