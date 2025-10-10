require 'app/modeling-api.rb'

def boot args
  Grid.origin_center!
end

def default args
  args.outputs.watch GTK.current_framerate
  args.outputs.labels << { x: 0,
                           y: 30.from_top,
                           text: "W,A,S,D to move. Mouse to look.",
                           alignment_enum: 1 }

  args.state.cam_y       ||= 0.00
  args.state.cam_angle_y ||= 0
  args.state.cam_angle_x ||= 0
  args.state.cam_z       ||= 6.4
  args.state.cam_x       ||= 0.00

  args.state.models ||= 50.map do
    new_random_cube
  end

  args.state.perspective_matrix ||= begin
                                      left   =  100.0
                                      right  = -100.0
                                      bottom =  100.0
                                      top    = -100.0
                                      near   =  3000.0
                                      far    =  8000.0
                                      sx = 2 * near / (right - left)
                                      sy = 2 * near / (top - bottom)
                                      c2 = - (far + near) / (far - near)
                                      c1 = 2 * near * far / (near - far)
                                      tx = -near * (left + right) / (right - left)
                                      ty = -near * (bottom + top) / (top - bottom)

                                      Matrix.mat4 sx, 0, 0, tx,
                                                  0, sy, 0, ty,
                                                  0, 0, c2, c1,
                                                  0, 0, -1, 0
                                    end

end

def tick args
  default args
  inputs args

  camera_matrix = Matrix.mul (translate -args.state.cam_x, -args.state.cam_y, -args.state.cam_z),
                             (rotate_y args.state.cam_angle_y),
                             (rotate_x args.state.cam_angle_x)

  args.outputs.sprites << args.state
                              .models
                              .flat_map { |model| model.triangles }
                              .map { |triangle| projected_triangle triangle, camera_matrix, args.state.perspective_matrix }
                              .compact
                              .sort_by { |triangle| -((triangle[0].z + triangle[1].z + triangle[2].z) / 3) }
                              .map { |triangle| prefab_triangle triangle, camera_matrix }

  args.outputs.lines << { x:   0, y: -50, h: 100, a: 80 }
  args.outputs.lines << { x: -50, y:   0, w: 100, a: 80 }
end

def inputs args
  if args.inputs.keyboard.i
    args.state.cam_y += 0.01
  elsif args.inputs.keyboard.k
    args.state.cam_y -= 0.01
  end

  if args.inputs.keyboard.q
    args.state.cam_angle_y += 0.25
  elsif args.inputs.keyboard.e
    args.state.cam_angle_y -= 0.25
  end

  if args.inputs.keyboard.u
    args.state.cam_angle_x += 0.1
  elsif args.inputs.keyboard.o
    args.state.cam_angle_x -= 0.1
  end

  if args.inputs.mouse.has_focus
    y_change_rate = (args.inputs.mouse.x / 640) ** 2
    if args.inputs.mouse.x < 0
      args.state.cam_angle_y -= 0.8 * y_change_rate
    else
      args.state.cam_angle_y += 0.8 * y_change_rate
    end

    x_change_rate = (args.inputs.mouse.y / 360) ** 2
    if args.inputs.mouse.y < 0
      args.state.cam_angle_x += 0.8 * x_change_rate
    else
      args.state.cam_angle_x -= 0.8 * x_change_rate
    end
  end

  if args.inputs.keyboard.up
    point_1 = { x: 0, y: 0.02 }
    point_r = Geometry.rotate_point point_1, args.state.cam_angle_y
    args.state.cam_x -= point_r.x
    args.state.cam_z -= point_r.y
  elsif args.inputs.keyboard.down
    point_1 = { x: 0, y: -0.02 }
    point_r = Geometry.rotate_point point_1, args.state.cam_angle_y
    args.state.cam_x -= point_r.x
    args.state.cam_z -= point_r.y
  end

  if args.inputs.keyboard.right
    point_1 = { x: -0.02, y: 0 }
    point_r = Geometry.rotate_point point_1, args.state.cam_angle_y
    args.state.cam_x -= point_r.x
    args.state.cam_z -= point_r.y
  elsif args.inputs.keyboard.left
    point_1 = { x:  0.02, y: 0 }
    point_r = Geometry.rotate_point point_1, args.state.cam_angle_y
    args.state.cam_x -= point_r.x
    args.state.cam_z -= point_r.y
  end

  if args.inputs.keyboard.key_down.r || args.inputs.keyboard.key_down.zero
    args.state.cam_x = 0.00
    args.state.cam_y = 0.00
    args.state.cam_z = 1.00
    args.state.cam_angle_y = 0
    args.state.cam_angle_x = 0
  end
end

def projected_triangle triangle, camera_matrix, perspective_matrix
  triangle_in_camera = mul_cam_triangle triangle, camera_matrix
  mul_perspective_triangle triangle_in_camera, perspective_matrix
end

def mul_cam_triangle triangle, camera_matrix
  mul_triangle triangle, camera_matrix
end

def mul_triangle triangle, mul_def
  Array.map triangle do |vec|
    Matrix.mul vec, mul_def
  end
end

def mul_perspective_triangle triangle, perspective_matrix
  v0 = perspective_vec triangle[0], perspective_matrix
  v1 = perspective_vec triangle[1], perspective_matrix
  v2 = perspective_vec triangle[2], perspective_matrix
  [v0, v1, v2] if v0 && v1 && v2
end

def prefab_triangle triangle, camera_matrix
  {
    x:  triangle[0].x,   y: triangle[0].y,
    x2: triangle[1].x,  y2: triangle[1].y,
    x3: triangle[2].x,  y3: triangle[2].y,
    source_x:   0, source_y:   0,
    source_x2: 80, source_y2:  0,
    source_x3:  0, source_y3: 80,
    path: "sprites/square/blue.png"
  }
end

def perspective_vec vec, perspective_matrix
  r = Matrix.mul vec, perspective_matrix
  return nil if r.w < 0
  r.x *= r.z / r.w / 100
  r.y *= r.z / r.w / 100
  r
end

def mat_scale scale
  Matrix.mat4 scale,     0,     0,   0,
              0, scale,     0,   0,
              0,     0, scale,   0,
              0,     0,     0,   1
end

def rotate_y angle_d
  cos_t = Math.cos angle_d.to_radians
  sin_t = Math.sin angle_d.to_radians
  Matrix.mat4  cos_t,  0, sin_t, 0,
               0,      1, 0,     0,
               -sin_t, 0, cos_t, 0,
               0,      0, 0,     1
end

def rotate_z angle_d
  cos_t = Math.cos angle_d.to_radians
  sin_t = Math.sin angle_d.to_radians
  Matrix.mat4 cos_t, -sin_t, 0, 0,
              sin_t,  cos_t, 0, 0,
              0,      0,     1, 0,
              0,      0,     0, 1
end

def translate dx, dy, dz
  Matrix.mat4 1, 0, 0, dx,
              0, 1, 0, dy,
              0, 0, 1, dz,
              0, 0, 0,  1
end


def rotate_x angle_d
  cos_t = Math.cos angle_d.to_radians
  sin_t = Math.sin angle_d.to_radians
  Matrix.mat4  1,     0,      0, 0,
               0, cos_t, -sin_t, 0,
               0, sin_t,  cos_t, 0,
               0,     0,      0, 1
end

def new_random_cube
  cube_w = rand * 0.2 + 0.1
  cube_h = rand * 0.2 + 0.1
  randx = Numeric.rand(-3.0..3.0)
  randy = Numeric.rand(-2.0..2.0)
  randz = Numeric.rand(-10.0..-5.0)

  cube = { triangles: [] }

  cube.triangles.concat(cube_side do
    scale x: cube_w, y: cube_h
    translate x: -cube_w / 2, y: -cube_h / 2
    rotate_x 90
    translate y: -cube_h / 2
    translate x: randx, y: randy, z: randz
  end)

  cube.triangles.concat(cube_side do
    scale x: cube_w, y: cube_h
    translate x: -cube_w / 2, y: -cube_h / 2
    rotate_x 90
    translate y:  cube_h / 2
    translate x: randx, y: randy, z: randz
  end)

  cube.triangles.concat(cube_side do
    scale x: cube_h, y: cube_h
    translate x: -cube_h / 2, y: -cube_h / 2
    rotate_y 90
    translate x: -cube_w / 2
    translate x: randx, y: randy, z: randz
  end)

  cube.triangles.concat(cube_side do
    scale x: cube_h, y: cube_h
    translate x: -cube_h / 2, y: -cube_h / 2
    rotate_y 90
    translate x:  cube_w / 2
    translate x: randx, y: randy, z: randz
  end)

  cube.triangles.concat(cube_side do
    scale x: cube_w, y: cube_h
    translate x: -cube_w / 2, y: -cube_h / 2
    translate z: -cube_h / 2
    translate x: randx, y: randy, z: randz
  end)

  cube.triangles.concat(cube_side do
    scale x: cube_w, y: cube_h
    translate x: -cube_w / 2, y: -cube_h / 2
    translate z:  cube_h / 2
    translate x: randx, y: randy, z: randz
  end)

  cube
end

GTK.reset
