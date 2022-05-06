include MatrixFunctions

def tick args
  args.state.square_one_sprite = { x:        0,
                                   y:        0,
                                   w:        100,
                                   h:        100,
                                   path:     "sprites/square/blue.png",
                                   source_x: 0,
                                   source_y: 0,
                                   source_w: 80,
                                   source_h: 80 }

  args.state.square_two_sprite = { x:        0,
                                   y:        0,
                                   w:        100,
                                   h:        100,
                                   path:     "sprites/square/red.png",
                                   source_x: 0,
                                   source_y: 0,
                                   source_w: 80,
                                   source_h: 80 }

  args.state.square_one        = sprite_to_triangles args.state.square_one_sprite
  args.state.square_two        = sprite_to_triangles args.state.square_two_sprite
  args.state.camera.x        ||= 0
  args.state.camera.y        ||= 0
  args.state.camera.zoom     ||= 1
  args.state.camera.rotation ||= 0

  zmod = 1
  move_multiplier = 1
  dzoom = 0.01

  if args.state.tick_count.zmod? zmod
    args.state.camera.x += args.inputs.left_right * -1 * move_multiplier
    args.state.camera.y += args.inputs.up_down * -1 * move_multiplier
  end

  if args.inputs.keyboard.i
    args.state.camera.zoom += dzoom
  elsif args.inputs.keyboard.o
    args.state.camera.zoom -= dzoom
  end

  args.state.camera.zoom = args.state.camera.zoom.clamp(0.25, 10)

  args.outputs.sprites << triangles_mat3_mul(args.state.square_one,
                                             mat3_translate(-50, -50),
                                             mat3_rotate(args.state.tick_count),
                                             mat3_translate(0, 0),
                                             mat3_translate(args.state.camera.x, args.state.camera.y),
                                             mat3_scale(args.state.camera.zoom),
                                             mat3_translate(640, 360))

  args.outputs.sprites << triangles_mat3_mul(args.state.square_two,
                                             mat3_translate(-50, -50),
                                             mat3_rotate(args.state.tick_count),
                                             mat3_translate(100, 100),
                                             mat3_translate(args.state.camera.x, args.state.camera.y),
                                             mat3_scale(args.state.camera.zoom),
                                             mat3_translate(640, 360))

  mouse_coord = vec3 args.inputs.mouse.x,
                     args.inputs.mouse.y,
                     1

  mouse_coord = mul mouse_coord,
                    mat3_translate(-640, -360),
                    mat3_scale(args.state.camera.zoom),
                    mat3_translate(-args.state.camera.x, -args.state.camera.y)

  args.outputs.lines  << { x: 640, y:   0, h:  720 }
  args.outputs.lines  << { x:   0, y: 360, w: 1280 }
  args.outputs.labels << { x: 30, y: 60.from_top, text: "x: #{args.state.camera.x.to_sf} y: #{args.state.camera.y.to_sf} z: #{args.state.camera.zoom.to_sf}" }
  args.outputs.labels << { x: 30, y: 90.from_top, text: "Mouse: #{mouse_coord.x.to_sf} #{mouse_coord.y.to_sf}" }
  args.outputs.labels << { x: 30,
                           y: 30.from_top,
                           text: "W,A,S,D to move. I, O to zoom. Triangles is a Indie/Pro Feature and will be ignored in Standard." }
end

def sprite_to_triangles sprite
  [
    {
      x:         sprite.x,                          y:  sprite.y,
      x2:        sprite.x,                          y2: sprite.y + sprite.h,
      x3:        sprite.x + sprite.w,               y3: sprite.y + sprite.h,
      source_x:  sprite.source_x,                   source_y:  sprite.source_y,
      source_x2: sprite.source_x,                   source_y2: sprite.source_y + sprite.source_h,
      source_x3: sprite.source_x + sprite.source_w, source_y3: sprite.source_y + sprite.source_h,
      path:      sprite.path
    },
    {
      x:  sprite.x,                                 y:  sprite.y,
      x2: sprite.x + sprite.w,                      y2: sprite.y + sprite.h,
      x3: sprite.x + sprite.w,                      y3: sprite.y,
      source_x:  sprite.source_x,                   source_y:  sprite.source_y,
      source_x2: sprite.source_x + sprite.source_w, source_y2: sprite.source_y + sprite.source_h,
      source_x3: sprite.source_x + sprite.source_w, source_y3: sprite.source_y,
      path:      sprite.path
    }
  ]
end

def mat3_translate dx, dy
  mat3 1, 0, dx,
       0, 1, dy,
       0, 0,  1
end

def mat3_rotate angle_d
  angle_r = angle_d.to_radians
  mat3 Math.cos(angle_r), -Math.sin(angle_r), 0,
       Math.sin(angle_r),  Math.cos(angle_r), 0,
                       0,                  0, 1
end

def mat3_scale scale
  mat3 scale,     0, 0,
           0, scale, 0,
           0,     0, 1
end

def triangles_mat3_mul triangles, *matrices
  triangles.map { |triangle| triangle_mat3_mul triangle, *matrices }
end

def triangle_mat3_mul triangle, *matrices
  result = [
    (vec3 triangle.x,  triangle.y,  1),
    (vec3 triangle.x2, triangle.y2, 1),
    (vec3 triangle.x3, triangle.y3, 1)
  ].map do |coord|
    mul coord, *matrices
  end

  {
    **triangle,
    x:  result[0].x,
    y:  result[0].y,
    x2: result[1].x,
    y2: result[1].y,
    x3: result[2].x,
    y3: result[2].y,
  }
rescue Exception => e
  pretty_print triangle
  pretty_print result
  pretty_print matrices
  puts "#{matrices}"
  raise e
end
