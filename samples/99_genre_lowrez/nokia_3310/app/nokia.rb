# Emulation of a 64x64 canvas. Don't change this file unless you know what you're doing :-)
# Head over to main.rb and study the code there.

NOKIA_WIDTH           = 84
NOKIA_HEIGHT          = 48
NOKIA_ZOOM            = 12
NOKIA_ZOOMED_WIDTH    = NOKIA_WIDTH  * NOKIA_ZOOM
NOKIA_ZOOMED_HEIGHT   = NOKIA_HEIGHT * NOKIA_ZOOM
NOKIA_X_OFFSET        = (1280 - NOKIA_ZOOMED_WIDTH).half
NOKIA_Y_OFFSET        = ( 720 - NOKIA_ZOOMED_HEIGHT).half

NOKIA_FONT_XL         = -1
NOKIA_FONT_XL_HEIGHT  = 20

NOKIA_FONT_LG         = -3.5
NOKIA_FONT_LG_HEIGHT  = 15

NOKIA_FONT_MD         = -6
NOKIA_FONT_MD_HEIGHT  = 10

NOKIA_FONT_SM         = -8.5
NOKIA_FONT_SM_HEIGHT  = 5

NOKIA_FONT_PATH       = 'fonts/lowrez.ttf'


class NokiaOutputs
  attr_accessor :width, :height

  def initialize args
    @args = args
  end

  def outputs_nokia
    return @args.outputs if @args.state.tick_count <= 0
    return @args.outputs[:nokia]
  end

  def solids
    outputs_nokia.solids
  end

  def borders
    outputs_nokia.borders
  end

  def sprites
    outputs_nokia.sprites
  end

  def labels
    outputs_nokia.labels
  end

  def default_label
    {
      x: 0,
      y: 63,
      text: "",
      size_enum: NOKIA_FONT_SM,
      alignment_enum: 0,
      r: 0,
      g: 0,
      b: 0,
      a: 255,
      font: NOKIA_FONT_PATH
    }
  end

  def lines
    outputs_nokia.lines
  end

  def primitives
    outputs_nokia.primitives
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
      ((@args.inputs.mouse.x - NOKIA_X_OFFSET).idiv(NOKIA_ZOOM)),
      ((@args.inputs.mouse.y - NOKIA_Y_OFFSET).idiv(NOKIA_ZOOM))
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
  def init_nokia
    return if @nokia
    @nokia = NokiaOutputs.new self
  end

  def nokia
    @nokia
  end
end

module GTK
  class Runtime
    alias_method :__original_tick_core__, :tick_core unless Runtime.instance_methods.include?(:__original_tick_core__)

    def tick_core
      @args.init_nokia

      __original_tick_core__

      return if @args.state.tick_count <= 0

      @args.render_target(:nokia)
           .labels
           .each do |l|
        l.y  += 1
        if (l.a || 255) > 128
          l.r = 67
          l.g = 82
          l.b = 61
          l.a = 255
        else
          l.a = 0
        end
      end

      @args.render_target(:nokia)
           .sprites
           .each do |s|
        if (s.a || 255) > 128
          s.a = 255
        else
          s.a = 0
        end
      end

      @args.render_target(:nokia)
           .solids
           .each do |s|
        if (s.a || 255) > 128
          s.r = 67
          s.g = 82
          s.b = 61
          s.a = 255
        else
          s.a = 0
        end
      end

      @args.render_target(:nokia)
           .borders
           .each do |s|
        if (s.a || 255) > 128
          s.r = 67
          s.g = 82
          s.b = 61
          s.a = 255
        else
          s.a = 0
        end
      end

      @args.render_target(:nokia)
           .lines
           .each do |l|
        l.y  += 1
        l.y2 += 1
        l.y2 += 1 if l.y1 != l.y2
        l.x2 += 1 if l.x1 != l.x2

        if (l.a || 255) > 128
          l.r = 67
          l.g = 82
          l.b = 61
          l.a = 255
        else
          l.a = 0
        end
      end

      @args.outputs.borders << {
        x: NOKIA_X_OFFSET      - 1,
        y: NOKIA_Y_OFFSET      - 1,
        w: NOKIA_ZOOMED_WIDTH  + 2,
        h: NOKIA_ZOOMED_HEIGHT + 2,
        r: 128, g: 128, b: 128
      }


      @args.outputs.background_color = [199, 240, 216]

      @args.outputs.solids << [0, 0, NOKIA_X_OFFSET, 720]
      @args.outputs.solids << [0, 0, 1280, NOKIA_Y_OFFSET]
      @args.outputs.solids << [NOKIA_X_OFFSET + NOKIA_ZOOMED_WIDTH, 0, NOKIA_X_OFFSET, 720]
      @args.outputs.solids << [0, NOKIA_Y_OFFSET.from_top, 1280, NOKIA_Y_OFFSET]

      @args.outputs
           .sprites << { x: NOKIA_X_OFFSET,
                         y: NOKIA_Y_OFFSET,
                         w: NOKIA_ZOOMED_WIDTH,
                         h: NOKIA_ZOOMED_HEIGHT,
                         source_x: 0,
                         source_y: 0,
                         source_w: NOKIA_WIDTH,
                         source_h: NOKIA_HEIGHT,
                         path: :nokia }

      if !@args.state.overlay_rendered
        (NOKIA_HEIGHT + 1).map_with_index do |i|
          @args.outputs.static_lines << {
            x:  NOKIA_X_OFFSET,
            y:  NOKIA_Y_OFFSET + (i * NOKIA_ZOOM),
            x2: NOKIA_X_OFFSET + NOKIA_ZOOMED_WIDTH,
            y2: NOKIA_Y_OFFSET + (i * NOKIA_ZOOM),
            r: 199,
            g: 240,
            b: 216,
            a: 100
          }.line!
        end

        (NOKIA_WIDTH + 1).map_with_index do |i|
          @args.outputs.static_lines << {
            x:  NOKIA_X_OFFSET + (i * NOKIA_ZOOM),
            y:  NOKIA_Y_OFFSET,
            x2: NOKIA_X_OFFSET + (i * NOKIA_ZOOM),
            y2: NOKIA_Y_OFFSET + NOKIA_ZOOMED_HEIGHT,
            r: 199,
            g: 240,
            b: 216,
            a: 100
          }.line!
        end

        @args.state.overlay_rendered = true
      end
    end
  end
end
