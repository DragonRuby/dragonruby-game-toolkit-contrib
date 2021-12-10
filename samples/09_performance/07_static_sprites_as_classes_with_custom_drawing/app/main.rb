# Sprites represented as Classes, with a draw_override method, and using the queue ~args.outputs.static_sprites~.
# is the fastest approach. This is comparable to what other game engines set as the default behavior.
# There are tradeoffs for all this speed if the creation of a full blown class, and bypassing
# functional/data-oriented practices.
class Star
  def initialize grid
    @grid = grid
    @x = (rand @grid.w) * -1
    @y = (rand @grid.h) * -1
    @w    = 4
    @h    = 4
    @s    = 1 + (4.randomize :ratio)
    @path = 'sprites/tiny-star.png'
  end

  def move
    @x += @s
    @y += @s
    @x = (rand @grid.w) * -1 if @x > @grid.right
    @y = (rand @grid.h) * -1 if @y > @grid.top
  end

  # if the object that is in args.outputs.sprites (or static_sprites)
  # respond_to? :draw_override, then the method is invoked giving you
  # access to the class used to draw to the canvas.
  def draw_override ffi_draw
    # first move then draw
    move

    # The argument order for ffi.draw_sprite is:
    # x, y, w, h, path
    ffi_draw.draw_sprite @x, @y, @w, @h, @path

    # The argument order for ffi_draw.draw_sprite_2 is (pass in nil for default value):
    # x, y, w, h, path,
    # angle, alpha

    # The argument order for ffi_draw.draw_sprite_3 is:
    # x, y, w, h,
    # path,
    # angle,
    # alpha, red_saturation, green_saturation, blue_saturation
    # tile_x, tile_y, tile_w, tile_h,
    # flip_horizontally, flip_vertically,
    # angle_anchor_x, angle_anchor_y,
    # source_x, source_y, source_w, source_h

    # The argument order for ffi_draw.draw_sprite_4 is:
    # x, y, w, h,
    # path,
    # angle,
    # alpha, red_saturation, green_saturation, blue_saturation
    # tile_x, tile_y, tile_w, tile_h,
    # flip_horizontally, flip_vertically,
    # angle_anchor_x, angle_anchor_y,
    # source_x, source_y, source_w, source_h,
    # blendmode_enum
  end
end

# calls methods needed for game to run properly
def tick args
  # sets console command when sample app initially opens
  if Kernel.global_tick_count == 0
    puts ""
    puts ""
    puts "========================================================="
    puts "* INFO: Static Sprites, Classes, Draw Override"
    puts "* INFO: Please specify the number of sprites to render."
    args.gtk.console.set_command "reset_with count: 100"
  end

  # init
  if args.state.tick_count == 0
    args.state.stars = args.state.star_count.map { |i| Star.new args.grid }
    args.outputs.static_sprites << args.state.stars
  end

  # render framerate
  args.outputs.background_color = [0, 0, 0]
  args.outputs.primitives << args.gtk.current_framerate_primitives
end

# resets game, and assigns star count given by user
def reset_with count: count
  $gtk.reset
  $gtk.args.state.star_count = count
end
