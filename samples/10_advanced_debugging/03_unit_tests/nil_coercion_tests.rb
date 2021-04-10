# numbers
def test_open_entity_add_number args, assert
  assert.nil! args.state.i_value
  args.state.i_value += 5
  assert.equal! args.state.i_value, 5

  assert.nil! args.state.f_value
  args.state.f_value += 5.5
  assert.equal! args.state.f_value, 5.5
end

def test_open_entity_subtract_number args, assert
  assert.nil! args.state.i_value
  args.state.i_value -= 5
  assert.equal! args.state.i_value, -5

  assert.nil! args.state.f_value
  args.state.f_value -= 5.5
  assert.equal! args.state.f_value, -5.5
end

def test_open_entity_multiply_number args, assert
  assert.nil! args.state.i_value
  args.state.i_value *= 5
  assert.equal! args.state.i_value, 0

  assert.nil! args.state.f_value
  args.state.f_value *= 5.5
  assert.equal! args.state.f_value, 0
end

def test_open_entity_divide_number args, assert
  assert.nil! args.state.i_value
  args.state.i_value /= 5
  assert.equal! args.state.i_value, 0

  assert.nil! args.state.f_value
  args.state.f_value /= 5.5
  assert.equal! args.state.f_value, 0
end

# array
def test_open_entity_add_array args, assert
  assert.nil! args.state.values
  args.state.values += [:a, :b, :c]
  assert.equal! args.state.values, [:a, :b, :c]
end

def test_open_entity_subtract_array args, assert
  assert.nil! args.state.values
  args.state.values -= [:a, :b, :c]
  assert.equal! args.state.values, []
end

def test_open_entity_shovel_array args, assert
  assert.nil! args.state.values
  args.state.values << :a
  assert.equal! args.state.values, [:a]
end

def test_open_entity_enumerate args, assert
  assert.nil! args.state.values
  args.state.values = args.state.values.map_with_index { |i| i }
  assert.equal! args.state.values, []

  assert.nil! args.state.values_2
  args.state.values_2 = args.state.values_2.map { |i| i }
  assert.equal! args.state.values_2, []

  assert.nil! args.state.values_3
  args.state.values_3 = args.state.values_3.flat_map { |i| i }
  assert.equal! args.state.values_3, []
end

# hashes
def test_open_entity_indexer args, assert
  GTK::Entity.__reset_id__!
  assert.nil! args.state.values
  args.state.values[:test] = :value
  assert.equal! args.state.values.to_s, { entity_id: 1, entity_name: :values, entity_keys_by_ref: {}, test: :value }.to_s
end

# bug
def test_open_entity_nil_bug args, assert
  GTK::Entity.__reset_id__!
  args.state.foo.a
  args.state.foo.b
  @hello[:foobar]
  assert.nil! args.state.foo.a, "a was not nil."
  # the line below fails
  # assert.nil! args.state.foo.b, "b was not nil."
end
