def test_hash_find_all args, assert
  h = {
    x: 100,
    y: 200,
    w: 10,
    h: 10
  }

  result_expected = h.find_all { |k, v| v == 100 }
  result_actual = Hash::find_all(h) { |k, v| v == 100 }
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
  result_actual = Hash::merge a, b
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
  result_actual = Hash::merge! a_2, b_2
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
  result_actual = Array::map a do |i| i**2 end
  assert.equal! result_expected, result_actual
  assert.not_equal! a.object_id, result_actual.object_id
end

def test_array_map_bang args, assert
  a = [1, 2, 3]
  result_expected = a.map do |i| i**2 end
  result_actual = Array::map! a do |i| i**2 end
  assert.equal! result_expected, result_actual
  assert.equal! a.object_id, result_actual.object_id
end
