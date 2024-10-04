def test_hash_find_all args, assert
  h = {
    x: 100,
    y: 200,
    w: 10,
    h: 10
  }

  result_expected = h.find_all { |k, v| v == 100 }
  result_actual = Hash.find_all(h) { |k, v| v == 100 }
  assert.equal! result_expected, result_actual
end

def test_hash_merge args, assert
  a = {
    x: 100,
    y: 200,
    w: 10,
    h: 10
  }

  b = {
    r: 255,
    g: 255,
    b: 255
  }

  result_expected = a.merge b
  result_actual = Hash.merge a, b
  assert.equal! result_actual, result_expected, "class implementation, matches instance implemenation"
  assert.not_equal! a.object_id, result_actual.object_id, "new hash created for merge"
end

def test_hash_merge_bang args, assert
  a = {
    x: 100,
    y: 200,
    w: 10,
    h: 10
  }

  b = {
    r: 255,
    g: 255,
    b: 255
  }

  a_2 = {
    x: 100,
    y: 200,
    w: 10,
    h: 10
  }

  b_2 = {
    r: 255,
    g: 255,
    b: 255
  }

  result_expected = a.merge! b
  result_actual = Hash.merge! a_2, b_2
  assert.equal! result_actual, result_expected, "class implementation, matches instance implemenation"
  assert.equal! a_2.object_id, result_actual.object_id, "hash updated for merge!"
end

def test_hash_merge_with_block args, assert
  a = {
    x: 100,
    y: 200,
    w: 10,
    h: 10
  }

  b = {
    x: 500,
  }

  result_expected = a.merge(b) do |k, current_value, new_value|
    current_value + new_value
  end

  result_actual = Hash.merge(a, b) do
    |k, current_value, new_value|
    current_value + new_value
  end

  assert.equal! result_expected[:x], result_actual[:x]
end

def test_array_map args, assert
  a = [1, 2, 3]

  result_expected = a.map do |i| i**2 end
  result_actual = Array.map a do |i| i**2 end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_array_map_with_destructoring args, assert
  a = [[1, 2], [3, 4]]
  result_expected = a.map do |x, y| x + y end
  result_actual = Array.map a do |x, y| x + y end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id

  a = [[1, 2], [3, 4]]
  result_expected = a.map.with_index do |(x, y), i| x + y + i end
  result_actual = Array.map_with_index a do |(x, y), i| x + y + i end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_array_map_bang args, assert
  a = [1, 2, 3]
  result_expected = a.map do |i| i**2 end
  result_actual = Array.map! a do |i| i**2 end
  assert.equal! result_expected, result_actual
  assert.equal! a.object_id, result_actual.object_id
end

def test_array_reject args, assert
  a = [1, 2, 3, 4, 5, 6]
  result_expected = a.reject do |i| i.even? end
  result_actual = Array.reject a do |i| i.even? end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_array_reject_bang args, assert
  a = [1, 2, 3, 4, 5, 6]
  result_expected = a.reject do |i| i.even? end
  result_actual = Array.reject! a do |i| i.even? end
  assert.equal! result_expected, result_actual
  assert.equal! a.object_id, result_actual.object_id
end

def test_array_select args, assert
  a = [1, 2, 3, 4, 5, 6]
  result_expected = a.select do |i| i.even? end
  result_actual = Array.select a do |i| i.even? end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_array_select_bang args, assert
  a = [1, 2, 3, 4, 5, 6]
  result_expected = a.select do |i| i.even? end
  result_actual = Array.select! a do |i| i.even? end
  assert.equal! result_expected, result_actual
  assert.equal! a.object_id, result_actual.object_id
end

def test_array_find_all args, assert
  a = [1, 2, 3, 4, 5, 6]
  result_expected = a.find_all do |i| i.even? end
  result_actual = Array.find_all a do |i| i.even? end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_array_compact args, assert
  a = [1, nil, 3, false, 5, 6]
  result_expected = a.compact do |i| i.even? end
  result_actual = Array.compact a do |i| i.even? end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_array_compact_bang args, assert
  a = 100.map { |i| i }.map { |i| i.even? ? i : nil }
  result_expected = a.compact do |i| i.even? end
  result_actual = Array.compact! a do |i| i.even? end
  assert.equal! result_expected, result_actual
  assert.equal! a.object_id, result_actual.object_id
end

def test_filter_map args, assert
  a = [1, 2, 3, 4, 5, 6]
  result_expected = a.filter_map do |i| i.even? ? i * 2 : nil end
  result_actual = Array.filter_map a do |i| i.even? ? i * 2 : nil end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_flat_map args, assert
  a = 100.map.each_slice(2).to_a
  result_expected = a.flat_map do |i| i end
  result_actual = Array.flat_map a do |i| i end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_array_each args, assert
  a = [1, 2, 3, 4, 5, 6]
  result_expected = []
  a.each do |i| result_expected << i end
  result_actual = []
  Array.each a do |i| result_actual << i end
  assert.equal! result_expected, result_actual

  a = [[1, 2], [3, 4], [5, 6]]
  result_expected = []
  a.each do |x, y| result_expected << x + y end
  result_actual = []
  Array.each a do |x, y| result_actual << x + y end
  assert.equal! result_expected, result_actual

  a = [1, 2, 3, 4, 5, 6]
  result_expected = []
  a.each_with_index do |n, i| result_expected << n - i end
  result_actual = []
  Array.each_with_index a do |n, i| result_actual << n - i end
  assert.equal! result_expected, result_actual

  a = [[1, 2], [3, 4], [5, 6]]
  result_expected = []
  a.each_with_index do |(x, y), i| result_expected << x + y + i end
  result_actual = []
  Array.each_with_index a do |(x, y), i| result_actual << x + y + i end
  assert.equal! result_expected, result_actual
end

def test_bench args, assert
  ary_numbers = 100.map { |i| i }.reverse.to_a
  ary_compact = 100.map { |i| i }.map { |i| i.even? ? i : nil }
  ary_flat_map = 100.map.each_slice(2).to_a

  functions = [
    { name: :map,        ary: ary_numbers, m: proc { |i| i / 2 } },
    { name: :map!,       ary: ary_numbers, m: proc { |i| i / 2 } },
    { name: :reject,     ary: ary_numbers, m: proc { |i| i.even? } },
    { name: :reject!,    ary: ary_numbers, m: proc { |i| i.even? } },
    { name: :find_all,   ary: ary_numbers, m: proc { |i| i.even? } },
    { name: :select,     ary: ary_numbers, m: proc { |i| i.even? } },
    { name: :select!,    ary: ary_numbers, m: proc { |i| i.even? } },
    { name: :filter_map, ary: ary_numbers, m: proc { |i| i.even? ? i * 2 : nil } },
    { name: :compact,    ary: ary_compact },
    { name: :compact!,   ary: ary_compact },
  ]

  functions.each do |fh|
    h = {
      iterations: 5000,
    }

    self_numbers = fh.ary.dup
    class_numbers = fh.ary.dup

    h["self_#{fh[:name]}".to_sym] = -> () {
      self_numbers.send(fh[:name], &fh[:m])
    }

    h["class_#{fh[:name]}".to_sym] = -> () {
      Array.send(fh[:name], class_numbers, &fh[:m])
    }

    results = GTK.benchmark(**h)
    assert.true! results.first_place.name.to_s.start_with?("class_"), "Class method #{fh[:name]} is faster"
  end

  self_numbers = ary_numbers.dup
  class_numbers = ary_numbers.dup
  results = GTK.benchmark iterations: 5000,
                          self_each: -> () { self_numbers.each { |i| i } },
                          class_each: -> () { Array.each(class_numbers) { |i| i } }

  self_flat_map = ary_flat_map.dup
  class_flat_map = ary_flat_map.dup
  results = GTK.benchmark iterations: 5000,
                          self_flat_map: -> () { self_flat_map.flat_map { |i| i } },
                          class_flat_map: -> () { Array.flat_map(class_flat_map) { |i| i } }

  assert.true! results.first_place.name.to_s.start_with?("class_"), "Class method each is faster"
end
