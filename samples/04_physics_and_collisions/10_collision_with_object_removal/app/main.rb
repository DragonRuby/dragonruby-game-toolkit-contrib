# coding: utf-8
INFINITY= 10**10
WIDTH=1280
HEIGHT=720

require 'app/vector2d.rb'
require 'app/paddle.rb'
require 'app/ball.rb'
require 'app/linear_collider.rb'

#Method to init default values
def defaults args
  args.state.game_board ||= [(args.grid.w / 2 - args.grid.w / 4), 0, (args.grid.w / 2), args.grid.h]
  args.state.bricks ||= []
  args.state.num_bricks ||= 0
  args.state.game_over_at ||= 0
  args.state.paddle ||= Paddle.new
  args.state.ball   ||= Ball.new
  args.state.westWall  ||= LinearCollider.new({x: args.grid.w/4,      y: 0},          {x: args.grid.w/4,      y: args.grid.h}, :pos)
  args.state.eastWall  ||= LinearCollider.new({x: 3*args.grid.w*0.25, y: 0},          {x: 3*args.grid.w*0.25, y: args.grid.h})
  args.state.southWall ||= LinearCollider.new({x: 0,                  y: 0},          {x: args.grid.w,        y: 0})
  args.state.northWall ||= LinearCollider.new({x: 0,                  y:args.grid.h}, {x: args.grid.w,        y: args.grid.h}, :pos)

  #args.state.testWall ||= LinearCollider.new({x:0 , y:0},{x:args.grid.w, y:args.grid.h})
end

#Render loop
def render args
  render_instructions args
  render_board args
  render_bricks args
end

begin :render_methods
  #Method to display the instructions of the game
  def render_instructions args
    args.outputs.labels << [225, args.grid.h - 30, "← and → to move the paddle left and right",  0, 1]
  end

  def render_board args
    args.outputs.borders << args.state.game_board
  end

  def render_bricks args
    args.outputs.solids << args.state.bricks.map(&:rect)
  end
end

#Calls all methods necessary for performing calculations
def calc args
  add_new_bricks args
  reset_game args
  calc_collision args
  win_game args

  args.state.westWall.update args
  args.state.eastWall.update args
  args.state.southWall.update args
  args.state.northWall.update args
  args.state.paddle.update args
  args.state.ball.update args

  #args.state.testWall.update args

  args.state.paddle.render args
  args.state.ball.render args
end

begin :calc_methods
  def add_new_bricks args
    return if args.state.num_bricks > 40

    #Width of the game board is 640px
    brick_width = (args.grid.w / 2) / 10
    brick_height = brick_width / 2

    (4).map_with_index do |y|
      #Make a box that is 10 bricks wide and 4 bricks tall
      args.state.bricks += (10).map_with_index do |x|
        args.state.new_entity(:brick) do |b|
          b.x = x * brick_width + (args.grid.w / 2 - args.grid.w / 4)
          b.y = args.grid.h - ((y + 1) * brick_height)
          b.rect = [b.x + 1, b.y - 1, brick_width - 2, brick_height - 2, 235, 50 * y, 52]

          #Add linear colliders to the brick
          b.collider_bottom = LinearCollider.new([(b.x-2), (b.y-5)], [(b.x+brick_width+1), (b.y-5)], :pos, brick_height)
          b.collider_right = LinearCollider.new([(b.x+brick_width+1), (b.y-5)], [(b.x+brick_width+1), (b.y+brick_height+1)], :pos)
          b.collider_left = LinearCollider.new([(b.x-2), (b.y-5)], [(b.x-2), (b.y+brick_height+1)], :neg)
          b.collider_top = LinearCollider.new([(b.x-2), (b.y+brick_height+1)], [(b.x+brick_width+1), (b.y+brick_height+1)], :neg)

          # @xyCollision  = LinearCollider.new({x: @x,y: @y+@height}, {x: @x+@width, y: @y+@height})
          # @xyCollision2 = LinearCollider.new({x: @x,y: @y}, {x: @x+@width, y: @y}, :pos)
          # @xyCollision3 = LinearCollider.new({x: @x,y: @y}, {x: @x, y: @y+@height})
          # @xyCollision4 = LinearCollider.new({x: @x+@width,y: @y}, {x: @x+@width, y: @y+@height}, :pos)

          b.broken = false

          args.state.num_bricks += 1
        end
      end
    end
  end

  def reset_game args
    if args.state.ball.xy.y < 20 && args.state.game_over_at.elapsed_time > 60
      #Freeze the ball
      args.state.ball.velocity.x = 0
      args.state.ball.velocity.y = 0
      #Freeze the paddle
      args.state.paddle.enabled = false

      args.state.game_over_at = args.state.tick_count
    end

    if args.state.game_over_at.elapsed_time < 60 && args.state.tick_count > 60 && args.state.bricks.count != 0
      #Display a "Game over" message
      args.outputs.labels << [100, 100, "GAME OVER", 10]
    end

    #If 60 frames have passed since the game ended, restart the game
    if args.state.game_over_at != 0 && args.state.game_over_at.elapsed_time == 60
      # FIXME: only put value types in state
      args.state.ball = Ball.new

      # FIXME: only put value types in state
      args.state.paddle = Paddle.new

      args.state.bricks = []
      args.state.num_bricks = 0
    end
  end

  def calc_collision args
    #Remove the brick if it is hit with the ball
    ball = args.state.ball
    ball_rect = [ball.xy.x, ball.xy.y, 20, 20]

    #Loop through each brick to see if the ball is colliding with it
    args.state.bricks.each do |b|
      if b.rect.intersect_rect?(ball_rect)
        #Run the linear collider for the brick if there is a collision
        b[:collider_bottom].update args
        b[:collider_right].update args
        b[:collider_left].update args
        b[:collider_top].update args

        b.broken = true
      end
    end

    args.state.bricks = args.state.bricks.reject(&:broken)
  end

  def win_game args
    if args.state.bricks.count == 0 && args.state.game_over_at.elapsed_time > 60
      #Freeze the ball
      args.state.ball.velocity.x = 0
      args.state.ball.velocity.y = 0
      #Freeze the paddle
      args.state.paddle.enabled = false

      args.state.game_over_at = args.state.tick_count
    end

    if args.state.game_over_at.elapsed_time < 60 && args.state.tick_count > 60 && args.state.bricks.count == 0
      #Display a "Game over" message
      args.outputs.labels << [100, 100, "CONGRATULATIONS!", 10]
    end
  end

end

def tick args
  defaults args
  render args
  calc args

  #args.outputs.lines << [0, 0, args.grid.w, args.grid.h]

  #$tc+=1
  #if $tc == 5
    #$train << [args.state.ball.xy.x, args.state.ball.xy.y]
    #$tc = 0
  #end
  #for t in $train

    #args.outputs.solids << [t[0],t[1],5,5,255,0,0];
  #end
end
