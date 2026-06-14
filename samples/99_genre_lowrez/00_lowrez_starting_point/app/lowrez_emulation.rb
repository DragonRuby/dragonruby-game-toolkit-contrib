# This is emulation code for lowrez, you don't have to worry about
# understanding this, go look at main.rb
class LowrezGame
  attr_gtk

  attr :w, :h

  def initialize(w:, h:)
    @w = w
    @h = h
  end

  def tick
  end

  def lowrez_outputs
    outputs[:lowrez].set w: @w,
                         h: @h,
                         background_color: [255, 255, 255]
    outputs[:lowrez]
  end

  def lowrez_mouse
    {
      x: (inputs.mouse.x - offset_x).idiv(zoom),
      y: (inputs.mouse.y - offset_y).idiv(zoom),
      w: 1,
      h: 1
    }
  end

  def zoom
    zoom_width = 1280.fdiv(@w)
    zoom_height = 720.fdiv(@h)
    zoom = [zoom_width, zoom_height].min
  end

  def offset_x
    (1280 - @w * zoom).fdiv(2)
  end

  def offset_y
    (720 - @h * zoom).fdiv(2)
  end

  def viewport_rect
    offset_x = (1280 - @w * zoom).fdiv(2)
    offset_y = (720 - @h * zoom).fdiv(2)
    w = @w * zoom
    h = @h * zoom

    {
      x: offset_x,
      y: offset_y,
      w: w,
      h: h
    }
  end
end

module Main
  def tick args
    @game ||= Game.new
    @game.args = args
    @game.tick
    args.outputs.background_color = [0, 0, 0]
    args.outputs.primitives << {
      **@game.viewport_rect,
      path: :lowrez,
    }
  end

  def reset args
    @game = nil
  end
end
