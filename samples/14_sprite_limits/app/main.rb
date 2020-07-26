=begin

 APIs listing that haven't been encountered in previous sample apps:

 - Instance variable (@): Used to give objects their own space to store data.
   Used in this sample app when the class data structure is chosen to assign
   star values, like the position, speed, size, color, etc. Check the
   initialize method inside of the StarClass class to see @ used.

 Reminders:

 - args.outputs.sprites: An array. The values generate a sprite.
   The parameters are [X, Y, WIDTH, HEIGHT, IMAGE PATH]
   For more information about sprites, go to mygame/documentation/05-sprites.md.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mymgame/documentation/02-labels.md.

 - Symbol (:): Ruby object with a name and an internal ID. Symbols are useful
   because with a given symbol name, you can refer to the same object throughout
   a Ruby program.

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   For example, if we want to create a new button, we would declare it as a new entity and
   then define its properties. (Remember, you can use state to define ANY property and it will
   be retained across frames.)

 - to_s: Returns a string representation of an object.

 - to_i: Returns an integer representation of an object.

 - String interpolation: uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - args.inputs.mouse.(x|y): The x and y location of the mouse.
   For more information about the mouse, go to mygame/documentation/07-mouse.md.

=end

# This sample app serves to show performance differences between using:
# a very flexible data structure (:entity),
# a less flexible but faster data structure (:strict),
# and the least flexible but fastest data structure (:class).

# If the user chooses the "class" data structure type, the StarClass will be used to assign star values
class StarClass
  attr_sprite
  attr_accessor :speed_x, :speed_y

  def initialize
    @x = -1280 * rand # random position on screen
    @y = -720 * rand
    @w = 15
    @h = 15
    @speed_x = 2 * rand + 1 # random speed
    @speed_y = 2 * rand + 1
    @r = 255
    @g = 255 * rand # random color
    @b = 255 * rand
    @a = 128
    @path = 'sprites/star.png'
  end
end

# Outputs sample app instructions onto console
# Provides acceptable command if user does not wish to enter their own input
# Calls methods needed to create and show stars
def tick args
  if Kernel.global_tick_count == 0
    args.gtk.console.show # shows console when the sample app initially opens
    puts "
================================================
                    HELLO!!!!
================================================

This sample app shows the performance differences between using
a very flexible data structure (:entity),
a less flexible but faster data structure (:strict),
and the least flexible but fastest data structure (:class).

To see the differences use the `reset_with SPRITE_COUNT, CATEGORY` method.

For example, the following invocations generate 100 sprites of each data structure type:

    reset_with 100, :entity
    reset_with 100, :strict
    reset_with 100, :class

and these commands generate 1k sprites of each data structure type:

    reset_with 1000, :entity
    reset_with 1000, :strict
    reset_with 1000, :class

================================================
"
    args.gtk.console.current_input_str = 'reset_with 1000, :entity' # default input for user
  end

  defaults args
  render_stars args
  move_stars args
  process_inputs args
end

# Sets default values, creates empty collection of stars
# Creates stars depending on whether user chooses the "entity", "strict", or "class" option
# by using an if/elsif statement
# Initialization happens only in first frame
def defaults args
  args.outputs.background_color = [0, 0, 0] # black background
  args.state.star_count ||= 10
  args.state.option ||= :class
  args.state.stars ||= args.state.star_count.map do # do the following to 10 stars
    r = nil # r starts off empty (given value later based on which data structure is chosen)
    if args.state.option == :entity # if the entity data structure is chosen
      r = args.state.new_entity(:star) do |star| # declares each star as new entity, sets properties
        star.x = -1280 * rand # random position
        star.y = -720 * rand
        star.speed_x = 2 * rand + 1 # random speed
        star.speed_y = 2 * rand + 1
        star.r = 255 # white color
        star.g = 255
        star.b = 255
        star.alpha = 128 # slightly transparent
        star.sprite = [star.x, star.y, 15, 15, 'sprites/star.png', 0, star.alpha, 255, 255 * rand, 255 * rand] # sets definition for star sprite (color is randomized)
      end
    elsif args.state.option == :strict # otherwise, if the strict data structure is chosen
      r = args.state.new_entity_strict(:star) do |star| # declares each star as new entity, sets properties
        star.x = -1280 * rand # random position
        star.y = -720 * rand
        star.speed_x = 2 * rand + 1 # random speed
        star.speed_y = 2 * rand + 1
        star.r = 255 # white
        star.g = 255
        star.b = 255
        star.alpha = 128 # slightly transparent
        star.sprite = [star.x, star.y, 15, 15, 'sprites/star.png', 0, star.alpha, 255, 255 * rand, 255 * rand] # sets definition for star sprite (color is randomized)
      end
    elsif args.state.option == :class # if the class data structure is chosen
      r = StarClass.new # uses StarClass to assign star values
    end
    r # returns r; value based on which part of the if statement above ran
  end
  args.state.stars ||= [] # initialized to empty array (if value of stars has not already been set)
end

# Used to output solids, sprites (specifically the stars), and labels on the screen
def render_stars args
  args.outputs.solids << [0, 0, 1280, 720] # sets black background

  # Outputs stars
  args.outputs.sprites << args.state.stars.map do |star| # outputs every star in the collection
    star.sprite
  end

  # Outputs (white) label with number of stars, type of data structure chosen,
  # and frames per second
  args.outputs.labels << [10, 30, "Count: #{args.state.star_count}, Type: #{args.state.option}, FPS: #{args.gtk.current_framerate.to_s.to_i}", 255, 255, 255, 80] # string interpolation
  # converts current framerate to a string, and then converts that result to an integer value
end

# Allows the stars to move across the screen
# Stars loop back around if they exceed the scope of the screen
def move_stars args
  args.state.stars.map! do |star| # for each star in the collection
    star.x = -200 * rand if star.x > 1500 # random x position if exceeds x value of 1500 (goes too far right)
    star.y = -200 * rand if star.y > 800 # random y position if exceeds y value fo 800 (goes too far up)
    star.x += star.speed_x # increments position by star's speed
    star.y += star.speed_y
    star.sprite.x = star.x # the sprite's position is the star's position
    star.sprite.y = star.y
    star
  end
end

# Creates and outputs a red border to surround the mouse
# Resets game if "r" key on keyboard is pressed
def process_inputs args
  # 50 is subtracted from x and y so the mouse can be in the center of red box
  mouse_border = [args.inputs.mouse.x - 50, args.inputs.mouse.y - 50, 100, 100, 255, 0, 0]
  args.outputs.borders << mouse_border
  $gtk.reset if args.inputs.keyboard.key_down.r
end

# Resets the game, and assigns the star_count and option values given by the user
def reset_with count, option
  $gtk.reset
  $gtk.args.state.option = option
  $gtk.args.state.star_count = count
end
