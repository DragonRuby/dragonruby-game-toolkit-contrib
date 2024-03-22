# Easing (`args.easing`)

A set of functions that allow you to determine the current progression of an easing function.

## `ease_spline`

Given a start, current, duration, and a multiple bezier values, this function returns a number between 0 and 1 that represents the progress of an easing function.

This example will move a box at a linear speed from 0 to 1280 and then back to 0 using two bezier definitions (represented as an array with four values).

```ruby
def tick args
  start_time = 10
  duration = 60
  spline = [
    [  0, 0.25, 0.75, 1.0],
    [1.0, 0.75, 0.25,   0]
  ]
  current_progress = args.easing.ease_spline start_time,
                                             args.state.tick_count,
                                             duration,
                                             spline
  args.outputs.solids << { x: 1280 * current_progress, y: 360, w: 10, h: 10 }
end
```

## `ease`

This function will give you a float value between `0` and `1` that represents a percentage. You need to give the funcation a `start_tick`, `current_tick`, duration, and easing `definitions`.

This YouTube video is a fantastic introduction to easing functions: <https://www.youtube.com/watch?v=mr5xkf6zSzk>

This example shows how to fade in a label at frame 60 over two seconds (120 ticks). The `:identity` definition implies a linear fade: `f(x) -> x`.

```ruby
def tick args
  fade_in_at   = 60
  current_tick = args.state.tick_count
  duration     = 120
  percentage   = args.easing.ease fade_in_at,
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
  current_progress = args.easing.ease start_time,
                                      args.state.tick_count,
                                      duration,
                                      :identity
  args.outputs.solids << { x: 1280 * current_progress, y: 360, w: 10, h: 10 }
end
```

### Easing Definitions

There are a number of easing definitions availble to you:

1.  `:identity`

    The easing definition for `:identity` is `f(x) = x`. For example, if `start_tick` is `0`, `current_tick` is `50`, and `duration` is `100`, then `args.easing.ease 0, 50, 100, :identity` will return `0.5` (since tick `50` is half way between `0` and `100`).

2.  `:flip`

    The easing definition for `:flip` is `f(x) = 1 - x`. For example, if `start_tick` is `0`, `current_tick` is `10`, and `duration` is `100`, then `args.easing.ease 0, 10, 100, :flip` will return `0.9` (since tick `10` means 100% - 10%).

3.  `:quad`, `:cube`, `:quart`, `:quint`

    These are the power easing definitions. `:quad` is `f(x) = x * x` (`x` squared), `:cube` is `f(x) = x * x * x` (`x` cubed), etc.
    
    The power easing definitions represent Smooth Start easing (the percentage changes slow at first and speeds up at the end).
    
Here is an example of Smooth Start (the percentage changes slow at first and speeds up at the end).

```ruby
def tick args
  start_tick   = 60
  current_tick = args.state.tick_count
  duration     = 120
  percentage   = args.easing.ease start_tick,
                                  current_tick,
                                  duration,
                                  :quad
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

### Combining Easing Definitions

The base easing definitions can be combined to create common easing functions.

Example

Here is an example of Smooth Stop (the percentage changes fast at first and slows down at the end).

```ruby
def tick args
  start_tick   = 60
  current_tick = args.state.tick_count
  duration     = 120

  # :flip, :quad, :flip is Smooth Stop
  percentage   = args.easing.ease start_tick,
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
  current_tick  = args.state.tick_count
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

  percentage    = args.easing.ease fade_in_at,
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
  current_tick  = args.state.tick_count
  duration      = 600

  # 2. Reference easing definition by name
  percentage    = args.easing.ease fade_in_at,
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

