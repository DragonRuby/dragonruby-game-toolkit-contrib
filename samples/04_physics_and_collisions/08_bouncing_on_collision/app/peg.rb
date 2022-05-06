class Peg
  def initialize(x, y, block_size)
    @x = x                    # x cordinate of the LEFT side of the peg
    @y = y                    # y cordinate of the RIGHT side of the peg
    @block_size = block_size  # diameter of the peg

    @radius = @block_size/2.0 # radius of the peg
    @center = {               # cordinatees of the CENTER of the peg
      x: @x+@block_size/2.0,
      y: @y+@block_size/2.0
    }

    @r = 255 # color of the peg
    @g = 0
    @b = 0

    @velocity = {x: 2, y: 0}
  end

  def draw args
    args.outputs.sprites << [ # draw the peg according to the @x, @y, @radius, and the RGB
      @x,
      @y,
      @radius*2.0,
      @radius*2.0,
      "sprites/circle-white.png",
      0,
      255,
      @r,    #r
      @g,    #g
      @b   #b
    ]
  end


  def calc args
    if collisionWithBounce? args # if the is a collision with the bouncing ball
      collide args
      @r = 0
      @b = 0
      @g = 255
    else
    end
  end


  # do two circles (the ball and this peg) intersect
  def collisionWithBounce? args
    squareDistance = (  # the squared distance between the ball's center and this peg's center
      (args.state.ball.center.x - @center.x) ** 2.0 +
      (args.state.ball.center.y - @center.y) ** 2.0
    )
    radiusSum = (  # the sum of the radius squared of the this peg and the ball
      (args.state.ball.radius + @radius) ** 2.0
    )
    # if the squareDistance is less or equal to radiusSum, then there is a radial intersection between the ball and this peg
    return (squareDistance <= radiusSum)
  end

  # ! The following links explain the getRepelMagnitude function !
  # https://raw.githubusercontent.com/DragonRuby/dragonruby-game-toolkit-physics/master/docs/docImages/LinearCollider_4.png
  # https://raw.githubusercontent.com/DragonRuby/dragonruby-game-toolkit-physics/master/docs/docImages/LinearCollider_5.png
  # https://github.com/DragonRuby/dragonruby-game-toolkit-physics/blob/master/docs/LinearCollider.md
  def getRepelMagnitude (args, fbx, fby, vrx, vry, ballMag)
    a = fbx ; b = vrx ; c = fby
    d = vry ; e = ballMag
    if b**2 + d**2 == 0
      #unexpected
    end

    x1 = (-a*b+-c*d + (e**2 * b**2 - b**2 * c**2 + 2*a*b*c*d + e**2 + d**2 - a**2 * d**2)**0.5)/(b**2 + d**2)
    x2 = -((a*b + c*d + (e**2 * b**2 - b**2 * c**2 + 2*a*b*c*d + e**2 * d**2 - a**2 * d**2)**0.5)/(b**2 + d**2))

    err = 0.00001
    o = ((fbx + x1*vrx)**2 + (fby + x1*vry)**2 ) ** 0.5
    p = ((fbx + x2*vrx)**2 + (fby + x2*vry)**2 ) ** 0.5
    r = 0

    if (ballMag >= o-err and ballMag <= o+err)
      r = x1
    elsif (ballMag >= p-err and ballMag <= p+err)
      r = x2
    else
      #unexpected
    end

    if (args.state.ball.center.x > @center.x)
      return x2*-1
    end

    return x2

    #return r
  end

  #this sets the new velocity of the ball once it has collided with this peg
  def collide args
    normalOfRCCollision = [                                                     #this is the normal of the collision in COMPONENT FORM
      {x: @center.x, y: @center.y},                                             #see https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.mathscard.co.uk%2Fonline%2Fcircle-coordinate-geometry%2F&psig=AOvVaw2GcD-e2-nJR_IUKpw3hO98&ust=1605731315521000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCMjBo7e1iu0CFQAAAAAdAAAAABAD
      {x: args.state.ball.center.x, y: args.state.ball.center.y},
    ]

    normalSlope = (                                                             #normalSlope is the slope of normalOfRCCollision
      (normalOfRCCollision[1].y - normalOfRCCollision[0].y) /
      (normalOfRCCollision[1].x - normalOfRCCollision[0].x)
    )
    slope = normalSlope**-1.0 * -1                                              # slope is the slope of the tangent
    # args.state.display_value = slope
    pointA = {                                                                  # pointA and pointB are using the var slope to tangent in COMPONENT FORM
      x: args.state.ball.center.x-1,
      y: -(slope-args.state.ball.center.y)
    }
    pointB = {
      x: args.state.ball.center.x+1,
      y: slope+args.state.ball.center.y
    }

    perpVect = {x: pointB.x - pointA.x, y:pointB.y - pointA.y}                  # perpVect is to be VECTOR of the perpendicular tangent
    mag  = (perpVect.x**2 + perpVect.y**2)**0.5                                 # find the magniude of the perpVect
    perpVect = {x: perpVect.x/(mag), y: perpVect.y/(mag)}                       # divide the perpVect by the magniude to make it a unit vector
    perpVect = {x: -perpVect.y, y: perpVect.x}                                  # swap the x and y and multiply by -1 to make the vector perpendicular
    args.state.display_value = perpVect
    if perpVect.y > 0                                                           #ensure perpVect points upward
      perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
    end

    previousPosition = {                                                        # calculate an ESTIMATE of the previousPosition of the ball
      x:args.state.ball.center.x-args.state.ball.velocity.x,
      y:args.state.ball.center.y-args.state.ball.velocity.y
    }

    yInterc = pointA.y + -slope*pointA.x
    if slope == INFINITY                                                        # the perpVect presently either points in the correct dirrection or it is 180 degrees off we need to correct this
      if previousPosition.x < pointA.x
        perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
        yInterc = -INFINITY
      end
    elsif previousPosition.y < slope*previousPosition.x + yInterc               # check if ball is bellow or above the collider to determine if perpVect is - or +
      perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
    end

    velocityMag =                                                               # the current velocity magnitude of the ball
      (args.state.ball.velocity.x**2 + args.state.ball.velocity.y**2)**0.5
    theta_ball=
      Math.atan2(args.state.ball.velocity.y,args.state.ball.velocity.x)         #the angle of the ball's velocity
    theta_repel=
      Math.atan2(args.state.ball.center.y,args.state.ball.center.x)             #the angle of the repelling force(perpVect)

    fbx = velocityMag * Math.cos(theta_ball)                                    #the x component of the ball's velocity
    fby = velocityMag * Math.sin(theta_ball)                                    #the y component of the ball's velocity
    repelMag = getRepelMagnitude(                                               # the magniude of the collision vector
      args,
      fbx,
      fby,
      perpVect.x,
      perpVect.y,
      (args.state.ball.velocity.x**2 + args.state.ball.velocity.y**2)**0.5
    )
    frx = repelMag* Math.cos(theta_repel)                                       #the x component of the repel's velocity | magnitude is set to twice of fbx
    fry = repelMag* Math.sin(theta_repel)                                       #the y component of the repel's velocity | magnitude is set to twice of fby

    fsumx = fbx+frx                            # sum of x forces
    fsumy = fby+fry                            # sum of y forces
    fr = velocityMag                           # fr is the resulting magnitude
    thetaNew = Math.atan2(fsumy, fsumx)        # thetaNew is the resulting angle
    xnew = fr*Math.cos(thetaNew)               # resulting x velocity
    ynew = fr*Math.sin(thetaNew)               # resulting y velocity
    if (args.state.ball.center.x >= @center.x) # this is necessary for the ball colliding on the right side of the peg
      xnew=xnew.abs
    end

    args.state.ball.velocity.x = xnew                                           # set the x-velocity to the new velocity
    if args.state.ball.center.y > @center.y                                     # if the ball is above the middle of the peg we need to temporarily ignore some of the gravity
      args.state.ball.velocity.y = ynew + GRAVITY * 0.01
    else
      args.state.ball.velocity.y = ynew - GRAVITY * 0.01                        # if the ball is bellow the middle of the peg we need to temporarily increase the power of the gravity
    end

    args.state.ball.center.x+= args.state.ball.velocity.x                       # update the position of the ball so it never looks like the ball is intersecting the circle
    args.state.ball.center.y+= args.state.ball.velocity.y
  end
end
