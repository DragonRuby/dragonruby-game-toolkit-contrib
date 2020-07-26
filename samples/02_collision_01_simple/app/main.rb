=begin

 Reminders:
 - ARRAY#intersect_rect?: Returns true or false depending on if the two rectangles intersect.

 - args.outputs.solids: An array. The values generate a solid.
   The parameters are [X, Y, WIDTH, HEIGHT, RED, GREEN, BLUE]

=end

# This sample app shows collisions between two boxes.

# Runs methods needed for game to run properly.
def tick args
  tick_instructions args, "Sample app shows how to move a square over time and determine collision."
  defaults args
  render args
  calc args
end

# Sets default values.
def defaults args
  # These values represent the moving box.
  args.state.moving_box_speed   = 10
  args.state.moving_box_size    = 100
  args.state.moving_box_dx    ||=  1
  args.state.moving_box_dy    ||=  1
  args.state.moving_box       ||= [0, 0, args.state.moving_box_size, args.state.moving_box_size] # moving_box_size is set as the width and height

  # These values represent the center box.
  args.state.center_box ||= [540, 260, 200, 200, 180]
  args.state.center_box_collision ||= false # initially no collision
end

def render args
  # If the game state denotes that a collision has occured,
  # render a solid square, otherwise render a border instead.
  if args.state.center_box_collision
    args.outputs.solids << args.state.center_box
  else
    args.outputs.borders << args.state.center_box
  end

  # Then render the moving box.
  args.outputs.solids << args.state.moving_box
end

# Generally in a pipeline for a game engine, you have rendering,
# game simulation (calculation), and input processing.
# This fuction represents the game simulation.
def calc args
  position_moving_box args
  determine_collision_center_box args
end

# Changes the position of the moving box on the screen by multiplying the change in x (dx) and change in y (dy) by the speed,
# and adding it to the current position.
# dx and dy are positive if the box is moving right and up, respectively
# dx and dy are negative if the box is moving left and down, respectively
def position_moving_box args
  args.state.moving_box.x += args.state.moving_box_dx * args.state.moving_box_speed
  args.state.moving_box.y += args.state.moving_box_dy * args.state.moving_box_speed

  # 1280x720 are the virtual pixels you work with (essentially 720p).
  screen_width  = 1280
  screen_height = 720

  # Position of the box is denoted by the bottom left hand corner, in
  # that case, we have to subtract the width of the box so that it stays
  # in the scene (you can try deleting the subtraction to see how it
  # impacts the box's movement).
  if args.state.moving_box.x > screen_width - args.state.moving_box_size
    args.state.moving_box_dx = -1 # moves left
  elsif args.state.moving_box.x < 0
    args.state.moving_box_dx =  1 # moves right
  end

  # Here, we're making sure the moving box remains within the vertical scope of the screen
  if args.state.moving_box.y > screen_height - args.state.moving_box_size # if the box moves too high
    args.state.moving_box_dy = -1 # moves down
  elsif args.state.moving_box.y < 0 # if the box moves too low
    args.state.moving_box_dy =  1 # moves up
  end
end

def determine_collision_center_box args
  # Collision is handled by the engine. You simply have to call the
  # `intersect_rect?` function.
  if args.state.moving_box.intersect_rect? args.state.center_box # if the two boxes intersect
    args.state.center_box_collision = true # then a collision happened
  else
    args.state.center_box_collision = false # otherwise, no collision happened
  end
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end
