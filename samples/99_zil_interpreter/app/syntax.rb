# Contains Syntax tokens of ZIL
module Syntax
  # (...)
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

  # <...>
  class Form < List
    def to_s
      "<#{@elements.join(' ')}>"
    end
  end

  # #DECL (...)
  class Decl < List
    def to_s
      "#DECL(#{@elements.join(' ')})"
    end
  end

  # Base class for Macro and Quote
  class ElementWrapper
    attr_reader :element

    def initialize(element)
      @element = element
    end

    def ==(other)
      other.class == self.class && @element == other.element
    end

    def inspect
      to_s
    end

    def serialize
      { type: self.class.name, element: @element }
    end
  end

  # ;...
  class Comment < ElementWrapper
    def to_s
      ";#{@element}"
    end
  end

  # %...
  class Macro < ElementWrapper
    def to_s
      "%#{@element}"
    end
  end

  # '...
  class Quote < ElementWrapper
    def to_s
      "'#{@element}"
    end
  end

  # !... (MDL splat equivalent)
  class Segment < ElementWrapper
    def to_s
      "!#{@element}"
    end
  end
end
