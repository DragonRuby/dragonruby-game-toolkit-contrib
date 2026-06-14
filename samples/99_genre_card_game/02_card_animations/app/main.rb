class Game
  attr_dr

  def initialize
    @suites = [
      :spades
    ]

    @ranks = [
      :ten,
      :jack,
      :queen,
      :king,
      :ace,
    ]

    @cards = @suites.product(@ranks).map_with_index do |(suite, rank), i|
      render_rect = Layout.rect(row: 10, col: 11, w: 2, h: 2)
      { suite: suite, rank: rank, shown_at: nil, order: i, render_rect: render_rect, target_render_rect: render_rect, is_moving: false }
    end.shuffle
  end

  def card_prefab card
    if card.shown_at
      w_perc = 1.0
      path = "sprites/cards/#{card.suite}_#{card.rank}.png"
      if card.shown_at.elapsed_time < 0
        path = "sprites/cards/back.png"
      elsif card.shown_at.elapsed_time < 15
        w_perc = 1 - card.shown_at.elapsed_time / 15.0
        path = "sprites/cards/back.png"
      elsif card.shown_at.elapsed_time < 30
        w_perc = (card.shown_at.elapsed_time - 15) / 15.0
      end
      card.render_rect.merge(x: card.render_rect.x + ((card.render_rect.w - (card.render_rect.w * w_perc)) / 2),
                             w: card.render_rect.w * w_perc,
                             path: path)
    else
      card.render_rect.merge(path: "sprites/cards/back.png")
    end
  end

  def tick
    @cards.each do |c|
      c.render_rect.x = c.render_rect.x.lerp c.target_render_rect.x, 0.1
      c.render_rect.y = c.render_rect.y.lerp c.target_render_rect.y, 0.1
      if c.render_rect.x.round == c.target_render_rect.x.round && c.render_rect.y.round == c.target_render_rect.y.round
        c.is_moving = false
      else
        c.is_moving = true
      end
    end

    outputs.sprites << @cards.find_all { |c| !c.is_moving }.map { |c| card_prefab c  }
    outputs.sprites << @cards.find_all { |c|  c.is_moving }.map { |c| card_prefab c  }

    if inputs.mouse.click
      clicked_card = @cards.reverse.find { |c| Geometry.intersect_rect? inputs.mouse, c.render_rect }

      if clicked_card
        row = clicked_card.order.idiv(13) * 2
        col = (clicked_card.order % 13) * 1.5 + 2
        destination_rect = Layout.rect(row: row, col: col, w: 2, h: 2)
        clicked_card.shown_at = Kernel.tick_count + 60
        clicked_card.target_render_rect = destination_rect
      end
    end
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

DR.reset
