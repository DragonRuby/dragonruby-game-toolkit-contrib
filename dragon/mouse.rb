# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# mouse.rb has been released under MIT (*only this file*).

module GTK
  class MousePoint
    include GTK::Geometry

    attr_accessor :x, :y, :point, :created_at, :global_created_at

    def initialize x, y
      @x = x
      @y = y
      @point = { x: @x, y: @y, w: 0, h: 0 }
      @created_at = Kernel.tick_count
      @global_created_at = Kernel.global_tick_count
    end

    def w; 0; end
    def h; 0; end
    def left; x; end
    def right; x; end
    def top; y; end
    def bottom; y; end

    def created_at_elapsed
      @created_at.elapsed_time
    end

    def to_hash
      serialize
    end

    def serialize
      {
        x: @x,
        y: @y,
        created_at: @created_at,
        global_created_at: @global_created_at
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class Mouse
    attr_accessor :moved,
                  :moved_at,
                  :global_moved_at,
                  :up, :has_focus,
                  :button_bits, :button_left,
                  :button_middle, :button_right,
                  :button_x1, :button_x2,
                  :wheel, :relative_x, :relative_y,
                  :active

    attr_accessor :click
    attr_accessor :click_at
    attr_accessor :global_click_at
    attr_accessor :up_at
    attr_accessor :global_up_at
    attr_accessor :previous_click
    attr_accessor :x
    attr_accessor :y
    attr_accessor :previous_x
    attr_accessor :previous_y

    def initialize
      @x = 0
      @y = 0
      @has_focus = false
      @button_bits = 0
      @button_left = false
      @button_middle = false
      @button_right = false
      @button_x1 = false
      @button_x2 = false
      @relative_x = 0
      @relative_y = 0
      clear
    end

    def held
      return false if !global_click_at
      return true if global_click_at && !global_up_at
      return global_up_at < global_click_at
    end

    def held_at
      return nil if !held
      return click_at + 1
    end

    def global_held_at
      return nil if !held
      return global_click_at + 1
    end

    def point
      { x: @x, y: @y, w: 0, h: 0 }
    end

    def inside_rect? rect
      point.inside_rect? rect
    end

    def inside_circle? center, radius
      point.point_inside_circle? center, radius
    end

    def intersect_rect? other_rect
      rect.intersect_rect? other_rect
    end

    def rect
      { x: point.x, y: point.y, w: 0, h: 0 }
    end

    def merge o
      rect.merge o
    end

    def w
      0
    end

    def h
      0
    end

    alias_method :position, :point

    def clear
      if @click
        @previous_click = MousePoint.new @click.point.x, @click.point.y
        @previous_click.created_at = @click.created_at
        @previous_click.global_created_at = @click.global_created_at
      end

      @active = nil
      @click = nil
      @up    = nil
      @moved = nil
      @wheel = nil
      @relative_x = 0
      @relative_y = 0
    end

    def up
      @up
    end

    def down
      @click
    end

    def serialize
      result = {}

      if @click
        result[:click] = @click.to_hash
        result[:down] = @click.to_hash
      end

      result[:up] = @up.to_hash if @up
      result[:x] = @x
      result[:y] = @y
      result[:moved] = @moved
      result[:moved_at] = @moved_at
      result[:has_focus] = @has_focus

      result
    end

    def to_s
      serialize.to_s
    end

    alias_method :inspect, :to_s
  end

  class FingerTouch
    attr_accessor :moved,
                  :moved_at,
                  :global_moved_at,
                  :down_at,
                  :global_down_at,
                  :touch_order,
                  :first_tick_down,
                  :x, :y

    def initialize
      @moved = false
      @moved_at = 0
      @global_moved_at = 0
      @down_at = 0
      @global_down_at = 0
      @touch_order = 0
      @first_tick_down = true
      @x = 0
      @y = 0
    end

    def point
      [@x, @y].point
    end

    def inside_rect? rect
      point.inside_rect? rect
    end

    def inside_circle? center, radius
      point.point_inside_circle? center, radius
    end

    alias_method :position, :point

    def serialize
      result = {}
      result[:x] = @x
      result[:y] = @y
      result[:touch_order] = @touch_order
      result[:moved] = @moved
      result[:moved_at] = @moved_at
      result[:global_moved_at] = @global_moved_at
      result[:down_at] = @down_at
      result[:global_down_at] = @global_down_at

      result
    end

    def to_s
      serialize.to_s
    end

    alias_method :inspect, :to_s
  end
end
