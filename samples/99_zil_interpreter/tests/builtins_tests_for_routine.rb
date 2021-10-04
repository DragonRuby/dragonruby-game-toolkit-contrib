require 'tests/test_helpers.rb'

def test_builtin_routine_basics(args, assert)
  zil_context = build_zil_context(args)
  zil_context.locals[:TEST_VAR] = "TEST_VAR"

  begin
    # <ROUTINE TEST>
    call_routine zil_context, :ROUTINE, [:TEST]
    raise 'ROUTINE with no argument list or body!'
  rescue FunctionError
    assert.ok!
  end

  begin
    # <ROUTINE TEST T>
    call_routine zil_context, :ROUTINE, [:TEST, :T]
    raise 'ROUTINE with no argument list!'
  rescue FunctionError
    assert.ok!
  end

  begin
    # <ROUTINE TEST ()>
    signature = list
    call_routine zil_context, :ROUTINE, [:TEST, signature]
    raise 'ROUTINE with no body!'
  rescue FunctionError
    assert.ok!
  end

  # <ROUTINE TEST () T>
  signature = list
  statements = [:T]
  call_routine zil_context, :ROUTINE, [:TEST, signature, *statements]
  result = call_routine zil_context, :TEST, []
  assert.equal! result, true, 'Expected true!'

  # execute again
  result = call_routine zil_context, :TEST, []
  assert.equal! result, true, 'Expected true! (2)'

  # <ROUTINE TEST () <NOT T>>
  signature = list
  statements = [form(:NOT, :T)]
  call_routine zil_context, :ROUTINE, [:TEST, signature, *statements]
  result = call_routine zil_context, :TEST, []
  assert.equal! result, false, 'Expected false!'

  # execute again
  result = call_routine zil_context, :TEST, []
  assert.equal! result, false, 'Expected false! (2)'
end

def test_builtin_routine_stack(args, assert)
  zil_context = build_zil_context(args)
  zil_context.locals[:TEST_VAR] = "TEST_VAR"

  # <ROUTINE TEST () T>
  signature = list
  statements = [:T]
  call_routine zil_context, :ROUTINE, [:TEST, signature, *statements]
  call_routine zil_context, :TEST, []

  # locals stack is manipulated when we invoke TEST, make sure locals is still intact
  assert.equal! zil_context.locals[:TEST_VAR], "TEST_VAR", 'Stack is corrupt!'
end

def test_builtin_routine_invalid1(args, assert)
  zil_context = build_zil_context(args)

  # define: <ROUTINE SUM (V1 V2) <+ .V1 .V2>>
  signature = list(:V1, :V2)
  statements = [form(:+, form(:LVAL, :V1), form(:LVAL, :V2))]
  call_routine zil_context, :ROUTINE, [:SUM, signature, *statements]

  begin
    # invoke: <SUM 1> [NOT ENOUGH PARAMETERS]
    call_routine zil_context, :SUM, [1]
    raise 'SUM does not have enough arguments!'
  rescue FunctionError
    assert.ok!
  end

  begin
    # invoke: <SUM 1 2 3> [TOO MANY PARAMETERS]
    call_routine zil_context, :SUM, [1, 2, 3]
    raise 'SUM has too many parameters!'
  rescue FunctionError
    assert.ok!
  end
end

def test_builtin_routine_invalid2(args, assert)
  zil_context = build_zil_context(args)

  # define: <ROUTINE TEST (P1 "AUX" P2 "OPTIONAL" P3) <>>
  begin
    signature = list(:P1, "AUX", :P2, "OPTIONAL", :P3)
    statements = [form]
    call_routine zil_context, :ROUTINE, [:TEST, signature, *statements]
    raise 'AUX cannot precede OPTIONAL!'
  rescue FunctionError
    assert.ok!
  end
end

def test_builtin_routine_invalid3(args, assert)
  zil_context = build_zil_context(args)

  # define: <ROUTINE TEST (P1 "OPTIONAL" (P2)) T>
  begin
    signature = list(:P1, "OPTIONAL", list(:P2))
    statements = [:T]
    call_routine zil_context, :ROUTINE, [:TEST, signature, *statements]
    raise 'P2 List must have addl. item!'
  rescue FunctionError
    assert.ok!
  end

  # define: <ROUTINE TEST (P1 "OPTIONAL" (P2 <> <>)) T>
  begin
    signature = list(:P1, "OPTIONAL", list(:P2, form , form))
    statements = [:T]
    call_routine zil_context, :ROUTINE, [:TEST, signature, *statements]
    raise 'P2 List has too many items!'
  rescue FunctionError
    assert.ok!
  end
end

def test_builtin_routine_simple(args, assert)
  zil_context = build_zil_context(args)

  # define: <ROUTINE SUM (V1 V2) <+ .V1 .V2>>
  signature = list(:V1, :V2)
  statements = [form(:+, form(:LVAL, :V1), form(:LVAL, :V2))]
  call_routine zil_context, :ROUTINE, [:SUM, signature, *statements]

  # invoke: <SUM 1 2>
  result = call_routine zil_context, :SUM, [1, 2]
  assert.equal! result, 3, 'Error when literals passed to SUM!'

  zil_context.locals[:P1] = 1
  zil_context.locals[:P2] = 2
  zil_context.locals[:P3] = 3
  zil_context.locals[:P4] = 4

  # invoke: <SUM .P1 .P2>
  result = call_routine zil_context, :SUM, [form(:LVAL, :P1), form(:LVAL, :P2)]
  assert.equal! result, 3, 'Error when local variables passed to SUM!'

  # invoke: <SUM <SUM .P1 .P2> <SUM .P3 .P4>>>
  result = call_routine zil_context, :SUM, [form(:SUM, form(:LVAL, :P1), form(:LVAL, :P2)), form(:SUM, form(:LVAL, :P3), form(:LVAL, :P4))]
  assert.equal! result, 10, 'Error when nesting calls to SUM!'

  zil_context.globals[:P1] = 11
  zil_context.globals[:P2] = 12

  # invoke: <SUM ,P1 ,P2>
  result = call_routine zil_context, :SUM, [form(:GVAL, :P1), form(:GVAL, :P2)]
  assert.equal! result, 23, 'Error when global values used in SUM!'
end

def test_builtin_routine_optional_atom(args, assert)
  zil_context = build_zil_context(args)
  zil_context.locals[:P1] = 1
  zil_context.locals[:P2] = 2
  zil_context.locals[:P3] = 3

  # define: <ROUTINE TEST1 (V1 V2 "OPTIONAL" V3) <ASSIGNED? V3>>
  signature = list(:V1, :V2, "OPTIONAL", :V3)
  statements = [form(:ASSIGNED?, :V3)]
  call_routine zil_context, :ROUTINE, [:TEST1, signature, *statements]

  # invoke: <TEST1 .P1 .P2>
  result = call_routine zil_context, :TEST1, [form(:LVAL, :P1), form(:LVAL, :P2)]
  assert.equal! result, false, 'OPTIONAL V3 not assigned!'

  # define: <ROUTINE TEST2 (V1 V2 "OPTIONAL" V3) .V3>
  signature = list(:V1, :V2, "OPTIONAL", :V3)
  statements = [form(:LVAL, :V3)]
  call_routine zil_context, :ROUTINE, [:TEST2, signature, *statements]

  # invoke: <TEST2 .P1 .P2>
  begin
    call_routine zil_context, :TEST2, [form(:LVAL, :P1), form(:LVAL, :P2)] # Exception: no value supplied for V3 ATOM (cannot LVAL unbound ATOM)
    raise 'TEST2 evals unbound optional parameter!'
  rescue FunctionError
    assert.ok!
  end

  # invoke: <TEST2 .P1 .P2 .P3>
  result = call_routine zil_context, :TEST2, [form(:LVAL, :P1), form(:LVAL, :P2), form(:LVAL, :P3)]
  assert.equal! result, 3, 'TEST2 should return LVAL of P3!'
end

def test_builtin_routine_optional_list(args, assert)
  zil_context = build_zil_context(args)
  zil_context.locals[:P1] = 1
  zil_context.locals[:P2] = 2

  # define: <ROUTINE TEST1 (V1 "OPTIONAL" (V2 <>)) .V2>
  signature = list(:V1, "OPTIONAL", list(:V2, form))
  statements = [form(:LVAL, :V2)]
  call_routine zil_context, :ROUTINE, [:TEST1, signature, *statements]

  result = call_routine zil_context, :TEST1, [form(:LVAL, :P1), form(:LVAL, :P2)] # we provided P2, so LVAL of P2 is returned
  assert.equal! result, 2, 'TEST1 should return LVAL of P2!'

  result = call_routine zil_context, :TEST1, [form(:LVAL, :P1)] # we provided no optional value so empty form is returned
  assert.equal! result, false, 'TEST1 should return <>!'
end

def test_builtin_routine_with_quoted(args, assert)
  zil_context = build_zil_context(args)

  # define: <ROUTINE Q1 ('A) .A>
  signature = list(quote(:A))
  statements = [form(:LVAL, :A)]
  call_routine zil_context, :ROUTINE, [:Q1, signature, *statements]

  result = call_routine zil_context, :Q1, [form(:+, 1, 2)]
  assert.equal! result, form(:+, 1, 2), 'Q1 should not eval parameter A!'

  # define: <ROUTINE Q2 ("OPTIONAL" 'A) .A>
  signature = list("OPTIONAL", quote(:A))
  statements = [form(:LVAL, :A)]
  call_routine zil_context, :ROUTINE, [:Q2, signature, *statements]

  result = call_routine zil_context, :Q2, [form(:+, 3, 4)]
  assert.equal! result, form(:+, 3, 4), 'Q2 should not eval parameter A!'

  # choosing not to implement - not observed in ZIL code ==> define: <ROUTINE Q3 ("OPTIONAL" ('A <+ 1 2>)) .A>
end

def test_builtin_routine_aux(args, assert)
  zil_context = build_zil_context(args)

  # define: <ROUTINE AUX1 ("AUX" A1) <ASSIGNED? A1>>
  signature = list("AUX", :A1)
  statements = [form(:ASSIGNED?, :A1)]
  call_routine zil_context, :ROUTINE, [:AUX1, signature, *statements]

  # invoke: <AUX1>
  result = call_routine zil_context, :AUX1, []
  assert.equal! result, false, 'AUX A1 should not be assigned!'

  # define: <ROUTINE AUX2 ("OPTIONAL" (OPT1 1) (OPT2 2) "AUX" (A1 <+ .OPT1 .OPT2)) .A1>
  signature = list("OPTIONAL", list(:OPT1, 1), list(:OPT2, 2), "AUX", list(:A1, form(:+, form(:LVAL, :OPT1), form(:LVAL, :OPT2))))
  statements = [form(:LVAL, :A1)]
  call_routine zil_context, :ROUTINE, [:AUX2, signature, *statements]

  # invoke: <AUX2>
  result = call_routine zil_context, :AUX2, []
  assert.equal! result, 3, 'AUX2 should return 3!'

  # invoke: <AUX2 11>
  result = call_routine zil_context, :AUX2, [11]
  assert.equal! result, 13, 'AUX2 should return 13!'

  # invoke: <AUX2 11 12>
  result = call_routine zil_context, :AUX2, [11, 12]
  assert.equal! result, 23, 'AUX2 should return 23!'
end
