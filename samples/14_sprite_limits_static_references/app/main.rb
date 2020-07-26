=begin

 Reminders:

 - Instance variable (@): Used to give objects their own space to store data.
   In this sample app, check the initialize method inside of the StarClass class
   to see @ used.

 - args.outputs.sprites: An array. The values generate a sprite.
   The parameters are [X, Y, WIDTH, HEIGHT, IMAGE PATH]
   For more information about sprites, go to mygame/documentation/05-sprites.md.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mymgame/documentation/02-labels.md.

 - to_s: Returns a string representation of an object.

 - to_i: Returns an integer representation of an object.

 - String interpolation: uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - args.inputs.mouse.(x|y): The x and y location of the mouse.
   For more information about the mouse, go to mygame/documentation/07-mouse.md.
=end

class StarClass
  attr_sprite
  attr_accessor :speed_x, :speed_y

  def initialize outputs
    @x = -1280 * rand # random position on screen
    @y = -720 * rand
    @w = 15 # size
    @h = 15
    @speed_x = 2 * rand + 1 # random speed
    @speed_y = 2 * rand + 1
    @r = 255
    @g = 255 * rand # random color
    @b = 255 * rand
    @a = 128 # transparency
    @path = 'sprites/star.png' # image path
    outputs.static_sprites << self # adds self to collection
  end
end

# calls methods needed for game to run properly
def tick args
  # sets console command when sample app initially opens
  if Kernel.global_tick_count == 0
    args.gtk.console.set_command "reset_with count: 100"
  end

  defaults args
  render_stars args
  move_stars args
  process_inputs args
end

# sets default values
def defaults args
  args.outputs.background_color = [0, 0, 0] # black background
  args.state.star_count ||= 10
  # sets stars collection by performing action on each star (initially 10 stars based on star_count)
  args.state.stars ||= args.state.star_count.map { StarClass.new args.outputs }
end

def render_stars args
  # outputs white label with number of stars and frames per second onto the screen
  args.outputs.labels << [10, 30, "Count: #{args.state.star_count}, FPS: #{args.gtk.current_framerate.to_s.to_i}", 255, 255, 255, 80] # string interpolation
end

# allows stars to move on screen
# stars loop back around if they exceed scope of screen
def move_stars args
  args.state.stars.each do |star| # perform action on each star in collection
    star.x = -200 * rand if star.x > 1500 # random x position if exceeds value of 1500 (goes too far right)
    star.y = -200 * rand if star.y > 800 # random y position if exceeds value of 800 (goes too far up)
    star.x += star.speed_x # increments position by speed of star
    star.y += star.speed_y
    star
  end
end

# creates and outputs a red border to surround the mouse
# resets game if "r" key on keyboard is pressed
def process_inputs args
  # 50 is subtracted from x and y so the mouse is in center of red box
  mouse_border = [args.inputs.mouse.x - 50, args.inputs.mouse.y - 50, 100, 100, 255, 0, 0]
  args.outputs.borders << mouse_border
  $gtk.reset if args.inputs.keyboard.key_down.r
end

# resets game, and assigns star count given by user
def reset_with count: count
  $gtk.reset
  $gtk.args.state.star_count = count
end
