module Syntax
  class Form
    attr_reader :elements

    def initialize(*elements)
      @elements = elements
    end

    def ==(other)
      other.is_a?(Form) && @elements == other.elements
    end

    def to_s
      "<#{@elements.join(' ')}>"
    end

    def inspect
      to_s
    end
  end

  class List
    attr_reader :elements

    def initialize(*elements)
      @elements = elements
    end

    def ==(other)
      other.is_a?(List) && @elements == other.elements
    end

    def to_s
      "(#{@elements.join(' ')})"
    end

    def inspect
      to_s
    end
  end
end
