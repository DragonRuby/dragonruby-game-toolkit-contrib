# this file sets up the main game loop (no need to modify it)
require "app/nokia_emulation.rb"

class Game
  attr :args, :nokia_mouse_position

  def tick
    # create a new game on frame zero
    new_game if Kernel.tick_count == 0
    # calc game
    calc
    # render game
    render
    # increment the clock
    state.clock += 1
  end

  def calc
    calc_game
    calc_restart
  end

  def calc_game
    # return if the game is over
    return if state.game_over

    # return if the game is just starting
    return if state.clock < 30

    # begin capturing input after the initial countdown
    if inputs.keyboard.left && snake.direction.x == 0
      # if keyboard left is pressed or held, and
      # if the snake is not moving left or right,
      # set the next direction to left
      snake.next_direction = { x: -1, y: 0 }
      snake.next_angle = 180
    elsif inputs.keyboard.right && snake.direction.x == 0
      # if keyboard right is pressed or held, and
      # if the snake is not moving left or right,
      # set the next direction to right
      snake.next_direction = { x: 1, y: 0 }
      snake.next_angle = 0
    end

    if inputs.keyboard.up && snake.direction.y == 0
      # if keyboard up is pressed or held, and
      # if the snake is not moving up or down,
      # set the next direction to up
      snake.next_direction = { x: 0, y: 1 }
      snake.next_angle = 90
    elsif inputs.keyboard.down && snake.direction.y == 0
      # if keyboard down is pressed or held, and
      # if the snake is not moving up or down,
      # set the next direction to down
      snake.next_direction = { x: 0, y: -1 }
      snake.next_angle = 270
    end

    # return if the game is in the initial countdown
    return if state.clock < 60

    # process the movement of the snake every 15 frames
    return if !state.clock.zmod?(15)

    # add a new segment to the end of the snake
    snake.body.push_back({ x: snake.head.x, y: snake.head.y })

    # update the snake's direction based on what input was captured
    snake.direction = { **snake.next_direction }

    # update the snake's angle based on what input was captured (for rendering)
    snake.angle = snake.next_angle

    # update the snake's head position based on its direction
    snake.head = { x: snake.head.x + snake.direction.x,
                   y: snake.head.y + snake.direction.y }

    # check if the snake has collided with the world boundaries
    if snake.head.x < 0 || snake.head.x >= state.world_dimensions.w ||
       snake.head.y < 0 || snake.head.y >= state.world_dimensions.h
      state.game_over = true
      state.game_over_at = state.clock
    end

    # check if the snake has collided with itself
    if snake.body.include?(snake.head)
      state.game_over = true
      state.game_over_at = state.clock
    end

    # if the snake body is longer than the snake size
    # remove the first segment of the snake body
    if snake.body.length > snake.sz
      snake.body.pop_front
    end

    # check if the snake has eaten the apple
    if snake.head.x == state.apple.x && snake.head.y == state.apple.y
      # increase the snake size
      snake.sz += 1
      # increase the score
      state.score += 1
      # check if the score is higher than the high score
      # and update the high score if necessary
      state.high_score = state.score if state.score > state.high_score
      # generate a new apple
      state.apple = new_apple
    end
  end

  def calc_restart
    # check keyboard input to see if game should be restarted
    # wait 60 frames after game over before accepting input
    return if !state.game_over
    return if state.game_over_at.elapsed_time(state.clock) < 60

    # if any key is pressed, start a new game
    if inputs.keyboard.key_down.truthy_keys.any?
      new_game
    end
  end

  def render
    # render the main game
    render_game
    # render the game over screen if needed
    render_game_over
  end

  def render_game
    # render the snake's head
    nokia.sprites << {
      x: snake.head.x * 3,
      y: snake.head.y * 3,
      w: 3,
      h: 3,
      path: "sprites/head.png",
      angle: snake.angle
    }

    # render the snake's body
    nokia.sprites << snake.body.map do |segment|
      {
        x: segment.x * 3,
        y: segment.y * 3,
        w: 3,
        h: 3,
        path: "sprites/body.png"
      }
    end

    # render the apple
    nokia.sprites << {
      x: state.apple.x * 3,
      y: state.apple.y * 3,
      w: 3,
      h: 3,
      path: "sprites/apple.png"
    }
  end

  def render_game_over
    # return if the game is not over
    return if !state.game_over

    # wait 60 frames after game over before rendering the game over screen/overlay
    return if state.game_over_at.elapsed_time(state.clock) < 60

    # render background
    nokia.sprites << {
      x: 84 / 2, y: 48 / 2, w: 84, h: 18, path: :solid, r: 67, g: 82, b: 61,
      anchor_x: 0.5, anchor_y: 0.5
    }

    # render game over text
    nokia.labels << sm_label.merge(x: 84 / 2,
                                   y: 48 / 2,
                                   r: 199, g: 240, b: 216,
                                   text: "GAME OVER",
                                   anchor_x: 0.5,
                                   anchor_y: -0.5)

    # render score text
    nokia.labels << sm_label.merge(x: 84 / 2,
                                   y: 48 / 2,
                                   r: 199, g: 240, b: 216,
                                   text: "SCORE: #{state.score}",
                                   anchor_x: 0.5,
                                   anchor_y: 0.5)

    # render high score text
    nokia.labels << sm_label.merge(x: 84 / 2,
                                   y: 48 / 2,
                                   r: 199, g: 240, b: 216,
                                   text: "HI SCORE: #{state.high_score}",
                                   anchor_x: 0.5,
                                   anchor_y: 1.75)
  end

  def snake
    # helper function to access the snake state so we aren't writing state.snake everywhere
    state.snake
  end

  def new_game
    # initial state for a new game
    state.clock = 0
    state.world_dimensions = { w: 28, h: 16 }
    state.snake = {
      sz: 3,
      head: { x: 14, y: 8 },
      body: [],
      direction: { x: 1, y: 0 },
      next_direction: { x: 1, y: 0 },
      angle: 0,
      next_angle: 0
    }
    state.high_score ||= 0
    state.score = 0
    state.apple = new_apple
    state.game_over = false
    state.game_over_at = nil
  end

  def new_apple
    # pick a random location for the apple
    potential_apple = { x: Numeric.rand(0..state.world_dimensions.w - 1),
                        y: Numeric.rand(0..state.world_dimensions.h - 1) }

    if snake.body.include?(potential_apple) || state.snake.head == potential_apple
      # if the apple is on the snake or in the snake's head, pick a new location
      new_apple
    else
      # otherwise, return the apple
      potential_apple
    end
  end

  def sm_label
    { x: 0, y: 0, size_px: 5, font: "fonts/lowrez.ttf", anchor_x: 0, anchor_y: 0 }
  end

  def md_label
    { x: 0, y: 0, size_px: 10, font: "fonts/lowrez.ttf", anchor_x: 0, anchor_y: 0 }
  end

  def lg_label
    { x: 0, y: 0, size_px: 15, font: "fonts/lowrez.ttf", anchor_x: 0, anchor_y: 0 }
  end

  def xl_label
    { x: 0, y: 0, size_px: 20, font: "fonts/lowrez.ttf", anchor_x: 0, anchor_y: 0 }
  end

  def nokia
    outputs[:nokia]
  end

  def outputs
    @args.outputs
  end

  def inputs
    @args.inputs
  end

  def state
    @args.state
  end
end

# GTK.reset will reset your entire game
# it's useful for debugging and starting fresh
# comment this line out if you want to retain your
# current game state in between hot reloads
GTK.reset
