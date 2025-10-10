# This sample is a more advanced example of raycasting that is based on the lodev raycasting articles.
# Refer to the prior sample to to understand the fundamental raycasting algorithm.
# This sample adds:
#  * Variable number of rays, field of view, and canvas size.
#  * Wall textures
#  * Inverse square law "drop off" lighting
#  * Weapon firing
#  * Drawing of sprites within the level.

# Contributors outside of DragonRuby who also hold Copyright:
# - James Stocks: https://github.com/james-stocks
# - Alex Mooney: https://github.com/AlexMooney

# https://github.com/BrennerLittle/DragonRubyRaycast
# https://lodev.org/cgtutor/raycasting.html
# https://github.com/3DSage/OpenGL-Raycaster_v1
# https://www.youtube.com/watch?v=gYRrGTC7GtA&ab_channel=3DSage

# For a *really* advanced ray caster, check out https://github.com/sojastar/dr_raycaster

def tick args
  defaults args
  update_player args
  update_missiles args
  update_enemies args
  render(args)

  w = args.state.camera[:screen_width]
  h = args.state.camera[:screen_height]
  args.outputs.sprites << { x: 0, y: 0, w: w, h: h, source_h: h, path: :screen }
  debug_text = <<~LABEL
    FPS: #{GTK.current_framerate.to_sf}
    angle: #{args.state.player.angle.to_i}°
    X: #{args.state.player.x.to_sf}
    Y: #{args.state.player.y.to_sf}
    Screen Size (h/j/k/l): #{w}x#{h}
    FOV (u/i): #{args.state.camera[:field_of_view]}°
    Rays (o/p): #{args.state.camera[:number_of_rays]}
  LABEL
  args.outputs.labels << { x: 30, y: 30.from_top, text: debug_text }
end

def defaults args
  args.state.stage ||= {
    layout: [
      [1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1],
      [1, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3],
      [1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 3],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 3],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0],
      [1, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0],
      [1, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0],
      [1, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0, 3],
      [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 3],
      [1, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3],
      [1, 1, 1, 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 1],
    ]
  }
  # 2d array layout means we can calculate width and height instead of having to specify them.
  args.state.stage[:w] ||= args.state.stage.layout[0].size
  args.state.stage[:h] ||= args.state.stage.layout.size

  args.state.player ||= {
    x: 5.5,
    y: 5,
    dx: -1,
    dy: 0,
    speed: 1.0 / 16.0,
    closest_allowed_to_wall: 0.5,
    angle: 180,
    angular_speed: 5,
    fire_cooldown_wait: 0,
    fire_cooldown_duration: 15
  }

  # Add an initial alien enemy.
  # The :bright property indicates that this entity doesn't produce light and should appear dimmer over distance.
  args.state.enemies ||= [
    { x: 2.5, y: 2.5, type: :alien, bright: false, expired: false },
    { x: 6.5, y: 5.5, type: :alien, bright: false, expired: false },
    { x: 2.5, y: 7.5, type: :alien, bright: false, expired: false }
  ]
  args.state.missiles ||= []
  args.state.splashes ||= []
  args.state.camera ||= {
    screen_width: 1280,
    screen_height: 720,
    number_of_rays: 160, # Number of rays to cast determines the resolution of the raycast view.
    field_of_view: 60 # Field of view in degrees
  }
end

# Update the player's input and movement
def update_player args
  player = args.state.player

  if args.inputs.keyboard.right
    player.angle -= player.angular_speed
    player.angle = player.angle % 360
    player.dx = player.angle.cos_d.round(6)
    player.dy = -player.angle.sin_d.round(6)
  end

  if args.inputs.keyboard.left
    player.angle += player.angular_speed
    player.angle = player.angle % 360
    player.dx = player.angle.cos_d.round(6)
    player.dy = -player.angle.sin_d.round(6)
  end

  # Check to see if player will get within closest_allowed_to_wall distance to a wall by going forward or backward.
  grid_x = player.x.to_i
  delta_x = player.closest_allowed_to_wall * player.dx.sign
  grid_x_forward = (player.x + delta_x).to_i
  grid_x_backward = (player.x - delta_x).to_i

  grid_y = player.y.to_i
  delta_y = player.closest_allowed_to_wall * player.dy.sign
  grid_y_forward = (player.y + delta_y).to_i
  grid_y_backward = (player.y - delta_y).to_i

  stage = args.state.stage
  if args.inputs.keyboard.up
    player.x += player.dx * player.speed if stage.layout[grid_y][grid_x_forward] == 0
    player.y += player.dy * player.speed if stage.layout[grid_y_forward][grid_x] == 0
  end

  if args.inputs.keyboard.down
    player.x -= player.dx * player.speed if stage.layout[grid_y][grid_x_backward] == 0
    player.y -= player.dy * player.speed if stage.layout[grid_y_backward][grid_x] == 0
  end

  player.fire_cooldown_wait -= 1 if player.fire_cooldown_wait > 0
  if args.inputs.keyboard.key_down.space && player.fire_cooldown_wait == 0
    m = { x: player.x, y: player.y, angle: player.angle, speed: 1.0/12, type: :missile, bright: true, expired: false }
    # Immediately move the missile forward a frame so it spawns ahead of the player
    m.x += m.angle.cos_d * m.speed
    m.y -= m.angle.sin_d * m.speed
    args.state.missiles << m
    player.fire_cooldown_wait = player.fire_cooldown_duration
  end

  # Allow messing with camera settings here.
  if args.inputs.keyboard.key_down.u
    args.state.camera[:field_of_view] -= 5
  elsif args.inputs.keyboard.key_down.i
    args.state.camera[:field_of_view] += 5
  elsif args.inputs.keyboard.key_down.h
    args.state.camera[:screen_width] -= 40
  elsif args.inputs.keyboard.key_down.l
    args.state.camera[:screen_width] += 40
  elsif args.inputs.keyboard.key_down.j
    args.state.camera[:screen_height] -= 40
  elsif args.inputs.keyboard.key_down.k
    args.state.camera[:screen_height] += 40
  elsif args.inputs.keyboard.key_down.o
    args.state.camera[:number_of_rays] -= 10
  elsif args.inputs.keyboard.key_down.p
    args.state.camera[:number_of_rays] += 10
  end
  args.state.camera[:field_of_view] = args.state.camera[:field_of_view].clamp(15, 180)
  args.state.camera[:screen_width] = args.state.camera[:screen_width].clamp(20, 1280)
  args.state.camera[:screen_height] = args.state.camera[:screen_height].clamp(20, 720)
  args.state.camera[:number_of_rays] = args.state.camera[:number_of_rays].clamp(10, 1280)
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
      if (new_x - e.x).abs < 0.25 && (new_y - e.y).abs < 0.25
        e.expired = true
        m.expired = true
        args.state.splashes << { x: m.x, y: m.y, ttl: 5, type: :splash, bright: true }
        next
      end
    end
    # Hit walls
    if args.state.stage.layout[new_y.to_i][new_x.to_i] != 0
      m.expired = true
      args.state.splashes << { x: m.x, y: m.y, ttl: 5, type: :splash, bright: true }
    else
      m.x = new_x
      m.y = new_y
    end
  end
  args.state.splashes.map! { |s| ((s.ttl -= 1) < 0) ? nil : s }
  args.state.splashes.compact!
end

def update_enemies args
  args.state.enemies.map! { |e| e.expired ? nil : e }
  args.state.enemies.compact!
end

def render args
  screen_width = args.state.camera[:screen_width]
  screen_height = args.state.camera[:screen_height]
  number_of_rays = args.state.camera[:number_of_rays]
  max_draw_distance = 24 # How many tiles away until the ray stops drawing
  light_length = 10 # How many tiles away until brightness is 25%
  texture_width = 64 # Width of the wall textures in pixels

  player = args.state.player

  # Build a camera vector perpendicular to player's angle with magnitide set to get desired FOV.
  camera_scale = (args.state.camera[:field_of_view] / 2.0).tan_d
  player_dir_x = player.angle.cos_d
  player_dir_y = player.angle.sin_d
  camera_dir_x = camera_scale * (player.angle + 90.0).cos_d
  camera_dir_y = camera_scale * (player.angle + 90.0).sin_d

  slice_width = screen_width / number_of_rays

  # Render the sky
  args.outputs[:screen].sprites << { x: 0,
                                     y: screen_height / 2,
                                     w: screen_width,
                                     h: screen_height / 2,
                                     path: :pixel,
                                     r: 89,
                                     g: 125,
                                     b: 206 }

  # Render the floor
  args.outputs[:screen].sprites << { x: 0,
                                     y: 0,
                                     w: screen_width,
                                     h: screen_height / 2,
                                     path: :pixel,
                                     r: 117,
                                     g: 113,
                                     b: 97 }

  # Collect sprites for the raycast view into an array - these will all be rendered with a single draw call.
  # This gives a substantial performance improvement over the previous sample where there was one draw call
  # per sprite.
  sprites_to_draw = []

  # Save distances of each wall hit. This is used subsequently when drawing sprites.
  depths = []

  # Cast however many rays across the FOV evenly.
  number_of_rays.times do |ray_idx|
    camera_x = -2.0 * ray_idx / number_of_rays + 1.0 # Screen coordinate: -1 is left edge, +1 is right edge
    ray_dir_x = player_dir_x + camera_dir_x * camera_x
    ray_dir_y = -(player_dir_y + camera_dir_y * camera_x)

    # Are x and y moving in positive or negative direction?
    step_x = ray_dir_x.sign
    step_y = ray_dir_y.sign

    # Which map cell the ray is currently in.
    map_x = player.x.to_i
    # map_x += 1 if step_x.positive?
    map_y = player.y.to_i
    # map_y += 1 if step_y.negative?

    # Distance to go from one x or y grid line to the next. These will be used to step to the next map edge.
    delta_dist_x = (ray_dir_x == 0) ? Float::INFINITY : (1 / ray_dir_x).abs
    delta_dist_y = (ray_dir_y == 0) ? Float::INFINITY : (1 / ray_dir_y).abs

    # Distance the ray travels to cross the closest x or y grid line. Initialized based on player's position.
    side_dist_x = if ray_dir_x.negative?
                    (player.x - map_x) * delta_dist_x
                  else
                    (map_x + 1 - player.x) * delta_dist_x
                  end
    side_dist_y = if ray_dir_y.negative?
                    (player.y - map_y) * delta_dist_y
                  else
                    (map_y + 1 - player.y) * delta_dist_y
                  end

    # DDA: find the first wall hit by stepping through the map along the ray.
    hit = false
    hit_side = nil
    wall_texture = nil
    max_draw_distance.times do
      if side_dist_x < side_dist_y
        # Move to the next vertical grid line
        side_dist_x += delta_dist_x
        map_x += step_x
        hit_side = :vertical
      else
        # Move to the next horizontal grid line
        side_dist_y += delta_dist_y
        map_y += step_y
        hit_side = :horizontal
      end
      # Stop if we have gone out of bounds of the map.
      break if !(0...args.state.stage.w).cover?(map_x) || !(0...args.state.stage.h).cover?(map_y)

      # Check if the ray hit a wall
      if args.state.stage.layout[map_y][map_x] > 0
        wall_texture = args.state.stage.layout[map_y][map_x]
        hit = true
        break
      end
    end

    # Calculate the distance from the camera plane to the wall hit and the wall texture coordinates.
    camera_distance = Float::INFINITY
    texture_x = 0
    if hit && hit_side == :vertical
      camera_distance = side_dist_x - delta_dist_x
      texture_x = player.y + camera_distance * ray_dir_y
    elsif hit && hit_side == :horizontal
      camera_distance = side_dist_y - delta_dist_y
      texture_x = player.x + camera_distance * ray_dir_x
    end
    texture_x = ((texture_x % 1.0) * texture_width).to_i
    # If player is looking backwards towards a tile then flip the side of the texture to sample.
    # The sample wall textures have a diagonal stripe pattern - if you comment out these 2 lines,
    # you will see what goes wrong with texturing.
    if (hit_side == :vertical && step_x.positive?) || (hit_side == :horizontal && step_y.negative?)
      texture_x = 63 - texture_x
    end

    next if !hit

    # Determine the render height for the strip proportional to the display height
    line_height = (screen_height / camera_distance)
    line_offset = ((screen_height - line_height) / 2.0)

    # Tint the wall strip - the further away it is, the darker, following an inverse square law.
    euclidean_distance = (ray_dir_x**2 + ray_dir_y**2)**0.5 * camera_distance
    # Store the game world distance for a wall hit at this angle for sprite ordering later.
    depths << euclidean_distance

    tint = 1.0 - (euclidean_distance / light_length)**2

    sprites_to_draw << {
      x: ray_idx * slice_width,
      y: line_offset,
      w: slice_width,
      h: line_height,
      path: "sprites/wall_#{wall_texture}.png",
      source_x: texture_x,
      source_w: 1,
      r: 255 * tint,
      g: 255 * tint,
      b: 255 * tint
    }
  end

  # Render sprites
  # Use common render code for enemies, missiles and explosion splashes.
  # This works because they are all hashes with :x, :y, and :type fields.
  things_to_draw = []
  things_to_draw.push(*args.state.enemies)
  things_to_draw.push(*args.state.missiles)
  things_to_draw.push(*args.state.splashes)

  # Do a first-pass on the things to draw, calculate distance from player and then sort so more-distant things are drawn
  # first.  We are using this only to sort, so don't spend time calculating the square root.
  things_to_draw.each do |thing|
    thing[:dist_squared] = Geometry.distance_squared([args.state.player[:x], args.state.player[:y]], [thing[:x], thing[:y]]).abs
  end
  things_to_draw = things_to_draw.sort_by { |thing| thing[:dist_squared] }

  # Now draw everything, most distant entities first.
  things_to_draw.reverse_each do |thing|
    # The crux of drawing a sprite in a raycast view is to:
    #   1. rotate the enemy around the player's position and viewing angle to get a position relative to the view.
    #   2. Translate that position from "3D space" to screen pixels.
    thing_delta_x = thing[:x] - args.state.player.x
    thing_delta_y = thing[:y] - args.state.player.y

    rotated_delta_x = thing_delta_y * player_dir_x + thing_delta_x * player_dir_y
    # This is the euclidean distance to thing when thing's in front of us but it is negative when things's behind us.
    distance_to_thing = thing_delta_x * player_dir_x - thing_delta_y * player_dir_y
    next unless distance_to_thing.positive?

    # The next 4 lines determine the screen x and y of (the center of) the entity, and a scale
    next if distance_to_thing == 0 # Avoid invalid Infinity/NaN calculations if the projected Y is 0
    scale_y = screen_height / distance_to_thing
    scale_x = screen_width / (2 * distance_to_thing * camera_scale)
    screen_x = screen_width * rotated_delta_x / (2 * distance_to_thing * camera_scale) + screen_width / 2.0
    screen_y = screen_height / 2 - scale_y * 0.5
    tint = thing[:bright] ? 1.0 : 1.0 - (distance_to_thing / light_length)**2

    # Now we know the x and y on-screen for the entity, and its scale, we can draw it. Simply drawing the sprite on the
    # screen doesn't work in a raycast view because the entity might be partly obscured by a wall. Instead we draw the
    # entity in vertical strips, skipping strips if a wall is closer to the player on that strip of the screen. To do
    # this perfectly, you'd have to align the vertical strips with the raycast rays. This approach is a good
    # approximation

    # Since dx stores the center x of the enemy on-screen, we start half the scale of the enemy to the left of dx
    x = screen_x - scale_x / 2
    next if x > screen_width || (screen_x + scale_x / 2 <= 0) # Skip rendering if the X position is entirely off-screen
    strip = 0                    # Keep track of the number of strips we've drawn
    strip_width = scale_x / 64   # Draw the sprite in 64 strips
    sample_width = 1             # For each strip we will sample 1/64 of sprite image, here we assume 64x64 sprites

    while x < screen_x + scale_x / 2 do
      if (-strip_width..screen_width).cover?(x)
        # Here we get the distance to the wall for this strip on the screen
        wall_depth = depths[(x / (screen_width / number_of_rays)).round] || Float::INFINITY
        if distance_to_thing < wall_depth
          sprites_to_draw << {
            x: x,
            y: screen_y,
            w: strip_width,
            h: scale_y,
            path: "sprites/#{thing[:type]}.png",
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
