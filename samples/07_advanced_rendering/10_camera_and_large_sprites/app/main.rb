# When using a render target as a camera, sprite rendered
# within the camera can become very large and tax the GPU. This
# example shows how to calculate the crop rectangle for the sprite and only
# render the portion of the sprite that is visible within the camera.
class Game
  attr :args

  def tick
    defaults
    calc
    render
  end

  def defaults
    @args.state.orbit ||= {
      x: 640,
      y: 640,
      w: 1280,
      h: 1280,
      anchor_x: 0.5,
      anchor_y: 0.5
    }

    @args.state.viewport ||= {
      x: 0,
      y: 0,
      w: 720,
      h: 720
    }

    @args.state.camera ||= {
      x: 0,
      y: 0,
      scale: 0.25,
      w: 720,
      h: 720
    }

    if !@args.state.orbit_sprite_size
      w, h = GTK.calcspritebox("sprites/ring-1280.png")
      @args.state.orbit_sprite_size = {
        w: w,
        h: h
      }
    end
  end

  def calc
    if inputs.keyboard.i
      state.camera.scale += 0.005 * state.camera.scale
    elsif inputs.keyboard.o
      state.camera.scale -= 0.005 * state.camera.scale
    end

    if inputs.keyboard.d
      state.camera.x += 10 / state.camera.scale
    elsif inputs.keyboard.a
      state.camera.x -= 10 / state.camera.scale
    end

    if inputs.keyboard.s
      state.camera.y -= 10 / state.camera.scale
    elsif inputs.keyboard.w
      state.camera.y += 10 / state.camera.scale
    end

    state.camera.scale = state.camera.scale.clamp(0.25, 10)
    state.camera.x = state.camera.x.round(2)
    state.camera.y = state.camera.y.round(2)

    state.orbit_in_camera = {
      x: (state.orbit.x - state.camera.x) * state.camera.scale,
      y: (state.orbit.y - state.camera.y) * state.camera.scale,
      w: state.orbit.w * state.camera.scale,
      h: state.orbit.h * state.camera.scale,
      anchor_x: state.orbit.anchor_x,
      anchor_y: state.orbit.anchor_y
    }
  end

  def render
    outputs.background_color = [32, 32, 32]

    outputs[:scene].w = 720
    outputs[:scene].h = 720
    outputs[:scene].background_color = [0, 0, 0, 0]

    orbit_sprite_rect = sprite_rect state.viewport, state.orbit_in_camera, state.orbit_sprite_size
    outputs[:scene].sprites << {
      **orbit_sprite_rect,
      path: "sprites/ring-1280.png"
    }

    outputs.borders << {
      x: Grid.w / 2,
      y: Grid.h / 2,
      w: 720,
      h: 720,
      path: :scene,
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 255,
      g: 255,
      b: 255
    }

    outputs.sprites << {
      x: Grid.w / 2,
      y: Grid.h / 2,
      w: 720,
      h: 720,
      path: :scene,
      anchor_x: 0.5,
      anchor_y: 0.5
    }

    outputs.watch("Instructions WASD: move camera, I: zoom in, O: zoom out")
    outputs.watch("state.camera:    #{state.camera.to_sf}")
    outputs.watch("orbit_in_camera: #{state.orbit_in_camera.to_sf}")
    outputs.watch("sprite_rect:     #{orbit_sprite_rect.to_sf}")
  end

  def sprite_rect viewport_rect, destination_rect, sprite_size
    ratio = destination_rect.w / sprite_size.w

    # if the destination rect is not within the viewport, return an empty rect
    if !Geometry.intersect_rect? viewport_rect, destination_rect
      return { x: 0, y: 0, w: 0, h: 0 }
    end

    # Geometry.rect_props returns a hash with x, y, w, h (removes/recomputes anchor_x, anchor_y)
    destination_rect = Geometry.rect_props destination_rect
    viewport_rect = Geometry.rect_props viewport_rect

    # calculate the x, w, source_x, source_w of the sprite
    destination_left = destination_rect.x
    viewport_left = viewport_rect.x
    destination_right = destination_rect.x + destination_rect.w
    viewport_right = viewport_rect.x + viewport_rect.w
    left_diff = viewport_left - destination_left
    right_diff = destination_right - viewport_right

    if destination_left <= viewport_left && destination_right >= viewport_right
      # destination rect's x, w is larger than the viewport
      x = viewport_left
      w = destination_rect.w - (viewport_left - destination_left) - right_diff
      source_x = 0 + left_diff / ratio
      source_w = sprite_size.w - left_diff / ratio - right_diff / ratio
    elsif destination_left <= viewport_left && destination_right <= viewport_right
      # destination rect's x, w is partially within the viewport
      x = viewport_left
      w = destination_rect.w - (viewport_left - destination_left)
      source_x = 0 + left_diff / ratio
      source_w = sprite_size.w - left_diff / ratio
    elsif destination_right >= viewport_right && destination_left >= viewport_left
      # destination rect's x, w is partially within the viewport
      x = destination_left
      w = destination_rect.w - right_diff
      source_x = 0
      source_w = sprite_size.w - right_diff / ratio
    else
      # destination rect's x, w is completely within the viewport
      x = destination_left
      w = destination_rect.w
      source_x = 0
      source_w = sprite_size.w
    end

    # calculate the y, h, source_y, source_h of the sprite
    destination_top = destination_rect.y + destination_rect.h
    viewport_top = viewport_rect.y + viewport_rect.h
    destination_bottom = destination_rect.y
    viewport_bottom = viewport_rect.y
    bottom_diff = viewport_bottom - destination_bottom
    top_diff = destination_top - viewport_top

    if destination_top >= viewport_top && destination_bottom <= viewport_bottom
      # destination rect's y, h is larger than the viewport
      y = viewport_bottom
      h = destination_rect.h - (viewport_bottom - destination_bottom) - top_diff
      source_y = 0 + (viewport_bottom - destination_bottom) / ratio
      source_h = sprite_size.h - (viewport_bottom - destination_bottom) / ratio - top_diff / ratio
    elsif destination_top >= viewport_top && destination_bottom >= viewport_bottom
      # destination rect's y, h is partially within the viewport
      y = destination_bottom
      h = destination_rect.h - top_diff
      source_y = 0
      source_h = sprite_size.h - top_diff / ratio
    elsif destination_bottom <= viewport_bottom && destination_top <= viewport_top
      # destination rect's y, h is partially within the viewport
      source_y = 0 + bottom_diff / ratio
      source_h = sprite_size.h - bottom_diff / ratio
      y = viewport_bottom
      h = destination_rect.h - bottom_diff
    else
      # destination rect's y, h is completely within the viewport
      y = destination_bottom
      h = destination_rect.h
      source_y = 0
      source_h = sprite_size.h
    end

    # return the calculated values
    {
      x: x,
      y: y,
      w: w,
      h: h,
      source_x: source_x,
      source_y: source_y,
      source_w: source_w,
      source_h: source_h
    }
  end

  def state
    @args.state
  end

  def outputs
    @args.outputs
  end

  def inputs
    @args.inputs
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
