# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# layout.rb has been released under MIT (*only this file*).

module GTK
  class Layout
    attr :w, :h, :aspect_ratio_w, :aspect_ratio_h, :orientation,
         :gutter_left, :gutter_right, :gutter_top, :gutter_bottom,
         :cell_size, :gutter

    def initialize w, h, aspect_ratio_w, aspect_ratio_h, orientation
      reinitialize w, h, aspect_ratio_w, aspect_ratio_h, orientation
    end

    def tick_after left, bottom, w, h, aspect_ratio_w, aspect_ratio_h, orientation, origin_name
      if @grid_origin_name != origin_name
        @debug_primitives = nil
      end

      @left = left
      @bottom = bottom
      @w = w
      @h = h
      @aspect_ratio_w = aspect_ratio_w
      @aspect_ratio_h = aspect_ratio_h
      @orientation = orientation
      @grid_origin_name = origin_name
    end

    def reinitialize w, h, aspect_ratio_w, aspect_ratio_h, orientation
      @grid_origin_name = :bottom_left
      @debug_primitives = nil
      @left = 0
      @bottom = 0
      @w = w
      @h = h
      @aspect_ratio_w = aspect_ratio_w
      @aspect_ratio_h = aspect_ratio_h
      @orientation = orientation
      @gutter_left   = 18
      @gutter_right  = 18
      @gutter_top    = 47
      @gutter_bottom = 52
      @cell_size     = 48
      @gutter        = 4
      @row_count     = 12
      @col_count     = 24

      if @orientation == :portrait
        @gutter_left   = 50
        @gutter_right  = 50
        @gutter_top    = 15
        @gutter_bottom = 15
        @cell_size     = 48
        @gutter        = 4
        @row_count     = 24
        @col_count     = 12
      end

      @safe_area_top_left_dx = -@gutter_left + @gutter
      @safe_area_top_left_dy = @gutter_top - 1

      @safe_area_bottom_left_dx = -@gutter_left + @gutter
      @safe_area_bottom_left_dy = (h - rect(row: 0, col: 0, w: 1, h: @row_count).h).idiv(2) - @gutter

      @safe_area_top_right_dx = (w - rect(row: 0, col: 0, w: @col_count, h: 1).w).idiv(2) - @gutter
      @safe_area_top_right_dy = @gutter_top - 1

      @safe_area_bottom_right_dx = (w - rect(row: 0, col: 0, w: @col_count, h: 1).w).idiv(2) - @gutter
      @safe_area_bottom_right_dy = (h - rect(row: 0, col: 0, w: 1, h: @row_count).h).idiv(2) - @gutter
    end

    def rect(*ignore_splat, row: 0, col: 0,
             w: 1, h: 1,
             row_from_bottom: nil,
             col_from_right: nil,
             max_width: nil, max_height: nil,
             dx: 0, dy: 0,
             include_row_gutter: false, include_col_gutter: false,
             merge: nil, origin: :top_left, safe_area: true, **ignore_kwargs)
      opts_col        = col || 0
      opts_row        = row || 0

      if opts_col.is_a?(Array) && opts_col.length == 2
        # eg rect(row: [3, 18])
        opts_from_col = col[0]
        opts_to_col   = col[1]

        # eg rect(row: [5, -5])
        opts_to_col   = opts_to_col - 1 + @col_count if opts_to_col <= 0

        opts_col      = opts_from_col
        opts_w        = opts_to_col - opts_from_col + 1
      else
        opts_w          = w || 1
      end

      if opts_row.is_a?(Array) && opts_row.length == 2
        opts_from_row = row[0]
        opts_to_row   = row[1]
        opts_to_row   = opts_to_row - 1 + @row_count if opts_to_row <= 0
        opts_row      = opts_from_row
        opts_h        = opts_to_row - opts_from_row + 1
      else
        opts_h          = h || 1
      end

      opts_row        = row_max_index - row_from_bottom if row_from_bottom
      opts_col        = col_max_index - col_from_right if col_from_right
      opts_max_height = max_height || opts_h
      opts_max_width  = max_width || opts_w
      opts_dx         = dx || 0
      opts_dy         = dy || 0

      opts_h = max_height if opts_h > opts_max_height
      opts_w = max_width  if opts_w > opts_max_width

      if origin == :bottom_left
        opts_row = row_count - opts_row - opts_h
      elsif origin == :bottom_right
        opts_row = row_count - opts_row - opts_h
        opts_col = col_count - opts_col - opts_w
      elsif origin == :top_right
        opts_col = col_count - opts_col - opts_w
      end

      rect_x = @left + @gutter_left + @gutter * opts_col + @cell_size * opts_col
      rect_y = @bottom + @h - @gutter_top - (@gutter * opts_row) - (@cell_size * opts_row) - (@cell_size * opts_h) - (@gutter * opts_h - 1)
      rect_w = @gutter * (opts_w - 1) + (@cell_size * opts_w)
      rect_h = @gutter * (opts_h - 1) + (@cell_size * opts_h)

      rect_x += opts_dx
      rect_y += opts_dy

      if !safe_area
        if origin == :top_left
          rect_x += @safe_area_top_left_dx
          rect_y += @safe_area_top_left_dy
        elsif origin == :bottom_left
          rect_x += @safe_area_bottom_left_dx
          rect_y -= @safe_area_bottom_left_dy
        elsif origin == :top_right
          rect_x += @safe_area_top_right_dx
          rect_y += @safe_area_top_right_dy
        elsif origin == :bottom_right
          rect_x += @safe_area_bottom_right_dx
          rect_y -= @safe_area_bottom_right_dy
        end
      end

      if include_col_gutter
        rect_x -= @gutter
        rect_w += @gutter * 2
      end

      if include_row_gutter
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

      result.merge! merge if merge
      result
    end

    def rects items,
              direction: :row,
              row: 0,
              col: 0,
              w: 1,
              h: 1,
              include_row_gutter: false,
              include_col_gutter: false

      return [] if !items
      return [] if items.length == 0

      running_row = row
      running_col = col
      results = []

      items.each_with_index do |item, i|
        if direction == :row
          if running_col + w > col_count && i > 0
            running_col = col
            running_row += h
          end
        elsif direction == :col
          if running_row + h > row_count && i > 0
            running_row = row
            running_col += w
          end
        end

        if (item.is_a?(Hash) || item.respond_to?(:rect_args)) && item.rect_args
          r_w = item.rect_args.w
          r_h = item.rect_args.h
          r_include_row_gutter = item.rect_args.include_row_gutter
          r_include_col_gutter = item.rect_args.include_col_gutter
        end

        r_w                  ||= w
        r_h                  ||= h
        r_include_row_gutter ||= include_row_gutter
        r_include_col_gutter ||= include_col_gutter

        r = rect row: running_row,
                 col: running_col,
                 w: r_w,
                 h: r_h,
                 include_row_gutter: r_include_row_gutter,
                 include_col_gutter: r_include_col_gutter

        results << r.merge(item: item,
                           layout: { row: running_row,
                                     col: running_col,
                                     w: r_w,
                                     h: r_h,
                                     include_row_gutter: r_include_row_gutter,
                                     include_col_gutter: r_include_col_gutter })

        if direction == :row
          running_col += r_w
        elsif direction == :col
          running_row += r_h
        end
      end

      results
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

    def __debug_primitives_crosshair__
      [
        {
          id: :crosshair_diagonal_top_left_to_bottom_right,
          x: @left + Grid.w / 2,
          y: @bottom + Grid.h / 2,
          w: gutter,
          h: Grid.allscreen_h * 2,
          angle: 45,
          anchor_x: 0.5,
          anchor_y: 0.5,
          r: 232, g: 232, b: 232,
          path: :solid,
        },
        {
          id: :crosshair_diagonal_bottom_left_to_top_right,
          x: @left + Grid.w / 2,
          y: @bottom + Grid.h / 2,
          w: Grid.allscreen_w * 2,
          h: gutter,
          angle: 45,
          anchor_x: 0.5,
          anchor_y: 0.5,
          r: 232, g: 232, b: 232,
          path: :solid,
        },
        {
          id: :crosshair_left,
          x: @left + 0,
          y: @bottom + Grid.h / 2,
          h: Grid.allscreen_h,
          w: gutter,
          anchor_x: 0.5,
          anchor_y: 0.5,
          path: :solid,
          r: 128, g: 128, b: 128
        },
        {
          id: :crosshair_right,
          x: @left + Grid.w,
          y: @bottom + Grid.h / 2,
          h: Grid.allscreen_h,
          w: gutter,
          anchor_x: 0.5,
          anchor_y: 0.5,
          path: :solid,
          r: 128, g: 128, b: 128
        },
        {
          id: :crosshair_bottom,
          x: @left + Grid.w / 2,
          y: @bottom + 0,
          h: gutter,
          w: Grid.allscreen_w,
          anchor_x: 0.5,
          anchor_y: 0.5,
          path: :solid,
          r: 128, g: 128, b: 128
        },
        {
          id: :crosshair_top,
          x: @left + Grid.w / 2,
          y: @bottom + Grid.h,
          h: gutter,
          w: Grid.allscreen_w,
          anchor_x: 0.5,
          anchor_y: 0.5,
          path: :solid,
          r: 128, g: 128, b: 128
        },
      ]
    end

    def __debug_primitives_seperators__
      single_cell = rect row: row_count - 1, col: 0, w: 1, h: 1
      double_cell = rect row: row_count - 1, col: 0, w: 2, h: 2
      single_row = rect row: 0, col: 0, w: col_count, h: 1
      single_col = rect row: 0, col: 0, w: 1, h: row_count
      safe_area = rect row: 0, col: 0, w: col_count, h: row_count, include_row_gutter: true, include_col_gutter: true
      bg_rect = rect(row: 0, col: 1, w: col_count, h: 1).merge(w: Grid.w - gutter)

      one_quarter_vertical   = { id: :one_quarter_vertical,
                                 x: Layout.rect(col: @col_count.idiv(4)).x - @gutter / 2,
                                 y: safe_area.y,
                                 w: gutter,
                                 h: safe_area.h,
                                 path: :pixel,
                                 r: 232,
                                 g: 232,
                                 b: 232,
                                 anchor_x: 0.5 }
      two_quarter_vertical   = { id: :two_quarter_vertical,
                                 x: Layout.rect(col: @col_count.idiv(4) * 2).x - @gutter / 2,
                                 y: safe_area.y,
                                 w: gutter,
                                 h: safe_area.h,
                                 path: :pixel,
                                 r: 128,
                                 g: 128,
                                 b: 128,
                                 anchor_x: 0.5 }
      three_quarter_vertical = { id: :three_quarter_vertical,
                                 x: Layout.rect(col: @col_count.idiv(4) * 3).x - @gutter / 2,
                                 y: safe_area.y,
                                 w: gutter,
                                 h: safe_area.h,
                                 path: :pixel,
                                 r: 232,
                                 g: 232,
                                 b: 232,
                                 anchor_x: 0.5}

      one_quarter_horizontal = { id: :one_quarter_horizontal,
                                 x: safe_area.x,
                                 y: Layout.rect(row: @row_count.idiv(4) * 1 - 1).y - @gutter / 2,
                                 w: safe_area.w,
                                 h: gutter,
                                 path: :pixel,
                                 r: 232,
                                 g: 232,
                                 b: 232,
                                 anchor_y: 0.5 }

      two_quarter_horizontal = { id: :two_quarter_horizontal,
                                 x: safe_area.x,
                                 y: Layout.rect(row: @row_count.idiv(2) - 1).y - @gutter / 2,
                                 w: safe_area.w,
                                 h: gutter,
                                 path: :pixel,
                                 r: 128,
                                 g: 128,
                                 b: 128,
                                 anchor_y: 0.5 }

      three_quarter_horizontal = { id: :three_quarter_horizontal,
                                   x: safe_area.x,
                                   y: Layout.rect(row: @row_count.idiv(4) * 3 - 1).y - @gutter / 2,
                                   w: safe_area.w,
                                   h: gutter,
                                   path: :pixel,
                                   r: 232,
                                   g: 232,
                                   b: 232,
                                   anchor_y: 0.5 }

      single_cell_border = { id: :single_cell_border, **safe_area, primitive_marker: :border }

      single_cell_bg = { id: :single_cell_bg,
                         x: safe_area.center.x,
                         y: @bottom + @h - 14,
                         anchor_x: 0.5,
                         anchor_y: 0.5,
                         h: 24,
                         w: bg_rect.w,
                         path: :pixel,
                         r: 0,
                         g: 0,
                         b: 0,
                         a: 255 }

      single_cell_bg_bottom = { id: :single_cell_bg_bottom,
                                x: safe_area.center.x,
                                y: @bottom + 0 + 14,
                                anchor_x: 0.5,
                                anchor_y: 0.5,
                                h: 24,
                                w: bg_rect.w,
                                path: :pixel,
                                r: 0,
                                g: 0,
                                b: 0,
                                a: 255 }

      values = [
        "scaling: [#{Grid.texture_scale_enum.fdiv(100).to_sf}]",
        "safe area: [#{safe_area.x},#{safe_area.y},#{safe_area.w},#{safe_area.h}]",
        "cell: [#{single_cell.w},#{single_cell.h}]",
        "cell 2X: [#{double_cell.w},#{double_cell.h}]"
      ]

      single_cell_label = { id: :single_cell_label,
                            x: safe_area.center.x,
                            y: @bottom + @h - 14,
                            text: values.join(" "),
                            anchor_x: 0.5,
                            anchor_y: 0.5,
                            r: 255, g: 255, b: 255, a: 255,
                            size_px: 18 }

      single_cell_label_bottom = { id: :single_cell_label_bottom,
                                   x: safe_area.center.x,
                                   y: @bottom + 0 + 14,
                                   text: "To invert colors use Layout.debug_primitives(invert_colors: true)",
                                   anchor_x: 0.5,
                                   anchor_y: 0.5,
                                   r: 255, g: 255, b: 255, a: 255,
                                   size_px: 18 }

      [one_quarter_horizontal,
       two_quarter_horizontal,
       three_quarter_horizontal,
       one_quarter_vertical,
       two_quarter_vertical,
       three_quarter_vertical,
       single_cell_border,
       single_cell_bg,
       single_cell_label,
       single_cell_bg_bottom,
       single_cell_label_bottom]
    end

    def __debug_primitives_cell_prefabs__(color:)
      col_count.map_with_index do |col|
        row_count.map_with_index do |row|
          cell   = rect row: row, col: col
          center = Geometry.rect_center_point cell
          [
            cell.copy
                .border!(id: "row_#{row}_col_#{col}_border".to_sym,
                         row: row,
                         col: col,
                         **color,
                         docs: "border for cell at row #{row}, col #{col}"),
            cell.copy
                .label!(id: "row_#{row}_col_#{col}_oridinal_label".to_sym,
                        x: cell.center.x,
                        y: cell.center.y,
                        text: "#{row},#{col}",
                        size_px: 12,
                        anchor_x: 0.5,
                        anchor_y: 0.5 + 0.5,
                        row: row,
                        col: col,
                        **color,
                        docs: "label for cell at row #{row}, col #{col}"),
            cell.copy
                .label!(id: "row_#{row}_col_#{col}_px_label".to_sym,
                        x: cell.center.x,
                        y: cell.center.y,
                        text: "#{cell.x},#{cell.y}",
                        size_px: 12,
                        anchor_x: 0.5,
                        anchor_y: 0.5 - 0.5,
                        row: row,
                        col: col,
                        **color,
                        docs: "label for cell at row #{row}, col #{col}")

          ]
        end
      end.flatten
    end

    def __debug_primitives__(color:)
      __debug_primitives_cell_prefabs__(color: color) +
      __debug_primitives_crosshair__ +
      __debug_primitives_seperators__
    end

    def debug_primitives(invert_colors: false)
      color = if invert_colors
                { r: 255, g: 255, b: 255 }
              else
                { r: 0, g: 0, b: 0 }
              end

      @debug_primitives_colors ||= color

      if @debug_primitives_colors != color
        @debug_primitives = nil
        @debug_primitives_colors = color
      end

      @debug_primitives ||= __debug_primitives__(color: color)
    end

    def serialize
      {
        w: @w,
        h: @h,
        aspect_ratio_w: @aspect_ratio_w,
        aspect_ratio_h: @aspect_ratio_h,
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

    def orientation_changed!
      @w = Grid.w
      @h = Grid.h
      @aspect_ratio_w = Grid.aspect_ratio_w
      @aspect_ratio_h = Grid.aspect_ratio_h
      @orientation = Grid.orientation
      reinitialize @w, @h, @aspect_ratio_w, @aspect_ratio_h, @orientation
    end

    def reset
      reinitialize @w, @h, @aspect_ratio_w, @aspect_ratio_h, @orientation
    end

    def landscape?
      Grid.landscape?
    end

    def portrait?
      Grid.portrait?
    end

    class << self
      def method_missing(m, *args, &block)
        if $layout.respond_to? m
          define_singleton_method(m) do |*args, &block|
            $layout.send m, *args, &block
          end
          send m, *args, &block
        elsif $layout.class.respond_to? m
          define_singleton_method(m) do |*args, &block|
            $layout.class.send m, *args, &block
          end
          send m, *args, &block
        else
          super
        end
      end
    end
  end
end

Layout = GTK::Layout
