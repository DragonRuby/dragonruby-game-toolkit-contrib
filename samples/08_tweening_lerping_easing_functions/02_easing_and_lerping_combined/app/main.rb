def boot args
  args.state = {}
end

def tick args
  # create 100 things and set the seed to a numeric value
  # the seed will be used to create a delay for each thing when the up and down keys are pressed
  args.state.things ||= 220.map do |i|
    x_ordinal = i % 20
    y_ordinal = i.idiv(20)
    {
      seed: i,
      # seed: Numeric.rand(30), # try this as a seed value (cool effect to try out)
      x: 6 + x_ordinal * 64,
      y: 6 + 8 + y_ordinal * 64,
      w: 52,
      h: 52,
      path: :solid,
      r: 80,
      g: 128,
      b: 200,
      a: 255,
      target_a: 255,
      target_a_at: nil
    }
  end

  # change these variable to control how closely the alpha transitions
  # are queued
  args.state.speed_multiplier ||= 1

  # change this variable to control how long the transition takes
  args.state.smooth_stop_duration ||= 15

  if args.inputs.keyboard.key_down.down
    # if down is pressed then queue fade out for each thing
    # schedule the fade out to start at a different time
    # for each thing based on the seed value
    args.state.things.each do |thing|
      thing.target_a = 64
      thing.target_a_at = Kernel.tick_count + thing.seed.idiv(args.state.speed_multiplier) * 2
    end
  elsif args.inputs.keyboard.key_down.up
    # otherwise if up is pressed then queue fade in for each thing
    args.state.things.each do |thing|
      thing.target_a = 255
      thing.target_a_at = Kernel.tick_count + thing.seed.idiv(args.state.speed_multiplier) * 2
    end
  end

  # enumerate each thing and check if it has a target_a_at value.
  # Then use Easing.smooth_stop to calculate the percentage of a.
  # clear out the target_a_at value and set a to the target_a value when the percentage is 1.
  args.state
      .things
      .find_all { |thing| thing.target_a_at }
      .each do |thing|
        perc = Easing.smooth_stop(start_at: thing.target_a_at,
                                  duration: args.state.smooth_stop_duration,
                                  power: 2,
                                  tick_count: Kernel.tick_count)
        thing.a = thing.a.lerp(thing.target_a, perc)
        thing.target_a_at = nil if perc == 1
      end

  args.outputs.background_color = [30, 30, 30]
  args.outputs.primitives << args.state.things
end

DR.reset
