def assert_hash_strings! assert, string_1, string_2
  Kernel.eval("$assert_hash_string_1 = #{string_1}")
  Kernel.eval("$assert_hash_string_2 = #{string_2}")
  assert.equal! $assert_hash_string_1, $assert_hash_string_2
end

def test_serialize args, assert
  args.state.player_one = "test"
  result = GTK.serialize_state args.state
  assert_hash_strings! assert, result, "{:entity_id=>1, :entity_keys_by_ref=>{}, :tick_count=>-1, :player_one=>\"test\"}"

  GTK.write_file 'state.txt', ''
  result = GTK.serialize_state 'state.txt', args.state
  assert_hash_strings! assert, result, "{:entity_id=>1, :entity_keys_by_ref=>{}, :tick_count=>-1, :player_one=>\"test\"}"
end

def test_deserialize args, assert
  result = GTK.deserialize_state '{:entity_id=>3, :tick_count=>-1, :player_one=>"test"}'
  assert.equal! result.player_one, "test"

  GTK.write_file 'state.txt',  '{:entity_id=>3, :tick_count=>-1, :player_one=>"test"}'
  result = GTK.deserialize_state 'state.txt'
  assert.equal! result.player_one, "test"
end

def test_very_large_serialization args, assert
  GTK.write_file("logs/log.txt", "")
  size = 3000
  size.map_with_index do |i|
    args.state.send("k#{i}=".to_sym, i)
  end

  result = GTK.serialize_state args.state
  assert.true! $serialize_state_serialization_too_large
end

def test_strict_entity_serialization args, assert
  args.state.player_one = args.state.new_entity(:player, name: "Ryu")
  args.state.player_two = args.state.new_entity_strict(:player_strict, name: "Ken")

  serialized_state = GTK.serialize_state args.state
  assert_hash_strings! assert, serialized_state, '{:entity_id=>1, :entity_keys_by_ref=>{}, :tick_count=>-1, :player_one=>{:entity_id=>3, :entity_name=>:player, :entity_keys_by_ref=>{}, :entity_type=>:player, :created_at=>-1, :global_created_at=>-1, :name=>"Ryu"}, :player_two=>{:entity_id=>5, :entity_name=>:player_strict, :entity_type=>:player_strict, :created_at=>-1, :global_created_at_elapsed=>-1, :entity_strict=>true, :entity_keys_by_ref=>{}, :name=>"Ken"}}'

  deserialize_state = GTK.deserialize_state serialized_state

  assert.equal! args.state.player_one.name, deserialize_state.player_one.name
  assert.true! args.state.player_one.is_a? GTK::OpenEntity

  assert.equal! args.state.player_two.name, deserialize_state.player_two.name
  assert.true! args.state.player_two.is_a? GTK::StrictEntity
end

def test_strict_entity_serialization_with_nil args, assert
  args.state.player_one = args.state.new_entity(:player, name: "Ryu")
  args.state.player_two = args.state.new_entity_strict(:player_strict, name: "Ken", blood_type: nil)

  serialized_state = GTK.serialize_state args.state
  assert_hash_strings! assert, serialized_state, '{:entity_id=>1, :entity_keys_by_ref=>{}, :tick_count=>-1, :player_one=>{:entity_id=>3, :entity_name=>:player, :entity_keys_by_ref=>{}, :entity_type=>:player, :created_at=>-1, :global_created_at=>-1, :name=>"Ryu"}, :player_two=>{:entity_name=>:player_strict, :global_created_at_elapsed=>-1, :created_at=>-1, :blood_type=>nil, :name=>"Ken", :entity_type=>:player_strict, :entity_strict=>true, :entity_keys_by_ref=>{}, :entity_id=>4}}'

  deserialized_state = GTK.deserialize_state serialized_state

  assert.equal! args.state.player_one.name, deserialized_state.player_one.name
  assert.true! args.state.player_one.is_a? GTK::OpenEntity

  assert.equal! args.state.player_two.name, deserialized_state.player_two.name
  assert.equal! args.state.player_two.blood_type, deserialized_state.player_two.blood_type
  assert.equal! deserialized_state.player_two.blood_type, nil
  assert.true! args.state.player_two.is_a? GTK::StrictEntity

  deserialized_state.player_two.blood_type = :O
  assert.equal! deserialized_state.player_two.blood_type, :O
end

def test_multiple_strict_entities args, assert
  args.state.player = args.state.new_entity_strict(:player_one, name: "Ryu")
  args.state.enemy = args.state.new_entity_strict(:enemy, name: "Bison", other_property: 'extra mean')

  serialized_state = GTK.serialize_state args.state

  deserialized_state = GTK.deserialize_state serialized_state

  assert.equal! deserialized_state.player.name, "Ryu"
  assert.equal! deserialized_state.enemy.other_property, "extra mean"
end

def test_by_reference_state args, assert
  # TODO
  # args.state.a = args.state.new_entity(:person, name: "Jane Doe")
  # args.state.b = args.state.a
  # assert.equal! args.state.a.object_id, args.state.b.object_id
  # serialized_state = GTK.serialize_state args.state

  # deserialized_state = GTK.deserialize_state serialized_state
  # assert.equal! deserialized_state.a.object_id, deserialized_state.b.object_id
end

def test_by_reference_state_strict_entities args, assert
  args.state.strict_entity = args.state.new_entity_strict(:couple) do |e|
    e.one = args.state.new_entity_strict(:person, name: "Jane")
    e.two = e.one
  end
  assert.equal! args.state.strict_entity.one, args.state.strict_entity.two
  serialized_state = GTK.serialize_state args.state

  deserialized_state = GTK.deserialize_state serialized_state
  assert.equal! deserialized_state.strict_entity.one, deserialized_state.strict_entity.two
end

def test_serialization_does_not_mix_up_zero_and_true args, assert
  args.state.enemy.evil = true
  args.state.enemy.hp = 0
  serialized = GTK.serialize_state args.state.enemy

  deserialized = GTK.deserialize_state serialized

  assert.equal! deserialized.hp, 0,
                "Value should have been deserialized as 0, but was #{deserialized.hp}"
  assert.equal! deserialized.evil, true,
                "Value should have been deserialized as true, but was #{deserialized.evil}"
end
