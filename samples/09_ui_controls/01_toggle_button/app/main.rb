class ToggleButton
  attr :on_off

  def initialize(x:, y:, w:, h:, on_off:, button_text:, on_click:)
    @x = x
    @y = y
    @w = w
    @h = h
    @on_off = on_off
    @button_text = button_text
    @on_click = on_click
  end

  def prefab
    color = if @on_off
              { r: 255, g: 255, b: 255 }
            else
              { r: 128, g: 128, b: 128 }
            end
    [
      { x: @x,
        y: @y,
        w: @w,
        h: @h,
        path: :solid,
        r: 30,
        g: 30,
        b: 30 },
      { x: @x + @w / 2,
        y: @y + @h / 2,
        text: "#{@button_text.call(@on_off)}",
        anchor_x: 0.5,
        anchor_y: 0.5,
        **color },
    ]
  end

  def click_rect
    { x: @x, y: @y, w: @w, h: @h }
  end

  def tick inputs
    if inputs.mouse.click && inputs.mouse.inside_rect?(click_rect)
      @on_off = !@on_off
      @on_click.call(@on_off)
    end
  end
end

def tick args
  init_state args
  args.state.buttons.each { |button| button.tick args.inputs }
  args.outputs.primitives << args.state.buttons.map { |button| button.prefab }
end

def init_state args
  return if Kernel.tick_count != 0

  args.state.game_speed  ||= :slow
  args.state.color_theme ||= :dark
  args.state.bg_music    ||= :unmuted
  game_speed_button = ToggleButton.new(x: 8,
                                       y: 720 - 32 - 8,
                                       w: 512,
                                       h: 32,
                                       on_off: true,
                                       button_text: lambda { |on_off|
                                         "Game Speed: #{args.state.game_speed} (on_off state: #{on_off})"
                                       },
                                       on_click: lambda { |on_off|
                                         if on_off
                                           args.state.game_speed = :fast
                                         else
                                           args.state.game_speed = :slow
                                         end
                                       })

  game_color_theme_button = ToggleButton.new(x: 8,
                                             y: 720 - 64 - 16,
                                             w: 512,
                                             h: 32,
                                             on_off: true,
                                             button_text: lambda { |on_off|
                                               "Color Theme: #{args.state.color_theme} (on_off state: #{on_off})"
                                             },
                                             on_click: lambda { |on_off|
                                               if on_off
                                                 args.state.color_theme = :dark
                                               else
                                                 args.state.color_theme = :light
                                               end
                                             })

  bg_music_button = ToggleButton.new(x: 8,
                                     y: 720 - 96 - 24,
                                     w: 512,
                                     h: 32,
                                     on_off: true,
                                     button_text: lambda { |on_off|
                                       "Background Music: #{args.state.bg_music} (on_off state: #{on_off})"
                                     },
                                     on_click: lambda { |on_off|
                                       if on_off
                                         args.state.bg_music = :unmuted
                                       else
                                         args.state.bg_music = :muted
                                       end
                                     })

  args.state.buttons = [
    game_speed_button,
    game_color_theme_button,
    bg_music_button,
  ]
end

GTK.reset
