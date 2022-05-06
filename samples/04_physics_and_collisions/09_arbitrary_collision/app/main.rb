INFINITY= 10**10
MAX_VELOCITY = 8.0
BALL_COUNT = 90
BALL_DISTANCE = 20
require 'app/vector2d.rb'
require 'app/blocks.rb'
require 'app/ball.rb'
require 'app/rectangle.rb'
require 'app/linear_collider.rb'
require 'app/square_collider.rb'



#Method to init default values
def defaults args
  args.state.board_width ||= args.grid.w / 4
  args.state.board_height ||= args.grid.h
  args.state.game_area ||= [(args.state.board_width + args.grid.w / 8), 0, args.state.board_width, args.grid.h]
  args.state.balls ||= []
  args.state.num_balls ||= 0
  args.state.ball_created_at ||= args.state.tick_count
  args.state.ball_hypotenuse = (10**2 + 10**2)**0.5
  args.state.ballParents ||=nil

  init_blocks args
  init_balls args
end

begin :default_methods
  def init_blocks args
    block_size = args.state.board_width / 8
    #Space inbetween each block
    block_offset = 4

    args.state.squares ||=[
      Square.new(args, 2, 0, block_size, :right, block_offset),
      Square.new(args, 5, 0, block_size, :right, block_offset),
      Square.new(args, 6, 7, block_size, :right, block_offset)
    ]


    #Possible orientations are :right, :left, :up, :down


    args.state.tshapes ||= [
      TShape.new(args, 0, 6, block_size, :left, block_offset),
      TShape.new(args, 3, 3, block_size, :down, block_offset),
      TShape.new(args, 0, 3, block_size, :right, block_offset),
      TShape.new(args, 0, 11, block_size, :up, block_offset)
    ]

    args.state.lines ||= [
      Line.new(args,3, 8, block_size, :down, block_offset),
      Line.new(args, 7, 3, block_size, :up, block_offset),
      Line.new(args, 3, 7, block_size, :right, block_offset)
    ]

    #exit()
  end

  def init_balls args
    return unless args.state.num_balls < BALL_COUNT


    #only create a new ball every 10 ticks
    return unless args.state.ball_created_at.elapsed_time > 10

    if (args.state.num_balls == 0)
      args.state.balls.append(Ball.new(args,args.state.num_balls,BALL_COUNT-1, nil, nil))
      args.state.ballParents = [args.state.balls[0]]
    else
      args.state.balls.append(Ball.new(args,args.state.num_balls,BALL_COUNT-1, args.state.balls.last, nil) )
      args.state.balls[-2].child = args.state.balls[-1]
    end
    args.state.ball_created_at = args.state.tick_count
    args.state.num_balls += 1
  end
end

#Render loop
def render args
  bgClr = {r:10, g:10, b:200}
  bgClr = {r:255-30, g:255-30, b:255-30}

  args.outputs.solids << [0, 0, $args.grid.right, $args.grid.top, bgClr[:r], bgClr[:g], bgClr[:b]];
  args.outputs.borders << args.state.game_area

  render_instructions args
  render_shapes args

  render_balls args

  #args.state.rectangle.draw args

  args.outputs.sprites << [$args.grid.right-(args.state.board_width + args.grid.w / 8), 0, $args.grid.right, $args.grid.top, "sprites/square-white-2.png", 0, 255, bgClr[:r], bgClr[:g], bgClr[:b]]
  args.outputs.sprites << [0, 0, (args.state.board_width + args.grid.w / 8), $args.grid.top, "sprites/square-white-2.png", 0, 255, bgClr[:r], bgClr[:g], bgClr[:b]]

end

begin :render_methods
  def render_instructions args
    #gtk.current_framerate
    args.outputs.labels << [20, $args.grid.top-20, "FPS: " + $gtk.current_framerate.to_s]
    if (args.state.balls != nil && args.state.balls[0] != nil)
        bx =  args.state.balls[0].velocity.x
        by =  args.state.balls[0].velocity.y
        bmg = (bx**2.0 + by**2.0)**0.5
        args.outputs.labels << [20, $args.grid.top-20-20, "V: " + bmg.to_s ]
    end


  end

  def render_shapes args
    for s in args.state.squares
      s.draw args
    end

    for l in args.state.lines
      l.draw args
    end

    for t in args.state.tshapes
      t.draw args
    end


  end

  def render_balls args
    #args.state.balls.each do |ball|
      #ball.draw args
    #end

    args.outputs.sprites << args.state.balls.map do |ball|
      ball.getDraw args
    end
  end
end

#Calls all methods necessary for performing calculations
def calc args
  for b in args.state.ballParents
    b.update args
  end

  for s in args.state.squares
    s.update args
  end

  for l in args.state.lines
    l.update args
  end

  for t in args.state.tshapes
    t.update args
  end



end

begin :calc_methods

end

def tick args
  defaults args
  render args
  calc args
end
