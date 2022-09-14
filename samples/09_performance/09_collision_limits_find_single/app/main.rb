def tick args
  if args.state.should_reset_framerate_calculation
    args.gtk.reset_framerate_calculation
    args.state.should_reset_framerate_calculation = nil
  end

  if !args.state.rects
    args.state.rects = []
    add_10_000_random_rects args
  end

  args.state.player_rect ||= { x: 640 - 20, y: 360 - 20, w: 40, h: 40 }
  args.state.collision_type ||= :using_lambda

  if args.state.tick_count == 0
    generate_scene args, args.state.quad_tree
  end

  # inputs
  # have a rectangle that can be moved around using arrow keys
  args.state.player_rect.x += args.inputs.left_right * 4
  args.state.player_rect.y += args.inputs.up_down * 4

  if args.inputs.mouse.click
    add_10_000_random_rects args
    args.state.should_reset_framerate_calculation = true
  end

  if args.inputs.keyboard.key_down.tab
    if args.state.collision_type == :using_lambda
      args.state.collision_type = :using_while_loop
    elsif args.state.collision_type == :using_while_loop
      args.state.collision_type = :using_find_intersect_rect
    elsif args.state.collision_type == :using_find_intersect_rect
      args.state.collision_type = :using_lambda
    end
    args.state.should_reset_framerate_calculation = true
  end

  # calc
  if args.state.collision_type == :using_lambda
    args.state.current_collision = args.state.rects.find { |r| r.intersect_rect? args.state.player_rect }
  elsif args.state.collision_type == :using_while_loop
    args.state.current_collision = nil
    idx = 0
    l = args.state.rects.length
    rects = args.state.rects
    player = args.state.player_rect
    while idx < l
      if rects[idx].intersect_rect? player
        args.state.current_collision = rects[idx]
        break
      end
      idx += 1
    end
  else
    args.state.current_collision = args.geometry.find_intersect_rect args.state.player_rect, args.state.rects
  end

  # render
  render_instructions args
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :scene }

  if args.state.current_collision
    args.outputs.sprites << args.state.current_collision.merge(path: :pixel, r: 255, g: 0, b: 0)
  end

  args.outputs.sprites << args.state.player_rect.merge(path: :pixel, a: 80, r: 0, g: 255, b: 0)
  args.outputs.labels  << {
    x: args.state.player_rect.x + args.state.player_rect.w / 2,
    y: args.state.player_rect.y + args.state.player_rect.h / 2,
    text: "player",
    alignment_enum: 1,
    vertical_alignment_enum: 1,
    size_enum: -4
  }

end

def add_10_000_random_rects args
  add_rects args, 10_000.map { { x: rand(1080) + 100, y: rand(520) + 100 } }
end

def add_rects args, points
  args.state.rects.concat(points.map { |point| { x: point.x, y: point.y, w: 5, h: 5 } })
  # args.state.quad_tree = args.geometry.quad_tree_create args.state.rects
  generate_scene args, args.state.quad_tree
end

def add_rect args, x, y
  args.state.rects << { x: x, y: y, w: 5, h: 5 }
  # args.state.quad_tree = args.geometry.quad_tree_create args.state.rects
  generate_scene args, args.state.quad_tree
end

def generate_scene args, quad_tree
  args.outputs[:scene].w = 1280
  args.outputs[:scene].h = 720
  args.outputs[:scene].solids << { x: 0, y: 0, w: 1280, h: 720, r: 255, g: 255, b: 255 }
  args.outputs[:scene].sprites << args.state.rects.map { |r| r.merge(path: :pixel, r: 0, g: 0, b: 255) }
end

def render_instructions args
  args.outputs.primitives << { x:  0, y: 90.from_top, w: 1280, h: 100, r: 0, g: 0, b: 0, a: 200 }.solid!
  args.outputs.labels << { x: 10, y: 10.from_top, r: 255, g: 255, b: 255, size_enum: -2, text: "Click to add 10,000 random rects. Tab to change collision algorithm." }
  args.outputs.labels << { x: 10, y: 40.from_top, r: 255, g: 255, b: 255, size_enum: -2, text: "Algorithm: #{args.state.collision_type}" }
  args.outputs.labels << { x: 10, y: 55.from_top, r: 255, g: 255, b: 255, size_enum: -2, text: "Rect Count: #{args.state.rects.length}" }
  args.outputs.labels << { x: 10, y: 70.from_top, r: 255, g: 255, b: 255, size_enum: -2, text: "FPS: #{args.gtk.current_framerate.to_sf}" }
end
