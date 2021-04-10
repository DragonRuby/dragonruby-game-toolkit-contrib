# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# controller/keys.rb has been released under MIT (*only this file*).

module GTK
  class Controller
    class Keys
      include Serialize

      LABELS = [
        :up, :down, :left, :right,
        :a, :b, :x, :y,
        :l1, :r1,
        :l2, :r2,
        :l3, :r3,
        :start, :select,
        :directional_up, :directional_down, :directional_left, :directional_right
      ].freeze

      LABELS.each do |label|
        attr label
      end

      # Activate a key.
      #
      # @return [void]
      def activate key
        instance_variable_set("@#{key}", Kernel.tick_count + 1)
      end

      # Deactivate a key.
      #
      # @return [void]
      def deactivate key
        instance_variable_set("@#{key}", nil)
      end

      # Clear all key inputs.
      #
      # @return [void]
      def clear
        LABELS.each { |label| deactivate(label) }
      end

      def truthy_keys
        LABELS.select { |label| send(label) }
      end
    end
  end
end
