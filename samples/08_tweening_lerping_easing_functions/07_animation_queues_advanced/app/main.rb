# sample app shows how to perform a fire and forget animation when a collision occurs
def tick args
  defaults args
  spawn_bullets args
  calc_bullets args
  render args
end

def defaults args
  # place a player on the far left with sprite and hp information
  args.state.player ||= { x: 100, y: 360 - 50, w: 100, h: 100, path: "sprites/square/blue.png", hp: 30 }
  # create an array of bullets
  args.state.bullets ||= []
  # create a queue for handling bullet explosions
  args.state.explosion_queue ||= []
end

def spawn_bullets args
  # span a bullet in a random location on the far right every half second
  return if !args.state.tick_count.zmod? 30
  args.state.bullets << {
    x: 1280 - 100,
    y: rand(720 - 100),
    w: 100,
    h: 100,
    path: "sprites/square/red.png"
  }
end

def calc_bullets args
  # for each bullet
  args.state.bullets.each do |b|
    # move it to the left by 20 pixels
    b.x -= 20

    # determine if the bullet collides with the player
    if b.intersect_rect? args.state.player
      # decrement the player's health if it does
      args.state.player.hp -= 1
      # mark the bullet as exploded
      b.exploded = true

      # queue the explosion by adding it to the explosion queue
      args.state.explosion_queue << b.merge(exploded_at: args.state.tick_count)
    end
  end

  # remove bullets that have exploded so they wont be rendered
  args.state.bullets.reject! { |b| b.exploded }

  # remove animations from the animation queue that have completed
  # frame index will return nil once the animation has completed
  args.state.explosion_queue.reject! { |e| !e.exploded_at.frame_index(7, 4, false) }
end

def render args
  # render the player's hp above the sprite
  args.outputs.labels << {
    x: args.state.player.x + 50,
    y: args.state.player.y + 110,
    text: "#{args.state.player.hp}",
    alignment_enum: 1,
    vertical_alignment_enum: 0
  }

  # render the player
  args.outputs.sprites << args.state.player

  # render the bullets
  args.outputs.sprites << args.state.bullets

  # process the animation queue
  args.outputs.sprites << args.state.explosion_queue.map do |e|
    number_of_frames = 7
    hold_each_frame_for = 4
    repeat_animation = false
    # use the exploded_at property and the frame_index function to determine when the animation should start
    frame_index = e.exploded_at.frame_index(number_of_frames, hold_each_frame_for, repeat_animation)
    # take the explosion primitive and set the path variariable
    e.merge path: "sprites/misc/explosion-#{frame_index}.png"
  end
end
