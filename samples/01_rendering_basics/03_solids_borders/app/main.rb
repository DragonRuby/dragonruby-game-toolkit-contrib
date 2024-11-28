=begin
APIs listing that haven't been encountered in a previous sample apps:

- args.outputs.solids: Provided an Array or a Hash, solid squares will be
  rendered to the screen.
- args.outputs.borders: Provided an Array or a Hash, borders
  will be rendered to the screen.
- args.outputs.primitives: Provided an Hash with a :primitive_marker key,
  either a solid square or border will be rendered to the screen.
=end

# The parameters required for rects are:
# 1. The bottom left corner (x, y)
# 2. The width (w)
# 3. The height (h)
# 4. The rgba values for the color and transparency (r, g, b, a)
# [100, 100, 400, 500, 0, 255, 0, 180]
# Whether the rect would be filled or not depends on if
# it is added to args.outputs.solids or args.outputs.borders
# (or its :primitive_marker if Hash is sent to args.outputs.primitives)
def tick args
  args.outputs.labels << { x: 640,
                           y: 700,
                           text: "Sample app shows how to create solid squares and borders.",
                           size_px: 22,
                           anchor_x: 0.5,
                           anchor_y: 0.5 }

  # Render solids/borders using Arrays/Tuples
  # Using arrays is quick and dirty and it's recommended to use Hashes long term
  args.outputs.solids << [470, 520, 50, 50]
  args.outputs.solids << [530, 520, 50, 50, 0, 0, 0]
  args.outputs.solids << [590, 520, 50, 50, 255, 0, 0]
  args.outputs.solids << [650, 520, 50, 50, 255, 0, 0, 128]

  # using Hashes
  args.outputs.solids << { x: 710,
                           y: 520,
                           w: 50,
                           h: 50,
                           r: 0,
                           g: 80,
                           b: 40,
                           a: Kernel.tick_count % 255 }

  # primitives outputs requires a primitive_marker to differentiate
  # between a solid or a border
  args.outputs.primitives << { x: 770,
                               y: 520,
                               w: 50,
                               h: 50,
                               r: 0,
                               g: 80,
                               b: 40,
                               a: Kernel.tick_count % 255,
                               primitive_marker: :solid }

  # using :solid sprite
  args.outputs.sprites << { x: 710,
                            y: 460,
                            w: 50,
                            h: 50,
                            path: :solid,
                            r: 0,
                            g: 80,
                            b: 40,
                            a: Kernel.tick_count % 255 }

  # using :solid sprite does not require a primitive marker
  args.outputs.primitives << { x: 770,
                               y: 460,
                               w: 50,
                               h: 50,
                               path: :solid,
                               r: 0,
                               g: 80,
                               b: 40,
                               a: Kernel.tick_count % 255 }


  # you can also render a border
  # Using arrays is quick and dirty and it's recommended to use Hashes long term
  args.outputs.borders << [470, 320, 50, 50]
  args.outputs.borders << [530, 320, 50, 50, 0, 0, 0]
  args.outputs.borders << [590, 320, 50, 50, 255, 0, 0]
  args.outputs.borders << [650, 320, 50, 50, 255, 0, 0, 128]

  args.outputs.borders << { x: 710,
                            y: 320,
                            w: 50,
                            h: 50,
                            r: 0,
                            g: 80,
                            b: 40,
                            a: Kernel.tick_count % 255 }

  # primitives outputs requires a primitive_marker to differentiate
  # between a solid or a border
  args.outputs.borders << { x: 770,
                            y: 320,
                            w: 50,
                            h: 50,
                            r: 0,
                            g: 80,
                            b: 40,
                            a: Kernel.tick_count % 255,
                            primitive_marker: :border }
end
