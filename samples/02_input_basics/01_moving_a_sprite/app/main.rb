def tick args
  # Create a player and set default values
  # NOTE: args.state is a construct that lets you define properties on the fly
  args.state.player ||= { x: 100,
                          y: 100,
                          w: 50,
                          h: 50,
                          path: 'sprites/square/green.png' }

  # move the player around by consulting args.inputs
  # the top level args.inputs checks the keyboard's arrow keys, WASD,
  # and controller one
  if args.inputs.up
    args.state.player.y += 10
  elsif args.inputs.down
    args.state.player.y -= 10
  end

  if args.inputs.left
    args.state.player.x -= 10
  elsif args.inputs.right
    args.state.player.x += 10
  end

  # Render the player to the screen
  args.outputs.sprites << args.state.player
end
