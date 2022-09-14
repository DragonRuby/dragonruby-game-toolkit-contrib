def tick args
  args.outputs.background_color = [0, 0, 0]
  args.outputs.borders << { x: 0, y: 0, w: 1280, h: 720, r: 255, g: 255, b: 255 }

  args.outputs.labels << { x: 30, y: 30.from_top, text: "render scale: #{args.grid.render_scale}", r: 255, g: 255, b: 255 }
  args.outputs.labels << { x: 30, y: 60.from_top, text: "render scale: #{args.grid.render_scale_enum}", r: 255, g: 255, b: 255 }

  args.outputs.sprites << { x: -640 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x: -320 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }

  args.outputs.sprites << { x:    0 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  320 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  960 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x: 1280 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }

  args.outputs.sprites << { x: 1600 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x: 1920 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }

  args.outputs.sprites << { x:  640 - 50, y: -280 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y:   40 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y:  360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y:  680 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y: 1000 - 50, w: 100, h: 100, path: "sprites/square.png" }
end
