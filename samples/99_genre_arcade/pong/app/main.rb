def tick args
  defaults args
  render args
  calc args
  input args
end

def defaults args
  args.state.ball ||= {
    debounce: 3 * 60,
    size: 10,
    size_half: 5,
    x: 640,
    y: 360,
    dx: 5.randomize(:sign),
    dy: 5.randomize(:sign)
  }

  args.state.paddle ||= {
    w: 10,
    h: 120
  }

  args.state.left_paddle  ||= { y: 360, score: 0 }
  args.state.right_paddle ||= { y: 360, score: 0 }
end

def render args
  render_center_line args
  render_scores args
  render_countdown args
  render_ball args
  render_paddles args
  render_instructions args
end

begin :render_methods
  def render_center_line args
    args.outputs.lines  << [640, 0, 640, 720]
  end

  def render_scores args
    args.outputs.labels << [
      { x: 320,
        y: 650,
        text: args.state.left_paddle.score,
        size_px: 40,
        anchor_x: 0.5,
        anchor_y: 0.5 },
      { x: 960,
        y: 650,
        text: args.state.right_paddle.score,
        size_px: 40,
        anchor_x: 0.5,
        anchor_y: 0.5 }
    ]
  end

  def render_countdown args
    return unless args.state.ball.debounce > 0
    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "%.2f" % args.state.ball.debounce.fdiv(60),
                             size_px: 40,
                             anchor_x: 0.5,
                             anchor_y: 0.5 }
  end

  def render_ball args
    args.outputs.solids << solid_ball(args)
  end

  def render_paddles args
    args.outputs.solids << solid_left_paddle(args)
    args.outputs.solids << solid_right_paddle(args)
  end

  def render_instructions args
    args.outputs.labels << { x: 320,
                             y: 30,
                             text: "W and S keys to move left paddle.",
                             anchor_x: 0.5,
                             anchor_y: 0.5 }
    args.outputs.labels << { x: 920,
                             y: 30,
                             text: "O and L keys to move right paddle.",
                             anchor_x: 0.5,
                             anchor_y: 0.5 }
  end
end

def calc args
  args.state.ball.debounce -= 1 and return if args.state.ball.debounce > 0
  calc_move_ball args
  calc_collision_with_left_paddle args
  calc_collision_with_right_paddle args
  calc_collision_with_walls args
end

begin :calc_methods
  def calc_move_ball args
    args.state.ball.x += args.state.ball.dx
    args.state.ball.y += args.state.ball.dy
  end

  def calc_collision_with_left_paddle args
    if solid_left_paddle(args).intersect_rect? solid_ball(args)
      args.state.ball.dx *= -1
    elsif args.state.ball.x < 0
      args.state.right_paddle.score += 1
      calc_reset_round args
    end
  end

  def calc_collision_with_right_paddle args
    if solid_right_paddle(args).intersect_rect? solid_ball(args)
      args.state.ball.dx *= -1
    elsif args.state.ball.x > 1280
      args.state.left_paddle.score += 1
      calc_reset_round args
    end
  end

  def calc_collision_with_walls args
    if args.state.ball.y + args.state.ball.size_half > 720
      args.state.ball.y = 720 - args.state.ball.size_half
      args.state.ball.dy *= -1
    elsif args.state.ball.y - args.state.ball.size_half < 0
      args.state.ball.y = args.state.ball.size_half
      args.state.ball.dy *= -1
    end
  end

  def calc_reset_round args
    args.state.ball.x = 640
    args.state.ball.y = 360
    args.state.ball.dx = 5.randomize(:sign)
    args.state.ball.dy = 5.randomize(:sign)
    args.state.ball.debounce = 3 * 60
  end
end

def input args
  input_left_paddle args
  input_right_paddle args
end

def input_left_paddle args
  if args.inputs.controller_one.key_down.down  || args.inputs.keyboard.key_down.s
    args.state.left_paddle.y -= 40
  elsif args.inputs.controller_one.key_down.up || args.inputs.keyboard.key_down.w
    args.state.left_paddle.y += 40
  end
end

def input_right_paddle args
  if args.inputs.controller_two.key_down.down  || args.inputs.keyboard.key_down.l
    args.state.right_paddle.y -= 40
  elsif args.inputs.controller_two.key_down.up || args.inputs.keyboard.key_down.o
    args.state.right_paddle.y += 40
  end
end

def solid_ball args
  { x: args.state.ball.x,
    y: args.state.ball.y,
    w: args.state.ball.size,
    h: args.state.ball.size,
    anchor_x: 0.5,
    anchor_y: 0.5 }
end

def solid_left_paddle args
  { x: 0,
    y: args.state.left_paddle.y,
    w: args.state.paddle.w,
    h: args.state.paddle.h,
    anchor_y: 0.5 }
end

def solid_right_paddle args
  { x: 1280 - args.state.paddle.w,
    y: args.state.right_paddle.y,
    w: args.state.paddle.w,
    h: args.state.paddle.h,
    anchor_y: 0.5 }
end
