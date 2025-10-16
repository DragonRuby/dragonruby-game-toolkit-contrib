# Sample app shows how you can use render targets to create arbitrary shapes like a thicker line
def tick args
  args.outputs.primitives << thick_line(args, x: 0, y: 0, x2: 640, y2: 360, thickness: 3)&.merge(r: 0, g: 0, b: 0)
end

def thick_line args, line
  line_length = Math.sqrt((line.x2 - line.x)**2 + (line.y2 - line.y)**2)
  name = "line-sprite-#{line_length}-#{line.thickness}"
  line_angle = Math.atan2(line.y2 - line.y, line.x2 - line.x) * 180 / Math::PI

  # query args.outputs.render_targets to get the current status of the texture
  # if it's ready then send it out to draw
  if args.outputs.render_targets.ready? name
    perpendicular_angle = (line_angle + 90) % 360
    return args.outputs
               .render_targets[name]
               .merge(x: line.x - perpendicular_angle.vector_x * (line.thickness / 2),
                      y: line.y - perpendicular_angle.vector_y * (line.thickness / 2),
                      anchor_x: 0,
                      anchor_y: 0,
                      angle: line_angle)
  end

  # if the render target status is queued then return nil until it's ready (a queued render target
  # means that a request has been made to generate the texture, but it hasn't been created yet/isn't ready)
  return nil if args.outputs.render_targets.queued? name

  args.outputs[name].w = line_length
  args.outputs[name].h = line.thickness
  args.outputs[name].solids << { x: 0, y: 0, w: line_length, h: line.thickness, r: 255, g: 255, b: 255 }
  return thick_line args, line
end
