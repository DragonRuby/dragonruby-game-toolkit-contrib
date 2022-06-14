# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# console_evaluator.rb has been released under MIT (*only this file*).

module GTK
  class ConsoleEvaluator
    class << self
      def search words = nil, &block
        Kernel.docs_search words, &block
      end

      def wizards
        $wizards
      end

      def locals
        @locals ||= {}
      end

      def args
        $args
      end

      def gtk
        $gtk
      end

      def state
        $state
      end

      def docs
        Kernel.docs
      end

      def docs_search words = nil, &block
        Kernel.docs_search words, &block
      end

      def export_docs!
        Kernel.export_docs!
      end

      def evaluate cmd
        code   = <<-S
#{
  locals.keys.map do |name|
    "#{name} = locals[:#{name}]"
  end.join "\n"
}

locals[:args] ||= $args
locals[:gtk]  ||= $gtk

begin
  _ = begin
    #{cmd}
  end
ensure
  local_variables.each do |name|
    locals[name] = eval(name.to_s)
  end
end
S

        GTK::ConsoleEvaluator.instance_eval code
      end
    end
  end
end
