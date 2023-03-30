# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# geometry_docs.rb has been released under MIT (*only this file*).

module GeometryDocs
  def docs_method_sort_order
    [
      :docs_class,
      :docs_intersect_rect?,
      :docs_inside_rect?,
      :docs_scale_rect,
      :docs_scale_rect_extended,
      :docs_anchor_rect,
      :docs_angle_from,
      :docs_angle_to,
      :docs_distance,
      :docs_point_inside_circle?,
      :docs_center_inside_rect,
      :docs_ray_test,
      :docs_line_rise_run,
      #:docs_cubic_bezier
      :docs_rotate_point,
      :docs_find_intersect_rect,
      :docs_find_all_intersect_rect,
      :docs_find_intersect_rect_quad_tree,
      :docs_quad_tree_create,
    ]
  end

  def docs_class
    <<-S
* ~Geometry~

The Geometry ~module~ contains methods for calculations that are
frequently used in game development. For convenience, this ~module~ is
mixed into ~Hash~, ~Array~, and DragonRuby's ~Entity~ class. It is
also available in a functional variant at ~args.geometry~.

Many of the geometric functions assume the objects have a certain
shape:

- ~Points~ are assumed to respond to ~x, y~.
- ~Rectangles~ are assumed to respond to ~x, y, w, h~.
- ~Lines~ are assumed to respond to ~x, y, x2, y2~.

#+begin_src
  def tick args
    # Geometry is mixed into Hash, Array, and Entity

    # define to rectangles
    rect_1 = { x: 0, y: 0, w: 100, h: 100 }
    rect_2 = { x: 50, y: 50, w: 100, h: 100 }

    # call geometry method function from instance of a Hash class
    puts rect_1.intersect_rect?(rect_2)

    # OR

    # use the geometry methods functionally
    puts args.geometry.intersect_rect?(rect_1, rect_2)
  end
#+end_src
S
  end

  def docs_find_intersect_rect
    <<-S
** ~find_intersect_rect~

Given a rect and a collection of rects, ~find_intersect_rect~ returns the first rect
that intersects with the the first parameter. If you find yourself doing this:

#+begin_src
  collision = args.state.terrain.find { |t| t.intersect_rect? args.state.player }
#+end_src

Consider using ~find_intersect_rect~ instead (it's more descriptive and faster):

#+begin_src
  collision = args.geometry.find_intersect_rect args.state.player, args.state.terrain
#+end_src

S
  end

  def docs_find_all_intersect_rect
    <<-S
** ~find_all_intersect_rect~

Given a rect and a collection of rects, ~find_all_intersect_rect~ returns all rects
that intersects with the the first parameter. If you find yourself doing this:

#+begin_src
  collisions = args.state.terrain.find_all { |t| t.intersect_rect? args.state.player }
#+end_src

Consider using ~find_all_intersect_rect~ instead (it's more descriptive and faster):

#+begin_src
  collisions = args.geometry.find_all_intersect_rect args.state.player, args.state.terrain
#+end_src

S
  end

  def docs_create_quad_tree
    <<-S
* ~create_quad_tree~

Generates a quad tree from an array of rectangles. See ~find_intersect_rect_quad_tree~
for usage.

S
  end

  def docs_find_intersect_rect_quad_tree
    <<-S
** ~find_intersect_rect_quad_tree~

This is a faster collision algorithm for determining if a
rectangle intersects any rectangle in an array. In order to use
~find_intersect_rect_quad_tree~, you must first generate a quad
tree data structure using ~create_quad_tree~. Use this function
if ~find_intersect_rect~ isn't fast enough.
#+begin_src
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
    args.state.quad_tree ||= args.geometry.quad_tree_create args.state.boxes

    # use quad tree and find_intersect_rect_quad_tree to determine collision with player
    collision = args.geometry.find_intersect_rect_quad_tree args.state.player,
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
#+end_src
S
  end

  def docs_anchor_rect
    <<-S
** ~anchor_rect~

Returns a new rect that is anchored by an ~anchor_x~ and ~anchor_y~ value.
The width and height of the rectangle is taken into consideration when
determining the anchor position:

#+begin_src
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
#+end_src


S
  end

  def docs_angle_from
    <<-S
** ~angle_from~

Invocation variants:

- ~args.geometry.angle_from start_point, end_point~
- ~start_point.angle_from end_point~

Returns an angle in degrees from the ~end_point~ to the
~start_point~ (if you want the value in radians, you can
call ~.to_radians~ on the value returned):

#+begin_src
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
    args.outputs.labels << { x: 30, y: 30.from_top, text: "\#{angle}, \#{angle_radians}" }

    angle = args.geometry.angle_from rect_1, rect_2 # returns 225 degrees
    angle_radians = angle.to_radians
    args.outputs.labels << { x: 30, y: 60.from_top, text: "\#{angle}, \#{angle_radians}" }
  end
#+end_src
S
  end

  def docs_angle_to
    <<-S
** ~angle_to~

Invocation variants:

- ~args.geometry.angle_to start_point, end_point~
- ~start_point.angle_to end_point~

Returns an angle in degrees to the ~end_point~ from the
~start_point~ (if you want the value in radians, you can
call ~.to_radians~ on the value returned):

#+begin_src
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
    args.outputs.labels << { x: 30, y: 30.from_top, text: "\#{angle}, \#{angle_radians}" }

    angle = args.geometry.angle_to rect_1, rect_2 # returns 45 degrees
    angle_radians = angle.to_radians
    args.outputs.labels << { x: 30, y: 60.from_top, text: "\#{angle}, \#{angle_radians}" }
  end
#+end_src
S
  end

  def docs_distance
    <<-S
** ~distance~

Returns the distance between two points;

#+begin_src
  def tick args
    rect_1 ||= {
      x: 0,
      y: 0,
    }

    rect_2 ||= {
      x: 100,
      y: 100,
    }

    distance = args.geometry.distance rect_1, rect_2
    args.outputs.labels << {
      x: 30,
      y: 30.from_top,
      text: "\#{distance}"
    }

    args.outputs.lines << {
      x: rect_1.x,
      y: rect_1.y,
      x2: rect_2.x,
      y2: rect_2.y
    }
  end
#+end_src
    S
  end

  def docs_point_inside_circle?
    <<-S
** ~point_inside_circle?~

Invocation variants:

- ~point_1.point_inside_circle? circle_center, circle_radius~
- ~args.geometry.point_inside_circle? point_1, circle_center, circle_radius~

Returns ~true~ if a point is inside of a circle defined as a center point and radius.

#+begin_src
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
    intersection = args.geometry.point_inside_circle? args.state.point_1,
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
#+end_src
S
  end

  def docs_center_inside_rect
    <<-S
** ~center_inside_rect~

Invocation variants:
- ~target_rect.center_inside_rect reference_rect~
- ~args.geometry.center_inside_rect target_rect, reference_rect~

Given a target rect and a reference rect, the target rect is
centered inside the reference rect (a new rect is returned).

#+begin_src
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

    centered_rect = args.geometry.center_inside_rect rect_1, rect_2
    # OR
    # centered_rect = rect_1.center_inside_rect rect_2

    args.outputs.solids << rect_1.merge(r: 255)
    args.outputs.solids << rect_2.merge(b: 255)
    args.outputs.solids << centered_rect.merge(g: 255)
  end
#+end_src

S
  end

  def docs_ray_test
    <<-S
** ~ray_test~

Given a point and a line, ~ray_test~ returns one of
the following symbols based on the location of the
point relative to the line: ~:left~, ~:right~, ~:on~

#+begin_src
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
    ray = args.geometry.ray_test point, line

    # output the results of ray test at mouse location
    args.outputs.labels << {
      x: point.x,
      y: point.y + 25,
      text: "\#{ray}",
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
#+end_src
S
  end

  def docs_line_rise_run
    <<-S
** ~line_rise_run~

Given a line, this function returns a Hash with ~x~ and ~y~ keys
representing a normalized representation of the rise and run of
the line.

#+begin_src
  def tick args
    # draw a line from the bottom left to the top right
    line = {
      x: 0,
      y: 0,
      x2: 1280,
      y2: 720
    }

    # get rise and run of line
    rise_run = args.geometry.line_rise_run line

    # output the rise and run of line
    args.outputs.labels << {
      x: 640,
      y: 360,
      text: "\#{rise_run}",
      alignment_enum: 1,
      vertical_alignment_enum: 1,
    }

    # render the line
    args.outputs.lines << line
  end
#+end_src

S
  end

  def docs_rotate_point
    <<-S
** ~rotate_point~

Given a point and an angle in degrees, a new point is returned
that is rotated around the origin by the degrees amount. An
optional third argument can be provided to rotate the angle
around a point other than the origin.

#+begin_src
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
    rotated_point_1 = args.geometry.rotate_point point_1,
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
    rotated_point_2 = args.geometry.rotate_point point_2,
                                                 args.state.rotate_amount,
                                                 x: 640, y: 360

    args.outputs.solids << {
      x: rotated_point_2.x - 5,
      y: rotated_point_2.y - 5,
      w: 10,
      h: 10
    }
  end
#+end_src
S
  end


  def docs_intersect_rect?
    <<-S
** ~intersect_rect?~

Invocation variants:

- ~instance.intersect_rect?(other, tolerance)~
- ~args.geometry.intersect_rect?(rect_1, rect_2, tolerance)~
- ~args.inputs.mouse.intersect_rect?(other, tolerance)~

Given two rectangle primitives this function will return ~true~ or
~false~ depending on if the two rectangles intersect or not. An
optional final parameter can be passed in representing the ~tolerence~
of overlap needed to be considered a true intersection. The default
value of ~tolerance~ is ~0.1~ which keeps the function from returning
true if only the edges of the rectangles overlap.

Here is an example where one rectangle is stationary, and another
rectangle is controlled using directional input. The rectangles change
color from blue to read if they intersect.

#+begin_src
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
#+end_src
S
  end

  def docs_intersect_rect?
    <<-S
** ~inside_rect?~

Invocation variants:

- ~instance.inside_rect?(other)~
- ~args.geometry.inside_rect?(rect_1, rect_2)~

Given two rectangle primitives this function will return ~true~ or
~false~ depending on if the first rectangle (or ~self~) is inside of the
second rectangle.

Here is an example where one rectangle is stationary, and another
rectangle is controlled using directional input. The rectangles change
color from blue to read if the movable rectangle is entirely inside
the stationary rectangle.

#+begin_src
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
#+end_src
S
  end

  def docs_scale_rect
    <<-S
** ~scale_rect~

Given a ~Rectangle~ this function returns a new rectangle with a scaled size.

- ~ratio~: the ratio by which to scale the rect. A ratio of 2 will double the dimensions of the rect while a ratio of 0.5 will halve its dimensions.
- ~anchor_x~ and ~anchor_y~ specify the point within the rect from which to resize it. Setting both to 0 will affect the width and height of the rect, leaving x and y unchanged. Setting both to 0.5 will scale all sides of the rect proportionally from the center.

#+begin_src ruby
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
#+end_src
S
  end

  def docs_scale_rect_extended
    <<-S
** ~scale_rect_extended~

The behavior is similar to ~scale_rect~ except that you can
independently control the scale of each axis. The
parameters are all named:

- ~percentage_x~: percentage to change the width (default value of 1.0)
- ~percentage_y~: percentage to change the height (default value of 1.0)
- ~anchor_x~: anchor repositioning of x (default value of 0.0)
- ~anchor_y~: anchor repositioning of y (default value of 0.0)

#+begin_src ruby
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
#+end_src
S
  end

  # todo
  # point_inside_circle?
  # anchor_rect
  # center_inside_rect
  # rect_center_point
  # rotate_point
  # angle_from
  # angle_to
  # distance
  # cubic_bezier
  # line_intersect
  # find_collisions
  # find_intersect_rect
  # find_intersect_rect_quad_tree
  # quad_tree_create
  # angle_between_lines
  # cubic_bezier
  # distance
  # line_intersect
  # line_rect
  # line_rise_run
  # line_slope
  # line_y_intercept
  # point_inside_circle?
  # point_inside_circle?
  # ray_test
  # rect_center_point
  # rect_center_point
  # rect_to_line
  # scale_rect
  # scale_rect_extended
  # shift_line
  # shift_rect
  # to_square
end

module Geometry
  extend Docs
  extend GeometryDocs
end
