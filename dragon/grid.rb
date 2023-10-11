# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# grid.rb has been released under MIT (*only this file*).

module GTK
  class Grid
    include Serialize
    include GridDeprecated
    SCREEN_Y_DIRECTION = -1.0

    attr_accessor :name
    attr_accessor :bottom
    attr_accessor :top
    attr_accessor :left
    attr_accessor :right
    attr_accessor :center_x
    attr_accessor :center_y
    attr_accessor :rect
    attr_accessor :origin_x
    attr_accessor :origin_y

    attr_accessor :left_margin, :bottom_margin

    attr :allscreen_left,
         :allscreen_right,
         :allscreen_top,
         :allscreen_bottom,
         :allscreen_width,
         :allscreen_height,
         :allscreen_offset_x,
         :allscreen_offset_y,
         :native_width,
         :native_height,
         :native_scale,
         :native_scale_enum,
         :window_width,
         :window_height

    def initialize runtime
      @runtime = runtime
      @ffi_draw = runtime.ffi_draw
      origin_bottom_left!
    end

    def orientation
      @runtime.orientation
    end

    def transform_x x
      @origin_x + x
    end

    def untransform_x x
      x - @origin_x
    end

    def transform_y y
      @origin_y + y * SCREEN_Y_DIRECTION
    end

    def untransform_y y
      @origin_y + y * SCREEN_Y_DIRECTION
    end

    def ffi_draw
      @ffi_draw
    end

    def ffi_draw= value
      @ffi_draw = value
    end

    def origin_bottom_left!
      return if @name == :bottom_left
      @name = :bottom_left
      @origin_x = 0.0
      @origin_y = @runtime.logical_height
      @left   = 0.0
      @right  = @runtime.logical_width
      @top    = @runtime.logical_height
      @bottom = 0.0
      @left_margin = 0.0
      @bottom_margin = 0.0
      @center_x = @runtime.logical_width.half
      @center_y = @runtime.logical_height.half
      @rect   = [@left, @bottom, @runtime.logical_width, @runtime.logical_height].rect
      @center = [@center_x, @center_y].point
      @ffi_draw.set_grid @origin_x, @origin_y, SCREEN_Y_DIRECTION
      @device_left       ||= @left
      @device_right      ||= @right
      @device_top        ||= @top
      @device_bottom     ||= @bottom
      @device_width      ||= @runtime.logical_width
      @device_height     ||= @runtime.logical_height
      @native_width      ||= @runtime.logical_width
      @native_height     ||= @runtime.logical_height
      @native_scale      ||= 1.0
      @native_scale_enum ||= 1.0
    end

    def origin_center!
      return if @name == :center
      @name = :center
      @origin_x = @runtime.logical_width.half
      @origin_y = @runtime.logical_height.half
      @left   =  -@runtime.logical_width.half
      @right  =   @runtime.logical_width.half
      @top    =   @runtime.logical_height.half
      @bottom =  -@runtime.logical_height.half
      @center_x = 0.0
      @center_y = 0.0
      @rect   = [@left, @bottom, @runtime.logical_width, @runtime.logical_height].rect
      @center = [@center_x, @center_y].point
      @ffi_draw.set_grid @origin_x, @origin_y, SCREEN_Y_DIRECTION
      @device_left     ||= @left
      @device_right    ||= @right
      @device_top      ||= @top
      @device_bottom   ||= @bottom
      @device_width    ||= @runtime.logical_width
      @device_height   ||= @runtime.logical_height
      @render_width    ||= @runtime.logical_width
      @render_height   ||= @runtime.logical_height
      @render_scale    ||= 1.0
      @render_offset_x ||= 0
      @render_offset_y ||= 0
    end

    def w
      @runtime.logical_width
    end

    def w_half
      w.half
    end

    def h
      @runtime.logical_height
    end

    def h_half
      h.half
    end

    def center
      @center
    end

    def bottom_right
      [@right, @bottom].point
    end

    def x
      0
    end

    def y
      0
    end
  end
end
