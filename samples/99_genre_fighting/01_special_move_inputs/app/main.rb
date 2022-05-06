def tick args
  #tick_instructions args, "Use LEFT and RIGHT arrow keys to move and SPACE to jump."
  defaults args
  render args
  input args
  calc args
end

# sets default values and creates empty collections
# initialization only happens in the first frame
def defaults args
  fiddle args

  args.state.tick_count = args.state.tick_count
  args.state.bridge_top = 128
  args.state.player.x  ||= 0                        # initializes player's properties
  args.state.player.y  ||= args.state.bridge_top
  args.state.player.w  ||= 64
  args.state.player.h  ||= 64
  args.state.player.dy ||= 0
  args.state.player.dx ||= 0
  args.state.player.r  ||= 0
  args.state.game_over_at ||= 0
  args.state.animation_time ||=0

  args.state.timeleft ||=0
  args.state.timeright ||=0
  args.state.lastpush ||=0

  args.state.inputlist ||=  ["j","k","l"]
end

# sets enemy, player, hammer values
def fiddle args
  args.state.gravity                     = -0.5
  args.state.player_jump_power           = 10      # sets player values
  args.state.player_jump_power_duration  = 5
  args.state.player_max_run_speed        = 20
  args.state.player_speed_slowdown_rate  = 0.9
  args.state.player_acceleration         = 0.9
end

# outputs objects onto the screen
def render args
  if (args.state.player.dx < 0.01) && (args.state.player.dx > -0.01)
    args.state.player.dx = 0
  end

  #move list
  (args.layout.rect_group row: 0, col_from_right: 8, drow: 0.3,
                          merge: { vertical_alignment_enum: 0, size_enum: -2 },
                          group: [
                            { text: "move:             WASD" },
                            { text: "jump:             Space" },
                            { text: "attack forwards:  J (while on ground" },
                            { text: "attack upwards:   K (while on groud)" },
                            { text: "attack backwards: J (while on ground and holding A)" },
                            { text: "attack downwards: K (while in air)" },
                            { text: "dash attack:      J, K in quick succession." },
                            { text: "shield: hold      J, K at the same time." },
                            { text: "dash backwards:   A, A in quick succession." },
                          ]).into args.outputs.labels

  # registered moves
  args.outputs.labels << { x: 0.to_layout_col,
                           y: 0.to_layout_row,
                           text: "input history",
                           size_enum: -2,
                           vertical_alignment_enum: 0 }

  (args.state.inputlist.take(5)).map do |s|
    { text: s, size_enum: -2, vertical_alignment_enum: 0 }
  end.yield_self do |group|
    (args.layout.rect_group row: 0.3, col: 0, drow: 0.3, group: group).into args.outputs.labels
  end


  #sprites
  player = [args.state.player.x, args.state.player.y,
            args.state.player.w, args.state.player.h,
            "sprites/square/white.png",
            args.state.player.r]

  playershield = [args.state.player.x - 20, args.state.player.y - 10,
                  args.state.player.w + 20, args.state.player.h + 20,
                  "sprites/square/blue.png",
                  args.state.player.r,
                  0]

  playerjab = [args.state.player.x + 32, args.state.player.y,
               args.state.player.w, args.state.player.h,
               "sprites/isometric/indigo.png",
               args.state.player.r,
               0]

  playerupper = [args.state.player.x, args.state.player.y + 32,
                 args.state.player.w, args.state.player.h,
                 "sprites/isometric/indigo.png",
                 args.state.player.r+90,
                 0]

  if ((args.state.tick_count - args.state.lastpush) <= 15)
    if (args.state.inputlist[0] == "<<")
      player = [args.state.player.x, args.state.player.y,
                args.state.player.w, args.state.player.h,
                "sprites/square/yellow.png", args.state.player.r]
    end

    if (args.state.inputlist[0] == "shield")
      player = [args.state.player.x, args.state.player.y,
                args.state.player.w, args.state.player.h,
                "sprites/square/indigo.png", args.state.player.r]

      playershield = [args.state.player.x - 10, args.state.player.y - 10,
                      args.state.player.w + 20, args.state.player.h + 20,
                      "sprites/square/blue.png", args.state.player.r, 50]
    end

    if (args.state.inputlist[0] == "back-attack")
      playerjab = [args.state.player.x - 20, args.state.player.y,
                   args.state.player.w - 10, args.state.player.h,
                   "sprites/isometric/indigo.png", args.state.player.r, 255]
    end

    if (args.state.inputlist[0] == "forward-attack")
      playerjab = [args.state.player.x + 32, args.state.player.y,
                   args.state.player.w, args.state.player.h,
                   "sprites/isometric/indigo.png", args.state.player.r, 255]
    end

    if (args.state.inputlist[0] == "up-attack")
      playerupper = [args.state.player.x, args.state.player.y + 32,
                     args.state.player.w, args.state.player.h,
                     "sprites/isometric/indigo.png", args.state.player.r + 90, 255]
    end

    if (args.state.inputlist[0] == "dair")
      playerupper = [args.state.player.x, args.state.player.y - 32,
                     args.state.player.w, args.state.player.h,
                     "sprites/isometric/indigo.png", args.state.player.r + 90, 255]
    end

    if (args.state.inputlist[0] == "dash-attack")
      playerupper = [args.state.player.x, args.state.player.y + 32,
                     args.state.player.w, args.state.player.h,
                     "sprites/isometric/violet.png", args.state.player.r + 90, 255]

      playerjab = [args.state.player.x + 32, args.state.player.y,
                   args.state.player.w, args.state.player.h,
                   "sprites/isometric/violet.png", args.state.player.r, 255]
    end
  end

  args.outputs.sprites << playerjab
  args.outputs.sprites << playerupper
  args.outputs.sprites << player
  args.outputs.sprites << playershield

  args.outputs.solids << 20.map_with_index do |i| # uses 20 squares to form bridge
    [i * 64, args.state.bridge_top - 64, 64, 64]
  end
end

# Performs calculations to move objects on the screen
def calc args
  # Since velocity is the change in position, the change in x increases by dx. Same with y and dy.
  args.state.player.x  += args.state.player.dx
  args.state.player.y  += args.state.player.dy

  # Since acceleration is the change in velocity, the change in y (dy) increases every frame
  args.state.player.dy += args.state.gravity

  # player's y position is either current y position or y position of top of
  # bridge, whichever has a greater value
  # ensures that the player never goes below the bridge
  args.state.player.y  = args.state.player.y.greater(args.state.bridge_top)

  # player's x position is either the current x position or 0, whichever has a greater value
  # ensures that the player doesn't go too far left (out of the screen's scope)
  args.state.player.x  = args.state.player.x.greater(0)

  # player is not falling if it is located on the top of the bridge
  args.state.player.falling = false if args.state.player.y == args.state.bridge_top
  #args.state.player.rect = [args.state.player.x, args.state.player.y, args.state.player.h, args.state.player.w] # sets definition for player
end

# Resets the player by changing its properties back to the values they had at initialization
def reset_player args
  args.state.player.x = 0
  args.state.player.y = args.state.bridge_top
  args.state.player.dy = 0
  args.state.player.dx = 0
  args.state.enemy.hammers.clear # empties hammer collection
  args.state.enemy.hammer_queue.clear # empties hammer_queue
  args.state.game_over_at = args.state.tick_count # game_over_at set to current frame (or passage of time)
end

# Processes input from the user to move the player
def input args
  if args.state.inputlist.length > 5
    args.state.inputlist.pop
  end

  should_process_special_move = (args.inputs.keyboard.key_down.j)           ||
                                (args.inputs.keyboard.key_down.k)           ||
                                (args.inputs.keyboard.key_down.a)           ||
                                (args.inputs.keyboard.key_down.d)           ||
                                (args.inputs.controller_one.key_down.y)     ||
                                (args.inputs.controller_one.key_down.x)     ||
                                (args.inputs.controller_one.key_down.left)  ||
                                (args.inputs.controller_one.key_down.right)

  if (should_process_special_move)
    if (args.inputs.keyboard.key_down.j && args.inputs.keyboard.key_down.k) ||
       (args.inputs.controller_one.key_down.x && args.inputs.controller_one.key_down.y)
      args.state.inputlist.unshift("shield")
    elsif (args.inputs.keyboard.key_down.k || args.inputs.controller_one.key_down.y) &&
          (args.state.inputlist[0] == "forward-attack") && ((args.state.tick_count - args.state.lastpush) <= 15)
      args.state.inputlist.unshift("dash-attack")
      args.state.player.dx = 20
    elsif (args.inputs.keyboard.key_down.j && args.inputs.keyboard.a) ||
          (args.inputs.controller_one.key_down.x && args.inputs.controller_one.key_down.left)
      args.state.inputlist.unshift("back-attack")
    elsif ( args.inputs.controller_one.key_down.x || args.inputs.keyboard.key_down.j)
      args.state.inputlist.unshift("forward-attack")
    elsif (args.inputs.keyboard.key_down.k || args.inputs.controller_one.key_down.y) &&
          (args.state.player.y > 128)
      args.state.inputlist.unshift("dair")
    elsif (args.inputs.keyboard.key_down.k || args.inputs.controller_one.key_down.y)
      args.state.inputlist.unshift("up-attack")
    elsif (args.inputs.controller_one.key_down.left || args.inputs.keyboard.key_down.a) &&
          (args.state.inputlist[0] == "<") &&
          ((args.state.tick_count - args.state.lastpush) <= 10)
      args.state.inputlist.unshift("<<")
      args.state.player.dx = -15
    elsif (args.inputs.controller_one.key_down.left || args.inputs.keyboard.key_down.a)
      args.state.inputlist.unshift("<")
      args.state.timeleft = args.state.tick_count
    elsif (args.inputs.controller_one.key_down.right || args.inputs.keyboard.key_down.d)
      args.state.inputlist.unshift(">")
    end

    args.state.lastpush = args.state.tick_count
  end

  if args.inputs.keyboard.space || args.inputs.controller_one.r2   # if the user presses the space bar
    args.state.player.jumped_at ||= args.state.tick_count # jumped_at is set to current frame

    # if the time that has passed since the jump is less than the player's jump duration and
    # the player is not falling
    if args.state.player.jumped_at.elapsed_time < args.state.player_jump_power_duration && !args.state.player.falling
      args.state.player.dy = args.state.player_jump_power # change in y is set to power of player's jump
    end
  end

  # if the space bar is in the "up" state (or not being pressed down)
  if args.inputs.keyboard.key_up.space || args.inputs.controller_one.key_up.r2
    args.state.player.jumped_at = nil # jumped_at is empty
    args.state.player.falling = true # the player is falling
  end

  if args.inputs.left # if left key is pressed
    if args.state.player.dx < -5
      args.state.player.dx = args.state.player.dx
    else
      args.state.player.dx = -5
    end

  elsif args.inputs.right # if right key is pressed
    if args.state.player.dx > 5
      args.state.player.dx = args.state.player.dx
    else
      args.state.player.dx = 5
    end
  else
    args.state.player.dx *= args.state.player_speed_slowdown_rate # dx is scaled down
  end

  if ((args.state.player.dx).abs > 5) #&& ((args.state.tick_count - args.state.lastpush) <= 10)
    args.state.player.dx *= 0.95
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
