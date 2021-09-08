def eval_zil(expression, zil_context)
  case expression
  when Numeric, String, Symbol
    expression
  when Syntax::Form
    func_atom = expression.elements.first
    func_args = expression.elements.drop(1)
    function = zil_context.globals[func_atom]
    function.call(func_args, zil_context)
  end
end
