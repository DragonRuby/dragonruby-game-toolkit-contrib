# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# directional_input_helper_methods.rb has been released under MIT (*only this file*).

module GTK
  # This is a module that contains normalization of behavior related to `up`|`down`|`left`|`right` on keyboards and controllers.
  module DirectionalInputHelperMethods
    def self.included klass
      key_state_methods = [:key_held, :key_down]
      directional_methods = [:up, :down, :left, :right]
      method_results = (directional_methods + key_state_methods).map {|m| [m, klass.instance_methods.include?(m)] }

      error_message = <<-S
* ERROR
The GTK::DirectionalKeys module should only be included in objects that respond to the following api hierarchy:

- (#{ directional_methods.join("|") })
- key_held.(#{ directional_methods.join("|") })
- key_down.(#{ directional_methods.join("|") })

#{klass} does not respond to all of these methods (here is the diagnostics):
#{method_results.map {|m, r| "- #{m}: #{r}"}.join("\n")}

Please implement the methods that returned false inthe list above.
S
      unless method_results.map {|m, result| result}.all?
        raise error_message
      end
    end

    # Returns a signal indicating left (`-1`), right (`1`), or neither ('0').
    #
    # @return [Integer]
    def left_right
      return -1 if self.left
      return  1 if self.right
      return  0
    end

    # Returns a signal indicating up (`1`), down (`-1`), or neither ('0').
    #
    # @return [Integer]
    def up_down
      return  1 if self.up
      return -1 if self.down
      return  0
    end

    # Returns a normal vector (in the form of a Hash with x, y keys). If no directionals are held/down, the function returns nil.
    #
    # The possible results are:
    #
    # - ~nil~ which denotes that no directional input exists.
    # - ~[   0,    1]~ which denotes that only up is being held/pressed.
    # - ~[   0,   -1]~ which denotes that only down is being held/pressed.
    # - ~[-0.707,  0.707]~ which denotes that right and up are being pressed/held.
    # - ~[-0.707, -0.707]~ which denotes that left and down are being pressed/held.
    def directional_vector
      lr, ud = self.left_right, self.up_down

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
  end
end
