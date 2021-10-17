def build_zil_context(args)
  args.state.new_entity_strict(
    :zil_context,
    globals: {}.merge(ZIL_BUILTINS),
    locals: {},
    locals_stack: [],
    call_stack: [],
    outputs: []
  )
end

def get_local_from_context(context, var_atom, throw_flag: true)
  result = :ZIL_LOCAL_VALUE_NOT_ASSIGNED

  [context.locals, *context.locals_stack].each { |stack|
    if stack.key? var_atom
      result = stack[var_atom]
      break
    end
  }

  raise FunctionError, "No local value for #{var_atom.inspect}" if result == :ZIL_LOCAL_VALUE_NOT_ASSIGNED && throw_flag

  result
end
