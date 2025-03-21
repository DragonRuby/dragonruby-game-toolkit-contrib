# sample app shows how to translate between screen and world coordinates using matrix multiplication
class Game
  attr_gtk

  def tick
    defaults
    input
    calc
    render
  end

  def defaults
    return if Kernel.tick_count != 0

    # define the size of the world
    state.world_size = 1280

    # initialize the camera
    state.camera = {
      x: 0,
      y: 0,
      zoom: 1
    }

    # initialize entities: place entities randomly in the world
    state.entities = 200.map do
      {
        x: (rand * state.world_size - 100).to_i * (rand > 0.5 ? 1 : -1),
        y: (rand * state.world_size - 100).to_i * (rand > 0.5 ? 1 : -1),
        w: 32,
        h: 32,
        angle: 0,
        path: "sprites/square/blue.png",
        rotation_speed: rand * 5
      }
    end

    # backdrop for the world
    state.backdrop = { x: -state.world_size,
                       y: -state.world_size,
                       w: state.world_size * 2,
                       h: state.world_size * 2,
                       r: 200,
                       g: 100,
                       b: 0,
                       a: 128,
                       path: :pixel }

    # rect representing the screen
    state.screen_rect = { x: 0, y: 0, w: 1280, h: 720 }

    # update the camera matricies (initial state)
    update_matricies!
  end

  # if the camera is ever changed, recompute the matricies that are used
  # to translate between screen and world coordinates. we want to cache
  # the resolved matrix for speed
  def update_matricies!
    # camera space is defined with three matricies
    # every entity is:
    # - offset by the location of the camera
    # - scaled
    # - then centered on the screen
    state.to_camera_space_matrix = MatrixFunctions.mul(mat3_translate(state.camera.x, state.camera.y),
                                                       mat3_scale(state.camera.zoom),
                                                       mat3_translate(640, 360))

    # world space is defined based off the camera matricies but inverted:
    # every entity is:
    # - uncentered from the screen
    # - unscaled
    # - offset by the location of the camera in the opposite direction
    state.to_world_space_matrix = MatrixFunctions.mul(mat3_translate(-640, -360),
                                                      mat3_scale(1.0 / state.camera.zoom),
                                                      mat3_translate(-state.camera.x, -state.camera.y))

    # the viewport is computed by taking the screen rect and moving it into world space.
    # what entities get rendered is based off of the viewport
    state.viewport = rect_mul_matrix(state.screen_rect, state.to_world_space_matrix)
  end

  def input
    # if the camera is changed, invalidate/recompute the translation matricies
    should_update_matricies = false

    # + and - keys zoom in and out
    if inputs.keyboard.equal_sign || inputs.keyboard.plus || inputs.mouse.wheel && inputs.mouse.wheel.y > 0
      state.camera.zoom += 0.01 * state.camera.zoom
      should_update_matricies = true
    elsif inputs.keyboard.minus || inputs.mouse.wheel && inputs.mouse.wheel.y < 0
      state.camera.zoom -= 0.01 * state.camera.zoom
      should_update_matricies = true
    end

    # clamp the zoom to a minimum of 0.25
    if state.camera.zoom < 0.25
      state.camera.zoom = 0.25
      should_update_matricies = true
    end

    # left and right keys move the camera left and right
    if inputs.left_right != 0
      state.camera.x += -1 * (inputs.left_right * 10) * state.camera.zoom
      should_update_matricies = true
    end

    # up and down keys move the camera up and down
    if inputs.up_down != 0
      state.camera.y += -1 * (inputs.up_down * 10) * state.camera.zoom
      should_update_matricies = true
    end

    # reset the camera to the default position
    if inputs.keyboard.key_down.zero
      state.camera.x = 0
      state.camera.y = 0
      state.camera.zoom = 1
      should_update_matricies = true
    end

    # if the update matricies flag is set, recompute the matricies
    update_matricies! if should_update_matricies
  end

  def calc
    # rotate all the entities by their rotation speed
    # and reset their hovered state
    state.entities.each do |entity|
      entity.hovered = false
      entity.angle += entity.rotation_speed
    end

    # find all the entities that are hovered by the mouse and update their state back to hovered
    mouse_in_world = rect_to_world_coordinates inputs.mouse.rect
    hovered_entities = Geometry.find_all_intersect_rect mouse_in_world, state.entities
    hovered_entities.each { |entity| entity.hovered = true }
  end

  def render
    # create a render target to represent the camera's viewport
    outputs[:scene].w = state.world_size
    outputs[:scene].h = state.world_size

    # render the backdrop
    outputs[:scene].primitives << rect_to_screen_coordinates(state.backdrop)

    # get all entities that are within the camera's viewport
    entities_to_render = Geometry.find_all_intersect_rect state.viewport, state.entities

    # render all the entities within the viewport
    outputs[:scene].primitives << entities_to_render.map do |entity|
      r = rect_to_screen_coordinates entity

      # change the color of the entity if it's hovered
      r.merge!(path: "sprites/square/red.png") if entity.hovered

      r
    end

    # render the camera's viewport
    outputs.sprites << {
      x: 0,
      y: 0,
      w: state.world_size,
      h: state.world_size,
      path: :scene
    }

    # show a label that shows the mouse's screen and world coordinates
    outputs.labels << { x: 30, y: 30.from_top, text: "#{gtk.current_framerate.to_sf}" }

    mouse_in_world = rect_to_world_coordinates inputs.mouse.rect

    outputs.labels << {
      x: 30,
      y: 55.from_top,
      text: "Screen Coordinates: #{inputs.mouse.x}, #{inputs.mouse.y}",
    }

    outputs.labels << {
      x: 30,
      y: 80.from_top,
      text: "World Coordinates: #{mouse_in_world.x.to_sf}, #{mouse_in_world.y.to_sf}",
    }
  end

  def rect_to_screen_coordinates rect
    rect_mul_matrix rect, state.to_camera_space_matrix
  end

  def rect_to_world_coordinates rect
    rect_mul_matrix rect, state.to_world_space_matrix
  end

  def rect_mul_matrix rect, matrix
    # the bottom left and top right corners of the rect
    # are multiplied by the matrix to get the new coordinates
    bottom_left = MatrixFunctions.mul (MatrixFunctions.vec3 rect.x, rect.y, 1), matrix
    top_right   = MatrixFunctions.mul (MatrixFunctions.vec3 rect.x + rect.w, rect.y + rect.h, 1), matrix

    # with the points of the rect recomputed, reconstruct the rect
    rect.merge x: bottom_left.x,
               y: bottom_left.y,
               w: top_right.x - bottom_left.x,
               h: top_right.y - bottom_left.y
  end

  # this is the definition of how to move a point in 2d space using a matrix
  def mat3_translate x, y
    MatrixFunctions.mat3 1, 0, x,
                         0, 1, y,
                         0, 0, 1
  end

  # this is the definition of how to scale a point in 2d space using a matrix
  def mat3_scale scale
    MatrixFunctions.mat3 scale, 0, 0,
                         0, scale, 0,
                         0,     0, 1
  end
end

$game = Game.new

def tick args
  $game.args = args
  $game.tick
end

GTK.reset
