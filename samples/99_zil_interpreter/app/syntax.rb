module Syntax
  class List
    attr_reader :elements

    def initialize(*elements)
      @elements = elements
    end

    def ==(other)
      other.class == self.class && @elements == other.elements
    end

    def to_s
      "(#{@elements.join(' ')})"
    end

    def inspect
      to_s
    end

    def serialize
      { type: self.class.name, elements: @elements }
    end
  end

  class Form < List
    def to_s
      "<#{@elements.join(' ')}>"
    end
  end
end
