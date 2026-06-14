def tick args
  args.outputs.background_color = [0, 0, 0]

  start_w = 90
  start_h = 72
  growth_px = (Kernel.tick_count % 3200) * 0.1

  # ============================================
  # scale_quality_enum: 0 (NEAREST NEIGHBOR)
  # ============================================
  args.outputs.sprites << {
    x: 640 - growth_px / 2 - start_w / 2,
    y: 360,
    w: start_w + growth_px,
    h: start_h + growth_px,
    path: "sprites/misc/dragon-0.png",
    anchor_x: 0.5,
    anchor_y: 0.5,
    scale_quality_enum: 0 # sprite's scale quality explicitly set to NEAREST_NEIGHBOR
  }

  args.outputs.labels << {
    x: 640 - growth_px / 2 - start_w / 2,
    y: 360 - (start_h + growth_px) / 2 - 6,
    text: "0=NEAREST",
    anchor_x: 0.5,
    anchor_y: 0.5,
    r: 255, g: 255, b: 255,
    size_px: 12,
    scale_quality_enum: 0
  }

  # ============================================
  # scale_quality_enum: 1 or 2 (LINEAR)
  # ============================================
  args.outputs.sprites << {
    x: 640,
    y: 360 + 32,
    w: start_w + growth_px,
    h: start_h + growth_px,
    path: "sprites/misc/dragon-0.png",
    anchor_x: 0.5,
    anchor_y: 0,
    scale_quality_enum: 1 # sprite's scale quality explicitly set to NEAREST_NEIGHBOR
  }

  args.outputs.labels << {
    x: 640,
    y: 360 + 32,
    text: "1=LINEAR",
    anchor_x: 0.5,
    anchor_y: 0.5,
    r: 255, g: 255, b: 255,
    size_px: 12,
    scale_quality_enum: 1
  }

  # ============================================
  # scale_quality_enum: 0 (PIXEL ART)
  # ============================================
  args.outputs.sprites << {
    x: 640 + growth_px / 2 + start_w / 2,
    y: 360,
    w: start_w + growth_px,
    h: start_h + growth_px,
    path: "sprites/misc/dragon-0.png",
    anchor_x: 0.5,
    anchor_y: 0.5,
    scale_quality_enum: 3 # sprite's scale quality explicitly set to PIXELART
  }

  args.outputs.labels << {
    x: 640 + growth_px / 2 + start_w / 2,
    y: 360 - (start_h + growth_px) / 2 - 6,
    text: "3=PIXELART",
    anchor_x: 0.5,
    anchor_y: 0.5,
    r: 255, g: 255, b: 255,
    size_px: 12,
    scale_quality_enum: 3
  }
end
