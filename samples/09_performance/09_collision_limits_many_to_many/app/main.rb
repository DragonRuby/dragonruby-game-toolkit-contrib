class Square
  attr :x, :y, :w, :h

  def initialize grid
    @grid = grid
    @x = (rand @grid.w)
    @y = (rand @grid.h)
    @w    = 20
    @h    = 20
    @path = 'sprites/square/blue.png'
  end

  def mark_collisions all
    @path = if all[self]
              'sprites/square/red.png'
            else
              'sprites/square/blue.png'
            end
  end

  def draw_override ffi_draw
    ffi_draw.draw_sprite @x, @y, @w, @h, @path
  end
end

def tick args
  if args.state.tick_count == 0
    args.state.star_count = 1000
    args.state.stars = args.state.star_count.map { |i| Square.new args.grid }.to_a
    args.outputs.static_sprites << args.state.stars
  end

  all = GTK::Geometry.find_collisions args.state.stars
  Fn.each args.state.stars do |s| s.mark_collisions all end

  args.outputs.background_color = [0, 0, 0]
  args.outputs.primitives << args.gtk.current_framerate_primitives
end
