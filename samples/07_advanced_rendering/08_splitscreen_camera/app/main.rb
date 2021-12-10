class CameraMovement
  attr_accessor :state, :inputs, :outputs, :grid

  #==============================================================================================
  #Serialize
  def serialize
    {state: state, inputs: inputs, outputs: outputs, grid: grid }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  #==============================================================================================
  #Tick
  def tick
    defaults
    calc
    render
    input
  end

  #==============================================================================================
  #Default functions
  def defaults
    outputs[:scene].background_color = [0,0,0]
    state.trauma ||= 0.0
    state.trauma_power ||= 2
    state.player_cyan ||= new_player_cyan
    state.player_magenta ||= new_player_magenta
    state.camera_magenta ||= new_camera_magenta
    state.camera_cyan ||= new_camera_cyan
    state.camera_center ||= new_camera_center
    state.room ||= new_room
  end

  def default_player x, y, w, h, sprite_path
    state.new_entity(:player,
                     { x: x,
                       y: y,
                       dy: 0,
                       dx: 0,
                       w: w,
                       h: h,
                       damage: 0,
                       dead: false,
                       orientation: "down",
                       max_alpha: 255,
                       sprite_path: sprite_path})
  end

  def default_floor_tile x, y, w, h, sprite_path
    state.new_entity(:room,
                     { x: x,
                       y: y,
                       w: w,
                       h: h,
                       sprite_path: sprite_path})
  end

  def default_camera x, y, w, h
    state.new_entity(:camera,
                     { x: x,
                       y: y,
                       dx: 0,
                       dy: 0,
                       w: w,
                       h: h})
  end

  def new_player_cyan
    default_player(0, 0, 64, 64,
                   "sprites/player/player_#{state.player_cyan.orientation}_standing.png")
  end

  def new_player_magenta
    default_player(64, 0, 64, 64,
                   "sprites/player/player_#{state.player_magenta.orientation}_standing.png")
  end

  def new_camera_magenta
    default_camera(0,0,720,720)
  end

  def new_camera_cyan
    default_camera(0,0,720,720)
  end

  def new_camera_center
    default_camera(0,0,1280,720)
  end


  def new_room
    default_floor_tile(0,0,1024,1024,'sprites/rooms/camera_room.png')
  end

  #==============================================================================================
  #Calculation functions
  def calc
    calc_camera_magenta
    calc_camera_cyan
    calc_camera_center
    calc_player_cyan
    calc_player_magenta
    calc_trauma_decay
  end

  def center_camera_tolerance
    return Math.sqrt(((state.player_magenta.x - state.player_cyan.x) ** 2) +
              ((state.player_magenta.y - state.player_cyan.y) ** 2)) > 640
  end

  def calc_player_cyan
    state.player_cyan.x += state.player_cyan.dx
    state.player_cyan.y += state.player_cyan.dy
  end

  def calc_player_magenta
    state.player_magenta.x += state.player_magenta.dx
    state.player_magenta.y += state.player_magenta.dy
  end

  def calc_camera_center
    timeScale = 1
    midX = (state.player_magenta.x + state.player_cyan.x)/2
    midY = (state.player_magenta.y + state.player_cyan.y)/2
    targetX = midX - state.camera_center.w/2
    targetY = midY - state.camera_center.h/2
    state.camera_center.x += (targetX - state.camera_center.x) * 0.1 * timeScale
    state.camera_center.y += (targetY - state.camera_center.y) * 0.1 * timeScale
  end


  def calc_camera_magenta
    timeScale = 1
    targetX = state.player_magenta.x + state.player_magenta.w - state.camera_magenta.w/2
    targetY = state.player_magenta.y + state.player_magenta.h - state.camera_magenta.h/2
    state.camera_magenta.x += (targetX - state.camera_magenta.x) * 0.1 * timeScale
    state.camera_magenta.y += (targetY - state.camera_magenta.y) * 0.1 * timeScale
  end

  def calc_camera_cyan
    timeScale = 1
    targetX = state.player_cyan.x + state.player_cyan.w - state.camera_cyan.w/2
    targetY = state.player_cyan.y + state.player_cyan.h - state.camera_cyan.h/2
    state.camera_cyan.x += (targetX - state.camera_cyan.x) * 0.1 * timeScale
    state.camera_cyan.y += (targetY - state.camera_cyan.y) * 0.1 * timeScale
  end

  def calc_player_quadrant angle
    if angle < 45 and angle > -45 and state.player_cyan.x < state.player_magenta.x
      return 1
    elsif angle < 45 and angle > -45 and state.player_cyan.x > state.player_magenta.x
      return 3
    elsif (angle > 45 or angle < -45) and state.player_cyan.y < state.player_magenta.y
      return 2
    elsif (angle > 45 or angle < -45) and state.player_cyan.y > state.player_magenta.y
      return 4
    end
  end

  def calc_camera_shake
    state.trauma
  end

  def calc_trauma_decay
    state.trauma = state.trauma * 0.9
  end

  def calc_random_float_range(min, max)
    rand * (max-min) + min
  end

  #==============================================================================================
  #Render Functions
  def render
    render_floor
    render_player_cyan
    render_player_magenta
    if center_camera_tolerance
      render_split_camera_scene
    else
      render_camera_center_scene
    end
  end

  def render_player_cyan
    outputs[:scene].sprites << {x: state.player_cyan.x,
                                y: state.player_cyan.y,
                                w: state.player_cyan.w,
                                h: state.player_cyan.h,
                                path: "sprites/player/player_#{state.player_cyan.orientation}_standing.png",
                                r: 0,
                                g: 255,
                                b: 255}
  end

  def render_player_magenta
    outputs[:scene].sprites << {x: state.player_magenta.x,
                                y: state.player_magenta.y,
                                w: state.player_magenta.w,
                                h: state.player_magenta.h,
                                path: "sprites/player/player_#{state.player_magenta.orientation}_standing.png",
                                r: 255,
                                g: 0,
                                b: 255}
  end

  def render_floor
    outputs[:scene].sprites << [state.room.x, state.room.y,
                                state.room.w, state.room.h,
                                state.room.sprite_path]
  end

  def render_camera_center_scene
    zoomFactor = 1
    outputs[:scene].width = state.room.w
    outputs[:scene].height = state.room.h

    maxAngle = 10.0
    maxOffset = 20.0
    angle = maxAngle * calc_camera_shake * calc_random_float_range(-1,1)
    offsetX = 32 - (maxOffset * calc_camera_shake * calc_random_float_range(-1,1))
    offsetY = 32 - (maxOffset * calc_camera_shake * calc_random_float_range(-1,1))

    outputs.sprites << {x: (-state.camera_center.x - offsetX)/zoomFactor,
                        y: (-state.camera_center.y - offsetY)/zoomFactor,
                        w: outputs[:scene].width/zoomFactor,
                        h: outputs[:scene].height/zoomFactor,
                        path: :scene,
                        angle: angle,
                        source_w: -1,
                        source_h: -1}
    outputs.labels << [128,64,"#{state.trauma.round(1)}",8,2,255,0,255,255]
  end

  def render_split_camera_scene
     outputs[:scene].width = state.room.w
     outputs[:scene].height = state.room.h
     render_camera_magenta_scene
     render_camera_cyan_scene

     angle = Math.atan((state.player_magenta.y - state.player_cyan.y)/(state.player_magenta.x- state.player_cyan.x)) * 180/Math::PI
     output_split_camera angle

  end

  def render_camera_magenta_scene
     zoomFactor = 1
     offsetX = 32
     offsetY = 32

     outputs[:scene_magenta].sprites << {x: (-state.camera_magenta.x*2),
                                         y: (-state.camera_magenta.y),
                                         w: outputs[:scene].width*2,
                                         h: outputs[:scene].height,
                                         path: :scene}

  end

  def render_camera_cyan_scene
    zoomFactor = 1
    offsetX = 32
    offsetY = 32
    outputs[:scene_cyan].sprites << {x: (-state.camera_cyan.x*2),
                                     y: (-state.camera_cyan.y),
                                     w: outputs[:scene].width*2,
                                     h: outputs[:scene].height,
                                     path: :scene}
  end

  def output_split_camera angle
    #TODO: Clean this up!
    quadrant = calc_player_quadrant angle
    outputs.labels << [128,64,"#{quadrant}",8,2,255,0,255,255]
    if quadrant == 1
      set_camera_attributes(w: 640, h: 720, m_x: 640, m_y: 0, c_x: 0, c_y: 0)

    elsif quadrant == 2
      set_camera_attributes(w: 1280, h: 360, m_x: 0, m_y: 360, c_x: 0, c_y: 0)

    elsif quadrant == 3
      set_camera_attributes(w: 640, h: 720, m_x: 0, m_y: 0, c_x: 640, c_y: 0)

    elsif quadrant == 4
      set_camera_attributes(w: 1280, h: 360, m_x: 0, m_y: 0, c_x: 0, c_y: 360)

    end
  end

  def set_camera_attributes(w: 0, h: 0, m_x: 0, m_y: 0, c_x: 0, c_y: 0)
    state.camera_cyan.w = w + 64
    state.camera_cyan.h = h + 64
    outputs[:scene_cyan].width = (w) * 2
    outputs[:scene_cyan].height = h

    state.camera_magenta.w = w + 64
    state.camera_magenta.h = h + 64
    outputs[:scene_magenta].width = (w) * 2
    outputs[:scene_magenta].height = h
    outputs.sprites << {x: m_x,
                        y: m_y,
                        w: w,
                        h: h,
                        path: :scene_magenta}
    outputs.sprites << {x: c_x,
                        y: c_y,
                        w: w,
                        h: h,
                        path: :scene_cyan}
  end

  def add_trauma amount
    state.trauma = [state.trauma + amount, 1.0].min
  end

  def remove_trauma amount
    state.trauma = [state.trauma - amount, 0.0].max
  end
  #==============================================================================================
  #Input functions
  def input
    input_move_cyan
    input_move_magenta

    if inputs.keyboard.key_down.t
      add_trauma(0.5)
    elsif inputs.keyboard.key_down.y
      remove_trauma(0.1)
    end
  end

  def input_move_cyan
    if inputs.keyboard.key_held.up
      state.player_cyan.dy = 5
      state.player_cyan.orientation = "up"
    elsif inputs.keyboard.key_held.down
      state.player_cyan.dy = -5
      state.player_cyan.orientation = "down"
    else
      state.player_cyan.dy *= 0.8
    end
    if inputs.keyboard.key_held.left
      state.player_cyan.dx = -5
      state.player_cyan.orientation = "left"
    elsif inputs.keyboard.key_held.right
      state.player_cyan.dx = 5
      state.player_cyan.orientation = "right"
    else
      state.player_cyan.dx *= 0.8
    end

    outputs.labels << [128,512,"#{state.player_cyan.x.round()}",8,2,0,255,255,255]
    outputs.labels << [128,480,"#{state.player_cyan.y.round()}",8,2,0,255,255,255]
  end

  def input_move_magenta
    if inputs.keyboard.key_held.w
      state.player_magenta.dy = 5
      state.player_magenta.orientation = "up"
    elsif inputs.keyboard.key_held.s
      state.player_magenta.dy = -5
      state.player_magenta.orientation = "down"
    else
      state.player_magenta.dy *= 0.8
    end
    if inputs.keyboard.key_held.a
      state.player_magenta.dx = -5
      state.player_magenta.orientation = "left"
    elsif inputs.keyboard.key_held.d
      state.player_magenta.dx = 5
      state.player_magenta.orientation = "right"
    else
      state.player_magenta.dx *= 0.8
    end

    outputs.labels << [128,360,"#{state.player_magenta.x.round()}",8,2,255,0,255,255]
    outputs.labels << [128,328,"#{state.player_magenta.y.round()}",8,2,255,0,255,255]
  end
end

$camera_movement = CameraMovement.new

def tick args
  args.outputs.background_color = [0,0,0]
  $camera_movement.inputs  = args.inputs
  $camera_movement.outputs = args.outputs
  $camera_movement.state   = args.state
  $camera_movement.grid    = args.grid
  $camera_movement.tick
end
