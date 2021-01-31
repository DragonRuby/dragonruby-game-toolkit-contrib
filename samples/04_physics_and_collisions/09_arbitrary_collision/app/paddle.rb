class Paddle
  attr_accessor :enabled

  def initialize ()
    @x=WIDTH/2
    @y=100
    @width=100
    @height=20
    @speed=10

    @xyCollision  = LinearCollider.new({x: @x,y: @y+@height+5}, {x: @x+@width, y: @y+@height+5})
    @xyCollision2 = LinearCollider.new({x: @x,y: @y}, {x: @x+@width, y: @y}, :pos)
    @xyCollision3 = LinearCollider.new({x: @x,y: @y}, {x: @x, y: @y+@height+5})
    @xyCollision4 = LinearCollider.new({x: @x+@width,y: @y}, {x: @x+@width, y: @y+@height+5}, :pos)

    @enabled = true
  end

  def update args
    @xyCollision.resetPoints({x: @x,y: @y+@height+5}, {x: @x+@width, y: @y+@height+5})
    @xyCollision2.resetPoints({x: @x,y: @y}, {x: @x+@width, y: @y})
    @xyCollision3.resetPoints({x: @x,y: @y}, {x: @x, y: @y+@height+5})
    @xyCollision4.resetPoints({x: @x+@width,y: @y}, {x: @x+@width, y: @y+@height+5})

    @xyCollision.update  args
    @xyCollision2.update args
    @xyCollision3.update args
    @xyCollision4.update args

    args.inputs.keyboard.key_held.left  ||= false
    args.inputs.keyboard.key_held.right  ||= false

    if not (args.inputs.keyboard.key_held.left == args.inputs.keyboard.key_held.right)
      if args.inputs.keyboard.key_held.left && @enabled
        @x-=@speed
      elsif args.inputs.keyboard.key_held.right && @enabled
        @x+=@speed
      end
    end

    xmin =WIDTH/4
    xmax = 3*(WIDTH/4)
    @x = (@x+@width > xmax) ? xmax-@width : (@x<xmin) ? xmin : @x;
  end

  def render args
    args.outputs.solids << [@x,@y,@width,@height,255,0,0];
  end

  def rect
    [@x, @y, @width, @height]
  end
end
