class Square
  attr :x, :y, :w, :h

  def initialize grid
    @grid = grid
    @x = (rand @grid.w)
    @y = (rand @grid.h)
    @w    = 20
    @h    = 20
    @s    = 1 + (4.randomize :ratio)
    @path = 'sprites/square/blue.png'
  end

  def mark_collisions all
    # be sure to do an optimized compilation -O3

    # using FFI function

    if all[self]
      @path = 'sprites/square/red.png'
    else
      @path = 'sprites/square/blue.png'
    end
  end

  def draw_override ffi_draw
    ffi_draw.draw_sprite @x, @y, @w, @h, @path
  end
end

class Game
  attr_gtk

  def tick
    if Kernel.global_tick_count == 0
      puts ""
      puts ""
      puts "========================================================="
      puts "* INFO: Many to Many Collisions"
      puts "* INFO: Please specify the number of sprites to check collisions on."
      args.gtk.console.set_command "reset_with count: 100"
    end

    if args.state.tick_count == 0
      args.state.stars = args.state.star_count.map { |i| Square.new args.grid }
      args.outputs.static_sprites << args.state.stars
    end

    state.all_collisions = GTK::Geometry.find_collisions args.state.stars
    Fn.each_send args.state.stars, self, :mark_collision

    args.outputs.background_color = [0, 0, 0]
    args.outputs.primitives << args.gtk.current_framerate_primitives
  end

  def mark_collision star
    star.mark_collisions state.all_collisions
  end

  def reset_with count: count
    $gtk.reset
    $gtk.args.state.star_count = count
  end
end

def tick args
  $game ||= Game.new
  $game.args = args and $game.tick
end

def reset_with count: count
  $game.reset_with count: count
end
