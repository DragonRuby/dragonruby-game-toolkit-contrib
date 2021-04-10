# Copyright 2019 DragonRuby LLC
# MIT License
# layout.rb has been released under MIT (*only this file*).

module GTK
  class Margin
    attr :left, :right, :top, :bottom

    def initialize
      @left   = 0
      @right  = 0
      @top    = 0
      @bottom = 0
    end

    def serialize
      {
        left:   @left,
        right:  @right,
        top:    @top,
        bottom: @bottom,
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class SafeArea
    attr :w, :h, :margin

    def initialize
      @w      = 0
      @h      = 0
      @margin = Margin.new
    end

    def serialize
      {
        w:      @w,
        h:      @h,
        margin: @margin.serialize
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class GridArea
    attr :w, :h, :margin, :gutter, :col_count, :row_count, :cell_w, :cell_h, :outer_gutter

    def initialize
      @w            = 0
      @h            = 0
      @gutter       = 0
      @outer_gutter = 0
      @col_count    = 0
      @row_count    = 0
      @margin       = Margin.new
    end

    def serialize
      {
        w:            @w,
        h:            @h,
        gutter:       @gutter,
        outer_gutter: @outer_gutter,
        col_count:    @col_count,
        row_count:    @row_count,
        margin:       @margin.serialize
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class ControlArea
    attr :cell_size, :w, :h, :margin

    def initialize
      @margin = Margin.new
    end

    def serialize
      {
        cell_size: @cell_size,
        w:         @w,
        h:         @h,
        margin:    @margin.serialize,
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class Device
    attr :w, :h, :safe_area, :grid_area, :control_area, :name, :aspect

    def initialize
      @name         = ""
      @w            = 0
      @h            = 0
      @safe_area    = SafeArea.new
      @grid_area    = GridArea.new
      @control_area = ControlArea.new
      @aspect       = AspectRatio.new
    end

    def assert! result, message
      return if result
      raise message
    end

    def check_math!
      assert! (@control_area.w + @control_area.margin.left + @control_area.margin.right) == @w, "Math for Width didn't pan out."
      assert! (@control_area.h + @control_area.margin.top + @control_area.margin.bottom) == @h, "Math for Height didn't pan out."
    end

    def serialize
      {
        name:         @name,
        w:            @w,
        h:            @h,
        aspect:       @aspect.serialize,
        safe_area:    @safe_area.serialize,
        grid_area:    @grid_area.serialize,
        control_area: @control_area.serialize
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class AspectRatio
    attr :w, :h, :u

    def initialize
      @w = 0
      @h = 0
      @u = 0
    end

    def serialize
      {
        w: @w,
        h: @h,
        u: @u
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class Layout
    attr :w, :h, :rect_cache

    def initialize w, h
      @w = w
      @h = h
      @rect_cache = {}
      init_device @w, @h
    end

    def u_for_16x9 w, h
      u = (w.fdiv 16).floor
      u = (h.fdiv 9).floor if (u * 9) > h

      {
        u: u,
        w: u * 16,
        h: u * 9
      }
    end

    def font_relative_size_enum size_enum
      base_line_logical = 22
      base_line_actual = font_size_med
      target_logical = size_enum
      target_logical = 1 if target_logical <= 0
      (base_line_actual / base_line_logical) * target_logical
    end

    def font_px_to_pt px
      (px / 1.33333).floor
    end

    def font_pt_to_px pt
      pt * 1.333333
    end

    def font_size_cell
      (cell_height / 1.33333)
    end

    def font_size_xl
      font_size_cell
    end

    def font_size_lg
      font_size_cell * 0.8
    end

    def font_size_med
      font_size_cell * 0.7
    end

    def font_size_sm
      font_size_cell * 0.6
    end

    def font_size_xs
      font_size_cell * 0.5
    end

    def font_size
      font_size_cell * 0.7
    end

    def logical_rect
      @logical_rect ||= { x: 0,
                          y: 0,
                          w: @w,
                          h: @h }
    end

    def safe_rect
      @safe_rect ||= { x: 0,
                       y: 0,
                       w: @w,
                       h: @h }
    end

    def control_rect
      @control_rect ||= { x: device.control_area.margin.left,
                          y: device.control_area.margin.top,
                          w: device.control_area.w,
                          h: device.control_area.h }
    end

    def row_count
      device.grid_area.row_count
    end

    def col_count
      device.grid_area.col_count
    end

    def gutter_height
      device.grid_area.gutter
    end

    def gutter_width
      device.grid_area.gutter
    end

    def outer_gutter
      device.grid_area.outer_gutter
    end

    def cell_height
      device.control_area.cell_size
    end

    def cell_width
      device.control_area.cell_size
    end

    def rect_defaults
      {
        row: nil,
        col: nil,
        h:   1,
        w:   1,
        dx:  0,
        dy:  0,
        rect: :control_rect
      }
    end

    def rect opts
      opts = rect_defaults.merge opts
      result = send opts[:rect]
      if opts[:row] && opts[:col] && opts[:w] && opts[:h]
        col = rect_col opts[:col], opts[:w]
        row = rect_row opts[:row], opts[:h]
        result = control_rect.merge x: col.x,
                                    y: row.y,
                                    w: col.w,
                                    h: row.h
      elsif opts[:row] && !opts[:col]
        result = rect_row opts[:row], opts[:h]
      elsif !opts[:row] && opts[:col]
        result = rect_col opts[:col], opts[:w]
      else
        raise "LayoutTheory::rect unable to process opts #{opts}."
      end

      if opts[:max_height] && opts[:max_height] >= 0
        if result[:h] > opts[:max_height]
          delta = (result[:h] - opts[:max_height]) * 2
          result[:y] += delta
          result[:h] = opts[:max_height]
        end
      end

      if opts[:max_width] && opts[:max_width] >= 0
        if result[:w] > opts[:max_width]
          delta = (result[:w] - opts[:max_width]) * 2
          result[:x] += delta
          result[:w] = opts[:max_width]
        end
      end

      result[:x] += opts[:dx]
      result[:y] += opts[:dy]

      if opts[:include_row_gutter]
        result[:x] -= device.grid_area.gutter
        result[:w] += device.grid_area.gutter * 2
      end

      if opts[:include_col_gutter]
        result[:y] -= device.grid_area.gutter
        result[:h] += device.grid_area.gutter * 2
      end

      result[:x] += opts[:dx] if opts[:dx]
      result[:y] += opts[:dy] if opts[:dy]
      result[:w] += opts[:dw] if opts[:dw]
      result[:h] += opts[:dh] if opts[:dh]
      result[:row] = opts[:row]
      result[:col] = opts[:col]

      if $gtk.args.grid.name == :center
        result[:x] -= 640
        result[:y] -= 360
      end

      result
    end

    def rect_center reference, target
      delta_x = (reference.w - target.w).fdiv 2
      delta_y = (reference.h - target.h).fdiv 2
      [target.x - delta_x, target.y - delta_y, target.w, target.h]
    end

    def rect_row index, h
      @rect_cache[:row] ||= {}
      @rect_cache[:row][index] ||= {}
      return @rect_cache[:row][index][h] if @rect_cache[:row][index][h]
      row_h = (device.grid_area.gutter * (h - 1)) +
              (device.control_area.cell_size * h)

      row_h = row_h.to_i
      row_h -= 1 if row_h.odd?

      row_y = (control_rect.y) +
              (device.grid_area.gutter * index) +
              (device.control_area.cell_size * index)

      row_y = row_y.to_i
      row_y += 1 if row_y.odd? && (index + 1) > @device.grid_area.row_count.half
      row_y += 1 if row_y.odd? && (index + 1) <= @device.grid_area.row_count.half

      row_y = device.h - row_y - row_h

      result = control_rect.merge y: row_y, h: row_h
      @rect_cache[:row][index][h] = result
      @rect_cache[:row][index][h]
    end

    def rect_col index, w
      @rect_cache[:col] ||= {}
      @rect_cache[:col][index] ||= {}
      return @rect_cache[:col][index][w] if @rect_cache[:col][index][w]
      col_x = (control_rect.x) +
              (device.grid_area.gutter * index) +
              (device.control_area.cell_size * index)

      col_x = col_x.to_i
      col_x -= 1 if col_x.odd? && (index + 1) < @device.grid_area.col_count.half
      col_x += 1 if col_x.odd? && (index + 1) >= @device.grid_area.col_count.half

      col_w = (device.grid_area.gutter * (w - 1)) +
              (device.control_area.cell_size * w)

      col_w = col_w.to_i
      col_w -= 1 if col_w.odd?

      result = control_rect.merge x: col_x, w: col_w
      @rect_cache[:col][index][w] = result
      @rect_cache[:col][index][w]
    end

    def device
      @device
    end

    def init_device w, h
      @device      = Device.new
      @device.w    = w
      @device.h    = h
      @device.name = "Device"
      @device.aspect.w = (u_for_16x9 w, h)[:w]
      @device.aspect.h = (u_for_16x9 w, h)[:h]
      @device.aspect.u = (u_for_16x9 w, h)[:u]
      @device.safe_area.w             = @device.aspect.u * 16
      @device.safe_area.h             = @device.aspect.u * 9
      @device.safe_area.margin.left   = ((@device.w - @device.safe_area.w).fdiv 2).floor
      @device.safe_area.margin.right  = ((@device.w - @device.safe_area.w).fdiv 2).floor
      @device.safe_area.margin.top    = ((@device.h - @device.safe_area.h).fdiv 2).floor
      @device.safe_area.margin.bottom = ((@device.h - @device.safe_area.h).fdiv 2).floor
      @device.grid_area.outer_gutter  = @device.w / 80
      @device.grid_area.gutter        = @device.w / 160

      @device.grid_area.w = @device.safe_area.w - (@device.grid_area.outer_gutter * 2)
      @device.grid_area.h = @device.safe_area.h - (@device.grid_area.outer_gutter * 2)

      @device.grid_area.margin.left   = ((@device.w - @device.grid_area.w).fdiv 2).floor
      @device.grid_area.margin.right  = ((@device.w - @device.grid_area.w).fdiv 2).floor
      @device.grid_area.margin.top    = ((@device.h - @device.grid_area.h).fdiv 2).floor
      @device.grid_area.margin.bottom = ((@device.h - @device.grid_area.h).fdiv 2).floor

      @device.grid_area.col_count = 24
      @device.grid_area.row_count = 12
      @device.grid_area.cell_w = ((@device.aspect.w - (@device.grid_area.outer_gutter * 2)) - ((@device.grid_area.col_count - 1) * @device.grid_area.gutter)).fdiv @device.grid_area.col_count
      @device.grid_area.cell_h = ((@device.aspect.h - (@device.grid_area.outer_gutter * 2)) - ((@device.grid_area.row_count - 1) * @device.grid_area.gutter)).fdiv @device.grid_area.row_count

      @device.control_area.cell_size = @device.grid_area.cell_w
      @device.control_area.cell_size = @device.grid_area.cell_h if @device.grid_area.cell_h < @device.grid_area.cell_w && @device.grid_area.cell_h > 0
      @device.control_area.cell_size = @device.control_area.cell_size.floor
      @device.control_area.w = (@device.control_area.cell_size * @device.grid_area.col_count) + (@device.grid_area.gutter * (@device.grid_area.col_count - 1))
      @device.control_area.h = (@device.control_area.cell_size * @device.grid_area.row_count) + (@device.grid_area.gutter * (@device.grid_area.row_count - 1))
      @device.control_area.margin.left  = (@device.w - @device.control_area.w).fdiv 2
      @device.control_area.margin.right  = (@device.w - @device.control_area.w).fdiv 2
      @device.control_area.margin.top  = (@device.h - @device.control_area.h).fdiv 2
      @device.control_area.margin.bottom  = (@device.h - @device.control_area.h).fdiv 2
      @device
    end

    def serialize
      {
        device: @device.serialize,
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
