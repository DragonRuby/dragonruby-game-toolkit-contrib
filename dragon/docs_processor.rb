# coding: utf-8
# Copyright 2022 DragonRuby LLC
# MIT License
# docs.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - Kevin Fischer: https://github.com/kfischer-okarin

module Docs
  class Processor
    def initialize(processors:)
      @processors = processors
      @line_type = :normal
      @active_markups = []
      @code_block_indent = nil
      reset_collected_text
    end

    def process(doc_string)
      call_processors :process_document_start
      @lines = doc_string.strip.split("\n")
      @index = 0

      while @index < @lines.length
        line = @lines[@index]

        send :"process_#{@line_type}_line", line

        @index += 1
      end

      process_collected_text unless @collected_text.empty?
      send :"finish_#{@line_type}" unless @line_type == :normal
      call_processors :process_document_end
    end

    private

    def reset_collected_text
      @collected_text = ''
    end

    def process_collected_text
      markup_type = @active_markups.pop
      return if @collected_text.empty?

      case markup_type
      when :link
        call_processors :process_link, href: @collected_text
      when :inline_code
        call_processors :process_inline_code, @collected_text
      else
        call_processors :process_text, @collected_text
      end
      reset_collected_text
    end

    def process_normal_line(line)
      if line.start_with?('* ')
        process_header(line, 1)
      elsif line.start_with?('** ')
        process_header(line, 2)
      elsif line.start_with?('*** ')
        process_header(line, 3)
      elsif line.start_with?('**** ')
        process_header(line, 4)
      elsif line.start_with?('***** ')
        process_header(line, 5)
      elsif line.start_with?('#+begin_src')
        start_code_block(line)
      elsif line.start_with?('#+begin_quote')
        process_collected_text
        call_processors :process_quote_start
      elsif line.start_with?('#+end_quote')
        process_collected_text
        call_processors :process_quote_end
      elsif line.start_with?('1.')
        start_ordered_list line
      elsif line.start_with?('- ')
        start_unordered_list line
      else
        process_text_line line
      end
    end

    def process_header(line, level)
      call_processors :process_header_start, level
      header_text = line.sub('*' * level, '').strip
      process_text_line header_text
      process_collected_text

      call_processors :process_header_end, level
    end

    def start_code_block(line)
      line_rest = line.sub('#+begin_src', '').strip

      @line_type = :code_block
      @code_block_language = line_rest.empty? ? nil : line_rest.to_sym
      @code_block_indent = calc_indent(@lines[@index + 1])
      @code_block_content = ''

      if @code_block_language
        call_processors :process_code_block_start, @code_block_language
      else
        call_processors :process_code_block_start
      end
    end

    def process_code_block_line(line)
      if line.start_with?("#+end_src")
        finish_code_block
      else
        @code_block_content << (line[@code_block_indent..-1] || '')
        @code_block_content << "\n"
      end
    end

    def finish_code_block
      @line_type = :normal
      @code_block_indent = nil

      call_processors :process_code_block_content, @code_block_content

      if @code_block_language
        call_processors :process_code_block_end, @code_block_language
      else
        call_processors :process_code_block_end
      end
    end

    def start_ordered_list(line)
      process_collected_text
      @line_type = :ordered_list
      call_processors :process_ordered_list_start
      process_ordered_list_line line
    end

    def process_ordered_list_line(line)
      if line[1] == '.'
        unless @collected_text.empty?
          process_collected_text
          call_processors :process_ordered_list_item_end
        end
        call_processors :process_ordered_list_item_start
        list_item_content = line[3..-1].strip
        process_text_line list_item_content
      elsif line[0..2] == '   '
        list_item_content = line[3..-1].strip
        process_text_line list_item_content
      elsif line.strip.empty?
        process_collected_text
        finish_ordered_list
      end
    end

    def finish_ordered_list
      call_processors :process_ordered_list_item_end
      call_processors :process_ordered_list_end
      @line_type = :normal
    end

    def start_unordered_list(line)
      process_collected_text
      @line_type = :unordered_list
      call_processors :process_unordered_list_start
      process_unordered_list_line line
    end

    def process_unordered_list_line(line)
      if line.start_with? '- '
        unless @collected_text.empty?
          process_collected_text
          call_processors :process_unordered_list_item_end
        end
        call_processors :process_unordered_list_item_start
        list_item_content = line[2..-1].strip
        process_text_line list_item_content
      elsif line[0..1] == '  '
        list_item_content = line[2..-1].strip
        process_text_line list_item_content
      elsif line.strip.empty?
        process_collected_text
        finish_unordered_list
      end
    end

    def finish_unordered_list
      call_processors :process_unordered_list_item_end
      call_processors :process_unordered_list_end
      @line_type = :normal
    end

    def calc_indent(line)
      line.each_char.with_index.each do |char, index|
        next if char == ' '

        return index
      end
    end

    def process_text_line(line)
      if line.empty?
        process_collected_text
        return
      end

      @collected_text << ' ' unless @collected_text.empty?

      text_start = 0
      chars = line.strip.chars
      index = 0

      while index < chars.length
        char = chars[index]
        if char == '[' && chars[index + 1] == '['
          @collected_text << line[text_start..index - 1]
          process_collected_text

          index += 2
          text_start = index
          @active_markups << :link
        elsif char == ']' && chars[index + 1] == ']'
          @collected_text << line[text_start..index - 1]
          process_collected_text

          index += 2
          text_start = index
        elsif char == '~'
          was_inside_code = @active_markups.last == :inline_code
          @collected_text << line[text_start..index - 1]
          process_collected_text

          index += 1
          text_start = index
          @active_markups << :inline_code unless was_inside_code
        else
          index += 1
        end
      end

      @collected_text << line[text_start..-1]
    end

    def call_processors(method_name, *args)
      @processors.each do |processor|
        processor.send(method_name, *args) if processor.respond_to? method_name
      end
    end
  end
end
