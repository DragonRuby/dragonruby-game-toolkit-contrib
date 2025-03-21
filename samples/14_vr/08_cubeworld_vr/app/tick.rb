class Game
  include MatrixFunctions

  attr_gtk

  def cube x:, y:, z:, angle_x:, angle_y:, angle_z:;
    combined = mul (rotate_x angle_x),
                   (rotate_y angle_y),
                   (rotate_z angle_z),
                   (translate x, y, z)

    face_1 = mul_triangles state.baseline_cube.face_1, combined
    face_2 = mul_triangles state.baseline_cube.face_2, combined
    face_3 = mul_triangles state.baseline_cube.face_3, combined
    face_4 = mul_triangles state.baseline_cube.face_4, combined
    face_5 = mul_triangles state.baseline_cube.face_5, combined
    face_6 = mul_triangles state.baseline_cube.face_6, combined

    [
      face_1,
      face_2,
      face_3,
      face_4,
      face_5,
      face_6
    ]
  end

  def random_point
    r = { xr: 2.randomize(:ratio) - 1,
          yr: 2.randomize(:ratio) - 1,
          zr: 2.randomize(:ratio) - 1 }
    if (r.xr ** 2 + r.yr ** 2 + r.zr ** 2) > 1.0
      return random_point
    else
      return r
    end
  end

  def random_cube_attributes
    state.cube_count.map_with_index do |i|
      point_on_sphere = random_point
      radius = rand * 10 + 3
      {
        x: point_on_sphere.xr * radius,
        y: point_on_sphere.yr * radius,
        z: 6.4 + point_on_sphere.zr * radius
      }
    end
  end

  def defaults
    state.cube_count ||= 1
    state.cube_attributes ||= random_cube_attributes
    if !state.baseline_cube
      state.baseline_cube = {
        face_1: [
          [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
          [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
        ],
        face_2: [
          [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
          [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
        ],
        face_3: [
          [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
          [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
        ],
        face_4: [
          [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
          [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
        ],
        face_5: [
          [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
          [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
        ],
        face_6: [
          [vec4(0, 0, 0, 1),   vec4(0.5, 0, 0, 1),   vec4(0, 0.5, 0, 1)],
          [vec4(0.5, 0, 0, 1), vec4(0.5, 0.5, 0, 1), vec4(0, 0.5, 0, 1)]
        ]
      }

      state.baseline_cube.face_1 = mul_triangles state.baseline_cube.face_1,
                                                 (translate -0.25, -0.25, 0),
                                                 (translate  0, 0, 0.25)

      state.baseline_cube.face_2 = mul_triangles state.baseline_cube.face_2,
                                                 (translate -0.25, -0.25, 0),
                                                 (translate  0, 0, -0.25)

      state.baseline_cube.face_3 = mul_triangles state.baseline_cube.face_3,
                                                 (translate -0.25, -0.25, 0),
                                                 (rotate_y 90),
                                                 (translate -0.25,  0, 0)

      state.baseline_cube.face_4 = mul_triangles state.baseline_cube.face_4,
                                                 (translate -0.25, -0.25, 0),
                                                 (rotate_y 90),
                                                 (translate  0.25,  0, 0)

      state.baseline_cube.face_5 = mul_triangles state.baseline_cube.face_5,
                                                 (translate -0.25, -0.25, 0),
                                                 (rotate_x 90),
                                                 (translate  0,  0.25, 0)

      state.baseline_cube.face_6 = mul_triangles state.baseline_cube.face_6,
                                                 (translate -0.25, -0.25, 0),
                                                 (rotate_x 90),
                                                 (translate  0,  -0.25, 0)
    end
  end

  def tick
    args.grid.origin_center!
    defaults

    if inputs.controller_one.key_down.a
      state.cube_count += 1
      state.cube_attributes = random_cube_attributes
    elsif inputs.controller_one.key_down.b
      state.cube_count -= 1 if state.cube_count > 1
      state.cube_attributes = random_cube_attributes
    end

    state.cube_attributes.each do |c|
      render_cube (cube x: c.x, y: c.y, z: c.z,
                        angle_x: Kernel.tick_count,
                        angle_y: Kernel.tick_count,
                        angle_z: Kernel.tick_count)
    end

    args.outputs.background_color = [255, 255, 255]
    framerate_primitives = GTK.current_framerate_primitives
    framerate_primitives.find { |p| p.text }.each { |p| p.z = 1 }
    framerate_primitives[-1].text = "cube count: #{state.cube_count} (#{state.cube_count * 12} triangles)"
    args.outputs.primitives << framerate_primitives
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

  def mul_triangles model, *mul_def
    model.map do |vecs|
      vecs.map do |vec|
        vec = mul vec, *mul_def
      end
    end
  end

  def render_cube cube
    render_face cube[0]
    render_face cube[1]
    render_face cube[2]
    render_face cube[3]
    render_face cube[4]
    render_face cube[5]
  end

  def render_face face
    triangle_1 = face[0]
    args.outputs.sprites << {
      x:  triangle_1[0].x * 100,   y: triangle_1[0].y * 100,  z: triangle_1[0].z * 100,
      x2: triangle_1[1].x * 100,  y2: triangle_1[1].y * 100, z2: triangle_1[1].z * 100,
      x3: triangle_1[2].x * 100,  y3: triangle_1[2].y * 100, z3: triangle_1[2].z * 100,
      source_x:   0, source_y:   0,
      source_x2: 80, source_y2:  0,
      source_x3:  0, source_y3: 80,
      path: 'sprites/square/blue.png'
    }

    triangle_2 = face[1]
    args.outputs.sprites << {
      x:  triangle_2[0].x * 100,   y: triangle_2[0].y * 100,  z: triangle_2[0].z * 100,
      x2: triangle_2[1].x * 100,  y2: triangle_2[1].y * 100, z2: triangle_2[1].z * 100,
      x3: triangle_2[2].x * 100,  y3: triangle_2[2].y * 100, z3: triangle_2[2].z * 100,
      source_x:  80, source_y:   0,
      source_x2: 80, source_y2: 80,
      source_x3:  0, source_y3: 80,
      path: 'sprites/square/blue.png'
    }
  end
end
