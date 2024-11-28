def tick args
  defaults args
  tick_audio args
  tick_calibration args

  if Kernel.tick_count > args.state.start_playing_on_tick
    args.state.beat_accumulator += args.state.beats_per_tick
    args.state.quarter_beat = args.state.beat_accumulator.to_i
    args.state.previous_quarter_beat ||= args.state.quarter_beat
  end

  if args.state.previous_quarter_beat != args.state.quarter_beat
    args.state.previous_quarter_beat_at = args.state.quarter_beat
    args.state.quarter_beat_occurred_at = Kernel.tick_count
  end

  if (Kernel.tick_count - args.state.quarter_beat_occurred_at + args.state.calibration_ticks).abs == 0
    args.state.fx_queue << { x: 640,
                             y: 360,
                             w: 100,
                             h: 100,
                             r: 255,
                             anchor_x: 0.5,
                             anchor_y: 0.5,
                             g: 0,
                             b: 0,
                             a: 255,
                             path: :solid }

    args.state.fx_queue << { x: 640,
                             y: 360,
                             w: 100,
                             h: 100,
                             r: 255,
                             anchor_x: 0.5,
                             anchor_y: 0.5,
                             g: 0,
                             b: 0,
                             a: 255,
                             d_size: 20,
                             path: :solid }
  end

  if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.a
    input_diff = (Kernel.tick_count - args.state.quarter_beat_occurred_at + args.state.calibration_ticks)
    if input_diff.abs <= 1
      args.state.label_fx_queue << { x: 640,
                                     y: 360,
                                     anchor_x: 0.5,
                                     anchor_y: 0.5,
                                     text: "perfect! (#{input_diff})" }
    elsif input_diff.abs <= 3
      args.state.label_fx_queue << { x: 640,
                                     y: 360,
                                     anchor_x: 0.5,
                                     anchor_y: 0.5,
                                     text: "great! (#{input_diff})" }
    elsif input_diff.abs <= 5
      args.state.label_fx_queue << { x: 640,
                                     y: 360,
                                     anchor_x: 0.5,
                                     anchor_y: 0.5,
                                     text: "okay... (#{input_diff})" }
    else
      args.state.label_fx_queue << { x: 640,
                                     y: 360,
                                     anchor_x: 0.5,
                                     anchor_y: 0.5,
                                     text: "bad :-( (#{input_diff})" }
    end
  end

  calc_fx_queues args
  render args
end

def defaults args
  args.state.track_length_in_ticks     ||= 2057
  args.state.main_track                ||= :track_1
  args.state.other_track               ||= :track_2
  args.state.fx_queue                  ||= []
  args.state.label_fx_queue            ||= []
  args.state.play_head                 ||= 0
  args.state.start_playing_on_tick     ||= 180
  args.state.beats_per_minute          ||= 140
  args.state.beats_per_second          ||= args.state.beats_per_minute / 60.0
  args.state.beats_per_tick            ||= args.state.beats_per_second / 60.0
  args.state.beat_accumulator          ||= 0
  args.state.quarter_beat              ||= 0
  args.state.calibration_ticks         ||= 0
  args.state.quarter_beat_interval     ||= 1.fdiv(args.state.beats_per_tick).to_i
  args.state.quarter_beat_inputs       ||= 0
  args.state.quarter_beat_diff_history ||= []
end

def tick_audio args
  return if Kernel.tick_count < args.state.start_playing_on_tick

  # start up audio
  args.audio[:track_1] ||= {
    input: "sounds/music.ogg",
    gain: 1.0,
    looping: false
  }

  args.audio[:track_2] ||= {
    input: "sounds/music.ogg",
    looping: false,
    gain: 0.0
  }

  # play head increment every tick
  args.state.play_head += 1
  args.state.play_head = args.state.play_head % args.state.track_length_in_ticks

  # every 10 seconds, cross fade
  if args.state.play_head.zmod?(600) && Kernel.tick_count > args.state.start_playing_on_tick
    if args.state.main_track == :track_1
      args.state.main_track = :track_2
      args.state.other_track = :track_1
    else
      args.state.main_track = :track_1
      args.state.other_track = :track_2
    end

    if args.audio[args.state.main_track]
      args.audio[args.state.main_track].playtime = args.state.play_head.idiv(60)
    end
  end

  # perform cross fade
  if args.audio[args.state.main_track]
    args.audio[args.state.main_track].gain += 0.1
    args.audio[args.state.main_track].gain = 1.0 if args.audio[args.state.main_track].gain > 1.0
  end

  if args.audio[args.state.other_track]
    args.audio[args.state.other_track].gain -= 0.1
    args.audio[args.state.other_track].gain = 0.0 if args.audio[args.state.other_track].gain < 0.0
  end
end

def tick_calibration args
  if args.inputs.keyboard.key_down.up || args.inputs.controller_one.key_down.up
    args.state.calibration_ticks += 1
  elsif args.inputs.keyboard.key_down.down || args.inputs.controller_one.key_down.down
    args.state.calibration_ticks -= 1
  end

  if args.inputs.keyboard.key_down.m || args.inputs.controller_one.key_down.b
    args.state.player_beat_at = Kernel.tick_count
  else
    args.state.player_beat_at = nil
  end

  if args.state.player_beat_at && args.state.quarter_beat_occurred_at
    diff = args.state.player_beat_at - args.state.quarter_beat_occurred_at
    description = if (diff + args.state.calibration_ticks) < 0
                    "early: increase calibration value"
                  elsif (diff + args.state.calibration_ticks) > 0
                    "late:  decrease calibration value"
                  else
                    "perfect"
                  end

    quarter_beat_diff = { diff: (diff + args.state.calibration_ticks), description: description }
    args.state.quarter_beat_diff_history.unshift quarter_beat_diff.copy
    if args.state.quarter_beat_diff_history.length > 20
      args.state.quarter_beat_diff_history = args.state.quarter_beat_diff_history.take 20
    end
  end
end

def calc_fx_queues args
  args.state.fx_queue.each do |fx|
    fx.at ||= Kernel.tick_count
    fx.d_size ||= 0
    fx.w += fx.d_size
    fx.h += fx.d_size
  end

  args.state.fx_queue.reject! { |fx| fx.at.elapsed_time > 5 }

  args.state.label_fx_queue.each do |fx|
    fx.at ||= Kernel.tick_count
    fx.a  ||= 255
    fx.y    = fx.y.lerp(540, 0.1)
    fx.a   -= 5
  end

  args.state.label_fx_queue.reject! { |fx| fx.a <= 0 }
end

def render args
  if Kernel.tick_count < args.state.start_playing_on_tick
    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "Count down: #{(args.state.start_playing_on_tick - Kernel.tick_count).idiv(60) + 1}",
                             anchor_x: 0.5,
                             anchor_y: 0.5 }
  end

  args.outputs.borders << { x: 640, y: 360, w: 100, h: 100,
                            anchor_x: 0.5, anchor_y: 0.5,
                            r: 255, g: 0, b: 0, a: 255 }

  args.outputs.primitives << args.state.fx_queue
  args.outputs.primitives << args.state.label_fx_queue
  args.state.previous_quarter_beat = args.state.quarter_beat

  args.outputs.debug.watch "Instructions: Close your eyes and listen to the beat and press 'M' (or 'B' on your controller) when you hear a quarter beat."
  args.outputs.debug.watch "              Press 'UP' or 'DOWN' to adjust calibration_ticks."
  args.outputs.debug.watch "              Press 'SPACE' (or 'A' on your controller) on quarter beats to test calibration."

  if args.audio[:track_1] && args.audio[:track_2]
    args.outputs.debug.watch "track_1 gain: #{args.audio[:track_1].gain.to_sf}"
    args.outputs.debug.watch "track_2 gain: #{args.audio[:track_2].gain.to_sf}"
  end

  args.outputs.debug.watch "beat accumulator: #{args.state.beat_accumulator.to_sf}"
  args.outputs.debug.watch "quarter beat: #{args.state.quarter_beat}"
  args.outputs.debug.watch "calibration_ticks: #{args.state.calibration_ticks.to_i}"
  args.state.quarter_beat_diff_history.each do |item|
    if item.diff >= 0
      args.outputs.debug.watch "+#{item.diff.to_sf} #{item.description}"
    elsif item.diff < 0
      args.outputs.debug.watch "#{item.diff.to_sf} #{item.description}"
    end
  end
end
