# Logical canvas width and height
WIDTH = 1280
HEIGHT = 720

# Nokia screen dimensions
NOKIA_WIDTH = 84
NOKIA_HEIGHT = 48

# Determine best fit zoom level
ZOOM_WIDTH = (WIDTH / NOKIA_WIDTH).floor
ZOOM_HEIGHT = (HEIGHT / NOKIA_HEIGHT).floor
ZOOM = [ZOOM_WIDTH, ZOOM_HEIGHT].min

# Compute the offset to center the Nokia screen
OFFSET_X = (WIDTH - NOKIA_WIDTH * ZOOM) / 2
OFFSET_Y = (HEIGHT - NOKIA_HEIGHT * ZOOM) / 2

# Compute the scaled dimensions of the Nokia screen
ZOOMED_WIDTH = NOKIA_WIDTH * ZOOM
ZOOMED_HEIGHT = NOKIA_HEIGHT * ZOOM

def boot args
  args.state = {}
end

def tick args
  # set the background color to black
  args.outputs.background_color = [0, 0, 0]

  # define a render target that represents the Nokia screen
  args.outputs[:nokia].w = 84
  args.outputs[:nokia].h = 48
  args.outputs[:nokia].background_color = [199, 240, 216]

  # new up the game if it hasn't been created yet
  $game ||= Game.new

  # pass args environment to the game
  $game.args = args

  # compute the mouse position in the Nokia screen
  $game.nokia_mouse_position = {
    x: (args.inputs.mouse.x - OFFSET_X).idiv(ZOOM),
    y: (args.inputs.mouse.y - OFFSET_Y).idiv(ZOOM),
    w: 1,
    h: 1,
  }

  # update the game
  $game.tick

  # render the game scaled to fit the screen
  args.outputs.sprites << {
    x: WIDTH / 2,
    y: HEIGHT / 2,
    w: ZOOMED_WIDTH,
    h: ZOOMED_HEIGHT,
    anchor_x: 0.5,
    anchor_y: 0.5,
    path: :nokia,
  }
end

# if GTK.reset is called
# clear out the game so that it can be re-initialized
def reset args
  $game = nil
end
