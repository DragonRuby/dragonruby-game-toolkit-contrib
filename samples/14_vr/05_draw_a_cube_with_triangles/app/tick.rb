include MatrixFunctions

def tick args
  args.grid.origin_center!

  # model A
  args.state.a = [
    [vec4(0, 0, 0, 1),   vec4(0.1, 0, 0, 1),   vec4(0, 0.1, 0, 1)],
    [vec4(0.1, 0, 0, 1), vec4(0.1, 0.1, 0, 1), vec4(0, 0.1, 0, 1)]
  ]

  # model to world
  args.state.back = mul_triangles args,
                                  args.state.a,
                                  (translate -0.05, -0.05, 0),
                                  (translate 0, 0, -0.05),
                                  (rotate_x Kernel.tick_count),
                                  (rotate_y Kernel.tick_count),
                                  (rotate_z Kernel.tick_count)

  args.state.front = mul_triangles args,
                                   args.state.a,
                                   (translate -0.05, -0.05, 0),
                                   (translate 0, 0, 0.05),
                                   (rotate_x Kernel.tick_count),
                                   (rotate_y Kernel.tick_count),
                                   (rotate_z Kernel.tick_count)

  args.state.left = mul_triangles args,
                                  args.state.a,
                                  (translate -0.05, -0.05, 0),
                                  (rotate_y 90),
                                  (translate -0.05, 0, 0),
                                  (rotate_x Kernel.tick_count),
                                  (rotate_y Kernel.tick_count),
                                  (rotate_z Kernel.tick_count)

  args.state.right = mul_triangles args,
                                   args.state.a,
                                   (translate -0.05, -0.05, 0),
                                   (rotate_y 90),
                                   (translate  0.05, 0, 0),
                                   (rotate_x Kernel.tick_count),
                                   (rotate_y Kernel.tick_count),
                                   (rotate_z Kernel.tick_count)

  args.state.top = mul_triangles args,
                                 args.state.a,
                                 (translate -0.05, -0.05, 0),
                                 (rotate_x 90),
                                 (translate 0, 0.05, 0),
                                 (rotate_x Kernel.tick_count),
                                 (rotate_y Kernel.tick_count),
                                 (rotate_z Kernel.tick_count)

  args.state.bottom = mul_triangles args,
                                    args.state.a,
                                    (translate -0.05, -0.05, 0),
                                    (rotate_x 90),
                                    (translate 0, -0.05, 0),
                                    (rotate_x Kernel.tick_count),
                                    (rotate_y Kernel.tick_count),
                                    (rotate_z Kernel.tick_count)

  render_square args, args.state.back
  render_square args, args.state.front
  render_square args, args.state.left
  render_square args, args.state.right
  render_square args, args.state.top
  render_square args, args.state.bottom
end

def render_square args, triangles
  args.outputs.sprites << { x:  triangles[0][0].x * 1280,
                            y:  triangles[0][0].y * 1280,
                            z:  triangles[0][0].z * 1280,
                            x2: triangles[0][1].x * 1280,
                            y2: triangles[0][1].y * 1280,
                            z2: triangles[0][1].z * 1280,
                            x3: triangles[0][2].x * 1280,
                            y3: triangles[0][2].y * 1280,
                            z3: triangles[0][2].z * 1280,
                            a: 255,
                            source_x:   0,
                            source_y:   0,
                            source_x2: 80,
                            source_y2:  0,
                            source_x3:  0,
                            source_y3: 80,
                            path: 'sprites/square/red.png' }

  args.outputs.sprites << { x:  triangles[1][0].x * 1280,
                            y:  triangles[1][0].y * 1280,
                            z:  triangles[1][0].z * 1280,
                            x2: triangles[1][1].x * 1280,
                            y2: triangles[1][1].y * 1280,
                            z2: triangles[1][1].z * 1280,
                            x3: triangles[1][2].x * 1280,
                            y3: triangles[1][2].y * 1280,
                            z3: triangles[1][2].z * 1280,
                            a: 255,
                            source_x:  80,
                            source_y:   0,
                            source_x2: 80,
                            source_y2: 80,
                            source_x3:  0,
                            source_y3: 80,
                            path: 'sprites/square/red.png' }
end

def mul_triangles args, triangles, *mul_def
  triangles.map do |vecs|
    vecs.map do |vec|
      mul vec, *mul_def
    end
  end
end

def scale scale
  mat4 scale,     0,     0,   0,
           0, scale,     0,   0,
           0,     0, scale,   0,
           0,     0,     0,   1
end

def rotate_y angle_d
  cos_t = Math.cos angle_d.to_radians
  sin_t = Math.sin angle_d.to_radians
  mat4  cos_t,  0, sin_t, 0,
        0,      1, 0,     0,
        -sin_t, 0, cos_t, 0,
        0,      0, 0,     1
end

def rotate_z angle_d
  cos_t = Math.cos angle_d.to_radians
  sin_t = Math.sin angle_d.to_radians
  mat4 cos_t, -sin_t, 0, 0,
       sin_t,  cos_t, 0, 0,
       0,      0,     1, 0,
       0,      0,     0, 1
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
  mat4  1,     0,      0, 0,
        0, cos_t, -sin_t, 0,
        0, sin_t,  cos_t, 0,
        0,     0,      0, 1
end
