def self.boot args
  args.state = {}
end

def self.tick args
  # init
  if Kernel.tick_count == 0
    control_points = [
      [
        [0.05, 0.58],
        [0.1,  0.95],
        [0.55, 0.86],
        [0.69, 0.75],
      ],
      [
        [0.69, 0.75],
        [0.96, 0.58],
        [1.00, 0.27],
        [0.76, 0.16],
      ],
      [
        [0.76, 0.16],
        [0.39, 0.08],
        [0.51, 0.4 ],
        [0.29, 0.36],
      ],
      [
        [0.29, 0.36],
        [0.11, 0.34],
        [0.04, 0.43],
        [0.05, 0.58],
      ],
    ]

    args.state.curves = control_points.map do |points|
      p0, p1, p2, p3 = points
      {
        color: { r: 128 + rand(128), g: 128 + rand(128), b: 128 + rand(128) },
        points: {
          p0: { x: p0[0], y: p0[1] },
          p1: { x: p1[0], y: p1[1] },
          p2: { x: p2[0], y: p2[1] },
          p3: { x: p3[0], y: p3[1] },
        }
      }
    end
  end

  # calc
  if args.inputs.mouse.held
    all_points = args.state.curves.flat_map do |curve|
      curve.points.values.map do |point|
        point
      end
    end

    args.state.currently_dragging_point ||= all_points.find do |point|
      mouse_inside_scene = args.inputs.mouse.rect(offset: { x: -280, y: 0 })
      Geometry.intersect_rect?(mouse_inside_scene,
                               to_rect(point))
    end

    if args.state.currently_dragging_point
      args.state.currently_dragging_point.x = (args.inputs.mouse.x - 280).fdiv(720).clamp(0, 1)
      args.state.currently_dragging_point.y = (args.inputs.mouse.y).fdiv(720).clamp(0, 1)
    end
  else
    args.state.currently_dragging_point = nil
  end

  # render
  args.outputs[:scene].set w: 720,
                           h: 720,
                           background_color: [0, 0, 0, 0]

  args.outputs[:scene].primitives << args.state.curves.map do |curve|
    curve.points.values.map do |point|
      to_rect(point).merge(path: "sprites/circle/solid.png", **curve.color, a: 128)
    end
  end

  args.outputs[:scene].primitives << args.state.curves.map do |curve|
    bezier_primitives(curve.points.p0,
                      curve.points.p1,
                      curve.points.p2,
                      curve.points.p3,
                      step: 20,
                      color: { **curve.color, a: 255 })
  end

  args.outputs.background_color = [30, 30, 30]
  args.outputs.primitives << { x: 280, y: 0, w: 720, h: 720, path: :scene }
end

def self.to_rect point
  {
    x: point.x * 720,
    y: point.y * 720,
    w: 16,
    h: 16,
    anchor_x: 0.5,
    anchor_y: 0.5,
  }
end

def self.bezier_primitives(p0, p1, p2, p3, step: 20, color:)
  curve = points_for_bezier(
    p0,
    p1,
    p2,
    p3,
    step: step
  ).each_cons(2)
   .map do |p0, p1|
     {
       x: p0.x  * 720,
       y: p0.y  * 720,
       x2: p1.x * 720,
       y2: p1.y * 720,
       **color
     }
   end

  control_points = points_for_bezier(
    p0,
    p1,
    p2,
    p3,
    step: 0
  ).each_cons(2)
   .map do |p0, p1|
     {
       x: p0.x  * 720,
       y: p0.y  * 720,
       x2: p1.x * 720,
       y2: p1.y * 720,
       **color
     }
   end

  [
    curve,
    control_points
  ]
end

def self.points_for_bezier(p0, p1, p2, p3, step:)
  points = []
  if step == 0
    [p0, p1, p2, p3]
  else
    t_step = 1.fdiv(step + 1)
    t = 0
    t += t_step
    points = []
    while t < 1
      points << Geometry.cubic_bezier_vec2(p0, p1, p2, p3, t)
      t += t_step
    end

    [
      p0,
      *points,
      p3
    ]
  end
end

DR.reset
