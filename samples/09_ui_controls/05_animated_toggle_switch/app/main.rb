class ToggleSwitch
  attr :toggle_state

  def initialize(row:, col:, toggle_state: :left, on_click:)
    @click_rect = Layout.rect(row: row, col: col, w: 2, h: 1)
    @switch_rect = Layout.rect(row: row, col: col, w: 1, h: 1)
    left_x =  Layout.rect(row: row, col: col, w: 1, h: 1).x
    right_x = Layout.rect(row: row, col: col + 1, w: 1, h: 1).x
    @diff_x = right_x - left_x
    @animation_duration = 15
    @toggle_state = toggle_state
    @click_at = -@animation_duration
    @on_click = on_click
  end

  def prefab
    perc = if @toggle_state == :right
             Easing.smooth_stop(start_at: @click_at,
                                duration: @animation_duration,
                                tick_count: Kernel.tick_count,
                                power: 4)
           elsif @toggle_state == :left
             Easing.smooth_stop(start_at: @click_at,
                                duration: @animation_duration,
                                tick_count: Kernel.tick_count,
                                power: 4,
                                flip: true)
           end

    text = if @toggle_state == :right
             "on"
           else
             "off"
            end

    switch_diff_x = @diff_x * perc

    switch_rect_prefab = [
      { **@switch_rect,
        path: :solid,
        r: 30,
        g: 30,
        b: 30,
        x: @switch_rect.x + switch_diff_x },
      { x: @switch_rect.x + 4 + switch_diff_x,
        y: @switch_rect.y + 4,
        w: @switch_rect.w - 8,
        h: @switch_rect.h - 8,
        path: :solid,
        r: 255,
        g: 255,
        b: 255 },
    ]

    switch_bg_prefab = { **@click_rect, path: :solid, r: 30, g: 30, b: 30 }

    switch_label_prefab = { **@switch_rect.center,
                            text: "#{text}",
                            anchor_x: 0.5,
                            anchor_y: 0.5,
                            r: 0,
                            g: 0,
                            b: 0,
                            x: @switch_rect.center.x + switch_diff_x }

    [
      switch_bg_prefab,
      switch_rect_prefab,
      switch_label_prefab,
    ]
  end

  def tick inputs
    return if !inputs.mouse.click
    return if !inputs.mouse.point.inside_rect?(@click_rect)

    if @toggle_state == :left
      @toggle_state = :right
      @click_at = Kernel.tick_count
    else
      @toggle_state = :left
      @click_at = Kernel.tick_count
    end

    @on_click.call @toggle_state
  end
end

class Game
  attr_gtk

  def initialize
    @slide_toggle_buttons = [
      ToggleSwitch.new(row: 0,
                      col: 0,
                      toggle_state: :right,
                      on_click: lambda { |toggle_state| GTK.notify "toggle 1 toggled to #{toggle_state}!" }),
      ToggleSwitch.new(row: 1,
                      col: 0,
                      toggle_state: :left,
                      on_click: lambda { |toggle_state| GTK.notify "toggle 2 toggled to #{toggle_state}!" }),
    ]
  end

  def tick
    @slide_toggle_buttons.each { |btn| btn.tick inputs }
    outputs.primitives << @slide_toggle_buttons.map(&:prefab)
  end
end

def boot args
  args.state = {}
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
