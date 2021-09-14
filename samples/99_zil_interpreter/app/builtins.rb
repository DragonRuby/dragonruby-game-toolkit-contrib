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
ZIL_BUILTINS[:-] = define_for_evaled_arguments { |arguments|
  if arguments.length == 0
    0
  elsif arguments.length == 1
    0 - arguments[0]
  else
    arguments.inject(:-)
  end
}

# <* ...>
ZIL_BUILTINS[:*] = define_for_evaled_arguments { |arguments|
  arguments.inject(1, :*)
}

# </ ...>
ZIL_BUILTINS[:/] = define_for_evaled_arguments { |arguments|
  # https://mdl-language.readthedocs.io/en/latest/03-built-in-functions/
  # "the division of two FIXes gives a FIX with truncation, not rounding, of the remainder:
  # the intermediate result remains a FIX until a FLOAT argument is encountered."

  if arguments.length == 0 # </ >
    1
  elsif arguments.length == 1 # </ divisor>
    dividend = 1
    divisor = arguments[0]
    if divisor.class == Float
      dividend.to_f / divisor
    else
      (dividend / divisor).to_i
    end
  else  # </ dividend divisor ...>
    i = 1
    dividend = arguments[0]

    while i < arguments.length
      divisor = arguments[i]

      if dividend.class == Float || divisor.class == Float
        dividend = dividend.to_f / divisor.to_f
      else
        dividend = (dividend / divisor).to_i
      end

      i += 1
    end

    dividend
  end
}

# <MIN ...>
ZIL_BUILTINS[:MIN] = define_for_evaled_arguments { |arguments|
  raise FunctionError, "MIN with 0 arguments not supported" if arguments.length == 0
  arguments.min
}

# <RANDOM ...>
ZIL_BUILTINS[:RANDOM] = define_for_evaled_arguments { |arguments|
  raise FunctionError, "RANDOM only supported with 1 argument!" if arguments.length != 1
  range = arguments[0]
  rand(range)
}
