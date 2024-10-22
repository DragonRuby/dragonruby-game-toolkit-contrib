=begin
APIs listing that haven't been encountered in a previous sample apps:
- args.outputs.sprites: Provided an Array or a Hash, a sprite will be
  rendered to the screen.

Properties of a sprite:
{
  # common properties
  x: 0,
  y: 0,
  w: 100,
  h: 100,
  path: "sprites/square/blue.png",
  angle: 90,
  a: 255,

  # anchoring (float value representing a percentage to offset w and h)
  anchor_x: 0,
  anchor_y: 0,
  angle_anchor_x: 0,
  angle_anchor_y: 0,

  # color saturation
  r: 255,
  g: 255,
  b: 255,

  # flip rendering
  flip_horizontally: false,
  flip_vertically: false

  # sprite sheet properties/clipped rect (using the top-left as the origin)
  tile_x: 0,
  tile_y: 0,
  tile_w: 20,
  tile_h: 20

  # sprite sheet properties/clipped rect (using the bottom-left as the origin)
  source_x: 0,
  source_y: 0,
  source_w: 20,
  source_h: 20,
}
=end
def tick args
  args.outputs.labels << { x: 640,
                           y: 700,
                           text: "Sample app shows how to render a sprite.",
                           size_px: 22,
                           anchor_x: 0.5,
                           anchor_y: 0.5 }

  # ==================
  # ROW 1 Simple Rendering
  # ==================
  args.outputs.labels << { x: 460,
                           y: 600,
                           text: "Simple rendering." }

  # using quick and dirty Array (use Hashes for long term maintainability)
  args.outputs.sprites << [460, 470, 128, 101, 'dragonruby.png']

  # using Hashes
  args.outputs.sprites << { x: 610,
                            y: 470,
                            w: 128,
                            h: 101,
                            path: 'dragonruby.png',
                            a: Kernel.tick_count % 255 }

  args.outputs.sprites << { x: 760 + 64,
                            y: 470 + 50,
                            w: 128,
                            h: 101,
                            anchor_x: 0.5,
                            anchor_y: 0.5,
                            path: 'dragonruby.png',
                            flip_horizontally: true,
                            flip_vertically: true,
                            a: Kernel.tick_count % 255 }

  # ==================
  # ROW 2 Angle/Angle Anchors
  # ==================
  args.outputs.labels << { x: 460,
                           y: 400,
                           text: "Angle/Angle Anchors." }
  # rotation using angle (in degrees)
  args.outputs.sprites << { x: 460,
                            y: 270,
                            w: 128,
                            h: 101,
                            path: 'dragonruby.png',
                            angle: Kernel.tick_count % 360 }

  # rotation anchor using angle_anchor_x
  args.outputs.sprites << { x: 760,
                            y: 270,
                            w: 128,
                            h: 101,
                            path: 'dragonruby.png',
                            angle: Kernel.tick_count % 360,
                            angle_anchor_x: 0,
                            angle_anchor_y: 0 }

  # ==================
  # ROW 3 Sprite Cropping
  # ==================
  args.outputs.labels << { x: 460,
                           y: 200,
                           text: "Cropping (tile sheets)." }

  # tiling using top left as the origin
  args.outputs.sprites << { x: 460,
                            y: 90,
                            w: 80,
                            h: 80,
                            path: 'dragonruby.png',
                            tile_x: 0,
                            tile_y: 0,
                            tile_w: 80,
                            tile_h: 80 }

  # overlay to see how tile_* crops
  args.outputs.sprites << { x: 460,
                            y: 70,
                            w: 128,
                            h: 101,
                            path: 'dragonruby.png',
                            a: 80 }

  # tiling using bottom left as the origin
  args.outputs.sprites << { x: 610,
                            y: 70,
                            w: 80,
                            h: 80,
                            path: 'dragonruby.png',
                            source_x: 0,
                            source_y: 0,
                            source_w: 80,
                            source_h: 80 }

  # overlay to see how source_* crops
  args.outputs.sprites << { x: 610,
                            y: 70,
                            w: 128,
                            h: 101,
                            path: 'dragonruby.png',
                            a: 80 }
end
