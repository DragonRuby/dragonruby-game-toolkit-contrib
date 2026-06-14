def boot args
  args.state = {}
end

# return an array of primitives, the sprite with the blendmode applied,
# and the label/name for the blend mode
def blendmode_prefab(name:, x:, y:, w:, h:, blendmode:)
  [
    { x: x,
      y: y,
      w: w,
      h: h,
      path: "sprites/blue-feathered.png",
      blendmode: blendmode },
    { x: x + w / 2,
      y: y + h / 2,
      anchor_x: 0.5, anchor_y: 0.5,
      r: 255, g: 255, b: 255,
      size_px: 32,
      text: "#{name}" }
  ]
end

def tick args
  # Different blend modes do different things, depending on what they
  # blend against (in this case, the background_color).

  # compute the color transation from red, to green, to blue, to black
  color_tick = Kernel.tick_count % 1020
  if color_tick < 255
    bg_color = { r: color_tick, g: 0, b: 0 }
  elsif color_tick < 510
    bg_color = { r: 255 - color_tick % 255, g: color_tick - 255, b: 0 }
  elsif color_tick < 765
    bg_color = { r: 0, g: 255 - color_tick % 255, b: color_tick - 255 - 255 }
  else
    bg_color = { r: 0, g: 0, b: 255 - color_tick % 255 }
  end

  args.outputs.background_color = bg_color

  args.outputs.primitives << {
    x: 640,
    y: 540,
    anchor_x: 0.5,
    anchor_y: 0.5,
    text: "background_color #{bg_color}",
    r: 255, g: 255, b: 255,
    size_px: 32
  }

  args.outputs.primitives << blendmode_prefab(name: "none",  blendmode: 0, x: 320 + 0,   y: 296, w: 128, h: 128)
  args.outputs.primitives << blendmode_prefab(name: "alpha", blendmode: 1, x: 320 + 128, y: 296, w: 128, h: 128)
  args.outputs.primitives << blendmode_prefab(name: "add",   blendmode: 2, x: 320 + 256, y: 296, w: 128, h: 128)
  args.outputs.primitives << blendmode_prefab(name: "mod",   blendmode: 4, x: 320 + 384, y: 296, w: 128, h: 128)
  args.outputs.primitives << blendmode_prefab(name: "mul",   blendmode: 8, x: 320 + 512, y: 296, w: 128, h: 128)
end

DR.reset
