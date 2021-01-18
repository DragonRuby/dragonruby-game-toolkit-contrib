class Ball
  #TODO limit accessors?
  attr_accessor :xy, :width, :height, :velocity


  #@xy [Vector2d] x,y position
  #@velocity [Vector2d] velocity of ball
  def initialize
    @xy = Vector2d.new(WIDTH/2,500)
    @velocity = Vector2d.new(4,-4)
    @width =  20
    @height = 20
  end

  #move the ball according to its velocity
  def update args
    @xy.x+=@velocity.x
    @xy.y+=@velocity.y
  end

  #render the ball to the screen
  def render args
    args.outputs.solids << [@xy.x,@xy.y,@width,@height,255,0,255];
    #args.outputs.labels << [20,HEIGHT-50,"velocity: " +@velocity.x.to_s+","+@velocity.y.to_s + "   magnitude:" + @velocity.mag.to_s]
  end

  def rect
    [@xy.x,@xy.y,@width,@height]
  end

end
