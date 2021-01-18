
class Ball
    attr_accessor :velocity, :child, :parent, :number, :leastChain
    attr_reader :x, :y, :hypotenuse, :width, :height

    def initialize args, number, leastChain, parent, child
        #Start the ball in the top center
        @number = number
        @leastChain = leastChain
        @x = args.grid.w / 2
        @y = args.grid.h - 20

        @velocity = Vector2d.new(2, -2)
        @width =  10
        @height = 10

        @left_wall = (args.state.board_width + args.grid.w / 8)
        @right_wall = @left_wall + args.state.board_width

        @max_velocity = MAX_VELOCITY

        @child = child
        @parent = parent

        @past = [{x: @x, y: @y}]
        @next = nil
    end

    def reassignLeastChain (lc=nil)
      if (lc == nil)
        lc = @number
      end
      @leastChain = lc
      if (parent != nil)
        @parent.reassignLeastChain(lc)
      end

    end

    def makeLeader args
      if isLeader
        return
      end
      @parent.reassignLeastChain
      args.state.ballParents.push(self)
      @parent = nil

    end

    def isLeader
      return (parent == nil)
    end

    def receiveNext (p)
      #trace!
      if parent != nil
        @x = p[:x]
        @y = p[:y]
        @velocity = p[:velocity]
        #puts @x.to_s + "|" + @y.to_s + "|"+@velocity.to_s
        @past.append(p)
        if (@past.length >= BALL_DISTANCE)
          if (@child != nil)
            @child.receiveNext(@past[0])
            @past.shift
          end
        end
      end
    end

    #Move the ball according to its velocity
    def update args

        if isLeader
          wallBounds args
          @x += @velocity.x
          @y += @velocity.y
          @past.append({x: @x, y: @y, velocity: @velocity})
          #puts @past

          if (@past.length >= BALL_DISTANCE)
            if (@child != nil)
              @child.receiveNext(@past[0])
              @past.shift
            end
          end

        else
          puts "unexpected"
          raise "unexpected"
        end
    end

    def wallBounds args
        b= false
        if @x < @left_wall
          @velocity.x = @velocity.x.abs() * 1
          b=true
        elsif @x + @width > @right_wall
          @velocity.x = @velocity.x.abs() * -1
          b=true
        end
        if @y < 0
          @velocity.y = @velocity.y.abs() * 1
          b=true
        elsif @y + @height > args.grid.h
          @velocity.y = @velocity.y.abs() * -1
          b=true
        end
        mag = (@velocity.x**2.0 + @velocity.y**2.0)**0.5
        if (b == true && mag < MAX_VELOCITY)
          @velocity.x*=1.1;
          @velocity.y*=1.1;
        end

    end

    #render the ball to the screen
    def draw args

        #update args
        #args.outputs.solids << [@x, @y, @width, @height, 255, 255, 0];
        #args.outputs.sprits << {
          #x: @x,
          #y: @y,
          #w: @width,
          #h: @height,
          #path: "sprites/ball10.png"
        #}
        #args.outputs.sprites <<[@x, @y, @width, @height, "sprites/ball10.png"]
        args.outputs.sprites << {x: @x, y: @y, w: @width, h: @height, path:"sprites/ball10.png" }
    end

    def getDraw args
      #wallBounds args
      #update args
      #args.outputs.labels << [@x, @y, @number.to_s + "|" + @leastChain.to_s]
      return [@x, @y, @width, @height, "sprites/ball10.png"]
    end

    def getPoints args
      points = [
        {x:@x+@width/2, y: @y},
        {x:@x+@width, y:@y+@height/2},
        {x:@x+@width/2,y:@y+@height},
        {x:@x,y:@y+@height/2}
      ]
      #psize = 5.0
      #for p in points
        #args.outputs.solids << [p.x-psize/2.0, p.y-psize/2.0, psize, psize, 0, 0, 0];
      #end
      return points
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
