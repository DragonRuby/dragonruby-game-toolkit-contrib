def tick args
  # STOP! Watch the following presentation first!!!!
  # Math for Game Programmers: Fast and Funky 1D Nonlinear Transformations
  # https://www.youtube.com/watch?v=mr5xkf6zSzk

  # You've watched the talk, yes? YES???

  # define starting and ending points of properties to animate
  args.state.target_x = 1180
  args.state.target_y = 620
  args.state.target_w = 100
  args.state.target_h = 100
  args.state.starting_x = 0
  args.state.starting_y = 0
  args.state.starting_w = 300
  args.state.starting_h = 300

  # define start time and duration of animation
  args.state.start_animate_at = 3.seconds # this is the same as writing 60 * 5 (or 300)
  args.state.duration = 2.seconds # this is the same as writing 60 * 2 (or 120)

  # define type of animations
  # Here are all the options you have for values you can put in the array:
  # :identity, :quad, :cube, :quart, :quint, :flip

  # Linear is defined as:
  # [:identity]
  #
  # Smooth start variations are:
  # [:quad]
  # [:cube]
  # [:quart]
  # [:quint]

  # Linear reversed, and smooth stop are the same as the animations defined above, but reversed:
  # [:flip, :identity]
  # [:flip, :quad, :flip]
  # [:flip, :cube, :flip]
  # [:flip, :quart, :flip]
  # [:flip, :quint, :flip]

  # You can also do custom definitions. See the bottom of the file details
  # on how to do that. I've defined a couple for you:
  # [:smoothest_start]
  # [:smoothest_stop]

  # CHANGE THIS LINE TO ONE OF THE LINES ABOVE TO SEE VARIATIONS
  args.state.animation_type = [:identity]
  # args.state.animation_type = [:quad]
  # args.state.animation_type = [:cube]
  # args.state.animation_type = [:quart]
  # args.state.animation_type = [:quint]
  # args.state.animation_type = [:flip, :identity]
  # args.state.animation_type = [:flip, :quad, :flip]
  # args.state.animation_type = [:flip, :cube, :flip]
  # args.state.animation_type = [:flip, :quart, :flip]
  # args.state.animation_type = [:flip, :quint, :flip]
  # args.state.animation_type = [:smoothest_start]
  # args.state.animation_type = [:smoothest_stop]

  # THIS IS WHERE THE MAGIC HAPPENS!
  # Numeric#ease
  progress = args.state.start_animate_at.ease(args.state.duration, args.state.animation_type)

  # Numeric#ease needs to called:
  # 1. On the number that represents the point in time you want to start, and takes two parameters:
  #   a. The first parameter is how long the animation should take.
  #   b. The second parameter represents the functions that need to be called.
  #
  # For example, if I wanted an animate to start 3 seconds in, and last for 10 seconds,
  # and I want to animation to start fast and end slow, I would do:
  # (60 * 3).ease(60 * 10, :flip, :quint, :flip)

  #        initial value           delta to the final value
  calc_x = args.state.starting_x + (args.state.target_x - args.state.starting_x) * progress
  calc_y = args.state.starting_y + (args.state.target_y - args.state.starting_y) * progress
  calc_w = args.state.starting_w + (args.state.target_w - args.state.starting_w) * progress
  calc_h = args.state.starting_h + (args.state.target_h - args.state.starting_h) * progress

  args.outputs.solids << [calc_x, calc_y, calc_w, calc_h, 0, 0, 0]

  # count down
  count_down = args.state.start_animate_at - args.state.tick_count
  if count_down > 0
    args.outputs.labels << [640, 375, "Running: #{args.state.animation_type} in...", 3, 1]
    args.outputs.labels << [640, 345, "%.2f" % count_down.fdiv(60), 3, 1]
  elsif progress >= 1
    args.outputs.labels << [640, 360, "Click screen to reset.", 3, 1]
    if args.inputs.click
      $gtk.reset
    end
  end
end

# $gtk.reset

# you can make own variations of animations using this
module Easing
  # you have access to all the built in functions: identity, flip, quad, cube, quart, quint
  def self.smoothest_start x
    quad(quint(x))
  end

  def self.smoothest_stop x
    flip(quad(quint(flip(x))))
  end

  # this is the source for the existing easing functions
  def self.identity x
    x
  end

  def self.flip x
    1 - x
  end

  def self.quad x
    x * x
  end

  def self.cube x
    x * x * x
  end

  def self.quart x
    x * x * x * x * x
  end

  def self.quint x
    x * x * x * x * x * x
  end
end
