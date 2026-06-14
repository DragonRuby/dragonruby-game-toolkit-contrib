def boot args
  args.state = {}
end

def tick args
  radius = Math.cos((Kernel.tick_count % 360).to_radians).abs * 360
  args.outputs.sprites << circle(x: 640 - radius,
                                 y: 360 - radius,
                                 w: radius * 2,
                                 h: radius * 2,
                                 r: 80,
                                 g: 80,
                                 b: 80)
end

def circle(x:, y:, w:, h:, r: 255, g: 255, b: 255)
  [
    { x: x,         y: y,         w: w / 2, h: h / 2, r: r, g: g, b: b, path: 'sprites/quarter-circle.png', flip_horizontally: false, flip_vertically: false },
    { x: x + w / 2, y: y,         w: w / 2, h: h / 2, r: r, g: g, b: b, path: 'sprites/quarter-circle.png', flip_horizontally: true,  flip_vertically: false },
    { x: x,         y: y + h / 2, w: w / 2, h: h / 2, r: r, g: g, b: b, path: 'sprites/quarter-circle.png', flip_horizontally: false, flip_vertically: true },
    { x: x + w / 2, y: y + h / 2, w: w / 2, h: h / 2, r: r, g: g, b: b, path: 'sprites/quarter-circle.png', flip_horizontally: true,  flip_vertically: true }
  ]
end
