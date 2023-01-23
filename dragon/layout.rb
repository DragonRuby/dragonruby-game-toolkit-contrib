# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# layout.rb has been released under MIT (*only this file*).

module GTK
  class Layout
    attr :w, :h, :ratio_w, :ratio_h, :orientation,
         :gutter_left, :gutter_right, :gutter_top, :gutter_bottom,
         :cell_size, :gutter

    def initialize w, h, ratio_w, ratio_h, orientation
      @w = w
      @h = h
      @ratio_w = ratio_w
      @ratio_h = ratio_h
      @orientation = orientation

      @gutter_left   = 20
      @gutter_right  = 20
      @gutter_top    = 52
      @gutter_bottom = 52
      @cell_size     = 48
      @gutter        = 4
      @row_count     = 12
      @col_count     = 24

      if @orientation == :portrait
        @gutter_left   = 52
        @gutter_right  = 52
        @gutter_top    = 20
        @gutter_bottom = 20
        @cell_size     = 48
        @gutter        = 4
        @row_count     = 24
        @col_count     = 12
      end
    end

    def rect *all_opts
      opts = {}

      if all_opts.length == 1
        opts = all_opts.first
      else
        opts = {}
        all_opts.each do |o|
          opts.merge! o
        end
      end

      opts_col        = opts[:col] || 0
      opts_row        = opts[:row] || 0
      opts_row        = row_max_index - opts[:row_from_bottom] if opts[:row_from_bottom]
      opts_col        = col_max_index - opts[:col_from_right] if opts[:col_from_right]
      opts_w          = opts[:w]   || 1
      opts_h          = opts[:h]   || 1
      opts_max_height = opts[:max_height] || opts_h
      opts_max_width  = opts[:max_width] || opts_w
      opts_dx         = opts[:dx] || 0
      opts_dy         = opts[:dy] || 0

      opts_h = opts[:max_height] if opts_h > opts_max_height
      opts_w = opts[:max_width]  if opts_w > opts_max_width

      rect_x = @gutter_left + @gutter * opts_col + @cell_size * opts_col
      rect_y = @h - @gutter_top - (@gutter * opts_row) - (@cell_size * opts_row) - (@cell_size * opts_h) - (@gutter * opts_h - 1)
      rect_w = @gutter * (opts_w - 1) + (@cell_size * opts_w)
      rect_h = @gutter * (opts_h - 1) + (@cell_size * opts_h)
      rect_x += opts_dx
      rect_y += opts_dy

      if opts[:include_row_gutter]
        rect_x -= @gutter
        rect_w += @gutter * 2
      end

      if opts[:include_col_gutter]
        rect_y -= @gutter
        rect_h += @gutter * 2
      end

      rect_w = 0 if rect_w < 0
      rect_h = 0 if rect_h < 0

      center_x = rect_x + rect_w / 2
      center_y = rect_y + rect_h / 2

      result = {
        x: rect_x,
        y: rect_y,
        w: rect_w,
        h: rect_h,
        center_x: center_x,
        center_y: center_y,
        center: { x: center_x, y: center_y }
      }

      result.merge! opts[:merge] if opts[:merge]
      result
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
      @control_rect ||= { x: @gutter_left,
                          y: @gutter_bottom,
                          w: @w - @gutter_left - @gutter_right,
                          h: @h - @gutter_top - @gutter_buttom }
    end

    def row_count
      @row_count
    end

    def row_max_index
      row_count - 1
    end

    def col_count
      @col_count
    end

    def col_max_index
      col_count - 1
    end

    def gutter_height
      @gutter
    end

    def gutter_width
      @gutter
    end

    def outer_gutter
      @gutter_left
    end

    def cell_height
      @cell_size
    end

    def cell_width
      @cell_size
    end

    def rect_defaults
      {
        row:      nil,
        col:      nil,
        h:        1,
        w:        1,
        dx:       0,
        dx_ratio: 1,
        dy:       0,
        dy_ratio: 1,
        dh_ratio: 1,
        dw_ratio: 1,
        merge:    nil,
        rect:     :control_rect
      }
    end

    def row n
      (rect row: n, col: 0, w: 0, h: 0).x
    end

    def row_from_bottom n
      (rect row: row_count - n, col: 0, w: 0, h: 0).x
    end

    def col n
      (rect row: 0, col: n, w: 0, h: 0).y
    end

    def col_from_right n
      (rect row: 0, col: col_max_index - n, w: 0, h: 0).y
    end

    def w n
      (rect row: 0, col: 0, w: n, h: 1).w
    end

    def h n
      (rect row: 0, col: 0, w: 1, h: n).h
    end

    def rect_group opts
      group = opts.group
      r     = opts.row || 0
      r     = row_max_index - opts.row_from_bottom if opts.row_from_bottom
      c     = opts.col || 0
      c     = col_max_index - opts.col_from_right  if opts.col_from_right
      drow  = opts.drow || 0
      dcol  = opts.dcol || 0
      w     = opts.w    || 0
      h     = opts.h    || 0
      merge = opts[:merge]

      running_row = r
      running_col = c

      running_col = calc_col_offset(opts.col_offset) if opts.col_offset
      running_row = calc_row_offset(opts.row_offset) if opts.row_offset

      group.map do |i|
        group_layout_opts = i.layout || {}
        group_layout_opts = group_layout_opts.merge row: running_row,
                                                    col: running_col,
                                                    merge: merge,
                                                    w: w, h: h
        result = (rect group_layout_opts).merge i

        if (i.is_a? Hash) && (i.primitive_marker == :label)
          if    i.alignment_enum == 1
            result.x += result.w.half
          elsif i.alignment_enum == 2
            result.x += result.w
          end
        end

        running_row += drow
        running_col += dcol
        result
      end
    end

    def calc_row_offset opts = {}
      count = opts[:count] || opts[:length] || 0
      h     = opts.h || 1
      (row_count - (count * h)) / 2.0
    end

    def calc_col_offset opts = {}
      count = opts[:count] || opts[:length] || 0
      w     = opts.w || 1
      (col_count - (count * w)) / 2.0
    end

    def point opts = {}
      opts.w = 1
      opts.h = 1
      opts.row ||= 0
      opts.col ||= 0
      r = rect opts
      r.x  += r.w * opts.col_anchor if opts.col_anchor
      r.y  += r.h * opts.row_anchor if opts.row_anchor
      r
    end

    def rect_center reference, target
      delta_x = (reference.w - target.w).fdiv 2
      delta_y = (reference.h - target.h).fdiv 2
      { x: target.x - delta_x, y: target.y - delta_y, w: reference.w, h: reference.h }
    end

    def debug_primitives opts = {}
      row_count_rework = 12
      col_count_rework = 24

      if @orientation == :portrait
        row_count_rework = 24
        col_count_rework = 12
      end

      @debug_primitives ||= col_count_rework.map_with_index do |col|
                        row_count_rework.map_with_index do |row|
                          cell   = rect row: row, col: col
                          center = Geometry.rect_center_point cell
                          [
                            cell.merge(opts).border!,
                            cell.merge(opts)
                                .label!(x: center.x,
                                        y: center.y,
                                        text: "#{row},#{col}",
                                        size_enum: -3,
                                        vertical_alignment_enum: 1,
                                        alignment_enum: 1)
                          ]
                        end
                      end
      @debug_primitives
    end

    def serialize
      {
        w: @w,
        h: @h,
        ratio_w: @ratio_w,
        ratio_h: @ratio_h,
        orientation: @orientation,
        gutter_left: @gutter_left,
        gutter_right: @gutter_right,
        gutter_top: @gutter_top,
        gutter_bottom: @gutter_bottom,
        cell_size: @cell_size,
        gutter: @gutter
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def reset
      @debug_primitives = nil
    end
  end
end
