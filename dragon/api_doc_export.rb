module GTK
  module ApiDocExport
    class << self
      def export
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

        $gtk.write_file_root 'docs/api_docs.json', build_json(entries)
      end

      private

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
    end
  end
end
