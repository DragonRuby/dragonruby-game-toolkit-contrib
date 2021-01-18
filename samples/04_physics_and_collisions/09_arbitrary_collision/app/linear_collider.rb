
COLLISIONWIDTH=8

class LinearCollider
  attr_reader :pointA, :pointB
  def initialize (pointA, pointB, mode,collisionWidth=COLLISIONWIDTH)
    @pointA = pointA
    @pointB = pointB
    @mode = mode
    @collisionWidth = collisionWidth

    if (@pointA.x > @pointB.x)
      @pointA, @pointB = @pointB, @pointA
    end

    @linearCollider_collision_once = false
  end

  def collisionSlope args
    if (@pointB.x-@pointA.x == 0)
      return INFINITY
    end
    return (@pointB.y - @pointA.y) / (@pointB.x - @pointA.x)
  end


  def collision? (args, points, ball=nil)

    slope = collisionSlope args
    result = false

    # calculate a vector with a magnitude of (1/2)collisionWidth and a direction perpendicular to the collision line
    vect=nil;mag=nil;vect=nil;
    if @mode == :both
      vect = {x: @pointB.x - @pointA.x, y:@pointB.y - @pointA.y}
      mag  = (vect.x**2 + vect.y**2)**0.5
      vect = {y: -1*(vect.x/(mag))*@collisionWidth*0.5, x: (vect.y/(mag))*@collisionWidth*0.5}
    else
      vect = {x: @pointB.x - @pointA.x, y:@pointB.y - @pointA.y}
      mag  = (vect.x**2 + vect.y**2)**0.5
      vect = {y: -1*(vect.x/(mag))*@collisionWidth, x: (vect.y/(mag))*@collisionWidth}
    end

    rpointA=nil;rpointB=nil;rpointC=nil;rpointD=nil;
    if @mode == :pos
      rpointA = {x:@pointA.x + vect.x, y:@pointA.y + vect.y}
      rpointB = {x:@pointB.x + vect.x, y:@pointB.y + vect.y}
      rpointC = {x:@pointB.x, y:@pointB.y}
      rpointD = {x:@pointA.x, y:@pointA.y}
    elsif @mode == :neg
      rpointA = {x:@pointA.x, y:@pointA.y}
      rpointB = {x:@pointB.x, y:@pointB.y}
      rpointC = {x:@pointB.x - vect.x, y:@pointB.y - vect.y}
      rpointD = {x:@pointA.x - vect.x, y:@pointA.y - vect.y}
    elsif @mode == :both
      rpointA = {x:@pointA.x + vect.x, y:@pointA.y + vect.y}
      rpointB = {x:@pointB.x + vect.x, y:@pointB.y + vect.y}
      rpointC = {x:@pointB.x - vect.x, y:@pointB.y - vect.y}
      rpointD = {x:@pointA.x - vect.x, y:@pointA.y - vect.y}
    end
    #four point rectangle



    if ball != nil
      xs = [rpointA.x,rpointB.x,rpointC.x,rpointD.x]
      ys = [rpointA.y,rpointB.y,rpointC.y,rpointD.y]
      correct = 1
      rect1 = [ball.x, ball.y, ball.width, ball.height]
      #$r1 = rect1
      rect2 = [xs.min-correct,ys.min-correct,(xs.max-xs.min)+correct*2,(ys.max-ys.min)+correct*2]
      #$r2 = rect2
      if rect1.intersect_rect?(rect2) == false
        return false
      end
    end


    #area of a triangle
    triArea = -> (a,b,c) { ((a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y))/2.0).abs }

    #if at least on point is in the rectangle then collision? is true - otherwise false
    for point in points
      #Check whether a given point lies inside a rectangle or not:
      #if the sum of the area of traingls, PAB, PBC, PCD, PAD equal the area of the rec, then an intersection has occured
      areaRec =  triArea.call(rpointA, rpointB, rpointC)+triArea.call(rpointA, rpointC, rpointD)
      areaSum = [
        triArea.call(point, rpointA, rpointB),triArea.call(point, rpointB, rpointC),
        triArea.call(point, rpointC, rpointD),triArea.call(point, rpointA, rpointD)
      ].inject(0){|sum,x| sum + x }
      e = 0.0001 #allow for minor error
      if areaRec>= areaSum-e and areaRec<= areaSum+e
        result = true
        #return true
        break
      end
    end

    #args.outputs.lines << [@pointA.x, @pointA.y, @pointB.x, @pointB.y,     000, 000, 000]
    #args.outputs.lines << [rpointA.x, rpointA.y, rpointB.x, rpointB.y,     255, 000, 000]
    #args.outputs.lines << [rpointC.x, rpointC.y, rpointD.x, rpointD.y,     000, 000, 255]


    #puts (rpointA.x.to_s + " " +  rpointA.y.to_s + " " + rpointB.x.to_s + " "+ rpointB.y.to_s)
    return result
  end #end collision?

  def getRepelMagnitude (fbx, fby, vrx, vry, ballMag)
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
    return r
  end

  def collide args, ball
    slope = collisionSlope args

    # perpVect: normal vector perpendicular to collision
    perpVect = {x: @pointB.x - @pointA.x, y:@pointB.y - @pointA.y}
    mag  = (perpVect.x**2 + perpVect.y**2)**0.5
    perpVect = {x: perpVect.x/(mag), y: perpVect.y/(mag)}
    perpVect = {x: -perpVect.y, y: perpVect.x}
    if perpVect.y > 0 #ensure perpVect points upward
      perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
    end
    previousPosition = {
      x:ball.x-ball.velocity.x,
      y:ball.y-ball.velocity.y
    }
    yInterc = @pointA.y + -slope*@pointA.x
    if slope == INFINITY
      if previousPosition.x < @pointA.x
        perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
        yInterc = -INFINITY
      end
    elsif previousPosition.y < slope*previousPosition.x + yInterc #check if ball is bellow or above the collider to determine if perpVect is - or +
      perpVect = {x: perpVect.x*-1, y: perpVect.y*-1}
    end

    velocityMag = (ball.velocity.x**2 + ball.velocity.y**2)**0.5
    theta_ball=Math.atan2(ball.velocity.y,ball.velocity.x) #the angle of the ball's velocity
    theta_repel=Math.atan2(perpVect.y,perpVect.x) #the angle of the repelling force(perpVect)

    fbx = velocityMag * Math.cos(theta_ball) #the x component of the ball's velocity
    fby = velocityMag * Math.sin(theta_ball) #the y component of the ball's velocity

    #the magnitude of the repelling force
    repelMag = getRepelMagnitude(fbx, fby, perpVect.x, perpVect.y, (ball.velocity.x**2 + ball.velocity.y**2)**0.5)
    frx = repelMag* Math.cos(theta_repel) #the x component of the repel's velocity | magnitude is set to twice of fbx
    fry = repelMag* Math.sin(theta_repel) #the y component of the repel's velocity | magnitude is set to twice of fby

    fsumx = fbx+frx #sum of x forces
    fsumy = fby+fry #sum of y forces
    fr = velocityMag#fr is the resulting magnitude
    thetaNew = Math.atan2(fsumy, fsumx)  #thetaNew is the resulting angle
    xnew = fr*Math.cos(thetaNew)#resulting x velocity
    ynew = fr*Math.sin(thetaNew)#resulting y velocity
    if (velocityMag < MAX_VELOCITY)
      ball.velocity =  Vector2d.new(xnew*1.1, ynew*1.1)
    else
      ball.velocity =  Vector2d.new(xnew, ynew)
    end

  end
end
