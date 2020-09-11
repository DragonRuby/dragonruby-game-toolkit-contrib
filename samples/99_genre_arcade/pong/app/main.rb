def tick args
  defaults args
  render args
  calc args
  input args
end

def defaults args
  args.state.ball.debounce       ||= 3 * 60
  args.state.ball.size           ||= 10
  args.state.ball.size_half      ||= args.state.ball.size / 2
  args.state.ball.x              ||= 640
  args.state.ball.y              ||= 360
  args.state.ball.dx             ||= 5.randomize(:sign)
  args.state.ball.dy             ||= 5.randomize(:sign)
  args.state.left_paddle.y       ||= 360
  args.state.right_paddle.y      ||= 360
  args.state.paddle.h            ||= 120
  args.state.paddle.w            ||= 10
  args.state.left_paddle.score   ||= 0
  args.state.right_paddle.score  ||= 0
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
      [320, 650, args.state.left_paddle.score, 10, 1],
      [960, 650, args.state.right_paddle.score, 10, 1]
    ]
  end

  def render_countdown args
    return unless args.state.ball.debounce > 0
    args.outputs.labels << [640, 360, "%.2f" % args.state.ball.debounce.fdiv(60), 10, 1]
  end

  def render_ball args
    args.outputs.solids << solid_ball(args)
  end

  def render_paddles args
    args.outputs.solids << solid_left_paddle(args)
    args.outputs.solids << solid_right_paddle(args)
  end

  def render_instructions args
    args.outputs.labels << [320, 30, "W and S keys to move left paddle.",  0, 1]
    args.outputs.labels << [920, 30, "O and L keys to move right paddle.", 0, 1]
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

begin :input_methods
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
end

begin :assets
  def solid_ball args
    centered_rect args.state.ball.x, args.state.ball.y, args.state.ball.size, args.state.ball.size
  end

  def solid_left_paddle args
    centered_rect_vertically 0, args.state.left_paddle.y, args.state.paddle.w, args.state.paddle.h
  end

  def solid_right_paddle args
    centered_rect_vertically 1280 - args.state.paddle.w, args.state.right_paddle.y, args.state.paddle.w, args.state.paddle.h
  end

  def centered_rect x, y, w, h
    [x - w / 2, y - h / 2, w, h]
  end

  def centered_rect_vertically x, y, w, h
    [x, y - h / 2, w, h]
  end
end
