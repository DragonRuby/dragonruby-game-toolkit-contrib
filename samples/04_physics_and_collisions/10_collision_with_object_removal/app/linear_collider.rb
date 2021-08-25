#The LinearCollider (theoretically) produces collisions upon a line segment defined point.y two x,y cordinates

class LinearCollider

  #start [Array of length 2] start of the line segment as a x,y cordinate
  #last [Array of length 2] end of the line segment as a x,y cordinate

  #inorder for the LinearCollider to be functional the line segment must be said to have a thickness
  #(as it is unlikly that a colliding object will land exactly on the linesegment)

  #extension defines if the line's thickness extends negatively or positively
  #extension :pos     extends positively
  #extension :neg     extends negatively

  #thickness [float] how thick the line should be (should always be atleast as large as the magnitude of the colliding object)
  def initialize (pointA, pointB, extension=:neg, thickness=10)
    @pointA = pointA
    @pointB = pointB
    @thickness = thickness
    @extension = extension

    @pointAExtended={
      x: @pointA.x + @thickness*(@extension == :neg ? -1 : 1),
      y: @pointA.y + @thickness*(@extension == :neg ? -1 : 1)
    }
    @pointBExtended={
      x: @pointB.x + @thickness*(@extension == :neg ? -1 : 1),
      y: @pointB.y + @thickness*(@extension == :neg ? -1 : 1)
    }

  end

  def resetPoints(pointA,pointB)
    @pointA = pointA
    @pointB = pointB

    @pointAExtended={
      x:@pointA.x + @thickness*(@extension == :neg ? -1 : 1),
      y:@pointA.y + @thickness*(@extension == :neg ? -1 : 1)
    }
    @pointBExtended={
      x:@pointB.x + @thickness*(@extension == :neg ? -1 : 1),
      y:@pointB.y + @thickness*(@extension == :neg ? -1 : 1)
    }
  end

  #TODO: Ugly function
  def slope (pointA, pointB)
    return (pointB.x==pointA.x) ? INFINITY : (pointB.y+-pointA.y)/(pointB.x+-pointA.x)
  end

  #TODO: Ugly function
  def intercept(pointA, pointB)
    if (slope(pointA, pointB) == INFINITY)
      -INFINITY
    elsif slope(pointA, pointB) == -1*INFINITY
      INFINITY
    else
      pointA.y+-1.0*(slope(pointA, pointB)*pointA.x)
    end
  end

  def calcY(pointA, pointB, x)
    return slope(pointA, pointB)*x + intercept(pointA, pointB)
  end

  #test if a collision has occurred
  def isCollision? (point)
    #INFINITY slop breaks down when trying to determin collision, ergo it requires a special test
    if slope(@pointA, @pointB) ==  INFINITY &&
      point.x >= [@pointA.x,@pointB.x].min+(@extension == :pos ? -@thickness : 0) &&
      point.x <= [@pointA.x,@pointB.x].max+(@extension == :neg ?  @thickness : 0) &&
      point.y >= [@pointA.y,@pointB.y].min && point.y <= [@pointA.y,@pointB.y].max
        return true
    end

    isNegInLine   = @extension == :neg &&
                    point.y <= slope(@pointA, @pointB)*point.x+intercept(@pointA,@pointB) &&
                    point.y >= point.x*slope(@pointAExtended, @pointBExtended)+intercept(@pointAExtended,@pointBExtended)
    isPosInLine   = @extension == :pos &&
                    point.y >= slope(@pointA, @pointB)*point.x+intercept(@pointA,@pointB) &&
                    point.y <= point.x*slope(@pointAExtended, @pointBExtended)+intercept(@pointAExtended,@pointBExtended)
    isInBoxBounds = point.x >= [@pointA.x,@pointB.x].min &&
                    point.x <= [@pointA.x,@pointB.x].max &&
                    point.y >= [@pointA.y,@pointB.y].min+(@extension == :neg ? -@thickness : 0) &&
                    point.y <= [@pointA.y,@pointB.y].max+(@extension == :pos ? @thickness : 0)

    return isInBoxBounds && (isNegInLine || isPosInLine)

  end

  def getRepelMagnitude (fbx, fby, vrx, vry, args)
    a = fbx ; b = vrx ; c = fby
    d = vry ; e = args.state.ball.velocity.mag

    if b**2 + d**2 == 0
      puts "magnitude error"
    end

    x1 = (-a*b+-c*d + (e**2 * b**2 - b**2 * c**2 + 2*a*b*c*d + e**2 + d**2 - a**2 * d**2)**0.5)/(b**2 + d**2)
    x2 = -((a*b + c*d + (e**2 * b**2 - b**2 * c**2 + 2*a*b*c*d + e**2 * d**2 - a**2 * d**2)**0.5)/(b**2 + d**2))
    return ((a+x1*b)**2 + (c+x1*d)**2 == e**2) ? x1 : x2
  end

  def update args
    #each of the four points on the square ball - NOTE simple to extend to a circle
    points= [ {x: args.state.ball.xy.x,                          y: args.state.ball.xy.y},
              {x: args.state.ball.xy.x+args.state.ball.width,    y: args.state.ball.xy.y},
              {x: args.state.ball.xy.x,                          y: args.state.ball.xy.y+args.state.ball.height},
              {x: args.state.ball.xy.x+args.state.ball.width,    y: args.state.ball.xy.y + args.state.ball.height}
            ]

    #for each point p in points
    for point in points
      #isCollision.md has more information on this section
      #TODO: section can certainly be simplifyed
      if isCollision?(point)
        u = Vector2d.new(1.0,((slope(@pointA, @pointB)==0) ? INFINITY : -1/slope(@pointA, @pointB))*1.0).normalize #normal perpendicular (to line segment) vector

        #the vector with the repeling force can be u or -u depending of where the ball was coming from in relation to the line segment
        previousBallPosition=Vector2d.new(point.x-args.state.ball.velocity.x,point.y-args.state.ball.velocity.y)
        choiceA = (u.mult(1))
        choiceB =  (u.mult(-1))
        vectorRepel = nil

        if (slope(@pointA, @pointB))!=INFINITY && u.y < 0
          choiceA, choiceB = choiceB, choiceA
        end
        vectorRepel = (previousBallPosition.y > calcY(@pointA, @pointB, previousBallPosition.x)) ? choiceA : choiceB

        #vectorRepel = (previousBallPosition.y > slope(@pointA, @pointB)*previousBallPosition.x+intercept(@pointA,@pointB)) ? choiceA : choiceB)
        if (slope(@pointA, @pointB) == INFINITY) #slope INFINITY breaks down in the above test, ergo it requires a custom test
          vectorRepel = (previousBallPosition.x > @pointA.x) ? (u.mult(1)) : (u.mult(-1))
        end
        #puts ("     " + $t[0].to_s + "," + $t[1].to_s + "    " + $t[2].to_s + "," + $t[3].to_s + "     " + "   " + u.x.to_s + "," + u.y.to_s)
        #vectorRepel now has the repeling force

        mag = args.state.ball.velocity.mag
        theta_ball=Math.atan2(args.state.ball.velocity.y,args.state.ball.velocity.x) #the angle of the ball's velocity
        theta_repel=Math.atan2(vectorRepel.y,vectorRepel.x) #the angle of the repeling force
        #puts ("theta:" + theta_ball.to_s + " " + theta_repel.to_s) #theta okay

        fbx = mag * Math.cos(theta_ball) #the x component of the ball's velocity
        fby = mag * Math.sin(theta_ball) #the y component of the ball's velocity

        repelMag = getRepelMagnitude(fbx, fby, vectorRepel.x, vectorRepel.y, args)

        frx = repelMag* Math.cos(theta_repel) #the x component of the repel's velocity | magnitude is set to twice of fbx
        fry = repelMag* Math.sin(theta_repel) #the y component of the repel's velocity | magnitude is set to twice of fby

        fsumx = fbx+frx #sum of x forces
        fsumy = fby+fry #sum of y forces
        fr = mag#fr is the resulting magnitude
        thetaNew = Math.atan2(fsumy, fsumx)  #thetaNew is the resulting angle
        xnew = fr*Math.cos(thetaNew) #resulting x velocity
        ynew = fr*Math.sin(thetaNew) #resulting y velocity

        args.state.ball.velocity = Vector2d.new(xnew,ynew)
        #args.state.ball.xy.add(args.state.ball.velocity)
        break #no need to check the other points ?
      else
      end
    end
  end #end update

end
