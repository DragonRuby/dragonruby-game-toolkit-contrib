class Game
  attr_gtk

  def tick
    defaults
    calc
    render
  end

  def render
    outputs.primitives << state.selection_point.merge(w: state.menu.button_w + 8,
                                                      h: state.menu.button_h + 8,
                                                      a: 128,
                                                      r: 0,
                                                      g: 200,
                                                      b: 100,
                                                      path: :solid,
                                                      anchor_x: 0.5,
                                                      anchor_y: 0.5)

    outputs.primitives << state.menu.buttons.map(&:primitives)
  end

  def calc_directional_input
    return if state.input_debounce.elapsed_time < 10
    return if !inputs.directional_vector
    state.input_debounce = Kernel.tick_count

    state.selected_button = Geometry::rect_navigate(
      rect: state.selected_button,
      rects: state.menu.buttons,
      left_right: inputs.left_right,
      up_down: inputs.up_down,
      wrap_x: true,
      wrap_y: true,
      using: lambda { |e| e.rect }
    )
  end

  def calc_mouse_input
    return if !inputs.mouse.moved
    hovered_button = state.menu.buttons.find { |b| Geometry::intersect_rect? inputs.mouse, b.rect }
    if hovered_button
      state.selected_button = hovered_button
    end
  end

  def calc
    target_point = state.selected_button.rect.center
    state.selection_point.x = state.selection_point.x.lerp(target_point.x, 0.25)
    state.selection_point.y = state.selection_point.y.lerp(target_point.y, 0.25)
    calc_directional_input
    calc_mouse_input
  end

  def defaults
    if !state.menu
      state.menu = {
        button_cell_w: 2,
        button_cell_h: 1,
      }
      state.menu.button_w = Layout::rect(w: 2).w
      state.menu.button_h = Layout::rect(h: 1).h
      state.menu.buttons = [
        menu_prefab(id: :item_1, text: "Item 1", row: 0, col: 0, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
        menu_prefab(id: :item_2, text: "Item 2", row: 0, col: 2, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
        menu_prefab(id: :item_3, text: "Item 3", row: 0, col: 4, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
        menu_prefab(id: :item_4, text: "Item 4", row: 1, col: 0, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
        menu_prefab(id: :item_5, text: "Item 5", row: 1, col: 2, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
        menu_prefab(id: :item_6, text: "Item 6", row: 1, col: 4, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
        menu_prefab(id: :item_7, text: "Item 7", row: 2, col: 0, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
        menu_prefab(id: :item_8, text: "Item 8", row: 2, col: 2, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
        menu_prefab(id: :item_9, text: "Item 9", row: 2, col: 4, w: state.menu.button_cell_w, h: state.menu.button_cell_h),
      ]
    end

    state.selected_button ||= state.menu.buttons.first
    state.selection_point ||= { x: state.selected_button.rect.center.x,
                                y: state.selected_button.rect.center.y }
    state.input_debounce  ||= 0
  end

  def menu_prefab id:, text:, row:, col:, w:, h:;
    rect = Layout::rect(row: row, col: col, w: w, h: h)
    {
      id: id,
      row: row,
      col: col,
      text: text,
      rect: rect,
      primitives: [
        rect.merge(primitive_marker: :border),
        rect.center.merge(text: text, anchor_x: 0.5, anchor_y: 0.5)
      ]
    }
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
