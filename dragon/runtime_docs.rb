# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# runtime_docs.rb has been released under MIT (*only this file*).

module RuntimeDocs
  def docs_class
    <<-S
* DOCS: ~GTK::Runtime~
The GTK::Runtime class is the core of DragonRuby. It is globally accessible via ~$gtk~.
S
  end

  def docs_reset
    <<-S
* DOCS: ~GTK::Runtime#reset~
This function will reset Kernel.tick_count to 0 and will remove all data from args.state.
S
  end

  def docs_calcstringbox
    <<-S
* DOCS: ~GTK::Runtime#calcstringbox~
This function returns the width and height of a string.

#+begin_src ruby
  def tick args
    args.state.string_size           ||= args.gtk.calcstringbox "Hello World"
    args.state.string_size_font_size ||= args.gtk.calcstringbox "Hello World"
  end
#+end_src
S
  end
end

class GTK::Runtime
  extend Docs
  extend RuntimeDocs
end
