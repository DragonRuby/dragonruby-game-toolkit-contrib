class Player
  attr :game, :x, :y, :w, :h, :ordinal_x, :ordinal_y

  def initialize(game:, x:, y:, w:, h:, ordinal_x:, ordinal_y:)
    @game = game
    @x = x
    @y = y
    @w = w
    @h = h
    @ordinal_x = ordinal_x
    @ordinal_y = ordinal_y
  end

  def primitives
    [
      {
        x: @x,
        y: @y,
        w: @w,
        h: @h,
        path: :solid,
        r: 128,
        g: 255,
        b: 128
      },
    ]
  end
end
