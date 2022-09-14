=begin

 Reminders:
 - find_all: Finds all elements of a collection that meet certain requirements.
   In this sample app, we're finding all bodies that intersect with the center body.

 - args.outputs.solids: An array. The values generate a solid.
   The parameters are [X, Y, WIDTH, HEIGHT, RED, GREEN, BLUE]
   For more information about solids, go to mygame/documentation/03-solids-and-borders.md.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

 - ARRAY#intersect_rect?: Returns true or false depending on if two rectangles intersect.

=end

# This code demonstrates moving objects that loop around once they exceed the scope of the screen,
# which has dimensions of 1280 by 720, and also detects collisions between objects called "bodies".

def body_count num
  $gtk.args.state.other_bodies = num.map { [1280 * rand, 720 * rand, 10, 10] } # other_bodies set using num collection
end

def tick args

  # Center body's values are set using an array
  # Map is used to set values of 5000 other bodies
  # All bodies that intersect with center body are stored in collisions collection
  args.state.center_body  ||= { x: 640 - 100, y: 360 - 100, w: 200, h: 200 } # calculations done to place body in center
  args.state.other_bodies ||= 5000.map do
    { x: 1280 * rand,
      y: 720 * rand,
      w: 2,
      h: 2,
      path: :pixel,
      r: 0,
      g: 0,
      b: 0 }
  end # 2000 bodies given random position on screen

  # finds all bodies that intersect with center body, stores them in collisions
  collisions = args.state.other_bodies.find_all { |b| b.intersect_rect? args.state.center_body }

  args.borders << args.state.center_body # outputs center body as a black border

  # transparency changes based on number of collisions; the more collisions, the redder (more transparent) the box becomes
  args.sprites  << { x: args.state.center_body.x,
                     y: args.state.center_body.y,
                     w: args.state.center_body.w,
                     h: args.state.center_body.h,
                     path: :pixel,
                     a: collisions.length.idiv(2), # alpha value represents the number of collisions that occured
                     r: 255,
                     g: 0,
                     b: 0 } # center body is red solid
  args.sprites  << args.state.other_bodies # other bodies are output as (black) solids, as well

  args.labels  << [10, 30, args.gtk.current_framerate.to_sf] # outputs frame rate in bottom left corner

  # Bodies are returned to bottom left corner if positions exceed scope of screen
  args.state.other_bodies.each do |b| # for each body in the other_bodies collection
    b.x += 5 # x and y are both incremented by 5
    b.y += 5
    b.x = 0 if b.x > 1280 # x becomes 0 if star exceeds scope of screen (goes too far right)
    b.y = 0 if b.y > 720 # y becomes 0 if star exceeds scope of screen (goes too far up)
  end
end

# Resets the game.
$gtk.reset
