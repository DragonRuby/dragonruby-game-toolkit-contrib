def form(*elements)
  Syntax::Form.new(*elements)
end

def list(*elements)
  Syntax::List.new(*elements)
end

def byte(element)
  Syntax::Byte.new element
end

def call_routine(context, name, args)
  context.globals[name].call args, context
end

def assert_raises_parser_error!(assert, source, assert_exception_text)
  exception_occurred = false

  begin
    Parser.parse_string(source)
  rescue
    exception_occurred = true
    assert.ok!
  end

  raise assert_exception_text unless exception_occurred
end

def assert_function_error_with_argument_counts!(context, routine_name, counts)
  counts.each do |argument_count|
    call_routine context, routine_name, ['an argument'] * argument_count
    raise "#{routine_name} did not raise FunctionError with #{argument_count} arguments"
  rescue FunctionError
    # Do nothing!
  end
end
