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

    def to_h
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
                  :button_bits,
                  :button_left,
                  :button_middle,
                  :button_right,
                  :button_x1,
                  :button_x2,
                  :wheel, :relative_x, :relative_y,
                  :active

    attr_accessor :x
    attr_accessor :y
    attr_accessor :previous_x
    attr_accessor :previous_y
    attr_accessor :key_down, :key_up, :key_held
    attr_accessor :buttons

    def initialize
      @x = 0
      @y = 0
      @has_focus = false
      @button_bits = 0
      @relative_x = 0
      @relative_y = 0
      @buttons_left = MouseButton.new :left, 0, @x, @y
      @buttons_middle = MouseButton.new :middle, 1, @x, @y
      @buttons_right = MouseButton.new :right, 2, @x, @y
      @buttons_x1 = MouseButton.new :x1, 3, @x, @y
      @buttons_x2 = MouseButton.new :x2, 4, @x, @y
      @buttons = MouseButtons.new @buttons_left, @buttons_middle, @buttons_right, @buttons_x1, @buttons_x2
      @key_down = MouseKeysDown.new @buttons
      @key_up = MouseKeysUp.new @buttons
      @key_held = MouseKeysHeld.new @buttons
      clear
    end

    def click
      @buttons_left.click
    end

    def click= value
      @buttons_left.click = value
    end

    def click_at
      @buttons_left.click&.created_at
    end

    def global_click_at
      @buttons_left.click&.global_created_at
    end

    def held
      @buttons_left.held
    end

    def held_at
      @buttons_left.held&.created_at
    end

    def global_held_at
      @buttons_left.held&.global_created_at
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

    def left
      @buttons_left.click || @buttons_left.held
    end

    def middle
      @buttons_middle.click || @buttons_middle.held
    end

    def right
      @buttons_right.click || @buttons_right.held
    end

    def x1
      @buttons_x1.click || @buttons_x1.held
    end

    def x2
      @buttons_x2.click || @buttons_x2.held
    end

    def key_down? key
      @key_down.send key
    end

    def key_up? key
      @key_up.send key
    end

    def key_held? key
      @key_held.send key
    end

    def key_down_or_held? key
      key_down?(key) || key_held?(key)
    end

    alias_method :position, :point

    def previous_click
      @buttons_left.previous_click
    end

    def clear
      @active = nil
      @click = nil
      @up    = nil
      @moved = nil
      @wheel = nil
      @relative_x = 0
      @relative_y = 0

      @buttons.each do |button|
        if button.click
          button.previous_click = MousePoint.new button.click.point.x, button.click.point.y
          button.previous_click.created_at = button.click.created_at
          button.previous_click.global_created_at = button.click.global_created_at
        end

        button.clear
      end
    end

    def up
      @buttons_left.up
    end

    def up_at
      @buttons_left.up&.created_at
    end

    def global_up_at
      @buttons_left.up&.global_created_at
    end

    def down
      @buttons_left.down
    end

    def to_h
      serialize
    end

    def to_hash
      serialize
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

    def buffered_click
      @buttons_left.buffered_click   ||
      @buttons_middle.buffered_click ||
      @buttons_right.buffered_click  ||
      @buttons_x1.buffered_click     ||
      @buttons_x2.buffered_click
    end

    def buffered_held
      @buttons_left.buffered_held   ||
      @buttons_middle.buffered_held ||
      @buttons_right.buffered_held  ||
      @buttons_x1.buffered_held     ||
      @buttons_x2.buffered_held
    end
  end

  class FingerTouch
    attr_accessor :moved,
                  :moved_at,
                  :global_moved_at,
                  :down_at,
                  :global_down_at,
                  :touch_order,
                  :first_tick_down,
                  :x, :y,
                  :previous_x, :previous_y

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
