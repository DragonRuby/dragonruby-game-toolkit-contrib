# representation of a game that has a healing mechanic
class Game
  # game has access to args and hp
  attr :args, :hp

  # initialize game with 100 hp
  def initialize
    @hp = 100
  end

  # take damage function that reduces hp
  def take_damage
    @hp -= 10
  end

  # heal function that increases hp
  def heal
    @hp += 10
  end

  # game over if hp <= 0
  def dead?
    @hp <= 0
  end

  # resets the game from the start
  def restart
    @hp = 100
  end
end

# scene that represents game over
class GameOverScene
  # property reference to game and args
  attr :game, :args

  # initialize scene with game reference
  def initialize game
    @game = game
  end

  # id for scene lookup
  def id
    :game_over_scene
  end

  # main tick function for scene
  def tick
    # click to restart game
    if args.inputs.mouse.click
      # mark the game as restarted
      @game.restart

      # set the scene to be the heal scene
      args.state.next_scene = :heal_scene
    end

    # render label with instructions
    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "Game Over. Click to restart.",
                             anchor_x: 0.5,
                             anchor_y: 0.5 }
  end
end

# scene that represents healing
class HealScene
  # property reference to game and args
  attr :game, :args

  # initialize scene with game reference
  def initialize game
    @game = game
  end

  # id for scene lookup
  def id
    :heal_scene
  end

  # main tick function for scene
  def tick
    # if mouse is clicked, go to the damage scene
    if args.inputs.click
      args.state.next_scene = :damage_scene
    end

    # if enter is pressed, heal
    if args.inputs.keyboard.key_down.enter
      @game.heal
    end

    # render instructions and current hp
    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "I am Heal Scene. Click to go to Damage Scene. Press enter to Heal.",
                             anchor_x: 0.5,
                             anchor_y: 0.5 }

    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "Current HP: #{@game.hp}",
                             anchor_x: 0.5,
                             anchor_y: 1.5 }
  end
end

# scene that represents damage
class DamageScene
  # property reference to game and args
  attr :game, :args

  # initialize scene with game reference
  def initialize game
    @game = game
  end

  # id for scene lookup
  def id
    :damage_scene
  end

  # main tick function for scene
  def tick
    # if mouse is clicked, go to heal scene
    if args.inputs.click
      args.state.next_scene = :heal_scene
    end

    # if enter is pressed, take damage
    if args.inputs.keyboard.key_down.enter
      @game.take_damage
    end

    # if the player is dead, go to the game over scene
    if @game.dead?
      args.state.next_scene = :game_over_scene
    end

    # render instructions and current hp
    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "I am Damage Scene. Click to go to Heal Scene. Press enter to Take Damage.",
                             anchor_x: 0.5,
                             anchor_y: 0.5 }

    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "Current HP: #{@game.hp}",
                             anchor_x: 0.5,
                             anchor_y: 1.5 }
  end
end

# root scene holds game and all other scenes
class RootScene
  # property reference to game and args
  attr :args, :game

  # initialize the root scene with game and all scenes
  def initialize
    @game = Game.new
    @heal_scene = HealScene.new @game
    @damage_scene = DamageScene.new @game
    @game_over_scene = GameOverScene.new @game
    @scenes = [@heal_scene, @damage_scene, @game_over_scene]
  end

  # set the starting state to the heal
  def defaults
    args.state.scene ||= :heal_scene
  end

  # top level tick function
  def tick
    # initialize defaults
    defaults

    # we want to make sure that scene transitions happen at the end
    # (you never want to swap scenes mid-tick since it makes things hard to debug)
    scene_before_tick = args.state.scene

    # get the current scene that should be ticked
    scene = get_current_scene
    # set that scene's args reference
    scene.args = args
    # invoke tick on the scene
    scene.tick

    # check to make sure that the current scene wasn't changed within the tick
    if args.state.scene != scene_before_tick
      raise "Do not change the scene mid tick, set state.next_scene"
    end

    # check to see if next scene was set, and if so do the scene transition here
    if args.state.next_scene
      args.state.scene = args.state.next_scene
      args.state.next_scene = nil
    end
  end

  # function is used to find the current scene that should be ticked
  def get_current_scene
    # each scene has a scene id, we use args.state.scene to search for the
    # correct scene to call tick on
    scene = @scenes.find { |scene| scene.id == args.state.scene }
    # raise an error if no scene was found
    raise "Scene with id #{args.state.scene} does not exist." if !scene

    # return the scene that was found
    scene
  end
end

# entry point
def tick args
  # set root scene if it isn't initialized, set args, and invoke tick
  $root_scene ||= RootScene.new
  $root_scene.args = args
  $root_scene.tick
end

# reset method that clears out root scene
def reset args
  $root_scene = nil
end

GTK.reset
