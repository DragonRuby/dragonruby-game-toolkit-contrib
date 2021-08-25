def tick args
  # variables you can play around with
  args.state.world.w      ||= 1280
  args.state.world.h      ||= 720

  args.state.player.x     ||= 0
  args.state.player.y     ||= 0
  args.state.player.size  ||= 32

  args.state.enemy.x      ||= 700
  args.state.enemy.y      ||= 700
  args.state.enemy.size   ||= 16

  args.state.camera.x                ||= 640
  args.state.camera.y                ||= 300
  args.state.camera.scale            ||= 1.0
  args.state.camera.show_empty_space ||= :yes

  # instructions
  args.outputs.primitives << { x: 0, y:  80.from_top, w: 360, h: 80, r: 0, g: 0, b: 0, a: 128 }.solid!
  args.outputs.primitives << { x: 10, y: 10.from_top, text: "arrow keys to move around", r: 255, g: 255, b: 255}.label!
  args.outputs.primitives << { x: 10, y: 30.from_top, text: "+/- to change zoom of camera", r: 255, g: 255, b: 255}.label!
  args.outputs.primitives << { x: 10, y: 50.from_top, text: "tab to change camera edge behavior", r: 255, g: 255, b: 255}.label!

  # render scene
  args.outputs[:scene].w = args.state.world.w
  args.outputs[:scene].h = args.state.world.h

  args.outputs[:scene].solids << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, r: 20, g: 60, b: 80 }
  args.outputs[:scene].solids << { x: args.state.player.x, y: args.state.player.y,
                                   w: args.state.player.size, h: args.state.player.size, r: 80, g: 155, b: 80 }
  args.outputs[:scene].solids << { x: args.state.enemy.x, y: args.state.enemy.y,
                                   w: args.state.enemy.size, h: args.state.enemy.size, r: 155, g: 80, b: 80 }

  # render camera
  scene_position = calc_scene_position args
  args.outputs.sprites << { x: scene_position.x,
                            y: scene_position.y,
                            w: scene_position.w,
                            h: scene_position.h,
                            path: :scene }

  # move player
  if args.inputs.directional_angle
    args.state.player.x += args.inputs.directional_angle.vector_x * 5
    args.state.player.y += args.inputs.directional_angle.vector_y * 5
    args.state.player.x  = args.state.player.x.clamp(0, args.state.world.w - args.state.player.size)
    args.state.player.y  = args.state.player.y.clamp(0, args.state.world.h - args.state.player.size)
  end

  # +/- to zoom in and out
  if args.inputs.keyboard.plus && args.state.tick_count.zmod?(3)
    args.state.camera.scale += 0.05
  elsif args.inputs.keyboard.hyphen && args.state.tick_count.zmod?(3)
    args.state.camera.scale -= 0.05
  elsif args.inputs.keyboard.key_down.tab
    if args.state.camera.show_empty_space == :yes
      args.state.camera.show_empty_space = :no
    else
      args.state.camera.show_empty_space = :yes
    end
  end

  args.state.camera.scale = args.state.camera.scale.greater(0.1)
end

def calc_scene_position args
  result = { x: args.state.camera.x - (args.state.player.x * args.state.camera.scale),
             y: args.state.camera.y - (args.state.player.y * args.state.camera.scale),
             w: args.state.world.w * args.state.camera.scale,
             h: args.state.world.h * args.state.camera.scale,
             scale: args.state.camera.scale }

  return result if args.state.camera.show_empty_space == :yes

  if result.w < args.grid.w
    result.merge!(x: (args.grid.w - result.w).half)
  elsif (args.state.player.x * result.scale) < args.grid.w.half
    result.merge!(x: 10)
  elsif (result.x + result.w) < args.grid.w
    result.merge!(x: - result.w + (args.grid.w - 10))
  end

  if result.h < args.grid.h
    result.merge!(y: (args.grid.h - result.h).half)
  elsif (result.y) > 10
    result.merge!(y: 10)
  elsif (result.y + result.h) < args.grid.h
    result.merge!(y: - result.h + (args.grid.h - 10))
  end

  result
end
