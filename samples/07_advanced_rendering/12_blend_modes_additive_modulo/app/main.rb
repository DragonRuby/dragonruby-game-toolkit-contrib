# Sample app shows how to use blend modes to create a masking layer
# Special thanks to akzidenz@discord (https://akzidenz.itch.io/) for providing this sample app
#
# blendmode_enum reference:
#  0: no blend
#  1: alpha blending (default)
#  2: additive blending
#  3: modulo blending
#  4: multiply blending
def tick args
  # create a render target to represent the masking layer
  args.outputs[:mask].w = 1280
  args.outputs[:mask].h = 720

  # don't erase the texture when new items are added
  args.outputs[:mask].clear_before_render = false

  # the "cover" only goes in once
  if Kernel.tick_count == 0
    # place a black background in the render target
    args.outputs[:mask].sprites << {
      x: 0, y: 0, w: 1280, h: 720,
      path: :solid,
      r: 0, g: 0, b: 0 # <-- important (black color)
    }
  end

  # the "reveal" sprite is added to the render target
  # when the left mouse button is clicked or held
  # NOTE: setting `clear_before_render = false` keeps the RT from resetting
  #       when a new primitive is drawn to it
  if args.inputs.mouse.key_down.left || args.inputs.mouse.key_held.left
    args.outputs[:mask].sprites << {
      x: args.inputs.mouse.x,
      y: args.inputs.mouse.y,
      w: 240, h: 240,
      anchor_x: 0.5,
      anchor_y: 0.5,
      path: 'sprites/mask.png', # <-- sprite representing the "reveal shape"
      blendmode: 2,             # <-- important (2 means additive blending)
      r: 255, g: 255, b: 255    # <-- important (white color)
    }
  end

  # render background to reveal
  args.outputs.sprites << { x: 0,
                            y: 0,
                            w: 1280,
                            h: 720,
                            path: 'sprites/bg.png' }

  # render masking layer over the bg to reveal
  args.outputs.sprites << {
    x: 0, y: 0, w: 1280, h: 720,
    path: :mask,
    blendmode: 4 # <-- important (4 means modulo blending)
  }

  # render mouse overlay
  args.outputs.sprites << {
    x: args.inputs.mouse.x,
    y: args.inputs.mouse.y,
    w: 180, h: 180,
    anchor_x: 0.5, anchor_y: 0.5,
    a: 32
  }

  # render instructions
  args.outputs.labels << { x: 8,
                           y: 720 - 8,
                           text: "click/drag move to uncover bg image",
                           r: 255,
                           g: 255,
                           b: 255 }
end
