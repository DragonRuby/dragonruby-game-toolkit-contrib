=begin

APIs listing that haven't been encountered in a previous sample apps:

- args.outputs.labels: An array. Values in this array generate labels
  the screen.
- args.grid.(left|right|top|bottom): Pixel value for the boundaries of the virtual
  720 p screen (Dragon Ruby Game Toolkits's virtual resolution is always 1280x720).
- Numeric#shift_(left|right|up|down): Shifts the Numeric in the correct direction
  by adding or subracting.

=end

# Labels are used to represent text elements in DragonRuby

# An example of creating a label is:
# args.outputs.labels << [320, 640, "Example", 3, 1, 255, 0, 0, 200, manaspace.ttf]

# The code above does the following:
# 1. GET the place where labels go: args.outputs.labels
# 2. Request a new LABEL be ADDED: <<
# 3. The DEFINITION of a SOLID is the ARRAY:
#     [320, 640, "Example", 3,     1,   255,   0,    0,    200,  manaspace.ttf]
#     [ X ,  Y,    TEXT,   SIZE, ALIGN, RED, GREEN, BLUE, ALPHA, FONT STYLE]


# The tick method is called by DragonRuby every frame
# args contains all the information regarding the game.
def tick args
  tick_instructions args, "Sample app shows different version of label sizes and alignments. And how to use hashes instead of arrays."
  # Here are some examples of simple labels, with the minimum number of parameters
  # Note that the default values for the other parameters are 0, except for Alpha which is 255 and Font Style which is the default font
  args.outputs.labels << [400, 620, "Here is a label with just an x, y, and text"]

  args.outputs.labels << [args.grid.left.shift_right(5), args.grid.top.shift_down(5), "This is a label located at the top left."]
  args.outputs.labels << [args.grid.left.shift_right(5), args.grid.bottom.shift_up(30), "This is a label located at the bottom left."]
  args.outputs.labels << [args.grid.right.shift_left(420), args.grid.top.shift_down(5), "This is a label located at the top right."]
  args.outputs.labels << [args.grid.right.shift_left(440), args.grid.bottom.shift_up(30), "This is a label located at the bottom right."]

  # Demonstration of the Size Parameter
  args.outputs.labels << [175 + 150, 610 - 50, "Smaller label.",  -2]
  args.outputs.labels << [175 + 150, 580 - 50, "Small label.",    -1]
  args.outputs.labels << [175 + 150, 550 - 50, "Medium label.",    0]
  args.outputs.labels << [175 + 150, 520 - 50, "Large label.",     1]
  args.outputs.labels << [175 + 150, 490 - 50, "Larger label.",    2]

  # Demonstration of the Align Parameter
  args.outputs.labels << [260 + 150, 345 - 50, "Left aligned.",    0, 2]
  args.outputs.labels << [260 + 150, 325 - 50, "Center aligned.",  0, 1]
  args.outputs.labels << [260 + 150, 305 - 50, "Right aligned.",   0, 0]

  # Demonstration of the RGBA parameters
  args.outputs.labels << [600  + 150, 590 - 50, "Red Label.",       0, 0, 255,   0,   0]
  args.outputs.labels << [600  + 150, 570 - 50, "Green Label.",     0, 0,   0, 255,   0]
  args.outputs.labels << [600  + 150, 550 - 50, "Blue Label.",      0, 0,   0,   0, 255]
  args.outputs.labels << [600  + 150, 530 - 50, "Faded Label.",     0, 0,   0,   0,   0, 128]

  # Demonstration of the Font parameter
  # In order to use a font of your choice, add its ttf file to the project folder, where the app folder is
  args.outputs.labels << [690 + 150, 330 - 20, "Custom font (Array)", 0, 1, 125, 0, 200, 255, "manaspc.ttf" ]
  args.outputs.primitives << { x: 690 + 150,
                               y: 330 - 50,
                               text: "Custom font (Hash)",
                               size_enum: 0,
                               alignment_enum: 1,
                               r: 125,
                               g: 0,
                               b: 200,
                               a: 255,
                               font: "manaspc.ttf" }.label!

  # Primitives can hold anything, and can be given a label in the following forms
  args.outputs.primitives << [690 + 150, 330 - 80, "Custom font (.primitives Array)", 0, 1, 125, 0, 200, 255, "manaspc.ttf" ].label

  args.outputs.primitives << { x: 690 + 150,
                               y: 330 - 110,
                               text: "Custom font (.primitives Hash)",
                               size_enum: 0,
                               alignment_enum: 1,
                               r: 125,
                               g: 0,
                               b: 200,
                               a: 255,
                               font: "manaspc.ttf" }.label!
end

def tick_instructions args, text, y = 715
  return if args.state.key_event_occurred
  if args.inputs.mouse.click ||
     args.inputs.keyboard.directional_vector ||
     args.inputs.keyboard.key_down.enter ||
     args.inputs.keyboard.key_down.escape
    args.state.key_event_occurred = true
  end

  args.outputs.debug << [0, y - 50, 1280, 60].solid
  args.outputs.debug << [640, y, text, 1, 1, 255, 255, 255].label
  args.outputs.debug << [640, y - 25, "(click to dismiss instructions)" , -2, 1, 255, 255, 255].label
end
