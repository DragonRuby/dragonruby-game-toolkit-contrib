def infinity
  1 / 0
end

def neg_infinity
  -1 / 0
end

def nan
  0.0 / 0
end

def test_add args, assert
  assert.equal! (args.fn.add), 0
  assert.equal! (args.fn.+), 0
  assert.equal! (args.fn.+ 1, 2, 3), 6
  assert.equal! (args.fn.+ 0), 0
  assert.equal! (args.fn.+ 0, nil), 0
  assert.equal! (args.fn.+ 0, nan), nil
  assert.equal! (args.fn.+ 0, nil, infinity), nil
  assert.equal! (args.fn.+ [1, 2, 3, [4, 5, 6]]), 21
  assert.equal! (args.fn.+ [nil, [4, 5, 6]]), 15
end

def test_sub args, assert
  neg_infinity = infinity * -1
  assert.equal! (args.fn.+), 0
  assert.equal! (args.fn.- 1, 2, 3), -4
  assert.equal! (args.fn.- 4), -4
  assert.equal! (args.fn.- 4, nan), nil
  assert.equal! (args.fn.- 0, nil), 0
  assert.equal! (args.fn.- 0, nil, infinity), nil
  assert.equal! (args.fn.- [0, 1, 2, 3, [4, 5, 6]]), -21
  assert.equal! (args.fn.- [nil, 0, [4, 5, 6]]), -15
end

def test_div args, assert
  assert.equal! (args.fn.div), 1
  assert.equal! (args.fn./), 1
  assert.equal! (args.fn./ 6, 3), 2
  assert.equal! (args.fn./ 6, infinity), nil
  assert.equal! (args.fn./ 6, nan), nil
  assert.equal! (args.fn./ infinity), nil
  assert.equal! (args.fn./ 0), nil
  assert.equal! (args.fn./ 6, [3]), 2
end

def test_idiv args, assert
  assert.equal! (args.fn.idiv), 1
  assert.equal! (args.fn.idiv 7, 3), 2
  assert.equal! (args.fn.idiv 6, infinity), nil
  assert.equal! (args.fn.idiv 6, nan), nil
  assert.equal! (args.fn.idiv infinity), nil
  assert.equal! (args.fn.idiv 0), nil
  assert.equal! (args.fn.idiv 7, [3]), 2
end

def test_mul args, assert
  assert.equal! (args.fn.mul), 1
  assert.equal! (args.fn.*), 1
  assert.equal! (args.fn.* 7, 3), 21
  assert.equal! (args.fn.* 6, nan), nil
  assert.equal! (args.fn.* 6, infinity), nil
  assert.equal! (args.fn.* infinity), nil
  assert.equal! (args.fn.* 0), 0
  assert.equal! (args.fn.* 7, [3]), 21
end

def test_lt args, assert
  assert.equal! (args.fn.lt 1), 1
  assert.equal! (args.fn.lt), nil
  assert.equal! (args.fn.lt infinity), nil
  assert.equal! (args.fn.lt nan), nil
  assert.equal! (args.fn.lt 10, 9, 8), 8
  assert.equal! (args.fn.< 10, 9, 8), 8
  assert.equal! (args.fn.< [10, 9, [8]]), 8
  assert.equal! (args.fn.< 10, 10), nil
end

def test_lte args, assert
  assert.equal! (args.fn.lte 1), 1
  assert.equal! (args.fn.lte), nil
  assert.equal! (args.fn.lte infinity), nil
  assert.equal! (args.fn.lte nan), nil
  assert.equal! (args.fn.lte 10, 9, 8), 8
  assert.equal! (args.fn.lte 10, 10), 10
  assert.equal! (args.fn.lte  10, 9, [8]), 8
  assert.equal! (args.fn.<=  10, 9, 8), 8
end

def test_gt args, assert
  assert.equal! (args.fn.gt 1), 1
  assert.equal! (args.fn.gt), nil
  assert.equal! (args.fn.gt infinity), nil
  assert.equal! (args.fn.gt nan), nil
  assert.equal! (args.fn.gt 8, 9, 10), 10
  assert.equal! (args.fn.gt [8, 9, [10]]), 10
  assert.equal! (args.fn.gt 10, 10), nil
  assert.equal! (args.fn.gt 10, 10), nil
  assert.equal! (args.fn.gt 10, 9), nil
  assert.equal! (args.fn.>  8, 9, 10), 10
end

def test_gte args, assert
  assert.equal! (args.fn.gte 1), 1
  assert.equal! (args.fn.gte), nil
  assert.equal! (args.fn.gte infinity), nil
  assert.equal! (args.fn.gte nan), nil
  assert.equal! (args.fn.gte 8, 9, 10), 10
  assert.equal! (args.fn.gte 10, 10), 10
  assert.equal! (args.fn.gte 8, 9, [10]), 10
  assert.equal! (args.fn.gte 10, 9), nil
  assert.equal! (args.fn.>=  8, 9, 10), 10
end


def test_acopy args, assert
  orig  = [1, 2, 3]
  clone = args.fn.acopy orig
  assert.equal! clone, [1, 2, 3]
  assert.equal! clone, orig
  assert.not_equal! clone.object_id, orig.object_id
end

def test_aget args, assert
  assert.equal! (args.fn.aget [:a, :b, :c], 1), :b
  assert.equal! (args.fn.aget [:a, :b, :c], nil), nil
  assert.equal! (args.fn.aget nil, 1), nil
end

def test_alength args, assert
  assert.equal! (args.fn.alength [:a, :b, :c]), 3
  assert.equal! (args.fn.alength nil), nil
end

def test_amap args, assert
  inc = lambda { |i| i + 1 }
  ary = [1, 2, 3]
  assert.equal! (args.fn.amap ary, inc), [2, 3, 4]
  assert.equal! (args.fn.amap nil, inc), nil
  assert.equal! (args.fn.amap ary, nil), nil
  assert.equal! (args.fn.amap ary, inc).class, Array
end

def test_and args, assert
  assert.equal! (args.fn.and 1, 2, 3, 4), 4
  assert.equal! (args.fn.and 1, 2, nil, 4), nil
  assert.equal! (args.fn.and), true
end

def test_or args, assert
  assert.equal! (args.fn.or 1, 2, 3, 4), 1
  assert.equal! (args.fn.or 1, 2, nil, 4), 1
  assert.equal! (args.fn.or), nil
  assert.equal! (args.fn.or nil, nil, false, 5, 10), 5
end

def test_eq_eq args, assert
  assert.equal! (args.fn.eq?), true
  assert.equal! (args.fn.eq? 1, 0), false
  assert.equal! (args.fn.eq? 1, 1, 1), true
  assert.equal! (args.fn.== 1, 1, 1), true
  assert.equal! (args.fn.== nil, nil), true
end

def test_apply args, assert
  assert.equal! (args.fn.and [nil, nil, nil]), [nil, nil, nil]
  assert.equal! (args.fn.apply [nil, nil, nil], args.fn.method(:and)), nil
  and_lambda = lambda {|*xs| args.fn.and(*xs)}
  assert.equal! (args.fn.apply [nil, nil, nil], and_lambda), nil
end

def test_areduce args, assert
  assert.equal! (args.fn.areduce [1, 2, 3], 0, lambda { |i, a| i + a }), 6
end

def test_array_hash args, assert
  assert.equal! (args.fn.array_hash :a, 1, :b, 2), { a: 1, b: 2 }
  assert.equal! (args.fn.array_hash), { }
end
