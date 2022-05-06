# full documenation is at http://docs.dragonruby.org
# be sure to come to the discord if you hit any snags: http://discord.dragonruby.org
def tick args
  # ====================================================
  # initialize default variables
  # ====================================================

  # ruby has an operator called ||= which means "only initialize this if it's nil"
  args.state.count_down   ||= 20 * 60 # set the count down to 20 seconds
  # set the initial position of the target
  args.state.target       ||= { x: args.grid.w.half,
                                y: args.grid.h.half,
                                w: 20,
                                h: 20 }

  # set the initial position of the player
  args.state.player       ||= { x: 50,
                                y: 50,
                                w: 20,
                                h: 20 }

  # set the player movement speed
  args.state.player_speed ||= 5

  # set the score
  args.state.score        ||= 0
  args.state.teleports    ||= 3

  # set the instructions
  args.state.instructions ||= "Get to the red goal! Use arrow keys to move. Spacebar to teleport (use them carefully)!"

  # ====================================================
  # render the game
  # ====================================================
  args.outputs.labels  << { x: args.grid.w.half, y: args.grid.h - 10,
                            text: args.state.instructions,
                            alignment_enum: 1 }

  # check if it's game over. if so, then render game over
  # otherwise render the current time left
  if game_over? args
    args.outputs.labels  << { x: args.grid.w.half,
                              y: args.grid.h - 40,
                              text: "game over! (press r to start over)",
                              alignment_enum: 1 }
  else
    args.outputs.labels  << { x: args.grid.w.half,
                              y: args.grid.h - 40,
                              text: "time left: #{(args.state.count_down.idiv 60) + 1}",
                              alignment_enum: 1 }
  end

  # render the score
  args.outputs.labels  << { x: args.grid.w.half,
                            y: args.grid.h - 70,
                            text: "score: #{args.state.score}",
                            alignment_enum: 1 }

  # render the player with teleport count
  args.outputs.sprites << { x: args.state.player.x,
                            y: args.state.player.y,
                            w: args.state.player.w,
                            h: args.state.player.h,
                            path: 'sprites/square-green.png' }

  args.outputs.labels << { x: args.state.player.x + 10,
                           y: args.state.player.y + 40,
                           text: "teleports: #{args.state.teleports}",
                           alignment_enum: 1, size_enum: -2 }

  # render the target
  args.outputs.sprites << { x: args.state.target.x,
                            y: args.state.target.y,
                            w: args.state.target.w,
                            h: args.state.target.h,
                            path: 'sprites/square-red.png' }

  # ====================================================
  # run simulation
  # ====================================================

  # count down calculation
  args.state.count_down -= 1
  args.state.count_down = -1 if args.state.count_down < -1

  # ====================================================
  # process player input
  # ====================================================
  # if it isn't game over let them move
  if !game_over? args
    dir_y = 0
    dir_x = 0

    # determine the change horizontally
    if args.inputs.keyboard.up
      dir_y += args.state.player_speed
    elsif args.inputs.keyboard.down
      dir_y -= args.state.player_speed
    end

    # determine the change vertically
    if args.inputs.keyboard.left
      dir_x -= args.state.player_speed
    elsif args.inputs.keyboard.right
      dir_x += args.state.player_speed
    end

    # determine if teleport can be used
    if args.inputs.keyboard.key_down.space && args.state.teleports > 0
      args.state.teleports -= 1
      dir_x *= 20
      dir_y *= 20
    end

    # apply change to player
    args.state.player.x += dir_x
    args.state.player.y += dir_y
  else
    # if r is pressed, reset the game
    if args.inputs.keyboard.key_down.r
      $gtk.reset
      return
    end
  end

  # ====================================================
  # determine score
  # ====================================================

  # calculate new score if the player is at goal
  if !game_over? args

    # if the player is at the goal, then move the goal
    if args.state.player.intersect_rect? args.state.target
      # increment the goal
      args.state.score += 1

      # move the goal to a random location
      args.state.target = { x: (rand args.grid.w), y: (rand args.grid.h), w: 20, h: 20 }

      # make sure the goal is inside the view area
      if args.state.target.x < 0
        args.state.target.x += 20
      elsif args.state.target.x > 1280
        args.state.target.x -= 20
      end

      # make sure the goal is inside the view area
      if args.state.target.y < 0
        args.state.target.y += 20
      elsif args.state.target.y > 720
        args.state.target.y -= 20
      end
    end
  end
end

def game_over? args
  args.state.count_down < 0
end

$gtk.reset
