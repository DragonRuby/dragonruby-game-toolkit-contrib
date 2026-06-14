class Game
  attr_dr

  def initialize
    @box_speed = 1
    @current_track_type = :right
    @cells = 30.flat_map do |x_ordinal|
      18.map do |y_ordinal|
        {
          **Geometry.rect(x: x_ordinal * 40, y: y_ordinal * 40, w: 40, h: 40),
          x_ordinal: x_ordinal,
          y_ordinal: y_ordinal,
        }
      end
    end

    @buttons = [
      {
        rect: Layout.rect(row: 0, col: 23, w: 1, h: 1),
        title: "type",
        text: -> { "#{track_char @current_track_type}" },
        callback: -> {
          case @current_track_type
          when :right
            @current_track_type = :down
          when :down
            @current_track_type = :left
          when :left
            @current_track_type = :up
          when :up
            @current_track_type = :right
          end
        }
      },
      {
        rect: Layout.rect(row: 1, col: 23, w: 1, h: 1),
        title: "speed",
        text: -> { "#{@box_speed}" },
        callback: -> {
          candidate_speed = @box_speed + 1
          while candidate_speed <= 20
            break if 40.zmod?(candidate_speed)
            candidate_speed += 1
          end
          if candidate_speed > 20
            candidate_speed = 1
          end
          @box_speed = candidate_speed
          @boxes = []
        },
      },
      {
        rect: Layout.rect(row: 2, col: 23, w: 1, h: 1),
        title: "clear boxes",
        text: -> { "#{@boxes.length}" },
        callback: -> { @boxes = [] }
      }
    ]

    @tracks = []
    @boxes = []
  end

  def new_box
    {
      x: 20,
      y: 340,
      w: 40,
      h: 40,
      dx: 0,
      dy: 0,
      speed: @box_speed,
      anchor_x: 0.5,
      anchor_y: 0.5,
      path: :solid,
      r: 128, g: 255, b: 128, a: 200
    }
  end

  def calc_edit_track
    cell = Geometry.find_intersect_rect(inputs.mouse, @cells)

    return if !cell

    track = Geometry.find_intersect_rect(inputs.mouse, @tracks)

    if inputs.mouse.key_up.left
      @tracks.delete track if track
      @tracks << { **cell, type: @current_track_type }
    elsif inputs.mouse.key_up.right
      @tracks.delete track if track
    end
  end

  def track_direction track
    type = if track.is_a? Symbol
             track
           else
             track.type
           end
    case type
    when :right
      { dx: 1, dy: 0 }
    when :down
      { dx: 0, dy: -1 }
    when :left
      { dx: -1, dy: 0 }
    when :up
      { dx: 0, dy: 1 }
    else
      raise "Unknown track type: #{track.type}"
    end
  end

  def tick_box box
    box.previous_track = box.current_track

    track_collisions = Geometry.find_all_intersect_rect(
      box,
      @tracks,
      tolerance: 0
    )

    cell_collisions = Geometry.find_all_intersect_rect(
      box,
      @cells,
      tolerance: 0
    )

    box.current_track = track_collisions.first

    if track_collisions.length == 0
      box.dx = 0
      box.dy = 0
    elsif track_collisions.length == 1 && cell_collisions.length == 1
      direction = track_direction(track_collisions.first)
      box.dx = direction.dx
      box.dy = direction.dy
    end

    box.x += box.dx * box.speed
    other_box = Geometry.find_intersect_rect(box, @boxes.reject { |b| b == box })
    if other_box
      if box.dx > 0
        box.x = other_box.x - box.w
      elsif box.dx < 0
        box.x = other_box.x + other_box.w
      end
    end
    box.y += box.dy * box.speed
    other_box = Geometry.find_intersect_rect(box, @boxes.reject { |b| b == box })
    if other_box
      if box.dy > 0
        box.y = other_box.y - box.h
      elsif box.dy < 0
        box.y = other_box.y + other_box.h
      end
    end
  end

  def track_char track
    type = if track.is_a? Symbol
             track
           else
             track.type
           end

    case type
    when :right
      "→"
    when :down
      "↓"
    when :left
      "←"
    when :up
      "↑"
    end
  end

  def calc_buttons
    return if !inputs.mouse.key_up.left
    button = Geometry.find_intersect_rect(inputs.mouse, @buttons, using: :rect)
    button.callback.call if button
  end

  def track_primitives track
    [
      {
        **Geometry.zoom_rect(rect: track, px: -1),
        path: :solid, r: 255, g: 255, b: 255, a: 128
      },
      {
        **track.center,
        text: track_char(track),
        anchor_x: 0.5,
        anchor_y: 0.5,
        r: 255,
        g: 255,
        b: 255
      }
    ]
  end

  def calc_boxes
    @boxes.each { |box| tick_box box }

    if Kernel.tick_count.zmod?(120)
      box_to_add = new_box
      if !Geometry.find_intersect_rect(box_to_add, @boxes)
        @boxes << box_to_add
      end
    end
  end

  def tick
    calc_edit_track
    calc_buttons
    calc_boxes
    render
  end

  def render
    outputs.background_color = [30, 30, 30]

    outputs.primitives << @cells.map do |cell|
      {
        **Geometry.zoom_rect(rect: cell, px: -1),
        path: :solid, r: 0, g: 0, b: 0, a: 128
      }
    end

    outputs.primitives << @tracks.map do |track|
      track_primitives track
    end

    outputs.primitives << @boxes
    outputs.primitives << {
      x: 640, y: 720, text: "Click to add/override track. Right click to remove track.",
      anchor_x: 0.5, anchor_y: 1, r: 255, g: 255, b: 255
    }

    outputs.primitives << {
      x: 640, y: 720, text: "Buttons at far right to change track type, change box speed, and clear boxes.",
      anchor_x: 0.5, anchor_y: 2, r: 255, g: 255, b: 255
    }

    mouse_cell = Geometry.find_intersect_rect(inputs.mouse, @cells)

    if mouse_cell
      outputs.primitives << track_primitives({ **mouse_cell, type: @current_track_type })
    end

    outputs.primitives << @buttons.map do |button|
      text = button.text.is_a?(Proc) ? button.text.call : button.text
      [
        { **button.rect, path: :solid, r: 0, g: 0, b: 0, a: 255 },
        { **button.rect.center,
          text: button.title,
          anchor_x: 0.5,
          anchor_y: 0.0,
          r: 255,
          g: 255,
          b: 255,
          size_px: 14 },
        { **button.rect.center,
          text: text,
          anchor_x: 0.5,
          anchor_y: 1.5,
          r: 255,
          g: 255,
          b: 255,
          size_px: 14 }
      ]
    end
  end
end

module Main
  def tick args
    @game ||= Game.new
    @game.args = args
    @game.tick
  end

  def reset args
    @game = nil
  end
end

GTK.reset
