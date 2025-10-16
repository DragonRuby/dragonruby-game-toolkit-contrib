# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# inputs.rb has been released under MIT (*only this file*).

module GTK
  class Inputs
    attr_reader :controllers
    attr_reader :keyboard
    attr_reader :mouse
    attr_accessor :http_requests
    attr_reader :touch
    attr_accessor :multi_touch_finger_up_at
    attr_accessor :finger_one, :finger_two
    attr_accessor :finger_left, :finger_right
    attr_accessor :pinch_zoom
    attr_accessor :text, :history
    attr_accessor :headset
    attr :last_active
    attr :last_active_at
    attr :last_active_global_at
    attr :touch_enabled
    attr :locale, :locale_raw
    attr_reader :application_control
    attr :a11y
    attr :mouse_touch

    def initialize
      @controllers = [Controller.new, Controller.new, Controller.new, Controller.new]
      @keyboard = Keyboard.new
      @mouse = Mouse.new
      @pinch_zoom = 0
      @touch = {}
      @mouse_touch = { x: -1000, y: -1000, tracking_speed: 1.0 }
      @finger_one = nil
      @finger_two = nil
      @text = []
      @http_requests = []
      @a11y = {}
      @keyboard_or_controller_key_down = KeyboardOrControllerKeyDown.new self
      @keyboard_or_controller_key_up = KeyboardOrControllerKeyUp.new self
      @keyboard_or_controller_key_held = KeyboardOrControllerKeyHeld.new self
      @headset = {
        position: { x: 0, y: 0, z: 0 },
        orientation: { x: 0, y: 0, z: 0 }
      }
    end

    def key_down
      @keyboard_or_controller_key_down
    end

    def key_held
      @keyboard_or_controller_key_held
    end

    def key_up
      @keyboard_or_controller_key_up
    end

    def touch_center
      log_once_important :inputs_touch_center, "* WARNING: ~Inputs#touch_center~ has been renamed to ~Inputs#mouse_touch~."
      @mouse_touch
    end

    def touch_center=(val)
      log_once_important :inputs_touch_center, "* WARNING: ~Inputs#touch_center~ has been renamed to ~Inputs#mouse_touch~."
      @mouse_touch = val
    end

    def up
      keyboard.up || (controller_one && controller_one.up)
    end

    alias_method :up_with_wasd, :up

    def down
      keyboard.down || (controller_one && controller_one.down)
    end

    alias_method :down_with_wasd, :down

    def left
      keyboard.left || (controller_one && controller_one.left)
    end

    alias_method :left_with_wasd, :left

    def right
      keyboard.right || (controller_one && controller_one.right)
    end

    alias_method :right_with_wasd, :right

    def directional_vector
      keyboard.directional_vector ||
        (controller_one && controller_one.directional_vector)
    end

    def last_directional_vector
      keyboard.last_directional_vector ||
        (controller_one && controller_one.last_directional_vector)
    end

    def directional_angle
      keyboard.directional_angle || (controller_one && controller_one.directional_angle)
    end

    def left_right
      directional_vector&.x&.sign || 0
    end

    def last_left_right
      keyboard&.last_directional_vector&.x&.sign || controller_one&.last_directional_vector&.x&.sign || 0
    end

    alias_method :left_right_with_wasd, :left_right

    def left_right_arrow
      return -1 if keyboard.left_arrow || (controller_one && controller_one.directional_left)
      return  1 if keyboard.right_arrow || (controller_one && controller_one.directional_right)
      return  0
    end

    alias_method :left_right_directional, :left_right_arrow

    def left_right_perc
      if controller_one && controller_one.left_analog_x_perc != 0
        controller_one.left_analog_x_perc
      else
        left_right
      end
    end

    alias_method :left_right_perc_with_wasd, :left_right_perc

    def left_right_directional_perc
      if controller_one && controller_one.left_analog_x_perc != 0
        controller_one.left_analog_x_perc
      else
        left_right_directional
      end
    end

    def up_down
      directional_vector&.y&.sign || 0
    end

    def last_up_down
      keyboard&.last_directional_vector&.y&.sign || controller_one&.last_directional_vector&.y&.sign || 0
    end

    alias_method :up_down_with_wasd, :up_down

    def up_down_arrow
      return  1 if keyboard.up_arrow || (controller_one && controller_one.directional_up)
      return -1 if keyboard.down_arrow || (controller_one && controller_one.directional_down)
      return  0
    end

    alias_method :up_down_directional, :up_down_arrow

    def up_down_perc
      if controller_one && controller_one.left_analog_y_perc != 0
        controller_one.left_analog_y_perc
      else
        up_down
      end
    end

    def up_down_directional_perc
      if controller_one && controller_one.left_analog_y_perc != 0
        controller_one.left_analog_y_perc
      else
        up_down_directional
      end
    end

    def click
      return nil unless @mouse.click
      return @mouse.click.point
    end

    def controller_one
      @controllers[0]
    end

    def controller_two
      @controllers[1]
    end

    def controller_three
      @controllers[2]
    end

    def controller_four
      @controllers[3]
    end

    def clear
      @mouse.clear
      @keyboard.clear
      @controllers.each(&:clear)
      @touch.clear
      @http_requests.clear
      @application_control = {
        key_down: {},
        key_up: {}
      }
      @finger_one = nil
      @finger_two = nil
      @pinch_zoom = 0
    end

    def serialize
      {
        controller_one: controller_one.serialize,
        controller_two: controller_two.serialize,
        controller_three: controller_three.serialize,
        controller_four: controller_four.serialize,
        keyboard: keyboard.serialize,
        mouse: mouse.serialize,
        text: text.serialize,
        application_control: application_control.serialize
      }
    end

    def touch_enabled?
      @touch_enabled
    end

    class KeyboardOrControllerKeyDown
      def initialize(inputs) = @inputs = inputs
      def up    = @inputs.keyboard.key_down.up    || @inputs.keyboard.key_down.w_scancode  || @inputs.controller_one.key_down.up
      def left  = @inputs.keyboard.key_down.left  || @inputs.keyboard.key_down.a_scancode  || @inputs.controller_one.key_down.left
      def down  = @inputs.keyboard.key_down.down  || @inputs.keyboard.key_down.s_scancode  || @inputs.controller_one.key_down.down
      def right = @inputs.keyboard.key_down.right || @inputs.keyboard.key_down.d_scancode  || @inputs.controller_one.key_down.right
      def directional_vector = @inputs.keyboard.key_down.directional_vector || @inputs.controller_one.key_down.directional_vector
      def last_directional_vector = @inputs.keyboard.key_down.last_directional_vector || @inputs.controller_one.key_down.last_directional_vector
      def directional_angle = @inputs.keyboard.key_down.directional_angle || @inputs.controller_one.key_down.directional_angle
      def left_right = @inputs.keyboard.key_down.directional_vector&.x&.sign || @inputs.controller_one.key_down.directional_vector&.x&.sign || 0
      def last_left_right = @inputs.keyboard.key_down.last_directional_vector&.x&.sign || @inputs.controller_one.key_down.last_directional_vector&.x&.sign || 0
      def up_down = @inputs.keyboard.key_down.directional_vector&.y&.sign || @inputs.controller_one.key_down.directional_vector&.y&.sign || 0
      def last_up_down = @inputs.keyboard.key_down.last_directional_vector&.y&.sign || @inputs.controller_one.key_down.last_directional_vector&.y&.sign || 0
    end

    class KeyboardOrControllerKeyUp
      def initialize(inputs) = @inputs = inputs
      def up    = @inputs.keyboard.key_up.up    || @inputs.keyboard.key_up.w_scancode || @inputs.controller_one.key_up.up
      def left  = @inputs.keyboard.key_up.left  || @inputs.keyboard.key_up.a_scancode || @inputs.controller_one.key_up.left
      def down  = @inputs.keyboard.key_up.down  || @inputs.keyboard.key_up.s_scancode || @inputs.controller_one.key_up.down
      def right = @inputs.keyboard.key_up.right || @inputs.keyboard.key_up.d_scancode || @inputs.controller_one.key_up.right
      def directional_vector = @inputs.keyboard.key_up.directional_vector || @inputs.controller_one.key_up.directional_vector
      def last_directional_vector = @inputs.keyboard.key_up.last_directional_vector || @inputs.controller_one.key_up.last_directional_vector
      def directional_angle = @inputs.keyboard.key_up.directional_angle || @inputs.controller_one.key_up.directional_angle
      def left_right = @inputs.keyboard.key_up.directional_vector&.x&.sign || @inputs.controller_one.key_up.directional_vector&.x&.sign || 0
      def last_left_right = @inputs.keyboard.key_up.last_directional_vector&.x&.sign || @inputs.controller_one.key_up.last_directional_vector&.x&.sign || 0
      def up_down = @inputs.keyboard.key_up.directional_vector&.y&.sign || @inputs.controller_one.key_up.directional_vector&.y&.sign || 0
      def last_up_down = @inputs.keyboard.key_up.last_directional_vector&.y&.sign || @inputs.controller_one.key_up.last_directional_vector&.y&.sign || 0
    end

    class KeyboardOrControllerKeyHeld
      def initialize(inputs) = @inputs = inputs
      def up    = @inputs.keyboard.key_held.up    || @inputs.keyboard.key_held.w_scancode || @inputs.controller_one.key_held.up
      def left  = @inputs.keyboard.key_held.left  || @inputs.keyboard.key_held.a_scancode || @inputs.controller_one.key_held.left
      def down  = @inputs.keyboard.key_held.down  || @inputs.keyboard.key_held.s_scancode || @inputs.controller_one.key_held.down
      def right = @inputs.keyboard.key_held.right || @inputs.keyboard.key_held.d_scancode || @inputs.controller_one.key_held.right
      def directional_vector = @inputs.keyboard.key_held.directional_vector || @inputs.controller_one.key_held.directional_vector
      def last_directional_vector = @inputs.keyboard.key_held.last_directional_vector || @inputs.controller_one.key_held.last_directional_vector
      def directional_angle = @inputs.keyboard.key_held.directional_angle || @inputs.controller_one.key_held.directional_angle
      def left_right = @inputs.keyboard.key_held.directional_vector&.x&.sign || @inputs.controller_one.key_held.directional_vector&.x&.sign || 0
      def last_left_right = @inputs.keyboard.key_held.last_directional_vector&.x&.sign || @inputs.controller_one.key_held.last_directional_vector&.x&.sign || 0
      def up_down = @inputs.keyboard.key_held.directional_vector&.y&.sign || @inputs.controller_one.key_held.directional_vector&.y&.sign || 0
      def last_up_down = @inputs.keyboard.key_held.last_directional_vector&.y&.sign || @inputs.controller_one.key_held.last_directional_vector&.y&.sign || 0
    end
  end
end
