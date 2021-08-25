
# Sprites represented as Hashes using the queue ~args.outputs.sprites~
# code up, but are the "slowest" to render.
# The reason for this is the access of the key in the Hash and also
# because the data args.outputs.sprites is cleared every tick.
def random_x args
  (args.grid.w.randomize :ratio) * -1
end

def random_y args
  (args.grid.h.randomize :ratio) * -1
end

def random_speed
  1 + (4.randomize :ratio)
end

def new_star args
  {
    x: (random_x args),
    y: (random_y args),
    w: 4, h: 4, path: 'sprites/tiny-star.png',
    s: random_speed
  }
end

def move_star args, star
  star.x += star[:s]
  star.y += star[:s]
  if star.x > args.grid.w || star.y > args.grid.h
    star.x = (random_x args)
    star.y = (random_y args)
    star[:s] = random_speed
  end
end

def tick args
  args.state.star_count ||= 0

  # sets console command when sample app initially opens
  if Kernel.global_tick_count == 0
    puts ""
    puts ""
    puts "========================================================="
    puts "* INFO: Sprites, Hashes"
    puts "* INFO: Please specify the number of sprites to render."
    args.gtk.console.set_command "reset_with count: 100"
  end

  # init
  if args.state.tick_count == 0
    args.state.stars = args.state.star_count.map { |i| new_star args }
  end

  # update
  args.state.stars.each { |s| move_star args, s }

  # render
  args.outputs.sprites << args.state.stars
  args.outputs.background_color = [0, 0, 0]
  args.outputs.primitives << args.gtk.current_framerate_primitives
end

# resets game, and assigns star count given by user
def reset_with count: count
  $gtk.reset
  $gtk.args.state.star_count = count
end
