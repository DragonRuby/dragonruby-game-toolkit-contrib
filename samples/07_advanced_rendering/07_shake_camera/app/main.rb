# Demo of camera shake
# Hold space to shake and release to stop

class ScreenShake
  attr_gtk

  def tick
    defaults
    calc_camera

    outputs.labels << { x: 600, y: 400, text: "Hold Space!" }

    # Add outputs to :scene
    outputs[:scene].sprites << { x: 100, y: 100,          w: 80, h: 80, path: 'sprites/square/blue.png' }
    outputs[:scene].sprites << { x: 200, y: 300.from_top, w: 80, h: 80, path: 'sprites/square/blue.png' }
    outputs[:scene].sprites << { x: 900, y: 200,          w: 80, h: 80, path: 'sprites/square/blue.png' }

    # Describe how to render :scene
    outputs.sprites << { x: 0 - state.camera.x_offset,
                         y: 0 - state.camera.y_offset,
                         w: 1280,
                         h: 720,
                         angle: state.camera.angle,
                         path: :scene }
  end

  def defaults
    state.camera.trauma ||= 0
    state.camera.angle ||= 0
    state.camera.x_offset ||= 0
    state.camera.y_offset ||= 0
  end

  def calc_camera
    if inputs.keyboard.key_held.space
      state.camera.trauma += 0.02
    end

    next_camera_angle = 180.0 / 20.0 * state.camera.trauma**2
    next_offset       = 100.0 * state.camera.trauma**2

    # Ensure that the camera angle always switches from
    # positive to negative and vice versa
    # which gives the effect of shaking back and forth
    state.camera.angle = state.camera.angle > 0 ?
                           next_camera_angle * -1 :
                           next_camera_angle

    state.camera.x_offset = next_offset.randomize(:sign, :ratio)
    state.camera.y_offset = next_offset.randomize(:sign, :ratio)

    # Gracefully degrade trauma
    state.camera.trauma *= 0.95
  end
end

def tick args
  $screen_shake ||= ScreenShake.new
  $screen_shake.args = args
  $screen_shake.tick
end
