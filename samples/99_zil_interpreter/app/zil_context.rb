def build_zil_context(args)
  args.state.new_entity_strict(
    :zil_context,
    globals: {},
    locals: {},
  )
end

