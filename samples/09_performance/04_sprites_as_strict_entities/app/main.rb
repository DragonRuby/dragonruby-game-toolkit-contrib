# Sprites represented as StrictEntities using the queue ~args.outputs.sprites~
# yields apis access similar to Entities, but all properties that can be set on the
# entity must be predefined with a default value. Strict entities do not support the
# addition of new properties after the fact. They are more performant than OpenEntities
# because of this constraint.
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
  args.state.new_entity_strict(:star,
                               x: (random_x args),
                               y: (random_y args),
                               w: 4, h: 4,
                               path: 'sprites/tiny-star.png',
                               s: random_speed) do |entity|
    # invoke attr_sprite so that it responds to
    # all properties that are required to render a sprite
    entity.attr_sprite
  end
end

def move_star args, star
  star.x += star.s
  star.y += star.s
  if star.x > args.grid.w || star.y > args.grid.h
    star.x = (random_x args)
    star.y = (random_y args)
    star.s = random_speed
  end
end

def tick args
  args.state.star_count ||= 0

  # sets console command when sample app initially opens
  if Kernel.global_tick_count == 0
    puts ""
    puts ""
    puts "========================================================="
    puts "* INFO: Sprites, Strict Entities"
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
