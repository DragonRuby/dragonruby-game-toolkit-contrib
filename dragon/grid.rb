# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# grid.rb has been released under MIT (*only this file*).

module GTK
  class Grid
    include Serialize
    SCREEN_Y_DIRECTION = -1.0

    attr_accessor :bottom, :left, :right, :top,
                  :rect, :origin_x, :origin_y, :center_x, :center_y,
                  :name, :ffi_draw

    def initialize ffi_draw
      @ffi_draw = ffi_draw
      origin_bottom_left!
    end

    def transform_x x
      @origin_x + x
    end

    def untransform_x x
      x - @origin_x
    end

    def untransform_y y
      @origin_y + y * SCREEN_Y_DIRECTION
    end

    def transform_y y
      @origin_y + y * SCREEN_Y_DIRECTION
    end

    def origin_bottom_left!
      return if @name == :bottom_left
      @name = :bottom_left
      @origin_x = 0.0
      @origin_y = 720.0
      @left   = 0.0
      @right  = 1280.0
      @top    = 720.0
      @bottom = 0.0
      @center_x = 640.0
      @center_y = 360.0
      @rect   = [@left, @bottom, 1280.0, 720.0].rect
      @center = [@center_x, @center_y].point
      @ffi_draw.set_gtk_grid @origin_x, @origin_y, SCREEN_Y_DIRECTION
    end

    def origin_center!
      return if @name == :center
      @name = :center
      @origin_x = 640.0
      @origin_y = 360.0
      @left   =  -640.0
      @right  =   640.0
      @top    =   360.0
      @bottom =  -360.0
      @center_x = 0.0
      @center_y = 0.0
      @rect   = [@left, @bottom, 1280.0, 720.0].rect
      @center = [@center_x, @center_y].point
      @ffi_draw.set_gtk_grid @origin_x, @origin_y, SCREEN_Y_DIRECTION
    end

    def w
      1280.0
    end

    def w_half
      640.0
    end

    def h
      720.0
    end

    def h_half
      360.0
    end

    def center
      @center
    end

    def bottom_right
      [@right, @bottom].point
    end
  end
end
