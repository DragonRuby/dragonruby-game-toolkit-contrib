=begin
 APIs listing that haven't been encountered in previous sample apps:

 - merge: Returns a hash containing the contents of two original hashes.
   Merge does not allow duplicate keys, so the value of a repeated key
   will be overwritten.

   For example, if we had two hashes
   h1 = { "a" => 1, "b" => 2}
   h2 = { "b" => 3, "c" => 3}
   and we called the command
   h1.merge(h2)
   the result would the following hash
   { "a" => 1, "b" => 3, "c" => 3}.

 Reminders:

 - Hashes: Collection of unique keys and their corresponding values. The value can be found
   using their keys.
   In this sample app, we're using a hash to create a sprite.

 - args.outputs.sprites: An array. The values generate a sprite.
   The parameters are [X, Y, WIDTH, HEIGHT, PATH, ANGLE, ALPHA, RED, GREEN, BLUE]
   Before continuing with this sample app, it is HIGHLY recommended that you look
   at mygame/documentation/05-sprites.md.

 - args.inputs.keyboard.key_held.KEY: Determines if a key is being pressed.
   For more information about the keyboard, go to mygame/documentation/06-keyboard.md.

 - args.inputs.controller_one: Takes input from the controller based on what key is pressed.
   For more information about the controller, go to mygame/documentation/08-controllers.md.

 - num1.lesser(num2): Finds the lower value of the given options.

=end

# This sample app shows a car moving across the screen. It loops back around if it exceeds the dimensions of the screen,
# and also can be moved in different directions through keyboard input from the user.

# Calls the methods necessary for the game to run successfully.
def tick args
  default args
  render args.grid, args.outputs, args.state
  calc args.state
  process_inputs args
end

# Sets default values for the car sprite
# Initialization ||= only happens in the first frame
def default args
  args.state.sprite.width    = 19
  args.state.sprite.height   = 10
  args.state.sprite.scale    = 4
  args.state.max_speed       = 5
  args.state.x             ||= 100
  args.state.y             ||= 100
  args.state.speed         ||= 1
  args.state.angle         ||= 0
end

# Outputs sprite onto screen
def render grid, outputs, state
  outputs.solids  <<  [grid.rect, 70, 70, 70] # outputs gray background
  outputs.sprites <<  [destination_rect(state), # sets first four parameters of car sprite
  'sprites/86.png', # image path of car
  state.angle,
  opacity, # transparency
  saturation,
  source_rect(state), # sprite sub division/tile (tile x, y, w, h)
  false, false,  # don't flip sprites
  rotation_anchor]

  # also look at the create_sprite helper method
  #
  # For example:
  #
  # dest   = destination_rect(state)
  # source = source_rect(state),
  # outputs.sprites << create_sprite(
  #   'sprites/86.png',
  #   x: dest.x,
  #   y: dest.y,
  #   w: dest.w,
  #   h: dest.h,
  #   angle: state.angle,
  #   source_x: source.x,
  #   source_y: source.y,
  #   source_w: source.w,
  #   source_h: source.h,
  #   flip_h: false,
  #   flip_v: false,
  #   rotation_anchor_x: 0.7,
  #   rotation_anchor_y: 0.5
  # )
end

# Creates sprite by setting values inside of a hash
def create_sprite path, options = {}
  options = {

    # dest x, y, w, h
    x: 0,
    y: 0,
    w: 100,
    h: 100,

    # angle, rotation
    angle: 0,
    rotation_anchor_x: 0.5,
    rotation_anchor_y: 0.5,

    # color saturation (red, green, blue), transparency
    r: 255,
    g: 255,
    b: 255,
    a: 255,

    # source x, y, width, height
    source_x: 0,
    source_y: 0,
    source_w: -1,
    source_h: -1,

    # flip horiztonally, flip vertically
    flip_h: false,
    flip_v: false,

  }.merge options

  [
    options[:x], options[:y], options[:w], options[:h], # dest rect keys
    path,
    options[:angle], options[:a], options[:r], options[:g], options[:b], # angle, color, alpha
    options[:source_x], options[:source_y], options[:source_w], options[:source_h], # source rect keys
    options[:flip_h], options[:flip_v], # flip
    options[:rotation_anchor_x], options[:rotation_anchor_y], # rotation anchor
  ] # hash keys contain corresponding values
end

# Calls the calc_pos and calc_wrap methods.
def calc state
  calc_pos state
  calc_wrap state
end

# Changes sprite's position on screen
# Vectors have magnitude and direction, so the incremented x and y values give the car direction
def calc_pos state
  state.x     += state.angle.vector_x * state.speed # increments x by product of angle's x vector and speed
  state.y     += state.angle.vector_y * state.speed # increments y by product of angle's y vector and speed
  state.speed *= 1.1 # scales speed up
  state.speed  = state.speed.lesser(state.max_speed) # speed is either current speed or max speed, whichever has a lesser value (ensures that the car doesn't go too fast or exceed the max speed)
end

# The screen's dimensions are 1280x720. If the car goes out of scope,
# it loops back around on the screen.
def calc_wrap state

  # car returns to left side of screen if it disappears on right side of screen
  # sprite.width refers to tile's size, which is multipled by scale (4) to make it bigger
  state.x = -state.sprite.width * state.sprite.scale if state.x - 20 > 1280

  # car wraps around to right side of screen if it disappears on the left side
  state.x = 1280 if state.x + state.sprite.width * state.sprite.scale + 20 < 0

  # car wraps around to bottom of screen if it disappears at the top of the screen
  # if you subtract 520 pixels instead of 20 pixels, the car takes longer to reappear (try it!)
  state.y = 0    if state.y - 20 > 720 # if 20 pixels less than car's y position is greater than vertical scope

  # car wraps around to top of screen if it disappears at the bottom of the screen
  state.y = 720  if state.y + state.sprite.height * state.sprite.scale + 20 < 0
end

# Changes angle of sprite based on user input from keyboard or controller
def process_inputs args

  # NOTE: increasing the angle doesn't mean that the car will continue to go
  # in a specific direction. The angle is increasing, which means that if the
  # left key was kept in the "down" state, the change in the angle would cause
  # the car to go in a counter-clockwise direction and form a circle (360 degrees)
  if args.inputs.keyboard.key_held.left # if left key is pressed
    args.state.angle += 2 # car's angle is incremented by 2

  # The same applies to decreasing the angle. If the right key was kept in the
  # "down" state, the decreasing angle would cause the car to go in a clockwise
  # direction and form a circle (360 degrees)
  elsif args.inputs.keyboard.key_held.right # if right key is pressed
    args.state.angle -= 2 # car's angle is decremented by 2

  # Input from a controller can also change the angle of the car
  elsif args.inputs.controller_one.left_analog_x_perc != 0
    args.state.angle += 2 * args.inputs.controller_one.left_analog_x_perc * -1
  end
end

# A sprite's center of rotation can be altered
# Increasing either of these numbers would dramatically increase the
# car's drift when it turns!
def rotation_anchor
  [0.7, 0.5]
end

# Sets opacity value of sprite to 255 so that it is not transparent at all
# Change it to 0 and you won't be able to see the car sprite on the screen
def opacity
  255
end

# Sets the color of the sprite to white.
def saturation
  [255, 255, 255]
end

# Sets definition of destination_rect (used to define the car sprite)
def destination_rect state
  [state.x, state.y,
  state.sprite.width  * state.sprite.scale, # multiplies by 4 to set size
  state.sprite.height * state.sprite.scale]
end

# Portion of a sprite (a tile)
# Sub division of sprite is denoted as a rectangle directly related to original size of .png
# Tile is located at bottom left corner within a 19x10 pixel rectangle (based on sprite.width, sprite.height)
def source_rect state
  [0, 0, state.sprite.width, state.sprite.height]
end
