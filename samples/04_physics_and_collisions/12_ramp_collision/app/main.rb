# sample app shows how to do ramp collision
# based off of the writeup here:
# http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/

# NOTE: at the bottom of the file you'll find $gtk.reset_and_replay "replay.txt"
#       whenever you make changes to this file, a replay will automatically run so you can
#       see how your changes affected the game. Comment out the line at the bottom if you
#       don't want the replay to autmatically run.

# toolbar interaction is in a seperate file
require 'app/toolbar.rb'

def tick args
  tick_toolbar args
  tick_game args
end

def tick_game args
  game_defaults args
  game_input args
  game_calc args
  game_render args
end

def game_input args
  # if space is pressed or held (signifying a jump)
  if args.inputs.keyboard.space
    # change the player's dy to the jump power if the
    # player is not currently touching a ceiling
    if !args.state.player.on_ceiling
      args.state.player.dy = args.state.player.jump_power
      args.state.player.on_floor = false
      args.state.player.jumping = true
    end
  else
    # if the space key is released, then jumping is false
    # and the player will no longer be on the ceiling
    args.state.player.jumping = false
    args.state.player.on_ceiling = false
  end

  # set the player's dx value to the left/right input
  # NOTE: that the speed of the player's dx movement has
  #       a sensitive relation ship with collision detection.
  #       If you increase the speed of the player, you may
  #       need to tweak the collision code to compensate for
  #       the extra horizontal speed.
  args.state.player.dx = args.inputs.left_right * 2
end

def game_render args
  # for each terrain entry, render the line that represents the connection
  # from the tile's left_height to the tile's right_height
  args.outputs.primitives << args.state.terrain.map { |t| t.line }

  # determine if the player sprite needs to be flipped hoizontally
  flip_horizontally = args.state.player.facing == -1

  # render the player
  args.outputs.sprites << args.state.player.merge(flip_horizontally: flip_horizontally)

  args.outputs.labels << {
    x: 640,
    y: 100,
    alignment_enum: 1,
    text: "Left and Right to move player. Space to jump. Use the toolbar at the top to add more terrain."
  }

  args.outputs.labels << {
    x: 640,
    y: 60,
    alignment_enum: 1,
    text: "Click any existing terrain on the map to delete it."
  }
end

def game_calc args
  # set the direction the player is facing based on the
  # the dx value of the player
  if args.state.player.dx > 0
    args.state.player.facing = 1
  elsif args.state.player.dx < 0
    args.state.player.facing = -1
  end

  # preform the calcuation of ramp collision
  calc_collision args

  # reset the player if the go off screen
  calc_off_screen args
end

def game_defaults args
  # how much gravity is in the game
  args.state.gravity ||= 0.1

  # initialized the player to the center of the screen
  args.state.player ||= {
    x: 640,
    y: 360,
    w: 16,
    h: 16,
    dx: 0,
    dy: 0,
    jump_power: 3,
    path: 'sprites/square/blue.png',
    on_floor: false,
    on_ceiling: false,
    facing: 1
  }
end

def calc_collision args
  # increment the players x position by the dx value
  args.state.player.x += args.state.player.dx

  # if the player is not on the floor
  if !args.state.player.on_floor
    # then apply gravity
    args.state.player.dy -= args.state.gravity
    # clamp the max dy value to -12 to 12
    args.state.player.dy = args.state.player.dy.clamp(-12, 12)

    # update the player's y position by the dy value
    args.state.player.y += args.state.player.dy
  end

  # get all colisions between the player and the terrain
  collisions = args.state.geometry.find_all_intersect_rect args.state.player, args.state.terrain

  # if there are no collisions, then the player is not on the floor or ceiling
  # return from the method since there is nothing more to process
  if collisions.length == 0
    args.state.player.on_floor = false
    args.state.player.on_ceiling = false
    return
  end

  # set a local variable to the player since
  # we'll be accessing it a lot
  player = args.state.player

  # sort the collisions by the distance from the collision's center to the player's center
  sorted_collisions = collisions.sort_by do |collision|
    player_center = player.x + player.w / 2
    collision_center = collision.x + collision.w / 2
    (player_center - collision_center).abs
  end

  # define a one pixel wide rectangle that represents the center of the player
  # we'll use this value to determine the location of the player's feet on
  # a ramp
  player_center_rect = {
    x: player.x + player.w / 2 - 0.5,
    y: player.y,
    w: 1,
    h: player.h
  }

  # for each collision...
  sorted_collisions.each do |collision|
    # if the player doesn't intersect with the collision,
    # then set the player's on_floor and on_ceiling values to false
    # and continue to the next collision
    if !collision.intersect_rect? player_center_rect
      player.on_floor = false
      player.on_ceiling = false
      next
    end

    if player.dy < 0
      # if the player is falling
      # the percentage of the player's center relative to the collision
      # is a difference from the collision to the player (as opposed to the player to the collision)
      perc = (collision.x - player_center_rect.x) / player.w
      height_of_slope = collision.tile.left_height - collision.tile.right_height

      new_y = (collision.y + collision.tile.left_height + height_of_slope * perc)
      diff = new_y - player.y

      if diff < 0
        # if the current fall rate of the player is less than the difference
        # of the player's new y position and the player's current y position
        # then don't set the player's y position to the new y position
        # and wait for another application of gravity to bring the player a little
        # closer
        if player.dy.abs >= diff.abs
          # if the player's current fall speed can cover the distance to the
          # new y position, then set the player's y position to the new y position
          # and mark them as being on the floor so that gravity no longer get's processed
          player.y = new_y
          player.on_floor = true

          # given the player's speed, set the player's dy to a value that will
          # keep them from bouncing off the floor when the ramp is steep
          # NOTE: if you change the player's speed, then this value will need to be adjusted
          #       to keep the player from bouncing off the floor
          player.dy = -1
        end
      elsif diff > 0 && diff < 8
        # there's a small edge case where collision may be processed from
        # below the terrain (eg when the player is jumping up and hitting the
        # ramp from below). The moment when jump is released, the player's dy
        # value could result in the player tunneling through the terrain,
        # and get popped on to the top side.

        # testing to make sure the distance that will be displaced is less than
        # 8 pixels will keep this tunneling from happening
        player.y = new_y
        player.on_floor = true

        # given the player's speed, set the player's dy to a value that will
        # keep them from bouncing off the floor when the ramp is steep
        # NOTE: if you change the player's speed, then this value will need to be adjusted
        #       to keep the player from bouncing off the floor
        player.dy = -1
      end
    elsif player.dy > 0
      # if the player is jumping
      # the percentage of the player's center relative to the collision
      # is a difference is reversed from the player to the collision (as opposed to the player to the collision)
      perc = (player_center_rect.x - collision.x) / player.w

      # the height of the slope is also reversed when approaching the collision from the bottom
      height_of_slope = collision.tile.right_height - collision.tile.left_height

      new_y = collision.y + collision.tile.left_height + height_of_slope * perc

      # since this collision is being processed from below, the difference
      # between the current players position and the new y position is
      # based off of the player's top position (their head)
      player_top = player.y + player.h

      diff = new_y - player_top

      # we also need to calculate the difference between the player's bottom
      # and the new position. This will be used to determine if the player
      # can jump from the new_y position
      diff_bottom = new_y - player.y


      # if the player's current rising speed can cover the distance to the
      # new y position, then set the player's y position to the new y position
      # an mark them as being on the floor so that gravity no longer get's processed
      can_cover_distance_to_new_y = player.dy >= diff.abs && player.dy.sign == diff.sign

      # another scenario that needs to be covered is if the player's top is already passed
      # the new_y position (their rising speed made them partially clip through the collision)
      player_top_above_new_y = player_top > new_y

      # if either of the conditions above is true then we want to set the player's y position
      if can_cover_distance_to_new_y || player_top_above_new_y
        # only set the player's y position to the new y position if the player's
        # cannot escape the collision by jumping up from the new_y position
        if diff_bottom >= player.jump_power
          player.y = new_y.floor - player.h

          # after setting the new_y position, we need to determine if the player
          # if the player is touching the ceiling or not
          # touching the ceiling disables the ability for the player to jump/increase
          # their dy value any more than it already is
          if player.jumping
            # disable jumping if the player is currently moving upwards
            player.on_ceiling = true

            # NOTE: if you change the player's speed, then this value will need to be adjusted
            #       to keep the player from bouncing off the ceiling as they move right and left
            player.dy = 1
          else
            # if the player is not currently jumping, then set their dy to 0
            # so they can immediately start falling after the collision
            # this also means that they are no longer on the ceiling and can jump again
            player.dy = 0
            player.on_ceiling = false
          end
        end
      end
    end
  end
end

def calc_off_screen args
  below_screen = args.state.player.y + args.state.player.h < 0
  above_screen = args.state.player.y > 720 + args.state.player.h
  off_screen_left = args.state.player.x + args.state.player.w < 0
  off_screen_right = args.state.player.x > 1280

  # if the player is off the screen, then reset them to the top of the screen
  if below_screen || above_screen || off_screen_left || off_screen_right
    args.state.player.x = 640
    args.state.player.y = 720
    args.state.player.dy = 0
    args.state.player.on_floor = false
  end
end

$gtk.reset_and_replay "replay.txt", speed: 2
