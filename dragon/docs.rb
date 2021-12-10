# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# docs.rb has been released under MIT (*only this file*).

module DocsOrganizer
  def self.sort_docs_classes!
    $docs_classes.sort! do |l, r|
      l_index = (class_sort_order.find_index l) || 50000
      r_index = (class_sort_order.find_index r) || 50000
      l_index = 51000 if l == :docs_classes
      r_index = 51000 if r == :docs_classes
      l_index <=> r_index
    end
  end

  def self.reserved_methods
    [
     :docs_export_docs!,
     :docs_all,
     :docs_method_sort_order,
     :docs_classes,
     :docs_search
    ]
  end

  def self.class_sort_order
    [
      GTK::ReadMe,
      GTK::Runtime,
      Array,
      GTK::Args,
      GTK::Outputs,
      GTK::Mouse,
      GTK::OpenEntity,
      Numeric,
      Kernel,
    ]
  end

  def self.check_class_sort_order
    unsorted = $docs_classes.find_all do |klass|
      !class_sort_order.include? klass
    end

    unsorted.each do |k|
        puts <<-S
* WARNING: #{klass.name} is not included in DocsOrganizer::class_sort_order. Please place this
module in its correct topological order.
S
    end

    if unsorted.length == 0
      puts <<-S
* INFO: Success. All documented classes have a sort order associated with them.
S
    end
  end

  def self.sort_method_delegate l, r, method_sort_order
    l_index = (method_sort_order.find_index l) || 50000
    r_index = (method_sort_order.find_index r) || 50000
    l_index = 51000 if l == :docs_classes
    r_index = 51000 if r == :docs_classes
    l_index = -51000 if l == :docs_class
    r_index = -51000 if r == :docs_class
    l_index <=> r_index
  end

  def self.find_methods_with_docs klass
    klass_method_sort_order = klass.docs_method_sort_order
    klass.methods.find_all { |m| m.start_with? 'docs_' }
                 .reject { |m| reserved_methods.include? m }
                 .sort do |l, r|
                   sort_method_delegate l, r, klass_method_sort_order
                 end
  end
end

module Docs
  def self.extended klass
    $docs_classes ||= []
    $docs_classes << klass
    $docs_classes.uniq!
  end

  def docs_method_sort_order
    []
  end

  def docs_classes
    DocsOrganizer.sort_docs_classes!
    list = $docs_classes.map { |mod| "** #{mod.name}.docs" }.join "\n"
    <<-S

* DOCS:
Here are the classes that have documentation. You can call the .docs method
on any of these classes:
#{list}
S
  end

  def docs_all
    docs_methods = DocsOrganizer.find_methods_with_docs(self).map { |d| send d }.join "\n"
    <<-S
#{docs_methods}
S
  end

  def docs
    docs_methods = [DocsOrganizer.find_methods_with_docs(self), :docs_classes].flatten.map { |d| "** #{self.name}.#{d}" }.join "\n"
    if self == Kernel
      <<-S

* DOCS: #{self.name}
Some Classes in Game Toolkit have a method called docs. You can invoke this
method interactively to see information about functions within the engine.
For example, invoking ~Kernel.docs_tick_count~ will give you documentation
for the Kernel.tick_count method.

To export all documentation you can use ~Kernel.export_docs!~ (or just ~export_docs!~).

To search docs you can use Kernel.docs_search (or just `docs_search`) by providing it a search term.
For example:

#+begin_src
  docs_search "array find remove nil"
#+end_src

You can do more advanced searches by providing a block:

#+begin_src
  docs_search do |entry|
    (entry.include? "Array") && (!entry.include? "Enumerable")
  end
#+end_src

#{docs_methods}
** NOTE: Invoke any of the methods above on #{self.name} to see detailed documentation.
** NOTE: Calling the docs_classes method will give you all classes in Game Toolkit that contain docs.
S
    else
      <<-S

* DOCS: #{self.name}
#{docs_methods}
S
    end
  end

  def self.__docs_search__ words = nil, &block

  end

  def __docs_search_help_text__
    <<-S
* DOCS: How To Search The Docs
To search docs you can use Kernel.docs_search (or just ~docs_search~) by providing it a search term.
For example:

#+begin_src
  docs_search "array find remove nil"
#+end_src

You can do more advanced searches by providing a block:

#+begin_src
  docs_search do |entry|
    (entry.include? "Array") && (!entry.include? "Enumerable")
  end
#+end_src
S
  end

  def __docs_search_results__ words = nil, &block
    words ||= ""

    if words.strip.length != 0
      each_word = words.split(' ').find_all { |w| w.strip.length > 3 }
      block = lambda do |entry|
        each_word.any? { |w| entry.downcase.include? w.downcase }
      end
    end

    return [__docs_search_help_text__] if !block

    DocsOrganizer.sort_docs_classes!

    this_block = block

    search_results = []

    if self == Kernel
      $docs_classes.each do |k|
        DocsOrganizer.find_methods_with_docs(k).each do |m|
          s = k.send m
          search_results << s if block.call s
        end
      end
    else
      DocsOrganizer.find_methods_with_docs(self).each do |m|
        s = send m
        search_results << s if block.call s
      end
    end

    search_results
  end

  def docs_search words = nil, &block
    results = __docs_search_results__ words, &block

    final_string = results.join "\n"

    final_string = "* DOCS: No results found." if final_string.strip.length == 0

    $gtk.write_file_root "docs/search_results.txt", final_string

    if !final_string.include? "* DOCS: No results found."
      log "* INFO: Search results have been written to docs/search_results.txt."
    end

    "\n" + final_string
  end

  def __export_docs__! opts = {}
    DocsOrganizer.sort_docs_classes!
    opts = defaults_export_docs!.merge opts
    opts[:methods] = methods_with_docs.reject { |m| m == :docs_classes } if opts[:methods].include? :all
    content = opts[:methods].map do |m|
      puts "* INFO: Getting docs for #{m}."
      (send m).ltrim + "\n"
    end.join "\n"
    file_path = "docs/#{self.name}.txt"
    $gtk.write_file_root "#{file_path}", content
    puts "* INFO: Documentation for #{self.name} has been exported to #{file_path}."
    $gtk.console.set_system_command file_path
    nil
  end

  def export_docs! opts = {}
    __export_docs__! opts
  end

  def __docs_append_true_line__ true_lines, true_line, parse_log
    true_line.rstrip!
    parse_log << "*** True Line Result\n#{true_line}"
    true_lines << true_line
  end

  # may god have mercy on your soul if you try to expand this
  def __docs_to_html__ string
    parse_log = []

    html_start_to_toc_start = <<-S
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>DragonRuby Game Toolkit Documentation</title>
    <link href="docs.css?ver=#{Time.now.to_i}" rel="stylesheet" type="text/css" media="all">
  </head>
  <body>
    <div id='table-of-contents'>
S
    html_toc_end_to_content_start = <<-S
    </div>
    <div id='content'>
S
    html_content_end_to_html_end = <<-S
    </div>
  </body>
</html>
S

    true_lines = []
    current_true_line = ""

    inside_source = false
    inside_ordered_list = false
    inside_unordered_list = false

    # PARSE TRUE LINES
    parse_log << "* Processing True Lines"
    string.strip.each_line do |l|
      parse_log << "** Processing line: ~#{l.rstrip}~"
      if l.start_with? "#+begin_src"
        parse_log << "- Line was identified as the beginning of a code block."
        inside_source = true
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        __docs_append_true_line__ true_lines, l, parse_log
      elsif l.start_with? "#+end_src"
        parse_log << "- Line was identified as the end of a code block."
        inside_source = false
        __docs_append_true_line__ true_lines, l, parse_log
        current_true_line = ""
      elsif l.start_with? "#+"
        parse_log << "- Line was identified as a literal block."
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        __docs_append_true_line__ true_lines, l, parse_log
        current_true_line = ""
      elsif l.start_with? "- "
        parse_log << "- Line was identified as a list."
        inside_unordered_list = true
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        current_true_line = l
      elsif l.start_with? "1. "
        parse_log << "- Line was identified as a start of a list."
        inside_ordered_list = true
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        current_true_line = l
      elsif inside_ordered_list && (l[1] == "." || l[2] == "." || l[3] == ".")
        parse_log << "- Line was identified as a continuation of a list."
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        current_true_line = l
      elsif inside_source
        parse_log << "- Inside source: true"
        inside_source = true
        __docs_append_true_line__ true_lines, l, parse_log
        current_true_line = ""
      elsif l.strip.length == 0
        parse_log << "- End of paragraph detected."
        inside_ordered_list = false
        inside_unordered_list = false
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        current_true_line = ""
      elsif l.start_with? "* "
        parse_log << "- Header detected."
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        __docs_append_true_line__ true_lines, l, parse_log
        current_true_line = ""
      elsif l.start_with? "** "
        parse_log << "- Header detected."
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        __docs_append_true_line__ true_lines, l, parse_log
        current_true_line = ""
      elsif l.start_with? "*** "
        parse_log << "- Header detected."
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        __docs_append_true_line__ true_lines, l, parse_log
        current_true_line = ""
      elsif l.start_with? "**** "
        parse_log << "- Header detected."
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        __docs_append_true_line__ true_lines, l, parse_log
        current_true_line = ""
      elsif l.start_with? "***** "
        parse_log << "- Header detected."
        __docs_append_true_line__ true_lines, current_true_line, parse_log
        __docs_append_true_line__ true_lines, l, parse_log
        current_true_line = ""
      else
        current_true_line += l.rstrip + " "
      end
    end

    true_lines << current_true_line if current_true_line.length != 0

    if true_lines[0].strip == ""
      true_lines = true_lines[1..-1]
    end

    toc_html = ""
    content_html = ""

    inside_pre = false
    inside_being_src    = false
    inside_paragraph    = false
    inside_literal      = false
    inside_h1           = false
    inside_ordered_list = false
    inside_ul           = false
    inside_ol           = false

    text_to_id = lambda do |text|
      text = text.strip.downcase
      text = text.gsub("*", "-")
      text = text.gsub("~", "-")
      text = text.gsub("[", "-")
      text = text.gsub("]", "-")
      text = text.gsub(":", "-")
      text = text.gsub(" ", "-")
      text = text.gsub(".", "-")
      text = text.gsub(",", "-")
      text = text.gsub("?", "-")
      text
    end

    close_list_if_needed = lambda do |inside_ul, inside_ol|
      begin
        result = ""
        if inside_ul
          result = "</ul>\n"
        elsif inside_ol
          result = "</ol>\n"
        else
          result
        end
      rescue Exception => e
        raise "* ERROR in determining close_list_if_needed lambda result. #{e}."
      end
    end

    inside_ol = false
    inside_ul = false

    toc_html = "<h1>Table Of Contents</h1>\n<ul>\n"
    parse_log << "* Processing Html Given True Lines"
    true_lines.each do |l|
      parse_log << "** Processing line: ~#{l.rstrip}~"
      if l.start_with? "* "
        parse_log << "- H1 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = text_to_id.call l
        toc_html += "<li><a class='header-1' href='##{link_id}'>#{formatted_html}</a></li>\n"
        content_html += "<h1 id='#{link_id}'>#{formatted_html}</h1>\n"
      elsif l.start_with? "** "
        parse_log << "- H2 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = text_to_id.call l
        toc_html += "<ul><li><a class='header-2' href='##{link_id}'>#{formatted_html}</a></li></ul>"
        content_html += "<h2 id='#{link_id}'>#{__docs_line_to_html__ l, parse_log}</h2>\n"
      elsif l.start_with? "*** "
        parse_log << "- H3 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = text_to_id.call l
        toc_html += "<ul><ul><li><a class='header-3' href='##{link_id}'>#{formatted_html}</a></li></ul></ul>"
        content_html += "<h3 id='#{link_id}'>#{__docs_line_to_html__ l, parse_log}</h3>\n"
      elsif l.start_with? "**** "
        parse_log << "- H4 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = text_to_id.call l
        # toc_html += "<ul><ul><ul><li><a href='##{link_id}'>#{formatted_html}</a></li></ul></ul></ul>"
        content_html += "<h4>#{__docs_line_to_html__ l, parse_log}</h4>\n"
      elsif l.start_with? "**** "
        parse_log << "- H5 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = text_to_id.call l
        # toc_html += "<ul><ul><ul><li><a href='##{link_id}'>#{formatted_html}</a></li></ul></ul></ul>"
        content_html += "<h5>#{__docs_line_to_html__ l, parse_log}</h5>\n"
      elsif l.strip.length == 0 && !inside_pre
        # do nothing
      elsif l.start_with? "#+begin_src"
        parse_log << "- PRE start detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        inside_pre = true
        content_html << '<pre><code class="language-ruby">'
      elsif l.start_with? "#+end_src"
        parse_log << "- PRE end detected."
        inside_ol = false
        inside_ul = false
        inside_pre = false
        content_html << "</code></pre>\n"
      elsif l.start_with? "#+begin_quote"
        parse_log << "- BLOCKQUOTE start detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        content_html << "<blockquote>\n"
      elsif l.start_with? "#+end_quote"
        parse_log << "- BLOCKQUOTE end detected."
        content_html << "</blockquote>\n"
      elsif (l.start_with? "1. ") && !inside_ol
        parse_log << "- OL start detected."
        parse_log << "- LI detected."

        inside_ol = true
        content_html << "<ol>\n"

        if l.split(".")[0].length == 1
          l = l[2..-1]
        elsif l.split(".")[0].length == 2
          l = l[3..-1]
        elsif l.split(".")[0].length == 3
          l = l[4..-1]
        end

        content_html << "<li>#{__docs_line_to_html__ l, parse_log}</li>\n"
      elsif inside_ol && (l[1] == "." || l[2] == "." || l[3] == ".")
        parse_log << "- LI detected."

        if l.split(".")[0].length == 1
          l = l[2..-1]
        elsif l.split(".")[0].length == 2
          l = l[3..-1]
        elsif l.split(".")[0].length == 3
          l = l[4..-1]
        elsif l.split(".")[0].length == 4
          l = l[5..-1]
        end

        content_html << "<li>#{__docs_line_to_html__ l, parse_log}</li>\n"
      elsif (l.start_with? "- ") && !inside_ul
        parse_log << "- UL start detected."
        parse_log << "- LI detected."

        inside_ul = true
        content_html << "<ul>\n"
        l = l[2..-1]

        content_html << "<li>#{__docs_line_to_html__ l, parse_log}</li>\n"
      elsif (l.start_with? "- ") && inside_ul
        parse_log << "- LI detected."

        l = l[2..-1]

        content_html << "<li>#{__docs_line_to_html__ l, parse_log}</li>\n"
      else
        if inside_ul
          parse_log << "- UL end detected."

          inside_ul = false
          content_html << "</ul>\n"
        end

        if inside_ol
          parse_log << "- OL end detected."

          inside_ol = false
          content_html << "</ol>\n"
        end

        if inside_pre
          content_html << "#{l.rstrip[2..-1]}\n"
        else
          parse_log << "- P detected."

          content_html << "<p>\n#{__docs_line_to_html__ l, parse_log}\n</p>\n"
        end
      end
    end
    toc_html += "</ul>"

    final_html = html_start_to_toc_start +
                 toc_html +
                 html_toc_end_to_content_start +
                 content_html +
                 html_content_end_to_html_end

    {
      original: string,
      html: final_html,
      parse_log: parse_log
    }
  rescue Exception => e
    $gtk.write_file_root 'docs/parse_log.txt', (parse_log.join "\n")
    raise "* ERROR in Docs::__docs_to_html__. #{e}"
  end

  def __docs_line_to_html__ line, parse_log
    parse_log << "- Determining if line is a header."
    if line.start_with? "**** "
      line = line.gsub "**** ", ""
      parse_log << "- Line contains ~**** ~... gsub-ing empty string"
    elsif line.start_with? "*** "
      line = line.gsub "*** ", ""
      parse_log << "- Line contains ~*** ~... gsub-ing empty string"
    elsif line.start_with? "** "
      line = line.gsub "** ", ""
      parse_log << "- Line contains ~** ~... gsub-ing empty string"
    elsif line.start_with? "* "
      line = line.gsub "* ", ""
      parse_log << "- Line contains ~* ~... gsub-ing empty string"
    elsif line.start_with? "* DOCS: "
      line = line.gsub "* DOCS: ", ""
      parse_log << "- Line contains ~* DOCS:~... gsub-ing empty string"
    else
      parse_log << "- Line does not appear to be a header."
    end

    tilde_count = line.count "~"
    line_has_link_marker = (line.include? "[[") && (line.include? "]]")
    parse_log << "- Formatting line: ~#{line}~"
    parse_log << "- Line's tilde count is: #{tilde_count}"
    parse_log << "- Line contains link marker: #{line_has_link_marker}"

    line_to_format = line.rstrip

    # <code> logic
    if tilde_count.even? && tilde_count != 0
      parse_log << "- CODE detected."
      temp = line_to_format
      line_to_format = ""
      in_literal = false
      in_code = false
      temp.each_char do |c|
        if c == "~" && !in_code
          in_code = true
          line_to_format << "<code>"
        elsif c == "~" && in_code
          line_to_format << "</code>"
          in_code = false
        else
          line_to_format << c
        end
      end
    end

    # <a> and <img> logic
    if line_has_link_marker
      line_to_format = line_to_format.gsub "[[", "["
      line_to_format = line_to_format.gsub "]]", "]"
      parse_log << "- LINK detected."
      temp = line_to_format
      line_to_format = ""
      in_literal = false
      in_link = false
      link_url = ""
      temp.each_char.with_index do |c, i|
        next_c = temp[i + 1]
        if !in_link && c == "["
          in_link = true
          link_url = ""
        elsif in_link && c == "]"
          in_link = false
          if link_url.end_with? ".gif"
            line_to_format << "<img src='#{link_url}'></img>"
          else
            line_to_format << "<a href='#{link_url}'>#{link_url}</a>"
          end
        elsif in_link
          link_url << c
        else
          line_to_format << c
        end
      end
    end

    return line_to_format
  rescue Exception => e
    parse_log << "* ERROR: Failed to parse line: ~#{line}~, #{e}"
    return line.rstrip
  end
end
