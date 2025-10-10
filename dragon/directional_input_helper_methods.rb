# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# directional_input_helper_methods.rb has been released under MIT (*only this file*).

module GTK
  # This is a module that contains normalization of behavior related to `up`|`down`|`left`|`right` on keyboards and controllers.
  # NOTE: module is no longer used in Keyboard or Controller
  #       this is kept around for backwards compatibility
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

    def left_right
      directional_vector&.x&.sign || 0
    end

    def up_down
      directional_vector&.y&.sign || 0
    end

    def directional_vector
      lr = if self.left
             -1
           elsif self.right
             1
           else
             0
           end

      ud = if self.up
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
  end
end
