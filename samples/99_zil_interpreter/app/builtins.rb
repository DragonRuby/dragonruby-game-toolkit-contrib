class FunctionError < StandardError; end

def define_for_evaled_arguments(&implementation)
  lambda { |arguments, context|
    evaled_arguments = arguments.map { |argument| eval_zil argument, context }
    implementation.call(evaled_arguments, context)
  }
end

ZIL_BUILTINS = {}

ZIL_BUILTINS[:LVAL] = define_for_evaled_arguments { |arguments, context|
  var_atom = arguments[0]
  raise FunctionError, "No local value for #{var_atom.inspect}" unless context.locals.key? var_atom

  context.locals[var_atom]
}

ZIL_BUILTINS[:+] = define_for_evaled_arguments { |arguments|
  arguments.inject(0, :+)
}
