class Cannon
  def initialize args
    @pointA = {x: args.grid.right/2,y: args.grid.top}
    @pointB = {x: args.inputs.mouse.x, y: args.inputs.mouse.y}
  end
  def update args
    activeBall = args.state.ball
    @pointB = {x: args.inputs.mouse.x, y: args.inputs.mouse.y}

    if args.inputs.mouse.click
      alpha = 0.01
      activeBall.velocity.y = (@pointB.y - @pointA.y) * alpha
      activeBall.velocity.x = (@pointB.x - @pointA.x) * alpha
      activeBall.center = {x: (args.grid.w / 2), y: (args.grid.h)}
    end
  end
  def render args
    args.outputs.lines << [@pointA.x, @pointA.y, @pointB.x, @pointB.y]
  end
end
