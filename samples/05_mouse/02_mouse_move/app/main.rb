=begin

 Reminders:

 - num1.greater(num2): Returns the greater value.
   For example, if we have the command
   puts 4.greater(3)
   the number 4 would be printed to the console since it has a greater value than 3.
   Similar to lesser, which returns the lesser value.

 - find_all: Finds all elements of a collection that meet certain requirements.
   For example, in this sample app, we're using find_all to find all zombies that have intersected
   or hit the player's sprite since these zombies have been killed.

 - args.inputs.keyboard.key_down.KEY: Determines if a key is being held or pressed.
   Stores the frame the "down" event occurred.
   For more information about the keyboard, go to mygame/documentation/06-keyboard.md.

 - args.outputs.sprites: An array. The values generate a sprite.
   The parameters are [X, Y, WIDTH, HEIGHT, PATH, ANGLE, ALPHA, RED, GREEN, BLUE]
   For more information about sprites, go to mygame/documentation/05-sprites.md.

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   When we want to create a new object, we can declare it as a new entity and then define
   its properties. (Remember, you can use state to define ANY property and it will
   be retained across frames.)

 - String interpolation: Uses #{} syntax; everything between the #{ and the } is evaluated
   as Ruby code, and the placeholder is replaced with its corresponding value or result.

 - map: Ruby method used to transform data; used in arrays, hashes, and collections.
   Can be used to perform an action on every element of a collection, such as multiplying
   each element by 2 or declaring every element as a new entity.

 - sample: Chooses a random element from the array.

 - reject: Removes elements that meet certain requirements.
   In this sample app, we're removing/rejecting zombies that reach the center of the screen. We're also
   rejecting zombies that were killed more than 30 frames ago.

=end

# This sample app allows users to move around the screen in order to kill zombies. Zombies appear from every direction so the goal
# is to kill the zombies as fast as possible!

class ProtectThePuppiesFromTheZombies
  attr_accessor :grid, :inputs, :state, :outputs

  # Calls the methods necessary for the game to run properly.
  def tick
    defaults
    render
    calc
    input
  end

  # Sets default values for the zombies and for the player.
  # Initialization happens only in the first frame.
  def defaults
    state.flash_at               ||= 0
    state.zombie_min_spawn_rate  ||= 60
    state.zombie_spawn_countdown ||= random_spawn_countdown state.zombie_min_spawn_rate
    state.zombies                ||= []
    state.killed_zombies         ||= []

    # Declares player as a new entity and sets its properties.
    # The player begins the game in the center of the screen, not moving in any direction.
    state.player ||= state.new_entity(:player, { x: 640,
                                               y: 360,
                                               attack_angle: 0,
                                               dx: 0,
                                               dy: 0 })
  end

  # Outputs a gray background.
  # Calls the methods needed to output the player, zombies, etc onto the screen.
  def render
    outputs.solids << [grid.rect, 100, 100, 100]
    render_zombies
    render_killed_zombies
    render_player
    render_flash
  end

  # Outputs the zombies on the screen and sets values for the sprites, such as the position, width, height, and animation.
  def render_zombies
    outputs.sprites << state.zombies.map do |z| # performs action on all zombies in the collection
      z.sprite = [z.x, z.y, 4 * 3, 8 * 3, animation_sprite(z)].sprite # sets definition for sprite, calls animation_sprite method
      z.sprite
    end
  end

  # Outputs sprites of killed zombies, and displays a slash image to show that a zombie has been killed.
  def render_killed_zombies
    outputs.sprites << state.killed_zombies.map do |z| # performs action on all killed zombies in collection
      z.sprite = [z.x,
                  z.y,
                  4 * 3,
                  8 * 3,
                  animation_sprite(z, z.death_at), # calls animation_sprite method
                  0, # angle
                  255 * z.death_at.ease(30, :flip)].sprite # transparency of a zombie changes when they die
                  # change the value of 30 and see what happens when a zombie is killed

      # Sets values to output the slash over the zombie's sprite when a zombie is killed.
      # The slash is tilted 45 degrees from the angle of the player's attack.
      # Change the 3 inside scale_rect to 30 and the slash will be HUGE! Scale_rect positions
      # the slash over the killed zombie's sprite.
      [z.sprite, [z.sprite.rect, 'sprites/slash.png', 45 + state.player.attack_angle_on_click, z.sprite.a].scale_rect(3, 0.5, 0.5)]
    end
  end

  # Outputs the player sprite using the images in the sprites folder.
  def render_player
    state.player_sprite = [state.player.x,
                           state.player.y,
                          4 * 3,
                          8 * 3, "sprites/player-#{animation_index(state.player.created_at_elapsed)}.png"] # string interpolation
    outputs.sprites << state.player_sprite

    # Outputs a small red square that previews the angles that the player can attack in.
    # It can be moved in a perfect circle around the player to show possible movements.
    # Change the 60 in the parenthesis and see what happens to the movement of the red square.
    outputs.solids <<  [state.player.x + state.player.attack_angle.vector_x(60),
                        state.player.y + state.player.attack_angle.vector_y(60),
                        3, 3, 255, 0, 0]
  end

  # Renders flash as a solid. The screen turns white for 10 frames when a zombie is killed.
  def render_flash
    return if state.flash_at.elapsed_time > 10 # return if more than 10 frames have passed since flash.
    # Transparency gradually changes (or eases) during the 10 frames of flash.
    outputs.primitives << [grid.rect, 255, 255, 255, 255 * state.flash_at.ease(10, :flip)].solid
  end

  # Calls all methods necessary for performing calculations.
  def calc
    calc_spawn_zombie
    calc_move_zombies
    calc_player
    calc_kill_zombie
  end

  # Decreases the zombie spawn countdown by 1 if it has a value greater than 0.
  def calc_spawn_zombie
    if state.zombie_spawn_countdown > 0
      state.zombie_spawn_countdown -= 1
      return
    end

    # New zombies are created, positioned on the screen, and added to the zombies collection.
    state.zombies << state.new_entity(:zombie) do |z| # each zombie is declared a new entity
      if rand > 0.5
        z.x = grid.rect.w.randomize(:ratio) # random x position on screen (within grid scope)
        z.y = [-10, 730].sample # y position is set to either -10 or 730 (randomly chosen)
        # the possible values exceed the screen's scope so zombies appear to be coming from far away
      else
        z.x = [-10, 1290].sample # x position is set to either -10 or 1290 (randomly chosen)
        z.y = grid.rect.w.randomize(:ratio) # random y position on screen
      end
    end

    # Calls random_spawn_countdown method (determines how fast new zombies appear)
    state.zombie_spawn_countdown = random_spawn_countdown state.zombie_min_spawn_rate
    state.zombie_min_spawn_rate -= 1
    # set to either the current zombie_min_spawn_rate or 0, depending on which value is greater
    state.zombie_min_spawn_rate  = state.zombie_min_spawn_rate.greater(0)
  end

  # Moves all zombies towards the center of the screen.
  # All zombies that reach the center (640, 360) are rejected from the zombies collection and disappear.
  def calc_move_zombies
    state.zombies.each do |z| # for each zombie in the collection
      z.y = z.y.towards(360, 0.1) # move the zombie towards the center (640, 360) at a rate of 0.1
      z.x = z.x.towards(640, 0.1) # change 0.1 to 1.1 and see how much faster the zombies move to the center
    end
    state.zombies = state.zombies.reject { |z| z.y == 360 && z.x == 640 } # remove zombies that are in center
  end

  # Calculates the position and movement of the player on the screen.
  def calc_player
    state.player.x += state.player.dx # changes x based on dx (change in x)
    state.player.y += state.player.dy # changes y based on dy (change in y)

    state.player.dx *= 0.9 # scales dx down
    state.player.dy *= 0.9 # scales dy down

    # Compares player's x to 1280 to find lesser value, then compares result to 0 to find greater value.
    # This ensures that the player remains within the screen's scope.
    state.player.x = state.player.x.lesser(1280).greater(0)
    state.player.y = state.player.y.lesser(720).greater(0) # same with player's y
  end

  # Finds all zombies that intersect with the player's sprite. These zombies are removed from the zombies collection
  # and added to the killed_zombies collection since any zombie that intersects with the player is killed.
  def calc_kill_zombie

    # Find all zombies that intersect with the player. They are considered killed.
    killed_this_frame = state.zombies.find_all { |z| z.sprite && (z.sprite.intersect_rect? state.player_sprite) }
    state.zombies = state.zombies - killed_this_frame # remove newly killed zombies from zombies collection
    state.killed_zombies += killed_this_frame # add newly killed zombies to killed zombies

    if killed_this_frame.length > 0 # if atleast one zombie was killed in the frame
      state.flash_at = state.tick_count # flash_at set to the frame when the zombie was killed
    # Don't forget, the rendered flash lasts for 10 frames after the zombie is killed (look at render_flash method)
    end

    # Sets the tick_count (passage of time) as the value of the death_at variable for each killed zombie.
    # Death_at stores the frame a zombie was killed.
    killed_this_frame.each do |z|
      z.death_at = state.tick_count
    end

    # Zombies are rejected from the killed_zombies collection depending on when they were killed.
    # They are rejected if more than 30 frames have passed since their death.
    state.killed_zombies = state.killed_zombies.reject { |z| state.tick_count - z.death_at > 30 }
  end

  # Uses input from the user to move the player around the screen.
  def input

    # If the "a" key or left key is pressed, the x position of the player decreases.
    # Otherwise, if the "d" key or right key is pressed, the x position of the player increases.
    if inputs.keyboard.key_held.a || inputs.keyboard.key_held.left
      state.player.x -= 5
    elsif inputs.keyboard.key_held.d || inputs.keyboard.key_held.right
      state.player.x += 5
    end

    # If the "w" or up key is pressed, the y position of the player increases.
    # Otherwise, if the "s" or down key is pressed, the y position of the player decreases.
    if inputs.keyboard.key_held.w || inputs.keyboard.key_held.up
      state.player.y += 5
    elsif inputs.keyboard.key_held.s || inputs.keyboard.key_held.down
      state.player.y -= 5
    end

    # Sets the attack angle so the player can move and attack in the precise direction it wants to go.
    # If the mouse is moved, the attack angle is changed (based on the player's position and mouse position).
    # Attack angle also contributes to the position of red square.
    if inputs.mouse.moved
      state.player.attack_angle = inputs.mouse.position.angle_from [state.player.x, state.player.y]
    end

    if inputs.mouse.click && state.player.dx < 0.5 && state.player.dy < 0.5
      state.player.attack_angle_on_click = inputs.mouse.position.angle_from [state.player.x, state.player.y]
      state.player.attack_angle = state.player.attack_angle_on_click # player's attack angle is set
      state.player.dx = state.player.attack_angle.vector_x(25) # change in player's position
      state.player.dy = state.player.attack_angle.vector_y(25)
    end
  end

  # Sets the zombie spawn's countdown to a random number.
  # How fast zombies appear (change the 60 to 6 and too many zombies will appear at once!)
  def random_spawn_countdown minimum
    10.randomize(:ratio, :sign).to_i + 60
  end

  # Helps to iterate through the images in the sprites folder by setting the animation index.
  # 3 frames is how long to show an image, and 6 is how many images to flip through.
  def animation_index at
    at.idiv(3).mod(6)
  end

  # Animates the zombies by using the animation index to go through the images in the sprites folder.
  def animation_sprite zombie, at = nil
    at ||= zombie.created_at_elapsed # how long it is has been since a zombie was created
    index = animation_index at
    "sprites/zombie-#{index}.png" # string interpolation to iterate through images
  end
end

$protect_the_puppies_from_the_zombies = ProtectThePuppiesFromTheZombies.new

def tick args
  $protect_the_puppies_from_the_zombies.grid    = args.grid
  $protect_the_puppies_from_the_zombies.inputs  = args.inputs
  $protect_the_puppies_from_the_zombies.state    = args.state
  $protect_the_puppies_from_the_zombies.outputs = args.outputs
  $protect_the_puppies_from_the_zombies.tick
  tick_instructions args, "How to get the mouse position and translate it to an x, y position using .vector_x and .vector_y. CLICK to play."
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
