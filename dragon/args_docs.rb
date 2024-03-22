# coding: utf-8
# Copyright 2020 DragonRuby LLC
# MIT License
# args_docs.rb has been released under MIT (*only this file*).

module ArgsDocs
  def docs_method_sort_order
    [
      :docs_audio,
      :docs_easing,
      :docs_pixel_array,
      :docs_cvars
    ]
  end

  def docs_cvars
    DocsOrganizer.get_docsify_content path: "docs/api/cvars.md", heading_level: 1, heading_include: "CVars"
  end

  def docs_audio
    DocsOrganizer.get_docsify_content path: "docs/api/cvars.md", heading_level: 1, heading_include: "Audio"
  end

  def docs_easing
    DocsOrganizer.get_docsify_content path: "docs/api/cvars.md", heading_level: 1, heading_include: "Easing"
  end

  def docs_pixel_array
    DocsOrganizer.get_docsify_content path: "docs/api/cvars.md", heading_level: 1, heading_include: "Pixel Arrays"
  end
end

class GTK::Args
  extend Docs
  extend ArgsDocs
end
