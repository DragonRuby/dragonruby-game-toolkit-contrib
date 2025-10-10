# game concept from: https://youtu.be/Tz-AinJGDIM

# Color pallete for game
RED         = { r: 222, g:  63, b:  66 }
GRAY        = { r: 128, g: 128, b: 128 }
BLACK       = { r:   0, g:   0, b:   0 }
LIGHT_GRAY  = { r: 237, g: 237, b: 237 }

# initialize state to an empty hash
def boot args
  args.state = {}
end

# on tick, initialize the root_scene if it's nil
# delegate tick to the root scene container
def tick args
  $root_scene ||= RootScene.new
  $root_scene.args = args
  $root_scene.tick

  if args.inputs.keyboard.key_down.forward_slash
    @show_fps = !@show_fps
  end

  if @show_fps
    args.outputs.primitives << GTK.current_framerate_primitives
  end
end

# for hotloading, reset $root_scene to nil so that it's
# reinitialized
def reset args
  $root_scene = nil
end

class RootScene
  attr_gtk

  def initialize
    @args = args
    @start_scene = StartScene.new
    @game_scene = GameScene.new
    @game_over_scene = GameOverScene.new
    @all_scenes = [@start_scene, @game_scene, @game_over_scene]
  end

  def tick
    defaults

    # scene management is simply based off of a value
    # on state. we only want to swap scenes at the very end
    # of tick, so we capture its current value and then
    # after all scenes run, we perform the scene swap
    state.scene_before_tick = state.current_scene

    tick_scenes
    render

    # throw an error if state.current_scene changed
    if state.scene_before_tick != state.current_scene
      raise "state.current_scene was changed during the tick. Use state.next_scene to set the scene to transfer to."
    end

    if state.next_scene
      state.current_scene = state.next_scene
      state.current_scene_at = Kernel.tick_count
      state.next_scene = nil
    end
  end

  # state has properties that are shared across scenes,
  # these are view specific concerns so it doesn't make sense
  # to put it on the core Game class
  def defaults
    state.current_scene ||= :start
    state.current_scene_at ||= 0

    state.events ||= {
      game_over_at: nil,
      game_started_at: nil,
      game_retried_at: nil
    }

    state.current_score ||= 0
    state.best_score ||= 0
  end

  # all the scenes are enumerated, args is set on each scene,
  # then tick is invoked
  def tick_scenes
    @all_scenes.each do |scene|
      scene.args = args
      scene.tick
    end
  end

  # this function renders the scenes with a transition effect
  # based off of timestamps stored in state.events
  def render
    outputs.background_color = LIGHT_GRAY

    # because of the fancy animation transition,
    # up to two scenes will be rendered.
    # the scenes_to_render function gives those two scenes,
    # and specifies which scene is being moved in vs which
    # is being moved out
    results = scenes_to_render

    # compute the y offset for each scene based on the
    # point in time the transition should start
    in_y = transition_in_y results.event_at
    out_y = transition_out_y results.event_at
    in_scene = results.in_scene
    out_scene = results.out_scene

    # render each scene taking into consideration the animation y offsets
    outputs.primitives << Grid.allscreen_rect.merge(y: in_y, path: in_scene) if in_scene
    outputs.primitives << Grid.allscreen_rect.merge(y: out_y, path: out_scene) if out_scene
  end

  def scenes_to_render
    if state.events.game_over_at
      # if game over was the last event,
      # then we want to move the game over scene in,
      # and move out the game scene
      {
        event_at: state.events.game_over_at,
        in_scene: :game_over_scene,
        out_scene: :game_scene
      }
    elsif state.events.game_retried_at
      # if game retried was the last event,
      # then we want to move in the game scene,
      # and move out the game over scene
      {
        event_at: state.events.game_retried_at,
        in_scene: :game_scene,
        out_scene: :game_over_scene
      }
    elsif state.events.game_started_at
      # if game started was the last event,
      # then we want to move in the game scene,
      # and move out the start scene
      {
        event_at: state.events.game_started_at,
        in_scene: :game_scene,
        out_scene: :start_scene
      }
    else
      # on game start, immediately present the starts scene
      {
        event_at: 0,
        in_scene: :start_scene,
        out_scene: nil
      }
    end
  end

  def transition_in_y start_at
    Grid.allscreen_y + Easing.smooth_stop(start_at: start_at,
                                          duration: 30,
                                          tick_count: Kernel.tick_count,
                                          power: 4,
                                          flip: true) * -Grid.allscreen_h
  end

  def transition_out_y start_at
    Easing.smooth_stop(start_at: start_at,
                       duration: 30,
                       tick_count: Kernel.tick_count,
                       power: 4) * Grid.allscreen_h
  end
end

# the start scene is loaded when the game is started
# it contains a PulseButton that starts the game by setting the next_scene to :game and
# setting the started_at time
class StartScene
  attr_gtk

  def initialize
    @play_button = PulseButton.new pulse_button_location, "play" do
      state.next_scene = :game
      state.events.game_started_at = Kernel.tick_count
      state.events.game_over_at = nil
    end
  end

  def title_prefab
    label = { text: "Squares", anchor_x: 0.5, anchor_y: 0.5, size_px: 64, **BLACK }
    if Grid.landscape?
      Layout.rect(row: 1, col: 11, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    else
      Layout.rect(row: 1, col: 5, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    end
  end

  def pulse_button_location
    if Grid.landscape?
      Layout.rect(row: 9, col: 11, w: 2, h: 2, allscreen: true)
    else
      Layout.rect(row: 17, col: 5, w: 2, h: 2, allscreen: true)
    end
  end

  def tick
    return if state.current_scene != :start

    @play_button.rect = pulse_button_location
    @play_button.tick inputs.mouse
    outputs[:start_scene].w = Grid.allscreen_w
    outputs[:start_scene].h = Grid.allscreen_h
    outputs[:start_scene].primitives << title_prefab
    outputs[:start_scene].primitives << @play_button.prefab
  end
end

# the game over scene is displayed when the game is over
# it contains a PulseButton that restarts the game by setting the next_scene to :game and
# setting the game_retried_at time
class GameOverScene
  attr_gtk

  def initialize
    @replay_button = PulseButton.new replay_button_location, "replay" do
      state.next_scene = :game
      state.events.game_retried_at = Kernel.tick_count
      state.events.game_over_at = nil
    end
  end

  def replay_button_location
    if Grid.landscape?
      Layout.rect(row: 9, col: 11, w: 2, h: 2, allscreen: true)
    else
      Layout.rect(row: 16, col: 5, w: 2, h: 2, allscreen: true)
    end
  end

  def title_prefab
    label = { text: "Game Over", anchor_x: 0.5, anchor_y: 0.5, size_px: 64 }
    if Grid.landscape?
      Layout.rect(row: 1, col: 11, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    else
      Layout.rect(row: 1, col: 5, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    end
  end

  def current_score_prefab
    label = { text: state.current_score, anchor_x: 0.5, anchor_y: 0.5, size_px: 128, **RED }
    if Grid.landscape?
      Layout.rect(row: 4, col: 11, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    else
      Layout.rect(row: 8, col: 5, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    end
  end

  def best_score_prefab
    label = { text: "BEST #{state.best_score}", anchor_x: 0.5, anchor_y: 0.5, size_px: 64, **GRAY }
    if Grid.landscape?
      Layout.rect(row: 6, col: 11, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    else
      Layout.rect(row: 10, col: 5, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    end
  end

  def tick
    return if state.current_scene != :game_over
    @replay_button.rect = replay_button_location

    if (state.events&.game_over_at&.elapsed_time || 0) > 15
      @replay_button.tick inputs.mouse
    end
    outputs[:game_over_scene].w = Grid.allscreen_w
    outputs[:game_over_scene].h = Grid.allscreen_h
    outputs[:game_over_scene].primitives << title_prefab
    outputs[:game_over_scene].primitives << @replay_button.prefab
    outputs[:game_over_scene].primitives << current_score_prefab
    outputs[:game_over_scene].primitives << best_score_prefab
  end
end

# this is the core game (separate from it's rendering)
class Game
  attr :score, :square_number, :squares, :square_spawn_rate,
       :movement_outer_rect, :movement_inner_rect, :player, :death_at, :score_at

  def initialize
    # initialization of the game
    @score = 0
    @square_number = 1
    @squares = []
    @square_spawn_rate = 60

    # area the player is restricted to
    @movement_outer_rect = if Grid.landscape?
                             Layout.rect(row: 10, col: 7, w: 10, h: 1, allscreen: true)
                           else
                             Layout.rect(row: 17, col: 1, w: 10, h: 1, allscreen: true)
                           end

    # player's starting location
    @player = {
      x: @movement_outer_rect.center.x,
      y: @movement_outer_rect.y,
      w: @movement_outer_rect.h,
      h: @movement_outer_rect.h,
      movement_direction: 1,
      movement_speed: 8
    }

    init_movement_inner_rect!
  end

  def init_movement_inner_rect!
    # a smaller/more forgiving area that's used
    # so that input/square movement feels a little nicer
    @movement_inner_rect = {
      x: @movement_outer_rect.x + @player.w * 1,
      y: @movement_outer_rect.y,
      w: @movement_outer_rect.w - @player.w * 2,
      h: @movement_outer_rect.h
    }
  end

  def update_layout!
    movement_outer_rect_x = @movement_outer_rect.x
    movement_outer_rect_y = @movement_inner_rect.y
    @movement_outer_rect = if Grid.landscape?
                             Layout.rect(row: 10, col: 7, w: 10, h: 1, allscreen: true)
                           else
                             Layout.rect(row: 17, col: 1, w: 10, h: 1, allscreen: true)
                           end

    init_movement_inner_rect!

    shift_x = @movement_outer_rect.x - movement_outer_rect_x
    shift_y = @movement_outer_rect.y - movement_outer_rect_y

    @player.x += shift_x
    @player.y += shift_y
    @squares.each do |square|
      square.x += shift_x
      square.y += shift_y
    end

    return { x: shift_x, y: shift_y }
  end

  def tick(change_direction_requested:)
    # tick of the game, the request to change the player's direction
    # is forwarded to tick_play
    tick_player change_direction_requested: change_direction_requested
    tick_squares
    tick_collision
  end

  def tick_player(change_direction_requested:)
    # increment the player's x and change it's diretion if it's out of the
    # outer rect
    @player.x += @player.movement_speed * @player.movement_direction
    @player.y = @movement_outer_rect.y
    @player.movement_direction *= -1 if !Geometry.inside_rect? @player, @movement_outer_rect

    # if a direction change was requested, then perform the update if
    # they aren't right at the edge of the movement area
    return if !change_direction_requested
    return if !Geometry.inside_rect? @player, @movement_inner_rect
    @player.movement_direction = -@player.movement_direction
  end

  def tick_squares
    # this function controls the spawning of squares and
    # movement of squares down the screen
    @squares << new_square if Kernel.tick_count.zmod? @square_spawn_rate

    @squares.each do |square|
      square.angle += 1
      square.x += square.dx
      square.y += square.dy
    end

    # delete squares that are off the screen
    @squares.reject! { |square| (square.y + square.h) < 0 }
  end

  def tick_collision
    # collision check returns a hash back to the view so
    # that the tick result can be acted on
    # we return whether death occured, whether a score occured,
    # and return the scoring square + the rest of the squares
    # which is used by the view to generate animations
    collision = Geometry.find_intersect_rect @player, @squares

    # the default collision result is "nothing happened"
    collision_result = {
      death_occurred: false,
      score_occurred: false,
      scored_square: nil,
      all_squares: Array.new(@squares)
    }

    if !collision
      # do nothing, collision result remains unchanged
    elsif collision.type == :good
      # if they collided with a "good" square, then
      # increment the score and update the collision result
      # with the square that was collided with
      @score += 1
      @score_at = Kernel.tick_count
      @squares.delete collision
      collision_result.merge! score_occurred: true,
                              scored_square: collision

    else
      # if they collided with a "bad" square, then it's a game over
      # clear all the current squares and set when death occurred
      @squares.clear
      @score = 0
      @square_number = 1
      @death_at = Kernel.tick_count
      collision_result.merge! death_occurred: true
    end

    # return the collision result
    collision_result
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

    if @square_number.zmod? 5
      type = :good
    else
      type = :bad
    end

    @square_number += 1

    {
      x: x - 16,
      y: @player.y + 1300, w: 32, h: 32,
      dx: dx, dy: -5,
      angle: 0, type: type
    }
  end

end

# the game scene contains the game logic
class GameScene
  attr_gtk

  attr :scale_down_particles_queue, :launch_particle_queue

  def initialize
    @game = Game.new
    @launch_particle_queue = []
    @scale_down_particles_queue = []
    @score_animation_spline = [[0.0, 0.66, 1.0, 1.0], [1.0, 0.33, 0.0, 0.0]]
  end

  def tick
    calc
    render
  end

  def calc
    should_update_layout = state.current_scene_at == Kernel.tick_count || Grid.orientation_changed? || events.resize_occurred

    if should_update_layout
      shifted_location = @game.update_layout!

      if shifted_location
        @launch_particle_queue.each do |p|
          p.x += shifted_location.x
          p.y += shifted_location.y
        end

        @scale_down_particles_queue.each do |p|
          p.x += shifted_location.x
          p.y += shifted_location.y
        end
      end
    end

    calc_game_over_at
    calc_particles

    # game logic is only calculated if the current scene is :game
    return if state.current_scene != :game

    # set the current score to zero for presentation
    state.current_score = 0

    # we don't want the game loop to start for half a second after the game starts
    # this gives enough time for the game scene to animate in
    return if !started_at || started_at.elapsed_time <= 30

    # update current score the the game score if things have started up
    state.current_score = @game.score

    # after, tick check the tick_result to see which animations we should kick off
    tick_result = @game.tick change_direction_requested: inputs.mouse.click

    # if the player captured a "good" square, then queue up the animation
    # of the "good" square
    if tick_result.score_occurred
      @scale_down_particles_queue << square_prefab(tick_result.scored_square).merge(start_at: Kernel.tick_count, scale_speed: -2)
    elsif tick_result.death_occurred
      # if death occured that generated the explosion animation
      # and the scale out of all the set pieces
      generate_death_particles! tick_result.all_squares
      state.best_score = state.current_score if state.current_score > state.best_score
      state.next_scene = :game_over
    end
  end

  # this function calculates the point in the time the game is over
  # an intermediary variable stored in @game.death_at is consulted
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
  # this isn't part of the Game object because its specifically visual effects
  # and doesn't affect the game logic
  def calc_particles
    @launch_particle_queue.each do |p|
      p.x += p.launch_angle.vector_x * p.speed
      p.y += p.launch_angle.vector_y * p.speed
      p.speed *= 0.90
      p.d_a ||= 1
      p.a -= 1 * p.d_a
      p.d_a *= 1.1
    end

    @launch_particle_queue.reject! { |p| p.a <= 0 }

    @scale_down_particles_queue.each do |p|
      next if p.start_at > Kernel.tick_count
      p.scale_speed = p.scale_speed.abs
      p.x += p.scale_speed
      p.y += p.scale_speed
      p.w -= p.scale_speed * 2
      p.h -= p.scale_speed * 2
    end

    @scale_down_particles_queue.reject! { |p| p.w <= 0 }
  end

  def render
    return if !started_at
    outputs[:game_scene].w = Grid.allscreen_w
    outputs[:game_scene].h = Grid.allscreen_h
    outputs[:game_scene].primitives << score_prefab
    outputs[:game_scene].primitives << @game.movement_outer_rect.merge(path: :solid, **GRAY, a: 128)
    outputs[:game_scene].primitives << square_prefabs(@game.squares)
    outputs[:game_scene].primitives << player_prefab(@game.player)
    outputs[:game_scene].primitives << @launch_particle_queue
    outputs[:game_scene].primitives << @scale_down_particles_queue
  end

  def square_prefab s
    color = s.type == :good ? RED : BLACK
    { **s, path: :solid, **color }
  end

  def square_prefabs squares
    squares.map { |s| square_prefab s }
  end

  # this function returns the rendering primitive for the score
  def score_prefab
    score = state.current_score

    label_scale_prec = Easing.spline(@game.score_at || 0, Kernel.tick_count, 15, @score_animation_spline)
    label = { text: score, anchor_x: 0.5, anchor_y: 0.5, size_px: 128 + 50 * label_scale_prec, **RED }
    if Grid.landscape?
      Layout.rect(row: 1, col: 11, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    else
      Layout.rect(row: 9, col: 5, w: 2, h: 2, allscreen: true)
            .center
            .merge(label)
    end
  end

  def player_prefab player
    scale_perc = if death_at
                   Easing.smooth_stop(start_at: death_at, duration: 15, tick_count: Kernel.tick_count, power: 2)
                 else
                   Easing.smooth_start(start_at: started_at + 30, duration: 15, tick_count: Kernel.tick_count, power: 2, flip: true)
                 end

    player.merge(x: player.x + player.w / 2 * scale_perc,
                 y: player.y + player.h / 2 * scale_perc,
                 w: player.w * (1 - scale_perc),
                 h: player.h * (1 - scale_perc),
                 path: :solid,
                 **RED,
                 a: 255 * (1 - scale_perc))
  end

  # determines if score should be incremented or if the game should be over
  # this function generates the particles when the player is hit
  def generate_death_particles! all_squares
    # create a prefab for each square/set piece and queue them
    # up to fade out
    square_particles = square_prefabs(all_squares).map do |b|
      b.merge(start_at: Kernel.tick_count + 60, scale_speed: -1)
    end

    @scale_down_particles_queue.concat square_particles

    # use the starting player prefab and generate the explosion
    player_prefab_base = player_prefab(@game.player)

    # generate 12 particles with random size, launch angle and speed
    player_particles = 12.map do
      size = rand * @game.player.h * 0.5 + 10
      player_prefab_base.merge(w: size,
                               h: size,
                               a: 255,
                               launch_angle: rand * 180, speed: 10 + rand * 50,
                               path: :solid,
                               **RED)
    end

    @launch_particle_queue.concat player_particles
  end

  # death_at is the point in time that the player died
  # the death_at value is an intermediary variable that is used to calculate the death animation
  # before setting state.game_over_at
  def death_at
    return nil if !@game.death_at
    return nil if @game.death_at < started_at
    @game.death_at
  end

  # started_at is the point in time that the player started (or retried) the game
  def started_at
    state.events.game_retried_at || state.events.game_started_at
  end
end

# This class encapsulates the logic of a button that pulses when clicked.
# It is used in the StartScene and GameOverScene classes.
class PulseButton
  attr :rect, :text, :on_click, :clicked_at

  # a block is passed into the constructor and is called when the button is clicked,
  # and after the pulse animation is complete
  def initialize rect, text, &on_click
    @rect = rect
    @text = text
    @on_click = on_click
    @pulse_animation_spline = [[0.0, 0.90, 1.0, 1.0], [1.0, 0.10, 0.0, 0.0]]
    @animation_duration = 10
  end

  # the button is ticked every frame and check to see if the mouse
  # intersects the button's bounding box.
  # if it does, then pertinent information is stored in the @clicked_at variable
  # which is used to calculate the pulse animation
  def tick mouse
    if @clicked_at && @clicked_at.elapsed_time > @animation_duration
      @clicked_at = nil
      @on_click.call
    end

    mouse_rect = { x: mouse.x + Grid.allscreen_offset_x, y: mouse.y + Grid.allscreen_offset_y }
    return if !mouse.click
    return if !Geometry.inside_rect? mouse_rect, @rect
    @clicked_at = Kernel.tick_count
  end

  # this function returns an array of primitives that can be rendered
  def prefab
    # calculate the percentage of the pulse animation that has completed
    # and use the percentage to compute the size and position of the button
    perc = if @clicked_at
             Easing.spline @clicked_at, Kernel.tick_count, @animation_duration, @pulse_animation_spline
           else
             0
           end

    center = { x: @rect.x + @rect.w / 2, y: @rect.y + @rect.h / 2, anchor_x: 0.5, anchor_y: 0.5 }

    [
      { **center,
        w: @rect.w + 50 * perc,
        h: @rect.h + 50 * perc,
        path: :solid },
      { **center, text: @text, size_px: 32 }
    ]
  end
end
