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
