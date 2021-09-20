require 'tests/test_helpers.rb'

def test_builtin_lval(args, assert)
  zil_context = build_zil_context(args)
  zil_context.locals[:"LOCAL-VAR"] = 22

  # <LVAL LOCAL-VAR>
  result = call_routine zil_context, :LVAL, [:"LOCAL-VAR"]

  assert.equal! result, 22

  # Evaluating argument first
  zil_context.locals[:VARNAME] = :"LOCAL-VAR"

  # <LVAL <LVAL VARNAME>>
  result = call_routine zil_context, :LVAL, [form(:LVAL, :VARNAME)]

  assert.equal! result, 22
end

def test_builtin_lval_raises_error_when_not_existing(args, assert)
  zil_context = build_zil_context(args)

  call_routine zil_context, :LVAL, [:"LOCAL-VAR"]
  raise 'No exception occurred'
rescue FunctionError
  assert.ok!
end

def test_builtin_plus(args, assert)
  zil_context = build_zil_context(args)

  # <+>
  result = call_routine zil_context, :+, []
  assert.equal! result, 0

  # <+ 5>
  result = call_routine zil_context, :+, [5]
  assert.equal! result, 5

  # <+ 1 2 <+ 3 4>>
  result = call_routine zil_context, :+, [1, 2, form(:+, 3, 4)]
  assert.equal! result, 10
end

def test_builtin_minus(args, assert)
  zil_context = build_zil_context(args)

  # <- 10 1 <- 5 1>>
  result = call_routine zil_context, :-, [10, 1, form(:-, 5, 1)]
  assert.equal! result, 5

  # <- 5>
  result = call_routine zil_context, :-, [5]
  assert.equal! result, -5

  # <- >
  result = call_routine zil_context, :-, []
  assert.equal! result, 0
end

def test_builtin_multiply(args, assert)
  zil_context = build_zil_context(args)

  # <* 1 5>
  result = call_routine zil_context, :*, [1, 5]
  assert.equal! result, 5

  # <* 1 5 <* 5 2>>
  result = call_routine zil_context, :*, [1, 5, form(:*, 5, 2)]
  assert.equal! result, 50

  # <* 1>
  result = call_routine zil_context, :*, []
  assert.equal! result, 1
end

def test_builtin_divide(args, assert)
  zil_context = build_zil_context(args)

  # </ 10 </ 50 10>>
  result = call_routine zil_context, :/, [10, form(:/, 50, 10)]
  assert.equal! result, 2

  # </ 10 2>
  result = call_routine zil_context, :/, [10, 2]
  assert.equal! result, 5

  # </ 5>
  result = call_routine zil_context, :/, [5]
  assert.equal! result, 0

  # </>
  result = call_routine zil_context, :/, []
  assert.equal! result, 1

  # </ 5.0>
  result = call_routine zil_context, :/, [5.0]
  assert.equal! result, 0.2

  # </ 1.5 0.5>
  result = call_routine zil_context, :/, [1.5, 0.5]
  assert.equal! result, 3.0

  # </ 11 7 2.0>
  result = call_routine zil_context, :/, [11, 7, 2.0]
  assert.equal! result, 0.5
end

def test_builtin_min(args, assert)
  zil_context = build_zil_context(args)

  # <MIN 1>
  result = call_routine zil_context, :MIN, [1]
  assert.equal! result, 1

  # <MIN 1.0>
  result = call_routine zil_context, :MIN, [1.0]
  assert.equal! result, 1.0

  # <MIN 2 3>
  result = call_routine zil_context, :MIN, [2, 3]
  assert.equal! result, 2

  # <MIN 2.0 3>
  result = call_routine zil_context, :MIN, [2.0, 3]
  assert.equal! result, 2.0

  # <MIN 3 4 <MIN 5 6.0>>
  result = call_routine zil_context, :MIN, [3, 4.0, form(:MIN, 5, 6.0)]
  assert.equal! result, 3

  # <MIN>
  call_routine zil_context, :MIN, []
  raise 'No exception occurred when invoking MIN with no arguments!'
rescue FunctionError
  assert.ok!
end

def test_builtin_random(args, assert)
  zil_context = build_zil_context(args)

  # <RANDOM 1>
  results = 50.times.map { call_routine zil_context, :RANDOM, [1] }
  assert.true! results.all? { |result| result == 1 }, '<RANDOM 1> returned a number other than 1'

  # <RANDOM 2>
  results = 50.times.map { call_routine zil_context, :RANDOM, [2] }
  assert.true! results.all? { |result|  result >= 1 && result <= 2 }, '<RANDOM 2> returned a number less than 1 or greater than 2.'

  # <RANDOM 3>
  results = 50.times.map { call_routine zil_context, :RANDOM, [3] }
  assert.true! results.all? { |result| result >= 1 && result <= 3 }, '<RANDOM 3> returned a number less than 1 or greater than 3.'

  # <RANDOM>
  begin
    call_routine zil_context, :RANDOM, []
    raise 'No exception occurred when invoking RANDOM with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <RANDOM 1 2>
  begin
    call_routine zil_context, :RANDOM, [1, 2]
    raise 'No exception occurred when invoking RANDOM with more than one argument!'
  rescue FunctionError
    assert.ok!
  end
end

def test_builtin_set(args, assert)
  zil_context = build_zil_context(args)
  zil_context.locals[:"LOCAL"] = 0

  result = call_routine zil_context, :SET, [:LOCAL, 5]

  assert.equal! zil_context.locals[:LOCAL], 5
  assert.equal! result, 5
end

def test_builtin_setg(args, assert)
  zil_context = build_zil_context(args)
  result = call_routine zil_context, :SETG, [:GLOBAL, 12]

  assert.equal! zil_context.globals[:GLOBAL], 12
  assert.equal! result, 12
end

def test_builtin_band(args, assert)
  zil_context = build_zil_context(args)
  result = zil_context.globals[:BAND].call [61, 31], nil
  assert.equal!(result, 61 & 31)
end

def test_builtin_bor(args, assert)
  zil_context = build_zil_context(args)
  result = zil_context.globals[:BOR].call [1, 128], nil

  assert.equal!(result, 1 | 128)
end

def test_builtin_btst(args, assert)
  zil_context = build_zil_context(args)
  result = zil_context.globals[:BTST].call [128, 128], nil

  assert.true! result
  
  result = zil_context.globals[:BTST].call [127, 128], nil

  assert.false! result
end

def test_builtin_bcom(args, assert)
  zil_context = build_zil_context(args)
  result = zil_context.globals[:BCOM].call [128], nil

  assert.equal! result, ~128
end

def test_builtin_shift(args, assert)
  zil_context = build_zil_context(args)
  result = zil_context.globals[:SHIFT].call [1, 10], nil

  assert.equal! result, 1024

  result = zil_context.globals[:SHIFT].call [256, -3], nil

  assert.equal! result, 32
end

def test_builtin_mod(args, assert)
  zil_context = build_zil_context(args)

  # <MOD> !!
  begin
    call_routine zil_context, :MOD, []
    raise 'No exception occurred when invoking MOD with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <MOD 1> !!
  begin
    call_routine zil_context, :MOD, [1]
    raise 'No exception occurred when invoking MOD one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <MOD 1 1.5> !!
  begin
    call_routine zil_context, :MOD, [1, 1.5]
    raise 'No exception occurred when invoking MOD with Float!'
  rescue FunctionError
    assert.ok!
  end

  # <MOD 5 2>
  result = call_routine zil_context, :MOD, [5, 2]
  assert.equal! result, 1

  # <MOD 20 7>
  result = call_routine zil_context, :MOD, [20, 7]
  assert.equal! result, 6
end

def test_builtin_0?(args, assert)
  zil_context = build_zil_context(args)

  # <0?> !!
  begin
    call_routine zil_context, :"0?", []
    raise 'No exception occurred when invoking "0?" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <0? 1 2> !!
  begin
    call_routine zil_context, :"0?", [1, 2]
    raise 'No exception occurred when invoking "0?" more than one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <0? 0>
  result = call_routine zil_context, :"0?", [0]
  assert.equal! result, true

  # <0? 0.0>
  result = call_routine zil_context, :"0?", [0.0]
  assert.equal! result, true

  # <0? 1>
  result = call_routine zil_context, :"0?", [1]
  assert.equal! result, false

  # <0? 1.0>
  result = call_routine zil_context, :"0?", [1.0]
  assert.equal! result, false
end

def test_builtin_1?(args, assert)
  zil_context = build_zil_context(args)

  # <1?> !!
  begin
    call_routine zil_context, :"1?", []
    raise 'No exception occurred when invoking "1?" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <1? 1 2> !!
  begin
    call_routine zil_context, :"1?", [1, 2]
    raise 'No exception occurred when invoking "1?" more than one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <1? 0>
  result = call_routine zil_context, :"1?", [0]
  assert.equal! result, false

  # <1? 0.0>
  result = call_routine zil_context, :"1?", [0.0]
  assert.equal! result, false

  # <1? 1>
  result = call_routine zil_context, :"1?", [1]
  assert.equal! result, true

  # <1? 1.0>
  result = call_routine zil_context, :"1?", [1.0]
  assert.equal! result, true
end

def test_builtin_greater(args, assert)
  zil_context = build_zil_context(args)

  # <G?> !!
  begin
    call_routine zil_context, :G?, []
    raise 'No exception occurred when invoking "1?" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <G? 1> !!
  begin
    call_routine zil_context, :G?, [1]
    raise 'No exception occurred when invoking "1?" with one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <G? 0 0>
  result = call_routine zil_context, :G?, [0, 0]
  assert.equal! result, false

  # <G? 0 1>
  result = call_routine zil_context, :G?, [0, 1]
  assert.equal! result, false

  # <G? 1 0>
  result = call_routine zil_context, :G?, [1, 0]
  assert.equal! result, true
end

def test_builtin_less(args, assert)
  zil_context = build_zil_context(args)

  # <L?> !!
  begin
    call_routine zil_context, :L?, []
    raise 'No exception occurred when invoking "1?" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <L? 1> !!
  begin
    call_routine zil_context, :L?, [1]
    raise 'No exception occurred when invoking "1?" with one argument!'
  rescue FunctionError
    assert.ok!
  end

  # <L? 0 0>
  result = call_routine zil_context, :L?, [0, 0]
  assert.equal! result, false

  # <L? 0 1>
  result = call_routine zil_context, :L?, [0, 1]
  assert.equal! result, true

  # <L? 1 0>
  result = call_routine zil_context, :L?, [1, 0]
  assert.equal! result, false
end

def test_builtin_not(args, assert)
  zil_context = build_zil_context(args)

  # <NOT>
  begin
    call_routine zil_context, :NOT, []
    raise 'No exception occurred when invoking "NOT" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <NOT T>
  result = call_routine zil_context, :NOT, [:T]
  assert.equal! result, false, '<NOT T>'

  # <NOT <NOT T>>
  result = call_routine zil_context, :NOT, [form(:NOT, :T)]
  assert.equal! result, true, '<NOT <NOT T>>'

  # <NOT <NOT NOT<T>>>
  result = call_routine zil_context, :NOT, [form(:NOT, form(:NOT, :T))]
  assert.equal! result, false, '<NOT <NOT NOT<T>>>'
end

def test_builtin_and(args, assert)
  zil_context = build_zil_context(args)

  # "Anything which is not FALSE, is, reasonably enough, true."
  # "If none of them evaluate to FALSE, it returns EVAL of its last argument."

  # <AND 0 0>
  result = call_routine zil_context, :AND, [0, 0]
  assert.equal! result, 0, '<AND 0 0> = 0'

  # <AND false 0>
  result = call_routine zil_context, :AND, [false, 0]
  assert.equal! result, false, '<AND false 0> = false'

  # <AND 0 false>
  result = call_routine zil_context, :AND, [0, false]
  assert.equal! result, false, '<AND 0 false> = false'

  # <AND "false" "false">
  result = call_routine zil_context, :AND, ["false", "false"]
  assert.equal! result, "false", '<AND "false" "false"> = "false"'

  # <AND <0? 0> <1? 1>>
  result = call_routine zil_context, :AND, [form(:"0?", 0), form(:"1?", 1)]
  assert.equal! result, true, '<AND <0? 0> <1? 1>> = true'

  # <AND <0? 1> <1? 1>>
  result = call_routine zil_context, :AND, [form(:"0?", 1), form(:"1?", 1)]
  assert.equal! result, false, '<AND <0? 1> <1? 1>> = false'
end

def test_builtin_and?(args, assert)
  zil_context = build_zil_context(args)

  # "Anything which is not FALSE, is, reasonably enough, true."
  # "If none of them evaluate to FALSE, it returns EVAL of its last argument."

  # this unit test would be a little better if we counted evals somewhere.
  # that way we could prove there more evals.

  # <AND? 0 0>
  result = call_routine zil_context, :AND, [0, 0]
  assert.equal! result, 0, '<AND? 0 0> = 0'

  # <AND? false 0>
  result = call_routine zil_context, :AND, [false, 0]
  assert.equal! result, false, '<AND? false 0> = false'

  # <AND? 0 false>
  result = call_routine zil_context, :AND, [0, false]
  assert.equal! result, false, '<AND? 0 false> = false'

  # <AND? "false" "false">
  result = call_routine zil_context, :AND, ["false", "false"]
  assert.equal! result, "false", '<AND? "false" "false"> = "false"'

  # <AND? <0? 0> <1? 1>>
  result = call_routine zil_context, :AND, [form(:"0?", 0), form(:"1?", 1)]
  assert.equal! result, true, '<AND? <0? 0> <1? 1>> = true'

  # <AND? <0? 1> <1? 1>>
  result = call_routine zil_context, :AND, [form(:"0?", 1), form(:"1?", 1)]
  assert.equal! result, false, '<AND? <0? 1> <1? 1>> = false'
end

def test_builtin_cond(args, assert)
  zil_context = build_zil_context(args)

  # <COND>
  begin
    call_routine zil_context, :COND, []
    raise 'No exception occurred when invoking "COND" with no arguments!'
  rescue FunctionError
    assert.ok!
  end

  # <COND ()>
  begin
    clause1 = list
    call_routine zil_context, :COND, [clause1]
    raise 'No exception occurred when invoking "COND" with empty clauses!'
  rescue FunctionError
    assert.ok!
  end

  # <COND (<0? 1>)> --> Nothing evals to true, so COND returns FALSE
  clause1 = list(form(:"0?", 1))
  result = call_routine zil_context, :COND, [clause1]
  assert.equal! result, false, '<COND (<0? 1>)> != false'

  # <COND (<0? 1>) (<0? 1>)> --> Nothing evals to true, so COND returns FALSE
  clause1 = list(form(:"0?", 1))
  clause2 = list(form(:"0?", 1))
  result = call_routine zil_context, :COND, [clause1, clause2]
  assert.equal! result, false, '<COND (<0? 1>) (<0? 1>)> != false'

  # <COND (<0? 0>)> --> Evals to true, even though no elements in the clause are evaled
  clause1 = list(form(:"0?", 0))
  result = call_routine zil_context, :COND, [clause1]
  assert.equal! result, true, '<COND (<0? 0>)> == false'

  # Setup for next set of tests
  zil_context.locals[:VAR10] = 10
  zil_context.locals[:VAR20] = 20
  zil_context.locals[:VAR30] = 30
  zil_context.locals[:VAR_T] = true
  zil_context.locals[:VAR_F] = false

  # <COND (<0? 0> .VAR10 .VAR20)> --> Evals to 20
  clause1 = list(form(:"0?", 0), form(:LVAL, :VAR10), form(:LVAL, :VAR20))
  result = call_routine zil_context, :COND, [clause1]
  assert.equal! result, 20, 'Last element of clause should be returned! (20)'

  # <COND (<0? 0> .VAR10 .VAR20 .VAR10)> --> Evals to 10
  clause1 = list(form(:"0?", 0), form(:LVAL, :VAR10), form(:LVAL, :VAR20), form(:LVAL, :VAR10))
  result = call_routine zil_context, :COND, [clause1]
  assert.equal! result, 10, 'Last element of clause should be returned! (10)'

  # <COND (<0? 0> .VAR10 .VAR20 .VAR10 .VAR_F .VAR30)> --> Evals to false because :VAR_F is false
  clause1 = list(form(:"0?", 0), form(:LVAL, :VAR10), form(:LVAL, :VAR20), form(:LVAL, :VAR10), form(:LVAL, :VAR_F), form(:LVAL, :VAR30))
  result = call_routine zil_context, :COND, [clause1]
  assert.equal! result, 30, 'Last element of clause should be returned! (30)'

  # <COND (<0? 0> .VAR10 .VAR20 .VAR_F)> --> Evals to false because :VAR_F is false
  clause1 = list(form(:"0?", 0), form(:LVAL, :VAR10), form(:LVAL, :VAR20), form(:LVAL, :VAR10), form(:LVAL, :VAR_F))
  result = call_routine zil_context, :COND, [clause1]
  assert.equal! result, false, 'Last element of clause should be returned! (false)'

  # <COND (<0? 0> .VAR10) (<0? 0> .VAR20)> --> Evals to 10
  clause1 = list(form(:"0?", 0), form(:LVAL, :VAR10))
  clause2 = list(form(:"0?", 0), form(:LVAL, :VAR20))
  result = call_routine zil_context, :COND, [clause1, clause2]
  assert.equal! result, 10, 'First cond should be evaled and returned'

  # <COND (<0? 1> .VAR10) (T .VAR20)> --> Evals to 20
  clause1 = list(form(:"0?", 1), form(:LVAL, :VAR10))
  clause2 = list(:T, form(:LVAL, :VAR20))
  result = call_routine zil_context, :COND, [clause1, clause2]
  assert.equal! result, 20, 'Else T returns 20'

  # <COND (<0? 1> .VAR10) (<1? 0> .VAR20) (T .VAR30)> --> Evals to 30
  clause1 = list(form(:"0?", 1), form(:LVAL, :VAR10))
  clause2 = list(form(:"1?", 0), form(:LVAL, :VAR20))
  clause3 = list(:T, form(:LVAL, :VAR30))
  result = call_routine zil_context, :COND, [clause1, clause2, clause3]
  assert.equal! result, 30, 'Else T returns 30'

  # <COND (.VAR_F .VAR10) (.VAR_T .VAR20)> --> Evals to 30
  clause1 = list(form(:LVAL, :VAR_F), form(:LVAL, :VAR10))
  clause2 = list(form(:LVAL, :VAR_T), form(:LVAL, :VAR20))
  result = call_routine zil_context, :COND, [clause1, clause2]
  assert.equal! result, 20, 'Else T returns 20 (2)'
end

def test_builtin_object(args, assert)
  zil_context = build_zil_context(args)

  # <OBJECT ROOM (HEIGHT 10)>
  specs = [:ROOM, list(:HEIGHT, 10)]
  result = call_routine zil_context, :OBJECT, specs
  assert.equal! zil_context.globals[:ROOM][:name], :ROOM, "Object's name should be ROOM"
  assert.equal! zil_context.globals[:ROOM][:properties][:HEIGHT], 10, "ROOM's HEIGHT should be 10"

end

def test_builtin_itable(args, assert)
  zil_context = build_zil_context(args)

  # <ITABLE 2 (LEXV) 0 #BYTE 1 #BYTE 2>
  result = call_routine zil_context, :ITABLE, [2, list(:LEXV), 0, byte(1), byte(2)]

  # LEXV table is prefixed with 2 bytes and has 4 byte records
  assert.equal! result, [
    2, 0, # Prefixed with record count and zero byte
    0, 0, 1, 2,
    0, 0, 1, 2
  ]

  # <ITABLE 3 (BYTE LENGTH) 8>
  result = call_routine zil_context, :ITABLE, [3, list(:BYTE, :LENGTH), 8]

  assert.equal! result, [
    3, # Prefixed with record count
    8, 8, 8
  ]
end

def test_builtin_table(args, assert)
  zil_context = build_zil_context(args)

  # <TABLE <> <> <> <>>
  result = call_routine zil_context, :TABLE, [form, form, form, form]

  assert.equal! result, [false, 0, false, 0, false, 0, false, 0]

  # <TABLE 8 #BYTE 2 #BYTE 5>
  result = call_routine zil_context, :TABLE, [8, byte(2), byte(5)]

  assert.equal! result, [8, 0, 2, 5]

  # <TABLE (LENGTH) 1 2 3>
  result = call_routine zil_context, :TABLE, [list(:LENGTH), 1, 2, 3]

  assert.equal! result, [3, 0, 1, 0, 2, 0, 3, 0]
end

def test_builtin_get(args, assert)
  zil_context = build_zil_context(args)

  zil_context.locals[:THETABLE] = [1, 0, 2, 0, 3, 0]
  # <GET ,THETABLE 2>
  result = call_routine zil_context, :GET, [form(:LVAL, :THETABLE), 2]

  assert.equal! result, 3
end
