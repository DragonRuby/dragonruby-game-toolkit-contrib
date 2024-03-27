# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# outputs_docs.rb has been released under MIT (*only this file*).

module OutputsDocs
  def docs_method_sort_order
    [
      :docs_class
    ]
  end

  def docs_class
    DocsOrganizer.get_docsify_content path: "docs/api/outputs.md",
                                      heading_level: 1,
                                      heading_include: "Outputs"
  end
end

class GTK::Outputs
  extend Docs
  extend OutputsDocs
end
