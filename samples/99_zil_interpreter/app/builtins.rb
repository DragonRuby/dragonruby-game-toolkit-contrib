class FunctionError < StandardError; end

ZIL_BUILTINS = {}

ZIL_BUILTINS[:LVAL] = lambda { |args, context|
  var_atom = eval_zil args[0], context
  raise FunctionError, "No local value for #{var_atom}" unless context.locals.key? var_atom

  context.locals[var_atom]
}
