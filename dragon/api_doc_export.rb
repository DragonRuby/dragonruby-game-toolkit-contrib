module GTK
  module ApiDocExport
    class << self
      def export
        entries = []

        api_doc_methods.each do |klass, doc_method|
          entry = {
            class: klass.name,
            method: doc_method.to_s[5..],
            raw_text: klass.send(doc_method)
          }
          puts "Exporting docs for #{entry[:class]}##{entry[:method]}"
          entries << entry
        end

        json = build_json(entries)
        $gtk.write_file_root 'docs/api_docs.json', json
        build_html(json)
      end

      private

      def api_doc_methods
        result = []
        $docs_classes.each do |klass|
          next if klass == GTK::ReadMe # Ignore text content of docs

          DocsOrganizer.find_methods_with_docs(klass).each do |doc_method|
            next if doc_method == :docs_class # Ignore class description
            next if doc_method.to_s.start_with?('docs_api_summary') # Ignore API summary texts

            result << [klass, doc_method]
          end
        end
        result
      end

      def build_json(object)
        case object
        when String
          object.gsub('"', '\"').inspect
        when Hash
          "{#{object.map { |k, v| "#{k.to_s.inspect}: #{build_json(v)}" }.join(',')}}"
        when Array
          "[#{object.map { |v| build_json(v) }.join(',')}]"
        end
      end

      def build_html(json)
        template = $gtk.read_file '.dragonruby/stubs/docs/api_docs.html'
        escaped_json = escape_json_for_javascript_string_literal json
        html = template.gsub(
          '// ----- EXPORT PLACEHOLDER: API ENTRIES -----',
          "const API_ENTRIES = JSON.parse('#{escaped_json}');"
        )
        $gtk.write_file_root 'docs/api_docs.html', html
      end

      def escape_json_for_javascript_string_literal(string)
        # Welcome to backslash escape hell, lol
        # Javascript string literals cannot contain real newlines, so we need to escape them
        result = string.gsub('\\n') { '\\\\\\\\n' }
        # Need to escape single quotes since we're using single quotes for the string literal
        result.gsub!("'") { "\\\\'" }
      end
    end
  end
end
