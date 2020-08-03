# Emulation of a 64x64 canvas. Don't change this file unless you know what you're doing :-)
# Head over to main.rb and study the code there.

LOWREZ_SIZE            = 64
LOWREZ_ZOOM            = 10
LOWREZ_ZOOMED_SIZE     = LOWREZ_SIZE * LOWREZ_ZOOM
LOWREZ_X_OFFSET        = (1280 - LOWREZ_ZOOMED_SIZE).half
LOWREZ_Y_OFFSET        = ( 720 - LOWREZ_ZOOMED_SIZE).half

LOWREZ_FONT_XL         = -1
LOWREZ_FONT_XL_HEIGHT  = 20

LOWREZ_FONT_LG         = -3.5
LOWREZ_FONT_LG_HEIGHT  = 15

LOWREZ_FONT_MD         = -6
LOWREZ_FONT_MD_HEIGHT  = 10

LOWREZ_FONT_SM         = -8.5
LOWREZ_FONT_SM_HEIGHT  = 5

LOWREZ_FONT_PATH       = 'fonts/lowrez.ttf'


class LowrezOutputs
  attr_accessor :width, :height

  def initialize args
    @args = args
    @background_color ||= [0, 0, 0]
    @args.outputs.background_color = @background_color
  end

  def background_color
    @background_color ||= [0, 0, 0]
  end

  def background_color= opts
    @background_color = opts
    @args.outputs.background_color = @background_color

    outputs_lowrez.solids << [0, 0, LOWREZ_SIZE, LOWREZ_SIZE, @background_color]
  end

  def outputs_lowrez
    return @args.outputs if @args.state.tick_count <= 0
    return @args.outputs[:lowrez]
  end

  def solids
    outputs_lowrez.solids
  end

  def borders
    outputs_lowrez.borders
  end

  def sprites
    outputs_lowrez.sprites
  end

  def labels
    outputs_lowrez.labels
  end

  def default_label
    {
      x: 0,
      y: 63,
      text: "",
      size_enum: LOWREZ_FONT_SM,
      alignment_enum: 0,
      r: 0,
      g: 0,
      b: 0,
      a: 255,
      font: LOWREZ_FONT_PATH
    }
  end

  def lines
    outputs_lowrez.lines
  end

  def primitives
    outputs_lowrez.primitives
  end

  def click
    return nil unless @args.inputs.mouse.click
    mouse
  end

  def mouse_click
    click
  end

  def mouse_down
    @args.inputs.mouse.down
  end

  def mouse_up
    @args.inputs.mouse.up
  end

  def mouse
    [
      ((@args.inputs.mouse.x - LOWREZ_X_OFFSET).idiv(LOWREZ_ZOOM)),
      ((@args.inputs.mouse.y - LOWREZ_Y_OFFSET).idiv(LOWREZ_ZOOM))
    ]
  end

  def mouse_position
    mouse
  end

  def keyboard
    @args.inputs.keyboard
  end
end

class GTK::Args
  def init_lowrez
    return if @lowrez
    @lowrez = LowrezOutputs.new self
  end

  def lowrez
    @lowrez
  end
end

module GTK
  class Runtime
    alias_method :__original_tick_core__, :tick_core unless Runtime.instance_methods.include?(:__original_tick_core__)

    def tick_core
      @args.init_lowrez
      __original_tick_core__

      return if @args.state.tick_count <= 0

      @args.render_target(:lowrez)
           .labels
           .each do |l|
        l.y  += 1
      end

      @args.render_target(:lowrez)
           .lines
           .each do |l|
        l.y  += 1
        l.y2 += 1
        l.y2 += 1 if l.y1 != l.y2
        l.x2 += 1 if l.x1 != l.x2
      end

      @args.outputs
           .sprites << { x: 320,
                         y: 40,
                         w: 640,
                         h: 640,
                         source_x: 0,
                         source_y: 0,
                         source_w: 64,
                         source_h: 64,
                         path: :lowrez }
    end
  end
end
