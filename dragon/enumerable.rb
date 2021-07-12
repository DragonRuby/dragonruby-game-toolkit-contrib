module Enumerable
  def sum(&blk)
    total = 0
    i = 0
    len = length
    if blk
      while i < len
        total += blk[self[i]]
        i += 1
      end
    else
      while i < len
        total += self[i]
        i += 1
      end
    end
    total
  end
end
