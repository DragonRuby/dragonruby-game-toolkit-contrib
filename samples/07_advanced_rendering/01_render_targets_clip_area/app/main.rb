def tick args
  # define your state
  args.state.player ||= { x: 0, y: 0, w: 300, h: 300, path: "sprites/square/blue.png" }

  # controller input for player
  args.state.player.x += args.inputs.left_right * 5
  args.state.player.y += args.inputs.up_down * 5

  # create a render target that holds the
  # full view that you want to render

  # make the background transparent
  args.outputs[:clipped_area].background_color = [0, 0, 0, 0]

  # set the w/h to match the screen
  args.outputs[:clipped_area].w = 1280
  args.outputs[:clipped_area].h = 720

  # render the player in the render target
  args.outputs[:clipped_area].sprites << args.state.player

  # render the player and clip area as borders to
  # keep track of where everything is at regardless of clip mode
  args.outputs.borders << args.state.player
  args.outputs.borders << { x: 540, y: 460, w: 200, h: 200 }

  # render the render target, but only the clipped area
  args.outputs.sprites << {
    # where to render the render target
    x: 540,
    y: 460,
    w: 200,
    h: 200,
    # what part of the render target to render
    source_x: 540,
    source_y: 460,
    source_w: 200,
    source_h: 200,
    # path of render target to render
    path: :clipped_area
  }

  # mini map
  args.outputs.borders << { x: 1280 - 160, y: 0, w: 160, h: 90 }
  args.outputs.sprites << { x: 1280 - 160, y: 0, w: 160, h: 90, path: :clipped_area }
end

GTK.reset
