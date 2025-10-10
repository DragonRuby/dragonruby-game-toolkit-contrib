#  Reminders:
#  - Geometry.intersect_rect?:
#    Returns true or false depending on if the two rectangles intersect.
#
#  - args.outputs.sprites: give this collection a hash to render a sprite.
#    Setting the sprite path to :solid will render a solid square
#    The parameters are { x: X, y: Y, w: WIDTH, h: HEIGHT, sprite: PATH, r: RED, g: GREEN, b: BLUE }

# This sample app shows collisions between two boxes. and screen edges.

# entry point of the game
def tick args
  defaults args
  calc args
  render args
end

# Sets default values.
def defaults args
  # moving_box_size is set as the width and height
  args.state.moving_box ||= {
    x: 0,
    y: 0,
    w: 100,
    h: 100,
    path: :solid,
    r: 0,
    g: 0,
    b: 0,
    dx: 1,     # represents the current x movement direction
    dy: 1,     # represents the current y movement direction
    speed: 10  # speed of movement
  }

  # These values represent the center box.
  args.state.center_box ||= {
    x: 540,
    y: 260,
    w: 200,
    h: 200,
    path: :solid,
    r: 180,
    g: 0,
    b: 0
  }

  args.state.center_box_collision ||= false # initially no collision
end

def render args
  # If the game state denotes that a collision has occurred,
  # render a solid square, otherwise render a border instead.
  if args.state.center_box_collision
    args.outputs.sprites << args.state.center_box
  else
    args.outputs.borders << args.state.center_box
  end

  # Then render the moving box.
  args.outputs.sprites << args.state.moving_box
end

# Generally in a pipeline for a game engine, you have rendering,
# game simulation (calculation), and input processing.
# This fuction represents the game simulation.
def calc args
  position_moving_box args.state.moving_box
  determine_collision_center_box args
end

# Changes the position of the moving box on the screen by multiplying the change in x (dx) and change in y (dy) by the speed,
# and adding it to the current position.
# dx and dy are positive if the box is moving right and up, respectively
# dx and dy are negative if the box is moving left and down, respectively
def position_moving_box box
  box.x += box.dx * box.speed
  box.y += box.dy * box.speed

  # 1280x720 are the virtual pixels you work with (essentially 720p).
  screen_width  = 1280
  screen_height = 720

  # Position of the box is denoted by the bottom left hand corner, in
  # that case, we have to subtract the width of the box so that it stays
  # in the scene (you can try deleting the subtraction to see how it
  # impacts the box's movement).
  if box.x + box.w > screen_width # if the box moves too far right
    box.dx = -1 # moves left
  elsif box.x < 0
    box.dx =  1 # moves right
  end

  # Here, we're making sure the moving box remains within the vertical scope of the screen
  if box.y + box.h > screen_height # if the box moves too high
    box.dy = -1 # moves down
  elsif box.y < 0 # if the box moves too low
    box.dy =  1 # moves up
  end
end

def determine_collision_center_box args
  # Collision is handled by the engine. You simply have to call the
  # `intersect_rect?` function.
  if Geometry.intersect_rect? args.state.moving_box, args.state.center_box # if the two boxes intersect
    args.state.center_box_collision = true # then a collision happened
  else
    args.state.center_box_collision = false # otherwise, no collision happened
  end
end

GTK.reset
