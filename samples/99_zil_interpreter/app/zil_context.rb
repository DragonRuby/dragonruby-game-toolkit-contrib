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
