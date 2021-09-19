def form(*elements)
  Syntax::Form.new(*elements)
end

def list(*elements)
  Syntax::List.new(*elements)
end

def call_routine(context, name, args)
  context.globals[name].call args, context
end
