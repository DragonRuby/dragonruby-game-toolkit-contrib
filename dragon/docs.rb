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
      GTK::Outputs,
      GTK::Inputs,
      GTK::Runtime,
      GTK::Geometry,
      GTK::Args,
      GTK::Layout,
      GTK::Grid,
      Array,
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

  def self.get_docsify_content path:, heading_level:, heading_include:, max_depth: 100
    header_found = false
    header_found_index = -1
    inside_code_block = false
    results = []
    content = GTK.read_file path
    current_heading_depth = 0
    content.each_line.with_index do |_l, i|
      l = _l.rstrip
      current_is_heading = l.start_with? "#"

      if current_is_heading
        current_heading_depth = (l.split(" ").first || "").length
      end

      if !header_found && current_is_heading && current_heading_depth == heading_level && l.include?(heading_include)
        header_found = true
        header_found_index = i
      end

      if !header_found
        next
      end

      if l.start_with? "```"
        inside_code_block = !inside_code_block
      end

      if current_is_heading && i > header_found_index && !inside_code_block
        if heading_level >= current_heading_depth
          break
        elsif current_heading_depth >= (heading_level + max_depth)
          break
        end
      end

      l = l.gsub("<br/>", "\n")
           .gsub("!>", "NOTE:\n\n")

      if l.strip.start_with?("<!-- org: ")
        l = l.gsub("<!-- org: ", "")
             .gsub(" -->", "")
      elsif l.strip.start_with?("<!--")
        next
      elsif l.start_with?("#") && !inside_code_block
        tokens = l.split(" ")
        beginning = tokens[0]
        rest = tokens[1..-1].join(" ")
                            .gsub("`", "~")
                            .gsub("*", "-")

        l = "#{beginning.gsub "#", "*"} #{rest}"
      elsif l.start_with?("```")
        if inside_code_block
          l = l.gsub "```", "#+begin_src "
        else
          l = l.gsub "```", "#+end_src"
        end
      elsif inside_code_block
        l = "  #{l}"
      else
        l = l.gsub("`", "~")
             .gsub("*", "-")
      end

      results << l
    end

    results.join("\n")
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

* Documentation
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

* #{self.name}
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

* #{self.name}
#{docs_methods}
S
    end
  end

  def self.__docs_search__ words = nil, &block

  end

  def __docs_search_help_text__
    <<-S
* How To Search The Docs
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

    return [__docs_search_help_text__] if words.strip.length == 0 && !block

    each_word = words.split(' ').find_all { |w| w.strip.length > 3 }
    block = lambda do |entry, meta|
      entry_contains_all_words = each_word.all? do |w|
        (entry.downcase.include? "#{w.downcase}")
      end
      m_contains_any_words = each_word.any? { |w| meta.m.include? w }
      entry_contains_all_words || m_contains_any_words
    end

    DocsOrganizer.sort_docs_classes!

    this_block = block

    search_results = []

    insert_headings_proc = lambda { |klass, m|
      s = klass.send m

      next if !s

      s = s.each_line.to_a.map do |s|
        if s.start_with? "* "
          "#{s.strip} [[#{klass}.#{m}]]\n"
        elsif s.start_with? "*"
          s
        elsif s
          ""
        end
      end.join.strip

      block_result = this_block.call s if this_block.arity == 1
      block_result = this_block.call s, m: m if this_block.arity == 2
      search_results << s if block_result
    }

    if self == Kernel
      $docs_classes.each do |klass|
        DocsOrganizer.find_methods_with_docs(klass).each do |m|
          insert_headings_proc.call klass, m
        end
      end
    else
      DocsOrganizer.find_methods_with_docs(self).each do |m|
        insert_headings_proc.call self, m
      end
    end

    search_results
  end

  def docs_search words = nil, &block
    results = __docs_search_results__ words, &block

    final_string = results.join "\n"

    final_string = "* No results found." if final_string.strip.length == 0

    $gtk.write_file_root "docs/search_results.txt", final_string

    if !final_string.include? "* No results found."
      final_string += "\n* INFO: Search results have been written to docs/search_results.txt."
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
    file_path = "docs/static/#{self.name}.txt"
    $gtk.write_file_root "#{file_path}", content
    puts "* INFO: Documentation for #{self.name} has been exported to #{file_path}."
    $gtk.console.set_system_command file_path
    nil
  end

  def export_docs! opts = {}
    __export_docs__! opts
  end

  def self.__docs_append_true_line__ true_lines, true_line, parse_log
    true_line.rstrip!
    parse_log << "*** True Line Result\n#{true_line}"
    true_lines << true_line
  end

  def self.__docs_generate_link_id__ text
    text.strip
        .downcase
        .gsub("*", "-")
        .gsub("~", "-")
        .gsub("|", "-")
        .gsub("[", "-")
        .gsub("]", "-")
        .gsub("(", "-")
        .gsub(")", "-")
        .gsub(":", "-")
        .gsub(" ", "-")
        .gsub(".", "-")
        .gsub(",", "-")
        .gsub("'", "-")
        .gsub("?", "-")
        .gsub("!", "-")
  end

  # may god have mercy on your soul if you try to expand this
  def self.__docs_to_html__ string, warn_long_lines: true
    parse_log = []

    highlight_js_min_content = $gtk.read_file "docs/static/highlight.min.js"

    html_start_to_toc_start = <<-S
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>DragonRuby Game Toolkit Documentation</title>
    <script type="text/javascript">
#{highlight_js_min_content}
    </script>
    <link href="docs.css?ver=#{Time.now.to_i}" rel="stylesheet" type="text/css" media="all">
    <script type="text/javascript">
var styleElement = document.createElement('style');
document.getElementsByTagName("head")[0].appendChild(styleElement);

document.addEventListener('load', () => {
  hljs.getLanguage('ruby').keywords += ' args tick ';
})

document.addEventListener("animationstart", e => {
  if (e.animationName == "node-ready") {
    hljs.highlightBlock(e.target);
    e.target.classList.add("fade-in");
    // get the first href within the visible hrefs
  }
});
 </script>
 </head>
  <body>
    <div id='table-of-contents'>
      <li><a class='header-1' href='docs.html'>Docs</a></li>
      <li><a class='header-1' href='samples.html'>Samples</a></li>
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
        link_id = __docs_generate_link_id__ l
        toc_html += "<li><a class='header-1' href='##{link_id}'>#{formatted_html}</a></li>\n"
        content_html += "<h1 id='#{link_id}'>#{formatted_html} <a style='font-size: small; float: right;' href='##{link_id}'>link</a></h1> \n"
      elsif l.start_with? "** "
        parse_log << "- H2 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = __docs_generate_link_id__ l
        toc_html += "<ul><li><a class='header-2' href='##{link_id}'>#{formatted_html}</a></li></ul>"
        content_html += "<h2 id='#{link_id}'>#{__docs_line_to_html__ l, parse_log} <a style='font-size: small; float: right;' href='##{link_id}'>link</a></h2> \n"
      elsif l.start_with? "*** "
        parse_log << "- H3 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = __docs_generate_link_id__ l
        toc_html += "<ul><ul><li><a class='header-3' href='##{link_id}'>#{formatted_html}</a></li></ul></ul>"
        content_html += "<h3 id='#{link_id}'>#{__docs_line_to_html__ l, parse_log} <a style='font-size: small; float: right;' href='##{link_id}'>link</a></h3> \n"
      elsif l.start_with? "**** "
        parse_log << "- H4 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = __docs_generate_link_id__ l
        # toc_html += "<ul><ul><ul><li><a href='##{link_id}'>#{formatted_html}</a></li></ul></ul></ul>"
        content_html += "<h4>#{__docs_line_to_html__ l, parse_log}</h4>\n"
      elsif l.start_with? "***** "
        parse_log << "- H5 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = __docs_generate_link_id__ l
        # toc_html += "<ul><ul><ul><li><a href='##{link_id}'>#{formatted_html}</a></li></ul></ul></ul>"
        content_html += "<h5>#{__docs_line_to_html__ l, parse_log}</h5>\n"
      elsif l.strip.length == 0 && !inside_pre
        # do nothing
      elsif l.start_with? "#+begin_src"
        language_name = l.gsub("#+begin_src", "").strip
        if language_name == ""
          language_name = "ruby"
        end
        parse_log << "- PRE start detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        inside_pre = true
        content_html << "<pre><code class=\"#{language_name}\">"
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
        if l.strip == "#end_src"
          parse_log << "* WARNING: A line exists where the value is ~#end_src~. Did you mean ~#+end_src~?"
          $gtk.log_warn "* WARNING: A line exists where the value is ~#end_src~. Did you mean ~#+end_src~?"
        end

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
          pre = l.rstrip[2..-1] || ""
          # if warn_long_lines && l.length > 105
          #   parse_log << "* WARNING: Long code line: #{pre}"
          #   $gtk.log_warn "* WARNING: Long code line:\n#{pre}"
          # end
          escaped_pre = pre.gsub("&", "&amp;")
                           .gsub("<", "&lt;")
                           .gsub(">", "&gt;")

          content_html << "#{escaped_pre}\n"
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
    $gtk.write_file_root 'docs/static/parse_log.txt', (parse_log.join "\n")
    raise "* ERROR in Docs::__docs_to_html__. #{e}"
  end

  def self.__docs_line_to_html__ line, parse_log
    # !!! FIXME: Edge case that isn't handled correctly
    #            ~args.inputs.keyboard[KEYCODE]~: [[https://wiki.libsdl.org/SDL2/SDLKeycodeLookup]]

    parse_log << "- Determining if line is a header."
    if line.start_with? "***** "
      line = line.gsub "***** ", ""
      parse_log << "- Line contains ~***** ~... gsub-ing empty string"
    elsif line.start_with? "**** "
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
    elsif line.start_with? "* "
      line = line.gsub "* ", ""
      parse_log << "- Line contains ~* ~... gsub-ing empty string"
    else
      parse_log << "- Line does not appear to be a header."
    end

    tilde_count = line.count "~"
    line_has_link_marker = (line.include? "[[") && (line.include? "]]")
    parse_log << "- Formatting line: ~#{line}~"
    parse_log << "- Line's tilde count is: #{tilde_count}"
    parse_log << "- Line contains link marker: #{line_has_link_marker}"

    line_to_format = line.rstrip
                         .gsub("&", "&amp;")
                         .gsub("<", "&lt;")
                         .gsub(">", "&gt;")
                         .gsub(":b:", "<b>")
                         .gsub(":/b:", "</b>")

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

# hotload locally if actively changing this file
# if $gtk
#   $gtk.export_docs!; $gtk.open_docs
# end
