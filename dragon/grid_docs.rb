# coding: utf-8
# Copyright 2020 DragonRuby LLC
# MIT License
# grid_docs.rb has been released under MIT (*only this file*).

module GridDocs
  def docs_method_sort_order
    [
      :docs_class
    ]
  end

  def docs_class
    <<-'S'
meow
S
  end
end

class GTK::Grid
  extend Docs
  extend GridDocs
end
