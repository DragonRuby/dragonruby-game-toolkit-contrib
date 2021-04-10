# An example of some major components in a tower defence game
# The pathing of the tanks is determined by A* algorithm -- try editing the walls

# The turrets shoot bullets at the closest tank. The bullets are heat-seeking

def tick args
  $gtk.reset if args.inputs.keyboard.key_down.r
  defaults args
  render args
  calc args
end

def defaults args
  args.outputs.background_color = wall_color
  args.state.grid_size = 5
  args.state.tile_size = 50
  args.state.grid_start ||= [0, 0]
  args.state.grid_goal  ||= [4, 4]

  # Try editing these walls to see the path change!
  args.state.walls ||= {
    [0, 4] => true,
    [1, 3] => true,
    [3, 1] => true,
    # [4, 0] => true,
  }

  args.state.a_star.frontier ||= []
  args.state.a_star.came_from ||= {}
  args.state.a_star.path ||= []

  args.state.tanks ||= []
  args.state.tank_spawn_period ||= 60
  args.state.tank_sprite_path ||= 'sprites/circle/white.png'
  args.state.tank_speed ||= 1

  args.state.turret_shoot_period = 10
  # Turrets can be entered as [x, y] but are immediately mapped to hashes
  # Walls are also added where the turrets are to prevent tanks from pathing over them
  args.state.turrets ||= [
    [2, 2]
  ].each { |turret| args.state.walls[turret] = true}.map do |x, y|
    {
      x: x * args.state.tile_size,
      y: y * args.state.tile_size,
      w: args.state.tile_size,
      h: args.state.tile_size,
      path: 'sprites/circle/gray.png',
      range: 100
    }
  end

  args.state.bullet_size ||= 25
  args.state.bullets ||= []
  args.state.bullet_path ||= 'sprites/circle/orange.png'
  #
end

def render args
  render_grid args
  render_a_star args
  args.outputs.sprites << args.state.tanks
  args.outputs.sprites << args.state.turrets
  args.outputs.sprites << args.state.bullets
end

def render_grid args
  # Draw a square the size and color of the grid
  args.outputs.solids << [
    0,
    0,
    args.state.grid_size * args.state.tile_size,
    args.state.grid_size * args.state.tile_size,
    grid_color
  ]

  # Draw lines across the grid to show tiles
  (args.state.grid_size + 1).times do | value |
    render_horizontal_line(args, value)
    render_vertical_line(args, value)
  end

  # Render special tiles
  render_tile(args, args.state.grid_start, start_color)
  render_tile(args, args.state.grid_goal, goal_color)
  args.state.walls.keys.each { |wall| render_tile(args, wall, wall_color) }
end

def render_vertical_line args, x
  args.outputs.lines << [
    x * args.state.tile_size,
    0,
    x * args.state.tile_size,
    args.state.tile_size * args.state.grid_size,
  ]
end

def render_horizontal_line args, y
  args.outputs.lines << [
    0,
    y * args.state.tile_size,
    args.state.tile_size * args.state.grid_size,
    y * args.state.tile_size,
  ]
end

def render_tile args, tile, color
  args.outputs.solids << [
    tile.x * args.state.tile_size,
    tile.y * args.state.tile_size,
    args.state.tile_size,
    args.state.tile_size,
    color
  ]
end

def calc args
  calc_a_star args
  calc_tanks args
  calc_turrets args
  calc_bullets args
end

def calc_a_star args
  # Only does this one time
  return unless args.state.a_star.path.empty?

  # Start the search from the grid start
  args.state.a_star.frontier << args.state.grid_start
  args.state.a_star.came_from[args.state.grid_start] = nil

  # Until a path to the goal has been found or there are no more tiles to explore
  until (args.state.a_star.came_from.has_key?(args.state.grid_goal)|| args.state.a_star.frontier.empty?)
    # For the first tile in the frontier
    tile_to_expand_from = args.state.a_star.frontier.shift
    # Add each of its neighbors to the frontier
    neighbors(args, tile_to_expand_from).each do | tile |
      args.state.a_star.frontier << tile
      args.state.a_star.came_from[tile] = tile_to_expand_from
    end
  end

  # Stop calculating a path if the goal was never reached
  return unless args.state.a_star.came_from.has_key? args.state.grid_goal

  # Fill path by tracing back from the goal
  current_cell = args.state.grid_goal
  while current_cell
    args.state.a_star.path.unshift current_cell
    current_cell = args.state.a_star.came_from[current_cell]
  end

  puts "The path has been calculated"
  puts args.state.a_star.path
end

def calc_tanks args
  spawn_tank args
  move_tanks args
end

def move_tanks args
  # Remove tanks that have reached the end of their path
  args.state.tanks.reject! { |tank| tank[:a_star].empty? }

  # Tanks have an array that has each tile it has to go to in order from a* path
  args.state.tanks.each do | tank |
    destination = tank[:a_star][0]
    # Move the tank towards the destination
    tank[:x] += copy_sign(args.state.tank_speed, ((destination.x * args.state.tile_size) - tank[:x]))
    tank[:y] += copy_sign(args.state.tank_speed, ((destination.y * args.state.tile_size) - tank[:y]))
    # If the tank has reached its destination
    if (destination.x * args.state.tile_size) == tank[:x] and
        (destination.y * args.state.tile_size) == tank[:y]
      # Set the destination to the next point in the path
      tank[:a_star].shift
    end
  end
end

def calc_turrets args
  return unless args.state.tick_count.mod_zero? args.state.turret_shoot_period
  args.state.turrets.each do | turret |
    # Finds the closest tank
    target = nil
    shortest_distance = turret[:range] + 1
    args.state.tanks.each do | tank |
      distance = distance_between(turret[:x], turret[:y], tank[:x], tank[:y])
      if distance < shortest_distance
        target = tank
        shortest_distance = distance
      end
    end
    # If there is a tank in range, fires a bullet
    if target
      args.state.bullets << {
        x: turret[:x],
        y: turret[:y],
        w: args.state.bullet_size,
        h: args.state.bullet_size,
        path: args.state.bullet_path,
        # Note that this makes it heat-seeking, because target is passed by reference
        # Could do target.clone to make the bullet go to where the tank initially was
        target: target
      }
    end
  end
end

def calc_bullets args
  # Bullets aim for the center of their targets
  args.state.bullets.each { |bullet| move bullet, center_of(bullet[:target])}
  args.state.bullets.reject! { |b| b.intersect_rect? b[:target] }
end

def center_of object
  object = object.clone
  object[:x] += 0.5
  object[:y] += 0.5
  object
end

def render_a_star args
  args.state.a_star.path.map do |tile|
    # Map each x, y coordinate to the center of the tile and scale up
    [(tile.x + 0.5) * args.state.tile_size, (tile.y + 0.5) * args.state.tile_size]
  end.inject do | point_a,  point_b |
    # Render the line between each point
    args.outputs.lines << [point_a.x, point_a.y, point_b.x, point_b.y, a_star_color]
    point_b
  end
end

# Moves object to target at speed
def move object, target, speed = 1
  if target.is_a? Hash
    object[:x] += copy_sign(speed, target[:x] - object[:x])
    object[:y] += copy_sign(speed, target[:y] - object[:y])
  else
    object[:x] += copy_sign(speed, target.x - object[:x])
    object[:y] += copy_sign(speed, target.y - object[:y])
  end
end
#
#
def distance_between a_x, a_y, b_x, b_y
  (((b_x - a_x) ** 2) + ((b_y - a_y) ** 2)) ** 0.5
end

def copy_sign value, sign
  return 0 if sign == 0
  return value if sign > 0
  -value
end
#
def spawn_tank args
  return unless args.state.tick_count.mod_zero? args.state.tank_spawn_period
  args.state.tanks << {
    x: args.state.grid_start.x,
    y: args.state.grid_start.y,
    w: args.state.tile_size,
    h: args.state.tile_size,
    path: args.state.tank_sprite_path,
    a_star: args.state.a_star.path.clone
  }
end

def neighbors args, tile
  [[tile.x, tile.y - 1],
   [tile.x, tile.y + 1],
   [tile.x + 1, tile.y],
   [tile.x - 1, tile.y]].reject do | neighbor |
    args.state.a_star.came_from.has_key?(neighbor) or
      tile_out_of_bounds?(args, neighbor) or
      args.state.walls.has_key? neighbor
  end
end

def tile_out_of_bounds? args, tile
  tile.x < 0 or tile.y < 0 or tile.x >= args.state.grid_size or tile.y >= args.state.grid_size
end

def grid_color
  [133, 226, 144]
end

def start_color
  [226, 144, 133]
end

def goal_color
  [226, 133, 144]
end

def wall_color
  [133, 144, 226]
end

def a_star_color
  [0, 0, 255]
end
