=begin

This sample is a minimal implementation of raycasting.
The sample is heavily documented because an understanding of the algorithm cannot easily be determined from the code.

A high level view of the raycasting algorithm is:
 - Given a player having an X and Y position in a 2D tile map, and an angle for the direction they are facing;
 - Consider 60 rays cast from 30 degrees left of the player's viewing angle to 30 degrees right. For each ray:
   - Find a "vertical hit" for the ray i.e. a hit to a vertical side (left or right side) of a solid tile in the 2D map array.
   - Store the X and Y of where this vertical hit occurred and also the distance from the player to that point.
     - If there is no vertical hit, assign a very large number as the distance.
   - Find a "horizontal hit" for the same ray i.e. a hit to a horizontal side (top or bottom side) of a solid tile in the 2D map array.
   - Store the X and Y of where this horizontal hit occurred and also the distance from the player to that point.
     - If there is no horizontal hit, assign a very large number as the distance.
  - Compare the vertical hit and the horizontal hit - the lesser distance is considered the overall hit for the raycast.
  - Render a strip to the screen with a height proportional to how far away the raycast hit was.

This algorithm might not be immediately intuitive, but it is an efficient and fast way to solve "what wall does a ray hit".

=end

# https://github.com/BrennerLittle/DragonRubyRaycast
# https://github.com/3DSage/OpenGL-Raycaster_v1
# https://www.youtube.com/watch?v=gYRrGTC7GtA&ab_channel=3DSage

def tick args
  defaults args
  calc args
  # The `render args` method renders the raycast view to the `:screen` Render Target. The subsequent line renders the
  # :screen Render Target to the display. w and h are multiplied to scale the raycast view up to the full 1280x720
  render args
  args.outputs.sprites << { x: 0, y: 0, w: 1280 * 2.66, h: 720 * 2.25, path: :screen }
  args.outputs.labels  << { x: 30, y: 30.from_top, text: "FPS: #{args.gtk.current_framerate.to_sf}" }
end

def defaults args
  args.state.stage ||= {
    w: 8,       # Width of the tile map (in tiles).
    h: 8,       # Height of the tile map (in tiles).
    sz: 64,     # To define a 3D space, define a size (in arbitrary units) we consider one map tile to be. 
    layout: [
      1, 1, 1, 1, 1, 1, 1, 1,
      1, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 1, 0, 1,
      1, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 1, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 1, 1, 1, 1,
    ]
  }

  args.state.player ||= {
    x: 250,
    y: 250,
    dx: 1,
    dy: 0,
    angle: 0
  }
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
                                     w: 750,
                                     h: 160,
                                     path: :pixel,
                                     r: 89,
                                     g: 125,
                                     b: 206 }

  # Render the floor
  args.outputs[:screen].sprites << { x: 0,
                                     y: 0,
                                     w: 750,
                                     h: 160,
                                     path: :pixel,
                                     r: 117,
                                     g: 113,
                                     b: 97 }


  # Cast 60 rays across 60 degrees
  # Start at +30 degrees; given that angles increase anti-clockwise, this takes us to the left edge of view.
  ra = (args.state.player.angle + 30) % 360

  60.times do |r|

    dof = 0             # Distance (in number of tiles) we have tested the ray cast for a hit.
    max_dof = 8         # Maximum number of tiles' distance to check for a hit. This should be large enough to reach the edge of the map.
    dis_v = 100000      # Distance to a vertical edge hit. Initially set to a huge number so if no hit is recorded then the horizontal hit will always be shorter.
    ra_tan = ra.tan_d   

    # The 14 lines below determine the first point we will consider to check for a wall hit; and the X and Y deltas to add to 
    # move to the next possible tile in that direction.
    # If the player is facing towards the right (cos > 0) then we will use an xo (x offset) of +64 to consider tiles to the right.
    # If the player is facing to the left (cos < 0) then we will use an xo of -64 to consider tiles to the left.
    # If the ray's angle has cos close to 0 then the ray is pointing sheer vertically and is never going to hit the side of a tile...
    # ...in that case we set the dof to max_dof to give up scanning and leave the hit distance at the default 100000
    if ra.cos_d > 0.001
      rx = ((args.state.player.x >> 6) << 6) + 64                       # Initial x ordinate we will consider when scanning to the right
                                                                        # This performs modulo 64 by shifting down then immediately back 6 bits
      ry = (args.state.player.x - rx) * ra_tan + args.state.player.y;   # Initial y ordinate we will consider when scanning to the right
      xo = 64                                                           # X offset to add to consider the next candidate tile
      yo = -xo * ra_tan                                                 # Y offset to add to consider the next candidate tile
    elsif ra.cos_d < -0.001
      rx = ((args.state.player.x >> 6) << 6) - 0.0001                   # Initial x ordinate we will consider when scanning to the left
                                                                        # (there is a slight offset to nudge the position one tile over).
      ry = (args.state.player.x - rx) * ra_tan + args.state.player.y    # Initial y ordinate we will consider when scanning to the left
      xo = -64
      yo = -xo * ra_tan
    else
      rx = args.state.player.x
      ry = args.state.player.y
      dof = max_dof                                                     # We won't hit a vertical edge, so short-circuit scanning
    end

    # The previous 14 lines defined offsets to add to a potential ray hit to move the candidate hit point by one tile.
    # Now we do the actual scanning by checking for a solid tile, and incrementing by those offsets if there isn't a solid tile.
    # One reason this algorithm is considered efficient is because moving to the next candidate tile requires just 3 addition operations.
    while dof < max_dof
      mx = rx >> 6      # Convert the hit x (in 3D space with a tile being 64 units) back to a map tile x by shifting 6 bits.
      mx = mx.to_i      # Cast to an int, to use it for array indexing
      my = ry >> 6
      my = my.to_i
      mp = my * args.state.stage.w + mx
      # If the candidate map position is within bounds of the array and is a solid tile, we have a hit!
      if mp > 0 && mp < args.state.stage.w * args.state.stage.h && args.state.stage.layout[mp] == 1
        dof = max_dof
        dis_v = ra.cos_d * (rx - args.state.player.x) - ra.sin_d * (ry - args.state.player.y)
      # ...else we had no hit, so apply the x and y offsets and try the next candidate hit spot.
      else
        rx += xo
        ry += yo
        dof += 1
      end
    end

    # Now dis_v stores the distance to hitting a vertical edge (or 100000 if no hit), and we note the x and y for a vertical hit
    vx = rx
    vy = ry

    # Find the hit to a horizontal edge. This is largely a repeat of the code above to find a vertical edge hit.
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
      if mp > 0 && mp < args.state.stage.w * args.state.stage.h && args.state.stage.layout[mp] == 1
        dof = 8
        dis_h = ra.cos_d * (rx - args.state.player.x) - ra.sin_d * (ry - args.state.player.y)
      else
        rx += xo
        ry += yo
        dof += 1
      end
    end

    # Default wall color
    color = { r: 52, g: 101, b: 36 }

    # Now dis_h, rx, and ry store the distance and location of a horizontal edge hit.
    # At this point if the vertical hit was closer, swap to those values.
    if dis_v < dis_h
      rx = vx
      ry = vy
      dis_h = dis_v
      # Use a different color for a vertical wall hit.
      color = { r: 109, g: 170, b: 44 }
    end

    # The following two lines fix the "fish eye" effect of seeing a straight wall ahead of you curve away at the edge of your sight.
    # Comment out the 2 lines below to see what we mean!
    ca = (args.state.player.angle - ra) % 360
    dis_h = dis_h * ca.cos_d
    # Determine the render height for the strip proportional to the display height
    line_h = (args.state.stage.sz * 320) / (dis_h)
    # Avoid rendering off-screen by capping the height of lines to 320
    line_h = 320 if line_h > 320
    line_off = 160 - (line_h >> 1)

    # Now render the strip to the `:screen` render target
    args.outputs[:screen].sprites << {
      x: r * 8,
      y: line_off,
      w: 8,
      h: line_h,
      path: :pixel,
      **color
    }

    # Increment the raycast angle for the next iteration of this loop
    ra = (ra - 1) % 360
  end
end
