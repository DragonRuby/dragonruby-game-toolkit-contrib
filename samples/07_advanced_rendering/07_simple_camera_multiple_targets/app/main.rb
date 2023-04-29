def tick args
  args.outputs.background_color = [0, 0, 0]

  # variables you can play around with
  args.state.world.w                ||= 1280
  args.state.world.h                ||= 720
  args.state.target_hero            ||= :hero_1
  args.state.target_hero_changed_at ||= -30
  args.state.hero_size              ||= 32

  # initial state of heros and camera
  args.state.hero_1 ||= { x: 100, y: 100 }
  args.state.hero_2 ||= { x: 100, y: 600 }
  args.state.camera ||= { x: 640, y: 360, scale: 1.0 }

  # render instructions
  args.outputs.primitives << { x: 0,  y: 80.from_top, w: 360, h: 80, r: 0, g: 0, b: 0, a: 128 }.solid!
  args.outputs.primitives << { x: 10, y: 10.from_top, text: "+/- to change zoom of camera", r: 255, g: 255, b: 255}.label!
  args.outputs.primitives << { x: 10, y: 30.from_top, text: "arrow keys to move target hero", r: 255, g: 255, b: 255}.label!
  args.outputs.primitives << { x: 10, y: 50.from_top, text: "space to cycle target hero", r: 255, g: 255, b: 255}.label!

  # render scene
  args.outputs[:scene].w = args.state.world.w
  args.outputs[:scene].h = args.state.world.h

  # render world
  args.outputs[:scene].solids << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, r: 20, g: 60, b: 80 }

  # render hero_1
  args.outputs[:scene].solids << { x: args.state.hero_1.x, y: args.state.hero_1.y,
                                   w: args.state.hero_size, h: args.state.hero_size, r: 255, g: 155, b: 80 }

  # render hero_2
  args.outputs[:scene].solids << { x: args.state.hero_2.x, y: args.state.hero_2.y,
                                   w: args.state.hero_size, h: args.state.hero_size, r: 155, g: 255, b: 155 }

  # render scene relative to camera
  scene_position = calc_scene_position args

  args.outputs.sprites << { x: scene_position.x,
                            y: scene_position.y,
                            w: scene_position.w,
                            h: scene_position.h,
                            path: :scene }

  # mini map
  args.outputs.borders << { x: 10,
                            y: 10,
                            w: args.state.world.w.idiv(8),
                            h: args.state.world.h.idiv(8),
                            r: 255,
                            g: 255,
                            b: 255 }
  args.outputs.sprites << { x: 10,
                            y: 10,
                            w: args.state.world.w.idiv(8),
                            h: args.state.world.h.idiv(8),
                            path: :scene }

  # cycle target hero
  if args.inputs.keyboard.key_down.space
    if args.state.target_hero == :hero_1
      args.state.target_hero = :hero_2
    else
      args.state.target_hero = :hero_1
    end
    args.state.target_hero_changed_at = args.state.tick_count
  end

  # move target hero
  hero_to_move = if args.state.target_hero == :hero_1
                   args.state.hero_1
                 else
                   args.state.hero_2
                 end

  if args.inputs.directional_angle
    hero_to_move.x += args.inputs.directional_angle.vector_x * 5
    hero_to_move.y += args.inputs.directional_angle.vector_y * 5
    hero_to_move.x  = hero_to_move.x.clamp(0, args.state.world.w - hero_to_move.size)
    hero_to_move.y  = hero_to_move.y.clamp(0, args.state.world.h - hero_to_move.size)
  end

  # +/- to zoom in and out
  if args.inputs.keyboard.plus && args.state.tick_count.zmod?(3)
    args.state.camera.scale += 0.05
  elsif args.inputs.keyboard.hyphen && args.state.tick_count.zmod?(3)
    args.state.camera.scale -= 0.05
  end

  args.state.camera.scale = 0.1 if args.state.camera.scale < 0.1
end

def other_hero args
  if args.state.target_hero == :hero_1
    return args.state.hero_2
  else
    return args.state.hero_1
  end
end

def calc_scene_position args
  target_hero = if args.state.target_hero == :hero_1
                  args.state.hero_1
                else
                  args.state.hero_2
                end

  other_hero = if args.state.target_hero == :hero_1
                 args.state.hero_2
               else
                 args.state.hero_1
               end

  # calculate the lerp percentage based on the time since the target hero changed
  lerp_percentage = args.easing.ease args.state.target_hero_changed_at,
                                     args.state.tick_count,
                                     30,
                                     :smooth_stop_quint,
                                     :flip

  # calculate the angle and distance between the target hero and the other hero
  angle_to_other_hero = args.geometry.angle_to target_hero, other_hero

  # calculate the distance between the target hero and the other hero
  distance_to_other_hero = args.geometry.distance target_hero, other_hero

  # the camera position is the target hero position plus the angle and distance to the other hero (lerped)
  { x: args.state.camera.x - (target_hero.x + (angle_to_other_hero.vector_x * distance_to_other_hero * lerp_percentage)) * args.state.camera.scale,
    y: args.state.camera.y - (target_hero.y + (angle_to_other_hero.vector_y * distance_to_other_hero * lerp_percentage)) * args.state.camera.scale,
    w: args.state.world.w * args.state.camera.scale,
    h: args.state.world.h * args.state.camera.scale }
end
