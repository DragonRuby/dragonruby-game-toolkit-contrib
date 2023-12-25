# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# controller.rb has been released under MIT (*only this file*).

module GTK
  class Controller
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
         :active

    attr :connected

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
    end

    def serialize
      {
        key_down: @key_down.serialize,
        key_held: @key_held.serialize,
        key_up:   @key_up.serialize
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
      @key_up.up || @key_held.up
    end

    def down
      @key_up.down || @key_held.down
    end

    def left
      @key_up.left || @key_held.left
    end

    def right
      @key_up.right || @key_held.right
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

    include DirectionalInputHelperMethods

    def method_missing m, *args
      define_singleton_method(m) do
        self.key_down.send(m) || self.key_held.send(m)
      end

      return send(m)
    end
  end
end
