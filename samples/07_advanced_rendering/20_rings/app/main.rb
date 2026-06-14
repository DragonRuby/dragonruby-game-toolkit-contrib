HOLE_PUNCH_BLENDMODE = Numeric.compose_blendmode(BLENDFACTOR_ZERO,
                                                 BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                                                 BLENDOPERATION_ADD,
                                                 BLENDFACTOR_ZERO,
                                                 BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                                                 BLENDOPERATION_ADD)
module Main
  def tick args
    # set the background color at the top level
    args.outputs.background_color = [30, 30, 30]
    tick_ring args
    tick_t_ring args
  end

  def tick_ring args
    # create a render target
    ring_perc = Math.sin((Kernel.tick_count % 360).to_radians).abs
    args.outputs[:ring].set w: 512, h: 512, background_color: [0, 0, 0, 0]

    # every texture within the render target that is rendered "under" the hole punch will be "clipped"
    # in this case, we have a solid circle in the center that fills the render target
    args.outputs[:ring].primitives << {
      x: 256,
      y: 256,
      w: 512,
      h: 512,
      path: "sprites/solid-circle.png",
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 0,
      g: 128,
      b: 128
    }

    # this texture represents the area that will be clipped
    # the amount of clipping is controlled by the textures alpha value
    # an alpha value of 255 means the area will be fully clipped, while an alpha value
    # of 0 means the area will not be clipped at all
    args.outputs[:ring].primitives << {
      x: 256,
      y: 256,
      w: 512 * ring_perc,
      h: 512 * ring_perc,
      path: "sprites/solid-circle.png",
      anchor_x: 0.5,
      anchor_y: 0.5,
      a: 255,
      blendmode: HOLE_PUNCH_BLENDMODE
    }


    # render the target to the screen (final result)
    args.outputs.primitives << {
      x: 320,
      y: 360,
      text: ":ring",
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 255,
      g: 255,
      b: 255
    }

    args.outputs << { x: 320,
                      y: 360,
                      w: 512,
                      h: 512,
                      path: :ring,
                      anchor_x: 0.5,
                      anchor_y: 0.5 }

  end

  def tick_t_ring args
    # create a render target
    ring_perc = Math.sin((Kernel.tick_count % 360).to_radians).abs
    args.outputs[:t_ring].set w: 512, h: 512, background_color: [0, 0, 0, 0]

    # every texture within the render target that is rendered "under" the hole punch will be "clipped"
    # in this case, we have a triangle in the center that fills the render target
    # NOTE: in order to use custom blendmodes, you must specify path:.
    #       :solid is a predefined path that is a solid white square with dimentions 1280x1280
    args.outputs[:t_ring].primitives << {
      x: 0,
      y: 0,
      r: 0, g: 128, b: 128,
      x2: 512,
      y2: 0,
      r2: 0, g2: 128, b2: 128,
      x3: 256,
      y3: 512,
      r3: 0, g3: 128, b3: 128,
      path: :solid,
      source_x: 0,
      source_y: 0,
      source_x2: 512,
      source_y2: 0,
      source_x3: 256,
      source_y3: 512,
    }

    # this texture represents the area that will be clipped
    # the amount of clipping is controlled by the textures alpha value
    # an alpha value of 255 means the area will be fully clipped, while an alpha value
    # of 0 means the area will not be clipped at all
    # NOTE: in order to use custom blendmodes, you must specify path:.
    #       :solid is a predefined path that is a solid white square with dimentions 1280x1280
    args.outputs[:t_ring].primitives << {
      x: 256 - (256 * ring_perc),
      y: 256 - (256 * ring_perc),
      r: 255, g: 255, b: 255, a: 255,
      x2: 256 + (256 * ring_perc),
      y2: 256 - (256 * ring_perc),
      r2: 255, g2: 255, b2: 255, a2: 128,
      x3: 256,
      y3: 256 + (256 * ring_perc),
      r3: 255, g3: 255, b3: 255, a2: 0,
      path: :solid,
      source_x: 0,
      source_y: 0,
      source_x2: 512,
      source_y2: 0,
      source_x3: 256,
      source_y3: 512,
      blendmode: HOLE_PUNCH_BLENDMODE
    }

    # render the target to the screen (final result)
    args.outputs.primitives << {
      x: 960,
      y: 360,
      text: ":t_ring",
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 255,
      g: 255,
      b: 255
    }

    args.outputs << { x: 960,
                      y: 360,
                      w: 512,
                      h: 512,
                      path: :t_ring,
                      anchor_x: 0.5,
                      anchor_y: 0.5 }
  end
end
