class Game
  attr_gtk

  def initialize
    @player = {
      x: 0,
      y: 0,
      w: 32,
      h: 32,
      anchor_x: 0.5,
      anchor_y: 0.5,
      path: "sprites/square/blue.png",
    }

    @terrain = 20.map do
      { x: 32 * Numeric.rand(-10..10) - 16,
        y: 32 * Numeric.rand(-10..10) - 16,
        w: 32,
        h: 32,
        anchor_x: 0.5,
        anchor_y: 0.5,
        path: "sprites/square/green.png",}
    end

    @camera = {
      target_x: 0,
      target_y: 0,
      target_scale: 1,
      target_pan_offset_x: 0,
      target_pan_offset_y: 0,
      x: 0,
      y: 0,
      scale: 1,
    }
  end

  def tick
    update_matrices!
    @mouse_in_world = point_to_world_space(inputs.mouse.x, inputs.mouse.y)
    @player.dx = inputs.left_right * 5
    @player.x += @player.dx
    if inputs.left_right != 0 || inputs.up_down != 0
      @camera.target_x = @player.x
      @camera.target_y = @player.y
    end

    @player.dy = inputs.up_down * 5
    @player.y += @player.dy

    if inputs.keyboard.key_down.minus
      @camera.target_scale *= 0.9
    elsif inputs.keyboard.key_down.equal
      @camera.target_scale *= 1.1
    end

    if inputs.mouse.buffered_held && inputs.mouse.moved
      @camera.target_x = @camera.target_x + (inputs.mouse.previous_x - inputs.mouse.x) / @camera.scale
      @camera.target_y = @camera.target_y + (inputs.mouse.previous_y - inputs.mouse.y) / @camera.scale
    end

    if inputs.mouse.wheel
      zoom_delta = inputs.mouse.wheel.y.clamp(-10, 10) * 0.1 * -1 * @camera.scale.lerp(@camera.target_scale, 0.1)
      next_scale = (@camera.scale + zoom_delta).clamp(0.1, 10.0)
      next_camera = { x: @camera.target_x,
                      y: @camera.target_y,
                      scale: next_scale }

      next_world_matrix = world_matrix next_camera
      world_point = point_mul(inputs.mouse.rect.x, inputs.mouse.rect.y, next_world_matrix)

      diff_x = world_point.x - @mouse_in_world.x
      diff_y = world_point.y - @mouse_in_world.y

      @camera.target_scale = next_scale
      @camera.target_x -= diff_x
      @camera.target_y -= diff_y
    end

    @camera.x = @camera.x.lerp(@camera.target_x, 0.1)
    @camera.y = @camera.y.lerp(@camera.target_y, 0.1)
    @camera.scale = @camera.scale.lerp(@camera.target_scale, 0.1)

    render
  end

  def world_matrix camera
    Matrix.mul(mat3_scale(1.0 / camera.scale), mat3_translate(camera.x, camera.y))
  end

  def camera_matrix camera
    Matrix.mul(mat3_translate(-camera.x, -camera.y), mat3_scale(camera.scale))
  end

  def update_matrices!
    @camera_matrix = camera_matrix @camera
    @world_matrix = world_matrix @camera
  end

  def render
    outputs.watch GTK.current_framerate
    outputs.watch "#{@mouse_in_world.x}, #{@mouse_in_world.y}"
    outputs[:scene].w = Grid.allscreen_w
    outputs[:scene].h = Grid.allscreen_h
    outputs[:scene].background_color = [0, 0, 0]
    outputs[:scene].primitives << to_camera_space(@player)

    outputs[:scene].primitives << @terrain.map do |t|
      to_camera_space(t)
    end

    outputs.primitives << { x: 0, y: 0, w: Grid.allscreen_w, h: Grid.allscreen_h, path: :scene, anchor_x: 0.5, anchor_y: 0.5 }

    outputs.lines << { x: 0, y: -360, h: 720, r: 255, g: 255, b: 255 }
    outputs.lines << { x: -640, y: 0, w: 1280, r: 255, g: 255, b: 255 }
  end

  def point_mul x, y, m
    r = Matrix.mul(Matrix.vec3(x, y, 1), m)
    { x: r.x, y: r.y }
  end

  def point_to_world_space x, y
    point_mul x, y, @world_matrix
  end

  def point_to_camera_space x, y
    projection = Matrix.mul(Matrix.vec3(x, y, 1), @camera_matrix)
    { x: projection.x, y: projection.y }
  end

  def to_world_space rect
    projection_bottom_left = point_to_world_space(rect.x, rect.y)
    projection_top_right = Matrix.mul(Matrix.vec3(rect.x + rect.w, rect.y + rect.h, 1),
                                      @world_matrix)

    rect.merge x: projection_bottom_left.x,
               y: projection_bottom_left.y,
               w: Geometry.distance(projection_bottom_left, projection_top_right),
               h: Geometry.distance(projection_bottom_left, projection_top_right)
  end

  def to_camera_space rect
    projection_bottom_left = point_to_camera_space(rect.x, rect.y)
    projection_top_right = point_to_camera_space(rect.x + rect.w, rect.y + rect.h)

    rect.merge x: projection_bottom_left.x,
               y: projection_bottom_left.y,
               w: Geometry.distance(projection_bottom_left, projection_top_right),
               h: Geometry.distance(projection_bottom_left, projection_top_right)
  end

  def mat3_translate x, y
    Matrix.mat3 1, 0, x,
                0, 1, y,
                0, 0, 1
  end

  def mat3_scale s
    Matrix.mat3 s, 0, 0,
                0, s, 0,
                0, 0, 1
  end

  def mat3_rotate t
    Matrix.mat3 Math.cos(t), -Math.sin(t), 0,
                Math.sin(t), Math.cos(t), 0,
                0, 0, 1
  end
end

def boot args
  args.state = {}
  Grid.origin_center!
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
