def tick args
  label_style = { r: 255, g: 255, b: 255, size_enum: 4 }
  args.outputs.background_color = [0, 0, 0]
  args.outputs.borders << { x: 0, y: 0, w: 1280, h: 720, r: 255, g: 255, b: 255 }

  args.outputs.labels << { x: 10, y:  10.from_top, text: "native_scale:       #{args.grid.native_scale}", **label_style }
  args.outputs.labels << { x: 10, y:  40.from_top, text: "native_scale_enum:  #{args.grid.native_scale_enum}",  **label_style }
  args.outputs.labels << { x: 10, y:  70.from_top, text: "allscreen_offset_x: #{args.grid.allscreen_offset_x}", **label_style }
  args.outputs.labels << { x: 10, y: 100.from_top, text: "allscreen_offset_y: #{args.grid.allscreen_offset_y}", **label_style }

  if (args.state.tick_count % 500) < 250
    args.outputs.labels << { x: 10, y: 130.from_top, text: "cropped to:         grid", **label_style }

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
    args.outputs.labels << { x: 10, y: 130.from_top, text: "cropped to:         allscreen", **label_style }

    args.outputs.sprites << { x:        0    - args.grid.allscreen_offset_x,
                              y:        0    - args.grid.allscreen_offset_y,
                              w:        1280 + args.grid.allscreen_offset_x * 2,
                              h:        720  + args.grid.allscreen_offset_y * 2,
                              source_x: 2000 - 640 - args.grid.allscreen_offset_x,
                              source_y: 2000 - 320 - args.grid.allscreen_offset_y,
                              source_w: 1280 + args.grid.allscreen_offset_x * 2,
                              source_h: 720  + args.grid.allscreen_offset_y * 2,
                              path:     "sprites/world.png" }

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

  args.outputs.sprites << { x: 0, y: 0.from_top - 165, w: 410, h: 165, r: 0, g: 0, b: 0, a: 200, path: :pixel }
end
