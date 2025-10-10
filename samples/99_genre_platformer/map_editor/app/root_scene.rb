class RootScene
  attr_gtk

  attr :level_editor

  def initialize args
    @level_editor = LevelEditor.new
  end

  def tick
    args.outputs.background_color = [0, 0, 0]
    args.state.terrain ||= []
    @level_editor.load_terrain args if Kernel.tick_count == 0

    state.player ||= {
      x: 0,
      y: 750,
      w: 16,
      h: 16,
      dy: 0,
      dx: 0,
      on_ground: false,
      path: "sprites/1-bit-platformer/0280.png"
    }

    if inputs.keyboard.left
      player.dx = -3
    elsif inputs.keyboard.right
      player.dx = 3
    end

    if inputs.keyboard.key_down.space && player.on_ground
      player.dy = 10
      player.on_ground = false
    end

    if args.inputs.keyboard.key_down.equal_sign || args.inputs.keyboard.key_down.plus
      state.camera.target_scale += 0.25
    elsif args.inputs.keyboard.key_down.minus
      state.camera.target_scale -= 0.25
      state.camera.target_scale = 0.25 if state.camera.target_scale < 0.25
    elsif args.inputs.keyboard.zero
      state.camera.target_scale = 1
    end

    state.gravity ||= 0.25
    calc_camera
    calc_physics
    outputs[:scene].w = Camera.viewport_w
    outputs[:scene].h = Camera.viewport_h
    outputs[:scene].background_color = [0, 0, 0, 0]
    outputs[:scene].lines << { x: 0, y: 0, x2: Camera.viewport_w, y2: Camera.viewport_h, r: 255, g: 255, b: 255, a: 255 }
    outputs[:scene].lines << { x: 0, y: Camera.viewport_h, x2: Camera.viewport_w, y2: 0, r: 255, g: 255, b: 255, a: 255 }

    terrain_to_render = Camera.find_all_intersect_viewport(state.camera, state.terrain)
    outputs[:scene].sprites << terrain_to_render.map do |m|
      Camera.to_screen_space(state.camera, m)
    end

    outputs[:scene].sprites << player_prefab

    outputs.sprites << { **Camera.viewport, path: :scene }

    @level_editor.args = args
    @level_editor.tick

    outputs.labels << { x: 640,
                        y: 30.from_top,
                        anchor_x: 0.5,
                        text: "WASD: move around. SPACE: jump. +/-: Zoom in and out. MOUSE: select tile/edit map (hold X and CLICK to delete).",
                        r: 255,
                        g: 255,
                        b: 255 }
  end

  def calc_camera
    state.world_size ||= 1280

    if !state.camera
      state.camera = {
        x: 0,
        y: 0,
        target_x: 0,
        target_y: 0,
        target_scale: 2,
        scale: 1
      }
    end

    ease = 0.1
    state.camera.scale += (state.camera.target_scale - state.camera.scale) * ease
    state.camera.target_x = player.x
    state.camera.target_y = player.y

    state.camera.x += (state.camera.target_x - state.camera.x) * ease
    state.camera.y += (state.camera.target_y - state.camera.y) * ease
  end

  def calc_physics
    player.x += player.dx
    collision = state.terrain.find do |t|
      t.intersect_rect?(player) && t.has_collision
    end

    if collision
      if player.dx > 0
        player.x = collision.x - player.w
      else
        player.x = collision.x + collision.w
      end

      player.dx = 0
    end

    player.dx *= 0.8
    if player.dx.abs < 0.5
      player.dx = 0
    end

    player.y += player.dy
    player.on_ground = false

    collision = state.terrain.find do |t|
      t.intersect_rect?(player) && t.has_collision
    end

    if collision
      if player.dy > 0
        player.y = collision.y - player.h
      else
        player.y = collision.y + collision.h
        player.on_ground = true
      end
      player.dy = 0
    end

    player.dy -= state.gravity

    if (player.y + player.h) < -750
      player.y = 750
      player.dy = 0
    end
  end

  def player
    state.player
  end

  def player_prefab
    prefab = Camera.to_screen_space state.camera, (player.merge path: "sprites/1-bit-platformer/0280.png")

    if !player.on_ground
      prefab.merge! path: "sprites/1-bit-platformer/0284.png"
      if player.dx > 0
        prefab.merge! flip_horizontally: false
      elsif player.dx < 0
        prefab.merge! flip_horizontally: true
      end
    elsif player.dx > 0
      frame_index = 0.frame_index 3, 5, true
      prefab.merge! path: "sprites/1-bit-platformer/028#{frame_index + 1}.png"
    elsif player.dx < 0
      frame_index = 0.frame_index 3, 5, true
      prefab.merge! path: "sprites/1-bit-platformer/028#{frame_index + 1}.png", flip_horizontally: true
    end

    prefab
  end

  def camera
    state.camera
  end

  def should_update_matricies?
    player.dx != 0 || player.dy != 0
  end
end
