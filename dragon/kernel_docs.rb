# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# kernel_docs.rb has been released under MIT (*only this file*).

module KernelDocs
  def docs_method_sort_order
    [:docs_class, :docs_tick_count, :docs_global_tick_count]
  end

  def docs_class
    <<-S
* ~Kernel~

Kernel in the DragonRuby Runtime has patches for how standard out is handled and also
contains a unit of time in games called a tick.

S
  end

  def docs_tick_count
    <<-S
** ~tick_count~

Returns the current tick of the game. This value is reset if you call $gtk.reset.

S
  end

  def docs_global_tick_count
    <<-S
** ~global_tick_count~

Returns the current tick of the application from the point it was started. This value is never reset.

S
  end

  def docs_export_docs!
    <<-S
** ~export_docs!~

Exports all GTK documentation to txt files and saves them to a docs directory.

S
  end

  def export_docs!
    DocsOrganizer.sort_docs_classes!
    docs_string = ""
    $docs_classes.each do |k|
      log "* INFO: Retrieving docs for #{k.name}."
      docs_string += k.docs_all
    end

    samples_string = (($gtk.read_file "docs/static/samples.txt") || "")
    index_string = docs_string + "\n" + samples_string

    index_parse_result = Docs.__docs_to_html__ index_string
    docs_parse_result = Docs.__docs_to_html__ docs_string, warn_long_lines: true
    samples_parse_result = Docs.__docs_to_html__ samples_string, warn_long_lines: false

    $gtk.write_file_root 'docs/static/docs.txt', "#{docs_string}"
    $gtk.write_file_root 'docs/static/docs.html', docs_parse_result[:html]

    $gtk.write_file_root 'docs/static/samples.txt', "#{samples_string}"
    $gtk.write_file_root 'docs/static/samples.html', samples_parse_result[:html]

    $gtk.write_file_root "docs/version.txt", "#{GTK_VERSION}"

    log "* INFO: All docs have been exported to docs/docs.txt."
    log "* INFO: All docs have been exported to docs/docs.html."
    log "* INFO: To view docs locally go to http://localhost:9001/docs.html execute ~$gtk.open_docs~."

    nil
  end
end

module Kernel
  extend Docs
  extend KernelDocs
end
