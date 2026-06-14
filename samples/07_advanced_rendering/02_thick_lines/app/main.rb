def boot args
  args.state = {}
end

def tick args
  args.outputs.primitives << thick_line(x: 640,
                                        y: 360,
                                        x2: args.inputs.mouse.x,
                                        y2: args.inputs.mouse.y,
                                        thickness: 10,
                                        r: 0, g: 0, b: 0)
end

def thick_line(x:, y:, x2:, y2:, thickness: 3, r: 0, g: 0, b: 0)
  line = { x: x, y: y, x2: x2, y2: y2 }
  line_length = Geometry.line_length line
  line_angle = Geometry.line_angle line
  perpendicular_angle = (line_angle + 90) % 360
  vec = perpendicular_angle.to_vector
  return { x: x - vec.x * (thickness / 2),
           y: y - vec.y * (thickness / 2) + 2,
           angle: line_angle,
           angle_anchor_x: 0,
           angle_anchor_y: 0,
           path: :solid,
           r: r, g: g, b: b,
           w: line_length,
           h: thickness }
end
