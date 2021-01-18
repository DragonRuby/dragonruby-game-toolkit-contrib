class Rectangle
  def initialize args

    @image = "sprites/roundSquare_white.png"
    @width  = 160.0
    @height = 80.0
    @x=$args.grid.right/2.0 - @width/2.0
    @y=$args.grid.top/2.0 - @height/2.0

    @xtmp = @width  * (1.0/10.0)
    @ytmp = @height * (1.0/10.0)

    #ball0 = args.state.balls[0]
    #hypotenuse = (args.state.balls[0].width**2 + args.state.balls[0].height**2)**0.5
    hypotenuse=args.state.ball_hypotenuse
    @boldXY = {x:(@x-hypotenuse/2)-1, y:(@y-hypotenuse/2)-1}
    @boldWidth = @width + hypotenuse + 2
    @boldHeight = @height + hypotenuse + 2
    @bold = [(@x-hypotenuse/2)-1,(@y-hypotenuse/2)-1,@width + hypotenuse + 2,@height + hypotenuse + 2]


    @points = [
      {x:@x,        y:@y+@ytmp},
      {x:@x+@xtmp,        y:@y},
      {x:@x+@width-@xtmp, y:@y},
      {x:@x+@width, y:@y+@ytmp},
      {x:@x+@width, y:@y+@height-@ytmp},#
      {x:@x+@width-@xtmp, y:@y+@height},
      {x:@x+@xtmp,        y:@y+@height},
      {x:@x,        y:@y+@height-@ytmp}
    ]

    @colliders = []
    #i = 0
    #while i < @points.length-1
      #@colliders.append(LinearCollider.new(@points[i],@points[i+1],:pos))
      #i+=1
    #end
    @colliders.append(LinearCollider.new(@points[0],@points[1], :neg))
    @colliders.append(LinearCollider.new(@points[1],@points[2], :neg))
    @colliders.append(LinearCollider.new(@points[2],@points[3], :neg))
    @colliders.append(LinearCollider.new(@points[3],@points[4], :neg))
    @colliders.append(LinearCollider.new(@points[4],@points[5], :pos))
    @colliders.append(LinearCollider.new(@points[5],@points[6], :pos))
    @colliders.append(LinearCollider.new(@points[6],@points[7], :pos))
    @colliders.append(LinearCollider.new(@points[0],@points[7], :pos))

  end

  def update args

    for b in args.state.balls
      if [b.x, b.y, b.width, b.height].intersect_rect?(@bold)
        for c in @colliders
          if c.collision?(args, b.getPoints(args),b)
            c.collide args, b
          end
        end
      end
    end
  end

  def draw args
    args.outputs.sprites << [
      @x,                                       # X
      @y,                                       # Y
      @width,                                   # W
      @height,                                  # H
      @image,                                   # PATH
      0,                                        # ANGLE
      255,                                      # ALPHA
      219,                                      # RED_SATURATION
      112,                                      # GREEN_SATURATION
      147                                       # BLUE_SATURATION
    ]
    #args.outputs.sprites << [@x, @y, @width, @height, "sprites/roundSquare_small_black.png"]
  end

  def serialize
  	{x: @x, y:@y}
  end

  def inspect
  	serialize.to_s
  end

  def to_s
  	serialize.to_s
  end
end
