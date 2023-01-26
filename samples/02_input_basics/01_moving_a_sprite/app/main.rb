def tick args
  # create a player and set default values
  # for the player's x, y, w (width), and h (height)
  args.state.player.x ||= 100
  args.state.player.y ||= 100
  args.state.player.w ||=  50
  args.state.player.h ||=  50

  # render the player to the screen
  args.outputs.sprites << { x: args.state.player.x,
                            y: args.state.player.y,
                            w: args.state.player.w,
                            h: args.state.player.h,
                            path: 'sprites/square/green.png' }

  # move the player around using the keyboard
  args.state.player.y += 10 if args.inputs.up
  args.state.player.y -= 10 if args.inputs.down
  args.state.player.x -= 10 if args.inputs.left
  args.state.player.x += 10 if args.inputs.right
end

$gtk.reset
