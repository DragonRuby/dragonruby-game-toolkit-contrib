def tick args
  # define terrain of 32x32 sized squares
  args.state.terrain ||= [
    { x: 640,          y: 360,          w: 32, h: 32, path: 'sprites/square/blue.png' },
    { x: 640,          y: 360 - 32,     w: 32, h: 32, path: 'sprites/square/blue.png' },
    { x: 640,          y: 360 - 32 * 2, w: 32, h: 32, path: 'sprites/square/blue.png' },
    { x: 640 + 32,     y: 360 - 32 * 2, w: 32, h: 32, path: 'sprites/square/blue.png' },
    { x: 640 + 32 * 2, y: 360 - 32 * 2, w: 32, h: 32, path: 'sprites/square/blue.png' },
  ]

  # define player
  args.state.player ||= {
    x: 600,
    y: 360,
    w: 32,
    h: 32,
    dx: 0,
    dy: 0,
    path: 'sprites/square/red.png'
  }

  # render terrain and player
  args.outputs.sprites << args.state.terrain
  args.outputs.sprites << args.state.player

  # set dx and dy based on inputs
  args.state.player.dx = args.inputs.left_right * 2
  args.state.player.dy = args.inputs.up_down * 2

  # check for collisions on the x and y axis independently

  # increment the player's position by dx
  args.state.player.x += args.state.player.dx

  # check for collision on the x axis first
  collision = args.state.terrain.find { |t| t.intersect_rect? args.state.player }

  # if there is a collision, move the player to the edge of the collision
  # based on the direction of the player's movement and set the player's
  # dx to 0
  if collision
    if args.state.player.dx > 0
      args.state.player.x = collision.x - args.state.player.w
    elsif args.state.player.dx < 0
      args.state.player.x = collision.x + collision.w
    end
    args.state.player.dx = 0
  end

  # increment the player's position by dy
  args.state.player.y += args.state.player.dy

  # check for collision on the y axis next
  collision = args.state.terrain.find { |t| t.intersect_rect? args.state.player }

  # if there is a collision, move the player to the edge of the collision
  # based on the direction of the player's movement and set the player's
  # dy to 0
  if collision
    if args.state.player.dy > 0
      args.state.player.y = collision.y - args.state.player.h
    elsif args.state.player.dy < 0
      args.state.player.y = collision.y + collision.h
    end
    args.state.player.dy = 0
  end
end
