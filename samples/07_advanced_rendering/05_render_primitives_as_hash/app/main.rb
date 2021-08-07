=begin

 Reminders:

 - Hashes: Collection of unique keys and their corresponding values. The value can be found
   using their keys.

   For example, if we have a "numbers" hash that stores numbers in English as the
   key and numbers in Spanish as the value, we'd have a hash that looks like this...
   numbers = { "one" => "uno", "two" => "dos", "three" => "tres" }
   and on it goes.

   Now if we wanted to find the corresponding value of the "one" key, we could say
   puts numbers["one"]
   which would print "uno" to the console.

 - args.outputs.sprites: An array. The values generate a sprite.
   The parameters are [X, Y, WIDTH, HEIGHT, PATH, ANGLE, ALPHA, RED, GREEN, BLUE]
   For more information about sprites, go to mygame/documentation/05-sprites.md.

 - args.outputs.labels: An array. The values generate a label.
   The parameters are [X, Y, TEXT, SIZE, ALIGNMENT, RED, GREEN, BLUE, ALPHA, FONT STYLE]
   For more information about labels, go to mygame/documentation/02-labels.md.

 - args.outputs.solids: An array. The values generate a solid.
   The parameters are [X, Y, WIDTH, HEIGHT, RED, GREEN, BLUE, ALPHA]
   For more information about solids, go to mygame/documentation/03-solids-and-borders.md.

 - args.outputs.borders: An array. The values generate a border.
   The parameters are the same as a solid.
   For more information about borders, go to mygame/documentation/03-solids-and-borders.md.

 - args.outputs.lines: An array. The values generate a line.
   The parameters are [X1, Y1, X2, Y2, RED, GREEN, BLUE]
   For more information about labels, go to mygame/documentation/02-labels.md.

=end

# This sample app demonstrates how hashes can be used to output different kinds of objects.

def tick args
  args.state.angle ||= 0 # initializes angle to 0
  args.state.angle  += 1 # increments angle by 1 every frame (60 times a second)

  # Outputs sprite using a hash
  args.outputs.sprites << {
    x: 30,                          # sprite position
    y: 550,
    w: 128,                         # sprite size
    h: 101,
    path: "dragonruby.png",         # image path
    angle: args.state.angle,        # angle
    a: 255,                         # alpha (transparency)
    r: 255,                         # color saturation
    g: 255,
    b: 255,
    tile_x:  0,                     # sprite sub division/tile
    tile_y:  0,
    tile_w: -1,
    tile_h: -1,
    flip_vertically: false,         # don't flip sprite
    flip_horizontally: false,
    angle_anchor_x: 0.5,            # rotation center set to middle
    angle_anchor_y: 0.5
  }

  # Outputs label using a hash
  args.outputs.labels << {
    x:              200,                 # label position
    y:              550,
    text:           "dragonruby",        # label text
    size_enum:      2,
    alignment_enum: 1,
    r:              155,                 # color saturation
    g:              50,
    b:              50,
    a:              255,                 # transparency
    font:           "fonts/manaspc.ttf"  # font style; without mentioned file, label won't output correctly
  }

  # Outputs solid using a hash
  # [X, Y, WIDTH, HEIGHT, RED, GREEN, BLUE, ALPHA]
  args.outputs.solids << {
    x: 400,                         # position
    y: 550,
    w: 160,                         # size
    h:  90,
    r: 120,                         # color saturation
    g:  50,
    b:  50,
    a: 255                          # transparency
  }

  # Outputs border using a hash
  # Same parameters as a solid
  args.outputs.borders << {
    x: 600,
    y: 550,
    w: 160,
    h:  90,
    r: 120,
    g:  50,
    b:  50,
    a: 255
  }

  # Outputs line using a hash
  args.outputs.lines << {
    x:  900,                        # starting position
    y:  550,
    x2: 1200,                       # ending position
    y2: 550,
    r:  120,                        # color saturation
    g:   50,
    b:   50,
    a:  255                         # transparency
  }

  # Outputs sprite as a primitive using a hash
  args.outputs.primitives << {
    x: 30,                          # position
    y: 200,
    w: 128,                         # size
    h: 101,
    path: "dragonruby.png",         # image path
    angle: args.state.angle,        # angle
    a: 255,                         # transparency
    r: 255,                         # color saturation
    g: 255,
    b: 255,
    tile_x:  0,                     # sprite sub division/tile
    tile_y:  0,
    tile_w: -1,
    tile_h: -1,
    flip_vertically: false,         # don't flip
    flip_horizontally: false,
    angle_anchor_x: 0.5,            # rotation center set to middle
    angle_anchor_y: 0.5
  }.sprite!

  # Outputs label as primitive using a hash
  args.outputs.primitives << {
    x:         200,                 # position
    y:         200,
    text:      "dragonruby",        # text
    size:      2,
    alignment: 1,
    r:         155,                 # color saturation
    g:         50,
    b:         50,
    a:         255,                 # transparency
    font:      "fonts/manaspc.ttf"  # font style
  }.label!

  # Outputs solid as primitive using a hash
  args.outputs.primitives << {
    x: 400,                         # position
    y: 200,
    w: 160,                         # size
    h:  90,
    r: 120,                         # color saturation
    g:  50,
    b:  50,
    a: 255                          # transparency
  }.solid!

  # Outputs border as primitive using a hash
  # Same parameters as solid
  args.outputs.primitives << {
    x: 600,                         # position
    y: 200,
    w: 160,                         # size
    h:  90,
    r: 120,                         # color saturation
    g:  50,
    b:  50,
    a: 255                          # transparency
  }.border!

  # Outputs line as primitive using a hash
  args.outputs.primitives << {
    x:  900,                        # starting position
    y:  200,
    x2: 1200,                       # ending position
    y2: 200,
    r:  120,                        # color saturation
    g:   50,
    b:   50,
    a:  255                         # transparency
  }.line!
end
