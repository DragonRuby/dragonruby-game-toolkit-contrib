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
module in it's correct topilogical order.
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
  
  def __docs_get_favicon_base64__
    "AAABAAMAMDAAAAEAIACoJQAANgAAACAgAAABACAAqBAAAN4lAAAQEAAAAQAgAGgEAACGNgAAKAAAADAAAABgAAAAAQAgAAAAAAAAJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABPlDgAT5RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE+UNABPkmAAT5KAAE+URAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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6ftncu/5DR7k/QAQ4/8AE+P/ABPj/wAT4/8AE+P/AhTj/gAS4/8AE+P/ABPj/wAT4/8AE+P/ABPj/wAT4/8AE+OjABPlFQAT5H0AE+P8ABPj/wAT4/8AE+P/ABPj/wAS4/8JGuT9jpbz+/v8//7/////oaj1+gYX5P0AEuP/ABPj/wga5P0WJ+b7ABHj/wEU4/4fL+f7ztL6+///////////+vr+/nV/8Pk/Ter5eYPx9qWs9vURIuX8OEfp+8nN+fz8/P/+r7X3+jRD6fsCE+P+ABDj/wAS4/8AEuP+VmLt9ig35/sAEeP/ABPj/wAT4/8AE+P/ABPj/wAT4/8AE+P8ABPkhQAT5C4AE+PWABPj/wUY5P0EFOP+ABDj/wAT4/8AEuP/DBzk/oON8vrz9P799/f+/m968PoFFeP+AA/j/wob5P2MlPP2O0nq+xAg5fuPl/P21dj7+f////////////////X2/v2rsfb6cXzw+M7R+vm/xPj66Or9/P///////////////+jp/fyMlfP6MUDp+wsd5P0WJ+b8v8T4+rC29/oKG+T9ABLj/wAT4/8AE+P/ABPj/wAT4/8AE+PmABPkRwAAAAAAE+RkABLj+Rss5vpxfPD3MUHp+wQW4/4AD+P/ABDj/wUV4/5OW+z6xMj5+/Dy/vyco/T6NkXp+wwe5fyor/b50dX6+yAv5/t0fvD6/f3//v///////////////////////////////v7+////////////////////////////////////////7O39/MbK+fvP0vr7+vr+/NPW+/Q5SOr4AhXj/gAT4/8AE+P/ABPj/wAT4/4AE+R+ABTsAQAAAAAAE+UMABPjrQAT4/92gfD56Or9+6mv9vpbZ+36IzPn+wcZ5P0ADuL+DR3k/U1b7PqdpfX5wMX5+L3C+Pjs7f38/////4uT8/oNHuT8k5vz+vj5/v35+v7+6+z9+v///////////////////////////////////////////////////////////////////////////v7//vb3/vzP0/r5HC3m+wAR4/8AE+P/ABPj/wAT48IAE+UXAAAAAAAAAAAAAAAAABPkNgAS4+QRIuX+vMH4+//////8/P/+5Ob8/Lq/+PqOl/P5a3bv+Vhk7fteau76kZnz9ufp/fr//////////9zf+/sdLeb8Bxjk/lRg7fp3gfH4v8T4+P/////////////////////////////////////////////////////////////////////7/P/97/D9/Pv7//3Hy/n7DyDl/QAS4/8AE+P/ABPj7wAT5EkAAAAAAAAAAAAAAAAAAAAAAAAAAAAT5HkAEOP9QU7q++zu/fz//////////////////////////v////7////////////////u7/390dT69vj4/vxEUuv6AA/j/wAM4v9GUuv68fL+/f///////////////////////////v7//+Xn/Pymrfb5vMH4+v39//7////////////////6+//8qrD29sLG+fZfau76ABHj/wAT4/8AE+P/ABPkjgAT5wQAAAAAAAAAAAAAAAAAAAAAAAAAAAAT5RUAE+O/BBXj/1Fe7PqVnfT5ub74+tDT+vvd3/v74+X8/eLk/PzZ2/v7w8f5+pOb9PlHVev5rLL2+f////1QXez5AA3i/xsq5vzEyPn7/v7//f7+////////////////////////8vP++rO49/aRmfP4jJXz9qiu9ve0uff6kZrz+XmD8fjDx/n31tn7+19r7vkFFuP+ABPj/wAT4/8AE+POABPkHwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE+RGABPj7gAQ4/8AEeP+Bhjk/RAi5fwZKub8IDDn/R4v5/wWJ+b8CRvk/QAQ4/5daO369PX+/vLz/v02ROn7ESLl/aiv9vr////+3eD89pif9Pe+w/j64eP8/PP0/v37+//++/v//vn5/v3q7P38kJjz+Rco5vsDFuP9ABHj/gcX5Pw+TOr3ITHn/AES4/8AE+P/ABPj/wAT4/QAE+RWAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE+cDABPkjQAT4/8AE+P/ABPj/wAS4/8AEuP/ABHj/wAR4/8AEOP/Bhbk/mRw7vrr7P39/////7vA+PsaK+b6i5Tz99LW+vqlrPX6UV7s+hgn5vpxfPD2bnnw915q7vVNWuz5Tlzs+0JQ6/onN+j7BBXj/gAS4/8AE+P/ABPj/wAT4/8AEOP/ABHj/wAT4/8AE+P/ABPj/wAT5JwAE+YHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABPkHwAT488AE+P/ABPj/wAT4/8AE+P/ABPj/wAT4/4iM+f6lZ30+PP0/vz+/v/96Or9/EVS6/sFF+T9HzDn+xIk5fwDFeP+AA3i/z9N6vnc3/v6o6r1+TFA6fkAD+P+AA/j/wAP4/8AEeP/ABPj/wAT4/8AE+P/ABPj/wAT4/8AE+P/ABPj/wAT4/8AE+P/ABPj2AAT5CgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAT5FgAE+P1ABPj/wAT4/8AE+P/ABPj/wEU4/0qOuj3TVrs+UxZ7PpMWez5NUTp+wMU4/8AEuP/ABHj/wAS4/8AE+P/ABLj/xgq5vslNef8Bxjk/gAR4/8AE+P/ABPj/wAT4/8AE+P/ABPj/wAT4/8AE+P/ABPj/wAT4/8AE+P/ABPj/wAT4/8AE+P4ABPkZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAT5QgAE+SfABPj+AAT4/YAE+P2ABPj9gAT4/YAEeP2AA/j9gAP4/YAD+P2ABDj9gAT4/YAE+P2ABPj9gAT4/YAE+P2ABPj9gAS4/YAEeP2ABPj9gAT4/YAE+P2ABPj9gAT4/YAE+P2ABPj9gAT4/YAE+P2ABPj9gAT4/YAE+P2ABPj9gAT4/gAE+SnABPlCwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE+UYABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5T8AE+U/ABPlPwAT5UAAE+UbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///////wAA////////AAD///////8AAP///n///wAA///8P///AAD///wf//8AAP//+B///wAA///wD///AAD//+AH//8AAP//wAP//wAA//+AAf//AAD//wAA//8AAP/+AAB//wAA//wAAD//AAD/+AAAH/8AAP/wAAAP/wAA/+AAAAf/AAD/wAAAA/8AAP/AAAAD/wAA/4AAAAH/AAD/AAAAAP8AAP4AAAAAfwAA/AAAAAA/AAD4AAAAAB8AAPAAAAAADwAA4AAAAAAHAADAAAAAAAMAAIAAAAAAAQAAgAAAAAAAAACAAAAAAAEAAMAAAAAAAwAAwAAAAAADAADgAAAAAAcAAPAAAAAABwAA8AAAAAAPAAD4AAAAAB8AAPgAAAAAHwAA/AAAAAA/AAD+AAAAAH8AAP4AAAAAfwAA////////AAD///////8AAP///////wAA////////AAD///////8AAP///////wAA////////AAD///////8AACgAAAAgAAAAQAAAAAEAIAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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4/8AD+P/OUXp/PP0/v7/////wMT4/Cg46PppdO/7usD4+XqE8foPH+X+ABLj/wAT4/8AE+P/ABPj/wAT4/8AE+P7ABPjhwAT5QgAAAAAAAAAAAAAAAAAE+UGABPjgAAQ4/k+Ter89PT+/v////97hPH7AA/j/wAT4/8AE+P/ABHj/yIz5/x+iPH69/j+/vX2/v5PWuz7fYXx+XN+8PqFjvL4HS3m/QAR4/8AE+P/ABPj/wAT4/8AE+P/ABPj/wAT4/8AE+P3ABPjeAAT5QQAAAAAABPlBAAT43EAE+P1AA/j/0hV6/z4+f7+/////mNt7vsAD+L/ABPj/wAT4/8AEOP/NkXp/O/w/f3/////1Nf6/DxK6vlNWuz6n6b19zxJ6vwAD+P+ABHj/wAT4/8AE+P/ABPj/wAS4/8AE+P/ABPj/wAT4/8AE+PzABPkaAAT5gIAE+RsABPj8AAT4/8AEuP/EiPl/ba79/z/////jpbz+wAR4/4AE+P/AhXj/gAR4/8QIeX9w8f5/P/////d4Pv9Ym3u+a2z9viBivH4Cxvk/nB78PtVYu38Bhfk/gAQ4/8AEeP/DyDl/AcY5P4AE+P/ABPj/wAT4/8AE+PsABPkZQAT5IAAE+P7Bhnk/gIS4/8ADuL/JDPn/bm++Pzk5vz9RFLr/AAO4v8nNef7QU7q+yQz5/u2vPf5//////7+//+7wPj8fojx+Kiu9vmnrvb89vf+/vP0/v6epfX8OEbp/A8h5f14gvH6Ym3u+wAQ4/8AE+P/ABPj/wAT4/4AE+ORABPkFAAR47kuPuj9cHvw+io66PwFFuP+ESHl/XR/8Pyyt/f7cHvw+mhz7/rQ1Pr7R1Xr+7q/+Pz//////P3//v/////7+//+/f3//v/////////////////////u7/390dT6/PDx/fy+w/j3IzPn/AAR4/8AE+P/ABPjxwAT5B4AAAAAABHjQQga5OqepfX86+39/bO59/x5g/H7UV7s+11p7vudpPX46+39+/////6QmPP7IzPn/ImS8vvBxvn5////////////////////////////////////////////////9PT+/fLz/vxLWOv7AA/j/wAT4/EAE+ROAAAAAAAAAAAAFucCAA/jiCg35/3Jzfn89vf+/v7+//78/P/+9fb+/vHy/v3a3fv8xcn5+cPI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"
  end

  # may god have mercy on your soul if you try to expand this
  def __docs_to_html__ string
    parse_log = []

    html_start_to_toc_start = <<-S
<html>
  <head>
    <title>DragonRuby Game Toolkit Documentation</title>
    <link href="docs.css?ver=#{Time.now.to_i}" rel="stylesheet" type="text/css" media="all">
    <link rel="icon" type="image/x-icon" href="data:image/x-icon;base64,#{__docs_get_favicon_base64__()}" />
  </head>
  <body>
    <div id='toc'>
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
        toc_html += "<li><a href='##{link_id}'>#{formatted_html}</a></li>\n"
        content_html += "<h1 id='#{link_id}'>#{formatted_html}</h1>\n"
      elsif l.start_with? "** "
        parse_log << "- H2 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = text_to_id.call l
        # toc_html += "<a href='##{link_id}'>#{formatted_html}</a></br>\n"
        content_html += "<h2>#{__docs_line_to_html__ l, parse_log}</h2>\n"
      elsif l.start_with? "*** "
        parse_log << "- H3 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = text_to_id.call l
        # toc_html += "<a href='##{link_id}'>#{formatted_html}</a></br>\n"
        content_html += "<h3>#{__docs_line_to_html__ l, parse_log}</h3>\n"
      elsif l.start_with? "**** "
        parse_log << "- H4 detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        formatted_html = __docs_line_to_html__ l, parse_log
        link_id = text_to_id.call l
        # toc_html += "<a href='##{link_id}'>#{formatted_html}</a></br>\n"
        content_html += "<h4>#{__docs_line_to_html__ l, parse_log}</h4>\n"
      elsif l.strip.length == 0 && !inside_pre
        # do nothing
      elsif l.start_with? "#+begin_src"
        parse_log << "- PRE start detected."
        content_html += close_list_if_needed.call inside_ul, inside_ol
        inside_ol = false
        inside_ul = false
        inside_pre = true
        content_html << "<pre>"
      elsif l.start_with? "#+end_src"
        parse_log << "- PRE end detected."
        inside_ol = false
        inside_ul = false
        inside_pre = false
        content_html << "</pre>\n"
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
