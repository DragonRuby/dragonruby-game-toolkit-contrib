=begin
APIs listing that haven't been encountered in a previous sample apps:

- args.outputs.lines: Provided an Array or a Hash, lines will be rendered to the screen.
- Kernel.tick_count: This property contains an integer value that
  represents the current frame. DragonRuby renders at 60 FPS. A value of 0
  for Kernel.tick_count represents the initial load of the game.
=end

# The parameters required for lines are:
# 1. The initial point (x, y)
# 2. The end point (x2, y2)
# 3. The rgba values for the color and transparency (r, g, b, a)
#    Creating a line using an Array (quick and dirty):
#    [x, y, x2, y2, r, g, b, a]
#    args.outputs.lines << [100, 100, 300, 300, 255, 0, 255, 255]
#    This would create a line from (100, 100) to (300, 300)
#    The RGB code (255, 0, 255) would determine its color, a purple
#    It would have an Alpha value of 255, making it completely opaque
# 4. Using Hashes, the keys are :x, :y, :x2, :y2, :r, :g, :b, and :a
def tick args
  args.outputs.labels << { x: 640,
                           y: 700,
                           text: "Sample app shows how to create lines.",
                           size_px: 22,
                           anchor_x: 0.5,
                           anchor_y: 0.5 }

  # Render lines using Arrays/Tuples
  # This is quick and dirty and it's recommended to use Hashes long term
  args.outputs.lines  << [380, 450, 675, 450]
  args.outputs.lines  << [380, 410, 875, 410]

  # These examples utilize Kernel.tick_count to change the length of the lines over time
  # Kernel.tick_count is the ticks that have occurred in the game
  # This is accomplished by making either the starting or ending point based on the Kernel.tick_count
  args.outputs.lines  << { x:  380,
                           y:  370,
                           x2: 875,
                           y2: 370,
                           r:  Kernel.tick_count % 255,
                           g:  0,
                           b:  0,
                           a:  255 }

  args.outputs.lines  << { x:  380,
                           y:  330 - Kernel.tick_count % 25,
                           x2: 875,
                           y2: 330,
                           r:  0,
                           g:  0,
                           b:  0,
                           a:  255 }

  args.outputs.lines  << { x:  380 + Kernel.tick_count % 400,
                           y:  290,
                           x2: 875,
                           y2: 290,
                           r:  0,
                           g:  0,
                           b:  0,
                           a:  255 }
end
