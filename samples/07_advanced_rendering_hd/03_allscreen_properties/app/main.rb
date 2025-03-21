def tick args
  label_style = { r: 255, g: 255, b: 255, size_enum: 4 }
  args.outputs.background_color = [0, 0, 0]
  args.outputs.borders << { x: 0, y: 0, w: 1280, h: 720, r: 255, g: 255, b: 255 }

  args.outputs.labels << { x: 10, y:  10.from_top, text: "texture_scale:       #{args.grid.texture_scale}", **label_style }
  args.outputs.labels << { x: 10, y:  40.from_top, text: "texture_scale_enum:  #{args.grid.texture_scale_enum}",  **label_style }
  args.outputs.labels << { x: 10, y:  70.from_top, text: "allscreen_offset_x:  #{args.grid.allscreen_offset_x}", **label_style }
  args.outputs.labels << { x: 10, y: 100.from_top, text: "allscreen_offset_y:  #{args.grid.allscreen_offset_y}", **label_style }

  if (Kernel.tick_count % 500) < 250
    args.outputs.labels << { x: 10, y: 130.from_top, text: "cropped to:          grid", **label_style }

    args.outputs.sprites << { x:        args.grid.left,
                              y:        args.grid.bottom,
                              w:        args.grid.w,
                              h:        args.grid.h,
                              # world.png has a 720p baseline size of 2000x2000 pixels
                              # we want to crop the center of the sprite
                              # wrt the bounds of the safe area.
                              source_x: 2000 - args.grid.w / 2,
                              source_y: 2000 - args.grid.h / 2,
                              source_w: 1280,
                              source_h: 720,
                              path: "sprites/world.png" } # world.png has a 720p baseline size of 2000x2000 pixels
  else
    args.outputs.labels << { x: 10, y: 130.from_top, text: "cropped to:          allscreen", **label_style }

    args.outputs.sprites << { x:        args.grid.allscreen_left,
                              y:        args.grid.allscreen_bottom,
                              w:        args.grid.allscreen_w,
                              h:        args.grid.allscreen_h,
                              # world.png has a 720p baseline size of 2000x2000 pixels
                              # we want to crop the center of the sprite to the bounds
                              # wrt to the bounds of the entire renderable area.
                              source_x: 2000 - args.grid.allscreen_w / 2,
                              source_y: 2000 - args.grid.allscreen_h / 2,
                              source_w: args.grid.allscreen_w,
                              source_h: args.grid.allscreen_h,
                              path:     "sprites/world.png" }
  end

  args.outputs.sprites << { x: 0, y: 0.from_top - 165, w: 410, h: 165, r: 0, g: 0, b: 0, a: 200, path: :pixel }

  if args.inputs.keyboard.key_down.right_arrow
    GTK.set_window_scale 1, 9, 16
  elsif args.inputs.keyboard.key_down.left_arrow
    GTK.set_window_scale 1, 32, 9
  elsif args.inputs.keyboard.key_down.up_arrow
    GTK.toggle_window_fullscreen
  end
end
