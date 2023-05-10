# Sample app shows how you can use render targets to create arbitrary shapes like a thicker line
def tick args
  args.state.line_cache ||= {}
  args.outputs.primitives << thick_line(args,
                                        args.state.line_cache,
                                        x: 0, y: 0, x2: 640, y2: 360, thickness: 3).merge(r: 0, g: 0, b: 0)
end

def thick_line args, cache, line
  line_length = Math.sqrt((line.x2 - line.x)**2 + (line.y2 - line.y)**2)
  name = "line-sprite-#{line_length}-#{line.thickness}"
  cached_line = cache[name]
  line_angle = Math.atan2(line.y2 - line.y1, line.x2 - line.x1) * 180 / Math::PI
  if cached_line
    perpendicular_angle = (line_angle + 90) % 360
    return cached_line.sprite.merge(x: line.x - perpendicular_angle.vector_x * (line.thickness / 2),
                                    y: line.y - perpendicular_angle.vector_y * (line.thickness / 2),
                                    angle: line_angle)
  end

  cache[name] = {
    line: line,
    thickness: line.thickness,
    sprite: {
      w: line_length,
      h: line.thickness,
      path: name,
      angle_anchor_x: 0,
      angle_anchor_y: 0
    }
  }

  args.outputs[name].w = line_length
  args.outputs[name].h = line.thickness
  args.outputs[name].solids << { x: 0, y: 0, w: line_length, h: line.thickness, r: 255, g: 255, b: 255 }
  return thick_line args, cache, line
end
