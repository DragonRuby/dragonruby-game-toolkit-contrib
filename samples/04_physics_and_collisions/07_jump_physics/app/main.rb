=begin

 Reminders:

 - args.state.new_entity: Used when we want to create a new object, like a sprite or button.
   For example, if we want to create a new button, we would declare it as a new entity and
   then define its properties. (Remember, you can use state to define ANY property and it will
   be retained across frames.)

 - args.outputs.solids: An array. The values generate a solid.
   The parameters for a solid are [X, Y, WIDTH, HEIGHT, RED, GREEN, BLUE]
   For more information about solids, go to mygame/documentation/03-solids-and-borders.md.

 - num1.greater(num2): Returns the greater value.

 - Hashes: Collection of unique keys and their corresponding values. The value can be found
   using their keys.

 - ARRAY#inside_rect?: Returns true or false depending on if the point is inside the rect.

=end

# This sample app is a game that requires the user to jump from one platform to the next.
# As the player successfully clears platforms, they become smaller and move faster.

class VerticalPlatformer
  attr_gtk

  # declares vertical platformer as new entity
  def s
    state.vertical_platformer ||= state.new_entity(:vertical_platformer)
    state.vertical_platformer
  end

  # creates a new platform using a hash
  def new_platform hash
    s.new_entity_strict(:platform, hash) # platform key
  end

  # calls methods needed for game to run properly
  def tick
    defaults
    render
    calc
    input
  end

  def init_game
    s.platforms ||= [ # initializes platforms collection with two platforms using hashes
      new_platform(x: 0, y: 0, w: 700, h: 32, dx: 1, speed: 0, rect: nil),
      new_platform(x: 0, y: 300, w: 700, h: 32, dx: 1, speed: 0, rect: nil), # 300 pixels higher
    ]

    s.tick_count  = args.state.tick_count
    s.gravity     = -0.3 # what goes up must come down because of gravity
    s.player.platforms_cleared ||= 0 # counts how many platforms the player has successfully cleared
    s.player.x  ||= 0           # sets player values
    s.player.y  ||= 100
    s.player.w  ||= 64
    s.player.h  ||= 64
    s.player.dy ||= 0           # change in position
    s.player.dx ||= 0
    s.player_jump_power           = 15
    s.player_jump_power_duration  = 10
    s.player_max_run_speed        = 5
    s.player_speed_slowdown_rate  = 0.9
    s.player_acceleration         = 1
    s.camera ||= { y: -100 } # shows view on screen (as the player moves upward, the camera does too)
  end

  # Sets default values
  def defaults
    init_game
  end

  # Outputs objects onto the screen
  def render
    outputs.solids << s.platforms.map do |p| # outputs platforms onto screen
      [p.x + 300, p.y - s.camera[:y], p.w, p.h] # add 300 to place platform in horizontal center
      # don't forget, position of platform is denoted by bottom left hand corner
    end

    # outputs player using hash
    outputs.solids << {
      x: s.player.x + 300, # player positioned on top of platform
      y: s.player.y - s.camera[:y],
      w: s.player.w,
      h: s.player.h,
      r: 100,              # color saturation
      g: 100,
      b: 200
    }
  end

  # Performs calculations
  def calc
    s.platforms.each do |p| # for each platform in the collection
      p.rect = [p.x, p.y, p.w, p.h] # set the definition
    end

    # sets player point by adding half the player's width to the player's x
    s.player.point = [s.player.x + s.player.w.half, s.player.y] # change + to - and see what happens!

    # search the platforms collection to find if the player's point is inside the rect of a platform
    collision = s.platforms.find { |p| s.player.point.inside_rect? p.rect }

    # if collision occurred and player is moving down (or not moving vertically at all)
    if collision && s.player.dy <= 0
      s.player.y = collision.rect.y + collision.rect.h - 2 # player positioned on top of platform
      s.player.dy = 0 if s.player.dy < 0 # player stops moving vertically
      if !s.player.platform
        s.player.dx = 0 # no horizontal movement
      end
      # changes horizontal position of player by multiplying collision change in x (dx) by speed and adding it to current x
      s.player.x += collision.dx * collision.speed
      s.player.platform = collision # player is on the platform that it collided with (or landed on)
      if s.player.falling # if player is falling
        s.player.dx = 0  # no horizontal movement
      end
      s.player.falling = false
      s.player.jumped_at = nil
    else
      s.player.platform = nil # player is not on a platform
      s.player.y  += s.player.dy # velocity is the change in position
      s.player.dy += s.gravity # acceleration is the change in velocity; what goes up must come down
    end

    s.platforms.each do |p| # for each platform in the collection
      p.x += p.dx * p.speed # x is incremented by product of dx and speed (causes platform to move horizontally)
      # changes platform's x so it moves left and right across the screen (between -300 and 300 pixels)
      if p.x < -300 # if platform goes too far left
        p.dx *= -1 # dx is scaled down
        p.x = -300 # as far left as possible within scope
      elsif p.x > (1000 - p.w) # if platform's x is greater than 300
        p.dx *= -1
        p.x = (1000 - p.w) # set to 300 (as far right as possible within scope)
      end
    end

    delta = (s.player.y - s.camera[:y] - 100) # used to position camera view

    if delta > -200
      s.camera[:y] += delta * 0.01 # allows player to see view as they move upwards
      s.player.x  += s.player.dx # velocity is change in position; change in x increases by dx

      # searches platform collection to find platforms located more than 300 pixels above the player
      has_platforms = s.platforms.find { |p| p.y > (s.player.y + 300) }
      if !has_platforms # if there are no platforms 300 pixels above the player
        width = 700 - (700 * (0.1 * s.player.platforms_cleared)) # the next platform is smaller than previous
        s.player.platforms_cleared += 1 # player successfully cleared another platform
        last_platform = s.platforms[-1] # platform just cleared becomes last platform
        # another platform is created 300 pixels above the last platform, and this
        # new platform has a smaller width and moves faster than all previous platforms
        s.platforms << new_platform(x: (700 - width) * rand, # random x position
                                    y: last_platform.y + 300,
                                    w: width,
                                    h: 32,
                                    dx: 1.randomize(:sign), # random change in x
                                    speed: 2 * s.player.platforms_cleared,
                                    rect: nil)
      end
    else
      # game over
      s.as_hash.clear # otherwise clear the hash (no new platform is necessary)
      init_game
    end
  end

  # Takes input from the user to move the player
  def input
    if inputs.keyboard.space # if the space bar is pressed
      s.player.jumped_at ||= s.tick_count # set to current frame

      # if the time that has passed since the jump is less than the duration of a jump (10 frames)
      # and the player is not falling
      if s.player.jumped_at.elapsed_time < s.player_jump_power_duration && !s.player.falling
        s.player.dy = s.player_jump_power # player jumps up
      end
    end

    if inputs.keyboard.key_up.space # if space bar is in "up" state
      s.player.falling = true # player is falling
    end

    if inputs.keyboard.left # if left key is pressed
      s.player.dx -= s.player_acceleration # player's position changes, decremented by acceleration
      s.player.dx = s.player.dx.greater(-s.player_max_run_speed) # dx is either current dx or -5, whichever is greater
    elsif inputs.keyboard.right # if right key is pressed
      s.player.dx += s.player_acceleration # player's position changes, incremented by acceleration
      s.player.dx  = s.player.dx.lesser(s.player_max_run_speed) # dx is either current dx or 5, whichever is lesser
    else
      s.player.dx *= s.player_speed_slowdown_rate # scales dx down
    end
  end
end

$game = VerticalPlatformer.new

def tick args
  $game.args = args
  $game.tick
end
