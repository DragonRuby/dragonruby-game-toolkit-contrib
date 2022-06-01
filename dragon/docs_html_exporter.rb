# coding: utf-8
# Copyright 2022 DragonRuby LLC
# MIT License
# docs.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - Kevin Fischer: https://github.com/kfischer-okarin

module Docs
  class HtmlExporter
    attr_reader :result

    def initialize
      @result = ''
    end

    def process_header_start(level)
      @result << "<h#{level}>"
    end

    def process_text(text)
      @result << text
    end

    def process_header_end(level)
      @result << "</h#{level}>\n"
    end

    def process_paragraph_start
      @result << '<p>'
    end

    def process_paragraph_end
      @result << "</p>\n"
    end

    def process_code_block_start(language = nil)
      @result << if language
                   "<pre><code class=\"language-#{language}\">"
                 else
                   '<pre><code>'
                 end
    end

    def process_code_block_content(content)
      @result << content
    end

    def process_code_block_end(_language = nil)
      @result << "</code></pre>\n"
    end

    def process_link(href:)
      @result << "<a href=\"#{href}\">#{href}</a>"
    end

    def process_inline_code(code)
      @result << "<code>#{code}</code>"
    end

    def process_quote_start
      @result << "<blockquote>\n"
    end

    def process_quote_end
      @result << "</blockquote>\n"
    end

    def process_ordered_list_start
      @result << "<ol>\n"
    end

    def process_ordered_list_end
      @result << "</ol>\n"
    end

    def process_ordered_list_item_start
      @result << '<li>'
    end

    def process_ordered_list_item_end
      @result << "</li>\n"
    end

    alias process_unordered_list_item_start process_ordered_list_item_start
    alias process_unordered_list_item_end process_ordered_list_item_end

    def process_unordered_list_start
      @result << "<ul>\n"
    end

    def process_unordered_list_end
      @result << "</ul>\n"
    end
  end
end
