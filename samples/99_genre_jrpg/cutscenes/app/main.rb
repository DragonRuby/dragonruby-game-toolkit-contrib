# creation of a game class
class Game
  attr_gtk # adds arg properties to the class

  def initialize
    # have the hero start at the center and the npc be at the far right
    @hero = { x: 640,
              y: 360,
              w: 80,
              h: 80,
              look_dir: { x: 1, y: 0 },
              anchor_x: 0.5,
              anchor_y: 0.5,
              path: "sprites/square/blue.png" }

    @npc = { x: 1000,
             y: 360,
             w: 80,
             h: 80,
             anchor_x: 0.5,
             anchor_y: 0.5,
             path: "sprites/square/red.png" }

    # queue for cutscene actions
    @cutscene = []
  end

  def hero_look_angle
    # given the vector the player is looking at, return an angle
    Geometry.vec2_angle(@hero.look_dir)
  end

  def hero_interaction_box
    # calculate the interaction hit box for the player based off of where they are looking
    @hero.intersect_box = { x: @hero.x + @hero.w / 2 * hero_look_angle.vector_x,
                            y: @hero.y + @hero.h / 2 * hero_look_angle.vector_y,
                            w: 80,
                            h: 80,
                            anchor_x: 0.5,
                            anchor_y: 0.5 }
  end

  def tick
    calc
    render
  end

  def calc
    tick_cutscene

    # if a cutscene isn't currently play, then return control to the player
    if !in_cutscene?
      calc_facing
      calc_movement
      calc_interaction
    end
  end

  def tick_cutscene
    # if the cutscene array is empty then skip
    return if @cutscene.length == 0

    # loop through all the cutscene items and compute the start_at and end_at times
    # based off of the relative frame timings
    @cutscene.each do |scene|
      scene.start_at ||= scene.frame_start_at + Kernel.tick_count
      scene.end_at   ||= scene.frame_end_at + Kernel.tick_count
    end

    # get all cutscene actions that are active
    scenes_to_tick = @cutscene.find_all { |scene| scene.start_at <= Kernel.tick_count }

    # for each of those actions, run them
    scenes_to_tick.each { |scene| scene.run.call }

    # remove any actions that have completed
    @cutscene.reject! { |scene| scene.end_at <= Kernel.tick_count }
  end

  def calc_interaction
    # return if the player hasn't pressed a on the controller or space on the keyboard
    return if !interaction_requested?

    # if interaction is requested and the hero's interaction box
    # intersects with the npc, then queue cutscene actions
    if Geometry.intersect_rect?(hero_interaction_box, @npc)
      @cutscene = [
        # from frame 1 to 60 (over one second), have the npc move up
        { frame_start_at: 0, frame_end_at:  60, run: lambda { @npc.y += 5  } },
        # from frame 60 to 120, have the hero move down
        { frame_start_at: 60, frame_end_at: 120, run: lambda { @hero.y -= 5 } },
        # then move both back at the same time
        { frame_start_at: 120, frame_end_at: 180, run: lambda { @npc.y -= 5  } },
        { frame_start_at: 120, frame_end_at: 180, run: lambda { @hero.y += 5  } },
      ]
    end
  end

  def interaction_requested?
    inputs.controller_one.key_down.a || inputs.keyboard.key_down.space
  end

  # you are considered to be in a cutscene
  def in_cutscene?
    @cutscene && !@cutscene.empty?
  end

  def calc_facing
    # compute the direction the player is facing based off of input
    # the direction the player is facing only changes if only one
    # key is down between up, down, left, and right
    return if inputs.left_right != 0 && inputs.up_down != 0
    @hero.look_dir = { x: inputs.left_right, y: inputs.up_down }
  end

  def calc_movement
    # axis aligned bounding box movement (player can't overlap with the npc)o

    # first set the hero's x location based off of horizontal movement
    # we use the &.x safe operation because directional vector will return
    # nil if there is no directional input
    # this horizontal movement vector is multipled by 5 which represents
    # the player's speed
    @hero.x += (inputs.directional_vector&.x || 0) * 5

    # after the player is moved, check collision on the horizontal plane (standard AABB processing)
    if Geometry.intersect_rect?(@hero, @npc)
      if @hero.x < @npc.x
        @hero.x = @npc.x - @hero.w
      else
        @hero.x = @npc.x + @hero.w
      end
    end

    # now do the same for the player movement on the vertical access
    @hero.y += (inputs.controller_one.directional_vector&.y || 0) * 5

    if Geometry.intersect_rect?(@hero, @npc)
      if @hero.y < @npc.y
        @hero.y = @npc.y - @hero.h
      else
        @hero.y = @npc.y + @hero.h
      end
    end
  end

  def render
    # render the player, player's interaction box, npc, and instructions
    outputs.primitives << hero_interaction_box.merge(path: :solid, r: 255, g: 0, b: 0)
    outputs.primitives << @hero.merge(angle: hero_look_angle)
    outputs.primitives << @npc
    outputs.primitives << { x: 640,
                            y: 640,
                            text: "Interact with NPC to start cutscene",
                            anchor_x: 0.5,
                            anchor_y: 0.5,
                            size_px: 26 }
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

GTK.reset
