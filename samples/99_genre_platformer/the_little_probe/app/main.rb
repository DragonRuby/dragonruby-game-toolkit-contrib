class FallingCircle
  attr_gtk

  def tick
    fiddle
    defaults
    render
    input
    calc
  end

  def fiddle
    state.gravity     = -0.02
    circle.radius     = 15
    circle.elasticity = 0.4
    camera.follow_speed = 0.4 * 0.4
  end

  def render
    render_stage_editor
    render_debug
    render_game
  end

  def defaults
    if state.tick_count == 0
      outputs.sounds << "sounds/bg.ogg"
    end

    state.storyline ||= [
      { text: "<- -> to aim, hold space to charge",                            distance_gate: 0 },
      { text: "the little probe - by @amirrajan, made with DragonRuby Game Toolkit", distance_gate: 0 },
      { text: "mission control, this is sasha. landing on europa successful.", distance_gate: 0 },
      { text: "operation \"find earth 2.0\", initiated at 8-29-2036 14:00.",   distance_gate: 0 },
      { text: "jupiter's sure is beautiful...",   distance_gate: 4000 },
      { text: "hmm, it seems there's some kind of anomoly in the sky",   distance_gate: 7000 },
      { text: "dancing lights, i'll call them whisps.",   distance_gate: 8000 },
      { text: "#todo... look i ran out of time -_-",   distance_gate: 9000 },
      { text: "there's never enough time",   distance_gate: 9000 },
      { text: "the game jam was fun though ^_^",   distance_gate: 10000 },
    ]

    load_level force: args.state.tick_count == 0
    state.line_mode            ||= :terrain

    state.sound_index          ||= 1
    circle.potential_lift      ||= 0
    circle.angle               ||= 90
    circle.check_point_at      ||= -1000
    circle.game_over_at        ||= -1000
    circle.x                   ||= -485
    circle.y                   ||= 12226
    circle.check_point_x       ||= circle.x
    circle.check_point_y       ||= circle.y
    circle.dy                  ||= 0
    circle.dx                  ||= 0
    circle.previous_dy         ||= 0
    circle.previous_dx         ||= 0
    circle.angle               ||= 0
    circle.after_images        ||= []
    circle.terrains_to_monitor ||= {}
    circle.impact_history      ||= []

    camera.x                   ||= 0
    camera.y                   ||= 0
    camera.target_x            ||= 0
    camera.target_y            ||= 0
    state.snaps                ||= { }
    state.snap_number            = 10

    args.state.storyline_x ||= -1000
    args.state.storyline_y ||= -1000
  end

  def render_game
    outputs.background_color = [0, 0, 0]
    outputs.sprites << [-circle.x + 1100,
                        -circle.y - 100,
                        2416 * 4,
                        3574 * 4,
                        'sprites/jupiter.png']
    outputs.sprites << [-circle.x,
                        -circle.y,
                        2416 * 4,
                        3574 * 4,
                        'sprites/level.png']
    outputs.sprites << state.whisp_queue
    render_aiming_retical
    render_circle
    render_notification
  end

  def render_notification
    toast_length = 500
    if circle.game_over_at.elapsed_time < toast_length
      label_text = "..."
    elsif circle.check_point_at.elapsed_time > toast_length
      args.state.current_storyline = nil
      return
    end
    if circle.check_point_at &&
       circle.check_point_at.elapsed_time == 1 &&
       !args.state.current_storyline
       if args.state.storyline.length > 0 && args.state.distance_traveled > args.state.storyline[0][:distance_gate]
         args.state.current_storyline = args.state.storyline.shift[:text]
         args.state.distance_traveled ||= 0
         args.state.storyline_x = circle.x
         args.state.storyline_y = circle.y
       end
      return unless args.state.current_storyline
    end
    label_text = args.state.current_storyline
    return unless label_text
    x = circle.x + camera.x
    y = circle.y + camera.y - 40
    w = 900
    h = 30
    outputs.primitives << [x - w.idiv(2), y - h, w, h, 255, 255, 255, 255].solid
    outputs.primitives << [x - w.idiv(2), y - h, w, h, 0, 0, 0, 255].border
    outputs.labels << [x, y - 4, label_text, 1, 1, 0, 0, 0, 255]
  end

  def render_aiming_retical
    outputs.sprites << [state.camera.x + circle.x + circle.angle.vector_x(circle.potential_lift * 10) - 5,
                        state.camera.y + circle.y + circle.angle.vector_y(circle.potential_lift * 10) - 5,
                        10, 10, 'sprites/circle-orange.png']
    outputs.sprites << [state.camera.x + circle.x + circle.angle.vector_x(circle.radius * 3) - 5,
                        state.camera.y + circle.y + circle.angle.vector_y(circle.radius * 3) - 5,
                        10, 10, 'sprites/circle-orange.png', 0, 128]
    if rand > 0.9
      outputs.sprites << [state.camera.x + circle.x + circle.angle.vector_x(circle.radius * 3) - 5,
                          state.camera.y + circle.y + circle.angle.vector_y(circle.radius * 3) - 5,
                          10, 10, 'sprites/circle-white.png', 0, 128]
    end
  end

  def render_circle
    outputs.sprites << circle.after_images.map do |ai|
      ai.merge(x: ai.x + state.camera.x - circle.radius,
               y: ai.y + state.camera.y - circle.radius,
               w: circle.radius * 2,
               h: circle.radius * 2,
               path: 'sprites/circle-white.png')
    end

    outputs.sprites << [(circle.x - circle.radius) + state.camera.x,
                        (circle.y - circle.radius) + state.camera.y,
                        circle.radius * 2,
                        circle.radius * 2,
                        'sprites/probe.png']
  end

  def render_debug
    return unless state.debug_mode

    outputs.labels << [10, 30, state.line_mode, 0, 0, 0, 0, 0]
    outputs.labels << [12, 32, state.line_mode, 0, 0, 255, 255, 255]

    args.outputs.lines << trajectory(circle).line.to_hash.tap do |h|
      h[:x] += state.camera.x
      h[:y] += state.camera.y
      h[:x2] += state.camera.x
      h[:y2] += state.camera.y
    end

    outputs.primitives << state.terrain.find_all do |t|
      circle.x.between?(t.x - 640, t.x2 + 640) || circle.y.between?(t.y - 360, t.y2 + 360)
    end.map do |t|
      [
        t.line.associate(r: 0, g: 255, b: 0) do |h|
          h.x  += state.camera.x
          h.y  += state.camera.y
          h.x2 += state.camera.x
          h.y2 += state.camera.y
          if circle.rect.intersect_rect? t[:rect]
            h[:r] = 255
            h[:g] = 0
          end
          h
        end,
        t[:rect].border.associate(r: 255, g: 0, b: 0) do |h|
          h.x += state.camera.x
          h.y += state.camera.y
          h.b = 255 if line_near_rect? circle.rect, t
          h
        end
      ]
    end

    outputs.primitives << state.lava.find_all do |t|
      circle.x.between?(t.x - 640, t.x2 + 640) || circle.y.between?(t.y - 360, t.y2 + 360)
    end.map do |t|
      [
        t.line.associate(r: 0, g: 0, b: 255) do |h|
          h.x  += state.camera.x
          h.y  += state.camera.y
          h.x2 += state.camera.x
          h.y2 += state.camera.y
          if circle.rect.intersect_rect? t[:rect]
            h[:r] = 255
            h[:b] = 0
          end
          h
        end,
        t[:rect].border.associate(r: 255, g: 0, b: 0) do |h|
          h.x += state.camera.x
          h.y += state.camera.y
          h.b = 255 if line_near_rect? circle.rect, t
          h
        end
      ]
    end

    if state.god_mode
      border = circle.rect.merge(x: circle.rect.x + state.camera.x,
                                 y: circle.rect.y + state.camera.y,
                                 g: 255)
    else
      border = circle.rect.merge(x: circle.rect.x + state.camera.x,
                                 y: circle.rect.y + state.camera.y,
                                 b: 255)
    end

    outputs.borders << border

    overlapping ||= {}

    circle.impact_history.each do |h|
      label_mod = 300
      x = (h[:body][:x].-(150).idiv(label_mod)) * label_mod + camera.x
      y = (h[:body][:y].+(150).idiv(label_mod)) * label_mod + camera.y
      10.times do
        if overlapping[x] && overlapping[x][y]
          y -= 52
        else
          break
        end
      end

      overlapping[x] ||= {}
      overlapping[x][y] ||= true
      outputs.primitives << [x, y - 25, 300, 50, 0, 0, 0, 128].solid
      outputs.labels << [x + 10, y + 24, "dy: %.2f" % h[:body][:new_dy], -2, 0, 255, 255, 255]
      outputs.labels << [x + 10, y +  9, "dx: %.2f" % h[:body][:new_dx], -2, 0, 255, 255, 255]
      outputs.labels << [x + 10, y -  5, " ?: #{h[:body][:new_reason]}", -2, 0, 255, 255, 255]

      outputs.labels << [x + 100, y + 24, "angle: %.2f" % h[:impact][:angle], -2, 0, 255, 255, 255]
      outputs.labels << [x + 100, y + 9, "m(l): %.2f" % h[:terrain][:slope], -2, 0, 255, 255, 255]
      outputs.labels << [x + 100, y - 5, "m(c): %.2f" % h[:body][:slope], -2, 0, 255, 255, 255]

      outputs.labels << [x + 200, y + 24, "ray: #{h[:impact][:ray]}", -2, 0, 255, 255, 255]
      outputs.labels << [x + 200, y +  9, "nxt: #{h[:impact][:ray_next]}", -2, 0, 255, 255, 255]
      outputs.labels << [x + 200, y -  5, "typ: #{h[:impact][:type]}", -2, 0, 255, 255, 255]
    end

    if circle.floor
      outputs.labels << [circle.x + camera.x + 30, circle.y + camera.y + 100, "point: #{circle.floor_point.slice(:x, :y).values}", -2, 0]
      outputs.labels << [circle.x + camera.x + 31, circle.y + camera.y + 101, "point: #{circle.floor_point.slice(:x, :y).values}", -2, 0, 255, 255, 255]
      outputs.labels << [circle.x + camera.x + 30, circle.y + camera.y +  85, "circle: #{circle.as_hash.slice(:x, :y).values}", -2, 0]
      outputs.labels << [circle.x + camera.x + 31, circle.y + camera.y +  86, "circle: #{circle.as_hash.slice(:x, :y).values}", -2, 0, 255, 255, 255]
      outputs.labels << [circle.x + camera.x + 30, circle.y + camera.y +  70, "rel: #{circle.floor_relative_x} #{circle.floor_relative_y}", -2, 0]
      outputs.labels << [circle.x + camera.x + 31, circle.y + camera.y +  71, "rel: #{circle.floor_relative_x} #{circle.floor_relative_y}", -2, 0, 255, 255, 255]
    end
  end

  def render_stage_editor
    return unless state.god_mode
    return unless state.point_one
    args.lines << [state.point_one, inputs.mouse.point, 0, 255, 255]
  end

  def trajectory body
    [body.x + body.dx,
     body.y + body.dy,
     body.x + body.dx * 1000,
     body.y + body.dy * 1000,
     0, 255, 255]
  end

  def lengthen_line line, num
    line = normalize_line(line)
    slope = geometry.line_slope(line, replace_infinity: 10).abs
    if slope < 2
      [line.x - num, line.y, line.x2 + num, line.y2].line.to_hash
    else
      [line.x, line.y, line.x2, line.y2].line.to_hash
    end
  end

  def normalize_line line
    if line.x > line.x2
      x  = line.x2
      y  = line.y2
      x2 = line.x
      y2 = line.y
    else
      x  = line.x
      y  = line.y
      x2 = line.x2
      y2 = line.y2
    end
    [x, y, x2, y2]
  end

  def rect_for_line line
    if line.x > line.x2
      x  = line.x2
      y  = line.y2
      x2 = line.x
      y2 = line.y
    else
      x  = line.x
      y  = line.y
      x2 = line.x2
      y2 = line.y2
    end

    w = x2 - x
    h = y2 - y

    if h < 0
      y += h
      h = h.abs
    end

    if w < circle.radius
      x -= circle.radius
      w = circle.radius * 2
    end

    if h < circle.radius
      y -= circle.radius
      h = circle.radius * 2
    end

    { x: x, y: y, w: w, h: h }
  end

  def snap_to_grid x, y, snaps
    snap_number = 10
    x = x.to_i
    y = y.to_i

    x_floor = x.idiv(snap_number) * snap_number
    x_mod   = x % snap_number
    x_ceil  = (x.idiv(snap_number) + 1) * snap_number

    y_floor = y.idiv(snap_number) * snap_number
    y_mod   = y % snap_number
    y_ceil  = (y.idiv(snap_number) + 1) * snap_number

    if snaps[x_floor]
      x_result = x_floor
    elsif snaps[x_ceil]
      x_result = x_ceil
    elsif x_mod < snap_number.idiv(2)
      x_result = x_floor
    else
      x_result = x_ceil
    end

    snaps[x_result] ||= {}

    if snaps[x_result][y_floor]
      y_result = y_floor
    elsif snaps[x_result][y_ceil]
      y_result = y_ceil
    elsif y_mod < snap_number.idiv(2)
      y_result = y_floor
    else
      y_result = y_ceil
    end

    snaps[x_result][y_result] = true
    return [x_result, y_result]

  end

  def snap_line line
    x, y, x2, y2 = line
  end

  def string_to_line s
    x, y, x2, y2 = s.split(',').map(&:to_f)

    if x > x2
      x2, x = x, x2
      y2, y = y, y2
    end

    x, y = snap_to_grid x, y, state.snaps
    x2, y2 = snap_to_grid x2, y2, state.snaps
    [x, y, x2, y2].line.to_hash
  end

  def load_lines file
    return unless state.snaps
    data = gtk.read_file(file) || ""
    data.each_line
        .reject { |l| l.strip.length == 0 }
        .map { |l| string_to_line l }
        .map { |h| h.merge(rect: rect_for_line(h))  }
  end

  def load_terrain
    load_lines 'data/level.txt'
  end

  def load_lava
    load_lines 'data/level_lava.txt'
  end

  def load_level force: false
    if force
      state.snaps = {}
      state.terrain = load_terrain
      state.lava = load_lava
    else
      state.terrain ||= load_terrain
      state.lava ||= load_lava
    end
  end

  def save_lines lines, file
    s = lines.map do |l|
      "#{l.x1},#{l.y1},#{l.x2},#{l.y2}"
    end.join("\n")
    gtk.write_file(file, s)
  end

  def save_level
    save_lines(state.terrain, 'level.txt')
    save_lines(state.lava, 'level_lava.txt')
    load_level force: true
  end

  def line_near_rect? rect, terrain
    geometry.intersect_rect?(rect, terrain[:rect])
  end

  def point_within_line? point, line
    return false if !point
    return false if !line
    return true
  end

  def calc_impacts x, dx, y, dy, radius
    results = { }
    results[:x] = x
    results[:y] = y
    results[:dx] = x
    results[:dy] = y
    results[:point] = { x: x, y: y }
    results[:rect] = { x: x - radius, y: y - radius, w: radius * 2, h: radius * 2 }
    results[:trajectory] = trajectory(results)
    results[:impacts] = terrain.find_all { |t| t && (line_near_rect? results[:rect], t) }.map do |t|
      {
        terrain: t,
        point: geometry.line_intersect(results[:trajectory], t, replace_infinity: 1000),
        type: :terrain
      }
    end.reject { |t| !point_within_line? t[:point], t[:terrain] }

    results[:impacts] += lava.find_all { |t| line_near_rect? results[:rect], t }.map do |t|
      {
        terrain: t,
        point: geometry.line_intersect(results[:trajectory], t, replace_infinity: 1000),
        type: :lava
      }
    end.reject { |t| !t || (!point_within_line? t[:point], t[:terrain]) }

    results
  end

  def calc_potential_impacts
    impact_results = calc_impacts circle.x, circle.dx, circle.y, circle.dy, circle.radius
    circle.rect = impact_results[:rect]
    circle.trajectory = impact_results[:trajectory]
    circle.impacts = impact_results[:impacts]
  end

  def calc_terrains_to_monitor
    return unless circle.impacts
    circle.impact = nil
    circle.impacts.each do |i|
      circle.terrains_to_monitor[i[:terrain]] ||= {
        ray_start: geometry.ray_test(circle, i[:terrain]),
      }

      circle.terrains_to_monitor[i[:terrain]][:ray_current] = geometry.ray_test(circle, i[:terrain])
      if circle.terrains_to_monitor[i[:terrain]][:ray_start] != circle.terrains_to_monitor[i[:terrain]][:ray_current]
        if circle.x.between?(i[:terrain].x, i[:terrain].x2) || circle.y.between?(i[:terrain].y, i[:terrain].y2)
          circle.impact = i
          circle.ray_current = circle.terrains_to_monitor[i[:terrain]][:ray_current]
        end
      end
    end
  end

  def impact_result body, impact
    infinity_alias = 1000
    r = {
      body: {},
      terrain: {},
      impact: {}
    }

    r[:body][:line] = body.trajectory.dup
    r[:body][:slope] = geometry.line_slope(body.trajectory, replace_infinity: infinity_alias)
    r[:body][:slope_sign] = r[:body][:slope].sign
    r[:body][:x] = body.x
    r[:body][:y] = body.y
    r[:body][:dy] = body.dy
    r[:body][:dx] = body.dx

    r[:terrain][:line] = impact[:terrain].dup
    r[:terrain][:slope] = geometry.line_slope(impact[:terrain], replace_infinity: infinity_alias)
    r[:terrain][:slope_sign] = r[:terrain][:slope].sign

    r[:impact][:angle] = geometry.angle_between_lines(body.trajectory, impact[:terrain], replace_infinity: infinity_alias)
    r[:impact][:point] = { x: impact[:point].x, y: impact[:point].y }
    r[:impact][:same_slope_sign] = r[:body][:slope_sign] == r[:terrain][:slope_sign]
    r[:impact][:ray] = body.ray_current
    r[:body][:new_on_floor] = body.on_floor
    r[:body][:new_floor] = r[:terrain][:line]

    if r[:impact][:angle].abs < 90 && r[:terrain][:slope].abs < 3
      play_sound
      r[:body][:new_dy] = r[:body][:dy] * circle.elasticity * -1
      r[:body][:new_dx] = r[:body][:dx] * circle.elasticity
      r[:impact][:type] = :horizontal
      r[:body][:new_reason] = "-"
    elsif r[:impact][:angle].abs < 90 && r[:terrain][:slope].abs > 3
      play_sound
      r[:body][:new_dy] = r[:body][:dy] * 1.1
      r[:body][:new_dx] = r[:body][:dx] * -circle.elasticity
      r[:impact][:type] = :vertical
      r[:body][:new_reason] = "|"
    else
      play_sound
      r[:body][:new_dx] = r[:body][:dx] * -circle.elasticity
      r[:body][:new_dy] = r[:body][:dy] * -circle.elasticity
      r[:impact][:type] = :slanted
      r[:body][:new_reason] = "/"
    end

    r[:impact][:energy] = r[:body][:new_dx].abs + r[:body][:new_dy].abs

    if r[:impact][:energy] <= 0.3 && r[:terrain][:slope].abs < 4
      r[:body][:new_dx] = 0
      r[:body][:new_dy] = 0
      r[:impact][:energy] = 0
      r[:body][:new_on_floor] = true
      r[:body][:new_floor] = r[:terrain][:line]
      r[:body][:new_reason] = "0"
    end

    r[:impact][:ray_next] = geometry.ray_test({ x: r[:body][:x] - (r[:body][:dx] * 1.1) + r[:body][:new_dx],
                                                y: r[:body][:y] - (r[:body][:dy] * 1.1) + r[:body][:new_dy] + state.gravity },
                                              r[:terrain][:line])

    if r[:impact][:ray_next] == r[:impact][:ray]
      r[:body][:new_dx] *= -1
      r[:body][:new_dy] *= -1
      r[:body][:new_reason] = "clip"
    end

    r
  end

  def game_over!
    circle.x = circle.check_point_x
    circle.y = circle.check_point_y
    circle.dx = 0
    circle.dy = 0
    circle.game_over_at = state.tick_count
  end

  def not_game_over!
    impact_history_entry = impact_result circle, circle.impact
    circle.impact_history << impact_history_entry
    circle.x -= circle.dx * 1.1
    circle.y -= circle.dy * 1.1
    circle.dx = impact_history_entry[:body][:new_dx]
    circle.dy = impact_history_entry[:body][:new_dy]
    circle.on_floor = impact_history_entry[:body][:new_on_floor]

    if circle.on_floor
      circle.check_point_at = state.tick_count
      circle.check_point_x = circle.x
      circle.check_point_y = circle.y
    end

    circle.previous_floor = circle.floor || {}
    circle.floor = impact_history_entry[:body][:new_floor] || {}
    circle.floor_point = impact_history_entry[:impact][:point]
    if circle.floor.slice(:x, :y, :x2, :y2) != circle.previous_floor.slice(:x, :y, :x2, :y2)
      new_relative_x = if circle.dx > 0
                         :right
                       elsif circle.dx < 0
                         :left
                       else
                         nil
                       end

      new_relative_y = if circle.dy > 0
                         :above
                       elsif circle.dy < 0
                         :below
                       else
                         nil
                       end

      circle.floor_relative_x = new_relative_x
      circle.floor_relative_y = new_relative_y
    end

    circle.impact = nil
    circle.terrains_to_monitor.clear
  end

  def calc_physics
    if args.state.god_mode
      calc_potential_impacts
      calc_terrains_to_monitor
      return
    end

    if circle.y < -700
      game_over
      return
    end

    return if state.game_over
    return if circle.on_floor
    circle.previous_dy = circle.dy
    circle.previous_dx = circle.dx
    circle.x  += circle.dx
    circle.y  += circle.dy
    args.state.distance_traveled ||= 0
    args.state.distance_traveled += circle.dx.abs + circle.dy.abs
    circle.dy += state.gravity
    calc_potential_impacts
    calc_terrains_to_monitor
    return unless circle.impact
    if circle.impact && circle.impact[:type] == :lava
      game_over!
    else
      not_game_over!
    end
  end

  def input_god_mode
    state.debug_mode = !state.debug_mode if inputs.keyboard.key_down.forward_slash

    # toggle god mode
    if inputs.keyboard.key_down.g
      state.god_mode = !state.god_mode
      state.potential_lift = 0
      circle.floor = nil
      circle.floor_point = nil
      circle.floor_relative_x = nil
      circle.floor_relative_y = nil
      circle.impact = nil
      circle.terrains_to_monitor.clear
      return
    end

    return unless state.god_mode

    circle.x = circle.x.to_i
    circle.y = circle.y.to_i

    # move god circle
    if inputs.keyboard.left || inputs.keyboard.a
      circle.x -= 20
    elsif inputs.keyboard.right || inputs.keyboard.d || inputs.keyboard.f
      circle.x += 20
    end

    if inputs.keyboard.up || inputs.keyboard.w
      circle.y += 20
    elsif inputs.keyboard.down || inputs.keyboard.s
      circle.y -= 20
    end

    # delete terrain
    if inputs.keyboard.key_down.x
      calc_terrains_to_monitor
      state.terrain = state.terrain.reject do |t|
        t[:rect].intersect_rect? circle.rect
      end

      state.lava = state.lava.reject do |t|
        t[:rect].intersect_rect? circle.rect
      end

      calc_potential_impacts
      save_level
    end

    # change terrain type
    if inputs.keyboard.key_down.l
      if state.line_mode == :terrain
        state.line_mode = :lava
      else
        state.line_mode = :terrain
      end
    end

    if inputs.mouse.click && !state.point_one
      state.point_one = inputs.mouse.click.point
    elsif inputs.mouse.click && state.point_one
      l = [*state.point_one, *inputs.mouse.click.point]
      l = [l.x  - state.camera.x,
           l.y  - state.camera.y,
           l.x2 - state.camera.x,
           l.y2 - state.camera.y].line.to_hash
      l[:rect] = rect_for_line l
      if state.line_mode == :terrain
        state.terrain << l
      else
        state.lava << l
      end
      save_level
      next_x = inputs.mouse.click.point.x - 640
      next_y = inputs.mouse.click.point.y - 360
      circle.x += next_x
      circle.y += next_y
      state.point_one = nil
    elsif inputs.keyboard.one
      state.point_one = [circle.x + camera.x, circle.y+ camera.y]
    end

    # cancel chain lines
    if inputs.keyboard.key_down.nine || inputs.keyboard.key_down.escape || inputs.keyboard.key_up.six || inputs.keyboard.key_up.one
      state.point_one = nil
    end
  end

  def play_sound
    return if state.sound_debounce > 0
    state.sound_debounce = 5
    outputs.sounds << "sounds/03#{"%02d" % state.sound_index}.wav"
    state.sound_index += 1
    if state.sound_index > 21
      state.sound_index = 1
    end
  end

  def input_game
    if inputs.keyboard.down || inputs.keyboard.space
      circle.potential_lift += 0.03
      circle.potential_lift = circle.potential_lift.lesser(10)
    elsif inputs.keyboard.key_up.down || inputs.keyboard.key_up.space
      play_sound
      circle.dy += circle.angle.vector_y circle.potential_lift
      circle.dx += circle.angle.vector_x circle.potential_lift

      if circle.on_floor
        if circle.floor_relative_y == :above
          circle.y += circle.potential_lift.abs * 2
        elsif circle.floor_relative_y == :below
          circle.y -= circle.potential_lift.abs * 2
        end
      end

      circle.on_floor = false
      circle.potential_lift = 0
      circle.terrains_to_monitor.clear
      circle.impact_history.clear
      circle.impact = nil
      calc_physics
    end

    # aim probe
    if inputs.keyboard.right || inputs.keyboard.a
      circle.angle -= 2
    elsif inputs.keyboard.left || inputs.keyboard.d
      circle.angle += 2
    end
  end

  def input
    input_god_mode
    input_game
  end

  def calc_camera
    state.camera.target_x = 640 - circle.x
    state.camera.target_y = 360 - circle.y
    xdiff = state.camera.target_x - state.camera.x
    ydiff = state.camera.target_y - state.camera.y
    state.camera.x += xdiff * camera.follow_speed
    state.camera.y += ydiff * camera.follow_speed
  end

  def calc
    state.sound_debounce ||= 0
    state.sound_debounce -= 1
    state.sound_debounce = 0 if state.sound_debounce < 0
    if state.god_mode
      circle.dy *= 0.1
      circle.dx *= 0.1
    end
    calc_camera
    state.whisp_queue ||= []
    if state.tick_count.mod_zero?(4)
      state.whisp_queue << {
        x: -300,
        y: 1400 * rand,
        speed: 2.randomize(:ratio) + 3,
        w: 20,
        h: 20, path: 'sprites/whisp.png',
        a: 0,
        created_at: state.tick_count,
        angle: 0,
        r: 100,
        g: 128 + 128 * rand,
        b: 128 + 128 * rand
      }
    end

    state.whisp_queue.each do |w|
      w.x += w[:speed] * 2
      w.x -= circle.dx * 0.3
      w.y -= w[:speed]
      w.y -= circle.dy * 0.3
      w.angle += w[:speed]
      w.a = w[:created_at].ease(30) * 255
    end

    state.whisp_queue = state.whisp_queue.reject { |w| w[:x] > 1280 }

    if state.tick_count.mod_zero?(2) && (circle.dx != 0 || circle.dy != 0)
      circle.after_images << {
        x: circle.x,
        y: circle.y,
        w: circle.radius,
        h: circle.radius,
        a: 255,
        created_at: state.tick_count
      }
    end

    circle.after_images.each do |ai|
      ai.a = ai[:created_at].ease(10, :flip) * 255
    end

    circle.after_images = circle.after_images.reject { |ai| ai[:created_at].elapsed_time > 10 }
    calc_physics
  end

  def circle
    state.circle
  end

  def camera
    state.camera
  end

  def terrain
    state.terrain
  end

  def lava
    state.lava
  end
end

# $gtk.reset

def tick args
  args.outputs.background_color = [0, 0, 0]
  if args.inputs.keyboard.r
    args.gtk.reset
    return
  end
  # uncomment the line below to slow down the game so you
  # can see each tick as it passes
  # args.gtk.slowmo! 30
  $game ||= FallingCircle.new
  $game.args = args
  $game.tick
end

def reset
  $game = nil
end
