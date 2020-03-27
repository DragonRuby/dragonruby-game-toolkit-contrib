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
                  :name

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
      @origin_y = GAME_HEIGHT
      @left   = 0.0
      @right  = GAME_WIDTH
      @top    = GAME_HEIGHT
      @bottom = 0.0
      @center_x = GAME_WIDTH.half
      @center_y = GAME_HEIGHT.half
      @rect   = [@left, @bottom, GAME_WIDTH, GAME_HEIGHT].rect
      @center = [@center_x, @center_y].point
      @ffi_draw.set_gtk_grid @origin_x, @origin_y, SCREEN_Y_DIRECTION
    end

    def origin_center!
      return if @name == :center
      @name = :center
      @origin_x = GAME_WIDTH.half
      @origin_y = GAME_HEIGHT.half
      @left   =  -GAME_WIDTH.half
      @right  =   GAME_WIDTH.half
      @top    =   GAME_HEIGHT.half
      @bottom =  -GAME_HEIGHT.half
      @center_x = 0.0
      @center_y = 0.0
      @rect   = [@left, @bottom, GAME_WIDTH, GAME_HEIGHT].rect
      @center = [@center_x, @center_y].point
      @ffi_draw.set_gtk_grid @origin_x, @origin_y, SCREEN_Y_DIRECTION
    end

    def w
      GAME_WIDTH
    end

    def w_half
      w.half
    end

    def h
      GAME_HEIGHT
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
  end
end
