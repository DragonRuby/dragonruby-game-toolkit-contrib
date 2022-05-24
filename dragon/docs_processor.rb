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
      @active_markups = []
      reset_collected_text
    end

    def process(doc_string)
      doc_string.strip.split("\n").each do |line|
        if @inside_code_block
          process_code_block_line line
          next
        end

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
          line_rest = line.sub('#+begin_src', '').strip

          @inside_code_block = true
          @code_block_language = line_rest.empty? ? nil : line_rest.to_sym
          @code_block_indent = nil
          @code_block_content = ''

          if @code_block_language
            call_processors :process_code_block_start, @code_block_language
          else
            call_processors :process_code_block_start
          end
        else
          process_text_line line
        end
      end

      process_collected_text unless @collected_text.empty?
    end

    private

    def reset_collected_text
      @collected_text = ''
    end

    def process_collected_text
      markup_type = @active_markups.pop

      case markup_type
      when :link
        call_processors :process_link, href: @collected_text
      else
        call_processors :process_text, @collected_text
      end
      reset_collected_text
    end

    def process_code_block_line(line)
      if line.start_with?("#+end_src")
        @inside_code_block = false

        call_processors :process_code_block_content, @code_block_content

        if @code_block_language
          call_processors :process_code_block_end, @code_block_language
        else
          call_processors :process_code_block_end
        end
      else
        @code_block_indent ||= calc_indent(line)
        @code_block_content << line[@code_block_indent..-1]
        @code_block_content << "\n"
      end
    end

    def process_header(line, level)
      call_processors :process_header_start, level
      header_text = line.sub('*' * level, '').strip
      call_processors :process_text, header_text
      call_processors :process_header_end, level
    end

    def calc_indent(line)
      line.each_char.with_index.each do |char, index|
        next if char == ' '

        return index
      end
    end

    def process_text_line(line)
      return if line.empty?

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
          next
        elsif char == ']' && chars[index + 1] == ']'
          @collected_text << line[text_start..index - 1]
          process_collected_text

          index += 2
          text_start = index
          next
        end

        index += 1
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
