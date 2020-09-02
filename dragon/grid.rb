# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# grid.rb has been released under MIT (*only this file*).

module GTK
  class Grid
    include Serialize
    SCREEN_Y_DIRECTION = -1.0

    # The coordinate system currently in use.
    #
    # @return [Symbol] `:bottom_left` or `:center`
    attr_accessor :name

    # Returns the "x" coordinate indicating the bottom of the screen.
    #
    # @return [Float]
    attr_accessor :bottom

    # Returns the "x" coordinate indicating the top of the screen.
    #
    # @return [Float]
    attr_accessor :top

    # Returns the "y" coordinate indicating the left of the screen.
    #
    # @return [Float]
    attr_accessor :left

    # Returns the "y" coordinate indicating the right of the screen.
    #
    # @return [Float]
    attr_accessor :right

    # Returns the "x" coordinate indicating the center of the screen.
    #
    # @return [Float]
    attr_accessor :center_x

    # Returns the "y" coordinate indicating the center of the screen.
    #
    # @return [Float]
    attr_accessor :center_y

    # Returns the bottom left and top right coordinates in a single list.
    #
    # @return [[Float, Float, Float, Float]]
    attr_accessor :rect

    # Returns the "x" coordinate of the origin.
    #
    # @return [Float]
    attr_accessor :origin_x

    # Returns the "y" coordinate of the origin.
    #
    # @return [Float]
    attr_accessor :origin_y

    attr_accessor :left_margin, :bottom_margin

    def initialize runtime
      @runtime = runtime
      @ffi_draw = runtime.ffi_draw
      origin_bottom_left!
    end

    # Returns `x` plus the origin "x".
    #
    # @return [Float]
    def transform_x x
      @origin_x + x
    end

    # Returns `x` minus the origin "x".
    #
    # @return [Float]
    def untransform_x x
      x - @origin_x
    end

    # Returns `y` plus the origin "y".
    #
    # @return [Float]
    def transform_y y
      @origin_y + y * SCREEN_Y_DIRECTION
    end

    # Returns `y` minus the origin "y".
    #
    # @return [Float]
    def untransform_y y
      @origin_y + y * SCREEN_Y_DIRECTION
    end

    def ffi_draw
      @ffi_draw
    end

    def ffi_draw= value
      @ffi_draw = value
    end

    # Sets the rendering coordinate system to have its origin in the bottom left.
    #
    # @return [void]
    # @gtk
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
    end

    # Sets the rendering coordinate system to have its origin in the center.
    #
    # @return [void]
    # @gtk
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
    end

    # The logical width used for rendering.
    #
    # @return [Float]
    def w
      @runtime.logical_width
    end

    # Half the logical width used for rendering.
    #
    # @return [Float]
    def w_half
      w.half
    end

    # The logical height used for rendering.
    #
    # @return [Float]
    def h
      @runtime.logical_height
    end

    # Half the logical height used for rendering.
    #
    # @return [Float]
    def h_half
      h.half
    end

    # Returns the coordinates indicating the center of the screen.
    #
    # @return [[Float, Float]]
    def center
      @center
    end

    # Returns the coordinates indicating the bottom right of the screen.
    #
    # @return [[Float, Float]]
    def bottom_right
      [@right, @bottom].point
    end
  end
end
