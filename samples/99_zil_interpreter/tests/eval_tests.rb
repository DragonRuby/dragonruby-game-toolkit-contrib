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

def test_eval_form_calls_global_value_of_func_atom(args, assert)
  zil_context = build_zil_context(args)
  call_args = nil
  call_context = nil
  zil_context.globals[:FUNC] = lambda { |args, context|
    call_args = args
    call_context = context
    'return value'
  }

  result = eval_zil(
    Syntax::Form.new(:FUNC, 'Bob', 22, Syntax::Form.new),
    zil_context
  )

  # Evaluating its arguments should be responsibility of the function
  # So eval_zil should pass them directly
  assert.equal! call_args, ['Bob', 22, Syntax::Form.new]
  assert.equal! call_context, zil_context
  assert.equal! result, 'return value'
end

def test_eval_list_returns_array_of_evaled_elements(args, assert)
  zil_context = build_zil_context(args)
  zil_context.globals[:ADD] = -> (args, _context) { args[0] + args[1] }

  result = eval_zil(
    Syntax::List.new(3, 'String', Syntax::Form.new(:ADD, 2, 12)),
    zil_context
  )

  assert.equal! result, [3, 'String', 14]
end

def test_eval_quote_returns_wrapped_element(args, assert)
  zil_context = build_zil_context(args)

  result = eval_zil(
    Syntax::Quote.new(Syntax::Form.new(:+, 1, 2, 3)),
    zil_context
  )

  assert.equal! result, Syntax::Form.new(:+, 1, 2, 3)
end

def test_eval_empty_form_returns_false(args, assert)
  zil_context = build_zil_context(args)

  result = eval_zil(
    Syntax::Form.new,
    zil_context
  )

  assert.equal! result, false
end
