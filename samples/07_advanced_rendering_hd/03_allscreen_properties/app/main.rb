def tick args
  args.outputs.background_color = [0, 0, 0]
  args.outputs.borders << { x: 0, y: 0, w: 1280, h: 720, r: 255, g: 255, b: 255 }

  args.outputs.labels << { x: 30, y: 30.from_top, text: "render scale: #{args.grid.render_scale}", r: 255, g: 128, b: 0, size_enum: 2 }
  args.outputs.labels << { x: 30, y: 60.from_top, text: "render scale: #{args.grid.render_scale_enum}", r: 255, g: 128, b: 0, size_enum: 2 }

  if (args.state.tick_count % 500) < 250
    args.outputs.labels << { x: 30, y: 90.from_top, text: "cropped to grid", r: 255, g: 128, b: 0, size_enum: 2 }

    args.outputs.sprites << { x:        0,
                              y:        0,
                              w:        1280,
                              h:        720,
                              source_x: 2000 - 640,
                              source_y: 2000 - 320,
                              source_w: 1280,
                              source_h: 720,
                              path: "sprites/world.png" }
  else
    args.outputs.labels << { x: 30, y: 90.from_top, text: "cropped to all screen", r: 255, g: 128, b: 0, size_enum: 2 }

    args.outputs.sprites << { x:        0    - args.grid.allscreen_offset_x,
                              y:        0    - args.grid.allscreen_offset_y,
                              w:        1280 + args.grid.allscreen_offset_x * 2,
                              h:        720  + args.grid.allscreen_offset_y * 2,
                              source_x: 2000 - 640 - args.grid.allscreen_offset_x,
                              source_y: 2000 - 320 - args.grid.allscreen_offset_y,
                              source_w: 1280 + args.grid.allscreen_offset_x * 2,
                              source_h: 720  + args.grid.allscreen_offset_y * 2,
                              path:     "sprites/world.png" }
  end
end
