# Easing

A set of functions that allow you to determine the current progression of an easing function.

All functions are available globally via `Easing.*`.

```ruby
def tick args
   Easing.function(...)
end
```

?> This YouTube video is a fantastic introduction to easing functions: <https://www.youtube.com/watch?v=mr5xkf6zSzk>

## `spline`

Given a start, current, duration, and multiple 4-point bezier values, this function returns a number on the bezier curve that represents the progress of an easing function.

This example will move a box at a linear speed from 0 to 1280 and then back to 0 using two bezier definitions (represented as an array with four values).

```ruby
def tick args
  start_time = 10
  duration = 300
  spline_definition = [
    [  0, 0.25, 0.75, 1.0],
    [1.0, 0.75, 0.25,   0]
  ]

  current_progress = Easing.spline start_time,
                                   Kernel.tick_count,
                                   duration,
                                   spline_definition

  args.outputs.solids << {
    x: 1280 * current_progress,
    y: 360,
    w: 10,
    h: 10,
    anchor_x: 0.5,
    anchor_y: 0.5
  }
end
```

This example will move a box at quadratic speed from 0 to 1280 and then back (after a small pause).

```ruby
def tick args
  start_time = 10
  duration = 300
  spline_definition = [
    [0.0, 0.0,  0.66, 1.0],
    [1.0, 1.0,  1.0,  1.0],
    [1.0, 0.33, 0.0,  0.0]
  ]

  current_progress = Easing.spline start_time,
                                   Kernel.tick_count,
                                   duration,
                                   spline_definition

  args.outputs.solids << {
    x: 1280 * current_progress,
    y: 360,
    w: 10,
    h: 10,
    anchor_x: 0.5,
    anchor_y: 0.5
  }
end
```

This example will show random labels fading in and fading out over 60 seconds (the same technique can be used to create notifications):

```ruby
def tick args
  args.state.toast_queue ||= []
  args.state.spline_definition = [
    [0.0, 0.0,  0.66, 1.0],
    [1.0, 1.0,  1.0,  1.0],
    [1.0, 0.33, 0.0,  0.0]
  ]
  args.state.spline_duration ||= 60


  if args.inputs.keyboard.key_down.space
    args.state.toast_queue << {
      x: rand(1280),
      y: rand(720),
      at: Kernel.tick_count, text: "message toasted at #{Kernel.tick_count}"
    }
  end

  args.state.toast_queue.each do |t|
    current_progress = Easing.spline t.at,
                                     Kernel.tick_count,
                                     args.state.spline_duration,
                                     args.state.spline_definition

    args.outputs.labels << { x: t.x,
                             y: t.y,
                             text: t.text,
                             anchor_x: 0.5,
                             anchor_y: 0.5,
                             a: current_progress * 255 }
  end

  args.state.toast_queue.reject! { |t| t.at.elapsed_time > args.state.spline_duration }
end

GTK.reset
```

## `smooth_start`

The `smooth_start`, `smooth_stop`, and `smooth_step` functions have the following
invocation variants:

- `Easing.FUNCTION(initial:, final:, perc:, power:, flip:)`
  - `initial`: starting value of the easing function (defaults to `0.0`).
  - `final`: ending value of the easing function (defaults to `1.0`).
  - `perc`: current easing percentage (a value over `1.0` will result in a higher final value).
  - `power`: `1` for linear, `2` for quadratic, `3` for cube, etc (defaults to `1.0`).
  - `flip`: This is an optional parameter (defaults to `false`). If the value is `true` then the resulting percentange is subtracted from `1` (percentage goes from `1` to `0`, instead of `0` to `1`).
- `Easing.FUNCTION(start_at:, end_at:, tick_count:, power:, flip:)`
  - `start_at`: starting tick_count to begin the easing function .
  - `end_at`: ending value of the easing function.
  - `tick_count`: current tick_count (defaults to `Kernel.tick_count`)
  - `power`: `1` for linear, `2` for quadratic, `3` for cube, etc (defaults to `1.0`).
  - `flip`: This is an optional parameter (defaults to `false`). If the value is `true` then the resulting percentange is subtracted from `1` (percentage goes from `1` to `0`, instead of `0` to `1`).
- `Easing.FUNCTION(start_at:, duration:, tick_count:, power:, flip:)`
  - `start_at`: starting tick_count to begin the easing function .
  - `duration`: used to compute `end_at` value.
  - `tick_count`: Current tick_count (defaults to `Kernel.tick_count`)
  - `power`: `1` for linear, `2` for quadratic, `3` for cube, etc (defaults to `1.0`).
  - `flip`: This is an optional parameter (defaults to `false`). If the value is `true` then the resulting percentange is subtracted from `1` (percentage goes from `1` to `0`, instead of `0` to `1`).

Here are examples of using `smooth_start`:

```ruby
def tick args
  args.state.clock ||= 0
  y_perc = Easing.smooth_start(start_at: 0,
                               end_at: 60,
                               tick_count: args.state.clock,
                               power: 5)

  # OR
  # y_perc = Easing.smooth_start(initial: 0,
  #                              final: 1,
  #                              perc: args.state.clock / 60.0,
  #                              power: 5)
  args.outputs.sprites << {
    x: args.state.clock * 10,
    y: 360 * y_perc,
    anchor_x: 0.5,
    anchor_y: 0.5,
    w: 10,
    h: 10,
    r: 255,
    g: 0,
    b: 0,
    a: 255,
    path: :solid
  }

  args.state.clock += 1
  if args.state.clock > 60
    args.state.clock = 0
  end
end
```

## `smooth_stop`

Here are examples of using `smooth_stop`:

```ruby
def tick args
  args.state.clock ||= 0
  y_perc = Easing.smooth_stop(start_at: 0,
                              end_at: 60,
                              tick_count: args.state.clock,
                              power: 5)

  # OR
  # y_perc = Easing.smooth_stop(initial: 0,
  #                             final: 1,
  #                             perc: args.state.clock / 60.0,
  #                             power: 5)
  args.outputs.sprites << {
    x: args.state.clock * 10,
    y: 360 * y_perc,
    anchor_x: 0.5,
    anchor_y: 0.5,
    w: 10,
    h: 10,
    r: 255,
    g: 0,
    b: 0,
    a: 255,
    path: :solid
  }

  args.state.clock += 1
  if args.state.clock > 60
    args.state.clock = 0
  end
end
```

## `smooth_step`

Here are examples of using `smooth_step`:

```ruby
def tick args
  args.state.clock ||= 0
  y_perc = Easing.smooth_step(start_at: 0,
                              end_at: 60,
                              tick_count: args.state.clock,
                              power: 5)

  # OR
  # y_perc = Easing.smooth_step(initial: 0,
  #                             final: 1,
  #                             perc: args.state.clock / 60.0,
  #                             power: 5)
  args.outputs.sprites << {
    x: args.state.clock * 10,
    y: 360 * y_perc,
    anchor_x: 0.5,
    anchor_y: 0.5,
    w: 10,
    h: 10,
    r: 255,
    g: 0,
    b: 0,
    a: 255,
    path: :solid
  }

  args.state.clock += 1
  if args.state.clock > 60
    args.state.clock = 0
  end
end
```

## `mix`

Function expects 3 parameters. The first two parameters are the values
to mix, and the third parameter is the mix percentage.

Example:

```ruby
def tick args
  args.state.clock ||= 0
  y_perc_a = Easing.smooth_start(start_at: 0,
                                 end_at: 60,
                                 tick_count: args.state.clock,
                                 power: 5)

  y_perc_b = Easing.smooth_stop(start_at: 0,
                                end_at: 60,
                                tick_count: args.state.clock,
                                power: 5)

  # a 50/50 mix of smooth_start and smooth_stop gives us a smooth_step
  y_perc = Easing.mix(y_perc_a, y_perc_b, 0.5)

  args.outputs.sprites << {
    x: args.state.clock * 10,
    y: 360 * y_perc,
    anchor_x: 0.5,
    anchor_y: 0.5,
    w: 10,
    h: 10,
    r: 255,
    g: 0,
    b: 0,
    a: 255,
    path: :solid
  }

  args.state.clock += 1
  if args.state.clock > 60
    args.state.clock = 0
  end
end
```

## `lerp` vs `Easing`

Using `Numeric#lerp` directly is simpler, but lacks frame perfect control. Here's an example of
stretching and shrinking a rectangle using only `Numeric#lerp`:

```ruby
def tick args
  args.state.player ||= {
    x: 640,
    y: 360,
    w: 0,
    h: 32,
    anchor_x: 0.5,
    anchor_y: 0.5,
    target_w: 200,
  }

  player = args.state.player

  if args.inputs.keyboard.key_down.up
    player.target_w = player.target_w + 200
  elsif args.inputs.keyboard.key_down.down
    player.target_w = player.target_w - 100
  end

  # unconditionally lerp player.w to player.target_w
  player.target_w = player.target_w.clamp(200, 1000)

  # lerp percentage is guess and test
  player.w = player.w.lerp(player.target_w, 0.2)
  args.outputs.sprites << player.merge(path: :solid, r: 128, g: 128, b: 128)
end
```

Using `Easing` in combination with `Numeric#lerp` is more code, but deterministic/frame-perfect:

```ruby
def tick args
  # "bar" that represents the player
  args.state.player ||= {
    x: 640,
    y: 360,
    w: 0,
    h: 32,
    anchor_x: 0.5,
    anchor_y: 0.5,
    powerup_target_w: 200,
    powerup_at: 0,
  }

  # duration of the lerp animation
  powerup_animation_duration = 15

  player = args.state.player

  # if the last powerup time has elapsed then allow for grow or shrink
  if player.powerup_at.elapsed_time > powerup_animation_duration
    if args.inputs.keyboard.key_down.up && player.w <= 1000
      # if up arrow pressed and the player's width is <= 1000
      # then set the frame the power up was performed and set the target width
      player.powerup_at = Kernel.tick_count
      player.powerup_target_w = player.w + 200
    elsif args.inputs.keyboard.key_down.down && player.w > 200
      # if down arrow pressed and the player's width is > 200
      # then set the frame the power up was performed and set the target width
      player.powerup_at = Kernel.tick_count
      player.powerup_target_w = player.w - 100
    end
  else
    # if the last powerup time is less than the animation duration
    # compute the easing percentage
    perc = Easing.smooth_stop(start_at: player.powerup_at,
                              duration: powerup_animation_duration,
                              power: 2)

    # lerp to the target width based off the percentage
    player.w = player.w.lerp(player.powerup_target_w, perc)
  end

  args.outputs.sprites << player.merge(path: :solid,
                                       r: 128,
                                       g: 128,
                                       b: 128)
end
```

## Chaining Time Stamped Based Easing Functions (Advanced)

Easing functions can be chained using the `ease` class function.

### `ease`

!> `Easing.ease` is not super fast. Consider using `Easing.smooth_(start|stop|step)` if your easing definition is simple.

This function will give you a float value between `0` and `1` that represents a percentage. You need to give the function a `start_tick`, `current_tick`, duration, and easing `definitions`.

This example shows how to fade in a label at frame 60 over two seconds (120 ticks). The `:identity` definition implies a linear fade: `f(x) -> x`.

```ruby
def tick args
  fade_in_at   = 60
  current_tick = Kernel.tick_count
  duration     = 120
  percentage   = Easing.ease fade_in_at,
                             current_tick,
                             duration,
                             :identity
  alpha = 255 * percentage
  args.outputs.labels << { x: 640,
                           y: 320, text: "#{percentage.to_sf}",
                           alignment_enum: 1,
                           a: alpha }
end
```

This example will move a box at a linear speed from 0 to 1280.

```ruby
def tick args
  start_time = 10
  duration = 60
  current_progress = Easing.ease start_time,
                                 Kernel.tick_count,
                                 duration,
                                 :identity
  args.outputs.solids << { x: 1280 * current_progress, y: 360, w: 10, h: 10 }
end
```

#### Easing Definitions

There are a number of easing definitions available to you:

1.  `:identity`

    The easing definition for `:identity` is `f(x) = x`. For example, if `start_tick` is `0`, `current_tick` is `50`, and `duration` is `100`, then `Easing.ease 0, 50, 100, :identity` will return `0.5` (since tick `50` is half way between `0` and `100`).

2.  `:flip`

    The easing definition for `:flip` is `f(x) = 1 - x`. For example, if `start_tick` is `0`, `current_tick` is `10`, and `duration` is `100`, then `Easing.ease 0, 10, 100, :flip` will return `0.9` (since tick `10` means 100% - 10%).

3.  `:quad`, `:cube`, `:quart`, `:quint`

    These are the power easing definitions. `:quad` is `f(x) = x * x` (`x` squared), `:cube` is `f(x) = x * x * x` (`x` cubed), etc.
    
    The power easing definitions represent Smooth Start easing (the percentage changes slow at first and speeds up at the end).

4. The following aliases are also available.

- `smooth_start_quad`: `:quad`
- `smooth_start_cube`: `:cube`
- `smooth_start_quart`: `:quart`
- `smooth_start_quint`: `:quint`
- `smooth_stop_quad`: `:flip, :quad, :flip`
- `smooth_stop_cube`: `:flip, :cube, :flip`
- `smooth_stop_quart`: `:flip, :quart, :flip`
- `smooth_stop_quint`: `:flip, :quint, :flip`

Here is an example of Smooth Start (the percentage changes slow at first and speeds up at the end).

```ruby
def tick args
  start_tick   = 60
  current_tick = Kernel.tick_count
  duration     = 120
  percentage   = Easing.ease start_tick,
                             current_tick,
                             duration,
                             :smooth_start_quad
  start_x      = 100
  end_x        = 1180
  distance_x   = end_x - start_x
  final_x      = start_x + (distance_x * percentage)

  start_y      = 100
  end_y        = 620
  distance_y   = end_y - start_y
  final_y      = start_y + (distance_y * percentage)

  args.outputs.labels << { x: final_x,
                           y: final_y,
                           text: "#{percentage.to_sf}",
                           alignment_enum: 1 }
end
```

#### Combining Easing Definitions

The base easing definitions can be combined to create common easing functions.

Example

Here is an example of Smooth Stop (the percentage changes fast at first and slows down at the end).

```ruby
def tick args
  start_tick   = 60
  current_tick = Kernel.tick_count
  duration     = 120

  # :flip, :quad, :flip is Smooth Stop
  percentage   = Easing.ease start_tick,
                             current_tick,
                             duration,
                             :flip, :quad, :flip
  start_x      = 100
  end_x        = 1180
  distance_x   = end_x - start_x
  final_x      = start_x + (distance_x * percentage)

  start_y      = 100
  end_y        = 620
  distance_y   = end_y - start_y
  final_y      = start_y + (distance_y * percentage)

  args.outputs.labels << { x: final_x,
                           y: final_y,
                           text: "#{percentage.to_sf}",
                           alignment_enum: 1 }
end
```

###  Custom Easing Functions

You can define your own easing functions by passing in a `lambda` as a `definition` or extending the `Easing` module.

#### Using Lambdas

This easing function goes from `0` to `1` for the first half of the ease, then `1` to `0` for the second half of the ease.

```ruby
def tick args
  fade_in_at    = 60
  current_tick  = Kernel.tick_count
  duration      = 600
  easing_lambda = lambda do |percentage, start_tick, duration|
                    fx = percentage
                    if fx < 0.5
                      fx = percentage * 2
                    else
                      fx = 1 - (percentage - 0.5) * 2
                    end
                    fx
                  end

  percentage    = Easing.ease fade_in_at,
                              current_tick,
                              duration,
                              easing_lambda

  alpha = 255 * percentage
  args.outputs.labels << { x: 640,
                           y: 320,
                           a: alpha,
                           text: "#{percentage.to_sf}",
                           alignment_enum: 1 }
end
```

#### Extending Easing Definitions

If you don't want to create a lambda, you can register an easing definition like so:

```ruby
# 1. Extend the Easing module
module Easing
  def self.saw_tooth x
    if x < 0.5
      x * 2
    else
      1 - (x - 0.5) * 2
    end
  end
end

def tick args
  fade_in_at    = 60
  current_tick  = Kernel.tick_count
  duration      = 600

  # 2. Reference easing definition by name
  percentage    = Easing.ease fade_in_at,
                              current_tick,
                              duration,
                              :saw_tooth

  alpha = 255 * percentage
  args.outputs.labels << { x: 640,
                           y: 320,
                           a: alpha,
                           text: "#{percentage.to_sf}",
                           alignment_enum: 1 }

end
```

