# https://github.com/BrennerLittle/DragonRubyRaycast
# https://github.com/3DSage/OpenGL-Raycaster_v1
# https://www.youtube.com/watch?v=gYRrGTC7GtA&ab_channel=3DSage

def tick args
  defaults args
  calc args
  render args
  args.outputs.sprites << { x: 0, y: 0, w: 1280 * 2.66, h: 720 * 2.25, path: :screen }
  args.outputs.labels  << { x: 30, y: 30.from_top, text: "FPS: #{args.gtk.current_framerate.to_sf}" }
end

def defaults args
  args.state.stage ||= {
    w: 8,
    h: 8,
    sz: 64,
    layout: [
      1, 1, 1, 1, 1, 1, 1, 1,
      1, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 0, 1, 0, 1,
      1, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 0, 1, 0, 1,
      1, 0, 0, 0, 0, 0, 0, 1,
      1, 1, 1, 1, 1, 1, 1, 1,
    ]
  }

  args.state.player ||= {
    x: 250,
    y: 250,
    dx: 1,
    dy: 0,
    angle: 0
  }
end

def calc args
  xo = 0

  if args.state.player.dx < 0
    xo = -20
  else
    xo = 20
  end

  yo = 0

  if args.state.player.dy < 0
    yo = -20
  else
    yo = 20
  end

  ipx = args.state.player.x.idiv 64.0
  ipx_add_xo = (args.state.player.x + xo).idiv 64.0
  ipx_sub_xo = (args.state.player.x - xo).idiv 64.0

  ipy = args.state.player.y.idiv 64.0
  ipy_add_yo = (args.state.player.y + yo).idiv 64.0
  ipy_sub_yo = (args.state.player.y - yo).idiv 64.0

  if args.inputs.keyboard.right
    args.state.player.angle -= 5
    args.state.player.angle = args.state.player.angle % 360
    args.state.player.dx = args.state.player.angle.cos_d
    args.state.player.dy = -args.state.player.angle.sin_d
  end

  if args.inputs.keyboard.left
    args.state.player.angle += 5
    args.state.player.angle = args.state.player.angle % 360
    args.state.player.dx = args.state.player.angle.cos_d
    args.state.player.dy = -args.state.player.angle.sin_d
  end

  if args.inputs.keyboard.up
    if args.state.stage.layout[ipy * args.state.stage.w + ipx_add_xo] == 0
      args.state.player.x += args.state.player.dx * 5
    end

    if args.state.stage.layout[ipy_add_yo * args.state.stage.w + ipx] == 0
      args.state.player.y += args.state.player.dy * 5
    end
  end

  if args.inputs.keyboard.down
    if args.state.stage.layout[ipy * args.state.stage.w + ipx_sub_xo] == 0
      args.state.player.x -= args.state.player.dx * 5
    end

    if args.state.stage.layout[ipy_sub_yo * args.state.stage.w + ipx] == 0
      args.state.player.y -= args.state.player.dy * 5
    end
  end
end

def render args
  args.outputs[:screen].sprites << { x: 0,
                                     y: 160,
                                     w: 750,
                                     h: 160,
                                     path: :pixel,
                                     r: 89,
                                     g: 125,
                                     b: 206 }

  args.outputs[:screen].sprites << { x: 0,
                                     y: 0,
                                     w: 750,
                                     h: 160,
                                     path: :pixel,
                                     r: 117,
                                     g: 113,
                                     b: 97 }


  ra = (args.state.player.angle + 30) % 360

  60.times do |r|
    dof = 0
    side = 0
    dis_v = 100000
    ra_tan = ra.tan_d

    if ra.cos_d > 0.001
      rx = ((args.state.player.x >> 6) << 6) + 64
      ry = (args.state.player.x - rx) * ra_tan + args.state.player.y;
      xo = 64
      yo = -xo * ra_tan
    elsif ra.cos_d < -0.001
      rx = ((args.state.player.x >> 6) << 6) - 0.0001
      ry = (args.state.player.x - rx) * ra_tan + args.state.player.y
      xo = -64
      yo = -xo * ra_tan
    else
      rx = args.state.player.x
      ry = args.state.player.y
      dof = 8
    end

    while dof < 8
      mx = rx >> 6
      mx = mx.to_i
      my = ry >> 6
      my = my.to_i
      mp = my * args.state.stage.w + mx
      if mp > 0 && mp < args.state.stage.w * args.state.stage.h && args.state.stage.layout[mp] == 1
        dof = 8
        dis_v = ra.cos_d * (rx - args.state.player.x) - ra.sin_d * (ry - args.state.player.y)
      else
        rx += xo
        ry += yo
        dof += 1
      end
    end

    vx = rx
    vy = ry

    dof = 0
    dis_h = 100000
    ra_tan = 1.0 / ra_tan

    if ra.sin_d > 0.001
      ry = ((args.state.player.y >> 6) << 6) - 0.0001;
      rx = (args.state.player.y - ry) * ra_tan + args.state.player.x;
      yo = -64;
      xo = -yo * ra_tan;
    elsif ra.sin_d < -0.001
      ry = ((args.state.player.y >> 6) << 6) + 64;
      rx = (args.state.player.y - ry) * ra_tan + args.state.player.x;
      yo = 64;
      xo = -yo * ra_tan;
    else
      rx = args.state.player.x
      ry = args.state.player.y
      dof = 8
    end

    while dof < 8
      mx = (rx) >> 6
      my = (ry) >> 6
      mp = my * args.state.stage.w + mx
      if mp > 0 && mp < args.state.stage.w * args.state.stage.h && args.state.stage.layout[mp] == 1
        dof = 8
        dis_h = ra.cos_d * (rx - args.state.player.x) - ra.sin_d * (ry - args.state.player.y)
      else
        rx += xo
        ry += yo
        dof += 1
      end
    end

    color = { r: 52, g: 101, b: 36 }

    if dis_v < dis_h
      rx = vx
      ry = vy
      dis_h = dis_v
      color = { r: 109, g: 170, b: 44 }
    end

    ca = (args.state.player.angle - ra) % 360
    dis_h = dis_h * ca.cos_d
    line_h = (args.state.stage.sz * 320) / (dis_h)
    line_h = 320 if line_h > 320

    line_off = 160 - (line_h >> 1)

    args.outputs[:screen].sprites << {
      x: r * 8,
      y: line_off,
      w: 8,
      h: line_h,
      path: :pixel,
      **color
    }

    ra = (ra - 1) % 360
  end
end
