def tick args
  defaults args
  input args
  calc args
  render args
end

def defaults args
  # uncomment the line below to slow the game down by a factor of 4 -> 15 fps (for debugging)
  # GTK.slowmo! 4

  args.state.player ||= {
    x: 144,                # render x of the player
    y: 32,                 # render y of the player
    w: 144 * 2,            # render width of the player
    h: 72 * 2,             # render height of the player
    dx: 0,                 # velocity x of the player
    action: :standing,     # current action/status of the player
    action_at: 0,          # frame that the action occurred
    previous_direction: 1, # direction the player was facing last frame
    direction: 1,          # direction the player is facing this frame
    launch_speed: 4,       # speed the player moves when they start running
    run_acceleration: 1,   # how much the player accelerates when running
    run_top_speed: 8,      # the top speed the player can run
    friction: 0.9,         # how much the player slows down when have stopped attempting to run
    anchor_x: 0.5,         # render anchor x of the player
    anchor_y: 0            # render anchor y of the player
  }
end

def input args
  # if the directional has been pressed on the input device
  if args.inputs.left_right != 0
    # determine if the player is currently running or not,
    # if they aren't, set their dx to their launch speed
    # otherwise, add the run acceleration to their dx
    if args.state.player.action != :running
      args.state.player.dx = args.state.player.launch_speed * args.inputs.left_right.sign
    else
      args.state.player.dx += args.inputs.left_right * args.state.player.run_acceleration
    end

    # capture the direction the player is facing and the previous direction
    args.state.player.previous_direction = args.state.player.direction
    args.state.player.direction = args.inputs.left_right.sign
  end
end

def calc args
  # clamp the player's dx to the top speed
  args.state.player.dx = args.state.player.dx.clamp(-args.state.player.run_top_speed, args.state.player.run_top_speed)

  # move the player by their dx
  args.state.player.x += args.state.player.dx

  # capture the player's hitbox
  player_hitbox = hitbox args.state.player

  # check boundary collisions and stop the player if they are colliding with the ednges of the screen
  if (player_hitbox.x - player_hitbox.w / 2) < 0
    args.state.player.x = player_hitbox.w / 2
    args.state.player.dx = 0
    # if the player is not standing, set them to standing and capture the frame
    if args.state.player.action != :standing
      args.state.player.action = :standing
      args.state.player.action_at = Kernel.tick_count
    end
  elsif (player_hitbox.x + player_hitbox.w / 2) > 1280
    args.state.player.x = 1280 - player_hitbox.w / 2
    args.state.player.dx = 0

    # if the player is not standing, set them to standing and capture the frame
    if args.state.player.action != :standing
      args.state.player.action = :standing
      args.state.player.action_at = Kernel.tick_count
    end
  end

  # if the player's dx is not 0, they are running. update their action and capture the frame if needed
  if args.state.player.dx.abs > 0
    if args.state.player.action != :running || args.state.player.direction != args.state.player.previous_direction
      args.state.player.action = :running
      args.state.player.action_at = Kernel.tick_count
    end
  elsif args.inputs.left_right == 0
    # if the player's dx is 0 and they are not currently trying to run (left_right == 0), set them to standing and capture the frame
    if args.state.player.action != :standing
      args.state.player.action = :standing
      args.state.player.action_at = Kernel.tick_count
    end
  end

  # if the player is not trying to run (left_right == 0), slow them down by the friction amount
  if args.inputs.left_right == 0
    args.state.player.dx *= args.state.player.friction

    # if the player's dx is less than 1, set it to 0
    if args.state.player.dx.abs < 1
      args.state.player.dx = 0
    end
  end
end

def render args
  # determine if the player should be flipped horizontally
  flip_horizontally = args.state.player.direction == -1
  # determine the path to the sprite to render, the idle sprite is used if action == :standing
  path = "sprites/link-idle.png"

  # if the player is running, determine the frame to render
  if args.state.player.action == :running
    # the sprite animation's first 3 frames represent the launch of the run, so we skip them on the animation loop
    # by setting the repeat_index to 3 (the 4th frame)
    frame_index = args.state.player.action_at.frame_index(count: 9, hold_for: 8, repeat: true, repeat_index: 3)
    path = "sprites/link-run-#{frame_index}.png"

    args.outputs.labels << { x: args.state.player.x - 144, y: args.state.player.y + 230, text: "action:      #{args.state.player.action}" }
    args.outputs.labels << { x: args.state.player.x - 144, y: args.state.player.y + 200, text: "action_at:   #{args.state.player.action_at}" }
    args.outputs.labels << { x: args.state.player.x - 144, y: args.state.player.y + 170, text: "frame_index: #{frame_index}" }
  else
    args.outputs.labels << { x: args.state.player.x - 144, y: args.state.player.y + 230, text: "action:      #{args.state.player.action}" }
    args.outputs.labels << { x: args.state.player.x - 144, y: args.state.player.y + 200, text: "action_at:   #{args.state.player.action_at}" }
    args.outputs.labels << { x: args.state.player.x - 144, y: args.state.player.y + 170, text: "frame_index: n/a" }
  end


  # render the player's hitbox and sprite (the hitbox is used to determine boundary collision)
  args.outputs.borders << hitbox(args.state.player)
  args.outputs.borders << args.state.player

  # render the player's sprite
  args.outputs.sprites << args.state.player.merge(path: path, flip_horizontally: flip_horizontally)
end

def hitbox entity
  {
    x: entity.x,
    y: entity.y + 5,
    w: 64,
    h: 96,
    anchor_x: 0.5,
    anchor_y: 0
  }
end


GTK.reset
