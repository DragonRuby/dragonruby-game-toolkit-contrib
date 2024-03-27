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
    DocsOrganizer.get_docsify_content path: "docs/api/grid.md",
                                      heading_level: 1,
                                      heading_include: "Grid"
  end
end

class GTK::Grid
  extend Docs
  extend GridDocs
end
