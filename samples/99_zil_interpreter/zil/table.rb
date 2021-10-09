module ZIL
  module Table
    class << self
      def get_flags_and_values(arguments)
        if arguments[0].is_a? Array
          flags = arguments[0]
          values = arguments[1..-1]
        else
          flags = []
          values = arguments.dup
        end

        values << 0 if values.empty?

        [flags, values]
      end

      def build(flags:, values:)
        result = if flags.include?(:BYTE)
                   values
                 else
                   values.flat_map { |value| eval_as_bytes(value) }
                 end

        prepend_length_if_necessary result, flags: flags
        result
      end

      private

      def eval_as_bytes(value)
        if value.is_a? Syntax::Byte
          [value.element]
        else
          [value, 0]
        end
      end

      def prepend_length_if_necessary(table, flags:)
        if flags.include? :LENGTH
          if flags.include? :BYTE
            table.insert(0, table.size)
          else
            table.insert(0, table.size.idiv(2))
            table.insert(1, 0)
          end
        elsif flags.include? :LEXV
          table.insert(0, table.size.idiv(4))
          table.insert(1, 0)
        end
      end
    end
  end
end
