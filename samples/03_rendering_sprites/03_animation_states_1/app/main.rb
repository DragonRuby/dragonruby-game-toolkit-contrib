# this class encapsulates the Game and shows
# how to manage animations states. The components
# that control animation states are action, action_at, and Numeric.frame
class Game
  # expose player and enemies as public properties
  # from the Console you can see their values via $game.player and $game.enemies
  attr :player, :enemies

  # DragonRuby class macro that allows you to access inputs, outputs, state, etc
  # without passing args everywhere
  attr_dr

  def initialize
    # when the game is constructed, create the player at the center of the screen
    @player = {
      speed: 3,
      x: 640,
      y: 360,
      w: 64,
      h: 64,
      x_dir: 1, # the direction the player is facing
      action: :idle, # set the player's current action to :idle
      action_at: 0,  # set the player's action timestamp to 0
      action_lookup: { # frame data for each action
        # when player is standing still
        idle: {
          path: "sprites/horizontal-stand.png",
          hold_for: 3,
          frame_count: 1,
          repeat: true
        },
        # when player is moving
        run: {
          path: "sprites/horizontal-run.png",
          hold_for: 3,
          frame_count: 6,
          repeat: true
        },
        # when player is attacking
        slash: {
          path: "sprites/horizontal-slash.png",
          hold_for: 3,
          frame_count: 5,
          repeat: false
        }
      }
    }

    # collection of enemies
    @enemies = []
  end

  def player_current_action_lookup
    @player.action_lookup[@player.action]
  end

  def player_frame
    # get the frame data for the current action the player is in
    action_lookup = player_current_action_lookup

    # Numeric.frame returns the following hash
    # For example, this would be the frame data for performing an attack
    # {
    #   frame_index: 3,
    #   frame_count: 5,
    #   frames_left: 2,
    #   started: true,
    #   completed: false,
    #   duration: 15,
    #   elapsed_time: 10,
    #   frame_elapsed_time: 1
    # }
    Numeric.frame(start_at: @player.action_at,
                  frame_count: action_lookup.frame_count,
                  hold_for: action_lookup.hold_for,
                  repeat: action_lookup.repeat)
  end

  # function adds an enemy to the enemies collection
  def add_enemy
    @enemies << {
      x: 1200 * rand,
      y: 600 * rand,
      w: 64,
      h: 64,
      anchor_x: 0.5,
      anchor_y: 0.5,
    }
  end

  # return the sprite to display based on the players current action
  def player_prefab
    # first get the action frame data for the player's current action
    # the lookup contains the sprite to display
    lookup = player_current_action_lookup

    # then get the frame information
    frame = player_frame

    {
      x: @player.x,
      y: @player.y,
      w: 128,
      h: 128,
      path: lookup.path, # lookup path
      tile_x: 128 * frame.frame_index, # the pngs are tile sheets, so we offset the tile_x by the frame index
      tile_y: 0,
      tile_w: 128,
      tile_h: 128,
      anchor_x: 0.5,
      anchor_y: 0.5,
      flip_horizontally: @player.x_dir == 1
    }
  end

  # return the representation of an enemy (int this case it's just a solid box)
  def enemy_prefab enemy
    { **enemy, path: :solid, r: 0, g: 0, b: 0, a: 128 }
  end

  # this represents the rectang for the player's sword
  def player_slash_rect
    {
      x: player.x + player.x_dir * 40,
      y: player.y,
      w: 40,
      h: 20,
      anchor_x: 0.5,
      anchor_y: 0.5,
      path: :solid,
      r: 0, g: 0, b: 0
    }
  end

  # slash is requested if controller's A is pressed,
  # J is pressed on the keyboard,
  # or enter is pressed on the keyboard
  def player_slash_requested?
    inputs.controller_one.key_down.a ||
    inputs.keyboard.key_down.j       ||
    inputs.keyboard.key_down.enter
  end

  # the slash of the player can damage an enemy
  # when the animation first transitions to frame index 2
  def player_slash_can_damage?
    @player.action == :slash &&
    player_frame.frame_index == 2 &&
    player_frame.frame_elapsed_time == 0
  end

  def player_action! action
    # set the player action and the timestamp for the action
    # if the player isn't already in that action
    return if @player.action == action
    @player.action = action
    @player.action_at = Kernel.tick_count
  end

  def tick
    # if no enemies exist in the enemies collection,
    # add an enemy at a random location
    add_enemy if @enemies.length == 0

    # if slash is requested, then put the player in the :slash action
    if player_slash_requested?
      player_action! :slash
    end

    # if :slash is completed, then move the player back to idle
    if @player.action == :slash
      if player_frame.completed
        player_action! :idle
      end
    else
      # get the directional vector for the player
      vec = inputs.directional_vector

      # if WASD/arrow keys/DPAD is being activated
      if vec
        # increment player's x by the vector x multiplied by speed
        @player.x += @player.speed * vec.x

        # increment player's y by the vector y multiplied by speed
        @player.y += @player.speed * vec.y

        # set the player's facing direction equal to vec.x's sign if vec.x is not zero
        if vec.x != 0
          @player.x_dir = vec.x.sign
        end

        # set the player action to run
        player_action! :run
      else
        # if no directional vector is being pressed then set the player to idle
        player_action! :idle
      end
    end

    # if the player can damage an enemy
    if player_slash_can_damage?
      # delete all enemies that intersect with the player's sword
      @enemies.reject! { |e| Geometry.intersect_rect? e, player_slash_rect }
    end

    outputs.watch "player action: #{@player.action}: #{@player.action_at}"
    outputs.watch "player frame data: #{pretty_format player_frame}"

    # render the player, they sword collision rect, and enemies
    outputs.primitives << player_slash_rect
    outputs.primitives << player_prefab
    outputs.primitives << @enemies.map { |e| enemy_prefab e }
  end
end

def boot args
  args.state = {}
end

def tick args
  # new up the game if it hasn't been initialized
  $game ||= Game.new
  # set args on the game
  $game.args = args
  # run tick
  $game.tick
end

# if reset is called, then set the game to nil so that it can be initialized again
def reset args
  $game = nil
end

DR.reset
