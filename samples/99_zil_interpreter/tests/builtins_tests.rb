def test_builtin_lval(args, assert)
  zil_context = build_zil_context(args)
  zil_context.locals[:"LOCAL-VAR"] = 22

  # <LVAL LOCAL-VAR>
  result = zil_context.globals[:LVAL].call [:"LOCAL-VAR"], zil_context

  assert.equal! result, 22

  # Evaluating argument first
  zil_context.locals[:VARNAME] = :"LOCAL-VAR"

  # <LVAL <LVAL VARNAME>>
  result = zil_context.globals[:LVAL].call [Syntax::Form.new(:LVAL, :VARNAME)], zil_context

  assert.equal! result, 22
end

def test_builtin_lval_raises_error_when_not_existing(args, assert)
  zil_context = build_zil_context(args)

  zil_context.globals[:LVAL].call [:"LOCAL-VAR"], zil_context
  raise 'No exception occurred'
rescue FunctionError
  assert.ok!
end

def test_builtin_plus(args, assert)
  zil_context = build_zil_context(args)

  # <+>
  result = zil_context.globals[:+].call [], zil_context
  assert.equal! result, 0

  # <+ 5>
  result = zil_context.globals[:+].call [5], zil_context
  assert.equal! result, 5

  # <+ 1 2 <+ 3 4>>
  result = zil_context.globals[:+].call [1, 2, Syntax::Form.new(:+, 3, 4)], zil_context
  assert.equal! result, 10
end

def test_builtin_minus(args, assert)
  zil_context = build_zil_context(args)

  # <- 10 1 <- 5 1>>
  result = zil_context.globals[:-].call [10, 1, Syntax::Form.new(:-, 5, 1)], zil_context
  assert.equal! result, 5

  # <- 5>
  result = zil_context.globals[:-].call [5], zil_context
  assert.equal! result, -5

  # <- >
  result = zil_context.globals[:-].call [], zil_context
  assert.equal! result, 0
end

def test_builtin_multiply(args, assert)
  zil_context = build_zil_context(args)

  # <* 1 5>
  result = zil_context.globals[:*].call [1, 5], zil_context
  assert.equal! result, 5

  # <* 1 5 <* 5 2>>
  result = zil_context.globals[:*].call [1, 5, Syntax::Form.new(:*, 5, 2)], zil_context
  assert.equal! result, 50

  # <* 1>
  result = zil_context.globals[:*].call [], zil_context
  assert.equal! result, 1
end

def test_builtin_divide(args, assert)
  zil_context = build_zil_context(args)

  # </ 10 </ 50 10>>
  result = zil_context.globals[:/].call [10, Syntax::Form.new(:/, 50, 10)], zil_context
  assert.equal! result, 2

  # </ 10 2>
  result = zil_context.globals[:/].call [10, 2], zil_context
  assert.equal! result, 5

  # </ 5>
  result = zil_context.globals[:/].call [5], zil_context
  assert.equal! result, 0

  # </>
  result = zil_context.globals[:/].call [], zil_context
  assert.equal! result, 1

  # </ 1.5 0.5>
  result = zil_context.globals[:/].call [1.5, 0.5], zil_context
  assert.equal! result, 3.0

  # </ 11 7 2.0>
  result = zil_context.globals[:/].call [11, 7, 2.0], zil_context
  assert.equal! result, 0.5
end

def test_builtin_min(args, assert)
  zil_context = build_zil_context(args)

  # <MIN 1>
  result = zil_context.globals[:MIN].call [1], zil_context
  assert.equal! result, 1

  # <MIN 1.0>
  result = zil_context.globals[:MIN].call [1.0], zil_context
  assert.equal! result, 1.0

  # <MIN 2 3>
  result = zil_context.globals[:MIN].call [2, 3], zil_context
  assert.equal! result, 2

  # <MIN 2.0 3>
  result = zil_context.globals[:MIN].call [2.0, 3], zil_context
  assert.equal! result, 2.0

  # <MIN 3 4 <MIN 5 6.0>>
  result = zil_context.globals[:MIN].call [3, 4.0, Syntax::Form.new(:MIN, 5, 6.0)], zil_context
  assert.equal! result, 3

  # <MIN>
  zil_context.globals[:MIN].call [], zil_context
  raise 'No exception occurred when invoking MIN with no arguments!'
rescue FunctionError
  assert.ok!
end

def test_builtin_random(args, assert)
  zil_context = build_zil_context(args)

  # <RANDOM 1>
  result = zil_context.globals[:RANDOM].call [1], zil_context
  assert.true! result == 0

  # <RANDOM 2>
  result = zil_context.globals[:RANDOM].call [2], zil_context
  assert.true! result >= 0 && result <= 1

  # <RANDOM 3>
  result = zil_context.globals[:RANDOM].call [3], zil_context
  assert.true! result >= 0 && result <= 2

  # <RANDOM>
  zil_context.globals[:RANDOM].call [], zil_context
  raise 'No exception occurred when invoking RANDOM with no arguments!'
rescue FunctionError
  assert.ok!

  # <RANDOM>
  zil_context.globals[:RANDOM].call [1, 2], zil_context
  raise 'No exception occurred when invoking RANDOM with more than one argument!'
rescue FunctionError
  assert.ok!
end
