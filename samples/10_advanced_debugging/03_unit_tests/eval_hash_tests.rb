def assert_hash assert, hash_or_string, expected
  h_to_s = if hash_or_string.is_a? String
             hash_or_string
           else
             hash_or_string.to_s
           end

  begin
    result = GTK::Codegen.eval_hash h_to_s
  rescue Exception => e
    result = e
  end
  if expected.is_a? Proc
    expected.call(result, assert)
  else
    assert.equal! result, expected
  end
end

def test_empty_hash args, assert
  assert_hash(assert, {}, {})
end

def test_allowed_node_types args, assert
  assert_hash(assert,
              {
                node_hash: { },
                node_nil: nil,
                node_int: 1,
                node_float: 10.5,
                node_str: "string",
                node_sym: :symbol,
                node_true: true,
                node_false: false,
                node_array: [1, 2, 3],
              },
              {
                node_hash: { },
                node_nil: nil,
                node_int: 1,
                node_float: 10.5,
                node_str: "string",
                node_sym: :symbol,
                node_true: true,
                node_false: false,
                node_array: [1, 2, 3],
              })
end

def test_args_state args, assert
  args.state.player.x ||= 100
  args.state.player.y ||= 200
  args.state.enemies ||= [
    { id: :a, x: 100, y: 100, w: 2, h: 3.0 },
    { id: :b, x: 100, y: 100, w: 2, h: 3.0 },
    { id: :c, x: 100, y: 100, w: 2, h: 3.0 },
    { id: :d, x: 100, y: 100, w: 2, h: 3.0 }
  ]

  assert_hash assert, args.state, ->(result, assert) {
    assert.true! args.state.as_hash.to_s, result.to_s
  }
end

def test_malicious_hash args, assert
  s = "{}; def malicious(args); end;"
  assert_hash assert, s, ->(result, assert) {
    assert.true! result.message.include?("NODE_DEF")
  }
end

def test_malicious_lvar_hash args, assert
  s = "a = 12; {};"
  assert_hash assert, s, ->(result, assert) {
    assert.true! result.message.include?("NODE_ASGN")
  }
end
