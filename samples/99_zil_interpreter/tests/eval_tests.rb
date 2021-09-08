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

def test_eval_vector_returns_array_of_evaled_elements(args, assert)
  zil_context = build_zil_context(args)
  zil_context.globals[:ADD] = -> (args, _context) { args[0] + args[1] }

  result = eval_zil(
    Syntax::Vector.new(3, 'String', Syntax::Form.new(:ADD, 2, 12)),
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

def test_eval_atom_T_returns_true(args, assert)
  zil_context = build_zil_context(args)

  result = eval_zil(
    :T,
    zil_context
  )

  assert.equal! result, true
end

def test_eval_comment_returns_nil(args, assert)
  zil_context = build_zil_context(args)

  result = eval_zil(
    Syntax::Comment.new(Syntax::Form.new(:TEST, 1, 2)),
    zil_context
  )

  assert.equal! result, nil
end

# Segments should not be evaluated by normal eval but only inside builtin list and string
# construction functions
def test_eval_segment_will_raise_exception(args, assert)
  zil_context = build_zil_context(args)

  will_raise_eval_error!(assert) do
    eval_zil(
      Syntax::Segment.new("ABC"),
      zil_context
    )
  end
end

# Macros should be evaluated not by default eval but inside functions that take unevaluated
# forms
def test_eval_macro_will_raise_exception(args, assert)
  zil_context = build_zil_context(args)

  will_raise_eval_error!(assert) do
    eval_zil(
      Syntax::Macro.new(
        Syntax::Form.new(:IF, :T, 2, 3)
      ),
      zil_context
    )
  end
end

def will_raise_eval_error!(assert)
  raised_exception_class = nil
  begin
    yield
  rescue Exception => e
    raised_exception_class = e.class
  end

  assert.equal! raised_exception_class, EvalError, 'it did not raise EvalError'
end
