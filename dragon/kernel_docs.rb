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
* DOCS: ~Kernel~

Kernel in the DragonRuby Runtime has patches for how standard out is handled and also
contains a unit of time in games called a tick.

S
  end

  def docs_tick_count
    <<-S
* DOCS: ~Kernel::tick_count~

Returns the current tick of the game. This value is reset if you call $gtk.reset.

S
  end

  def docs_global_tick_count
    <<-S
* DOCS: ~Kernel::global_tick_count~

Returns the current tick of the application from the point it was started. This value is never reset.

S
  end

  def docs_export_docs!
    <<-S
* DOCS: ~Kernel::export_docs!~

Exports all GTK documentation to txt files and saves them to a docs directory.

S
  end

  def export_docs!
    DocsOrganizer.sort_docs_classes!
    final_string = ""
    $docs_classes.each do |k|
      log "* INFO: Retrieving docs for #{k.name}."
      final_string += k.docs_all
    end

    final_string += "\n" + (($gtk.read_file "docs/source.txt") || "")

    html_parse_result = (__docs_to_html__ final_string)

    $gtk.write_file_root 'docs/docs.txt', "#{final_string}"
    $gtk.write_file_root 'docs/docs.html', html_parse_result[:html]
    $gtk.write_file_root 'docs/parse_log.txt', (html_parse_result[:parse_log].join "\n")

    log "* INFO: All docs have been exported to docs/docs.txt."
    log "* INFO: All docs have been exported to docs/docs.html."

    nil
  end
end

module Kernel
  extend Docs
  extend KernelDocs
end
