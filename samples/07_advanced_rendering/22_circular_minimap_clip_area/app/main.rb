def boot args
  args.state = {}
end

def tick args
  args.outputs.background_color = [30, 30, 30]
  args.state.player ||= {
    x: 640 - 32,
    y: 360 - 32,
    w: 64,
    h: 64,
  }
  args.state.squares ||= 100.map do
    {
      x: rand(1280),
      y: rand(720),
      w: 96,
      h: 96,
      r: Numeric.rand(128..255),
      g: Numeric.rand(128..255),
      b: Numeric.rand(128..255),
      a: 128,
      path: :solid
    }
  end

  args.state.player.x += args.inputs.left_right * 4
  args.state.player.y += args.inputs.up_down * 4

  minimap_size = 196
  minimap_coverage = 320
  render_scene args
  render_square_minimap args, minimap_size: minimap_size, minimap_coverage: minimap_coverage
  render_circle_minimap args, minimap_size: minimap_size, minimap_coverage: minimap_coverage

  args.outputs.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :scene }

  args.outputs.primitives << {
    x: minimap_size * 0,
    y: 0,
    w: minimap_size,
    h: minimap_size,
    path: :minimap
  }

  args.outputs.primitives << {
    x: minimap_size * 1,
    y: 0,
    w: minimap_size,
    h: minimap_size,
    path: :ring_minimap,
  }
end

def render_scene args
  args.outputs[:scene].set w: 1280, h: 720,
                           background_color: [30, 30, 30]

  args.outputs[:scene].primitives << args.state.squares
  args.outputs[:scene].primitives << [
    {
      x: args.state.player.x,
      y: args.state.player.y,
      w: args.state.player.w,
      h: args.state.player.h,
      r: 255,
      g: 255,
      b: 255,
      path: :solid
    },
    {
      x: args.state.player.x + 4,
      y: args.state.player.y + 4,
      w: args.state.player.w - 8,
      h: args.state.player.h - 8,
      r: 80,
      g: 128,
      b: 128,
      path: :solid
    },
  ]
end

def minimap_scene_rect(args, minimap_size:, minimap_coverage:)
  minimap_center_x = args.state.player.x + (args.state.player.w / 2)
  minimap_center_y = args.state.player.y + (args.state.player.h / 2)
  minimap_source_x = minimap_center_x - minimap_coverage / 2
  minimap_source_y = minimap_center_y - minimap_coverage / 2
  minimap_source_w = minimap_coverage
  minimap_source_h = minimap_coverage
  minimap_w = minimap_size
  minimap_h = minimap_size

  if minimap_source_x < 0
    minimap_source_x = 0
  end

  if minimap_source_y < 0
    minimap_source_y = 0
  end

  if minimap_center_x + (minimap_coverage / 2) > 1280
    source_x = 1280 - minimap_coverage
    minimap_source_x = source_x
  end

  if minimap_center_y + (minimap_coverage / 2) > 720
    source_y = 720 - minimap_coverage
    minimap_source_y = source_y
  end

  {
    x: minimap_source_x,
    y: minimap_source_y,
    w: minimap_source_w,
    h: minimap_source_h,
  }
end

def render_square_minimap(args, minimap_size:, minimap_coverage:)
  args.outputs[:minimap].set w: minimap_size,
                             h: minimap_size,
                             background_color: [0, 0, 0, 0]

  scene_source_rect = minimap_scene_rect args,
                                         minimap_size: minimap_size,
                                         minimap_coverage: minimap_coverage

  args.outputs[:minimap].primitives << {
    x: 0, y: 0, w: minimap_size, h: minimap_size,
    r: 255, g: 255, b: 255,
    path: :solid
  }

  args.outputs[:minimap].primitives << {
    x: 4, y: 4, w: minimap_size - 8, h: minimap_size - 8,
    source_x: scene_source_rect.x,
    source_y: scene_source_rect.y,
    source_w: scene_source_rect.w,
    source_h: scene_source_rect.h,
    path: :scene,
  }
end


HOLE_PUNCH_BLENDMODE = Numeric.compose_blendmode(BLENDFACTOR_ZERO,
                                                 BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                                                 BLENDOPERATION_ADD,
                                                 BLENDFACTOR_ZERO,
                                                 BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                                                 BLENDOPERATION_ADD)

def render_circle_minimap(args, minimap_size:, minimap_coverage:)
  args.outputs[:ring_sprite].set w: minimap_size,
                                 h: minimap_size,
                                 background_color: [0, 0, 0, 0]

  args.outputs[:ring_sprite].primitives << {
    x: 0, y: 0, w: minimap_size, h: minimap_size,
    path: :solid, r: 255, g: 255, b: 255, a: 255
  }

  args.outputs[:ring_sprite].primitives << {
    x: minimap_size / 2,
    y: minimap_size / 2,
    w: minimap_size - 8,
    h: minimap_size - 8,
    anchor_x: 0.5,
    anchor_y: 0.5,
    path: "sprites/solid-circle.png",
    blendmode: HOLE_PUNCH_BLENDMODE
  }

  args.outputs[:ring_minimap_clip].set w: minimap_size,
                                       h: minimap_size,
                                       background_color: [0, 0, 0, 0]

  scene_source_rect = minimap_scene_rect args,
                                         minimap_size: minimap_size,
                                         minimap_coverage: minimap_coverage


  args.outputs[:ring_minimap_clip].primitives << {
    x: 4, y: 4, w: minimap_size - 8, h: minimap_size - 8,
    source_x: scene_source_rect.x,
    source_y: scene_source_rect.y,
    source_w: scene_source_rect.w,
    source_h: scene_source_rect.h,
    path: :scene,
  }

  args.outputs[:ring_minimap_clip].primitives << {
    x: 0, y: 0, w: minimap_size, h: minimap_size,
    path: :ring_sprite
  }

  args.outputs[:ring_minimap_clip].primitives << {
    x: 0, y: 0, w: minimap_size, h: minimap_size,
    path: :ring_sprite,
    blendmode: HOLE_PUNCH_BLENDMODE,
  }

  args.outputs[:ring_minimap].set w: minimap_size, h: minimap_size, background_color: [0, 0, 0, 0]

  args.outputs[:ring_minimap].primitives << {
    x: 0,
    y: 0,
    w: minimap_size,
    h: minimap_size,
    r: 255, g: 255, b: 255,
    path: "sprites/solid-circle.png",
  }

  args.outputs[:ring_minimap].primitives << {
    x: 0,
    y: 0,
    w: minimap_size,
    h: minimap_size,
    path: :ring_minimap_clip,
  }
end

DR.reset
