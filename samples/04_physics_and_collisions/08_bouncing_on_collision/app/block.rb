DEGREES_TO_RADIANS = Math::PI / 180

class Block
  def initialize(x, y, block_size, rotation)
    @x = x
    @y = y
    @block_size = block_size
    @rotation = rotation

    #The repel velocity?
    @velocity = {x: 2, y: 0}

    horizontal_offset = (3 * block_size) * Math.cos(rotation * DEGREES_TO_RADIANS)
    vertical_offset = block_size * Math.sin(rotation * DEGREES_TO_RADIANS)

    if rotation >= 0
      theta = 90 - rotation
      #The line doesn't visually line up exactly with the edge of the sprite, so artificially move it a bit
      modifier = 5
      x_offset = modifier * Math.cos(theta * DEGREES_TO_RADIANS)
      y_offset = modifier * Math.sin(theta * DEGREES_TO_RADIANS)
      @x1 = @x - x_offset
      @y1 = @y + y_offset
      @x2 = @x1 + horizontal_offset
      @y2 = @y1 + (vertical_offset * 3)

      @imaginary_line = [ @x1, @y1, @x2, @y2 ]
    else
      theta = 90 + rotation
      x_offset = @block_size * Math.cos(theta * DEGREES_TO_RADIANS)
      y_offset = @block_size * Math.sin(theta * DEGREES_TO_RADIANS)
      @x1 = @x + x_offset
      @y1 = @y + y_offset + 19
      @x2 = @x1 + horizontal_offset
      @y2 = @y1 + (vertical_offset * 3)

      @imaginary_line = [ @x1, @y1, @x2, @y2 ]
    end

  end

  def draw args
    args.outputs.sprites << [
      @x,
      @y,
      @block_size*3,
      @block_size,
      "sprites/square-green.png",
      @rotation
    ]

    args.outputs.lines << @imaginary_line
    args.outputs.solids << @debug_shape
  end

  def multiply_matricies
  end

  def calc args
    if collision? args
        collide args
    end
  end

  #Determine if the ball and block are touching
  def collision? args
    #The minimum area enclosed by the center of the ball and the 2 corners of the block
    #If the area ever drops below this value, we know there is a collision
    min_area = ((@block_size * 3) * args.state.ball.radius) / 2

    #https://www.mathopenref.com/coordtrianglearea.html
    ax = @x1
    ay = @y1
    bx = @x2
    by = @y2
    cx = args.state.ball.center.x
    cy = args.state.ball.center.y

    current_area = (ax*(by-cy)+bx*(cy-ay)+cx*(ay-by))/2

    collision = false
    if @rotation >= 0
      if (current_area < min_area &&
        current_area > 0 &&
        args.state.ball.center.y > @y1 &&
        args.state.ball.center.x < @x2)

        collision = true
      end
    else
      if (current_area < min_area &&
        current_area > 0 &&
        args.state.ball.center.y > @y2 &&
        args.state.ball.center.x > @x1)

      collision = true
      end
    end

    return collision
  end

  def collide args
    #Slope of the block
    slope = (@y2 - @y1) / (@x2 - @x1)

    #Create a unit vector and tilt it (@rotation) number of degrees
    x = -Math.cos(@rotation * DEGREES_TO_RADIANS)
    y = Math.sin(@rotation * DEGREES_TO_RADIANS)

    #Find the vector that is perpendicular to the slope
    perpVect = { x: x, y: y }
    mag  = (perpVect.x**2 + perpVect.y**2)**0.5                                 # find the magniude of the perpVect
    perpVect = {x: perpVect.x/(mag), y: perpVect.y/(mag)}                       # divide the perpVect by the magniude to make it a unit vector

    previousPosition = {                                                        # calculate an ESTIMATE of the previousPosition of the ball
      x:args.state.ball.center.x-args.state.ball.velocity.x,
      y:args.state.ball.center.y-args.state.ball.velocity.y
    }

    velocityMag = (args.state.ball.velocity.x**2 + args.state.ball.velocity.y**2)**0.5 # the current velocity magnitude of the ball
    theta_ball = Math.atan2(args.state.ball.velocity.y, args.state.ball.velocity.x)         #the angle of the ball's velocity
    theta_repel = (180 * DEGREES_TO_RADIANS) - theta_ball + (@rotation * DEGREES_TO_RADIANS)

    fbx = velocityMag * Math.cos(theta_ball)                                    #the x component of the ball's velocity
    fby = velocityMag * Math.sin(theta_ball)                                    #the y component of the ball's velocity

    frx = velocityMag * Math.cos(theta_repel)                                       #the x component of the repel's velocity | magnitude is set to twice of fbx
    fry = velocityMag * Math.sin(theta_repel)                                       #the y component of the repel's velocity | magnitude is set to twice of fby

    args.state.display_value = velocityMag
    fsumx = fbx+frx                                                             #sum of x forces
    fsumy = fby+fry                                                             #sum of y forces
    fr = velocityMag                                                            #fr is the resulting magnitude
    thetaNew = Math.atan2(fsumy, fsumx)                                         #thetaNew is the resulting angle

    xnew = fr*Math.cos(thetaNew)                                                #resulting x velocity
    ynew = fr*Math.sin(thetaNew)                                                #resulting y velocity

    dampener = 0.3
    ynew *= dampener * 0.5

    #If the bounce is very low, that means the ball is rolling and we don't want to dampenen the X velocity
    if ynew > -0.1
      xnew *= dampener
    end

    #Add the sine component of gravity back in (X component)
    gravity_x = 4 * Math.sin(@rotation * DEGREES_TO_RADIANS)
    xnew += gravity_x

    args.state.ball.velocity.x = -xnew
    args.state.ball.velocity.y = -ynew

    #Set the position of the ball to the previous position so it doesn't warp throught the block
    args.state.ball.center.x = previousPosition.x
    args.state.ball.center.y = previousPosition.y
  end
end
