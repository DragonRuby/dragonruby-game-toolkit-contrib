# sample app shows how to use a render target to
# create a combined sprite
def tick args
  create_combined_sprite args

  # render the combined sprite
  # using its name :two_squares
  # have it move across the screen and rotate
  args.outputs.sprites << { x: args.state.tick_count % 1280,
                            y: 0,
                            w: 80,
                            h: 80,
                            angle: args.state.tick_count,
                            path: :two_squares }
end

def create_combined_sprite args
  # NOTE: you can have the construction of the combined
  #       sprite to happen every tick or only once (if the
  #       combined sprite never changes).
  #
  # if the combined sprite never changes, comment out the line
  # below to only construct it on the first frame and then
  # use the cached texture
  # return if args.state.tick_count != 0 # <---- guard clause to only construct on first frame and cache

  # define the dimensions of the combined sprite
  # the name of the combined sprite is :two_squares
  args.outputs[:two_squares].w = 80
  args.outputs[:two_squares].h = 80

  # put a blue sprite within the combined sprite
  # who's width is "thin"
  args.outputs[:two_squares].sprites << {
    x: 40 - 10,
    y: 0,
    w: 20,
    h: 80,
    path: 'sprites/square/blue.png'
  }

  # put a red sprite within the combined sprite
  # who's height is "thin"
  args.outputs[:two_squares].sprites << {
    x: 0,
    y: 40 - 10,
    w: 80,
    h: 20,
    path: 'sprites/square/red.png'
  }
end
