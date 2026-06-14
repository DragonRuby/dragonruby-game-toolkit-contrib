class Element
  attr :x_ordinal, :y_ordinal

  def initialize x_ordinal, y_ordinal, grain_size, r, g, b
    @x_ordinal     = x_ordinal
    @y_ordinal     = y_ordinal
    @grain_size    = grain_size
    @x             = x_ordinal * grain_size
    @y             = y_ordinal * grain_size
    @w             = grain_size
    @h             = grain_size
    @path          = :solid
    @r             = r
    @g             = g
    @b             = b
  end

  def draw_override ffi
    ffi.draw_sprite_ivar self
  end

  def static?
    false
  end

  def move dx, dy
    @y_ordinal += dy
    @x_ordinal += dx
    @y = @y_ordinal * @grain_size
    @x = @x_ordinal * @grain_size
  end
end

class SandElement < Element
  def initialize x_ordinal, y_ordinal, grain_size
    super x_ordinal, y_ordinal, grain_size, 207, 174, 124
  end
end

class WaterElement < Element
  def initialize x_ordinal, y_ordinal, grain_size
    super x_ordinal, y_ordinal, grain_size, 60, 107, 150
  end
end

class SedimentElement < Element
  def initialize x_ordinal, y_ordinal, grain_size
    super x_ordinal, y_ordinal, grain_size, 150, 115, 75
  end
end

class GlassElement < Element
  def initialize x_ordinal, y_ordinal, grain_size
    super x_ordinal, y_ordinal, grain_size, 255, 235, 204
  end

  def static?
    true
  end
end

class Elements
  attr :entries, :grain_size

  def initialize(grain_size:, static_sprites:)
    @grain_size     = grain_size
    @static_sprites = static_sprites
    @cols = 1280.idiv grain_size
    @rows = 720.idiv grain_size
    @grid = Array.new(@cols * @rows)
    @entries = []
  end

  def add_element x_ordinal, y_ordinal, klass: SandElement
    return nil if x_ordinal < 0 || x_ordinal >= @cols
    return nil if y_ordinal < 0 || y_ordinal >= @rows
    existing = @grid[x_ordinal + y_ordinal * @cols]
    if existing
      return nil unless (klass == SandElement || klass == SedimentElement) && existing.is_a?(WaterElement)
      remove existing
    end
    element = klass.new x_ordinal, y_ordinal, @grain_size
    @entries << element unless element.static?
    @static_sprites << element
    @grid[x_ordinal + y_ordinal * @cols] = element
    element
  end

  def create_globe cx, cy, radius, thickness: 2
    outer_sq = radius * radius
    inner_sq = (radius - thickness) * (radius - thickness)
    (cy - radius..cy + radius).each do |y|
      (cx - radius..cx + radius).each do |x|
        d_sq = (x - cx) ** 2 + (y - cy) ** 2
        next if d_sq < inner_sq
        next if d_sq > outer_sq
        add_element x, y, klass: GlassElement
      end
    end
  end

  def erase_at x_ordinal, y_ordinal
    return if x_ordinal < 0 || x_ordinal >= @cols
    return if y_ordinal < 0 || y_ordinal >= @rows
    existing = @grid[x_ordinal + y_ordinal * @cols]
    return unless existing && !existing.static?
    remove existing
  end

  def tick
    @pending_removal = []
    Array.each(@entries) { |el| move_element el }
    @pending_removal.each { |el| remove el }
  end

  def move_element element
    x  = element.x_ordinal
    y  = element.y_ordinal
    dx = rand(2) == 0 ? -1 : 1

    if element.is_a?(SandElement)
      water = water_at?(x + dx, y - 1)
      if empty_at?(x, y - 1)
        move_to element, x, y, 0, -1
      elsif water
        swap element, water
      elsif empty_at?(x + dx, y - 1)
        move_to element, x, y, dx, -1
      end
    elsif element.is_a?(SedimentElement)
      if rand(2) == 1
        water = water_at?(x + dx, y - 1)
        if empty_at?(x + dx, y - 1)
          move_to element, x, y, dx, -1
        elsif water
          swap element, water
        end
      end
    elsif element.is_a?(WaterElement)
      if empty_at?(x, y - 1)
        move_to element, x, y, 0, -1
      elsif empty_at?(x + dx, y - 1)
        move_to element, x, y, dx, -1
      elsif empty_at?(x + dx, y)
        move_to element, x, y, dx, 0
      elsif empty_at?(x - dx, y)
        move_to element, x, y, -dx, 0
      end
    end
  end

  def element_count
    @entries.length
  end

  def remove element
    x, y = element.x_ordinal, element.y_ordinal
    @grid[x + y * @cols] = nil if x >= 0 && x < @cols && y >= 0 && y < @rows
    @entries.delete element
    @static_sprites.delete element
  end

  def swap a, b
    ax, ay = a.x_ordinal, a.y_ordinal
    bx, by = b.x_ordinal, b.y_ordinal
    @grid[ax + ay * @cols] = nil
    @grid[bx + by * @cols] = nil
    a.move bx - ax, by - ay
    b.move ax - bx, ay - by
    @grid[a.x_ordinal + a.y_ordinal * @cols] = a
    @grid[b.x_ordinal + b.y_ordinal * @cols] = b
  end

  def water_at? x, y
    return nil if x < 0 || x >= @cols
    return nil if y < 0
    cell = @grid[x + y * @cols]
    cell.is_a?(WaterElement) ? cell : nil
  end

  def move_to element, x, y, dx, dy
    @grid[x + y * @cols] = nil
    element.move dx, dy
    nx, ny = element.x_ordinal, element.y_ordinal
    if nx < 0 || nx >= @cols || ny < 0 || ny >= @rows
      @pending_removal << element
    else
      @grid[nx + ny * @cols] = element
    end
  end

  def empty_at? x, y
    return true if x < 0 || x >= @cols || y < 0 || y >= @rows
    !@grid[x + y * @cols]
  end
end

module Main
  def buttons
    @buttons ||= [
      { rect: Layout.rect(row: 0, col: 21, w: 3, h: 1), label: "Sand",     element: SandElement,     density: 1.0, brush_radius: 3 },
      { rect: Layout.rect(row: 1, col: 21, w: 3, h: 1), label: "Water",    element: WaterElement,    density: 1.0, brush_radius: 6 },
      { rect: Layout.rect(row: 2, col: 21, w: 3, h: 1), label: "Sediment", element: SedimentElement, density: 0.1, brush_radius: 3 },
      { rect: Layout.rect(row: 3, col: 21, w: 3, h: 1), label: "Erase",    element: :erase,          density: 1.0, brush_radius: 3 },
      { rect: Layout.rect(row: 4, col: 21, w: 3, h: 1), label: "Reset",    callback: -> { DR.reset_next_tick } },
    ]
  end

  def tick args
    @selected_element ||= SandElement
    calc_elements args
    calc_buttons args
    calc_paint args
    render args
  end

  def calc_buttons args
    if args.inputs.keyboard.key_down.tab
      element_buttons = buttons.select { |b| b[:element] }
      idx = element_buttons.index { |b| b.element == @selected_element } || 0
      @selected_element = element_buttons[(idx + 1) % element_buttons.length].element
    elsif args.inputs.mouse.key_down.left
      button = Geometry.find_intersect_rect(args.inputs.mouse, buttons, using: :rect)
      if button
        button[:callback] ? button.callback.call : @selected_element = button.element
      end
    end
  end

  def render_buttons args
    args.outputs.primitives << buttons.map do |button|
      inner_rect = Geometry.zoom_rect(rect: button.rect, px: -4)
      selected = button[:element] && button.element == @selected_element
      [
        { **button.rect, path: :solid,
          r: 255,
          g: 255,
          b: 255,
          a: 220 },
        { **inner_rect.rect, path: :solid,
          r: selected ? 80 : 0,
          g: selected ? 80 : 0,
          b: selected ? 80 : 0,
          a: 220 },
        { **button.rect.center, text: button.label,
          anchor_x: 0.5, anchor_y: 0.5,
          r: 255, g: 255, b: 255, size_px: 16 }
      ]
    end
  end

  def calc_paint args
    mouse_over_button = Geometry.find_intersect_rect(args.inputs.mouse, buttons, using: :rect)

    unless args.inputs.mouse.key_held.left && !mouse_over_button
      @last_mx = nil
      @last_my = nil
      return
    end

    mx = args.inputs.mouse.x
    my = args.inputs.mouse.y

    selected_button = buttons.find { |b| b.element == @selected_element }
    brush_radius    = selected_button.brush_radius
    density         = selected_button.density

    paint_points = []
    if @last_mx
      ddx  = mx - @last_mx
      ddy  = my - @last_my
      dist = Math.sqrt(ddx * ddx + ddy * ddy)
      step = @elements.grain_size * brush_radius
      if dist > step
        steps = dist.idiv(step)
        steps.times do |i|
          t = (i + 1).to_f / (steps + 1)
          paint_points << [(@last_mx + ddx * t).to_i, (@last_my + ddy * t).to_i]
        end
      end
    end

    paint_points << [mx, my]

    paint_points.each do |px, py|
      cx = px.idiv(@elements.grain_size)
      cy = py.idiv(@elements.grain_size)
      (-brush_radius..brush_radius).each do |bx|
        (-brush_radius..brush_radius).each do |by|
          next if bx * bx + by * by > brush_radius * brush_radius
          next if rand > density
          if @selected_element == :erase
            @elements.erase_at(cx + bx, cy + by)
          else
            @elements.add_element(cx + bx, cy + by, klass: @selected_element)
          end
        end
      end
    end

    @last_mx = mx
    @last_my = my
  end

  def calc_elements args
    @elements ||= begin
      e = Elements.new(grain_size: 4, static_sprites: args.outputs.static_sprites)
      e.create_globe 160, 90, 82
      e
    end

    @elements.tick
  end

  def render args
    args.outputs.background_color = [30, 30, 30]
    render_buttons args
    args.outputs.watch "FPS: #{DR.current_framerate.to_sf}"
    args.outputs.watch "Particles: #{@elements.element_count}"
  end

  def reset args
    @elements         = nil
    @selected_element = nil
    @buttons          = nil
    @last_mx          = nil
    @last_my          = nil
  end
end

# DR.reset
