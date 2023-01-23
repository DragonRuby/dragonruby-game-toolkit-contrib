# With HD mode enabled. DragonRuby will automatically use HD sprites given the following
# naming convention (assume we are using a sprite called =player.png=):
#
# | Name  | Resolution | File Naming Convention        |
# |-------+------------+-------------------------------|
# | 720p  |   1280x720 | =player.png=                  |
# | HD+   |   1600x900 | =player@125.png=              |
# | 1080p |  1920x1080 | =player@125.png=              |
# | 1440p |  2560x1440 | =player@200.png=              |
# | 1800p |  3200x1800 | =player@250.png=              |
# | 4k    |  3200x2160 | =player@300.png=              |
# | 5k    |  6400x2880 | =player@400.png=              |

# Note: Review the sample app's game_metadata.txt file for what configurations are enabled.

def tick args
  args.outputs.background_color = [0, 0, 0]
  args.outputs.borders << { x: 0, y: 0, w: 1280, h: 720, r: 255, g: 255, b: 255 }

  args.outputs.labels << { x: 30, y: 30.from_top, text: "render scale: #{args.grid.native_scale}", r: 255, g: 255, b: 255 }
  args.outputs.labels << { x: 30, y: 60.from_top, text: "render scale: #{args.grid.native_scale_enum}", r: 255, g: 255, b: 255 }

  args.outputs.sprites << { x: -640 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x: -320 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }

  args.outputs.sprites << { x:    0 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  320 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  960 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x: 1280 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }

  args.outputs.sprites << { x: 1600 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x: 1920 - 50, y: 360 - 50, w: 100, h: 100, path: "sprites/square.png" }

  args.outputs.sprites << { x:  640 - 50, y:          720, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y: 100.from_top, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y:     360 - 50, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y:            0, w: 100, h: 100, path: "sprites/square.png" }
  args.outputs.sprites << { x:  640 - 50, y:         -100, w: 100, h: 100, path: "sprites/square.png" }
end
