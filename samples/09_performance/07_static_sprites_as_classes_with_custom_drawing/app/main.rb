# Sprites represented as Classes, with a draw_override method, and using the queue ~args.outputs.static_sprites~.
# is the fastest approach. This is comparable to what other game engines set as the default behavior.
# There are tradeoffs for all this speed if the creation of a full blown class, and bypassing
# functional/data-oriented practices.
class Star
  def initialize
    @grid_w = Grid.w
    @grid_h = Grid.h
    @x = Numeric.rand(@grid_w) * -1
    @y = Numeric.rand(@grid_h) * -1
    @w = 4
    @h = 4
    @path = "sprites/tiny-star.png"
    @s = 1 + Numeric.rand(4.0) + Numeric.rand(1.0) ** 2
  end

  def tick
    @x += @s
    @y += @s
    @x = Numeric.rand(@grid_w) * -1 if @x > @grid_w
    @y = Numeric.rand(@grid_h) * -1 if @y > @grid_h
  end

  # if the object that is in args.outputs.sprites (or static_sprites)
  # respond_to? :draw_override, then the method is invoked giving you
  # access to the class used to draw to the canvas.
  def draw_override ffi_draw
    # iVars for this instance will be directly
    # queried to deteremine what should be rendered:
    # :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x,
    # :tile_y, :tile_w, :tile_h, :flip_horizontally,
    # :flip_vertically, :angle_anchor_x, :angle_anchor_y,
    # :source_x, :source_y, :source_w, :source_h, :blendmode_enum,
    # :source_x2, :source_y2, :source_x3, :source_y3, :x2, :y2, :x3, :y3,
    # :anchor_x, :anchor_y, :r2, :g2, :b2, :a2, :r3, :g3, :b3, :a3,
    # :scale_quality_enum, :blendmode
    ffi_draw.draw_sprite_ivar self
  end
end

class Game
  attr_dr

  def tick
    if Kernel.global_tick_count == 0
      puts ""
      puts ""
      puts "========================================================="
      puts "* INFO: Static Sprites, Classes, Draw Override"
      puts "* INFO: Please specify the number of sprites to render."
      DR.console.set_command "$game.reset_with count: 100"
    end

    if inputs.keyboard.key_down.space
      reset_with count: 40000
    end

    state.star_count ||= 0

    # init
    if Kernel.tick_count == 0
      @stars = state.star_count.map { |i| Star.new }
      outputs.static_sprites << @stars
    end

    Array.each(@stars, &:tick)

    # render framerate
    outputs.background_color = [0, 0, 0]
    outputs.primitives << DR.current_framerate_primitives
  end

  # resets game, and assigns star count given by user
  def reset_with count: count
    DR.reset
    DR.args.state.star_count = count
  end
end

def self.boot args
  args.state = {}
end

def self.tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def self.reset args
  $game = nil
end

DR.reset
