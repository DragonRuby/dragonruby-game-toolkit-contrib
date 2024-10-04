# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# grid.rb has been released under MIT (*only this file*).

module GTK
  class Grid
    include Serialize
    include GridDeprecated
    SCREEN_Y_DIRECTION = -1.0

    attr :origin_name

    attr :x, :x_px

    attr :y, :y_px

    attr :w, :w_px

    attr :h, :h_px

    attr :bottom, :bottom_px

    attr :top, :top_px

    attr :left, :left_px

    attr :right, :right_px

    attr :center_x, :center_x_px

    attr :center_y, :center_y_px

    attr :center, :center_px

    attr :origin_x, :origin_x_px

    attr :origin_y, :origin_y_px

    attr :allscreen_left, :allscreen_left_px

    attr :allscreen_right, :allscreen_right_px

    attr :allscreen_top, :allscreen_top_px

    attr :allscreen_bottom, :allscreen_bottom_px

    attr :allscreen_w, :allscreen_w_px, :allscreen_w_pt

    attr :allscreen_h, :allscreen_h_px, :allscreen_h_pt

    attr :allscreen_offset_x, :allscreen_offset_x_px

    attr :allscreen_offset_y, :allscreen_offset_y_px

    attr :texture_scale, :texture_scale_enum

    def initialize runtime
      @runtime = runtime
      @ffi_draw = runtime.ffi_draw
      __origin_bottom_left__!
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

    def __origin_bottom_left__!(force: false)
      if !force
        return if @origin_name == :bottom_left
      end
      @origin_name = :bottom_left
      @left        = 0.0
      @right       = @runtime.logical_width
      @top         = @runtime.logical_height
      @bottom      = 0.0
      @x           = 0.0
      @y           = 0.0
      @w           = @runtime.logical_width
      @h           = @runtime.logical_height
      @center_x    = @runtime.logical_width.half
      @center_y    = @runtime.logical_height.half
      @rect        = { x: @left, y: @bottom, w: @w, h: @h }
      @center      = { x: @center_x, y: @center_y }
      @origin_x    = 0.0
      @origin_y    = @runtime.logical_height
    end

    def origin_bottom_left!(force: false)
      __origin_bottom_left__!(force: force)
      @ffi_draw.set_grid @origin_x, @origin_y, SCREEN_Y_DIRECTION
    end

    def origin_center!(force: false)
      if !force
        return if @origin_name == :center
      end
      @origin_name = :center
      @left        = -@runtime.logical_width.half
      @right       = @runtime.logical_width.half
      @top         = @runtime.logical_height.half
      @bottom      = -@runtime.logical_height.half
      @x           = 0.0
      @y           = 0.0
      @w           = @runtime.logical_width
      @h           = @runtime.logical_height
      @center_x    = 0.0
      @center_y    = 0.0
      @rect        = { x: @left, y: @bottom, w: @runtime.logical_width, h: @runtime.logical_height }
      @center      = { x: @center_x, y: @center_y, w: 0, h: 0 }
      @origin_x    = @runtime.logical_width.half
      @origin_y    = @runtime.logical_height.half
      @ffi_draw.set_grid @origin_x, @origin_y, SCREEN_Y_DIRECTION
    end

    def x
      @left
    end

    def x_px
      @left_px
    end

    def y
      @bottom
    end

    def y_px
      @bottom_px
    end

    def allscreen_x
      @allscreen_left
    end

    def allscreen_x_px
      @allscreen_left_px
    end

    def allscreen_y
      @allscreen_bottom
    end

    def allscreen_y_px
      @allscreen_bottom_px
    end

    def w_half
      @w / 2
    end

    def h_half
      @h / 2
    end

    def rect
      { x: @left, y: @bottom, w: @w, h: @h }
    end

    def rect_px
      { x: @left_px, y: @bottom_px, w: @w_px, h: @h_px }
    end

    def allscreen_rect
      { x: @allscreen_left, y: @allscreen_bottom, w: @allscreen_w, h: @allscreen_h }
    end

    def allscreen_rect_px
      { x: @allscreen_left_px, y: @allscreen_bottom_px, w: @allscreen_w_px, h: @allscreen_h_px }
    end

    def letterbox?
      @letterbox
    end

    def letterbox
      @letterbox
    end

    def letterbox= value
      @letterbox = value
    end

    def landscape?
      @runtime.orientation == :landscape
    end

    def portrait?
      @runtime.orientation == :portrait
    end

    def aspect_ratio_w
      landscape? ? 16 : 9
    end

    def aspect_ratio_h
      landscape? ? 9 : 16
    end

    def hd?
      @hd ||= @hd = Cvars["game_metadata.hd"].value
    end

    alias_method :hd, :hd?

    def highdpi?
      @highdpi ||= Cvars["game_metadata.highdpi"].value
    end

    alias_method :highdpi, :highdpi?

    class << self
      def method_missing(m, *args, &block)
        if $grid.respond_to? m
          define_singleton_method(m) do |*args, &block|
            $grid.send m, *args, &block
          end
          send m, *args, &block
        elsif $grid.class.respond_to? m
          define_singleton_method(m) do |*args, &block|
            $grid.class.send m, *args, &block
          end
          send m, *args, &block
        else
          super
        end
      end
    end
  end
end

Grid = GTK::Grid
