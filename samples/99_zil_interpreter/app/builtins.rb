class FunctionError < StandardError; end

def define_for_evaled_arguments(&implementation)
  lambda { |arguments, context|
    evaled_arguments = arguments.map { |argument| eval_zil argument, context }
    implementation.call(evaled_arguments, context)
  }
end

ZIL_BUILTINS = {}

ZIL_BUILTINS[:LVAL] = define_for_evaled_arguments { |arguments, context|
  var_atom = arguments[0]
  raise FunctionError, "No local value for #{var_atom.inspect}" unless context.locals.key? var_atom

  context.locals[var_atom]
}

# <+ ...>
ZIL_BUILTINS[:+] = define_for_evaled_arguments { |arguments|
  arguments.inject(0, :+)
}

# <- ...>
ZIL_BUILTINS[:-] = lambda { |arguments, context|
  if arguments.length == 0
    result = 0
  elsif arguments.length == 1
    result = 0 - eval_zil(arguments[0], context)
  else
    i = 1
    result = eval_zil(arguments[0], context)
    while i < arguments.length
      result -= eval_zil(arguments[i], context)
      i += 1
    end
  end

  result
}

# <* ...>
ZIL_BUILTINS[:*] = lambda { |arguments, context|
  if arguments.length == 0
    result = 1
  elsif arguments.length == 1
    result = eval_zil(arguments[0], context)
  else
    i = 1
    result = eval_zil(arguments[0], context)
    while i < arguments.length
      result *= eval_zil(arguments[i], context)
      i += 1
    end
  end
  result
}

# </ ...>
ZIL_BUILTINS[:/] = lambda { |arguments, context|
  # https://mdl-language.readthedocs.io/en/latest/03-built-in-functions/
  # "the division of two FIXes gives a FIX with truncation, not rounding, of the remainder:
  # the intermediate result remains a FIX until a FLOAT argument is encountered."

  if arguments.length == 0 # </ >
    result = 1
  elsif arguments.length == 1 # </ divisor>
    dividend = 1
    divisor = eval_zil(arguments[0], context)

    if divisor.class == Float
      result = dividend.to_f / divisor
    else
      result = (dividend / divisor).to_i
    end
  else  # </ dividend divisor ...>
    i = 1
    dividend = eval_zil(arguments[0], context)
    while i < arguments.length
      divisor = eval_zil(arguments[i], context)

      if dividend.class == Float || divisor.class == Float
        dividend = dividend.to_f / divisor.to_f
      else
        dividend = (dividend / divisor).to_i
      end

      i += 1
    end

    result = dividend
  end

  result
}

# <MIN ...>
ZIL_BUILTINS[:MIN] = lambda { |arguments, context|
  if arguments.length == 0
    raise FunctionError, "MIN with 0 arguments not supported"
  elsif arguments.length == 1
    result = eval_zil(arguments[0], context)
  else
    result = eval_zil(arguments[0], context)
    i = 1
    while i < arguments.length
      new_value = eval_zil(arguments[i], context)
      result = [result, new_value].min
      i += 1
    end
  end

  result
}

# <RANDOM ...>
ZIL_BUILTINS[:RANDOM] = lambda { |arguments, context|
  raise FunctionError, "RANGE only supported with 1 argument!" if arguments.length != 1
  range = eval_zil(arguments[0], context)
  rand(range)
}
