# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# console_font_style.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - Kevin Fischer: https://github.com/kfischer-okarin

module GTK
  class Console
    class FontStyle
      attr_reader :font, :size_enum, :line_height

      def initialize(font:, size_enum:, line_height:)
        @font = font
        @size_enum = size_enum
        @line_height = line_height
      end

      def letter_size
        w, h = $gtk.calcstringbox 'W', size_enum, font
        @letter_size ||= { w: w, h: h }
      end

      def line_height_px
        @line_height_px ||= letter_size.h * line_height
      end

      def label(x:, y:, text:, color:, alignment_enum: 0)
        {
          x: x,
          y: y.shift_up(line_height_px),  # !!! FIXME: remove .shift_up(line_height_px) when we fix coordinate origin on labels.
          text: text,
          font: font,
          size_enum: size_enum,
          alignment_enum: alignment_enum,
          **color.to_h,
        }.label!
      end
    end
  end
end
