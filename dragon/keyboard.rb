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
    attr :last_directional_vector_wasd
    attr :last_directional_vector_arrow

    attr :active

    def initialize
      @key_up      = KeyboardKeys.new
      @key_held    = KeyboardKeys.new
      @key_down    = KeyboardKeys.new
      @key_repeat  = KeyboardKeys.new
      @has_focus   = true
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

    def left_wasd
      a_scancode
    end

    def right
      @key_down.right || @key_held.right || d_scancode || nil
    end

    def right_arrow
      @key_down.right || @key_held.right || nil
    end

    def right_wasd
      d_scancode
    end

    def up
      @key_down.up || @key_held.up || w_scancode || nil
    end

    def up_arrow
      @key_down.up || @key_held.up || nil
    end

    def up_wasd
      w_scancode
    end

    def down_wasd
      s_scancode
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

    def __directional_vector__ l, r, u, d, last_lr, last_ud
      # if both left right keys are held, then return last left right key
      lr = if l && r && last_lr != 0
             last_lr
           elsif l
             -1
           elsif r
             1
           else
             0
           end

      # if both up down keys are held, then return last up down key
      ud = if u && d && last_ud != 0
             last_ud
           elsif u
             1
           elsif d
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

    def directional_vector_arrow
      __directional_vector__ self.left_arrow,
                             self.right_arrow,
                             self.up_arrow,
                             self.down_arrow,
                             self.last_left_right_arrow,
                             self.last_up_down_arrow
    end

    def directional_vector_wasd
      __directional_vector__ self.left_wasd,
                             self.right_wasd,
                             self.up_wasd,
                             self.down_wasd,
                             self.last_left_right_wasd,
                             self.last_up_down_wasd
    end

    def directional_vector
      __directional_vector__ self.left,
                             self.right,
                             self.up,
                             self.down,
                             self.last_left_right,
                             self.last_up_down
    end

    def last_up_down_arrow
      last_directional_vector_arrow&.y&.sign || 0
    end

    def last_up_down_wasd
      last_directional_vector_wasd&.y&.sign || 0
    end

    def up_down_arrow
      directional_vector_arrow&.y&.sign || 0
    end

    def up_down_wasd
      directional_vector_wasd&.y&.sign || 0
    end

    def left_right_arrow
      directional_vector_arrow&.x&.sign || 0
    end

    def left_right_wasd
      directional_vector_wasd&.x&.sign || 0
    end

    def last_left_right_arrow
      last_directional_vector_arrow&.x&.sign || 0
    end

    def last_left_right_wasd
      last_directional_vector_wasd&.x&.sign || 0
    end

    def has_focus
      return true if $gtk.platform?(:mobile)
      @has_focus
    end
  end
end
