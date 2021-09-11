class FunctionError < StandardError; end

def define_for_evaled_args(&implementation)
  lambda { |args, context|
    evaled_args = args.map { |arg| eval_zil arg, context }
    implementation.call(evaled_args, context)
  }
end

ZIL_BUILTINS = {}

ZIL_BUILTINS[:LVAL] = define_for_evaled_args { |args, context|
  var_atom = args[0]
  raise FunctionError, "No local value for #{var_atom.inspect}" unless context.locals.key? var_atom

  context.locals[var_atom]
}
