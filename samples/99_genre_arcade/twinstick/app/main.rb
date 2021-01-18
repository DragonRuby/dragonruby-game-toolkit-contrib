def tick args
  args.state.player         ||= {x: 600, y: 320, w: 80, h: 80, path: 'sprites/circle-white.png', vx: 0, vy: 0, health: 10, cooldown: 0, score: 0}
  args.state.enemies        ||= []
  args.state.player_bullets ||= []
  args.state.tick_count     ||= -1
  args.state.tick_count     += 1
  spawn_enemies args
  kill_enemies args
  move_enemies args
  move_bullets args
  move_player args
  fire_player args
  args.state.player[:r] = args.state.player[:g] = args.state.player[:b] = (args.state.player[:health] * 25.5).clamp(0, 255)
  label_color           = args.state.player[:health] <= 5 ? 255 : 0
  args.outputs.labels << [
      {
          x: args.state.player.x + 40, y: args.state.player.y + 60, alignment_enum: 1, text: "#{args.state.player[:health]} HP",
          r: label_color, g: label_color, b: label_color
      }, {
          x: args.state.player.x + 40, y: args.state.player.y + 40, alignment_enum: 1, text: "#{args.state.player[:score]} PTS",
          r: label_color, g: label_color, b: label_color, size_enum: 2 - args.state.player[:score].to_s.length,
      }
  ]
  args.outputs.sprites << [args.state.player, args.state.enemies, args.state.player_bullets]
  args.state.clear! if args.state.player[:health] < 0 # Reset the game if the player's health drops below zero
end

def spawn_enemies args
  # Spawn enemies more frequently as the player's score increases.
  if rand < (100+args.state.player[:score])/(10000 + args.state.player[:score]) || args.state.tick_count.zero?
    theta = rand * Math::PI * 2
    args.state.enemies << {
        x: 600 + Math.cos(theta) * 800, y: 320 + Math.sin(theta) * 800, w: 80, h: 80, path: 'sprites/circle-white.png',
        r: (256 * rand).floor, g: (256 * rand).floor, b: (256 * rand).floor
    }
  end
end

def kill_enemies args
  args.state.enemies.reject! do |enemy|
    # Check if enemy and player are within 80 pixels of each other (i.e. overlapping)
    if 6400 > (enemy.x - args.state.player.x) ** 2 + (enemy.y - args.state.player.y) ** 2
      # Enemy is touching player. Kill enemy, and reduce player HP by 1.
      args.state.player[:health] -= 1
    else
      args.state.player_bullets.any? do |bullet|
        # Check if enemy and bullet are within 50 pixels of each other (i.e. overlapping)
        if 2500 > (enemy.x - bullet.x + 30) ** 2 + (enemy.y - bullet.y + 30) ** 2
          # Increase player health by one for each enemy killed by a bullet after the first enemy, up to a maximum of 10 HP
          args.state.player[:health] += 1 if args.state.player[:health] < 10 && bullet[:kills] > 0
          # Keep track of how many enemies have been killed by this particular bullet
          bullet[:kills]             += 1
          # Earn more points by killing multiple enemies with one shot.
          args.state.player[:score]  += bullet[:kills]
        end
      end
    end
  end
end

def move_enemies args
  args.state.enemies.each do |enemy|
    # Get the angle from the enemy to the player
    theta   = Math.atan2(enemy.y - args.state.player.y, enemy.x - args.state.player.x)
    # Convert the angle to a vector pointing at the player
    dx, dy  = theta.to_degrees.vector 5
    # Move the enemy towards thr player
    enemy.x -= dx
    enemy.y -= dy
  end
end

def move_bullets args
  args.state.player_bullets.each do |bullet|
    # Move the bullets according to the bullet's velocity
    bullet.x += bullet[:vx]
    bullet.y += bullet[:vy]
  end
  args.state.player_bullets.reject! do |bullet|
    # Despawn bullets that are outside the screen area
    bullet.x < -20 || bullet.y < -20 || bullet.x > 1300 || bullet.y > 740
  end
end

def move_player args
  # Get the currently held direction.
  dx, dy                 = move_directional_vector args
  # Take the weighted average of the old velocities and the desired velocities. 
  # Since move_directional_vector returns values between -1 and 1, 
  #   and we want to limit the speed to 7.5, we multiply dx and dy by 7.5*0.1 to get 0.75
  args.state.player[:vx] = args.state.player[:vx] * 0.9 + dx * 0.75
  args.state.player[:vy] = args.state.player[:vy] * 0.9 + dy * 0.75
  # Move the player
  args.state.player.x    += args.state.player[:vx]
  args.state.player.y    += args.state.player[:vy]
  # If the player is about to go out of bounds, put them back in bounds.
  args.state.player.x    = args.state.player.x.clamp(0, 1201)
  args.state.player.y    = args.state.player.y.clamp(0, 640)
end


def fire_player args
  # Reduce the firing cooldown each tick
  args.state.player[:cooldown] -= 1
  # If the player is allowed to fire
  if args.state.player[:cooldown] <= 0
    dx, dy = shoot_directional_vector args # Get the bullet velocity
    return if dx == 0 && dy == 0 # If the velocity is zero, the player doesn't want to fire. Therefore, we just return early.
    # Add a new bullet to the list of player bullets.
    args.state.player_bullets << {
        x:     args.state.player.x + 30 + 40 * dx,
        y:     args.state.player.y + 30 + 40 * dy,
        w:     20, h: 20,
        path:  'sprites/circle-white.png',
        r:     0, g: 0, b: 0,
        vx:    10 * dx + args.state.player[:vx] / 7.5, vy: 10 * dy + args.state.player[:vy] / 7.5, # Factor in a bit of the player's velocity
        kills: 0
    }
    args.state.player[:cooldown] = 30 # Reset the cooldown
  end
end

# Custom function for getting a directional vector just for movement using WASD
def move_directional_vector args
  dx = 0
  dx += 1 if args.inputs.keyboard.d
  dx -= 1 if args.inputs.keyboard.a
  dy = 0
  dy += 1 if args.inputs.keyboard.w
  dy -= 1 if args.inputs.keyboard.s
  if dx != 0 && dy != 0
    dx *= 0.7071
    dy *= 0.7071
  end
  [dx, dy]
end

# Custom function for getting a directional vector just for shooting using the arrow keys
def shoot_directional_vector args
  dx = 0
  dx += 1 if args.inputs.keyboard.key_down.right || args.inputs.keyboard.key_held.right
  dx -= 1 if args.inputs.keyboard.key_down.left || args.inputs.keyboard.key_held.left
  dy = 0
  dy += 1 if args.inputs.keyboard.key_down.up || args.inputs.keyboard.key_held.up
  dy -= 1 if args.inputs.keyboard.key_down.down || args.inputs.keyboard.key_held.down
  if dx != 0 && dy != 0
    dx *= 0.7071
    dy *= 0.7071
  end
  [dx, dy]
end