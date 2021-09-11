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

    begin
      result = eval_zil(parsed, context)
    rescue EvalError => e
      context.outputs << "EvalError: #{e}"
      next
    rescue FunctionError => e
      context.outputs << "FunctionError: #{e}"
      next
    end
    context.outputs << "-> #{result}"
  end
}
