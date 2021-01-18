
class SquareCollider
  def initialize x,y,direction,size=COLLISIONWIDTH
    @x = x
    @y = y
    @size = size
    @direction = direction

  end
  def collision? args, ball
    #args.outputs.solids <<  [@x, @y, @size, @size,     000, 255, 255]


    return [@x,@y,@size,@size].intersect_rect?([ball.x,ball.y,ball.width,ball.height])
  end

  def collide args, ball
    vmag = (ball.velocity.x**2.0 +ball.velocity.y**2.0)**0.5
    a = ((2.0**0.5)*vmag)/2.0
    if vmag < MAX_VELOCITY
      ball.velocity.x = (a) * @direction.x * 1.1
      ball.velocity.y = (a) * @direction.y * 1.1
    else
      ball.velocity.x = (a) * @direction.x
      ball.velocity.y = (a) * @direction.y
    end

  end
end
