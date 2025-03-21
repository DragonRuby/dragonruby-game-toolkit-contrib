class Game
  attr_gtk

  def tick
    if Kernel.tick_count == 0
      # set window to an ultra wide aspect ratio for the demonstration
      GTK.set_window_scale(1.0, 32, 9)
    end

    state.player ||= {
      x: -64,
      y: -64,
      w: 128,
      h: 128,
      path: :solid,
      r: 80,
      g: 128,
      b: 128
    }

    state.boxes ||= 1000.map do |i|
      {
        x: Numeric.rand(-3000..3000),
        y: Numeric.rand(-3000..3000),
        w: 64,
        h: 64,
        r: Numeric.rand(128..255),
        g: Numeric.rand(128..255),
        b: Numeric.rand(128..255),
        a: 128,
        path: :solid
      }
    end

    calc_camera

    render
  end

  def calc_camera
    if !state.camera
      state.camera = {
        x: 0,
        y: 0,
        target_x: 0,
        target_y: 0,
        target_scale: 1,
        scale: 1
      }
    end

    state.view_zoom ||= 1

    state.player.x += 10 * inputs.left_right
    state.player.y += 10 * inputs.up_down

    if inputs.keyboard.key_down.plus
      state.view_zoom *= 1.1
    elsif inputs.keyboard.key_down.minus
      state.view_zoom /= 1.1
    end

    state.camera.target_x = state.player.x + state.player.w / 2
    state.camera.target_y = state.player.y + state.player.h / 2
    state.camera.target_scale = state.view_zoom

    ease = 0.1
    state.camera.scale += (state.camera.target_scale - state.camera.scale) * ease
    state.camera.x += (state.camera.target_x - state.camera.x) * ease
    state.camera.y += (state.camera.target_y - state.camera.y) * ease
  end

  def render
    outputs.background_color = [0, 0, 0]

    outputs[:scene].w = Camera.world_w
    outputs[:scene].h = Camera.world_h
    outputs[:scene].background_color = [0, 0, 0]

    outputs[:scene].primitives << Camera.find_all_intersect_viewport(state.camera, state.boxes)
                                        .map do |b|
                                          Camera.to_screen_space(state.camera, b)
                                        end

    outputs[:scene].primitives << Camera.to_screen_space(state.camera, state.player)

    outputs.primitives << { **Camera.viewport, path: :scene }

    outputs.lines << { x: 640, y: 0, h: 720, r: 255, g: 255, b: 255 }
    outputs.lines << { x: 0, y: 360, w: 1280, r: 255, g: 255, b: 255 }

    outputs.labels << { x: 640,
                        y: 720 - 32,
                        text: "Note: All Screen rendering requires a Pro license (Standard license will be letter boxed)",
                        anchor_x: 0.5,
                        anchor_y: 0.5,
                        size_px: 32,
                        r: 255,
                        g: 255,
                        b: 255 }

    outputs.labels << { x: 640,
                        y: 32,
                        text: "Arrow keys to move camera, +/- to zoom in/out",
                        anchor_x: 0.5,
                        anchor_y: 0.5,
                        size_px: 32,
                        r: 255,
                        g: 255,
                        b: 255 }
  end
end

class Camera
  class << self
    def world_w
      Grid.allscreen_w
    end

    def world_h
      Grid.allscreen_h
    end

    def world_size_w_half
      Grid.allscreen_w / 2
    end

    def world_size_h_half
      Grid.allscreen_h / 2
    end

    def offset_x
      Grid.allscreen_x
    end

    def offset_y
      Grid.allscreen_y
    end

    def to_world_space camera, rect
      return nil if !rect
      x = (rect.x - world_size_w_half + camera.x * camera.scale - offset_x) / camera.scale
      y = (rect.y - world_size_h_half + camera.y * camera.scale - offset_y) / camera.scale
      w = rect.w / camera.scale
      h = rect.h / camera.scale
      rect.merge x: x, y: y, w: w, h: h
    end

    def to_screen_space camera, rect
      return nil if !rect
      x = rect.x * camera.scale - camera.x * camera.scale + world_size_w_half
      y = rect.y * camera.scale - camera.y * camera.scale + world_size_h_half
      w = rect.w * camera.scale
      h = rect.h * camera.scale
      rect.merge x: x, y: y, w: w, h: h
    end

    def viewport
      {
        x: offset_x,
        y: offset_y,
        w: world_w,
        h: world_h,
      }
    end

    def viewport_world camera
      to_world_space camera, viewport
    end

    def find_all_intersect_viewport camera, os
      Geometry.find_all_intersect_rect viewport_world(camera), os
    end
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
