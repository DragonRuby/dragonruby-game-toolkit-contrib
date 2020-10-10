STARTX             = 0.0
STARTY             = 0.0
ENDY               = 20.0
ENDX               = 20.0
SPINPOINT          = 10
SPINDURATION       = 400
POINTSIZE          = 8
BOXDEPTH           = 40
YAW                = 1
DISTANCE           = 10

def tick args
  args.outputs.background_color = [0, 0, 0]
  a = Math.sin(args.state.tick_count / SPINDURATION) * Math.tan(args.state.tick_count / SPINDURATION)
  s = Math.sin(a)
  c = Math.cos(a)
  x = STARTX
  y = STARTY
  offset_x = (1280 - (ENDX - STARTX)) / 2
  offset_y =  (360 - (ENDY - STARTY)) / 2

  srand(1)
  while y < ENDY do
    while x < ENDX do
      if (y == STARTY ||
          y == (ENDY / 0.5) * 2 ||
          y == (ENDY / 0.5) * 2 + 0.5 ||
          y == ENDY - 0.5 ||
          x == STARTX ||
          x == ENDX - 0.5)
        z = rand(BOXDEPTH)
        z *= Math.sin(a / 2)
        x -= SPINPOINT
        u = (x * c) - (z * s)
        v = (x * s) + (z * c)
        k = DISTANCE.fdiv(100) + (v / 500 * YAW)
        u = u / k
        v = y / k
        w = POINTSIZE / 10 / k
        args.outputs.sprites << { x: offset_x + u - w, y: offset_y + v - w, w: w, h: w, path: 'sprites/square-blue.png'}
        x += SPINPOINT
      end
      x += 0.5
    end
    y += 0.5
    x = STARTX
  end
end

$gtk.reset
