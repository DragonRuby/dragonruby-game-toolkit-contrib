class Square
  attr_sprite

  def initialize
    @x    = rand 1280
    @y    = rand 720
    @w    = 15
    @h    = 15
    @path = 'sprites/square/blue.png'
    @dir = 1
  end

  def mark_collisions all
    @path = if all[self]
              'sprites/square/red.png'
            else
              'sprites/square/blue.png'
            end
  end

  def move
    @dir  = -1 if (@x + @w >= 1280) && @dir ==  1
    @dir  =  1 if (@x      <=    0) && @dir == -1
    @x   += @dir
  end
end

def reset_if_needed args
  if args.state.tick_count == 0 || args.inputs.mouse.click
    args.state.star_count = 1500
    args.state.stars = args.state.star_count.map { |i| Square.new }.to_a
    args.outputs.static_sprites.clear
    args.outputs.static_sprites << args.state.stars
  end
end

def tick args
  reset_if_needed args

  Fn.each args.state.stars do |s| s.move end

  all = GTK::Geometry.find_collisions args.state.stars
  Fn.each args.state.stars do |s| s.mark_collisions all end

  args.outputs.background_color = [0, 0, 0]
  args.outputs.primitives << args.gtk.current_framerate_primitives
end
