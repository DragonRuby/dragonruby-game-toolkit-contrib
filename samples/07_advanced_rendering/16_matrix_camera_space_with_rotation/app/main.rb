# sample app shows how to create a camera that rotates, zooms in, and zooms out
# W to move forward, A to strafe left, D to strafe right
# Q to turn left, E to turn right

# Top level game with attr_gtk macro so we're not having to pass args everywhere
class Game
  attr_gtk

  def initialize
    # on initialization put the player in the center of the world
    # and generate 20 pieces of terrain
    @player = { x: 30,
                y: -16,
                w: 32,
                h: 32,
                dx: 0,
                dy: 0,
                path: "sprites/square/blue.png",
                rotation: 90.to_radians }

    @terrain = 20.map do
      { x: 32 * Numeric.rand(-10..10) - 16,
        y: 32 * Numeric.rand(-10..10) - 16,
        w: 32,
        h: 32,
        path: "sprites/square/green.png",}
    end

    # for collision, we are going to use circles (simpler than polygon collision with arbitrary rotation)
    @terrain.each do |t|
      t.hit_circ = { x: t.x + t.w / 2,
                     y: t.y + t.h / 2,
                     radius: (t.w / 2) * 1.5 }
    end

    # remove any terrain that intersects with the player (don't want to be stuck in a wall)
    @terrain.reject! { |t| Geometry.intersect_circle?(player_hit_circ, t.hit_circ) }

    # location of the camera, rotation is represented in radians
    @camera = { x: 0, y: 0, scale: 1, rotation: 0 }
  end

  # helper method that gives the player's circle collision shape
  def player_hit_circ
    { x: @player.x + @player.w / 2,
      y: @player.y + @player.h / 2,
      radius: @player.w / 2 }
  end

  # calc function handles collisions and input
  def calc
    # partition the collision logic into quarter steps
    # basically we are processing collision at 240 hz
    4.times do
      # take the keyboard input, and strafe input
      @player.dx = (inputs.directional_vector&.y || 0) * 5 * Math.cos(@player.rotation) -
                   (inputs.directional_vector&.x || 0) * 5 * Math.cos(@player.rotation + Math::PI / 2)

      # we are doing this 4 times so take that speed and multiple it by 0.25
      @player.dx *= 0.25
      @player.x += @player.dx

      # find anything the player has collided with
      collision = @terrain.find do |t|
        Geometry.intersect_circle?(player_hit_circ, t.hit_circ)
      end

      # if the collision occurred, then undo the movement of the player
      if collision
        @player.x -= @player.dx
      end
    end

    # do the same quarter step for dy
    4.times do
      @player.dy = (inputs.directional_vector&.y || 0) * 5 * Math.sin(@player.rotation) -
                   (inputs.directional_vector&.x || 0) * 5 * Math.sin(@player.rotation + Math::PI / 2)

      @player.dy *= 0.25

      @player.y += @player.dy

      collision = @terrain.find do |t|
        Geometry.intersect_circle?(player_hit_circ, t.hit_circ)
      end

      if collision
        @player.y -= @player.dy
      end
    end

    # if the player moved, then we want to invalidate the
    # matrix we use to calculate the camera
    if @player.dx != 0 || @player.dy != 0
      @camera_space_matrix = nil
    end

    # if they zoom in or out, set the camera scale, and again invalidate the camera matrix
    if inputs.keyboard.plus || inputs.controller_one.right_analog_y_perc > 0.5
      @camera.scale *= 1.01
      @camera_space_matrix = nil
    elsif inputs.keyboard.minus || inputs.controller_one.right_analog_y_perc < -0.5
      @camera.scale = @camera.scale / 1.01
      @camera_space_matrix = nil
    end

    # turning does the same thing, rotates the player, rotates the camera,
    # and invalidates the camera matrix
    if inputs.keyboard.e || inputs.controller_one.right_analog_x_perc > 0.5
      @player.rotation -= 0.05
      @camera.rotation -= 0.05
      @camera_space_matrix = nil
    elsif inputs.keyboard.q || inputs.controller_one.right_analog_x_perc < -0.5
      @player.rotation += 0.05
      @camera.rotation += 0.05
      @camera_space_matrix = nil
    end

    @camera.x = @player.x
    @camera.y = @player.y
  end

  def tick
    calc

    render
  end

  def render
    # outputs.watch @camera
    # outputs.watch @player
    # outputs.watch to_camera_space(@player)

    # create a render target that holds our world
    outputs[:scene].w = 1280
    outputs[:scene].h = 720
    outputs[:scene].background_color = [0, 0, 0]

    # take the player, and move them into camera space
    player_rect = to_camera_space(@player)
    player_circ = { x: player_rect.x + player_rect.w / 2,
                    y: player_rect.y + player_rect.h / 2,
                    w: player_rect.w,
                    h: player_rect.h,
                    path: "sprites/circle/white.png",
                    anchor_x: 0.5,
                    anchor_y: 0.5 }
    outputs[:scene].primitives << player_rect

    # do the same thing for the terrain
    outputs[:scene].primitives << @terrain.map do |t|
      to_camera_space(t)
    end

    # render the scene
    outputs.primitives << { x: 0,
                            y: 0,
                            w: 1280,
                            h: 720,
                            anchor_x: 0.5,
                            anchor_y: 0.5,
                            path: :scene }
  end

  def to_camera_space rect
    # if the camera space matrix is nil, then compute the matrix projection
    # - we move the rect into camera space
    # - scale it
    # - then rotate
    # Note: if we wanted to translate from camera to world, then these steps would be done in reverse
    @camera_space_matrix ||= Matrix.mul(mat3_translate(-@camera.x, -@camera.y),
                                         mat3_scale(@camera.scale),
                                         mat3_rotate(-@camera.rotation))

    # deconstruct the rect that we are trying to transform into its bottom left and
    # top left point. run both points through the camerap projects
    projection_bottom_left = Matrix.mul(Matrix.vec3(rect.x, rect.y, 1),
                                        @camera_space_matrix)

    projection_top_right = Matrix.mul(Matrix.vec3(rect.x + rect.w, rect.y + rect.h, 1),
                           @camera_space_matrix)

    # compute the new angle of the rect and use that to compute the angle of rotation
    # within the screen for the sprite
    rect_angle = (rect.rotation || 0).to_degrees
    projection_angle = Geometry.angle(projection_bottom_left, projection_top_right)

    rect.merge x: projection_bottom_left.x,
               y: projection_bottom_left.y,
               w: Geometry.distance(projection_bottom_left, projection_top_right),
               h: Geometry.distance(projection_bottom_left, projection_top_right),
               angle: projection_angle - 45 + rect_angle
  end

  # standard translate matrix
  def mat3_translate x, y
    Matrix.mat3 1, 0, x,
                0, 1, y,
                0, 0, 1
  end

  # scale matrix
  def mat3_scale s
    Matrix.mat3 s, 0, 0,
                0, s, 0,
                0, 0, 1
  end

  # rotation matrix (where t/theta is represented in radians)
  def mat3_rotate t
    Matrix.mat3 Math.cos(t), -Math.sin(t), 0,
                Math.sin(t), Math.cos(t), 0,
                0, 0, 1
  end
end

$game = Game.new

# on game boot, set the origin to be the center of the screen
def boot args
  Grid.origin_center!
end

# new up our game object, set args, and execute tick
def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

# if the file is saved, clear out the game so it can be recreated
def reset args
  $game = nil
end

GTK.reset
