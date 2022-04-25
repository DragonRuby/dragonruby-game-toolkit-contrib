include MatrixFunctions

def tick args
  args.outputs.labels << { x: 0,
                           y: 30.from_top,
                           text: "W,A,S,D to move. Q,E,U,O to turn, I,K for elevation. Triangles is a Indie/Pro Feature and will be ignored in Standard.",
                           alignment_enum: 1 }

  args.grid.origin_center!

  args.state.cam_x ||= 0.00
  if args.inputs.keyboard.left
    args.state.cam_x += 0.01
  elsif args.inputs.keyboard.right
    args.state.cam_x -= 0.01
  end

  args.state.cam_y ||= 0.00
  if args.inputs.keyboard.i
    args.state.cam_y += 0.01
  elsif args.inputs.keyboard.k
    args.state.cam_y -= 0.01
  end

  args.state.cam_z ||= 6.5
  if args.inputs.keyboard.s
    args.state.cam_z += 0.1
  elsif args.inputs.keyboard.w
    args.state.cam_z -= 0.1
  end

  args.state.cam_angle_y ||= 0
  if args.inputs.keyboard.q
    args.state.cam_angle_y += 0.25
  elsif args.inputs.keyboard.e
    args.state.cam_angle_y -= 0.25
  end

  args.state.cam_angle_x ||= 0
  if args.inputs.keyboard.u
    args.state.cam_angle_x += 0.1
  elsif args.inputs.keyboard.o
    args.state.cam_angle_x -= 0.1
  end

  # model A
  args.state.a = [
    [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
    [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
  ]

  # model to world
  args.state.a_world = mul_world args,
                                 args.state.a,
                                 (translate -0.25, -0.25, 0),
                                 (translate  0, 0, 0.25),
                                 (rotate_x args.state.tick_count)

  args.state.a_camera = mul_cam args, args.state.a_world
  args.state.a_projected = mul_perspective args, args.state.a_camera
  render_projection args, args.state.a_projected

  # model B
  args.state.b = [
    [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
    [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
  ]

  # model to world
  args.state.b_world = mul_world args,
                                 args.state.b,
                                 (translate -0.25, -0.25, 0),
                                 (translate  0, 0, -0.25),
                                 (rotate_x args.state.tick_count)

  args.state.b_camera = mul_cam args, args.state.b_world
  args.state.b_projected = mul_perspective args, args.state.b_camera
  render_projection args, args.state.b_projected

  # model C
  args.state.c = [
    [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
    [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
  ]

  # model to world
  args.state.c_world = mul_world args,
                                 args.state.c,
                                 (translate -0.25, -0.25, 0),
                                 (rotate_y 90),
                                 (translate -0.25,  0, 0),
                                 (rotate_x args.state.tick_count)

  args.state.c_camera = mul_cam args, args.state.c_world
  args.state.c_projected = mul_perspective args, args.state.c_camera
  render_projection args, args.state.c_projected

  # model D
  args.state.d = [
    [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
    [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
  ]

  # model to world
  args.state.d_world = mul_world args,
                                 args.state.d,
                                 (translate -0.25, -0.25, 0),
                                 (rotate_y 90),
                                 (translate  0.25,  0, 0),
                                 (rotate_x args.state.tick_count)

  args.state.d_camera = mul_cam args, args.state.d_world
  args.state.d_projected = mul_perspective args, args.state.d_camera
  render_projection args, args.state.d_projected

  # model E
  args.state.e = [
    [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
    [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
  ]

  # model to world
  args.state.e_world = mul_world args,
                                 args.state.e,
                                 (translate -0.25, -0.25, 0),
                                 (rotate_x 90),
                                 (translate  0,  0.25, 0),
                                 (rotate_x args.state.tick_count)

  args.state.e_camera = mul_cam args, args.state.e_world
  args.state.e_projected = mul_perspective args, args.state.e_camera
  render_projection args, args.state.e_projected

  # model E
  args.state.f = [
    [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
    [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
  ]

  # model to world
  args.state.f_world = mul_world args,
                                 args.state.f,
                                 (translate -0.25, -0.25, 0),
                                 (rotate_x 90),
                                 (translate  0,  -0.25, 0),
                                 (rotate_x args.state.tick_count)

  args.state.f_camera = mul_cam args, args.state.f_world
  args.state.f_projected = mul_perspective args, args.state.f_camera
  render_projection args, args.state.f_projected

  # render_debug args, args.state.a, args.state.a_transform, args.state.a_projected
  # args.outputs.labels << { x: -630, y:  10.from_top,  text: "x:         #{args.state.cam_x.to_sf} -> #{( args.state.cam_x * 1000 ).to_sf}" }
  # args.outputs.labels << { x: -630, y:  30.from_top,  text: "y:         #{args.state.cam_y.to_sf} -> #{( args.state.cam_y * 1000 ).to_sf}" }
  # args.outputs.labels << { x: -630, y:  50.from_top,  text: "z:         #{args.state.cam_z.fdiv(10).to_sf} -> #{( args.state.cam_z * 100 ).to_sf}" }
end

def mul_world args, model, *mul_def
  model.map do |vecs|
    vecs.map do |vec|
      mul vec,
          *mul_def
    end
  end
end

def mul_cam args, world_vecs
  world_vecs.map do |vecs|
    vecs.map do |vec|
      mul vec,
          (translate -args.state.cam_x, args.state.cam_y, -args.state.cam_z),
          (rotate_y args.state.cam_angle_y),
          (rotate_x args.state.cam_angle_x)
    end
  end
end

def mul_perspective args, camera_vecs
  camera_vecs.map do |vecs|
    vecs.map do |vec|
      perspective vec
    end
  end
end

def render_debug args, model, transform, projected
  args.outputs.labels << { x: -630, y:  10.from_top,  text: "model:     #{vecs_to_s model[0]}" }
  args.outputs.labels << { x: -630, y:  30.from_top,  text: "           #{vecs_to_s model[1]}" }
  args.outputs.labels << { x: -630, y:  50.from_top,  text: "transform: #{vecs_to_s transform[0]}" }
  args.outputs.labels << { x: -630, y:  70.from_top,  text: "           #{vecs_to_s transform[1]}" }
  args.outputs.labels << { x: -630, y:  90.from_top,  text: "projected: #{vecs_to_s projected[0]}" }
  args.outputs.labels << { x: -630, y: 110.from_top,  text: "           #{vecs_to_s projected[1]}" }
end

def render_projection args, projection
  p0 = projection[0]
  args.outputs.sprites << {
    x:  p0[0].x,   y: p0[0].y,
    x2: p0[1].x,  y2: p0[1].y,
    x3: p0[2].x,  y3: p0[2].y,
    source_x:   0, source_y:   0,
    source_x2: 80, source_y2:  0,
    source_x3:  0, source_y3: 80,
    a: 40,
    # r: 128, g: 128, b: 128,
    path: 'sprites/square/blue.png'
  }

  p1 = projection[1]
  args.outputs.sprites << {
    x:  p1[0].x,   y: p1[0].y,
    x2: p1[1].x,  y2: p1[1].y,
    x3: p1[2].x,  y3: p1[2].y,
    source_x:  80, source_y:   0,
    source_x2: 80, source_y2: 80,
    source_x3:  0, source_y3: 80,
    a: 40,
    # r: 128, g: 128, b: 128,
    path: 'sprites/square/blue.png'
  }
end

def perspective vec
  left   = -1.0
  right  =  1.0
  bottom = -1.0
  top    =  1.0
  near   =  300.0
  far    =  1000.0
  sx = 2 * near / (right - left)
  sy = 2 * near / (top - bottom)
  c2 = - (far + near) / (far - near)
  c1 = 2 * near * far / (near - far)
  tx = -near * (left + right) / (right - left)
  ty = -near * (bottom + top) / (top - bottom)

  p = mat4 sx, 0, 0, tx,
           0, sy, 0, ty,
           0, 0, c2, c1,
           0, 0, -1, 0

  r = mul vec, p
  r.x *= r.z / r.w / 100
  r.y *= r.z / r.w / 100
  r
end

def mat_scale scale
  mat4 scale,     0,     0,   0,
           0, scale,     0,   0,
           0,     0, scale,   0,
           0,     0,     0,   1
end

def rotate_y angle_d
  cos_t = Math.cos angle_d.to_radians
  sin_t = Math.sin angle_d.to_radians
  (mat4  cos_t,  0, sin_t, 0,
         0,      1, 0,     0,
         -sin_t, 0, cos_t, 0,
         0,      0, 0,     1)
end

def rotate_z angle_d
  cos_t = Math.cos angle_d.to_radians
  sin_t = Math.sin angle_d.to_radians
  (mat4 cos_t, -sin_t, 0, 0,
        sin_t,  cos_t, 0, 0,
        0,      0,     1, 0,
        0,      0,     0, 1)
end

def translate dx, dy, dz
  mat4 1, 0, 0, dx,
       0, 1, 0, dy,
       0, 0, 1, dz,
       0, 0, 0,  1
end


def rotate_x angle_d
  cos_t = Math.cos angle_d.to_radians
  sin_t = Math.sin angle_d.to_radians
  (mat4  1,     0,      0, 0,
         0, cos_t, -sin_t, 0,
         0, sin_t,  cos_t, 0,
         0,     0,      0, 1)
end

def vecs_to_s vecs
  vecs.map do |vec|
    "[#{vec.x.to_sf} #{vec.y.to_sf} #{vec.z.to_sf}]"
  end.join " "
end
