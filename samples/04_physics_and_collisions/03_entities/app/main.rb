=begin

 Reminders:

 - map: Ruby method used to transform data; used in arrays, hashes, and collections.
   Can be used to perform an action on every element of a collection, such as multiplying
   each element by 2 or declaring every element as a new entity.

 - reject: Removes elements from a collection if they meet certain requirements.
   For example, you can derive an array of odd numbers from an original array of
   numbers 1 through 10 by rejecting all elements that are even (or divisible by 2).

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   In this sample app, new_entity is used to define the properties of enemies and bullets.
   (Remember, you can use state to define ANY property and it will be retained across frames.)

 - args.outputs.labels: An array. The values generate a label on the screen.
   The parameters are [X, Y, TEXT, SIZE, ALIGN, RED, GREEN, BLUE, ALPHA, FONT STYLE]

 - ARRAY#intersect_rect?: Returns true or false depending on if the two rectangles intersect.

 - args.inputs.mouse.click.point.(x|y): The x and y location of the mouse.

=end

# This sample app shows enemies that contain an id value and the time they were created.
# These enemies can be removed by shooting at them with bullets.

# Calls all methods necessary for the game to function properly.
def tick args
  tick_instructions args, "Sample app shows how to use args.state.new_entity along with collisions. CLICK to shoot a bullet."
  defaults args
  render args
  calc args
  process_inputs args
end

# Sets default values
# Enemies and bullets start off as empty collections
def defaults args
  args.state.enemies ||= []
  args.state.bullets ||= []
end

# Provides each enemy in enemies collection with rectangular border,
# as well as a label showing id and when they were created
def render args
  # When you're calling a method that takes no arguments, you can use this & syntax on map.
  # Numbers are being added to x and y in order to keep the text within the enemy's borders.
  args.outputs.borders << args.state.enemies.map(&:rect)
  args.outputs.labels  << args.state.enemies.flat_map do |enemy|
    [
      [enemy.x + 4, enemy.y + 29, "id: #{enemy.entity_id}", -3, 0],
      [enemy.x + 4, enemy.y + 17, "created_at: #{enemy.created_at}", -3, 0] # frame enemy was created
    ]
  end

  # Outputs bullets in bullets collection as rectangular solids
  args.outputs.solids << args.state.bullets.map(&:rect)
end

# Calls all methods necessary for performing calculations
def calc args
  add_new_enemies_if_needed args
  move_bullets args
  calculate_collisions args
  remove_bullets_of_screen args
end

# Adds enemies to the enemies collection and sets their values
def add_new_enemies_if_needed args
  return if args.state.enemies.length >= 10 # if 10 or more enemies, enemies are not added
  return unless args.state.bullets.length == 0 # if user has not yet shot bullet, no enemies are added

  args.state.enemies += (10 - args.state.enemies.length).map do # adds enemies so there are 10 total
    args.state.new_entity(:enemy) do |e| # each enemy is declared as a new entity
      e.x = 640 + 500 * rand # each enemy is given random position on screen
      e.y = 600 * rand + 50
      e.rect = [e.x, e.y, 130, 30] # sets definition for enemy's rect
    end
  end
end

# Moves bullets across screen
# Sets definition of the bullets
def move_bullets args
  args.state.bullets.each do |bullet| # perform action on each bullet in collection
    bullet.x += bullet.speed # increment x by speed (bullets fly horizontally across screen)

    # By randomizing the value that increments bullet.y, the bullet does not fly straight up and out
    # of the scope of the screen. Try removing what follows bullet.speed, or changing 0.25 to 1.25 to
    # see what happens to the bullet's movement.
    bullet.y += bullet.speed.*(0.25).randomize(:ratio, :sign)
    bullet.rect = [bullet.x, bullet.y, bullet.size, bullet.size] # sets definition of bullet's rect
  end
end

# Determines if a bullet hits an enemy
def calculate_collisions args
  args.state.bullets.each do |bullet| # perform action on every bullet and enemy in collections
    args.state.enemies.each do |enemy|
      # if bullet has not exploded yet and the bullet hits an enemy
      if !bullet.exploded && bullet.rect.intersect_rect?(enemy.rect)
        bullet.exploded = true # bullet explodes
        enemy.dead = true # enemy is killed
      end
    end
  end

  # All exploded bullets are rejected or removed from the bullets collection
  # and any dead enemy is rejected from the enemies collection.
  args.state.bullets = args.state.bullets.reject(&:exploded)
  args.state.enemies = args.state.enemies.reject(&:dead)
end

# Bullets are rejected from bullets collection once their position exceeds the width of screen
def remove_bullets_of_screen args
  args.state.bullets = args.state.bullets.reject { |bullet| bullet.x > 1280 } # screen width is 1280
end

# Calls fire_bullet method
def process_inputs args
  fire_bullet args
end

# Once mouse is clicked by the user to fire a bullet, a new bullet is added to bullets collection
def fire_bullet args
  return unless args.inputs.mouse.click # return unless mouse is clicked
  args.state.bullets << args.state.new_entity(:bullet) do |bullet| # new bullet is declared a new entity
    bullet.y = args.inputs.mouse.click.point.y # set to the y value of where the mouse was clicked
    bullet.x = 0 # starts on the left side of the screen
    bullet.size = 10
    bullet.speed = 10 * rand + 2 # speed of a bullet is randomized
    bullet.rect = [bullet.x, bullet.y, bullet.size, bullet.size] # definition is set
  end
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.space ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end
