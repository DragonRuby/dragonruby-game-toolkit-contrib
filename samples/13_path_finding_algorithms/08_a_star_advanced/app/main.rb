require 'app/astar.rb'
require 'app/enemy.rb'
require 'app/player.rb'

class Game
  attr_dr

  attr :walls, :player, :enemies

  def initialize
    @enemies = [
      Enemy.new(game: self, **ordinal_rect(ordinal_x: 0, ordinal_y: 17)),
      Enemy.new(game: self, **ordinal_rect(ordinal_x: 8, ordinal_y: 17)),
      Enemy.new(game: self, **ordinal_rect(ordinal_x: 7, ordinal_y: 8)),
      Enemy.new(game: self, **ordinal_rect(ordinal_x: 12, ordinal_y: 14)),
    ]

    @player = Player.new(game: self, **ordinal_rect(ordinal_x: 31, ordinal_y: 0))

    @walls = [
      ordinal_rect(ordinal_x: 1, ordinal_y: 1),
      ordinal_rect(ordinal_x: 2, ordinal_y: 2),
      ordinal_rect(ordinal_x: 3, ordinal_y: 3),
      ordinal_rect(ordinal_x: 4, ordinal_y: 4),
      ordinal_rect(ordinal_x: 5, ordinal_y: 5),
      ordinal_rect(ordinal_x: 6, ordinal_y: 6),
      ordinal_rect(ordinal_x: 7, ordinal_y: 7),
      ordinal_rect(ordinal_x: 8, ordinal_y: 8),
      ordinal_rect(ordinal_x: 9, ordinal_y: 9),
      ordinal_rect(ordinal_x: 10, ordinal_y: 10),
      ordinal_rect(ordinal_x: 11, ordinal_y: 11),
      ordinal_rect(ordinal_x: 12, ordinal_y: 12),
      ordinal_rect(ordinal_x: 13, ordinal_y: 13),
      ordinal_rect(ordinal_x: 14, ordinal_y: 14),
      ordinal_rect(ordinal_x: 15, ordinal_y: 15),
      ordinal_rect(ordinal_x: 16, ordinal_y: 16),
    ]
  end

  def ordinal_rect(ordinal_x:, ordinal_y:)
    {
      x: ordinal_x * 40,
      y: ordinal_y * 40,
      w: 40,
      h: 40,
      ordinal_x: ordinal_x,
      ordinal_y: ordinal_y,
    }
  end

  def tick
    if inputs.keyboard.key_down.j
      @enemies.each(&:move_to_player!)
    elsif inputs.keyboard.key_down.k
      @enemies.each(&:move_to_home!)
    end
    @enemies.each(&:tick)
    render
  end

  def render
    outputs.background_color = [30, 30, 30]
    outputs.primitives << @walls.map do |w|
      w.merge(path: :solid, r: 128, g: 128, b: 128)
    end

    outputs.primitives << @player.primitives
    outputs.primitives << @enemies.map(&:primitives)
    outputs.primitives << {
      x: 640,
      y: 60,
      text: "press J to move enemies to player, press K to move back to start position",
      anchor_x: 0.5,
      anchor_y: 0.5,
      r: 255,
      g: 255,
      b: 255
    }
  end
end

module Main
  attr :game

  def boot args
    args.state = {}
  end

  def tick args
    @game ||= Game.new
    @game.args = args
    @game.tick
  end

  def did_reset args
    @game = nil
  end
end

DR.reset
