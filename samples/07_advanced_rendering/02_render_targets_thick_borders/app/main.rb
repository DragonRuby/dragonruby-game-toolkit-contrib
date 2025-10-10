# sample app shows how to create a border with thickness
# using render targets

def boot args
  # initialize state to an empty hash
  args.state = {}
end

def tick args
  # create a value in state that stores border_cache information
  args.state.border_cache ||= {}

  args.outputs.background_color = [80, 80, 80]

  # render a thick border
  args.outputs.primitives << thick_border_prefab(args.outputs, args.state.border_cache,
                                                 { x: 640,
                                                   y: 360,
                                                   w: 100,
                                                   h: 100,
                                                   r: 255,
                                                   g: 255,
                                                   b: 255,
                                                   angle: Kernel.tick_count,
                                                   thickness: 5,
                                                   anchor_x: 0.5,
                                                   anchor_y: 0.5 })

  args.outputs.primitives << thick_border_prefab(args.outputs, args.state.border_cache,
                                                 { x: 640,
                                                   y: 360,
                                                   w: 50,
                                                   h: 50,
                                                   r: 0,
                                                   g: 128,
                                                   b: 80,
                                                   a: 128,
                                                   angle: -Kernel.tick_count,
                                                   thickness: 10,
                                                   anchor_x: 0.5,
                                                   anchor_y: 0.5 })
end

def thick_border_prefab outputs, cache, border
  # a texture/render target will be create for each border profile
  # the key/path for the render target uses the border width, height, and thickness
  name = "thick-border-sprite-#{border.w.to_i}-#{border.h.to_i}-#{border.thickness.to_i}"

  # look into the cache and see if the texture/render target has already been created
  if cache[name]
    # if so, then return a sprite to the render target,
    # default values for the texture are a black border in the bottom left,
    # those values are then overriden with the values in border (via ** splat args)
    # path is the name of the render target
    return { r: 0, g: 0, b: 0, a: 255, **border, path: name }
  end

  # if the cache entry doesn't exist, then store a record,
  # and then generate the texture
  cache[name] = { path: name, create_at: Kernel.tick_count }

  # the texture's width and height will be that of the border
  outputs[name].w = border.w.to_i
  outputs[name].h = border.h.to_i

  # set the background to transparent
  outputs[name].background_color = [255, 255, 255, 0]

  # the primitives for this texture is a :solid,
  # with an :empty texture on top of it with the blend mode set to 0.
  # both :solid, and :empty are provided by DragonRuby
  # the solid's r, g, b values are set to full white so that
  # it's saturation can be controlled by the r, g, b values sent to the border
  outputs[name].primitives << [
    {
      x: 0,
      y: 0,
      w: border.w,
      h: border.h,
      path: :solid,
      r: 255,
      g: 255,
      b: 255,
      a: 255
    },
    # setting the blend mode to 0 for the :empty texture will create a clip area within the solid (giving the illusion of a border)
    {
      x: border.thickness,
      y: border.thickness,
      w: border.w - border.thickness * 2,
      h: border.h - border.thickness * 2,
      path: :empty,
      blendmode_enum: 0
    }
  ]

  # after the cache entry is created,
  # call thick_border_prefab again (recursive call which will
  # resolve because the cache entry is now there)
  thick_border_prefab outputs, cache, border
end

GTK.reset
