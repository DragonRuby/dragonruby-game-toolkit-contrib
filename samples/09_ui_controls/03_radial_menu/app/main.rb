class Game
  attr_gtk

  def tick
    defaults
    calc
    render
  end

  def defaults
    state.menu_items = [
      { id: :item_1, text: "Item 1" },
      { id: :item_2, text: "Item 2" },
      { id: :item_3, text: "Item 3" },
      { id: :item_4, text: "Item 4" },
      { id: :item_5, text: "Item 5" },
      { id: :item_6, text: "Item 6" },
      { id: :item_7, text: "Item 7" },
      { id: :item_8, text: "Item 8" },
      { id: :item_9, text: "Item 9" },
    ]

    state.menu_status     ||= :hidden
    state.menu_radius     ||= 200
    state.menu_status_at  ||= -1000
  end

  def calc
    state.menu_items.each_with_index do |item, i|
      item.menu_angle = 90 + (360 / state.menu_items.length) * i
      item.menu_angle_range = 360 / state.menu_items.length - 10
    end

    state.menu_items.each do |item|
      item.rect = Geometry.rect_props x: 640 + item.menu_angle.vector_x * state.menu_radius - 50,
                                      y: 360 + item.menu_angle.vector_y * state.menu_radius - 25,
                                      w: 100,
                                      h: 50

      item.circle = { x: item.rect.x + item.rect.w / 2, y: item.rect.y + item.rect.h / 2, radius: item.rect.w / 2 }
    end

    show_menu_requested = false
    if state.menu_status == :hidden
      show_menu_requested = true if inputs.controller_one.key_down.a
      show_menu_requested = true if inputs.mouse.click
    end

    hide_menu_requested = false
    if state.menu_status == :shown
      hide_menu_requested = true if inputs.controller_one.key_down.b
      hide_menu_requested = true if inputs.mouse.click && !state.hovered_menu_item
    end

    if state.menu_status == :shown && state.hovered_menu_item && (inputs.mouse.click || inputs.controller_one.key_down.a)
      GTK.notify! "You selected #{state.hovered_menu_item[:text]}"
    elsif show_menu_requested
      state.menu_status = :shown
      state.menu_status_at = Kernel.tick_count
    elsif hide_menu_requested
      state.menu_status = :hidden
      state.menu_status_at = Kernel.tick_count
    end

    state.hovered_menu_item = state.menu_items.find { |item| Geometry.point_inside_circle? inputs.mouse, item.circle }

    if inputs.controller_one.active && inputs.controller_one.left_analog_active?(threshold_perc: 0.5)
      state.hovered_menu_item = state.menu_items.find do |item|
        Geometry.angle_within_range? inputs.controller_one.left_analog_angle, item.menu_angle, item.menu_angle_range
      end
    end
  end

  def menu_prefab item, perc
    dx = item.rect.center.x - 640
    x = 640 + dx * perc
    dy = item.rect.center.y - 360
    y = 360 + dy * perc
    Geometry.rect_props item.rect.merge x: x - item.rect.w / 2, y: y - item.rect.h / 2
  end

  def ring_prefab x_center, y_center, radius, precision:, color: nil
    color ||= { r: 0, g: 0, b: 0, a: 255 }
    pi = Math::PI
    lines = []

    precision.map do |i|
      theta = 2.0 * pi * i / precision
      next_theta = 2.0 * pi * (i + 1) / precision

      {
        x: x_center + radius * theta.cos_r,
        y: y_center + radius * theta.sin_r,
        x2: x_center + radius * next_theta.cos_r,
        y2: y_center + radius * next_theta.sin_r,
        **color
      }
    end
  end

  def circle_prefab x_center, y_center, radius, precision:, color: nil
    color ||= { r: 0, g: 0, b: 0, a: 255 }
    pi = Math::PI
    lines = []

    # Indie/Pro Only (uses triangles)
    precision.map do |i|
      theta = 2.0 * pi * i / precision
      next_theta = 2.0 * pi * (i + 1) / precision

      {
        x:  x_center + radius * theta.cos_r,
        y:  y_center + radius * theta.sin_r,
        x2: x_center + radius * next_theta.cos_r,
        y2: y_center + radius * next_theta.sin_r,
        y3: y_center,
        x3: x_center,
        source_x:  0,
        source_y:  0,
        source_x2: 0,
        source_y2: radius,
        source_x3: radius,
        source_y3: 0,
        path:      :solid,
        **color,
      }
    end
  end

  def render
    outputs.debug.watch "Controller"
    outputs.debug.watch pretty_format(inputs.controller_one.to_h)

    outputs.debug.watch "Mouse"
    outputs.debug.watch pretty_format(inputs.mouse.to_h)

    # outputs.debug.watch "Mouse"
    # outputs.debug.watch pretty_format(inputs.mouse)
    outputs.primitives << { x: 640, y: 360, w: 10, h: 10, path: :solid, r: 128, g: 0, b: 0, a: 128, anchor_x: 0.5, anchor_y: 0.5 }

    if state.menu_status == :shown
      perc = Easing.ease(state.menu_status_at, Kernel.tick_count, 30, :smooth_stop_quart)
    else
      perc = Easing.ease(state.menu_status_at, Kernel.tick_count, 30, :smooth_stop_quart, :flip)
    end

    outputs.primitives << state.menu_items.map do |item|
      a = 255 * perc
      color = { r: 128, g: 128, b: 128, a: a }
      if state.hovered_menu_item == item
        color = { r: 80, g: 128, b: 80, a: a }
      end

      menu = menu_prefab(item, perc)

      if state.menu_status == :shown
        ring = ring_prefab(menu.center.x, menu.center.y, item.circle.radius, precision: 30, color: color.merge(a: 128))
        circle = circle_prefab(menu.center.x, menu.center.y, item.circle.radius, precision: 30, color: color.merge(a: 128))
      end

      [
        ring,
        circle,
        menu.merge(path: :solid, **color),
        menu.center.merge(text: item.text, a: a, anchor_x: 0.5, anchor_y: 0.5)
      ]
    end
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset
  $game = nil
end

GTK.reset
