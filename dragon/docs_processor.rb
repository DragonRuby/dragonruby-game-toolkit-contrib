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
    end

    def process(doc_string)
      doc_string.strip.split("\n").each do |line|
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
        end
      end
    end

    private

    def process_header(line, level)
      call_processors :process_header_start, level
      header_text = line.sub('*' * level, '').strip
      call_processors :process_text, header_text
      call_processors :process_header_end, level
    end

    def call_processors(method_name, *args)
      @processors.each do |processor|
        processor.send(method_name, *args) if processor.respond_to? method_name
      end
    end
  end
end
