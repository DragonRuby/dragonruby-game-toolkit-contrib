require "app/lowrez_emulation.rb"

class Game < LowrezGame
  def initialize
    super(w: 128, h: 128) # update this to change the size of your lowrez canvas

    @player = {
      x: 0,
      y: 0,
      w: 4,
      h: 8,
      path: :solid,
      r: 128, g: 128, b: 255
    }

    @button_rect = {
      x: 64 - 36,
      y: 64 - 16,
      w: 72,
      h: 8,
    }

    @button_text = "Click me!"
  end

  def tick
    calc
    render
  end

  def calc
    @player.x += inputs.left_right
    @player.y += inputs.up_down
    if inputs.mouse.key_down.left && Geometry.inside_rect?(lowrez_mouse, @button_rect)
      @button_text = "Clicked at #{Kernel.tick_count}"
    end
  end

  def render
    lowrez_outputs.primitives << @player
    lowrez_outputs.primitives << {
      x: @w.idiv(2),
      y: @h - 1,
      text: "WASD OR ARROW KEYS TO MOVE",
      size_px: 5,
      anchor_x: 0.5,
      anchor_y: 1.0,
      font: "fonts/lowrez.ttf",
    }

    lowrez_outputs.primitives << {
      x: @w.idiv(2),
      y: @h.idiv(2),
      text: "mouse x: #{lowrez_mouse.x}, y: #{lowrez_mouse.y}",
      size_px: 5,
      anchor_x: 0.5,
      anchor_y: 0.5,
      font: "fonts/lowrez.ttf",
    }

    lowrez_outputs.primitives << @button_rect.merge(
      path: :solid,
      r: 128, g: 128, b: 128,
    )

    lowrez_outputs.primitives << {
      x: @button_rect.x + @button_rect.w.idiv(2),
      y: @button_rect.y + @button_rect.h.idiv(2),
      text: @button_text,
      size_px: 5,
      anchor_x: 0.5,
      anchor_y: 0.5,
      font: "fonts/lowrez.ttf",
    }
  end
end

DR.reset
