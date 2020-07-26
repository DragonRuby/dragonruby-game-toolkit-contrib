def test_serialize args, assert
  GTK::Entity.__reset_id__!
  args.state.player_one = "test"
  result = args.gtk.serialize_state args.state
  assert.equal! result, "{:entity_id=>3, :tick_count=>-1, :player_one=>\"test\"}"

  GTK::Entity.__reset_id__!
  args.gtk.write_file 'state.txt', ''
  result = args.gtk.serialize_state 'state.txt', args.state
  assert.equal! result, "{:entity_id=>3, :tick_count=>-1, :player_one=>\"test\"}"
end

def test_deserialize args, assert
  GTK::Entity.__reset_id__!
  result = args.gtk.deserialize_state '{:entity_id=>3, :tick_count=>-1, :player_one=>"test"}'
  assert.equal! result.player_one, "test"

  GTK::Entity.__reset_id__!
  args.gtk.write_file 'state.txt',  '{:entity_id=>3, :tick_count=>-1, :player_one=>"test"}'
  result = args.gtk.deserialize_state 'state.txt'
  assert.equal! result.player_one, "test"
end

def test_very_large_serialization args, assert
  GTK::Entity.__reset_id__!
  size = 3000
  size.map_with_index do |i|
    args.state.send("k#{i}=".to_sym, i)
  end

  result = args.gtk.serialize_state args.state
  assert.true! (args.gtk.console.log.join.include? "unlikely a string this large will deserialize correctly")
end

def test_strict_entity_serialization args, assert
  GTK::Entity.__reset_id__!
  args.state.player_one = args.state.new_entity(:player, name: "Ryu")
  args.state.player_two = args.state.new_entity_strict(:player_strict, name: "Ken")

  serialized_state = args.gtk.serialize_state args.state
  assert.equal! serialized_state, '{:entity_id=>1, :tick_count=>-1, :player_one=>{:entity_id=>1, :entity_name=>:player, :entity_type=>:player, :created_at=>-1, :global_created_at=>-1, :name=>"Ryu"}, :player_two=>{:entity_id=>3, :entity_name=>:player_strict, :created_at=>-1, :global_created_at_elapsed=>-1, :entity_strict=>true, :name=>"Ken"}}'

  deserialize_state = args.gtk.deserialize_state serialized_state

  assert.equal! args.state.player_one.name, deserialize_state.player_one.name
  assert.true! args.state.player_one.is_a? GTK::OpenEntity

  assert.equal! args.state.player_two.name, deserialize_state.player_two.name
  assert.true! args.state.player_two.is_a? GTK::StrictEntity
end

def test_strict_entity_serialization_with_nil args, assert
  GTK::Entity.__reset_id__!
  args.state.player_one = args.state.new_entity(:player, name: "Ryu")
  args.state.player_two = args.state.new_entity_strict(:player_strict, name: "Ken", blood_type: nil)

  serialized_state = args.gtk.serialize_state args.state
  assert.equal! serialized_state, '{:entity_id=>3, :tick_count=>-1, :player_one=>{:entity_id=>1, :entity_name=>:player, :entity_type=>:player, :created_at=>-1, :global_created_at=>-1, :name=>"Ryu"}, :player_two=>{:entity_id=>3, :entity_name=>:player_strict, :created_at=>-1, :global_created_at_elapsed=>-1, :entity_strict=>true, :name=>"Ken", :blood_type=>nil}}'

  deserialized_state = args.gtk.deserialize_state serialized_state

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
  GTK::Entity.__reset_id__!
  args.state.player = args.state.new_entity_strict(:player_one, name: "Ryu")
  args.state.enemy = args.state.new_entity_strict(:enemy, name: "Bison", other_property: 'extra mean')

  serialized_state = args.gtk.serialize_state args.state
  deserialized_state = args.gtk.deserialize_state serialized_state

  assert.equal! deserialized_state.player.name, "Ryu"
  assert.equal! deserialized_state.enemy.other_property, "extra mean"
end

$tests.start
