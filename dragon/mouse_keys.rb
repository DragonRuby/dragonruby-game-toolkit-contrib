# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# mouse_keys.rb has been released under MIT (*only this file*).

module GTK
  class MouseButtons
    include Enumerable

    attr_accessor :left, :middle, :right, :x1, :x2

    def initialize(left, middle, right, x1, x2)
      @left = left
      @middle = middle
      @right = right
      @x1 = x1
      @x2 = x2
      @buttons = [@left, @middle, @right, @x1, @x2]
    end

    def each
      @buttons.each do |item|
        yield item
      end
    end
  end

  class MouseKeys
    def initialize(mouse_buttons)
      @left = mouse_buttons.left
      @middle = mouse_buttons.middle
      @right = mouse_buttons.right
      @x1 = mouse_buttons.x1
      @x2 = mouse_buttons.x2
    end
  end

  class MouseKeysDown < MouseKeys
    def left
      @left.down
    end

    def middle
      @middle.down
    end

    def right
      @right.down
    end

    def x1
      @x1.down
    end

    def x2
      @x2.down
    end
  end

  class MouseKeysHeld < MouseKeys
    def left
      @left.held
    end

    def middle
      @middle.held
    end

    def right
      @right.held
    end

    def x1
      @x1.held
    end

    def x2
      @x2.held
    end
  end

  class MouseKeysUp < MouseKeys
    def left
      @left.up
    end

    def middle
      @middle.up
    end

    def right
      @right.up
    end

    def x1
      @x1.up
    end

    def x2
      @x2.up
    end
  end

  class MouseButton
    attr :id,
         :index,
         :x, :y,
         :relative_x, :relative_y,
         :click, :click_at, :global_click_at,
         :up, :up_at, :global_up_at,
         :previous_click

    alias_method :down, :click
    alias_method :down=, :click=
    alias_method :down_at, :click_at
    alias_method :down_at=, :click_at=
    alias_method :global_down_at, :global_click_at
    alias_method :global_down_at=, :global_click_at=

    def initialize id, index, x, y
      @id = id
      @index = index
    end

    def w; 0; end
    def h; 0; end

    def held
      click_occurred_last_frame = @global_click_at == Kernel.global_tick_count - 1
      up_occurred_after_click = if @global_click_at &&
                                   @global_up_at &&
                                   @global_up_at >= @global_click_at
                                  true
                                else
                                  false
                                end

      if !@global_click_at
        @held_point = nil
      elsif click_occurred_last_frame && !up_occurred_after_click
        @held_point = MousePoint.new @x, @y
        @held_point.created_at = @click.created_at + 1
        @held_point.global_created_at = @click.global_created_at + 1
      elsif !up_occurred_after_click
        @held_point ||= MousePoint.new @x, @y
        @held_point.created_at ||= @click.created_at + 1
        @held_point.global_created_at ||= @click.global_created_at + 1
        @held_point.x = @x
        @held_point.y = @y
      else
        @held_point = nil
      end

      if @held_point
        @held_point.x = @x
        @held_point.y = @y
      end

      @held_point
    end

    def held_at
      click_occurred_last_frame = @global_click_at == Kernel.global_tick_count - 1
      up_occurred_on_click_frame = @global_click_at && @global_up_at && @global_click_at == @global_up_at
      if click_occurred_last_frame && !up_occurred_on_click_frame
        @held_at = @click_at + 1
      end

      @held_at
    end

    def global_held_at
      click_occurred_last_frame = @global_click_at == Kernel.global_tick_count - 1
      up_occurred_on_click_frame = @global_click_at && @global_up_at && @global_click_at != @global_up_at
      if click_occurred_last_frame && !up_occurred_on_click_frame
        @global_held_at = @global_click_at + 1
      end

      @global_held_at
    end

    def buffered_click
      if @click && @up_at == @click_at
        # buffered click is true if a legit click was sent
        # (denoted by the up time stamp being equal to the click time stamp)
        @buffered_click = MousePoint.new @x, @y
        @buffered_click.created_at = Kernel.tick_count
        @buffered_click.global_created_at = Kernel.global_tick_count
        @buffered_click
      elsif @previous_click && @up && held_duration < buffered_duration_threshold
        # if the up time stamp is less than 12 frames, then
        # consider it a click if the distance between the current position and the
        # previous position is less than 10 pixels
        # if it's greater than 10 pixels then don't consider it a click
        if Geometry.distance(self, @previous_click) < buffered_distance_threshold
          @buffered_click = MousePoint.new @x, @y
          @buffered_click.created_at = Kernel.tick_count
          @buffered_click.global_created_at = Kernel.global_tick_count
          @buffered_click
        else
          @buffered_click = nil
        end
      else
        # buffered click is considered false if the held duration is
        # greater than 12 frames
        @buffered_click = nil
      end

      @buffered_click
    end

    def buffered_duration_threshold
      12
    end

    def buffered_distance_threshold
      10
    end

    def held_duration
      return 0 if !held
      return 0 if !held_at
      return held_at.elapsed_time if held
      return 0 if !up
      return @up_at - @click_at if up
    end

    def buffered_held
      # buffered held returns true if the held duration is greater than 12
      # or if the distance between the previous mouse location and the current
      # mouse location is greater than 10
      if held && held_duration > 1
        if (Geometry.distance(self, @previous_click) >= 10 || held_duration >= buffered_duration_threshold)
          @buffered_held ||= MousePoint.new @x, @y
          @buffered_held.x = @x
          @buffered_held.y = @y
          @buffered_held.created_at ||= Kernel.tick_count
          @buffered_held.global_created_at ||= Kernel.global_tick_count
          @buffered_held
        else
          @buffered_held = nil
        end
      else
        @buffered_held = nil
      end

      @buffered_held
    end

    def clear
      @click = nil
      @up    = nil
      @wheel = nil
      @relative_x = 0
      @relative_y = 0
    end
  end
end
