class ScrollView
  attr_gtk

  attr :y_offset, :rect, :clicked_items, :target_y_offset

  def initialize row:, col:, w:, h:;
    @items = []
    @clicked_items = []
    @y_offset = 0
    @scroll_view_dy = 0
    @rect = Layout.rect row: row,
                        col: col,
                        w: w,
                        h: h,
                        include_row_gutter: true,
                        include_col_gutter: true
    @primitives = []
  end

  def add_item prefab
    raise "prefab must be a Hash" unless prefab.is_a? Hash
    @items << prefab
  end

  def content_height
    lowest_item = @items.min_by { |primitive| primitive.y } || { x: 0, y: 0 }
    h = @rect.h

    if lowest_item
      h -= lowest_item.y - Layout.gutter
    end

    h
  end

  def y_offset_bottom_limit
    -80
  end

  def y_offset_top_limit
    content_height - @rect.h + @rect.y + 80
  end

  def tick_inputs
    @clicked_items = []

    if inputs.mouse.down
      @last_mouse_held_y = inputs.mouse.y
      @last_mouse_held_y_diff = 0
    elsif inputs.mouse.held
      @last_mouse_held_y ||= inputs.mouse.y
      @last_mouse_held_y_diff ||= 0
      @last_mouse_held_y_diff = inputs.mouse.y - @last_mouse_held_y
      @last_mouse_held_y = inputs.mouse.y
    end

    if inputs.mouse.down
      @mouse_down_at = Kernel.tick_count
      @mouse_down_y = inputs.mouse.y
      if @scroll_view_dy.abs < 7
        @maybe_click = true
      else
        @maybe_click = false
      end

      @scroll_view_dy = 0
    elsif inputs.mouse.held
      @target_y_offset = @y_offset + (inputs.mouse.y - @mouse_down_y) * 2
      @mouse_down_y = inputs.mouse.y
    elsif inputs.mouse.up
      @target_y_offset = nil
      @mouse_up_at = Kernel.tick_count
      @mouse_up_y = inputs.mouse.y

      if @maybe_click && (@last_mouse_held_y_diff).abs <= 1 && (@mouse_down_at - @mouse_up_at).abs < 12
        if inputs.mouse.y - 20 > @rect.y && inputs.mouse.y < (@rect.y + @rect.h - 20)
          @clicked_items = offset_items.reject { |primitive| !primitive.w || !primitive.h }
                                       .find_all { |primitive| inputs.mouse.inside_rect? primitive }
        end
      else
        @scroll_view_dy += @last_mouse_held_y_diff
      end
      @mouse_down_at = nil
      @mouse_up_at = nil
    end

    if inputs.keyboard.key_down.page_down
      if @scroll_view_dy >= 0
        @scroll_view_dy += 5
      else
        @scroll_view_dy = @scroll_view_dy.lerp(0, 1)
      end
    elsif inputs.keyboard.key_down.page_up
      if @scroll_view_dy <= 0
        @scroll_view_dy -= 5
      else
        @scroll_view_dy = @scroll_view_dy.lerp(0, 1)
      end
    end

    if inputs.mouse.wheel
      if inputs.mouse.wheel.inverted
        @scroll_view_dy -= inputs.mouse.wheel.y
      else
        @scroll_view_dy += inputs.mouse.wheel.y
      end
    end

  end

  def tick
    if @target_y_offset
      if @target_y_offset < y_offset_bottom_limit
        @y_offset = @y_offset.lerp @target_y_offset, 0.05
      elsif @target_y_offset > y_offset_top_limit
        @y_offset = @y_offset.lerp @target_y_offset, 0.05
      else
        @y_offset = @y_offset.lerp @target_y_offset, 0.5
      end
      @target_y_offset = nil if @y_offset.round == @target_y_offset.round
      @scroll_view_dy = 0
    end

    tick_inputs

    @y_offset += @scroll_view_dy

    if @y_offset < 0
      if inputs.mouse.held
        # if @y_offset < -80
        #   @y_offset = -80
        # end
      else
        @y_offset = @y_offset.lerp(0, 0.2)
      end
    end

    if content_height <= (@rect.h - @rect.y)
      @y_offset = 0
      @scroll_view_dy = 0
    elsif @y_offset > content_height - @rect.h + @rect.y
      if inputs.mouse.held
        # if @y_offset > (content_height - @rect.h + @rect.y) + 80
        #   @y_offset = (content_height - @rect.h + @rect.y) + 80
        # end
      else
        @y_offset = @y_offset.lerp(content_height - @rect.h + @rect.y, 0.2)
      end
    end
    @scroll_view_dy *= 0.95
    @scroll_view_dy = @scroll_view_dy.round(2)
  end

  def items
    @items
  end

  def offset_items
    @items.map { |primitive| primitive.merge(y: primitive.y + @y_offset) }
  end

  def prefab
    outputs[:scroll_view].w = Grid.w
    outputs[:scroll_view].h = Grid.h
    outputs[:scroll_view].background_color = [0, 0, 0, 0]

    outputs[:scroll_view_content].w = Grid.w
    outputs[:scroll_view_content].h = Grid.h
    outputs[:scroll_view_content].background_color = [0, 0, 0, 0]

    outputs[:scroll_view_content].primitives << offset_items

    outputs[:scroll_view].primitives << {
      x: @rect.x,
      y: @rect.y,
      w: @rect.w,
      h: @rect.h,
      source_x: @rect.x,
      source_y: @rect.y,
      source_w: @rect.w,
      source_h: @rect.h,
      path: :scroll_view_content
    }

    outputs[:scroll_view].primitives << [
      { x: @rect.x,
        y: @rect.y,
        w: @rect.w,
        h: @rect.h,
        primitive_marker: :border,
        r: 128,
        g: 128,
        b: 128 },
    ]

    { x: 0,
      y: 0,
      w: Grid.w,
      h: Grid.h,
      path: :scroll_view }
  end
end

class Game
  attr_gtk

  attr :scroll_view

  def initialize
    @scroll_view = ScrollView.new row: 2, col: 0, w: 12, h: 20
  end

  def defaults
    state.scroll_view_dy             ||= 0
    state.scroll_view_offset_y       ||= 0
  end

  def calc
    if Kernel.tick_count == 0
      80.times do |i|
        @scroll_view.add_item Layout.rect(row: 2 + i * 2, col: 0, w: 2, h: 2).merge(id: "item_#{i}_square_1".to_sym, path: :solid, r: 32 + i * 2, g: 32, b: 32)
        @scroll_view.add_item Layout.rect(row: 2 + i * 2, col: 0, w: 2, h: 2).center.merge(text: "item #{i}", anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255)
        @scroll_view.add_item Layout.rect(row: 2 + i * 2, col: 2, w: 2, h: 2).merge(id: "item_#{i}_square_2".to_sym, path: :solid, r: 64 + i * 2, g: 64, b: 64)
      end
    end

    @scroll_view.args = args
    @scroll_view.tick

    if @scroll_view.clicked_items.length > 0
      puts @scroll_view.clicked_items
    end
  end

  def render
    outputs.primitives << @scroll_view.prefab
  end

  def tick
    defaults
    calc
    render
  end
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

GTK.reset
