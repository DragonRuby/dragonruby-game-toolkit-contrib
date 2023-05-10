# here's how to create a "fire and forget" sprite animation queue
def tick args
  args.outputs.labels << { x: 640,
                           y: 360,
                           text: "Click anywhere on the screen.",
                           alignment_enum: 1,
                           vertical_alignment_enum: 1 }

  # initialize the queue to an empty array
  args.state.fade_out_queue ||=[]

  # if the mouse is click, add a sprite to the fire and forget
  # queue to be processed
  if args.inputs.mouse.click
    args.state.fade_out_queue << {
      x: args.inputs.mouse.x - 20,
      y: args.inputs.mouse.y - 20,
      w: 40,
      h: 40,
      path: "sprites/square/blue.png"
    }
  end

  # process the queue
  args.state.fade_out_queue.each do |item|
    # default the alpha value if it isn't specified
    item.a ||= 255

    # decrement the alpha by 5 each frame
    item.a -= 5
  end

  # remove the item if it's completely faded out
  args.state.fade_out_queue.reject! { |item| item.a <= 0 }

  # render the sprites in the queue
  args.outputs.sprites << args.state.fade_out_queue
end
