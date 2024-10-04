class Square
  attr_sprite

  def initialize x, y
    @x    = x
    @y    = y
    @w    = 8
    @h    = 8
    @path = 'sprites/square/blue.png'
    @dir = if x < 640
             -1.0
           else
             1.0
           end
  end

  def reset_collision
    @path = "sprites/square/blue.png"
  end

  def mark_collision
    @path = 'sprites/square/red.png'
  end

  def move
    @dir  = -1.0 if (@x + @w >= 1280) && @dir ==  1.0
    @dir  =  1.0 if (@x      <=    0) && @dir == -1.0
    @x   += @dir
  end
end

def generate_random_squares args, center_x, center_y
  100.times do
    angle = rand 360
    distance = rand(200) + 20
    x = center_x + angle.vector_x * distance
    y = center_y + angle.vector_y * distance
    if x > 0 && x < 1280 && y < 720 && y > 0
      args.state.squares << Square.new(x, y)
    end
  end

  args.outputs.static_sprites.clear
  args.outputs.static_sprites << args.state.squares
  args.state.square_count = args.state.squares.length
end

def tick args
  args.state.squares ||= []

  if Kernel.tick_count == 0
    generate_random_squares args, 640, 360
  end

  if args.inputs.mouse.click
    generate_random_squares args, args.inputs.mouse.x, args.inputs.mouse.y
  end

  Array.each(args.state.squares) do |s|
    s.reset_collision
    s.move
  end

  Geometry.each_intersect_rect(args.state.squares, args.state.squares) do |a, b|
    a.mark_collision
    b.mark_collision
  end

  args.outputs.background_color = [0, 0, 0]
  args.outputs.watch "FPS: #{GTK.current_framerate.to_sf}"
  args.outputs.watch "Square Count: #{args.state.square_count.to_i}"
  args.outputs.watch "Instructions: click to add squares."
end
