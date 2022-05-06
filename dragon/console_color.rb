# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# console_color.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - Kevin Fischer: https://github.com/kfischer-okarin

module GTK
  class Console
    class Color
      def initialize(color)
        @color = color
        @color << 255 if @color.size == 3
      end

      def mult_alpha(alpha_modifier)
        Color.new [@color[0], @color[1], @color[2], (@color[3].to_f * alpha_modifier).to_i]
      end

      # Support splat operator
      def to_a
        @color
      end

      def to_s
        "GTK::Console::Color #{to_h}"
      end

      def to_h
        { r: @color[0], g: @color[1], b: @color[2], a: @color[3] }
      end
    end
  end
end
