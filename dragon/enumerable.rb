module Enumerable
  def sum(init = 0)
    result = init
    self.each do |element|
      result += block_given? ? yield element : element
    end
    result
  end
end
