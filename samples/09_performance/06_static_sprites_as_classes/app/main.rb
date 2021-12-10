# Sprites represented as Classes using the queue ~args.outputs.static_sprites~.
# bypasses the queue behavior of ~args.outputs.sprites~. All instances are held
# by reference. You get better performance, but you are mutating state of held objects
# which is less functional/data oriented.
class Star
  attr_sprite

  def initialize grid
    @grid = grid
    @x = (rand @grid.w) * -1
    @y = (rand @grid.h) * -1
    @w    = 4
    @h    = 4
    @s    = 1 + (4.randomize :ratio)
    @path = 'sprites/tiny-star.png'
  end

  def move
    @x += @s
    @y += @s
    @x = (rand @grid.w) * -1 if @x > @grid.right
    @y = (rand @grid.h) * -1 if @y > @grid.top
  end
end

# calls methods needed for game to run properly
def tick args
  # sets console command when sample app initially opens
  if Kernel.global_tick_count == 0
    puts ""
    puts ""
    puts "========================================================="
    puts "* INFO: Static Sprites, Classes"
    puts "* INFO: Please specify the number of sprites to render."
    args.gtk.console.set_command "reset_with count: 100"
  end

  # init
  if args.state.tick_count == 0
    args.state.stars = args.state.star_count.map { |i| Star.new args.grid }
    args.outputs.static_sprites << args.state.stars
  end

  # update
  args.state.stars.each(&:move)

  # render
  args.outputs.background_color = [0, 0, 0]
  args.outputs.primitives << args.gtk.current_framerate_primitives
end

# resets game, and assigns star count given by user
def reset_with count: count
  $gtk.reset
  $gtk.args.state.star_count = count
end
