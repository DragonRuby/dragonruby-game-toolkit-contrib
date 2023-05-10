# the sample app is an expansion of ./01_simple_aabb_collision
# but includes an in game map editor that saves map data to disk
def tick args
  # if it's the first tick, read the terrain data from disk
  # and create the player
  if args.state.tick_count == 0
    args.state.terrain = read_terrain_data args

    args.state.player = {
      x: 320,
      y: 320,
      w: 32,
      h: 32,
      dx: 0,
      dy: 0,
      path: 'sprites/square/red.png'
    }
  end

  # tick the game (where input and aabb collision is processed)
  tick_game args

  # tick the map editor
  tick_map_editor args
end

def tick_game args
  # render terrain and player
  args.outputs.sprites << args.state.terrain
  args.outputs.sprites << args.state.player

  # set dx and dy based on inputs
  args.state.player.dx = args.inputs.left_right * 2
  args.state.player.dy = args.inputs.up_down * 2

  # check for collisions on the x and y axis independently

  # increment the player's position by dx
  args.state.player.x += args.state.player.dx

  # check for collision on the x axis first
  collision = args.state.terrain.find { |t| t.intersect_rect? args.state.player }

  # if there is a collision, move the player to the edge of the collision
  # based on the direction of the player's movement and set the player's
  # dx to 0
  if collision
    if args.state.player.dx > 0
      args.state.player.x = collision.x - args.state.player.w
    elsif args.state.player.dx < 0
      args.state.player.x = collision.x + collision.w
    end
    args.state.player.dx = 0
  end

  # increment the player's position by dy
  args.state.player.y += args.state.player.dy

  # check for collision on the y axis next
  collision = args.state.terrain.find { |t| t.intersect_rect? args.state.player }

  # if there is a collision, move the player to the edge of the collision
  # based on the direction of the player's movement and set the player's
  # dy to 0
  if collision
    if args.state.player.dy > 0
      args.state.player.y = collision.y - args.state.player.h
    elsif args.state.player.dy < 0
      args.state.player.y = collision.y + collision.h
    end
    args.state.player.dy = 0
  end
end

def tick_map_editor args
  # determine the location of the mouse, but
  # aligned to the grid
  grid_aligned_mouse_rect = {
    x: args.inputs.mouse.x.idiv(32) * 32,
    y: args.inputs.mouse.y.idiv(32) * 32,
    w: 32,
    h: 32
  }

  # determine if there's a tile at the grid aligned mouse location
  existing_terrain = args.state.terrain.find { |t| t.intersect_rect? grid_aligned_mouse_rect }

  # if there is, then render a red square to denote that
  # the tile will be deleted
  if existing_terrain
    args.outputs.sprites << {
      x: args.inputs.mouse.x.idiv(32) * 32,
      y: args.inputs.mouse.y.idiv(32) * 32,
      w: 32,
      h: 32,
      path: "sprites/square/red.png",
      a: 128
    }
  else
    # otherwise, render a blue square to denote that
    # a tile will be added
    args.outputs.sprites << {
      x: args.inputs.mouse.x.idiv(32) * 32,
      y: args.inputs.mouse.y.idiv(32) * 32,
      w: 32,
      h: 32,
      path: "sprites/square/blue.png",
      a: 128
    }
  end

  # if the mouse is clicked, then add or remove a tile
  if args.inputs.mouse.click
    if existing_terrain
      args.state.terrain.delete existing_terrain
    else
      args.state.terrain << { **grid_aligned_mouse_rect, path: "sprites/square/blue.png" }
    end

    # once the terrain state has been updated
    # save the terrain data to disk
    write_terrain_data args
  end
end

def read_terrain_data args
  # create the terrain data file if it doesn't exist
  contents = args.gtk.read_file "data/terrain.txt"
  if !contents
    args.gtk.write_file "data/terrain.txt", ""
  end

  # read the terrain data from disk which is a csv
  args.gtk.read_file('data/terrain.txt').split("\n").map do |line|
    x, y, w, h = line.split(',').map(&:to_i)
    { x: x, y: y, w: w, h: h, path: 'sprites/square/blue.png' }
  end
end

def write_terrain_data args
  terrain_csv = args.state.terrain.map { |t| "#{t.x},#{t.y},#{t.w},#{t.h}" }.join "\n"
  args.gtk.write_file 'data/terrain.txt', terrain_csv
end
