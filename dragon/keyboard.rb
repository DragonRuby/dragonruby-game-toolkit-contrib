# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# keyboard.rb has been released under MIT (*only this file*).
module GTK
  class Keyboard
    attr_accessor :key_up
    attr_accessor :key_held
    attr_accessor :key_down
    attr_accessor :key_repeat
    attr_accessor :has_focus
    attr :last_directional_vector

    attr :active

    def initialize
      @key_up      = KeyboardKeys.new
      @key_held    = KeyboardKeys.new
      @key_down    = KeyboardKeys.new
      @key_repeat  = KeyboardKeys.new
      @has_focus   = false
    end

    def key_down? key
      @key_down.send(key)
    end

    def key_up? key
      @key_up.send(key)
    end

    def key_held? key
      @key_held.send(key)
    end

    def key_repeat? key
      @key_repeat.send(key)
    end

    def key_down_or_held? key
      key_down?(key) || key_held?(key)
    end

    def p
      @key_down.p || @key_held.p
    end

    def left
      @key_down.left || @key_held.left || a_scancode || nil
    end

    def left_arrow
      @key_down.left || @key_held.left || nil
    end

    def right
      @key_down.right || @key_held.right || d_scancode || nil
    end

    def right_arrow
      @key_down.right || @key_held.right || nil
    end

    def up
      @key_down.up || @key_held.up || w_scancode || nil
    end

    def up_arrow
      @key_down.up || @key_held.up || nil
    end

    def down
      @key_down.down || @key_held.down || s_scancode || nil
    end

    def down_arrow
      @key_down.down || @key_held.down || nil
    end

    def clear
      @key_up.clear
      @key_held.clear
      @key_down.clear
      @active = nil
    end

    def serialize
      {
        key_up: @key_up.serialize,
        key_held: @key_held.serialize,
        key_down: @key_down.serialize,
        has_focus: @has_focus
      }
    end

    alias_method :inspect, :serialize

    # @return [String]
    def to_s
      serialize.to_s
    end

    def to_h
      serialize
    end

    def key
      {
        down: @key_down.truthy_keys,
        held: @key_held.truthy_keys,
        down_or_held: (@key_down.truthy_keys + @key_held.truthy_keys).uniq,
        up: @key_up.truthy_keys,
        repeat: @key_repeat.truthy_keys
      }
    end

    alias_method :keys, :key

    def left_right
      directional_vector&.x&.sign || 0
    end

    def last_left_right
      last_directional_vector&.x&.sign || 0
    end

    def up_down
      directional_vector&.y&.sign || 0
    end

    def last_up_down
      last_directional_vector&.y&.sign || 0
    end

    def directional_vector
      # if both left right keys are held, then return last left right key
      lr = if self.left && self.right && last_left_right != 0
             last_left_right
           elsif self.left
             -1
           elsif self.right
             1
           else
             0
           end

      # if both up down keys are held, then return last up down key
      ud = if self.up && self.down && last_up_down != 0
             last_up_down
           elsif self.up
             1
           elsif self.down
             -1
           else
             0
           end

      if lr == 0 && ud == 0
        return nil
      elsif lr.abs == ud.abs
        return { x: 45.vector_x * lr.sign, y: 45.vector_y * ud.sign }
      else
        return { x: lr, y: ud }
      end
    end

    def directional_angle
      return nil unless directional_vector

      Math.atan2(up_down, left_right).to_degrees
    end

    def method_missing m, *args
      if m.to_s.start_with?("ctrl_") || m.to_s.start_with?("control_")
        other_key = m.to_s.split("_").last
        define_singleton_method(m) do
          return self.key_down.send(other_key.to_sym) && self.control
        end

        return send(m)
      elsif m.to_s.start_with?("shift_")
        other_key = m.to_s.split("_").last
        define_singleton_method(m) do
          return self.key_down.send(other_key.to_sym) && self.shift
        end

        return send(m)
      elsif m.to_s.start_with?("alt_")
        other_key = m.to_s.split("_").last
        define_singleton_method(m) do
          return self.key_down.send(other_key.to_sym) && self.alt
        end

        return send(m)
      elsif m.to_s.start_with?("meta_")
        other_key = m.to_s.split("_").last
        define_singleton_method(m) do
          return self.key_down.send(other_key.to_sym) && self.meta
        end

        return send(m)
      else
        define_singleton_method(m) do
          self.key_down.send(m) || self.key_held.send(m)
        end

        return send(m)
      end
    end
  end
end
