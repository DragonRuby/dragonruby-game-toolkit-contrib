# Fallback implementation that starts REPL
ZIL_BUILTINS[:GO] = define_for_evaled_arguments { |_, context|
  context.globals[:REPL].call [], context
}

ZIL_BUILTINS[:REPL] = define_for_evaled_arguments { |_, context|
  loop do
    input = Fiber.yield
    begin
      parsed = Parser.parse_string(input)[0]
    rescue RuntimeError => e
      context.outputs << "ParserError: #{e}"
      next
    end
    result = eval_zil(parsed, context)
    context.outputs << "-> #{result}"
  end
}
