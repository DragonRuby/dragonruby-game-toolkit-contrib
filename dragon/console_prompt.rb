# Copyright 2019 DragonRuby LLC
# MIT License
# console_prompt.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - Kevin Fischer: https://github.com/kfischer-okarin

module GTK
  class Console
    class Prompt
      attr_accessor :current_input_str, :font_style, :console_text_width, :last_input_str, :last_input_str_changed

      def initialize(font_style:, text_color:, console_text_width:)
        @prompt = '-> '
        @current_input_str = ''
        @font_style = font_style
        @text_color = text_color
        @cursor_color = Color.new [187, 21, 6]
        @console_text_width = console_text_width

        @cursor_position = 0

        @last_autocomplete_prefix = nil
        @next_candidate_index = 0
      end

      def current_input_str=(str)
        @current_input_str = str
        @cursor_position = str.length
      end

      def <<(str)
        @current_input_str = @current_input_str[0...@cursor_position] + str + @current_input_str[@cursor_position..-1]
        @cursor_position += str.length
        @current_input_changed_at = Kernel.global_tick_count
        reset_autocomplete
      end

      def backspace
        return if current_input_str.length.zero? || @cursor_position.zero?

        @current_input_str = @current_input_str[0...(@cursor_position - 1)] + @current_input_str[@cursor_position..-1]
        @cursor_position -= 1
        reset_autocomplete
      end

      def move_cursor_left
        @cursor_position -= 1 if @cursor_position > 0
      end

      def move_cursor_right
        @cursor_position += 1 if @cursor_position < current_input_str.length
      end

      def clear
        @current_input_str = ''
        @cursor_position = 0
        reset_autocomplete
      end

      def autocomplete
        if !@last_autocomplete_prefix
          @last_autocomplete_prefix = calc_autocomplete_prefix

          puts "* AUTOCOMPLETE CANDIDATES: #{current_input_str}.."
          pretty_print_strings_as_table method_candidates(@last_autocomplete_prefix)
        else
          candidates = method_candidates(@last_autocomplete_prefix)
          return if candidates.empty?

          candidate = candidates[@next_candidate_index]
          candidate = candidate[0..-2] + " = " if candidate.end_with? '='
          @next_candidate_index += 1
          @next_candidate_index = 0 if @next_candidate_index >= candidates.length
          self.current_input_str = display_autocomplete_candidate(candidate)
        end
      end

      def pretty_print_strings_as_table items
        if items.length == 0
          puts <<-S.strip
+--------+
| (none) |
+--------+
S
        else
          # figure out the largest string
          string_width = items.sort_by { |c| -c.to_s.length }.first

          # add spacing to each side of the string which represents the cell width
          cell_width = string_width.length + 2

          # add spacing to each side of the cell to represent the column width
          column_width = cell_width + 2

          # determine the max number of columns that can fit on the screen
          columns = @console_text_width.idiv column_width
          columns = items.length if items.length < columns

          # partition the original list of items into a string to be printed
          items.each_slice(columns).each_with_index do |cells, i|
            pretty_print_row_seperator string_width, cell_width, column_width, columns
            pretty_print_row cells, string_width, cell_width, column_width, columns
          end

          pretty_print_row_seperator string_width, cell_width, column_width, columns
        end
      end

      def pretty_print_row cells, string_width, cell_width, column_width, columns
        # if the number of cells doesn't match the number of columns, then pad the array with empty values
        cells += (columns - cells.length).map { "" }

        # right align each cell value
        formated_row = "|" + cells.map do |c|
          "#{" " * (string_width.length - c.length) } #{c} |"
        end.join

        # remove seperators between empty values
        formated_row = formated_row.gsub("  |  ", "     ")

        puts formated_row
      end

      def pretty_print_row_seperator string_width, cell_width, column_width, columns
        # this is a joint: +--------
        column_joint = "+#{"-" * cell_width}"

        # multiple joints create a row seperator: +----+----+
        puts (column_joint * columns) + "+"
      end

      def render(args, x:, y:)
        args.outputs.reserved << font_style.label(x: x, y: y, text: "#{@prompt}#{current_input_str}", color: @text_color)
        args.outputs.reserved << font_style.label(x: x - 4, y: y + 3, text: (" " * (@prompt.length + @cursor_position)) + "|", color: @cursor_color)
      end

      def tick
        if (@current_input_changed_at) &&
           (@current_input_changed_at < Kernel.global_tick_count) &&
           (@last_input_str != @current_input_str)
          @last_input_str_changed = true
          @last_input_str = "#{@current_input_str}"
          @current_input_changed_at = nil
        else
          @last_input_str_changed = false
        end
      end

      private

      def last_period_index
        current_input_str.rindex('.')
      end

      def calc_autocomplete_prefix
        if last_period_index
          current_input_str[(last_period_index + 1)..-1]
        else
          current_input_str
        end
      end

      def current_object
        return Kernel unless last_period_index

        Kernel.eval(current_input_str[0...last_period_index])
      rescue NameError
        nil
      end

      def method_candidates(prefix)
        current_object.autocomplete_methods.map(&:to_s).select { |m| m.start_with? prefix }
      end

      def display_autocomplete_candidate(candidate)
        if last_period_index
          @current_input_str[0..last_period_index] + candidate.to_s
        else
          candidate.to_s
        end
      end

      def reset_autocomplete
        @last_autocomplete_prefix = nil
        @next_candidate_index = 0
      end
    end
  end
end
