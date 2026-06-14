# Geometry

The Geometry `module` contains methods for calculations that are frequently used in game development.

The following functions of `Geometry` are mixed into `Hash`, `Array`, and DragonRuby's `Entity` class:

- `intersect_rect?`
- `inside_rect?`
- `scale_rect`
- `angle_to`
- `angle_from`
- `point_inside_circle?`
- `center_inside_rect`
- `center_inside_rect_x`
- `center_inside_rect_y`
- `anchor_rect`
- `rect_center_point`

You can invoke the functions above using either the mixin variant or the module variant. Example:

```ruby
def tick args
  # define to rectangles
  rect_1 = { x: 0, y: 0, w: 100, h: 100 }
  rect_2 = { x: 50, y: 50, w: 100, h: 100 }

  # mixin variant
  # call geometry method function from instance of a Hash class
  puts rect_1.intersect_rect?(rect_2)

  # OR

  # module variants
  puts Geometry.intersect_rect?(rect_1, rect_2)
end
```

## Trig Functions

### `angle`

Invocation variants:

- `Geometry.angle start_point, end_point`

Returns an angle in degrees from the `start_point` to the `end_point` (if you want the value in radians call `.to_radians` on the value returned).

### `angle_from`

Invocation variants:

- `Geometry.angle_from start_point, end_point`
- `start_point.angle_from end_point`

Returns an angle in degrees from the `end_point` to the `start_point` (if you want the value in radians, you can call `.to_radians` on the value returned):

```ruby
def tick args
  rect_1 ||= {
    x: 0,
    y: 0,
  }

  rect_2 ||= {
    x: 100,
    y: 100,
  }

  angle = rect_1.angle_from rect_2 # returns 225 degrees
  angle_radians = angle.to_radians
  args.outputs.labels << { x: 30, y: 30.from_top, text: "#{angle}, #{angle_radians}" }

  angle = Geometry.angle_from rect_1, rect_2 # returns 225 degrees
  angle_radians = angle.to_radians
  args.outputs.labels << { x: 30, y: 60.from_top, text: "#{angle}, #{angle_radians}" }
end
```

### `angle_to`, `angle`

Invocation variants:

- `Geometry.angle_to start_point, end_point`
- `Geometry.angle start_point, end_point` (alias)
- `start_point.angle_to end_point`

Returns an angle in degrees to the `end_point` from the `start_point` (if you want the value in radians, you can call `.to_radians` on the value returned):

```ruby
def tick args
  rect_1 ||= {
    x: 0,
    y: 0,
  }

  rect_2 ||= {
    x: 100,
    y: 100,
  }

  angle = rect_1.angle_to rect_2 # returns 45 degrees
  angle_radians = angle.to_radians
  args.outputs.labels << { x: 30, y: 30.from_top, text: "#{angle}, #{angle_radians}" }

  angle = Geometry.angle_to rect_1, rect_2 # returns 45 degrees
  angle_radians = angle.to_radians
  args.outputs.labels << { x: 30, y: 60.from_top, text: "#{angle}, #{angle_radians}" }
end
```

### `angle_turn_direction`

Invocation variants:

- `Geometry.angle_turn_direction angle, target_angle`

Returns `1` or -1 depending on which direction the `angle` needs to turn to reach the `target_angle` most efficiently. The angles are assumed to be in degrees. `1` means turn clockwise, and `-1` means turn counter-clockwise.

### `angle_delta`

Invocation variants:

- `Geometry.angle_delta angle, target_angle`

Given an `angle` and a `target_angle`, this function will return the
smallest angle delta between the two angles. The angles are assumed to
be in degrees.

### `angle_within_range?`

Invocation variants:

- `Geometry.angle_within_range? test_angle, target_angle, range`

Given a `test_angle`, `target_angle`, and `range` (all in degrees),
this function will return `true` if the `test_angle` is within the
`range` of the `target_angle` on either side. The `range` is the
number of degrees from the `target_angle` that the `test_angle` can be
within to return `true`.

```ruby
def tick args
  args.state.target_angle ||= 90
  args.state.angle_range  ||= 10
  mouse_angle  = Geometry.angle({ x: 640, y: 0 }, args.inputs.mouse.point)
  delta_angle  = Geometry.angle_delta(args.state.target_angle, mouse_angle)
  within_range = Geometry.angle_within_range?(args.state.target_angle, mouse_angle, args.state.angle_range)

  # render line for mouse
  args.outputs.lines << { x: 640,
                          y: 0,
                          x2: args.inputs.mouse.x,
                          y2: args.inputs.mouse.y,
                          r: 0,
                          g: 0,
                          b: 0 }

  # render line for target angle
  args.outputs.lines << { x: 640,
                          y: 0,
                          x2: 640 + 700 * args.state.target_angle.vector_x,
                          y2: 700 * args.state.target_angle.vector_y,
                          r: 0,
                          g: 0,
                          b: 0 }

  # render lines for angle range
  args.outputs.lines << { x: 640,
                          y: 0,
                          x2: 640 + 700 * (args.state.target_angle - args.state.angle_range).vector_x,
                          y2: 700 * (args.state.target_angle - args.state.angle_range).vector_y,
                          r: 0,
                          g: 0,
                          b: 0 }
  args.outputs.lines << { x: 640,
                          y: 0,
                          x2: 640 + 700 * (args.state.target_angle + args.state.angle_range).vector_x,
                          y2: 700 * (args.state.target_angle + args.state.angle_range).vector_y,
                          r: 0,
                          g: 0,
                          b: 0 }

  args.outputs.debug << "Target Angle #{args.state.target_angle}"
  args.outputs.debug << "Angle Range #{args.state.angle_range}"
  args.outputs.debug << "Mouse Angle #{mouse_angle.to_sf}"
  args.outputs.debug << "Delta Angle #{delta_angle.to_sf}"
  args.outputs.debug << "Within Range? #{within_range}"
end
```

### `rotate_point`

Given a point and an angle in degrees, a new point is returned that is rotated around the origin by the degrees amount. An optional third argument can be provided to rotate the angle around a point other than the origin.

```ruby
def tick args
  args.state.rotate_amount ||= 0
  args.state.rotate_amount  += 1

  if args.state.rotate_amount >= 360
    args.state.rotate_amount = 0
  end

  point_1 = {
    x: 100,
    y: 100
  }

  # rotate point around 0, 0
  rotated_point_1 = Geometry.rotate_point point_1,
                                          args.state.rotate_amount

  args.outputs.solids << {
    x: rotated_point_1.x - 5,
    y: rotated_point_1.y - 5,
    w: 10,
    h: 10
  }

  point_2 = {
    x: 640 + 100,
    y: 360 + 100
  }

  # rotate point around center screen
  rotated_point_2 = Geometry.rotate_point point_2,
                                          args.state.rotate_amount,
                                          x: 640, y: 360

  args.outputs.solids << {
    x: rotated_point_2.x - 5,
    y: rotated_point_2.y - 5,
    w: 10,
    h: 10
  }
end
```

### `angle_vec2`

Given an angle in degrees, a `Hash` will be returned with `x`, `y` representing the vector components of the angle.

### `angle_vec2_r`

Given an angle in radians, a `Hash` will be returned with `x`, `y` representing the vector components of the angle.

### `angle_cardinal_vec2`

Given an angle in degrees, a `Hash` will be returned with `x`, `y` representing the vector components of the angle snapped to 45 degree angles (mirroring the directional options for a DPAD).

### `angle_cardinal_vec2_r`

Given an angle in radians, a `Hash` will be returned with `x`, `y` representing the vector components of the angle snapped to 45 degree angles (mirroring the directional options for a DPAD)..

### `distance`

Returns the distance between two points;

```ruby
def tick args
  rect_1 ||= {
    x: 0,
    y: 0,
  }

  rect_2 ||= {
    x: 100,
    y: 100,
  }

  distance = Geometry.distance rect_1, rect_2
  args.outputs.labels << {
    x: 30,
    y: 30.from_top,
    text: "#{distance}"
  }

  args.outputs.lines << {
    x: rect_1.x,
    y: rect_1.y,
    x2: rect_2.x,
    y2: rect_2.y
  }
end
```

### `distance_squared`

Given two `Hashes` with `x` and `y` keys (or `Objects` that respond to `x` and `y`), this function will return the distance squared between the two points. This is useful when you only want to compare distances, and don't need the actual distance.

Note: Take a look at this sample app for a non-trivial example of how to use this function: `./samples/04_physics_and_collisions/11_bouncing_ball_with_gravity/`

### `line_angle`

Given a line, this function will return the angle of the line in degrees.

### `line_rise_run`

Given a line, this function returns a `Hash[x:, y:]` representing a normalized representation of the rise and run of the line.

```ruby
def tick args
  # draw a line from the bottom left to the top right
  line = {
    x: 0,
    y: 0,
    x2: 1280,
    y2: 720
  }

  # get rise and run of line
  rise_run = Geometry.line_rise_run line

  # output the rise and run of line
  args.outputs.labels << {
    x: 640,
    y: 360,
    text: "#{rise_run}",
    alignment_enum: 1,
    vertical_alignment_enum: 1,
  }

  # render the line
  args.outputs.lines << line
end
```

### `line_vec2`

Given a line, this function will return a `Hash` with `x` and `y` keys that represents the vector of the line.

Note: Take a look at this sample app for a non-trivial example of how to use this function: `./samples/04_physics_and_collisions/11_bouncing_ball_with_gravity/`

### `line_normal`

The first parameter is a line (a `Hash` with `x`, `y`, `x2`, and `y2` keys, or an `Object` that responds to `x`, `y`, `x2`, and `y2`).

The second parameter is a `Hash` with `x` and `y` keys (or an `Object` that responds to `x` and `y`).

This function will return a `Hash` with `x` and `y` keys that represents the normal of the line relative to the point provided.

Note: Take a look at this sample app for a non-trivial example of how to use this function: `./samples/04_physics_and_collisions/11_bouncing_ball_with_gravity/`

### `vec2_dot_product`

Given two `Hashes` with `x` and `y` keys (or `Objects` that respond to `x` and `y`), this function will return the dot product of the two vectors.

Note: Take a look at this sample app for a non-trivial example of how to use this function: `./samples/04_physics_and_collisions/11_bouncing_ball_with_gravity/`

### `vec2_magnitude`

Given a `Hash` with `x` and `y` keys (or an `Object` that responds to `x` and `y`), this function will return the magnitude of the vector. 

### `vec2_normalize`

Given a `Hash` with `x` and `y` keys (or an `Object` that responds to `x` and `y`), this function will return a `Hash` with `x` and `y` keys that represents the normalized vector. Normalization is performed by dividing the x and y components of a vector by its magnitude.

### `vec2_normal`

Given a `Hash` with `x` and `y` keys (or an `Object` that responds to `x` and `y`), this function will return a `Hash` with `x` and `y` keys that represents the normal of the vector.

### `vec2_add`

Given two `Hashes` with `x` and `y` keys (or an `Objects` that responds to `x` and `y`), this function will return a `Hash` with `x` and `y` keys that represents the sum of the two vectors.

### `vec2_subtract`, `vec2_sub`

Given two `Hashes` with `x` and `y` keys (or an `Objects` that responds to `x` and `y`), this function will return a `Hash` with `x` and `y` keys that represents the difference of the two vectors.

### `vec2_scale`

Given a `Hash` with `x` and `y` keys (or an `Object` that responds to `x` and `y`) and a `Numeric` value, this function will return a `Hash` with `x` and `y` keys with each component of the vector multiplied by the scalar value.

### `vec2_angle`

Given a `Hash` with `x` and `y` keys (or an `Object` that responds to `x` and `y`) this function returns the angle in degrees (`0` to `359.9s`). If you want an angle in radius, use `Math.atan2(x, y)`.

## Collision Functions

### `intersect_rect?`

Invocation variants:

- `instance.intersect_rect?(other, tolerance)`
- `Geometry.intersect_rect?(rect_1, rect_2, tolerance)`
- `args.inputs.mouse.intersect_rect?(other, tolerance)`

Given two rectangle primitives this function will return `true` or `false` depending on if the two rectangles intersect or not. An optional final parameter can be passed in representing the `tolerance` of overlap needed to be considered a true intersection. The default value of `tolerance` is `0.1` which keeps the function from returning true if only the edges of the rectangles overlap.

?> `:anchor_x`, and `anchor_y` is taken into consideration if the objects respond to these methods.

Here is an example where one rectangle is stationary, and another rectangle is controlled using directional input. The rectangles change color from blue to red if they intersect.

```ruby
def tick args
  # define a rectangle in state and position it
  # at the center of the screen with a color of blue
  args.state.box_1 ||= {
    x: 640 - 20,
    y: 360 - 20,
    w: 40,
    h: 40,
    r: 0,
    g: 0,
    b: 255
  }

  # create another rectangle in state and position it
  # at the far left center
  args.state.box_2 ||= {
    x: 0,
    y: 360 - 20,
    w: 40,
    h: 40,
    r: 0,
    g: 0,
    b: 255
  }

  # take the directional input and use that to move the second rectangle around
  # increase or decrease the x value based on if left or right is held
  args.state.box_2.x += args.inputs.left_right * 5
  # increase or decrease the y value based on if up or down is held
  args.state.box_2.y += args.inputs.up_down * 5

  # change the colors of the rectangles based on whether they
  # intersect or not
  if args.state.box_1.intersect_rect? args.state.box_2
    args.state.box_1.r = 255
    args.state.box_1.g = 0
    args.state.box_1.b = 0

    args.state.box_2.r = 255
    args.state.box_2.g = 0
    args.state.box_2.b = 0
  else
    args.state.box_1.r = 0
    args.state.box_1.g = 0
    args.state.box_1.b = 255

    args.state.box_2.r = 0
    args.state.box_2.g = 0
    args.state.box_2.b = 255
  end

  # render the rectangles as border primitives on the screen
  args.outputs.borders << args.state.box_1
  args.outputs.borders << args.state.box_2
end
```

### `inside_rect?`

Invocation variants:

- `instance.inside_rect?(other)`
- `Geometry.inside_rect?(rect_1, rect_2)`

Given two rectangle primitives this function will return `true` or `false` depending on if the first rectangle (or `self`) is inside of the second rectangle.

Here is an example where one rectangle is stationary, and another rectangle is controlled using directional input. The rectangles change color from blue to red if the movable rectangle is entirely inside the stationary rectangle.

?> `:anchor_x`, and `anchor_y` is taken into consideration if the objects respond to these methods.

```ruby
def tick args
  # define a rectangle in state and position it
  # at the center of the screen with a color of blue
  args.state.box_1 ||= {
    x: 640 - 40,
    y: 360 - 40,
    w: 80,
    h: 80,
    r: 0,
    g: 0,
    b: 255
  }

  # create another rectangle in state and position it
  # at the far left center
  args.state.box_2 ||= {
    x: 0,
    y: 360 - 10,
    w: 20,
    h: 20,
    r: 0,
    g: 0,
    b: 255
  }

  # take the directional input and use that to move the second rectangle around
  # increase or decrease the x value based on if left or right is held
  args.state.box_2.x += args.inputs.left_right * 5
  # increase or decrease the y value based on if up or down is held
  args.state.box_2.y += args.inputs.up_down * 5

  # change the colors of the rectangles based on whether they
  # intersect or not
  if args.state.box_2.inside_rect? args.state.box_1
    args.state.box_1.r = 255
    args.state.box_1.g = 0
    args.state.box_1.b = 0

    args.state.box_2.r = 255
    args.state.box_2.g = 0
    args.state.box_2.b = 0
  else
    args.state.box_1.r = 0
    args.state.box_1.g = 0
    args.state.box_1.b = 255

    args.state.box_2.r = 0
    args.state.box_2.g = 0
    args.state.box_2.b = 255
  end

  # render the rectangles as border primitives on the screen
  args.outputs.borders << args.state.box_1
  args.outputs.borders << args.state.box_2
end
```

### `intersect_circle?`

Invocation variants:

- `Geometry.intersect_circle?(circle_1, circle_2)`
- `Geometry.intersect_circle?(rect_1, circle_2)`
- `Geometry.intersect_circle?(circle_1, rect_2)`
- `Geometry.intersect_circle?(rect_1, rect_2)`

The parameters must be one of the following:

- A `Hash` with `x`, `y`, and `radius` (or an object that responds to `x`, `y`, and `radius`).
- A `Hash` with `x`, `y`, `w`, `h`, `anchor_x`, and `anchor_y` (or an object that responds to `x`, `y`, `w`, `h`, `anchor_x`, and `anchor_y`). If the parameter is a `Hash`, `anchor_x` and `anchor_y` are optional and default to `0`.

Given two shapes that represent circles or rectangles, this function will return `true` or `false`
depending on if the two circles intersect or not.

```ruby
def tick args
  # create a rect at the center of the screen
  args.state.rect ||= { x: 640 - 50,
                        y: 360 - 50,
                        w: 100,
                        h: 100 }

  # create a circle that fits inside the rect
  args.state.circle ||= Geometry.rect_to_circle(args.state.rect)

  # create a rect at the mouse position
  args.state.mouse_rect = { x: args.inputs.mouse.x,
                            y: args.inputs.mouse.y,
                            w: 100,
                            h: 100,
                            anchor_x: 0.5,
                            anchor_y: 0.5 }

  # create a circle that fits inside the mouse rect
  args.state.mouse_circle = Geometry.rect_to_circle(args.state.mouse_rect)

  # render the center rect, circle, mouse rect, and mouse circle
  args.outputs.sprites << args.state.rect
                              .merge(path: "sprites/square/blue.png")
  args.outputs.sprites << args.state.circle
                              .merge(path: "sprites/circle/red.png")
  args.outputs.sprites << args.state.mouse_rect
                              .merge(path: "sprites/square/orange.png")
  args.outputs.sprites << args.state.mouse_circle
                              .merge(path: "sprites/circle/green.png")

  # render a label if the rect and mouse rect intersect
  if Geometry.intersect_rect? args.state.rect, args.state.mouse_rect
    args.outputs.labels << { x: 640,
                             y: 700,
                             text: "Rect and Mouse Rect intersect",
                             anchor_x: 0.5 }
  end

  # render a label if the rect and mouse rect intersect
  if Geometry.intersect_circle? args.state.circle, args.state.mouse_circle
    args.outputs.labels << { x: 640,
                             y: 680,
                             text: "Circle and Mouse Circle intersect",
                             anchor_x: 0.5 }
  end
end
```

### `point_inside_circle?`

Invocation variants:

- `point_1.point_inside_circle? circle_center, circle_radius`
- `Geometry.point_inside_circle? point_1, circle_center, circle_radius`

`circle_center` can also contain the `radius` value (instead of passing it as a separate argument).

Returns `true` if a point is inside of a circle defined as a center point and radius.

```ruby
def tick args
  # define circle center
  args.state.circle_center ||= {
    x: 640,
    y: 360
  }

  # define circle radius
  args.state.circle_radius ||= 100

  # define point
  args.state.point_1 ||= {
    x: 100,
    y: 100
  }

  # allow point to be moved using keyboard
  args.state.point_1.x += args.inputs.left_right * 5
  args.state.point_1.y += args.inputs.up_down * 5

  # determine if point is inside of circle
  intersection = Geometry.point_inside_circle? args.state.point_1,
                                               args.state.circle_center,
                                               args.state.circle_radius

  # render point as a square
  args.outputs.sprites << {
    x: args.state.point_1.x - 20,
    y: args.state.point_1.y - 20,
    w: 40,
    h: 40,
    path: "sprites/square/blue.png"
  }

  # if there is an intersection, render a red circle
  # otherwise render a blue circle
  if intersection
    args.outputs.sprites << {
      x: args.state.circle_center.x - args.state.circle_radius,
      y: args.state.circle_center.y - args.state.circle_radius,
      w: args.state.circle_radius * 2,
      h: args.state.circle_radius * 2,
      path: "sprites/circle/red.png",
      a: 128
    }
  else
    args.outputs.sprites << {
      x: args.state.circle_center.x - args.state.circle_radius,
      y: args.state.circle_center.y - args.state.circle_radius,
      w: args.state.circle_radius * 2,
      h: args.state.circle_radius * 2,
      path: "sprites/circle/blue.png",
      a: 128
    }
  end
end
```

### `ray_test`

Given a point and a line, `ray_test` returns one of the following symbols based on the location of the point relative to the line: `:left`, `:right`, `:on`

```ruby
def tick args
  # create a point based off of the mouse location
  point = {
    x: args.inputs.mouse.x,
    y: args.inputs.mouse.y
  }

  # draw a line from the bottom left to the top right
  line = {
    x: 0,
    y: 0,
    x2: 1280,
    y2: 720
  }

  # perform ray_test on point and line
  ray = Geometry.ray_test point, line

  # output the results of ray test at mouse location
  args.outputs.labels << {
    x: point.x,
    y: point.y + 25,
    text: "#{ray}",
    alignment_enum: 1,
    vertical_alignment_enum: 1,
  }

  # render line
  args.outputs.lines << line

  # render point
  args.outputs.solids << {
    x: point.x - 5,
    y: point.y - 5,
    w: 10,
    h: 10
  }
end
```

### `line_intersect`

Given two lines (`:x`, `:y`, `:x2`, `:y2`), this function returns point of intersection if the line segments intersect. If the line segments do not intersect, `nil` is returned. If you want the lines to be treated as infinite lines, use `ray_intersect`.

Invocation variants:

- `Geometry.line_intersect line_1, line_2`

```ruby
def tick args
  args.state.line_one ||= { x: 0, y: 0, x2: 1280, y2: 720 }
  line_two = { x: 0, y: 720, x2: args.inputs.mouse.x, y2: args.inputs.mouse.y }
  args.state.intersect_point = Geometry.line_intersect args.state.line_one, line_two
  args.outputs.lines << { x: 0, y: 0, x2: 1280, y2: 720 }
  args.outputs.lines << line_two
  if args.state.intersect_point
    args.outputs.solids << {
      x: args.state.intersect_point.x,
      y: args.state.intersect_point.y,
      w: 10,
      h: 10,
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 255,
      g: 0,
      b: 0
    }
  end
end
```

### `ray_intersect`

Given two lines (`:x`, `:y`, `:x2`, `:y2`), this function returns point of intersection if the ray (infinite line) intersect. If the lines are parallel, `nil` is returned. If you do not want the lines to be treated as infinite lines, use `line_intersect`.

Invocation variants:

- `Geometry.ray_intersect line_1, line_2`

```ruby
def tick args
  # define line_one to go from the bottom left to the top right
  args.state.line_one ||= { x: 0, y: 0, x2: 1280, y2: 720 }

  # have the mouse control the x2 and y2 of line_two
  line_two = { x: 0, y: 720, x2: args.inputs.mouse.x, y2: args.inputs.mouse.y }

  # calc if line_one and line_two intersect and if so, the point of intersection
  args.state.intersect_point = Geometry.ray_intersect args.state.line_one, line_two

  # draw line_one
  args.outputs.lines << { x: 0, y: 0, x2: 1280, y2: 720 }

  # draw line_two
  args.outputs.lines << line_two

  # draw a rect at the intersection point
  if args.state.intersect_point
    args.outputs.solids << {
      x: args.state.intersect_point.x,
      y: args.state.intersect_point.y,
      w: 10,
      h: 10,
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 255,
      g: 0,
      b: 0 }
  end
end
```

### `find_intersect_rect`

Given a rect and a collection of rects, `find_intersect_rect` returns the **first rect** that intersects with the the first parameter.

`:anchor_x`, and `anchor_y` is taken into consideration if the objects respond to these methods.

If you find yourself doing this:

```ruby
collision = args.state.terrain.find { |t| t.intersect_rect? args.state.player }
```

Consider using `find_intersect_rect` instead (it's more descriptive and faster):

```ruby
collision = Geometry.find_intersect_rect args.state.player, args.state.terrain
```

?> Function returns `nil` if either parameter is `nil` (`nil` values within the collection are skipped).

### `find_all_intersect_rect`

Given a rect and a collection of rects, `find_all_intersect_rect` returns **all rects** that intersects with the the first parameter.

`:anchor_x`, and `anchor_y` is taken into consideration if the objects respond to these methods.

If you find yourself doing this:

```ruby
collisions = args.state.terrain.find_all { |t| t.intersect_rect? args.state.player }
```

Consider using `find_all_intersect_rect` instead (it's more descriptive and faster):

```ruby
collisions = Geometry.find_all_intersect_rect args.state.player, args.state.terrain
```

?> Function returns an empty `Array` if either parameter is `nil` (`nil` values within the collection are skipped).

The third parameter is optional and is a `Numeric` value representing the `tolerance` (defaulted to `0.1`).

An optional named parameter called `using` can be included to tell the function what value contains rect information.

Example:

```ruby
def tick args
  player = {
    name: "Hero",
    hp: 10,
    hitbox: {
      x: 0, y: 0, w: 100, h: 100
    }
  }

  enemies = [
    {
      name: "Enemy 1",
      hp: 10,
      hitbox: {
        x: 0, y: 0, w: 100, h: 100
      }
    },
    {
      name: "Enemy 1",
      hp: 10,
      hitbox: {
        x: 200, y: 200, w: 100, h: 100
      }
    }
  ]

  first_enemy = Geometry.find_intersect_rect(player, enemies, using: :hitbox)
  # OR
  first_enemy = Geometry.find_intersect_rect(player, enemies, using: ->(o) { o.hitbox })

  puts first_enemy
end
```

### `circle_intersect_line?`

The first parameters is a `Hash` with `x`, `y`, and `radius` keys (or an `Object` that responds to `x`, `y`, and `radius`).

The second parameter is a `Hash` with `x`, `y`, `x2`, and `y2` keys (or an `Object` that responds to `x`, `y`, `x2`, and `y2`).

This function will return `true` if the circle intersects the line, and `false` if it does not.

Note: Take a look at this sample app for a non-trivial example of how to use this function: `./samples/04_physics_and_collisions/11_bouncing_ball_with_gravity/`

### `point_on_line?`

The first parameter is a `point` (a `Hash` with `x` and `y` keys, or an `Object` that responds to `x` and `y`).

The second parameter is a `line` (a `Hash` with `x`, `y`, `x2`, and `y2` keys, or an `Object` that responds to `x`, `y`, `x2`, and `y2`).

The third parameter is optional and is a `Numeric` value representing the `tolerance` (defaulted to `0.1`).

This function will return `true` if the point is on the line, and `false` if it is not.

```ruby
def tick args
  args.state.test_line ||= { x: 0, y: 0, x2: 320, y2: 320 }
  args.state.test_point ||= { x: 0, y: 0 }
  args.outputs.lines << args.state.test_line
  args.outputs.sprites << args.state.test_point.merge(path: :solid, w: 8, h: 8, anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 0, b: 0)

  if args.inputs.keyboard.key_down.space
    args.state.test_point.x += 32

    if args.state.test_point.x > 320
      args.state.test_point.x = 0
      args.state.test_point.y += 32
    end

    if args.state.test_point.y > 320
      args.state.test_point.y = 0
    end
  end

  args.outputs.watch args.state.test_point
  args.outputs.watch "#{Geometry.point_on_line? args.state.test_point, args.state.test_line}"
end
```

Note: Take a look at this sample app for a non-trivial example of how to use this function: `./samples/04_physics_and_collisions/11_bouncing_ball_with_gravity/`

### `each_intersect_rect`

The first parameter can be an array or a single `Hash` (or an object that responds to `x`, `y`, `w`, `h`).

The second parameter can be an array or a single `Hash` (or an object that responds to `x`, `y`, `w`, `h`). The second parameter should be the larger of the two sets of rectangles.

The third parameter is optional and is the tolerance for the intersection. The default value is `0.1`.

An optional `using:` named parameter can be given to specify what
function should be used to extract the `x`, `y`, `w`, and `h`
properties from the objects in the first and second parameters. This
parameter can be a `Symbol` or a `Proc`. If it is a `Symbol`, it will
be used as a method name to call on the objects in the first and
second parameters. If it is a `Proc`, it will be called with the
object in the first and second parameters. 

An implicit block is required for this function. The block will be called with each pair of intersecting rectangles.

#### Simple Usage

```ruby
rects = [
  { x: 0, y: 0, w: 100, h: 100 },
  { x: 50, y: 50, w: 100, h: 100 }
]

Geometry.each_intersect_rect(rects) do |rect_1, rect_2|
  # do something with the intersecting rectangles
end

# OR

rects_1 = [{ x: 0, y: 0, w: 100, h: 100 }]
rects_2 = [{ x: 50, y: 50, w: 100, h: 100 }]

Geometry.each_intersect_rect(rects_1, rects_2) do |rect_1, rect_2|
  # do something with the intersecting rectangles
end
```

#### Advanced Usage

```ruby
class Player
  def initialize x:, y:, w:, h:;
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def box
    { x: @x, y: @y, w: @w, h: @h }
  end
end

class Bullet
  def initialize x:, y:, w:, h:;
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def box
    { x: @x, y: @y, w: @w, h: @h }
  end
end

rects_1 = [Player.new(x: 0, y: 0, w: 100, h: 100)]
rects_2 = [Bullet.new(x: 50, y: 50, w: 100, h: 100)]

Geometry.each_intersect_rect(rects_1, rects_2, using: :box) do |player, bullet|
  # do something with the intersecting rectangles
end

# OR
Geometry.each_intersect_rect(rects_1,
                             rects_2,
                             using: lambda { |obj| obj.box }) do |player, bullet|
  # do something with the intersecting rectangles
end
```

### `find_collisions`

Given an `Array` of rects, returns a `Hash` of collisions. Each entry in the return `Hash` maps two rects from the input `Array` that intersect.

This function only returns the _first_ collision that was found (within a quad tree partition) for each entry in the `Array` that's passed in.

```ruby
rects = [
  { id: :a, x: 0, y: 0, w: 100, h: 100 },
  { id: :b, x: 0, y: 0, w: 25, h: 25 },
  { id: :c, x: 0, y: 0, w: 50, h: 50 },
]

collisions = Geometry.find_collisions(rects)
```

`collisions` would be:

```ruby
{
  # only first collision is returned even though :a collides with both :b and :c
  { id: :a, ... } => { id: :c, ... },
  
  { id: :b, ... } => { id: :a, ... },
  { id: :c, ... } => { id: :a, ... },
}
```

Multiple rects can be provided (the first being the source rect collection, the second being the target rect collection):

```ruby
rects_1 = [
  { id: :a, x: 0, y: 0, w: 100, h: 100 },
]

rects_2 = [
  { id: :b, x: 0, y: 0, w: 25, h: 25 },
  { id: :c, x: 0, y: 0, w: 50, h: 50 },
]


collisions = Geometry.find_collisions(rects_1, rects_2)
```

`collisions` would be:

```ruby
{
  { id: :a, ... } => { id: :c, ... },
}
```

Flipping the source and target parameters:

```ruby
collisions = Geometry.find_collisions(rects_2, rects_1)
```

would give:

```ruby
{
  { id: :b, ... } => { id: :a, ... },
  { id: :c, ... } => { id: :a, ... },
}
```

### `find_intersect_rect_quad_tree`

This is a faster collision algorithm for determining if a rectangle intersects any rectangle in an array. In order to use `find_intersect_rect_quad_tree`, you must first generate a quad tree data structure using `create_quad_tree`. Use this function if `find_intersect_rect` isn't fast enough.

```ruby
def tick args
  # create a player
  args.state.player ||= {
    x: 640 - 10,
    y: 360 - 10,
    w: 20,
    h: 20
  }

  # allow control of player movement using arrow keys
  args.state.player.x += args.inputs.left_right * 5
  args.state.player.y += args.inputs.up_down * 5

  # generate 40 random rectangles
  args.state.boxes ||= 40.map do
    {
      x: 1180 * rand + 50,
      y: 620 * rand + 50,
      w: 100,
      h: 100
    }
  end

  # generate a quad tree based off of rectangles.
  # the quad tree should only be generated once for
  # a given array of rectangles. if the rectangles
  # change, then the quad tree must be regenerated
  args.state.quad_tree ||= Geometry.quad_tree_create args.state.boxes

  # use quad tree and find_intersect_rect_quad_tree to determine collision with player
  collision = Geometry.find_intersect_rect_quad_tree args.state.player,
                                                     args.state.quad_tree

  # if there is a collision render a red box
  if collision
    args.outputs.solids << collision.merge(r: 255)
  end

  # render player as green
  args.outputs.solids << args.state.player.merge(g: 255)

  # render boxes as borders
  args.outputs.borders << args.state.boxes
end
```

### `find_all_intersect_rect_quad_tree`

This is a faster collision algorithm for determining if a rectangle intersects other rectangles in an array. In order to use `find_all_intersect_rect_quad_tree`, you must first generate a quad tree data structure using `create_quad_tree`. Use this function if `find_all_intersect_rect` isn't fast enough.

```ruby
def tick args
  # create a player
  args.state.player ||= {
    x: 640 - 10,
    y: 360 - 10,
    w: 20,
    h: 20
  }

  # allow control of player movement using arrow keys
  args.state.player.x += args.inputs.left_right * 5
  args.state.player.y += args.inputs.up_down * 5

  # generate 40 random rectangles
  args.state.boxes ||= 40.map do
    {
      x: 1180 * rand + 50,
      y: 620 * rand + 50,
      w: 100,
      h: 100
    }
  end

  # generate a quad tree based off of rectangles.
  # the quad tree should only be generated once for
  # a given array of rectangles. if the rectangles
  # change, then the quad tree must be regenerated
  args.state.quad_tree ||= Geometry.quad_tree_create args.state.boxes

  # use quad tree and find_intersect_rect_quad_tree to determine collision with player
  collisions = Geometry.find_all_intersect_rect_quad_tree args.state.player,
                                                          args.state.quad_tree

  # if there is a collision render a red box
  args.outputs.solids << collisions.map { |c| c.merge(r: 255) }

  # render player as green
  args.outputs.solids << args.state.player.merge(g: 255)

  # render boxes as borders
  args.outputs.borders << args.state.boxes
end
```


### `create_quad_tree`

Generates a quad tree from an array of rectangles. See `find_intersect_rect_quad_tree` for usage.

## Transform Functions

### `rect_props`

Invocation variants:

- `Geometry.rect_props rect`

Given a `Hash[x:, y:, w:, h:, anchor_x: nil, anchor_y: nil]`, this function returns a `Hash` in the following form.

```ruby
{
  x:,
  y:,
  w:,
  h:,
  center: {
    x:,
    y:,
  }
}
```

Notes:

- Any object that responds to `x`, `y`, `w`, `h`, `anchor_x`, `anchor_y` can leverage this function.
- The returned `Hash` will not include `anchor_(x|y)` (recomputes `x`, `y` to take the anchors into consideration).

### `rect_center_point`, `center`

- `Geometry.rect_center_point rect`

Given a `Hash[x:, y:, w:, h:, anchor_x: nil, anchor_y: nil]`, this function returns a `Hash[x:, y:]` representing the center point of the rect.

### `line_center_point`

- `Geometry.line_center_point line`

Given a `Hash[x:, y:, x2:, y2:]` returns a `Hash[x:, y:]` representing the center point of the line.

### `center`

- `Geometry.line_center_point rect_or_line`

Given a `Hash[x:, y:, w:, h:, anchor_x: nil, anchor_y: nil]` or a `Hash[x:, y:, x2:, y2:]`, this function returns a `Hash[x:, y:]` representing the center point of the rect or line.

Here's an example usage of `rect_center_point`, `rect_props`, and `line_center_point`:

```ruby
def tick args
  # rect without anchors
  rect_one = {
    x: 100,
    y: 100,
    w: 100,
    h: 100
  }

  # rect center
  rect_one_center = Geometry.rect_center_point(rect_one)

  # render rect and center point
  args.outputs.sprites << rect_one.merge(path: :solid, r: 0, g: 0, b: 0)
  args.outputs.sprites << rect_one_center.merge(w: 4,
                                                h: 4,
                                                path: :solid,
                                                r: 255,
                                                g: 0,
                                                b: 0,
                                                anchor_x: 0.5,
                                                anchor_y: 0.5)

  # rect with anchors
  rect_two = {
    x: 640,
    y: 360,
    w: 100,
    h: 100,
    anchor_x: 0.5,
    anchor_y: 0.5
  }

  # rect center
  rect_two_center = Geometry.rect_center_point(rect_two)

  # render rect and center point
  args.outputs.sprites << rect_two.merge(path: :solid, r: 0, g: 0, b: 0)
  args.outputs.sprites << rect_two_center.merge(w: 4,
                                                h: 4,
                                                path: :solid,
                                                r: 255,
                                                g: 0,
                                                b: 0,
                                                anchor_x: 0.5,
                                                anchor_y: 0.5)

  # rect + center with Geometry.rect_props
  rect_three = Geometry.rect_props(x: 100, y: 600, w: 100, h: 100, anchor_x: 0.5)
  args.outputs.sprites << rect_three.merge(path: :solid, r: 0, g: 0, b: 0)
  args.outputs.sprites << rect_three.center.merge(w: 4,
                                                  h: 4,
                                                  path: :solid,
                                                  r: 255,
                                                  g: 0,
                                                  b: 0,
                                                  anchor_x: 0.5,
                                                  anchor_y: 0.5)

  # line
  line_one = { x: 640, y: 0, x2: 1280, y2: 720 }

  # line center
  line_one_center = Geometry.line_center_point(line_one)
  args.outputs.lines << line_one.merge(r: 0, g: 0, b: 0)
  args.outputs.sprites << line_one_center.merge(w: 4,
                                                h: 4,
                                                path: :solid,
                                                r: 255,
                                                g: 0,
                                                b: 0,
                                                anchor_x: 0.5,
                                                anchor_y: 0.5)
end
```

### `rect_navigate`

This function returns the next rect provided a move direction. The function is helpful for navigating controls using a keyboard or controller (like in on a menu screen).

The function takes in the following parameters:

- `rect`: The rect that navigation should originate from. Function will return `nil` if this parameter is nil.
- `rects`: A collection of rects that are candidates for navigation. Function will return `rect` if this parameter is nil or if the candidates length is 0.
- `left_right`: A number that's either -1, 0, or 1 indicating the x navigation direction.
- `up_down`: A number that's either -1, 0, or 1 indicating the y navigation direction.
- `directional_vector`: An object that responds to `x`, and `y`. The sign of these properties will be used to populate `left_right`, and `up_down` parameters.
- `wrap_x`: Determines whether the navigation will wrap around if no navigation is found in the `left_right` direction. Defaulted to `true`.
- `wrap_y`: Determines whether the navigation will wrap around if no navigation is found in the `up_down` direction. Defaulted to `true`.
- `using`: Optional lambda that can be passed in so the function knows which construct contains the properties `x`, `y`, `w`, `h` properties. If this parameter isn't provided, then the source `rect`, `rects` objects are assumed to have `x`, `y`, `w`, `h`.

Note: `directional_vector` will only be consulted if `left_right~/~up_down` aren't provided.

Example:

```ruby
def tick args
  # create buttons
  args.state.buttons ||= [
    { x: 0,   y: 520, w: 100, h: 100 },
    { x: 100, y: 520, w: 100, h: 100 },
    { x: 0,   y: 420, w: 100, h: 100 },
    { x: 100, y: 420, w: 100, h: 100 },
  ]

  # default the selected button the the first one
  args.state.selected_button ||= args.state.buttons.first

  # navigate based on the keyboard's left_right, up_down properties
  args.state.selected_button = Geometry.rect_navigate(
    rect: args.state.selected_button,
    rects: args.state.buttons,
    left_right: args.inputs.keyboard.key_down.left_right,
    up_down: args.inputs.keyboard.key_down.up_down
  )

  # render all buttons
  args.outputs.borders << args.state.buttons

  # render the selected button
  args.outputs.solids << args.state.selected_button
end
```

Using `directional_vector`:

```ruby
args.state.selected_button = Geometry.rect_navigate(
  rect: args.state.selected_button,
  rects: args.state.buttons,
  directional_vector: args.inputs.keyboard.key_down.directional_vector
)
```

Optional properties:

```ruby
args.state.selected_button = Geometry.rect_navigate(
  rect: args.state.selected_button,
  rects: args.state.buttons,
  left_right: args.inputs.keyboard.key_down.left_right,
  up_down: args.inputs.keyboard.key_down.up_down,
  wrap_x: false,
  wrap_y: false,
  using: lambda { |e| Hash[x: e.x, y: e.y, w: e.w, h: e.h] }
)
```

For a non-trivial usage, see the following sample app: `./samples/09_ui_controls/02_menu_navigation`.


### `rect_to_circle`

Invocation variants:

- `Geometry.rect_to_circle(circle)`
- `Geometry.rect_to_circle(rect)`

The parameters must be one of the following:

- A `Hash` with `x`, `y`, and `radius` (or an object that responds to `x`, `y`, and `radius`).
- A `Hash` with `x`, `y`, `w`, `h`, `anchor_x`, and `anchor_y` (or an object that responds to `x`, `y`, `w`, `h`, `anchor_x`, and `anchor_y`). If the parameter is a `Hash`, `anchor_x` and `anchor_y` are optional and default to `0`.

Given a circle or a rectangle, this function will return a rectangle that is the smallest rectangle that can contain the circle.

### `scale_rect`

Given a `Rectangle` this function returns a new rectangle with a scaled size.

- `ratio`: the ratio by which to scale the rect. A ratio of 2 will double the dimensions of the rect while a ratio of 0.5 will halve its dimensions.
- `anchor_x` and `anchor_y` specify the point within the rect from which to resize it. Setting both to 0 will affect the width and height of the rect, leaving x and y unchanged. Setting both to 0.5 will scale all sides of the rect proportionally from the center.

```ruby
def tick args
  # a rect at the center of the screen
  args.state.rect_1 ||= { x: 640 - 20, y: 360 - 20, w: 40, h: 40 }

  # render the rect
  args.outputs.borders << args.state.rect_1

  # the rect half the size with the x and y position unchanged
  args.outputs.borders << args.state.rect_1.scale_rect(0.5)

  # the rect double the size, repositioned in the center given anchor optional arguments
  args.outputs.borders << args.state.rect_1.scale_rect(2, 0.5, 0.5)
end
```

### `scale_rect_extended`

The behavior is similar to `scale_rect` except that you can independently control the scale of each axis. The parameters are all named:

- `percentage_x`: percentage to change the width (default value of 1.0)
- `percentage_y`: percentage to change the height (default value of 1.0)
- `anchor_x`: anchor repositioning of x (default value of 0.0)
- `anchor_y`: anchor repositioning of y (default value of 0.0)

```ruby
def tick args
  baseline_rect = { x: 640 - 20, y: 360 - 20, w: 40, h: 40 }
  args.state.rect_1 ||= baseline_rect
  args.state.rect_2 ||= baseline_rect.scale_rect_extended(percentage_x: 2,
                                                          percentage_y: 0.5,
                                                          anchor_x: 0.5,
                                                          anchor_y: 1.0)
  args.outputs.borders << args.state.rect_1
  args.outputs.borders << args.state.rect_2
end
```

### `anchor_rect`

Returns a new rect that is anchored by an `anchor_x` and `anchor_y` value. The width and height of the rectangle is taken into consideration when determining the anchor position:

```ruby
def tick args
  args.state.rect ||= {
    x: 640,
    y: 360,
    w: 100,
    h: 100
  }

  # rect's center: 640 + 50, 360 + 50
  args.outputs.borders << args.state.rect.anchor_rect(0, 0)

  # rect's center: 640, 360
  args.outputs.borders << args.state.rect.anchor_rect(0.5, 0.5)

  # rect's center: 640, 360
  args.outputs.borders << args.state.rect.anchor_rect(0.5, 0)
end
```

### `center_inside_rect`

Invocation variants:

- `target_rect.center_inside_rect reference_rect`
- `Geometry.center_inside_rect target_rect, reference_rect`

Given a target rect and a reference rect, the target rect is centered inside the reference rect (a new rect is returned).

```ruby
def tick args
  rect_1 = {
    x: 0,
    y: 0,
    w: 100,
    h: 100
  }

  rect_2 = {
    x: 640 - 100,
    y: 360 - 100,
    w: 200,
    h: 200
  }

  centered_rect = Geometry.center_inside_rect rect_1, rect_2
  # OR
  # centered_rect = rect_1.center_inside_rect rect_2

  args.outputs.solids << rect_1.merge(r: 255)
  args.outputs.solids << rect_2.merge(b: 255)
  args.outputs.solids << centered_rect.merge(g: 255)
end
```

### `points_to_line`

Invocation variants:

- `Geometry.points_to_line p1, p2`

Given two points (each with `x` and `y` properties), this function returns a `Hash[x:, y:, x2:, y2:]` representing a line. The line starts at point `p1` and ends at point `p2`.

```ruby
def tick args
  # define two points
  point_1 = { x: 100, y: 100 }
  point_2 = { x: 200, y: 300 }

  # convert points to a line
  line = Geometry.points_to_line(point_1, point_2)
  # returns { x: 100, y: 100, x2: 200, y2: 300 }

  # render the line
  args.outputs.lines << line
end
```

### `line_midpoint`

Invocation variants:

- `Geometry.line_midpoint line`

Given a `Hash` with `x`, `y`, `x2`, `y2` properties, this function returns a `Hash[x:, y:]` representing the midpoint of the line.

```ruby
def tick args
  # define a line
  line = { x: 100, y: 100, x2: 300, y: 300 }

  # get the midpoint
  midpoint = Geometry.line_midpoint(line)
  # returns { x: 200, y: 200 }

  # render the line
  args.outputs.lines << line

  # render a square at the midpoint
  args.outputs.sprites << {
    x: midpoint.x - 5,
    y: midpoint.y - 5,
    w: 10,
    h: 10,
    path: :solid,
    r: 255,
    g: 0,
    b: 0
  }
end
```

### `rect_to_lines`

Invocation variants:

- `Geometry.rect_to_lines rect`

Given a rectangle (with `x`, `y`, `w`, `h`, and optionally `anchor_x`, `anchor_y` properties), this function returns an array of four lines representing the edges of the rectangle. The lines are ordered as: bottom, right, top, left.

```ruby
def tick args
  # define a rectangle
  rect = { x: 100, y: 100, w: 200, h: 150 }

  # convert rect to lines
  lines = Geometry.rect_to_lines(rect)
  # returns an array of 4 lines:
  # [
  #   { x: 100, y: 100, x2: 300, y2: 100 },   # bottom edge
  #   { x: 300, y: 100, x2: 300, y2: 250 },   # right edge
  #   { x: 300, y: 250, x2: 100, y2: 250 },   # top edge
  #   { x: 100, y: 250, x2: 100, y2: 100 }    # left edge
  # ]

  # render the rectangle
  args.outputs.borders << rect

  # render each line in a different color
  args.outputs.lines << lines[0].merge(r: 255, g: 0, b: 0)     # red
  args.outputs.lines << lines[1].merge(r: 0, g: 255, b: 0)     # green
  args.outputs.lines << lines[2].merge(r: 0, g: 0, b: 255)     # blue
  args.outputs.lines << lines[3].merge(r: 255, g: 255, b: 0)   # yellow
end
```

### `zoom_rect`

Invocation variants:

- `Geometry.zoom_rect(rect:, ratio:, w_ratio:, h_ratio:)`
- `Geometry.zoom_rect(rect:, px:, w_px:, h_px:)`

Given a rectangle, this function returns a new rectangle with adjusted dimensions while maintaining the center point. You can zoom using either ratio-based or pixel-based parameters, but not both.

Returns `Hash[x:, y:, w:, h:, center: Hash[x:, y:]]`.

Ratio-based parameters:
- `ratio`: uniform scaling ratio for both width and height
- `w_ratio`: scaling ratio for width (overrides `ratio` for width)
- `h_ratio`: scaling ratio for height (overrides `ratio` for height)

Pixel-based parameters:
- `px`: uniform pixel adjustment for both width and height
- `w_px`: pixel adjustment for width (overrides `px` for width)
- `h_px`: pixel adjustment for height (overrides `px` for height)

The function ensures the resulting rectangle stays centered on the
original rectangle's center point. Negative ratios or pixel values
that would result in negative dimensions are clamped to 0.

```ruby
def tick args
  args.state.rect ||= { x: 640,
                        y: 360,
                        w: 256,
                        h: 256,
                        anchor_x: 0.5,
                        anchor_y: 0.5 }

  args.outputs.primitives << args.state.rect.merge(path: :solid, r: 30, g: 128, b: 30, a: 64)
  args.outputs.primitives << Geometry.zoom_rect(rect: args.state.rect, ratio: 1.5)
                                     .merge(path: :solid, r: 30, g: 30, b: 128, a: 64)
end
```

### `lerp_rect`

Invocation variants:

- `Geometry.lerp_rect from, to, step, tolerance: 0`

Given two rectangles and an interpolation step, this function returns
a new rectangle that represents the linear interpolation between the
`from` and `to` rectangles. This is useful for animating smooth
transitions between two rectangle states.

Returns `Hash[x:, y:, w:, h:, center: Hash[x:, y:]]`.

Parameters:
- `from`: the starting rectangle
- `to`: the ending rectangle
- `step`: the interpolation step (typically a value between `0.0` and `1.0`, where `0.0` returns the `from` rect and `1.0` returns the `to` rect)
- `tolerance`: optional tolerance parameter passed to the underlying `lerp` function (default `0`)

Each property (`x`, `y`, `w`, `h`) is independently interpolated from the `from` rectangle to the `to` rectangle.

```ruby
def tick args
  args.state.current_rect ||= { x: 0, y: 0, w: 10, h: 10 }
  args.state.final_rect ||= { x: 640, y: 360, w: 256, h: 256, anchor_x: 0.5, anchor_y: 0.5 }
  args.state.current_rect = Geometry.lerp_rect(args.state.current_rect,
                                               args.state.final_rect, 0.05)
  args.outputs.primitives << args.state
                                 .current_rect
                                 .merge(path: :solid, r: 30, g: 30, b: 30)
end
```

Here's another example that uses `Easing.smooth_stop` (the benefit being that the duration of the lerp can be predefined):

```ruby
def tick args
  args.state.start_rect ||= { x: 0, y: 0, w: 10, h: 10 }
  args.state.final_rect ||= { x: 640, y: 360, w: 256, h: 256, anchor_x: 0.5, anchor_y: 0.5 }
  perc = Easing.smooth_stop(start_at: 0, duration: 120, tick_count: Kernel.tick_count, power: 2)
  progress_rect = Geometry.lerp_rect(args.state.start_rect, args.state.final_rect, perc)
  args.outputs.primitives << progress_rect.merge(path: :solid, r: 30, g: 30, b: 30)
end
```

## Perlin Noise Functions

The following functions provide access to various Perlin noise
algorithms for procedural content generation. All noise functions
expect normalized coordinates (x, y, z) in the range [-1, 1] and
return float values typically in the range [-1, 1].

?> See sample app `./samples/08_procgen/01_perlin_noise` for visualization of each of these functions.

### `perlin_noise`

Invocation variants:

- `Geometry.perlin_noise(x, y, z, x_wrap, y_wrap, z_wrap)`

Generates basic 3D Perlin noise at the given coordinates.

Parameters:
- `x`, `y`, `z`: Normalized coordinates in the range [-1, 1]
- `x_wrap`, `y_wrap`, `z_wrap`: Wrapping values for tiling (use 0 for no wrapping)

Returns a float value representing the noise at the given coordinates.

```ruby
def tick args
  # Initialize results hash once
  args.state.perlin_noise_results ||= generate_perlin_noise_texture(args)

  # Render the noise texture
  args.outputs.primitives << { x: 100, y: 100, w: 196, h: 196, path: :perlin_noise }
end

def generate_perlin_noise_texture args
  results = {}

  # Set up render target
  args.outputs[:perlin_noise].set w: 196, h: 196, background_color: [0, 0, 0]

  # Generate noise for each pixel
  196.times do |x|
    results[x] = {}
    196.times do |y|
      # Normalize coordinates to range centered at 0
      normalized_x = (x - 98).fdiv(196)
      normalized_y = (y - 98).fdiv(196)

      # Generate noise value
      noise = Geometry.perlin_noise(normalized_x, normalized_y, 0, 0, 0, 0)
      results[x][y] = noise

      # Convert noise to grayscale and render
      gray_color = 128 + 128 * noise
      args.outputs[:perlin_noise] << { x: x, y: y, w: 1, h: 1,
                                       path: :solid,
                                       r: gray_color, g: gray_color, b: gray_color }
    end
  end

  results
end
```

### `perlin_noise_seed`

Invocation variants:

- `Geometry.perlin_noise_seed(x, y, z, x_wrap, y_wrap, z_wrap, seed)`

Generates 3D Perlin noise with a custom seed value for reproducible results.

Parameters:
- `x`, `y`, `z`: Normalized coordinates in the range [-1, 1]
- `x_wrap`, `y_wrap`, `z_wrap`: Wrapping values for tiling (use 0 for no wrapping)
- `seed`: Integer seed value for reproducible noise generation

Returns a float value representing the noise at the given coordinates.

```ruby
PERLIN_SIZE = 196

def tick args
  # Initialize results hash once
  args.state.perlin_noise_seed_results ||= generate_perlin_noise_seed_texture(args)

  # Render the noise texture
  args.outputs.primitives << { x: 100, y: 100, w: PERLIN_SIZE, h: PERLIN_SIZE,
                               path: :perlin_noise_seed }
end

def generate_perlin_noise_seed_texture args
  results = {}
  seed = DR.rng_seed

  # Set up render target
  args.outputs[:perlin_noise_seed].set w: PERLIN_SIZE,
                                       h: PERLIN_SIZE,
                                       background_color: [0, 0, 0]

  # Generate noise for each pixel
  PERLIN_SIZE.times do |x|
    results[x] = {}
    PERLIN_SIZE.times do |y|
      # Normalize coordinates to range centered at 0
      normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
      normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)

      # Generate noise value with seed
      noise = Geometry.perlin_noise_seed(normalized_x, normalized_y, 0, 0, 0, 0, seed)
      results[x][y] = noise

      # Convert noise to grayscale and render
      gray_color = 128 + 128 * noise
      args.outputs[:perlin_noise_seed] << { x: x, y: y, w: 1, h: 1,
                                            path: :solid,
                                            r: gray_color, g: gray_color, b: gray_color }
    end
  end

  results
end
```

### `perlin_ridge_noise`

Invocation variants:

- `Geometry.perlin_ridge_noise(x, y, z, lacunarity, gain, offset, octaves)`

Generates ridge noise, useful for creating mountain ridges and sharp terrain features.

Parameters:
- `x`, `y`, `z`: Normalized coordinates in the range [-1, 1]
- `lacunarity`: Controls the frequency increase per octave (typically 2.0)
- `gain`: Controls the amplitude decrease per octave (typically 0.5)
- `offset`: Ridge offset value (typically 1.0)
- `octaves`: Number of noise layers to combine (typically 6)

Returns a float value representing the ridge noise at the given coordinates.

```ruby
PERLIN_SIZE = 196

def tick args
  # Initialize results hash once
  args.state.perlin_ridge_noise_results ||= generate_perlin_ridge_noise_texture(args)

  # Render the noise texture
  args.outputs.primitives << { x: 100, y: 100, w: PERLIN_SIZE, h: PERLIN_SIZE,
                               path: :perlin_ridge_noise }
end

def generate_perlin_ridge_noise_texture args
  results = {}

  # Set up render target
  args.outputs[:perlin_ridge_noise].set w: PERLIN_SIZE,
                                        h: PERLIN_SIZE,
                                        background_color: [0, 0, 0]

  # Generate noise for each pixel
  PERLIN_SIZE.times do |x|
    results[x] = {}
    PERLIN_SIZE.times do |y|
      # Normalize coordinates to range centered at 0
      normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
      normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)

      # Generate ridge noise with standard parameters
      noise = Geometry.perlin_ridge_noise(normalized_x, normalized_y, 0,
                                          2.0,  # lacunarity
                                          0.5,  # gain
                                          1.0,  # offset
                                          6)    # octaves
      results[x][y] = noise

      # Convert noise to grayscale and render
      gray_color = 128 + 128 * noise
      args.outputs[:perlin_ridge_noise] << { x: x, y: y, w: 1, h: 1,
                                             path: :solid,
                                             r: gray_color, g: gray_color, b: gray_color }
    end
  end

  results
end
```

### `perlin_fbm_noise`

Invocation variants:

- `Geometry.perlin_fbm_noise(x, y, z, lacunarity, gain, octaves)`

Generates Fractional Brownian Motion (fBm) noise, useful for natural-looking textures like clouds, terrain, and wood grain.

Parameters:
- `x`, `y`, `z`: Normalized coordinates in the range [-1, 1]
- `lacunarity`: Controls the frequency increase per octave (typically 2.0)
- `gain`: Controls the amplitude decrease per octave (typically 0.5)
- `octaves`: Number of noise layers to combine (typically 6)

Returns a float value representing the fBm noise at the given coordinates.

```ruby
PERLIN_SIZE = 196

def tick args
  # Initialize results hash once
  args.state.perlin_fbm_noise_results ||= generate_perlin_fbm_noise_texture(args)

  # Render the noise texture
  args.outputs.primitives << { x: 100, y: 100, w: PERLIN_SIZE, h: PERLIN_SIZE,
                               path: :perlin_fbm_noise }
end

def generate_perlin_fbm_noise_texture args
  results = {}

  # Set up render target
  args.outputs[:perlin_fbm_noise].set w: PERLIN_SIZE,
                                      h: PERLIN_SIZE,
                                      background_color: [0, 0, 0]

  # Generate noise for each pixel
  PERLIN_SIZE.times do |x|
    results[x] = {}
    PERLIN_SIZE.times do |y|
      # Normalize coordinates to range centered at 0
      normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
      normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)

      # Generate fBm noise with standard parameters
      noise = Geometry.perlin_fbm_noise(normalized_x, normalized_y, 0,
                                        2.0,  # lacunarity
                                        0.5,  # gain
                                        6)    # octaves
      results[x][y] = noise

      # Convert noise to grayscale and render
      gray_color = 128 + 128 * noise
      args.outputs[:perlin_fbm_noise] << { x: x, y: y, w: 1, h: 1,
                                           path: :solid,
                                           r: gray_color, g: gray_color, b: gray_color }
    end
  end

  results
end
```

### `perlin_turbulence_noise`

Invocation variants:

- `Geometry.perlin_turbulence_noise(x, y, z, lacunarity, gain, octaves)`

Generates turbulence noise using absolute values, useful for marble, fire, and liquid effects.

Parameters:
- `x`, `y`, `z`: Normalized coordinates in the range [-1, 1]
- `lacunarity`: Controls the frequency increase per octave (typically 2.0)
- `gain`: Controls the amplitude decrease per octave (typically 0.5)
- `octaves`: Number of noise layers to combine (typically 6)

Returns a float value representing the turbulence noise at the given coordinates.

```ruby
PERLIN_SIZE = 196

def tick args
  # Initialize results hash once
  args.state.perlin_turbulence_noise_results ||= generate_perlin_turbulence_noise_texture(args)

  # Render the noise texture
  args.outputs.primitives << { x: 100, y: 100, w: PERLIN_SIZE, h: PERLIN_SIZE,
                               path: :perlin_turbulence_noise }
end

def generate_perlin_turbulence_noise_texture args
  results = {}

  # Set up render target
  args.outputs[:perlin_turbulence_noise].set w: PERLIN_SIZE,
                                             h: PERLIN_SIZE,
                                             background_color: [0, 0, 0]

  # Generate noise for each pixel
  PERLIN_SIZE.times do |x|
    results[x] = {}
    PERLIN_SIZE.times do |y|
      # Normalize coordinates to range centered at 0
      normalized_x = (x - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)
      normalized_y = (y - PERLIN_SIZE.idiv(2)).fdiv(PERLIN_SIZE)

      # Generate turbulence noise with standard parameters
      noise = Geometry.perlin_turbulence_noise(normalized_x, normalized_y, 0,
                                               2.0,  # lacunarity
                                               0.5,  # gain
                                               6)    # octaves
      results[x][y] = noise

      # Convert noise to grayscale and render
      gray_color = 128 + 128 * noise
      args.outputs[:perlin_turbulence_noise] << { x: x, y: y, w: 1, h: 1,
                                                  path: :solid,
                                                  r: gray_color, g: gray_color, b: gray_color }
    end
  end

  results
end
```

### `cubic_bezier_vec2`

Given control points `p0`, `p1`, `p2`, `p3` (each with type `Hash[:x, :y]`),
and `t` (`Float` value between `0.0` and `1.0`). This function
returns a point interpolated for time `t`. 

See the following sample for non-trivial usage of this function: `./samples/08_tweening_lerping_easing_functions/02_cubic_bezier`.
