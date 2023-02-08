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

  def export_api_docs!
    entries = []
    $docs_classes.each do |klass|
      next if klass == GTK::ReadMe # Ignore text content of docs

      DocsOrganizer.find_methods_with_docs(klass).each do |doc_method|
        next if doc_method == :docs_class # Ignore class description
        next if doc_method.to_s.start_with?('docs_api_summary') # Ignore API summary texts

        entry = {
          class: klass.name,
          method: doc_method.to_s[5..],
          raw_text: klass.send(doc_method)
        }
        puts "Exporting docs for #{entry[:class]}##{entry[:method]}"
        entries << entry
      end
    end
  end
end

module Kernel
  extend Docs
  extend KernelDocs
end
