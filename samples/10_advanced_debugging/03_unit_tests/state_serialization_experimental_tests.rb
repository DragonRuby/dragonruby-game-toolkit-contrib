MAX_CODE_GEN_LENGTH = 50

# NOTE: This is experimental/advanced stuff.
def needs_partitioning? target
  target[:value].to_s.length > MAX_CODE_GEN_LENGTH
end

def partition target
  return [] unless needs_partitioning? target
  if target[:value].is_a? GTK::OpenEntity
    target[:value] = target[:value].hash
  end

  results = []
  idx = 0
  left, right = target[:value].partition do
    idx += 1
    idx.even?
  end
  left, right = Hash[left], Hash[right]
  left = { value: left }
  right = { value: right}
  [left, right]
end

def add_partition target, path, aggregate, final_result
  partitions = partition target
  partitions.each do |part|
    if needs_partitioning? part
      if part[:value].keys.length == 1
        first_key = part[:value].keys[0]
        new_part = { value: part[:value][first_key] }
        path.push first_key
        add_partition new_part, path, aggregate, final_result
        path.pop
      else
        add_partition part, path, aggregate, final_result
      end
    else
      final_result << { value: { __path__: [*path] } }
      final_result << { value: part[:value] }
    end
  end
end

def state_to_string state
  parts_queue = []
  final_queue = []
  add_partition({ value: state.hash },
                [],
                parts_queue,
                final_queue)
  final_queue.reject {|i| i[:value].keys.length == 0}.map do |i|
    i[:value].to_s
  end.join("\n#==================================================#\n")
end

def state_from_string string
  Kernel.eval("$load_data = {}")
  lines = string.split("\n#==================================================#\n")
  lines.each do |l|
    puts "todo: #{l}"
  end

  GTK::OpenEntity.parse_from_hash $load_data
end

def test_save_and_load args, assert
  args.state.item_1.name = "Jane"
  string = state_to_string args.state
  state = state_from_string string
  assert.equal! args.state.item_1.name, state.item_1.name
end

def test_save_and_load_big args, assert
  size = 1000
  size.map_with_index do |i|
    args.state.send("k#{i}=".to_sym, i)
  end

  string = state_to_string args.state
  state = state_from_string string
  size.map_with_index do |i|
    assert.equal! args.state.send("k#{i}".to_sym), state.send("k#{i}".to_sym)
    assert.equal! args.state.send("k#{i}".to_sym), i
    assert.equal! state.send("k#{i}".to_sym), i
  end
end

def test_save_and_load_big_nested args, assert
  args.state.player_one.friend.nested_hash.k0 = 0
  args.state.player_one.friend.nested_hash.k1 = 1
  args.state.player_one.friend.nested_hash.k2 = 2
  args.state.player_one.friend.nested_hash.k3 = 3
  args.state.player_one.friend.nested_hash.k4 = 4
  args.state.player_one.friend.nested_hash.k5 = 5
  args.state.player_one.friend.nested_hash.k6 = 6
  args.state.player_one.friend.nested_hash.k7 = 7
  args.state.player_one.friend.nested_hash.k8 = 8
  args.state.player_one.friend.nested_hash.k9 = 9
  string = state_to_string args.state
  state = state_from_string string
end

$gtk.reset 100
$gtk.log_level = :off
