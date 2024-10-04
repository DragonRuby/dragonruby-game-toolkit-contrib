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
#     [320, 640, "Example
#     [ X ,  Y,    TEXT]
# 4. It's recommended to use hashes so that you're not reliant on positional values:
#    { x: 320,
#      y: 640,
#      text: "Text",
#      font: "fonts/font.ttf",
#      anchor_x: 0.5, # or alignment_enum: 0, 1, or 2
#      anchor_y: 0.5, # or vertical_alignment_enum: 0, 1, or 2
#      r: 0,
#      g: 0,
#      b: 0,
#      a: 255,
#      size_px: 20,   # or size_enum: -10 to 10 (0 means "ledgible on small devices" ie: 20px)
#      blendmode_enum: 1 }


# The tick method is called by DragonRuby every frame
# args contains all the information regarding the game.
def tick args
  # render the current frame to the screen using a simple array
  # this is useful for quick and dirty output and is recommended to use
  # a Hash to render long term.
  args.outputs.labels << [640, 650, "frame: #{Kernel.tick_count}"]

  # render the current frame to the screen centered vertically and horizontally at 640, 620
  args.outputs.labels << { x: 640, y: 620, anchor_x: 0.5, anchor_y: 0.5, text: "frame: #{Kernel.tick_count}" }

  # Here are some examples of simple labels, with the minimum number of parameters
  # Note that the default values for the other parameters are 0, except for Alpha which is 255 and Font Style which is the default font
  args.outputs.labels << { x: 5,          y: 720 - 5, text: "This is a label located at the top left." }
  args.outputs.labels << { x: 5,          y:      30, text: "This is a label located at the bottom left." }
  args.outputs.labels << { x: 1280 - 420, y: 720 - 5, text: "This is a label located at the top right." }
  args.outputs.labels << { x: 1280 - 440, y: 30,      text: "This is a label located at the bottom right." }

  # Demonstration of the Size Enum Parameter

  # size_enum of -2 is equivalent to using size_px: 18
  args.outputs.labels << { x: 175 + 150, y: 635 - 50, text: "Smaller label.",  size_enum: -2 }
  args.outputs.labels << { x: 175 + 150, y: 620 - 50, text: "Smaller label.",  size_px: 18 }

  # size_enum of -1 is equivalent to using size_px: 20
  args.outputs.labels << { x: 175 + 150, y: 595 - 50, text: "Small label.",    size_enum: -1 }
  args.outputs.labels << { x: 175 + 150, y: 580 - 50, text: "Small label.",    size_px: 20 }

  # size_enum of  0 is equivalent to using size_px: 22
  args.outputs.labels << { x: 175 + 150, y: 550 - 50, text: "Medium label.",   size_enum:  0 }

  # size_enum of  0 is equivalent to using size_px: 24
  args.outputs.labels << { x: 175 + 150, y: 520 - 50, text: "Large label.",    size_enum:  1 }

  # size_enum of  0 is equivalent to using size_px: 26
  args.outputs.labels << { x: 175 + 150, y: 490 - 50, text: "Larger label.",   size_enum:  2 }

  # Demonstration of the Align Parameter
  args.outputs.lines  << { x: 175 + 150, y: 0, h: 720 }

  # alignment_enum: 0 is equivalent to anchor_x: 0
  # vertical_alignment_enum: 1 is equivalent to anchor_y: 0.5
  args.outputs.labels << { x: 175 + 150, y: 360 - 50, text: "Left aligned.",   alignment_enum: 0, vertical_alignment_enum: 1 }
  args.outputs.labels << { x: 175 + 150, y: 342 - 50, text: "Left aligned.",   anchor_x: 0, anchor_y: 0.5 }

  # alignment_enum: 1 is equivalent to anchor_x: 0.5
  args.outputs.labels << { x: 175 + 150, y: 325 - 50, text: "Center aligned.", alignment_enum: 1, vertical_alignment_enum: 1  }

  # alignment_enum: 2 is equivalent to anchor_x: 1
  args.outputs.labels << { x: 175 + 150, y: 305 - 50, text: "Right aligned.",  alignment_enum: 2 }

  # Demonstration of the RGBA parameters
  args.outputs.labels << { x: 600  + 150, y: 590 - 50, text: "Red Label.",   r: 255, g:   0, b:   0 }
  args.outputs.labels << { x: 600  + 150, y: 570 - 50, text: "Green Label.", r:   0, g: 255, b:   0 }
  args.outputs.labels << { x: 600  + 150, y: 550 - 50, text: "Blue Label.",  r:   0, g:   0, b: 255 }
  args.outputs.labels << { x: 600  + 150, y: 530 - 50, text: "Faded Label.", r:   0, g:   0, b:   0, a: 128 }

  # providing a custom font
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

  args.outputs.labels << { x: 640,
                           y: 100,
                           anchor_x: 0.5,
                           anchor_y: 0.5,
                           text: "Ніколи не здам тебе. Ніколи не підведу тебе. Ніколи не буду бігати навколо і залишати тебе." }
end
