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
  # Map is used to set values of 2000 other bodies
  # All bodies that intersect with center body are stored in collisions collection
  args.state.center_body  ||= [640 - 100, 360 - 100, 200, 200] # calculations done to place body in center
  args.state.other_bodies ||= 2000.map { [1280 * rand, 720 * rand, 10, 10] } # 2000 bodies given random position on screen

  # finds all bodies that intersect with center body, stores them in collisions
  collisions = args.state.other_bodies.find_all { |b| b.intersect_rect? args.state.center_body }

  args.borders << args.state.center_body # outputs center body as a black border

  # transparency changes based on number of collisions; the more collisions, the redder (more transparent) the box becomes
  args.solids  << [args.state.center_body, 255, 0, 0, collisions.length * 5] # center body is red solid
  args.solids  << args.state.other_bodies # other bodies are output as (black) solids, as well

  args.labels  << [10, 30, args.gtk.current_framerate] # outputs frame rate in bottom left corner

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
