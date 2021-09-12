def eval_zil(expression, zil_context)
  case expression
  when Numeric, String
    expression
  when Symbol
    return true if expression == :T

    expression
  when Syntax::Form
    return false if expression.elements.empty?

    func_atom = expression.elements.first
    func_args = expression.elements.drop(1)
    function = zil_context.globals[func_atom]
    raise EvalError, "Function #{func_atom} does not exist" unless function

    function.call(func_args, zil_context)
  when Syntax::List
    expression.elements.map { |element| eval_zil(element, zil_context) }
  when Syntax::Quote
    expression.element
  when Syntax::Comment
    nil
  else
    raise EvalError, "Cannot eval #{expression}"
  end
end

class EvalError < StandardError; end
