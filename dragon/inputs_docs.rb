# coding: utf-8
# Copyright 2020 DragonRuby LLC
# MIT License
# inputs_docs.rb has been released under MIT (*only this file*).

module InputsDocs
  def docs_method_sort_order
    [
      :docs_class
    ]
  end

  def docs_class
    DocsOrganizer.get_docsify_content path: "docs/api/inputs.md",
                                      heading_level: 1,
                                      heading_include: "Inputs"
  end
end

class GTK::Inputs
  extend Docs
  extend InputsDocs
end
