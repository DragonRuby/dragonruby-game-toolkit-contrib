# game concept from: https://youtu.be/Tz-AinJGDIM

# This class encapsulates the logic of a button that pulses when clicked.
# It is used in the StartScene and GameOverScene classes.
class PulseButton
  # a block is passed into the constructor and is called when the button is clicked,
  # and after the pulse animation is complete
  def initialize rect, text, &on_click
    @rect = rect
    @text = text
    @on_click = on_click
    @pulse_animation_spline = [[0.0, 0.90, 1.0, 1.0], [1.0, 0.10, 0.0, 0.0]]
    @duration = 10
  end

  # the button is ticked every frame and check to see if the mouse
  # intersects the button's bounding box.
  # if it does, then pertinent information is stored in the @clicked_at variable
  # which is used to calculate the pulse animation
  def tick tick_count, mouse
    @tick_count = tick_count

    if @clicked_at && @clicked_at.elapsed_time > @duration
      @clicked_at = nil
      @on_click.call
    end

    return if !mouse.click
    return if !mouse.inside_rect? @rect
    @clicked_at = tick_count
  end

  # this function returns an array of primitives that can be rendered
  def prefab easing
    # calculate the percentage of the pulse animation that has completed
    # and use the percentage to compute the size and position of the button
    perc = if @clicked_at
             Easing.spline @clicked_at, @tick_count, @duration, @pulse_animation_spline
           else
             0
           end

    rect = { x: @rect.x - 50 * perc / 2,
             y: @rect.y - 50 * perc / 2,
             w: @rect.w + 50 * perc,
             h: @rect.h + 50 * perc }

    point = { x: @rect.x + @rect.w / 2, y: @rect.y + @rect.h / 2 }
    [
      { **rect, path: :pixel },
      { **point, text: @text, size_px: 32, anchor_x: 0.5, anchor_y: 0.5 }
    ]
  end
end

# the start scene is loaded when the game is started
# it contains a PulseButton that starts the game by setting the next_scene to :game and
# setting the started_at time
class StartScene
  attr_gtk

  def initialize args
    self.args = args
    @play_button = PulseButton.new layout.rect(row: 6, col: 11, w: 2, h: 2), "play" do
      state.next_scene = :game
      state.events.game_started_at = Kernel.tick_count
      state.events.game_over_at = nil
    end
  end

  def tick
    return if state.current_scene != :start
    @play_button.tick Kernel.tick_count, inputs.mouse
    outputs[:start_scene].labels << layout.point(row: 0, col: 12).merge(text: "Squares", anchor_x: 0.5, anchor_y: 0.5, size_px: 64)
    outputs[:start_scene].primitives << @play_button.prefab(easing)
  end
end

# the game over scene is displayed when the game is over
# it contains a PulseButton that restarts the game by setting the next_scene to :game and
# setting the game_retried_at time
class GameOverScene
  attr_gtk

  def initialize args
    self.args = args
    @replay_button = PulseButton.new layout.rect(row: 6, col: 11, w: 2, h: 2), "replay" do
      state.next_scene = :game
      state.events.game_retried_at = Kernel.tick_count
      state.events.game_over_at = nil
    end
  end

  def tick
    return if state.current_scene != :game_over
    @replay_button.tick Kernel.tick_count, inputs.mouse
    outputs[:game_over_scene].labels << layout.point(row: 0, col: 12).merge(text: "Game Over", anchor_x: 0.5, anchor_y: 0.5, size_px: 64)
    outputs[:game_over_scene].primitives << @replay_button.prefab(easing)

    rect = layout.point row: 2, col: 12
    outputs[:game_over_scene].primitives << rect.merge(text: state.score_last_game, anchor_x: 0.5, anchor_y: 0.5, size_px: 128, **state.red_color)

    rect = layout.point row: 4, col: 12
    outputs[:game_over_scene].primitives << rect.merge(text: "BEST #{state.best_score}", anchor_x: 0.5, anchor_y: 0.5, size_px: 64, **state.gray_color)
  end
end

# the game scene contains the game logic
class GameScene
  attr_gtk

  def tick
    defaults
    calc
    render
  end

  def defaults
    return if started_at != Kernel.tick_count

    # initalization of scene_state variables for the game
    scene_state.score_animation_spline = [[0.0, 0.66, 1.0, 1.0], [1.0, 0.33, 0.0, 0.0]]
    scene_state.launch_particle_queue = []
    scene_state.scale_down_particles_queue = []
    scene_state.score = 0
    scene_state.square_number = 1
    scene_state.squares = []
    scene_state.square_spawn_rate = 60
    scene_state.movement_outer_rect = layout.rect(row: 11, col: 7, w: 10, h: 1).merge(path: :pixel, **state.gray_color)

    scene_state.player = { x: Geometry.rect_center_point(movement_outer_rect).x,
                           y: movement_outer_rect.y,
                           w: movement_outer_rect.h,
                           h: movement_outer_rect.h,
                           path: :pixel,
                           movement_direction: 1,
                           movement_speed: 8,
                           **args.state.red_color }

    scene_state.movement_inner_rect = { x: movement_outer_rect.x + player.w * 1,
                                        y: movement_outer_rect.y,
                                        w: movement_outer_rect.w - player.w * 2,
                                        h: movement_outer_rect.h }
  end

  def calc
    calc_game_over_at
    calc_particles

    # game logic is only calculated if the current scene is :game
    return if state.current_scene != :game

    # we don't want the game loop to start for half a second after the game starts
    # this gives enough time for the game scene to animate in
    return if !started_at || started_at.elapsed_time <= 30

    calc_player
    calc_squares
    calc_game_over
  end

  # this function calculates the point in the time the game is over
  # an intermediary variable stored in scene_state.death_at is consulted
  # before transitioning to the game over scene to ensure that particle animations
  # have enough time to complete before the game over scene is rendered
  def calc_game_over_at
    return if !death_at
    return if death_at.elapsed_time < 120
    state.events.game_over_at ||= Kernel.tick_count
  end

  # this function calculates the particles
  # there are two queues of particles that are processed
  # the launch_particle_queue contains particles that are launched when the player is hit
  # the scale_down_particles_queue contains particles that need to be scaled down
  def calc_particles
    return if !started_at

    scene_state.launch_particle_queue.each do |p|
      p.x += p.launch_angle.vector_x * p.speed
      p.y += p.launch_angle.vector_y * p.speed
      p.speed *= 0.90
      p.d_a ||= 1
      p.a -= 1 * p.d_a
      p.d_a *= 1.1
    end

    scene_state.launch_particle_queue.reject! { |p| p.a <= 0 }

    scene_state.scale_down_particles_queue.each do |p|
      next if p.start_at > Kernel.tick_count
      p.scale_speed = p.scale_speed.abs
      p.x += p.scale_speed
      p.y += p.scale_speed
      p.w -= p.scale_speed * 2
      p.h -= p.scale_speed * 2
    end

    scene_state.scale_down_particles_queue.reject! { |p| p.w <= 0 }
  end

  def render
    return if !started_at
    scene_outputs.primitives << game_scene_score_prefab
    scene_outputs.primitives << scene_state.movement_outer_rect.merge(a: 128)
    scene_outputs.primitives << squares
    scene_outputs.primitives << player_prefab
    scene_outputs.primitives << scene_state.launch_particle_queue
    scene_outputs.primitives << scene_state.scale_down_particles_queue
  end

  # this function returns the rendering primitive for the score
  def game_scene_score_prefab
    score = if death_at
              state.score_last_game
            else
              scene_state.score
            end

    label_scale_prec = Easing.spline(scene_state.score_at || 0, Kernel.tick_count, 15, scene_state.score_animation_spline)
    rect = layout.point row: 4, col: 12
    rect.merge(text: score, anchor_x: 0.5, anchor_y: 0.5, size_px: 128 + 50 * label_scale_prec, **state.gray_color)
  end

  def player_prefab
    return nil if death_at
    scale_perc = Easing.ease(started_at + 30, Kernel.tick_count, 15, :smooth_start_quad, :flip)
    player.merge(x: player.x - player.w / 2 * scale_perc, y: player.y + player.h / 2 * scale_perc,
                 w: player.w * (1 - scale_perc), h: player.h * (1 - scale_perc))
  end

  # controls the player movement and change in direction of the player when the mouse is clicked
  def calc_player
    player.x += player.movement_speed * player.movement_direction
    player.movement_direction *= -1 if !Geometry.inside_rect? player, scene_state.movement_outer_rect
    return if !inputs.mouse.click
    return if !Geometry.inside_rect? player, movement_inner_rect
    player.movement_direction = -player.movement_direction
  end

  # computes the squares movement
  def calc_squares
    squares << new_square if Kernel.tick_count.zmod? scene_state.square_spawn_rate

    squares.each do |square|
      square.angle += 1
      square.x += square.dx
      square.y += square.dy
    end

    squares.reject! { |square| (square.y + square.h) < 0 }
  end

  # determines if score should be incremented or if the game should be over
  def calc_game_over
    collision = Geometry.find_intersect_rect player, squares
    return if !collision
    if collision.type == :good
      scene_state.score += 1
      scene_state.score_at = Kernel.tick_count
      scene_state.scale_down_particles_queue << collision.merge(start_at: Kernel.tick_count, scale_speed: -2)
      squares.delete collision
    else
      generate_death_particles
      state.best_score = scene_state.score if scene_state.score > state.best_score
      squares.clear
      state.score_last_game = scene_state.score
      scene_state.score = 0
      scene_state.square_number = 1
      scene_state.death_at = Kernel.tick_count
      state.next_scene = :game_over
    end
  end

  # this function generates the particles when the player is hit
  def generate_death_particles
    square_particles = squares.map { |b| b.merge(start_at: Kernel.tick_count + 60, scale_speed: -1) }

    scene_state.scale_down_particles_queue.concat square_particles

    # generate 12 particles with random size, launch angle and speed
    player_particles = 12.map do
      size = rand * player.h * 0.5 + 10
      player.merge(w: size, h: size, a: 255, launch_angle: rand * 180, speed: 10 + rand * 50)
    end

    scene_state.launch_particle_queue.concat player_particles
  end

  # this function returns a new square
  # every 5th square is a good square (increases the score)
  def new_square
    x = movement_inner_rect.x + rand * movement_inner_rect.w

    dx = if x > Geometry.rect_center_point(movement_inner_rect).x
           -0.9
         else
           0.9
         end

    if scene_state.square_number.zmod? 5
      type = :good
      color = state.red_color
    else
      type = :bad
      color = { r: 0, g: 0, b: 0 }
    end

    scene_state.square_number += 1

    { x: x - 16, y: 1300, w: 32, h: 32,
      dx: dx, dy: -5,
      angle: 0, type: type,
      path: :pixel, **color }
  end

  # death_at is the point in time that the player died
  # the death_at value is an intermediary variable that is used to calculate the death animation
  # before setting state.game_over_at
  def death_at
    return nil if !scene_state.death_at
    return nil if scene_state.death_at < started_at
    scene_state.death_at
  end

  # started_at is the point in time that the player started (or retried) the game
  def started_at
    state.events.game_retried_at || state.events.game_started_at
  end

  def scene_state
    state.game_scene ||= {}
  end

  def scene_outputs
    outputs[:game_scene]
  end

  def player
    scene_state.player
  end

  def movement_outer_rect
    scene_state.movement_outer_rect
  end

  def movement_inner_rect
    scene_state.movement_inner_rect
  end

  def squares
    scene_state.squares
  end
end

class RootScene
  attr_gtk

  def initialize args
    self.args = args
    @start_scene = StartScene.new args
    @game_scene = GameScene.new
    @game_over_scene = GameOverScene.new args
  end

  def tick
    outputs.background_color = [237, 237, 237]
    init_game
    state.scene_at_tick_start = state.current_scene
    tick_start_scene
    tick_game_scene
    tick_game_over_scene
    render_scenes
    transition_to_next_scene
  end

  def tick_start_scene
    @start_scene.args = args
    @start_scene.tick
  end

  def tick_game_scene
    @game_scene.args = args
    @game_scene.tick
  end

  def tick_game_over_scene
    @game_over_scene.args = args
    @game_over_scene.tick
  end

  # initlalization of game state that is shared between scenes
  def init_game
    return if Kernel.tick_count != 0

    state.current_scene = :start

    state.red_color = { r: 222, g: 63, b: 66 }
    state.gray_color = { r: 128, g: 128, b: 128 }

    state.events ||= {
      game_over_at: nil,
      game_started_at: nil,
      game_retried_at: nil
    }

    state.score_last_game = 0
    state.best_score = 0
    state.viewport = { x: 0, y: 0, w: 1280, h: 720 }
  end

  def transition_to_next_scene
    if state.scene_at_tick_start != state.current_scene
      raise "state.current_scene was changed during the tick. This is not allowed (use state.next_scene to set the scene to transfer to)."
    end

    return if !state.next_scene
    state.current_scene = state.next_scene
    state.next_scene = nil
  end

  # this function renders the scenes with a transition effect
  # based off of timestamps stored in state.events
  def render_scenes
    if state.events.game_over_at
      in_y = transition_in_y state.events.game_over_at
      out_y = transition_out_y state.events.game_over_at
      outputs.sprites << state.viewport.merge(y: out_y, path: :game_scene)
      outputs.sprites << state.viewport.merge(y: in_y, path: :game_over_scene)
    elsif state.events.game_retried_at
      in_y = transition_in_y state.events.game_retried_at
      out_y = transition_out_y state.events.game_retried_at
      outputs.sprites << state.viewport.merge(y: out_y, path: :game_over_scene)
      outputs.sprites << state.viewport.merge(y: in_y, path: :game_scene)
    elsif state.events.game_started_at
      in_y = transition_in_y state.events.game_started_at
      out_y = transition_out_y state.events.game_started_at
      outputs.sprites << state.viewport.merge(y: out_y, path: :start_scene)
      outputs.sprites << state.viewport.merge(y: in_y, path: :game_scene)
    else
      in_y = transition_in_y 0
      start_scene_perc = Easing.ease(0, Kernel.tick_count, 30, :smooth_stop_quad, :flip)
      outputs.sprites << state.viewport.merge(y: in_y, path: :start_scene)
    end
  end

  def transition_in_y start_at
    Easing.ease(start_at, Kernel.tick_count, 30, :smooth_stop_quad, :flip) * -1280
  end

  def transition_out_y start_at
    Easing.ease(start_at, Kernel.tick_count, 30, :smooth_stop_quad) * 1280
  end
end

def tick args
  $game ||= RootScene.new args
  $game.args = args
  $game.tick

  if args.inputs.keyboard.key_down.forward_slash
    @show_fps = !@show_fps
  end
  if @show_fps
    args.outputs.primitives << GTK.current_framerate_primitives
  end
end

GTK.reset
