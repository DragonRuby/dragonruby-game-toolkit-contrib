def tick args
  args.state.id_seed    ||= 1
  args.state.bullets    ||= []
  args.state.terrain    ||= [
    {
      x: 40, y: 0, w: 1200, h: 40, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 1240, y: 0, w: 40, h: 720, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 0, y: 0, w: 40, h: 720, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 40, y: 680, w: 1200, h: 40, path: :pixel, r: 0, g: 0, b: 0
    },

    {
      x: 760, y: 420, w: 180, h: 40, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 720, y: 420, w: 40, h: 100, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 940, y: 420, w: 40, h: 100, path: :pixel, r: 0, g: 0, b: 0
    },

    {
      x: 660, y: 220, w: 280, h: 40, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 620, y: 220, w: 40, h: 100, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 940, y: 220, w: 40, h: 100, path: :pixel, r: 0, g: 0, b: 0
    },

    {
      x: 460, y: 40, w: 280, h: 40, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 420, y: 40, w: 40, h: 100, path: :pixel, r: 0, g: 0, b: 0
    },
    {
      x: 740, y: 40, w: 40, h: 100, path: :pixel, r: 0, g: 0, b: 0
    },
  ]

  if args.inputs.keyboard.space
      b = {
        id: args.state.id_seed,
        x: 60,
        y: 60,
        w: 10,
        h: 10,
        dy: rand(20) + 10,
        dx: rand(20) + 10,
        path: 'sprites/square/blue.png'
      }

      args.state.bullets << b # if b.id == 122

      args.state.id_seed += 1
  end

  terrain = args.state.terrain

  args.state.bullets.each do |b|
    next if b.still
    # if b.still
    #   x_dir = if rand > 0.5
    #             -1
    #           else
    #             1
    #           end

    #   y_dir = if rand > 0.5
    #             -1
    #           else
    #             1
    #           end

    #   b.dy = rand(20) + 10 * x_dir
    #   b.dx = rand(20) + 10 * y_dir
    #   b.still = false
    #   b.on_floor = false
    # end

    if b.on_floor
      b.dx *= 0.9
    end

    b.x += b.dx

    collision_x = args.geometry.find_intersect_rect(b, terrain)

    if collision_x
      if b.dx > 0
        b.x = collision_x.x - b.w
      elsif b.dx < 0
        b.x = collision_x.x + collision_x.w
      end
      b.dx *= -0.8
    end

    b.dy -= 0.25
    b.y += b.dy

    collision_y = args.geometry.find_intersect_rect(b, terrain)

    if collision_y
      if b.dy > 0
        b.y = collision_y.y - b.h
      elsif b.dy < 0
        b.y = collision_y.y + collision_y.h
      end

      if b.dy < 0 && b.dy.abs < 1
        b.on_floor = true
      end

      b.dy *= -0.8
    end

    if b.on_floor && (b.dy.abs + b.dx.abs) < 0.1
      b.still = true
    end
  end

  args.outputs.labels << { x: 60, y: 60.from_top, text: "Hold space bar to add squares." }
  args.outputs.labels << { x: 60, y: 90.from_top, text: "FPS: #{args.gtk.current_framerate.to_sf}" }
  args.outputs.labels << { x: 60, y: 120.from_top, text: "Count: #{args.state.bullets.length}" }
  args.outputs.borders << args.state.terrain
  args.outputs.sprites << args.state.bullets
end

# $gtk.reset
