def test_eval_number_returns_itself(args, assert)
  result = eval_zil(
    2,
    build_zil_context(args)
  )

  assert.equal! result, 2
end

def test_eval_symbol_returns_itself(args, assert)
  result = eval_zil(
    :ATOM,
    build_zil_context(args)
  )

  assert.equal! result, :ATOM
end

def test_eval_string_returns_itself(args, assert)
  result = eval_zil(
    'Bob',
    build_zil_context(args)
  )

  assert.equal! result, 'Bob'
end
