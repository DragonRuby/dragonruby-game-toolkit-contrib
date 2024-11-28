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
    attr :touch_center

    def initialize
      @controllers = [Controller.new, Controller.new, Controller.new, Controller.new]
      @keyboard = Keyboard.new
      @mouse = Mouse.new
      @pinch_zoom = 0
      @touch = {}
      @touch_center = { x: -1000, y: -1000 }
      @finger_one = nil
      @finger_two = nil
      @text = []
      @http_requests = []
      @a11y = {}
      @headset = {
        position: { x: 0, y: 0, z: 0 },
        orientation: { x: 0, y: 0, z: 0 }
      }
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

    def directional_angle
      keyboard.directional_angle || (controller_one && controller_one.directional_angle)
    end

    def left_right
      return -1 if self.left
      return  1 if self.right
      return  0
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
      return  1 if self.up
      return -1 if self.down
      return  0
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
  end
end
