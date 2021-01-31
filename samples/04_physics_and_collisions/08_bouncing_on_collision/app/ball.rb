GRAVITY = -0.08

class Ball
    attr_accessor :velocity, :center, :radius, :collision_enabled

    def initialize args
        #Start the ball in the top center
        #@x = args.grid.w / 2
        #@y = args.grid.h - 20

        @velocity = {x: 0, y: 0}
        #@width =  20
        #@height = @width
        @radius = 20.0 / 2.0
        @center = {x: (args.grid.w / 2), y: (args.grid.h)}

        #@left_wall = (args.state.board_width + args.grid.w / 8)
        #@right_wall = @left_wall + args.state.board_width
        @left_wall = 0
        @right_wall = $args.grid.right

        @max_velocity = 7
        @collision_enabled = true
    end

    #Move the ball according to its velocity
    def update args
      @center.x += @velocity.x
      @center.y += @velocity.y
      @velocity.y += GRAVITY

      alpha = 0.2
      if @center.y-@radius <= 0
        @velocity.y  = (@velocity.y.abs*0.7).abs
        @velocity.x  = (@velocity.x.abs*0.9).abs * ((@velocity.x < 0) ? -1 : 1)

        if @velocity.y.abs() < alpha
          @velocity.y=0
        end
        if @velocity.x.abs() < alpha
          @velocity.x=0
        end
      end

      if @center.x > args.grid.right+@radius*2
        @center.x = 0-@radius
      elsif @center.x< 0-@radius*2
        @center.x = args.grid.right + @radius
      end
    end

    def wallBounds args
        #if @x < @left_wall || @x + @width > @right_wall
            #@velocity.x *= -1.1
            #if @velocity.x > @max_velocity
                #@velocity.x = @max_velocity
            #elsif @velocity.x < @max_velocity * -1
                #@velocity.x = @max_velocity * -1
            #end
        #end
        #if @y < 0 || @y + @height > args.grid.h
            #@velocity.y *= -1.1
            #if @velocity.y > @max_velocity
                #@velocity.y = @max_velocity
            #elsif @velocity.y < @max_velocity * -1
                #@velocity.y = @max_velocity * -1
            #end
        #end
    end

    #render the ball to the screen
    def draw args
        #args.outputs.solids << [@x, @y, @width, @height, 255, 255, 0];
        args.outputs.sprites << [
          @center.x-@radius,
          @center.y-@radius,
          @radius*2,
          @radius*2,
          "sprites/circle-white.png",
          0,
          255,
          255,    #r
          0,    #g
          255   #b
        ]
    end
  end
