# This sample app shows a more advanced implementation of scenes:
# 1. "Scene 1" has a label on it that says "I am scene ONE. Press enter to go to scene TWO."
# 2. "Scene 2" has a label on it that says "I am scene TWO. Press enter to go to scene ONE."
# 3. When the game starts, Scene 1 is presented.
# 4. When the player presses enter, the scene transitions to Scene 2 (fades out Scene 1 over half a second, then fades in Scene 2 over half a second).
# 5. When the player presses enter again, the scene transitions to Scene 1 (fades out Scene 2 over half a second, then fades in Scene 1 over half a second).
# 6. During the fade transitions, spamming the enter key is ignored (scenes don't accept a transition/respond to the enter key until the current transition is completed).
class SceneOne
  attr_gtk

  def tick
    outputs[:scene].labels << { x: 640,
                                y: 360,
                                text: "I am scene ONE. Press enter to go to scene TWO.",
                                alignment_enum: 1,
                                vertical_alignment_enum: 1 }

    state.next_scene = :scene_two if inputs.keyboard.key_down.enter
  end
end

class SceneTwo
  attr_gtk

  def tick
    outputs[:scene].labels << { x: 640,
                                y: 360,
                                text: "I am scene TWO. Press enter to go to scene ONE.",
                                alignment_enum: 1,
                                vertical_alignment_enum: 1 }

    state.next_scene = :scene_one if inputs.keyboard.key_down.enter
  end
end

class RootScene
  attr_gtk

  def initialize
    @scene_one = SceneOne.new
    @scene_two = SceneTwo.new
  end

  def tick
    defaults
    render
    tick_scene
  end

  def defaults
    set_current_scene! :scene_one if state.tick_count == 0
    state.scene_transition_duration ||= 30
  end

  def render
    a = if state.transition_scene_at
          255 * state.transition_scene_at.ease(state.scene_transition_duration, :flip)
        elsif state.current_scene_at
          255 * state.current_scene_at.ease(state.scene_transition_duration)
        else
          255
        end

    outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :scene, a: a }
  end

  def tick_scene
    current_scene = state.current_scene

    @current_scene.args = args
    @current_scene.tick

    if current_scene != state.current_scene
      raise "state.current_scene changed mid tick from #{current_scene} to #{state.current_scene}. To change scenes, set state.next_scene."
    end

    if state.next_scene && state.next_scene != state.transition_scene && state.next_scene != state.current_scene
      state.transition_scene_at = state.tick_count
      state.transition_scene = state.next_scene
    end

    if state.transition_scene_at && state.transition_scene_at.elapsed_time >= state.scene_transition_duration
      set_current_scene! state.transition_scene
    end

    state.next_scene = nil
  end

  def set_current_scene! id
    return if state.current_scene == id
    state.current_scene = id
    state.current_scene_at = state.tick_count
    state.transition_scene = nil
    state.transition_scene_at = nil

    if state.current_scene == :scene_one
      @current_scene = @scene_one
    elsif state.current_scene == :scene_two
      @current_scene = @scene_two
    end
  end
end

def tick args
  $game ||= RootScene.new
  $game.args = args
  $game.tick
end
