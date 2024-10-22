# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# console_prompt.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - Kevin Fischer: https://github.com/kfischer-okarin

module GTK
  class Console
    class Prompt
      # ? Can be changed, it was just taken from my editor settings :>
      WORD_LIMITER_CHARS = "`~!@#$%^&*-=+()[]{}\|;:'\",.<>/?_ \t\n\0".chars

      attr_accessor :current_input_str, :font_style, :console_text_width, :last_input_str, :last_input_str_changed

      def initialize(font_style:, text_color:, console_text_width:)
        @prompt = '-> '
        @current_input_str = ''
        @font_style = font_style
        @text_color = text_color
        @cursor_color = Color.new [187, 21, 6]
        @console_text_width = console_text_width

        @cursor_position = 0
        update_cursor_position_px

        @last_autocomplete_prefix = nil
        @next_candidate_index = 0
      end

      def update_cursor_position_px
        w, _ = $gtk.calcstringbox (@prompt + @current_input_str[0...@cursor_position]), @font_style.size_enum, @font_style.font
        @cursor_position_px = w
      end

      def current_input_str=(str)
        @current_input_str = str
        @cursor_position = str.length
        update_cursor_position_px
      end

      def <<(str)
        @current_input_str = @current_input_str[0...@cursor_position] + str + @current_input_str[@cursor_position..-1]
        @cursor_position += str.length
        update_cursor_position_px
        @current_input_changed_at = Kernel.global_tick_count
        reset_autocomplete
      end

      def backspace
        return if current_input_str.length.zero? || @cursor_position.zero?

        @current_input_str = @current_input_str[0...(@cursor_position - 1)] + @current_input_str[@cursor_position..-1]
        @cursor_position -= 1
        update_cursor_position_px
        reset_autocomplete
      end

      def delete
        return if current_input_str.length.zero? || @cursor_position == current_input_str.length

        @cursor_position += 1
        backspace
      end

      def move_cursor_left
        @cursor_position -= 1 if @cursor_position > 0
        update_cursor_position_px
      end

      def move_cursor_left_word
        return if @cursor_position.zero?

        new_pos = @cursor_position - 1
        (is_word_boundary? @current_input_str[new_pos]) ?
            (new_pos -= 1 until !(is_word_boundary? @current_input_str[new_pos - 1]) || new_pos.zero?):
            (new_pos -= 1 until (is_word_boundary? @current_input_str[new_pos - 1]) || new_pos.zero?)

        @cursor_position = new_pos
        update_cursor_position_px
      end

      def move_cursor_right
        @cursor_position += 1 if @cursor_position < current_input_str.length
        update_cursor_position_px
      end

      def move_cursor_right_word
        return if @cursor_position.equal? str_len

        new_pos = @cursor_position + 1
        (is_word_boundary? @current_input_str[new_pos]) ?
            (new_pos += 1 until !(is_word_boundary? @current_input_str[new_pos]) || (new_pos.equal? str_len)):
            (new_pos += 1 until (is_word_boundary? @current_input_str[new_pos]) || (new_pos.equal? str_len))

        @cursor_position = new_pos
        update_cursor_position_px
      end

      def move_cursor_home
        @cursor_position = 0
        update_cursor_position_px
      end

      def move_cursor_end
        @cursor_position = str_len
        update_cursor_position_px
      end

      def clear
        @current_input_str = ''
        @cursor_position = 0
        update_cursor_position_px
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
          update_cursor_position_px
        end
      rescue Exception => e
        puts "* BUG: Tab autocompletion failed. Let us know about this.\n#{e}"
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
            pretty_print_row_separator string_width, cell_width, column_width, columns
            pretty_print_row cells, string_width, cell_width, column_width, columns
          end

          pretty_print_row_separator string_width, cell_width, column_width, columns
        end
      end

      def pretty_print_row cells, string_width, cell_width, column_width, columns
        # if the number of cells doesn't match the number of columns, then pad the array with empty values
        cells += (columns - cells.length).map { "" }

        # right align each cell value
        formated_row = "|" + cells.map do |c|
          "#{" " * (string_width.length - c.length) } #{c} |"
        end.join

        # remove separators between empty values
        formated_row = formated_row.gsub("  |  ", "     ")

        puts formated_row
      end

      def pretty_print_row_separator string_width, cell_width, column_width, columns
        # this is a joint: +--------
        column_joint = "+#{"-" * cell_width}"

        # multiple joints create a row separator: +----+----+
        puts (column_joint * columns) + "+"
      end

      def render(args, x:, y:)
        args.outputs.reserved << font_style.label(x: x, y: y, text: "#{@prompt}#{current_input_str}", color: @text_color)
        args.outputs.reserved << (@cursor_color.to_h.merge x: x + @cursor_position_px + 0.5,
                                                           y: y + 5,
                                                           x2: x + @cursor_position_px + 0.5,
                                                           y2: y + @font_style.letter_size.h + 4,
                                                           a: Math.sin(Kernel.tick_count.fdiv(10)) * 64 + 192)

        args.outputs.reserved << (@cursor_color.to_h.merge x: x + @cursor_position_px + 1,
                                                           y: y + 5,
                                                           x2: x + @cursor_position_px + 1,
                                                           y2: y + @font_style.letter_size.h + 4,
                                                           a: Math.sin(Kernel.tick_count.fdiv(10)) * 64 + 192)
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
        return ConsoleEvaluator unless last_period_index

        ConsoleEvaluator.eval(current_input_str[0...last_period_index])
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

      def is_word_boundary? char
        # Alternative method
        # (WORD_LIMITER_CHARS - [char]).length != WORD_LIMITER_CHARS.length
        # Production code
        WORD_LIMITER_CHARS.include? char
      end

      def str_len
        @current_input_str.length
      end
    end
  end
end
