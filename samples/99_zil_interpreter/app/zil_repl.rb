# Fallback implementation that starts REPL
ZIL_BUILTINS[:GO] = define_for_evaled_arguments { |_, context|
  context.globals[:REPL].call [], context
}

ZIL_BUILTINS[:REPL] = define_for_evaled_arguments { |_, context|
  loop do
    input = Fiber.yield
    parsed = Parser.parse_string(input)[0]
    result = eval_zil(parsed, context)
    context.outputs << "-> #{result}"
  rescue ParserError, EvalError, FunctionError => e
    context.outputs << "#{e.class}: #{e}"
    next
  end
}
