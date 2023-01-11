=begin

This sample is a more advanced example of raycasting that extends the previous 04_ray_caster sample.
Refer to the prior sample to to understand the fundamental raycasting algorithm.
This sample adds a higher resolution of raycasting, wall textures, simple "drop off" lighting and drawing off a sprite with the level.

# Contributors outside of DragonRuby who also hold Copyright:
# - James Stocks: https://github.com/james-stocks

=end

# https://github.com/BrennerLittle/DragonRubyRaycast
# https://github.com/3DSage/OpenGL-Raycaster_v1
# https://www.youtube.com/watch?v=gYRrGTC7GtA&ab_channel=3DSage

def tick args
  defaults args
  calc args
  render args
  args.outputs.sprites << { x: 0, y: 0, w: 1280 * 2.66, h: 720 * 2.25, path: :screen }
  args.outputs.labels  << { x: 30, y: 30.from_top, text: "FPS: #{args.gtk.current_framerate.to_sf} X: #{args.state.player.x} Y: #{args.state.player.y}" }
end

def defaults args
  args.state.stage ||= {
    w: 8,       # Width of the tile map
    h: 8,       # Height of the tile map
    sz: 64,     # To define a 3D space, define a size (in arbitrary units) we consider one map tile to be. 
    layout: [
      1, 1, 1, 1, 2, 1, 1, 1,
      1, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 3, 0, 1,
      1, 0, 1, 0, 0, 0, 0, 2,
      1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 3, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 2, 1, 1, 1, 1,
    ]
  }

  args.state.player ||= {
    x: 250,
    y: 250,
    dx: 1,
    dy: 0,
    angle: 0
  }
  
  args.state.enemies ||= [{ x: 280, y: 280, type: :alien }]
end

# Update the player's input and movement
def calc args
  xo = 0

  if args.state.player.dx < 0
    xo = -20
  else
    xo = 20
  end

  yo = 0

  if args.state.player.dy < 0
    yo = -20
  else
    yo = 20
  end

  ipx = args.state.player.x.idiv 64.0
  ipx_add_xo = (args.state.player.x + xo).idiv 64.0
  ipx_sub_xo = (args.state.player.x - xo).idiv 64.0

  ipy = args.state.player.y.idiv 64.0
  ipy_add_yo = (args.state.player.y + yo).idiv 64.0
  ipy_sub_yo = (args.state.player.y - yo).idiv 64.0

  if args.inputs.keyboard.right
    args.state.player.angle -= 5
    args.state.player.angle = args.state.player.angle % 360
    args.state.player.dx = args.state.player.angle.cos_d
    args.state.player.dy = -args.state.player.angle.sin_d
  end

  if args.inputs.keyboard.left
    args.state.player.angle += 5
    args.state.player.angle = args.state.player.angle % 360
    args.state.player.dx = args.state.player.angle.cos_d
    args.state.player.dy = -args.state.player.angle.sin_d
  end

  if args.inputs.keyboard.up
    if args.state.stage.layout[ipy * args.state.stage.w + ipx_add_xo] == 0
      args.state.player.x += args.state.player.dx * 5
    end

    if args.state.stage.layout[ipy_add_yo * args.state.stage.w + ipx] == 0
      args.state.player.y += args.state.player.dy * 5
    end
  end

  if args.inputs.keyboard.down
    if args.state.stage.layout[ipy * args.state.stage.w + ipx_sub_xo] == 0
      args.state.player.x -= args.state.player.dx * 5
    end

    if args.state.stage.layout[ipy_sub_yo * args.state.stage.w + ipx] == 0
      args.state.player.y -= args.state.player.dy * 5
    end
  end
end

def render args
  # Render the sky
  args.outputs[:screen].sprites << { x: 0,
                                     y: 160,
                                     w: 480,
                                     h: 160,
                                     path: :pixel,
                                     r: 89,
                                     g: 125,
                                     b: 206 }

  # Render the floor
  args.outputs[:screen].sprites << { x: 0,
                                     y: 0,
                                     w: 480,
                                     h: 160,
                                     path: :pixel,
                                     r: 117,
                                     g: 113,
                                     b: 97 }

  ra = (args.state.player.angle + 30) % 360

  # Collect sprites for the raycast view into an array.
  # These will then be rendered with a single draw call for substantial performance improvement.
  sprites_to_draw = []

  # Save distances of each wall hit. This is used subsequently when drawing sprites.
  depths = []

  # Cast 120 rays across 60 degress - we'll consider the next 0.5 degrees each ray 
  120.times do |r|

    # The next ~120 lines are largely the same as the previous sample. The changes are:
    # - Increment by 0.5 degrees instead of 1 degree for the next ray.
    # - When a wall hit is found, the distance is stored in the `depths` array.
    # - We draw a slice of a wall texture instead of a solid color.
    # - The wall strip for the array hit is appended to `sprites_to_draw` instead of being drawn immediately.
    dof = 0             
    max_dof = 8        
    dis_v = 100000

    ra_tan = Math.tan(ra * Math::PI / 180)

    if ra.cos_d > 0.001
      rx = ((args.state.player.x >> 6) << 6) + 64                       
                                                                        
      ry = (args.state.player.x - rx) * ra_tan + args.state.player.y;   
      xo = 64                                                           
      yo = -xo * ra_tan                                                 
    elsif ra.cos_d < -0.001
      rx = ((args.state.player.x >> 6) << 6) - 0.0001                   
      ry = (args.state.player.x - rx) * ra_tan + args.state.player.y
      xo = -64
      yo = -xo * ra_tan
    else
      rx = args.state.player.x
      ry = args.state.player.y
      dof = max_dof
    end

    while dof < max_dof
      mx = rx >> 6      
      mx = mx.to_i      
      my = ry >> 6
      my = my.to_i
      mp = my * args.state.stage.w + mx
      if mp > 0 && mp < args.state.stage.w * args.state.stage.h && args.state.stage.layout[mp] > 0
        dof = max_dof
        dis_v = ra.cos_d * (rx - args.state.player.x) - ra.sin_d * (ry - args.state.player.y)
        wall_texture_v = args.state.stage.layout[mp]
      else
        rx += xo
        ry += yo
        dof += 1
      end
    end

    vx = rx
    vy = ry

    dof = 0
    dis_h = 100000
    ra_tan = 1.0 / ra_tan

    if ra.sin_d > 0.001
      ry = ((args.state.player.y >> 6) << 6) - 0.0001;
      rx = (args.state.player.y - ry) * ra_tan + args.state.player.x;
      yo = -64;
      xo = -yo * ra_tan;
    elsif ra.sin_d < -0.001
      ry = ((args.state.player.y >> 6) << 6) + 64;
      rx = (args.state.player.y - ry) * ra_tan + args.state.player.x;
      yo = 64;
      xo = -yo * ra_tan;
    else
      rx = args.state.player.x
      ry = args.state.player.y
      dof = 8
    end

    while dof < 8
      mx = (rx) >> 6
      my = (ry) >> 6
      mp = my * args.state.stage.w + mx
      if mp > 0 && mp < args.state.stage.w * args.state.stage.h && args.state.stage.layout[mp] > 0
        dof = 8
        dis_h = ra.cos_d * (rx - args.state.player.x) - ra.sin_d * (ry - args.state.player.y)
        wall_texture = args.state.stage.layout[mp]
      else
        rx += xo
        ry += yo
        dof += 1
      end
    end

    dist = dis_h
    if dis_v < dis_h
      rx = vx
      ry = vy
      dist = dis_v
      wall_texture = wall_texture_v
    end
    # Remember the hit distance
    depths << dist

    # Adjust for fish-eye across FOV
    ca = (args.state.player.angle - ra) % 360
    dist = dist * ca.cos_d
    # Determine the render height for the strip proportional to the display height
    line_h = (args.state.stage.sz * 320) / (dist)

    line_off = 160 - (line_h >> 1)

    # Tint darker further away
    tint = 1.0 - (dist / 500)

    # Wall texturing - Determine the section of source texture to use
    tx = dis_v > dis_h ? (rx.to_i % 64).to_i : (ry.to_i % 64).to_i
    # If player is looking backwards towards a tile then flip the side of the texture to sample.
    # The sample wall textures have a diagonal stripe pattern - if you comment out these lines, you can see from that pattern what is wrong.
    tx = 63 - tx if (ra > 180 && dis_v > dis_h)
    tx = 63 - tx if (ra > 90 && ra < 270 && dis_v < dis_h)

    sprites_to_draw << {
      x: r * 4,
      y: line_off,
      w: 4,
      h: line_h,
      path: "sprites/wall_#{wall_texture}.png",
      source_x: tx,
      source_w: 1,
      r: 255 * tint,
      g: 255 * tint,
      b: 255 * tint
    }

    # Increment the raycast angle for the next iteration of this loop
    ra = (ra - 0.5) % 360
  end

  # Render enemies
  # This sample has only 1 enemy. To have several enemies and/or other sprites on screen, it would be necessary to sort them by distance.
  args.state.enemies.each do |e|
      distance_to_enemy = args.geometry.distance([args.state.player[:x],args.state.player[:y]],[e[:x],e[:y]]).abs
      #scale = 1.0 / ((distance_to_enemy)/64).abs
      #args.outputs.labels  << { x: 30, y: 90.from_top, text: "Distance to enemy: #{distance_to_enemy}" }
      
      # The crux of drawing a sprite in a raycast view is to:
      # 1. rotate the enemy around the player's position and viewing angle to get a position relative to the view
      # 2. Translate that position from "3D space" to screen pixels
      # The next 6 lines get the enemy position relative to the player position and angle:
      ex = e[:x] - args.state.player.x
      ey = e[:y] - args.state.player.y
      cs = Math.cos(args.state.player.angle * Math::PI / 180)
      sn = Math.sin(args.state.player.angle * Math::PI / 180)
      dx = ey * cs + ex * sn
      dy = ex * cs - ey * sn
      
      # The next 5 lines determine the screen x and y of (the center of) the enemy, and a scale
      next if dy == 0 # Avoid invalid Infinity/NaN calculations if the projected Y is 0
      ody = dy
      dx = dx*480/dy + 240
      dy = 32/dy + 32
      scale = 64*180/(ody / 2)

      tint = 1.0 - (distance_to_enemy / 500)

      # Now we know the x and y on-screen for the enemy, and its scale, we can draw it.
      # Simply drawing the sprite on the screen doesn't work in a raycast view because the enemy might be partly hidden by a wall.
      # Instead we draw the enemy in vertical strips, skipping strips if a wall is closer to the player on that vertical strip on the screen.

      # Since dx stores the center x of the enemy on-screen, we start half the scale of the enemy to the left of dx
      x = dx - scale/2
      next if (x > 480 or (dx + scale/2 <= 0)) # Skip rendering if the X position is entirely off screen
      strip = 0                    # Keep track of the number of strips we've drawn
      strip_width = scale / 32     # Draw the sprite in 32 strips
      sample_width = 64/32         # For each strip we will sample 1/32 of sprite image, here we assume 64x64 sprites

      until x >= dx + scale/2 do
          if x > 0 && x < 480
              # Here we get the distance to the wall for this strip on the screen
              wall_depth = depths[(x.to_i/4)]
              if ((distance_to_enemy < wall_depth))
                  sprites_to_draw << {
                      x: x,
                      y: dy + 90 - scale/2,
                      w: strip_width,
                      h: scale,
                      path: "sprites/#{e[:type]}.png",
                      source_x: strip * sample_width,
                      source_w: sample_width,
                      r: 255 * tint,
                      g: 255 * tint,
                      b: 255 * tint
                  }
              end
          end
          x += strip_width
          strip += 1
      end
  end

  # Draw all the sprites we collected in the array to the render target
  args.outputs[:screen].sprites << sprites_to_draw
end
