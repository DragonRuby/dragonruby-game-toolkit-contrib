=begin

APIs listing that haven't been encountered in a previous sample apps:

- args.outputs.labels: An array. Values in this array generate labels the screen.

=end

# Labels are used to represent text elements in DragonRuby

# An example of creating a label is:
# args.outputs.labels << [320, 640, "Example", 3, 1, 255, 0, 0, 200, manaspace.ttf]

# The code above does the following:
# 1. GET the place where labels go: args.outputs.labels
# 2. Request a new LABEL be ADDED: <<
# 3. The DEFINITION of a LABEL is the ARRAY:
#     [320, 640, "Example", 3,     1,   255,   0,    0,    200,  manaspace.ttf]
#     [ X ,  Y,    TEXT,   SIZE, ALIGN, RED, GREEN, BLUE, ALPHA, FONT STYLE]
# 4. It's recommended to use hashes so that you're not reliant on positional values:
#    { x: 320, y: 640, text: "Example", size_enum: 3, alignment_enum: 1, r: 255, g: 0, b: 0, a: 200, font: "manaspace.ttf" }


# The tick method is called by DragonRuby every frame
# args contains all the information regarding the game.
def tick args
  # render the current frame to the screen centered vertically and horizontally at 640, 620
  args.outputs.labels << { x: 640, y: 620, anchor_x: 0.5, anchor_y: 0.5, text: "frame: #{args.state.tick_count}" }

  # Here are some examples of simple labels, with the minimum number of parameters
  # Note that the default values for the other parameters are 0, except for Alpha which is 255 and Font Style which is the default font
  args.outputs.labels << { x: 5,          y: 720 - 5, text: "This is a label located at the top left." }
  args.outputs.labels << { x: 5,          y:      30, text: "This is a label located at the bottom left." }
  args.outputs.labels << { x: 1280 - 420, y: 720 - 5, text: "This is a label located at the top right." }
  args.outputs.labels << { x: 1280 - 440, y: 30,      text: "This is a label located at the bottom right." }

  # Demonstration of the Size Parameter
  args.outputs.labels << { x: 175 + 150, y: 610 - 50, text: "Smaller label.",  size_enum: -2 } # size_enum of -2 is equivalent to using size_px: 18
  args.outputs.labels << { x: 175 + 150, y: 580 - 50, text: "Small label.",    size_enum: -1 } # size_enum of -1 is equivalent to using size_px: 20
  args.outputs.labels << { x: 175 + 150, y: 550 - 50, text: "Medium label.",   size_enum:  0 } # size_enum of  0 is equivalent to using size_px: 22
  args.outputs.labels << { x: 175 + 150, y: 520 - 50, text: "Large label.",    size_enum:  1 } # size_enum of  0 is equivalent to using size_px: 24
  args.outputs.labels << { x: 175 + 150, y: 490 - 50, text: "Larger label.",   size_enum:  2 } # size_enum of  0 is equivalent to using size_px: 26

  # Demonstration of the Align Parameter
  args.outputs.lines  << { x: 175 + 150, y: 0, h: 720 }

  args.outputs.labels << { x: 175 + 150, y: 345 - 50, text: "Left aligned.",   alignment_enum: 0 } # alignment_enum: 0 is equivalent to anchor_x: 0
  args.outputs.labels << { x: 175 + 150, y: 325 - 50, text: "Center aligned.", alignment_enum: 1 } # alignment_enum: 1 is equivalent to anchor_x: 0.5
  args.outputs.labels << { x: 175 + 150, y: 305 - 50, text: "Right aligned.",  alignment_enum: 2 } # alignment_enum: 2 is equivalent to anchor_x: 1

  # Demonstration of the RGBA parameters
  args.outputs.labels << { x: 600  + 150, y: 590 - 50, text: "Red Label.",   r: 255, g:   0, b:   0 }
  args.outputs.labels << { x: 600  + 150, y: 570 - 50, text: "Green Label.", r:   0, g: 255, b:   0 }
  args.outputs.labels << { x: 600  + 150, y: 550 - 50, text: "Blue Label.",  r:   0, g:   0, b: 255 }
  args.outputs.labels << { x: 600  + 150, y: 530 - 50, text: "Faded Label.", r:   0, g:   0, b:   0, a: 128 }

  # Demonstration of the Font parameter
  # In order to use a font of your choice, add its ttf file to the project folder, where the app folder is
  # Again, it's recommended to use hashes so that you're not reliant on positional values.
  args.outputs.labels << [690 + 150,               # x
                          330 - 20,                # y
                          "Custom font (Array)",   # text
                          0,                       # size_enum
                          1,                       # alignment_enum
                          125,                     # r
                          0,                       # g
                          200,                     # b
                          255,                     # a
                          "manaspc.ttf" ]          # font

  args.outputs.labels << { x: 690 + 150,
                           y: 330 - 50,
                           text: "Custom font (Hash)",
                           size_enum: 0,                 # equivalent to size_px:  22
                           alignment_enum: 1,            # equivalent to anchor_x: 0.5
                           vertical_alignment_enum: 2,   # equivalent to anchor_y: 1
                           r: 125,
                           g: 0,
                           b: 200,
                           a: 255,
                           font: "manaspc.ttf" }

  # Primitives can hold anything, and can be given a label in the following forms
  args.outputs.primitives << { x: 690 + 150,
                               y: 330 - 80,
                               text: "Custom font (.primitives Hash)",
                               size_enum: 0,
                               alignment_enum: 1,
                               r: 125,
                               g: 0,
                               b: 200,
                               a: 255,
                               font: "manaspc.ttf" }
end
