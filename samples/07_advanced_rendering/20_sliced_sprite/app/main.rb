BLENDOPERATION_ADD              = 0x1
BLENDOPERATION_SUBTRACT         = 0x2
BLENDOPERATION_REV_SUBTRACT     = 0x3
BLENDOPERATION_MINIMUM          = 0x4
BLENDOPERATION_MAXIMUM          = 0x5
BLENDFACTOR_ZERO                = 0x1
BLENDFACTOR_ONE                 = 0x2
BLENDFACTOR_SRC_COLOR           = 0x3
BLENDFACTOR_ONE_MINUS_SRC_COLOR = 0x4
BLENDFACTOR_SRC_ALPHA           = 0x5
BLENDFACTOR_ONE_MINUS_SRC_ALPHA = 0x6
BLENDFACTOR_DST_COLOR           = 0x7
BLENDFACTOR_ONE_MINUS_DST_COLOR = 0x8
BLENDFACTOR_DST_ALPHA           = 0x9
BLENDFACTOR_ONE_MINUS_DST_ALPHA = 0xA

# color_out = color_src * src_color_factor [color_operation] color_dst * dst_color_factor
# alpha_out = alpha_src * src_alpha_factor [alpha_operation] alpha_dst * dst_alpha_factor
def compose_blendmode(src_color_factor, dst_color_factor, color_operation, src_alpha_factor, dst_alpha_factor, alpha_operation)
  (color_operation  << 0)  |
  (src_color_factor << 4)  |
  (dst_color_factor << 8)  |
  (alpha_operation  << 16) |
  (src_alpha_factor << 20) |
  (dst_alpha_factor << 24)
end

HOLE_PUNCH_BLENDMODE = compose_blendmode(
  BLENDFACTOR_ZERO,
  BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
  BLENDOPERATION_ADD,
  BLENDFACTOR_ZERO,
  BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
  BLENDOPERATION_ADD)

def boot args
  args.state = {}
end

def tick args
  args.state.left_side ||= {
    x: 640,
    y: 360,
    angle: 0,
    dx: -6,
    dy: 6,
    dangle: 4,
  }

  args.state.right_side ||= {
    x: 640,
    y: 360,
    angle: 0,
    dx: 4,
    dy: 10,
    dangle: -6
  }

  args.state.gravity ||= -0.2

  args.state.slice_angle ||= 32

  if Kernel.tick_count > 60
    args.state.left_side.x += args.state.left_side.dx
    args.state.left_side.y += args.state.left_side.dy
    args.state.left_side.dy += args.state.gravity
    args.state.left_side.angle += args.state.left_side.dangle

    args.state.right_side.x += args.state.right_side.dx
    args.state.right_side.y += args.state.right_side.dy
    args.state.right_side.dy += args.state.gravity
    args.state.right_side.angle += args.state.right_side.dangle
  end

  args.outputs[:left_side].set w: 80, h: 80, background_color: [0, 0, 0, 0]
  args.outputs[:left_side].primitives << { x: 0, y: 0, w: 80, h: 80, path: "sprites/square/blue.png" }
  args.outputs[:left_side].primitives << {
    x: 40, y: 40, w: 114, h: 114,
    angle: args.state.slice_angle - 90,
    anchor_x: 0.5, anchor_y: 0, angle_anchor_x: 0.5, angle_anchor_y: 0,
    path: :solid,
    blendmode: HOLE_PUNCH_BLENDMODE,  # comment out this line to see the holepunch area
    r: 255, g: 0, b: 0
  }

  args.outputs[:right_side].set w: 80, h: 80, background_color: [0, 0, 0, 0]
  args.outputs[:right_side].primitives << { x: 0, y: 0, w: 80, h: 80, path: "sprites/square/blue.png" }
  args.outputs[:right_side].primitives << {
    x: 40, y: 40, w: 114, h: 114,
    angle: args.state.slice_angle,
    anchor_x: 1, anchor_y: 0.5, angle_anchor_x: 1, angle_anchor_y: 0.5,
    path: :solid,
    blendmode: HOLE_PUNCH_BLENDMODE, # comment out this line to see the holepunch area
    r: 0, g: 0, b: 255
  }

  args.outputs << {
    x: args.state.left_side.x,
    y: args.state.left_side.y,
    w: 80,
    h: 80,
    path: :left_side,
    anchor_x: 0.5,
    anchor_y: 0.5,
    angle: args.state.left_side.angle
  }

  args.outputs << {
    x: args.state.right_side.x,
    y: args.state.right_side.y,
    w: 80,
    h: 80,
    path: :right_side,
    anchor_x: 0.5,
    anchor_y: 0.5,
    angle: args.state.right_side.angle
  }
end

DR.reset
