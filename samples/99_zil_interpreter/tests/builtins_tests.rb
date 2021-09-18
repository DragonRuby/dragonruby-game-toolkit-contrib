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

  # </ 5.0>
  result = zil_context.globals[:/].call [5.0], zil_context
  assert.equal! result, 0.2

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
  results = 50.times.map { zil_context.globals[:RANDOM].call([1], zil_context) }
  assert.true! results.all? { |result| result == 1 }, '<RANDOM 1> returned a number other than 1'

  # <RANDOM 2>
  results = 50.times.map { zil_context.globals[:RANDOM].call([2], zil_context) }
  assert.true! results.all? { |result|  result >= 1 && result <= 2 }, '<RANDOM 2> returned a number less than 1 or greater than 2.'

  # <RANDOM 3>
  results = 50.times.map { zil_context.globals[:RANDOM].call([3], zil_context) }
  assert.true! results.all? { |result| result >= 1 && result <= 3 }, '<RANDOM 3> returned a number less than 1 or greater than 3.'

  # <RANDOM>
  begin
    zil_context.globals[:RANDOM].call [], zil_context
    raise 'No exception occurred when invoking RANDOM with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <RANDOM 1 2>
  begin
    zil_context.globals[:RANDOM].call [1, 2], zil_context
    raise 'No exception occurred when invoking RANDOM with more than one argument!'
  rescue FunctionError
    assert.ok!
  end
end

def test_builtin_mod(args, assert)
  zil_context = build_zil_context(args)

  # <MOD> !!
  begin
    zil_context.globals[:MOD].call [], zil_context
    raise 'No exception occurred when invoking MOD with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <MOD 1> !!
  begin
    zil_context.globals[:MOD].call [1], zil_context
    raise 'No exception occurred when invoking MOD one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <MOD 1 1.5> !!
  begin
    zil_context.globals[:MOD].call [1, 1.5], zil_context
    raise 'No exception occurred when invoking MOD with Float!'
  rescue FunctionError
    assert.ok!
  end

  # <MOD 5 2>
  result = zil_context.globals[:MOD].call [5, 2], zil_context
  assert.equal! result, 1

  # <MOD 20 7>
  result = zil_context.globals[:MOD].call [20, 7], zil_context
  assert.equal! result, 6
end

def test_builtin_0?(args, assert)
  zil_context = build_zil_context(args)

  # <0?> !!
  begin
    zil_context.globals[:"0?"].call [], zil_context
    raise 'No exception occurred when invoking "0?" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <0? 1 2> !!
  begin
    zil_context.globals[:"0?"].call [1, 2], zil_context
    raise 'No exception occurred when invoking "0?" more than one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <0? 0>
  result = zil_context.globals[:"0?"].call [0], zil_context
  assert.equal! result, true

  # <0? 0.0>
  result = zil_context.globals[:"0?"].call [0.0], zil_context
  assert.equal! result, true

  # <0? 1>
  result = zil_context.globals[:"0?"].call [1], zil_context
  assert.equal! result, false

  # <0? 1.0>
  result = zil_context.globals[:"0?"].call [1.0], zil_context
  assert.equal! result, false
end

def test_builtin_1?(args, assert)
  zil_context = build_zil_context(args)

  # <1?> !!
  begin
    zil_context.globals[:"1?"].call [], zil_context
    raise 'No exception occurred when invoking "1?" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <1? 1 2> !!
  begin
    zil_context.globals[:"1?"].call [1, 2], zil_context
    raise 'No exception occurred when invoking "1?" more than one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <1? 0>
  result = zil_context.globals[:"1?"].call [0], zil_context
  assert.equal! result, false

  # <1? 0.0>
  result = zil_context.globals[:"1?"].call [0.0], zil_context
  assert.equal! result, false

  # <1? 1>
  result = zil_context.globals[:"1?"].call [1], zil_context
  assert.equal! result, true

  # <1? 1.0>
  result = zil_context.globals[:"1?"].call [1.0], zil_context
  assert.equal! result, true
end

def test_builtin_greater(args, assert)
  zil_context = build_zil_context(args)

  # <G?> !!
  begin
    zil_context.globals[:G?].call [], zil_context
    raise 'No exception occurred when invoking "1?" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <G? 1> !!
  begin
    zil_context.globals[:G?].call [1], zil_context
    raise 'No exception occurred when invoking "1?" with one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <G? 0 0>
  result = zil_context.globals[:G?].call [0, 0], zil_context
  assert.equal! result, false

  # <G? 0 1>
  result = zil_context.globals[:G?].call [0, 1], zil_context
  assert.equal! result, false

  # <G? 1 0>
  result = zil_context.globals[:G?].call [1, 0], zil_context
  assert.equal! result, true
end

def test_builtin_less(args, assert)
  zil_context = build_zil_context(args)

  # <L?> !!
  begin
    zil_context.globals[:L?].call [], zil_context
    raise 'No exception occurred when invoking "1?" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <L? 1> !!
  begin
    zil_context.globals[:L?].call [1], zil_context
    raise 'No exception occurred when invoking "1?" with one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <L? 0 0>
  result = zil_context.globals[:L?].call [0, 0], zil_context
  assert.equal! result, false

  # <L? 0 1>
  result = zil_context.globals[:L?].call [0, 1], zil_context
  assert.equal! result, true

  # <L? 1 0>
  result = zil_context.globals[:L?].call [1, 0], zil_context
  assert.equal! result, false
end

def test_builtin_not(args, assert)
  zil_context = build_zil_context(args)

  # <NOT>
  begin
    zil_context.globals[:NOT].call [], zil_context
    raise 'No exception occurred when invoking "NOT" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <NOT T>
  result = zil_context.globals[:NOT].call [:T], zil_context
  assert.equal! result, false, '<NOT T>'

  # <NOT <NOT T>>
  result = zil_context.globals[:NOT].call [Syntax::Form.new(:NOT, :T)], zil_context
  assert.equal! result, true, '<NOT <NOT T>>'

  # <NOT <NOT NOT<T>>>
  result = zil_context.globals[:NOT].call [Syntax::Form.new(:NOT, Syntax::Form.new(:NOT, :T))], zil_context
  assert.equal! result, false, '<NOT <NOT NOT<T>>>'
end

def test_builtin_and(args, assert)
  zil_context = build_zil_context(args)

  # "Anything which is not FALSE, is, reasonably enough, true."
  # "If none of them evaluate to FALSE, it returns EVAL of its last argument."

  # <AND 0 0>
  result = zil_context.globals[:AND].call [0, 0], zil_context
  assert.equal! result, 0, '<AND 0 0> = 0'

  # <AND false 0>
  result = zil_context.globals[:AND].call [false, 0], zil_context
  assert.equal! result, false, '<AND false 0> = false'

  # <AND 0 false>
  result = zil_context.globals[:AND].call [0, false], zil_context
  assert.equal! result, false, '<AND 0 false> = false'

  # <AND "false" "false">
  result = zil_context.globals[:AND].call ["false", "false"], zil_context
  assert.equal! result, "false", '<AND "false" "false"> = "false"'

  # <AND <0? 0> <1? 1>>
  result = zil_context.globals[:AND].call [Syntax::Form.new(:"0?", 0), Syntax::Form.new(:"1?", 1)], zil_context
  assert.equal! result, true, '<AND <0? 0> <1? 1>> = true'

  # <AND <0? 1> <1? 1>>
  result = zil_context.globals[:AND].call [Syntax::Form.new(:"0?", 1), Syntax::Form.new(:"1?", 1)], zil_context
  assert.equal! result, false, '<AND <0? 1> <1? 1>> = false'
end

def test_builtin_and?(args, assert)
  zil_context = build_zil_context(args)

  # "Anything which is not FALSE, is, reasonably enough, true."
  # "If none of them evaluate to FALSE, it returns EVAL of its last argument."

  # this unit test would be a little better if we counted evals somewhere.
  # that way we could prove there more evals.

  # <AND? 0 0>
  result = zil_context.globals[:AND].call [0, 0], zil_context
  assert.equal! result, 0, '<AND? 0 0> = 0'

  # <AND? false 0>
  result = zil_context.globals[:AND].call [false, 0], zil_context
  assert.equal! result, false, '<AND? false 0> = false'

  # <AND? 0 false>
  result = zil_context.globals[:AND].call [0, false], zil_context
  assert.equal! result, false, '<AND? 0 false> = false'

  # <AND? "false" "false">
  result = zil_context.globals[:AND].call ["false", "false"], zil_context
  assert.equal! result, "false", '<AND? "false" "false"> = "false"'

  # <AND? <0? 0> <1? 1>>
  result = zil_context.globals[:AND].call [Syntax::Form.new(:"0?", 0), Syntax::Form.new(:"1?", 1)], zil_context
  assert.equal! result, true, '<AND? <0? 0> <1? 1>> = true'

  # <AND? <0? 1> <1? 1>>
  result = zil_context.globals[:AND].call [Syntax::Form.new(:"0?", 1), Syntax::Form.new(:"1?", 1)], zil_context
  assert.equal! result, false, '<AND? <0? 1> <1? 1>> = false'
end

def test_builtin_cond(args, assert)
  zil_context = build_zil_context(args)

  # <COND>
  begin
    zil_context.globals[:COND].call [], zil_context
    raise 'No exception occurred when invoking "COND" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <COND ()>
  begin
    clause1 = Syntax::List.new
    zil_context.globals[:COND].call [clause1], zil_context
    raise 'No exception occurred when invoking "COND" with empty clauses!'
  rescue FunctionError
    assert.ok!
  end

  # <COND (<0? 1>)> --> Nothing evals to true, so COND returns FALSE
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 1))
  result = zil_context.globals[:COND].call [clause1], zil_context
  assert.equal! result, false, '<COND (<0? 1>)> != false'

  # <COND (<0? 1>) (<0? 1>)> --> Nothing evals to true, so COND returns FALSE
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 1))
  clause2 = Syntax::List.new(Syntax::Form.new(:"0?", 1))
  result = zil_context.globals[:COND].call [clause1, clause2], zil_context
  assert.equal! result, false, '<COND (<0? 1>) (<0? 1>)> != false'

  # <COND (<0? 0>)> --> Evals to true, even though no elements in the clause are evaled
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 0))
  result = zil_context.globals[:COND].call [clause1], zil_context
  assert.equal! result, true, '<COND (<0? 0>)> == false'

  # Setup for next set of tests
  zil_context.locals[:VAR10] = 10
  zil_context.locals[:VAR20] = 20
  zil_context.locals[:VAR30] = 30
  zil_context.locals[:VAR_T] = true
  zil_context.locals[:VAR_F] = false

  # <COND (<0? 0> .VAR10 .VAR20)> --> Evals to 20
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 0), Syntax::Form.new(:LVAL, :VAR10), Syntax::Form.new(:LVAL, :VAR20))
  result = zil_context.globals[:COND].call [clause1], zil_context
  assert.equal! result, 20, 'Last element of clause should be returned! (20)'

  # <COND (<0? 0> .VAR10 .VAR20 .VAR10)> --> Evals to 10
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 0), Syntax::Form.new(:LVAL, :VAR10), Syntax::Form.new(:LVAL, :VAR20), Syntax::Form.new(:LVAL, :VAR10))
  result = zil_context.globals[:COND].call [clause1], zil_context
  assert.equal! result, 10, 'Last element of clause should be returned! (10)'

  # <COND (<0? 0> .VAR10 .VAR20 .VAR10 .VAR_F .VAR30)> --> Evals to false because :VAR_F is false
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 0), Syntax::Form.new(:LVAL, :VAR10), Syntax::Form.new(:LVAL, :VAR20), Syntax::Form.new(:LVAL, :VAR10), Syntax::Form.new(:LVAL, :VAR_F), Syntax::Form.new(:LVAL, :VAR30))
  result = zil_context.globals[:COND].call [clause1], zil_context
  assert.equal! result, 30, 'Last element of clause should be returned! (30)'

  # <COND (<0? 0> .VAR10 .VAR20 .VAR_F)> --> Evals to false because :VAR_F is false
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 0), Syntax::Form.new(:LVAL, :VAR10), Syntax::Form.new(:LVAL, :VAR20), Syntax::Form.new(:LVAL, :VAR10), Syntax::Form.new(:LVAL, :VAR_F))
  result = zil_context.globals[:COND].call [clause1], zil_context
  assert.equal! result, false, 'Last element of clause should be returned! (false)'

  # <COND (<0? 0> .VAR10) (<0? 0> .VAR20)> --> Evals to 10
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 0), Syntax::Form.new(:LVAL, :VAR10))
  clause2 = Syntax::List.new(Syntax::Form.new(:"0?", 0), Syntax::Form.new(:LVAL, :VAR20))
  result = zil_context.globals[:COND].call [clause1, clause2], zil_context
  assert.equal! result, 10, 'First cond should be evaled and returned'

  # <COND (<0? 1> .VAR10) (T .VAR20)> --> Evals to 20
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 1), Syntax::Form.new(:LVAL, :VAR10))
  clause2 = Syntax::List.new(:T, Syntax::Form.new(:LVAL, :VAR20))
  result = zil_context.globals[:COND].call [clause1, clause2], zil_context
  assert.equal! result, 20, 'Else T returns 20'

  # <COND (<0? 1> .VAR10) (<1? 0> .VAR20) (T .VAR30)> --> Evals to 30
  clause1 = Syntax::List.new(Syntax::Form.new(:"0?", 1), Syntax::Form.new(:LVAL, :VAR10))
  clause2 = Syntax::List.new(Syntax::Form.new(:"1?", 0), Syntax::Form.new(:LVAL, :VAR20))
  clause3 = Syntax::List.new(:T, Syntax::Form.new(:LVAL, :VAR30))
  result = zil_context.globals[:COND].call [clause1, clause2, clause3], zil_context
  assert.equal! result, 30, 'Else T returns 30'

  # <COND (.VAR_F .VAR10) (.VAR_T .VAR20)> --> Evals to 30
  clause1 = Syntax::List.new(Syntax::Form.new(:LVAL, :VAR_F), Syntax::Form.new(:LVAL, :VAR10))
  clause2 = Syntax::List.new(Syntax::Form.new(:LVAL, :VAR_T), Syntax::Form.new(:LVAL, :VAR20))
  result = zil_context.globals[:COND].call [clause1, clause2], zil_context
  assert.equal! result, 20, 'Else T returns 20 (2)'
end
