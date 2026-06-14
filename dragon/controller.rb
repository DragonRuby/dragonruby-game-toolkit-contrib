# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# controller.rb has been released under MIT (*only this file*).

module GTK
  class Controller
    attr :name
    attr :key_down
    attr :key_up
    attr :key_held

    attr :left_analog_x_raw,
         :left_analog_y_raw,
         :left_analog_x_perc,
         :left_analog_y_perc,
         :right_analog_x_raw,
         :right_analog_y_raw,
         :right_analog_x_perc,
         :right_analog_y_perc,
         :active,
         :active_at,
         :active_global_at,
         :analog_dead_zone

    attr :connected

    attr :last_directional_vector

    def initialize
      @key_down = Controller::Keys.new
      @key_up   = Controller::Keys.new
      @key_held = Controller::Keys.new
      @left_analog_x_raw = 0
      @left_analog_y_raw = 0
      @left_analog_x_perc = 0
      @left_analog_y_perc = 0
      @right_analog_x_raw = 0
      @right_analog_y_raw = 0
      @right_analog_x_perc = 0
      @right_analog_y_perc = 0
      @connected = false
      @analog_dead_zone = 3600
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

    def key_down_or_held? key
      key_down?(key) || key_held?(key)
    end

    def to_h
      serialize
    end

    def to_hash
      serialize
    end

    def serialize
      {
        left_analog_x_raw:     @left_analog_x_raw,
        left_analog_y_raw:     @left_analog_y_raw,
        left_analog_x_perc:    @left_analog_x_perc,
        left_analog_y_perc:    @left_analog_y_perc,
        right_analog_x_raw:    @right_analog_x_raw,
        right_analog_y_raw:    @right_analog_y_raw,
        right_analog_x_perc:   @right_analog_x_perc,
        right_analog_y_perc:   @right_analog_y_perc,
        active:                @active,
        key_down:              @key_down.serialize,
        key_held:              @key_held.serialize,
        key_up:                @key_up.serialize,
        left_analog_angle:     left_analog_angle,
        right_analog_angle:    right_analog_angle,
        left_analog_active:    left_analog_active?,
        right_analog_active:    right_analog_active?
      }
    end

    # Clear all current key presses.
    #
    # @return [void]
    def clear
      @key_down.clear
      @key_up.clear
      @key_held.clear
      @active = nil
    end

    def up
      @key_down.up || @key_held.up
    end

    def up_dpad
      @key_down.up_dpad || @key_held.up_dpad
    end

    def down
      @key_down.down || @key_held.down
    end

    def down_dpad
      @key_down.down_dpad || @key_held.down_dpad
    end

    def left
      @key_down.left || @key_held.left
    end

    def left_dpad
      @key_down.left_dpad || @key_held.left_dpad
    end

    def right
      @key_down.right || @key_held.right
    end

    def right_dpad
      @key_down.right_dpad || @key_held.right_dpad
    end

    # Activates a key into the down position.
    #
    # @param key [Symbol] The key to press down.
    #
    # @return [void]
    def activate_down(key)
      key_down.activate(key)
      key_held.deactivate(key)
      key_up.deactivate(key)
    end

    # Activates a key into the held down position.
    #
    # @param key [Symbol] The key to hold down.
    #
    # @return [void]
    def activate_held(key)
      key_down.deactivate(key)
      key_held.activate(key) unless key_held.send(key)
      key_up.deactivate(key)
    end


    # Activates a key release into the up position.
    #
    # @param key [Symbol] The key release up.
    #
    # @return [void]
    def activate_up(key)
      key_down.deactivate(key)
      key_held.deactivate(key)
      key_up.activate(key)
    end

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

    def directional_vector_left
      directional_vector_left_analog || directional_vector_dpad
    end

    def directional_vector_right
      directional_vector_right_analog || directional_vector_buttons
    end

    def directional_vector_buttons
      lr = if self.w
             -1
           elsif self.e
             1
           else
             0
           end

      ud = if self.s
             -1
           elsif self.n
             1
           else
             0
           end

      Geometry.vec2_normalize(x: lr, y: ud)
    end

    def directional_vector
      __directional_vector__ self.left,
                             self.right,
                             self.up,
                             self.down,
                             self.last_left_right,
                             self.last_up_down
    end

    def directional_vector_dpad
      __directional_vector__ self.left_dpad,
                             self.right_dpad,
                             self.up_dpad,
                             self.down_dpad,
                             0,
                             0
    end

    def directional_vector_left_analog
      Geometry.vec2_normalize(x: left_analog_x_perc, y: left_analog_y_perc)
    end

    def directional_vector_left_analog_cardinal
      return nil if left_analog_x_raw == 0 && left_analog_y_raw == 0

      angle = Math.atan2(left_analog_y_perc, left_analog_x_perc).to_degrees

      Geometry.angle_cardinal_vec2 angle
    end

    def directional_vector_right_analog
      Geometry.vec2_normalize(x: right_analog_x_perc, y: right_analog_y_perc)
    end

    def directional_vector_right_analog_cardinal
      return nil if right_analog_x_raw == 0 && right_analog_y_raw == 0

      angle = Math.atan2(right_analog_y_perc, right_analog_x_perc).to_degrees

      Geometry.angle_cardinal_vec2 angle
    end

    def directional_angle
      return nil unless directional_vector

      Math.atan2(up_down, left_right).to_degrees
    end


    def method_missing m, *args
      define_singleton_method(m) do
        self.key_down.send(m) || self.key_held.send(m)
      end

      return send(m)
    end

    def inspect
      "#{serialize}"
    end

    def to_s
      "#{serialize}"
    end

    def left_analog_angle
      return nil if left_analog_x_raw == 0 && left_analog_y_raw == 0
      Math.atan2(left_analog_y_perc, left_analog_x_perc).to_degrees % 360
    end

    def right_analog_angle
      return nil if right_analog_x_raw == 0 && right_analog_y_raw == 0
      Math.atan2(right_analog_y_perc, right_analog_x_perc).to_degrees % 360
    end

    def left_analog_active? threshold_raw: nil, threshold_perc: nil
      threshold_value = threshold_raw || threshold_perc || 0
      threshold_to_use = if threshold_raw
                           :raw
                         elsif threshold_perc
                           :perc
                         else
                           :raw
                         end
      if threshold_to_use == :raw
        if left_analog_x_raw == 0 && left_analog_y_raw == 0
          return false
        else
          return true
        end
      else
        if left_analog_x_perc.abs < threshold_value && left_analog_y_perc.abs < threshold_value
          return false
        else
          return true
        end
      end
    end

    def name
      @name || ""
    end

    def right_analog_active? threshold_raw: nil, threshold_perc: nil
      threshold_value = threshold_raw || threshold_perc || 0
      threshold_to_use = if threshold_raw
                           :raw
                         elsif threshold_perc
                           :perc
                         else
                           :raw
                         end
      if threshold_to_use == :raw
        if right_analog_x_raw == 0 && right_analog_y_raw == 0
          return false
        else
          return true
        end
      else
        if right_analog_x_perc.abs < threshold_value && right_analog_y_perc.abs < threshold_value
          return false
        else
          return true
        end
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

    # VR (needs to be reworked if/when Steam Frame comes out)
    def left_hand
      @left_hand  ||= {
        position: { x: 0, y: 0, z: 0 },
        orientation: { x: 0, y: 0, z: 0 }
      }
    end

    def right_hand
      @right_hand ||= {
        position: { x: 0, y: 0, z: 0 },
        orientation: { x: 0, y: 0, z: 0 }
      }
    end
  end
end
