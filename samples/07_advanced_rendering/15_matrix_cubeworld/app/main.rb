require 'app/modeling-api.rb'

include MatrixFunctions

def tick args
  args.outputs.labels << { x: 0,
                           y: 30.from_top,
                           text: "W,A,S,D to move. Mouse to look. Triangles is a Indie/Pro Feature and will be ignored in Standard.",
                           alignment_enum: 1 }

  args.grid.origin_center!

  args.state.cam_y ||= 0.00
  if args.inputs.keyboard.i
    args.state.cam_y += 0.01
  elsif args.inputs.keyboard.k
    args.state.cam_y -= 0.01
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

  args.state.cam_z ||= 6.4
  if args.inputs.keyboard.up
    point_1 = { x: 0, y: 0.02 }
    point_r = args.geometry.rotate_point point_1, args.state.cam_angle_y
    args.state.cam_x -= point_r.x
    args.state.cam_z -= point_r.y
  elsif args.inputs.keyboard.down
    point_1 = { x: 0, y: -0.02 }
    point_r = args.geometry.rotate_point point_1, args.state.cam_angle_y
    args.state.cam_x -= point_r.x
    args.state.cam_z -= point_r.y
  end

  args.state.cam_x ||= 0.00
  if args.inputs.keyboard.right
    point_1 = { x: -0.02, y: 0 }
    point_r = args.geometry.rotate_point point_1, args.state.cam_angle_y
    args.state.cam_x -= point_r.x
    args.state.cam_z -= point_r.y
  elsif args.inputs.keyboard.left
    point_1 = { x:  0.02, y: 0 }
    point_r = args.geometry.rotate_point point_1, args.state.cam_angle_y
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

  if !args.state.models
    args.state.models = []
    25.times do
      args.state.models.concat new_random_cube
    end
  end

  args.state.models.each do |m|
    render_triangles args, m
  end

  args.outputs.lines << { x:   0, y: -50, h: 100, a: 80 }
  args.outputs.lines << { x: -50, y:   0, w: 100, a: 80 }
end

def mul_triangles model, *mul_def
  combined = mul mul_def
  model.map do |vecs|
    vecs.map do |vec|
      mul vec, *combined
    end
  end
end

def mul_cam args, world_vecs
  mul_triangles world_vecs,
                (translate -args.state.cam_x, -args.state.cam_y, -args.state.cam_z),
                (rotate_y args.state.cam_angle_y),
                (rotate_x args.state.cam_angle_x)
end

def mul_perspective camera_vecs
  camera_vecs.map do |vecs|
    r = vecs.map do |vec|
      perspective vec
    end

    r if r[0] && r[1] && r[2]
  end.reject_nil
end

def render_debug args, model, transform, projected
  args.outputs.labels << { x: -630, y:  10.from_top,  text: "model:     #{vecs_to_s model[0]}" }
  args.outputs.labels << { x: -630, y:  30.from_top,  text: "           #{vecs_to_s model[1]}" }
  args.outputs.labels << { x: -630, y:  50.from_top,  text: "transform: #{vecs_to_s transform[0]}" }
  args.outputs.labels << { x: -630, y:  70.from_top,  text: "           #{vecs_to_s transform[1]}" }
  args.outputs.labels << { x: -630, y:  90.from_top,  text: "projected: #{vecs_to_s projected[0]}" }
  args.outputs.labels << { x: -630, y: 110.from_top,  text: "           #{vecs_to_s projected[1]}" }
end

def render_triangles args, triangles
  camera_space = mul_cam args, triangles
  projection = mul_perspective camera_space

  args.outputs.sprites << projection.map_with_index do |i, index|
    if i
      {
        x:  i[0].x,   y: i[0].y,
        x2: i[1].x,  y2: i[1].y,
        x3: i[2].x,  y3: i[2].y,
        source_x:   0, source_y:   0,
        source_x2: 80, source_y2:  0,
        source_x3:  0, source_y3: 80,
        r: 128, g: 128, b: 128,
        a: 80 + 128 * 1 / (index + 1),
        path: :pixel
      }
    end
  end
end

def perspective vec
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

  p = mat4 sx, 0, 0, tx,
           0, sy, 0, ty,
           0, 0, c2, c1,
           0, 0, -1, 0

  r = mul vec, p
  return nil if r.w < 0
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

def new_random_cube
  cube_w = rand * 0.2 + 0.1
  cube_h = rand * 0.2 + 0.1
  randx = rand * 2.0 * [1, -1].sample
  randy = rand * 2.0
  randz = rand * 5   * [1, -1].sample

  cube = [
    square do
      scale x: cube_w, y: cube_h
      translate x: -cube_w / 2, y: -cube_h / 2
      rotate_x 90
      translate y: -cube_h / 2
      translate x: randx, y: randy, z: randz
    end,
    square do
      scale x: cube_w, y: cube_h
      translate x: -cube_w / 2, y: -cube_h / 2
      rotate_x 90
      translate y:  cube_h / 2
      translate x: randx, y: randy, z: randz
    end,
    square do
      scale x: cube_h, y: cube_h
      translate x: -cube_h / 2, y: -cube_h / 2
      rotate_y 90
      translate x: -cube_w / 2
      translate x: randx, y: randy, z: randz
    end,
    square do
      scale x: cube_h, y: cube_h
      translate x: -cube_h / 2, y: -cube_h / 2
      rotate_y 90
      translate x:  cube_w / 2
      translate x: randx, y: randy, z: randz
    end,
    square do
      scale x: cube_w, y: cube_h
      translate x: -cube_w / 2, y: -cube_h / 2
      translate z: -cube_h / 2
      translate x: randx, y: randy, z: randz
    end,
    square do
      scale x: cube_w, y: cube_h
      translate x: -cube_w / 2, y: -cube_h / 2
      translate z:  cube_h / 2
      translate x: randx, y: randy, z: randz
    end
  ]

  cube
end

$gtk.reset
