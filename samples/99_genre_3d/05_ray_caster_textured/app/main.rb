=begin

This sample is a more advanced example of raycasting that extends the previous 04_ray_caster sample.
Refer to the prior sample to to understand the fundamental raycasting algorithm.
This sample adds:
 * higher resolution of raycasting
 * Wall textures
 * Simple "drop off" lighting
 * Weapon firing
 * Drawing of sprites within the level.

# Contributors outside of DragonRuby who also hold Copyright:
# - James Stocks: https://github.com/james-stocks

=end

# https://github.com/BrennerLittle/DragonRubyRaycast
# https://github.com/3DSage/OpenGL-Raycaster_v1
# https://www.youtube.com/watch?v=gYRrGTC7GtA&ab_channel=3DSage

def tick args
  defaults args
  update_player args
  update_missiles args
  update_enemies args
  render args
  args.outputs.sprites << { x: 0, y: 0, w: 1280 * 1.5, h: 720 * 1.2, path: :screen }
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
    angle: 0,
    fire_cooldown_wait: 0,
    fire_cooldown_duration: 15
  }
  
  # Add an initial alien enemy.
  # The :bright property indicates that this entity doesn't produce light and should appear dimmer over distance.
  args.state.enemies ||= [{ x: 280, y: 280, type: :alien, bright: false, expired: false }]
  args.state.missiles ||= []
  args.state.splashes ||= []
end

# Update the player's input and movement
def update_player args

  player = args.state.player
  player.fire_cooldown_wait -= 1 if player.fire_cooldown_wait > 0

  xo = 0

  if player.dx < 0
    xo = -20
  else
    xo = 20
  end

  yo = 0

  if player.dy < 0
    yo = -20
  else
    yo = 20
  end

  ipx = player.x.idiv 64.0
  ipx_add_xo = (player.x + xo).idiv 64.0
  ipx_sub_xo = (player.x - xo).idiv 64.0

  ipy = player.y.idiv 64.0
  ipy_add_yo = (player.y + yo).idiv 64.0
  ipy_sub_yo = (player.y - yo).idiv 64.0

  if args.inputs.keyboard.right
    player.angle -= 5
    player.angle = player.angle % 360
    player.dx = player.angle.cos_d
    player.dy = -player.angle.sin_d
  end

  if args.inputs.keyboard.left
    player.angle += 5
    player.angle = player.angle % 360
    player.dx = player.angle.cos_d
    player.dy = -player.angle.sin_d
  end

  if args.inputs.keyboard.up
    if args.state.stage.layout[ipy * args.state.stage.w + ipx_add_xo] == 0
      player.x += player.dx * 5
    end

    if args.state.stage.layout[ipy_add_yo * args.state.stage.w + ipx] == 0
      player.y += player.dy * 5
    end
  end

  if args.inputs.keyboard.down
    if args.state.stage.layout[ipy * args.state.stage.w + ipx_sub_xo] == 0
      player.x -= player.dx * 5
    end

    if args.state.stage.layout[ipy_sub_yo * args.state.stage.w + ipx] == 0
      player.y -= player.dy * 5
    end
  end

  if args.inputs.keyboard.key_down.space && player.fire_cooldown_wait == 0
    m = { x: player.x, y: player.y, angle: player.angle, speed: 6, type: :missile, bright: true, expired: false }
    # Immediately move the missile forward a frame so it spawns ahead of the player
    m.x += m.angle.cos_d * m.speed
    m.y -= m.angle.sin_d * m.speed
    args.state.missiles << m
    player.fire_cooldown_wait = player.fire_cooldown_duration
  end
end

def update_missiles args
  # Remove expired missiles by mapping expired missiles to `nil` and then calling `compact!` to
  # remove nil entries.
  args.state.missiles.map! { |m| m.expired ? nil : m }
  args.state.missiles.compact!

  args.state.missiles.each do |m|
    new_x = m.x + m.angle.cos_d * m.speed
    new_y = m.y - m.angle.sin_d * m.speed
    # Hit enemies
    args.state.enemies.each do |e|
        if (new_x - e.x).abs < 16 && (new_y - e.y).abs < 16
            e.expired = true
            m.expired = true
            args.state.splashes << { x: m.x, y: m.y, ttl: 5, type: :splash, bright: true }
            next
        end
    end
    # Hit walls
    if(args.state.stage.layout[(new_y / 64).to_i * args.state.stage.w + (new_x / 64).to_i] != 0)
      m.expired = true
      args.state.splashes << { x: m.x, y: m.y, ttl: 5, type: :splash, bright: true }
    else
      m.x = new_x
      m.y = new_y
    end
  end
  args.state.splashes.map! { |s| s.ttl <= 0 ? nil : s }
  args.state.splashes.compact!
  args.state.splashes.each do |s|
    s.ttl -= 1
  end
end

def update_enemies args
    args.state.enemies.map! { |e| e.expired ?  nil : e }
    args.state.enemies.compact!
end

def render args
  # Render the sky
  args.outputs[:screen].sprites << { x: 0,
                                     y: 320,
                                     w: 960,
                                     h: 320,
                                     path: :pixel,
                                     r: 89,
                                     g: 125,
                                     b: 206 }

  # Render the floor
  args.outputs[:screen].sprites << { x: 0,
                                     y: 0,
                                     w: 960,
                                     h: 320,
                                     path: :pixel,
                                     r: 117,
                                     g: 113,
                                     b: 97 }

  ra = (args.state.player.angle + 30) % 360

  # Collect sprites for the raycast view into an array - these will all be rendered with a single draw call.
  # This gives a substantial performance improvement over the previous sample where there was one draw call
  # per sprite.
  sprites_to_draw = []

  # Save distances of each wall hit. This is used subsequently when drawing sprites.
  depths = []

  # Cast 120 rays across 60 degress - we'll consider the next 0.5 degrees each ray 
  120.times do |r|

    # The next ~120 lines are largely the same as the previous sample. The changes are:
    # - Increment by 0.5 degrees instead of 1 degree for the next ray.
    # - When a wall hit is found, the distance is stored in the `depths` array.
    #   - `depths` is used later when rendering enemies and bullet.
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
    # Store the distance for a wall hit at this angle
    depths << dist

    # Adjust for fish-eye across FOV
    ca = (args.state.player.angle - ra) % 360
    dist = dist * ca.cos_d
    # Determine the render height for the strip proportional to the display height
    line_h = (args.state.stage.sz * 640) / (dist)

    line_off = 320 - (line_h >> 1)

    # Tint the wall strip - the further away it is, the darker.
    tint = 1.0 - (dist / 500)

    # Wall texturing - Determine the section of source texture to use
    tx = dis_v > dis_h ? (rx.to_i % 64).to_i : (ry.to_i % 64).to_i
    # If player is looking backwards towards a tile then flip the side of the texture to sample.
    # The sample wall textures have a diagonal stripe pattern - if you comment out these 2 lines, 
    # you will see what goes wrong with texturing.
    tx = 63 - tx if (ra > 180 && dis_v > dis_h)
    tx = 63 - tx if (ra > 90 && ra < 270 && dis_v < dis_h)

    sprites_to_draw << {
      x: r * 8,
      y: line_off,
      w: 8,
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

  # Render sprites
  # Use common render code for enemies, missiles and explosion splashes.
  # This works because they are all hashes with :x, :y, and :type fields.
  things_to_draw = []
  things_to_draw.push(*args.state.enemies)
  things_to_draw.push(*args.state.missiles)
  things_to_draw.push(*args.state.splashes)

  # Do a first-pass on the things to draw, calculate distance from player and then
  # sort so more-distant things are drawn first.
  things_to_draw.each do |t|
    t[:dist] = args.geometry.distance([args.state.player[:x],args.state.player[:y]],[t[:x],t[:y]]).abs
  end
  things_to_draw = things_to_draw.sort_by { |t| t[:dist] }.reverse

  # Now draw everything, most distant entities first. 
  things_to_draw.each do |t|
      distance_to_thing = t[:dist]
      # The crux of drawing a sprite in a raycast view is to:
      #   1. rotate the enemy around the player's position and viewing angle to get a position relative to the view.
      #   2. Translate that position from "3D space" to screen pixels.
      # The next 6 lines get the entitiy's position relative to the player position and angle:
      tx = t[:x] - args.state.player.x
      ty = t[:y] - args.state.player.y
      cs = Math.cos(args.state.player.angle * Math::PI / 180)
      sn = Math.sin(args.state.player.angle * Math::PI / 180)
      dx = ty * cs + tx * sn
      dy = tx * cs - ty * sn
      
      # The next 5 lines determine the screen x and y of (the center of) the entity, and a scale
      next if dy == 0 # Avoid invalid Infinity/NaN calculations if the projected Y is 0
      ody = dy
      dx = dx*640/(dy) + 480
      dy = 32/dy + 192
      scale = 64*360/(ody / 2)

      tint = t[:bright] ? 1.0 : 1.0 - (distance_to_thing / 500)

      # Now we know the x and y on-screen for the entity, and its scale, we can draw it.
      # Simply drawing the sprite on the screen doesn't work in a raycast view because the entity might be partly obscured by a wall.
      # Instead we draw the entity in vertical strips, skipping strips if a wall is closer to the player on that strip of the screen.

      # Since dx stores the center x of the enemy on-screen, we start half the scale of the enemy to the left of dx
      x = dx - scale/2
      next if (x > 960 or (dx + scale/2 <= 0)) # Skip rendering if the X position is entirely off-screen
      strip = 0                    # Keep track of the number of strips we've drawn
      strip_width = scale / 64     # Draw the sprite in 64 strips
      sample_width = 1             # For each strip we will sample 1/64 of sprite image, here we assume 64x64 sprites

      until x >= dx + scale/2 do
          if x > 0 && x < 960
              # Here we get the distance to the wall for this strip on the screen
              wall_depth = depths[(x.to_i/8)]
              if ((distance_to_thing < wall_depth))
                  sprites_to_draw << {
                      x: x,
                      y: dy + 120 - scale * 0.6,
                      w: strip_width,
                      h: scale,
                      path: "sprites/#{t[:type]}.png",
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
