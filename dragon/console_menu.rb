# Copyright 2019 DragonRuby LLC
# MIT License
# console_menu.rb has been released under MIT (*only this file*).

module GTK
  class Console
    class Menu
      def initialize console
        @console = console
      end

      def record_clicked
        $recording.start 100
      end

      def replay_clicked
        $replay.start 'replay.txt'
      end

      def reset_clicked
        $gtk.reset
      end

      def scroll_up_clicked
        @console.scroll_up_half
      end

      def scroll_down_clicked
        @console.scroll_down_half
      end

      def close_clicked
        @console.hide
      end

      def tick args
        return unless @console.visible?

        # defaults
        @buttons = [
          (button id: :record,      row: 0, col: 15, text: "record",      method: :record_clicked),
          (button id: :replay,      row: 0, col: 16, text: "replay",      method: :replay_clicked),
          (button id: :reset,       row: 0, col: 17, text: "reset",       method: :reset_clicked),
          (button id: :scroll_up,   row: 0, col: 18, text: "scroll up",   method: :scroll_up_clicked),
          (button id: :scroll_down, row: 0, col: 19, text: "scroll down", method: :scroll_down_clicked),
          (button id: :close,       row: 0, col: 20, text: "close",       method: :close_clicked),
        ]

        # render
        args.outputs.reserved << @buttons.map { |b| b[:primitives] }

        # inputs
        if args.inputs.mouse.click
          clicked = @buttons.find { |b| args.inputs.mouse.inside_rect? b[:rect] }
          if clicked
            send clicked[:method]
          end
        end
      end

      def rect_for_layout row, col
        col_width  = 50
        row_height = 50
        col_margin = 5
        row_margin = 5
        x = (col_margin + (col * col_width)  + (col * col_margin))
        y = (row_margin + (row * row_height) + (row * row_margin) + row_height).from_top
        { x: x, y: y, w: row_height, h: col_width }
      end

      def button args
        id, row, col, text, method = args[:id], args[:row], args[:col], args[:text], args[:method]

        font_height = @console.font_style.line_height_px.half
        {
          id: id,
          rect: (rect_for_layout row, col),
          method: method
        }.let do |entity|
          primitives = []
          primitives << entity[:rect].merge(a: 80).solid
          primitives << entity[:rect].merge(r: 255, g: 255, b: 255).border
          primitives << text.wrapped_lines(5)
                            .map_with_index do |l, i|
                              [
                                entity[:rect][:x] + entity[:rect][:w].half,
                                entity[:rect][:y] + entity[:rect][:h].half + font_height - (i * (font_height + 2)),
                                l, -3, 1, 255, 255, 255
                              ]
                            end.labels

          entity.merge(primitives: primitives)
        end
      end

      def serialize
        {
          not_supported: "#{self}"
        }
      end
    end
  end
end
