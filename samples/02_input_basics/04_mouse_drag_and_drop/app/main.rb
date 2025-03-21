def tick args
  # create 10 random squares on the screen
  if !args.state.squares
    # the squares will be contained in lookup/Hash so that we can access via their id
    args.state.squares = {}
    10.times_with_index do |id|
      # for each square, store it in the hash with
      # the id (we're just using the index 0-9 as the index)
      args.state.squares[id] = {
        id: id,
        x: 100 + (rand * 1080),
        y: 100 + (520 * rand),
        w: 100,
        h: 100,
        path: "sprites/square/blue.png"
      }
    end
  end

  # two key variables are set here
  # - square_reference: this represents the square that is currently being dragged
  # - square_under_mouse: this represents the square that the mouse is currently being hovered over
  if args.state.currently_dragging_square_id
    # if the currently_dragging_square_id is set, then set the "square_under_mouse" to
    # the same square as square_reference
    square_reference = args.state.squares[args.state.currently_dragging_square_id]
    square_under_mouse = square_reference
  else
    # if currently_dragging_square_id isn't set, then see if there is a square that
    # the mouse is currently hovering over (the square reference will be nil since
    # we haven't selected a drag target yet)
    square_under_mouse = Geometry.find_intersect_rect args.inputs.mouse, args.state.squares.values
    square_reference = nil
  end


  # if a click occurs, and there is a square under the mouse
  if args.inputs.mouse.click && square_under_mouse
    # capture the id of the square that the mouse is hovering over
    args.state.currently_dragging_square_id = square_under_mouse.id

    # also capture where in the square the mouse was clicked so that
    # the movement of the square will smoothly transition with the mouse's
    # location
    args.state.mouse_point_inside_square = {
      x: args.inputs.mouse.x - square_under_mouse.x,
      y: args.inputs.mouse.y - square_under_mouse.y,
    }
  elsif args.inputs.mouse.held && args.state.currently_dragging_square_id
    # if the mouse is currently being held and the currently_dragging_square_id was set,
    # then update the x and y location of the referenced square (taking into consideration the
    # relative position of the mouse when the square was clicked)
    square_reference.x = args.inputs.mouse.x - args.state.mouse_point_inside_square.x
    square_reference.y = args.inputs.mouse.y - args.state.mouse_point_inside_square.y
  elsif args.inputs.mouse.up
    # if the mouse is released, then clear out the currently_dragging_square_id
    args.state.currently_dragging_square_id = nil
  end

  # render all the squares on the screen
  args.outputs.sprites << args.state.squares.values

  # if there was a square under the mouse, add an "overlay"
  if square_under_mouse
    args.outputs.sprites << square_under_mouse.merge(path: "sprites/square/red.png")
  end
end

GTK.recording.on_replay_completed_successfully do |args|
  raise "Square was not in the right place" if args.state.squares[2].x.floor != 746
end
