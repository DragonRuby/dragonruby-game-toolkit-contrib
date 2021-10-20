module ZIL
  class Routine
    def initialize(name, signature, body, debug_flag: false)
      @debug_flag = debug_flag
      log "[ROUTINE.INIT  ]      name = " + name.to_s if @debug_flag
      log "[ROUTINE.INIT  ] signature = " + signature.to_s if @debug_flag
      log "[ROUTINE.INIT  ]      body = " + body.to_s if @debug_flag

      @name = name # for debugging, it will be nice to know who we are

      # signature tells us about the arguments we will receive:
        # MDL argument keywords not in use in ZIL: "CALL", "BIND", "NAME", "ACT", "OPT", "EXTRA"
          # "OPTIONAL" - NAME1 or (NAME1 DEFAULT1) = optional values and their default if they are not included
          # "AUX"      - NAME1 or (NAME1 DEFAULT1) = set up local variables to be used in function
          # "ARGS"     - used wholly with DEFMAC
          # "TUPLE"    - zork3 only (not implemented)
          # Quoted Arguments - REQUIRED or OPTIONAL ATOM's only

      # body tells us all of the statements we will execute
      # (first line may be #DECL, which gives us information about our signature data types)
      @body = body

      begin
        @arguments = Routine.parse_signature(signature)
        @num_required_arguments = @arguments.count { |argument| argument[:arg_type] == :REQUIRED }
      rescue FunctionError => error
        raise FunctionError, "#{@name}() - #{error}"
      end
    end

    def self.parse_signature(signature)
      arg_type = :REQUIRED
      arguments = []

      signature.elements.each do |argument|
        quoted = argument.class == Syntax::Quote
        if argument == 'OPTIONAL'
          raise FunctionError, 'OPTIONAL keyword appears in wrong position, must follow REQUIRED arguments' unless arg_type == :REQUIRED
          arg_type = :OPTIONAL
        elsif argument == 'AUX'
          raise FunctionError, 'AUX keyword appears in wrong position, must follow REQUIRED or OPTIONAL arguments' unless arg_type == :REQUIRED || arg_type == :OPTIONAL
          arg_type = :AUX
        elsif argument == 'ARGS'
          raise FunctionError, 'ARGS used with DEFMAC: to be implemented with DEFMAC feature!'
        elsif argument == 'TUPLE'
          raise FunctionError, 'TUPLE keyword is for the future: to be implemented for Zork III support!'
        elsif arg_type == :REQUIRED
          arg_data = quoted ? argument.element : argument
          arguments << {arg_type: arg_type, arg_data: arg_data, arg_quoted: quoted}
        elsif arg_type == :OPTIONAL
          raise FunctionError, 'OPTIONAL list argument ' + argument.to_s + ' must have two elements!' if argument.class == Syntax::List && argument.elements.length != 2
          arg_data = quoted ? argument.element : argument
          arguments << {arg_type: arg_type, arg_data: arg_data, arg_quoted: quoted}
        elsif arg_type == :AUX
          raise FunctionError, 'AUX list argument ' + argument.to_s + ' must have two elements!' if argument.class == Syntax::List && argument.elements.length != 2
          arg_data = argument
          arguments << {arg_type: arg_type, arg_data: arg_data, arg_quoted: quoted}
        else
          raise FunctionError, 'Unsupported signature at ' + argument.to_s + '!'
        end
      end

      arguments
    end

    def indent(width) # debugging only, put spaces based on stack level
      str = ""
      width.times do str += "  " end
      str
    end

    def call(args, zil_context)
      log "[ROUTINE.CALL  ] " + indent(zil_context.call_stack.length) + @name.to_s + " " + args.to_s + " {" if @debug_flag

      # make sure we got enough parameters to fulfil our requirements
      raise FunctionError, "Not enough arguments for #{@name}! (required: #{@num_required_arguments}, received: #{args.length})" if args.length < @num_required_arguments

      result = nil
      begin
        # Push current locals onto stack
        zil_context.call_stack.push([@name, args]) # this will be convenient to track nesting (and possibly debug deep procedure calls)
        zil_context.locals_stack.push zil_context.locals

        # Create new stack
        zil_context.locals = {}

        # Load function argument values onto new stack
        process_arguments_onto_stack args, zil_context

        # Eval body
        begin
          @body.each do |statement|
            result = eval_zil(statement, zil_context)
          end
        rescue AgainException
          retry
        end
      #rescue
      #Future: Handle AgainException, ReturnException
      ensure
        # Always pop stack
        zil_context.locals = zil_context.locals_stack.pop
        zil_context.call_stack.pop
      end

      log "[ROUTINE.RESULT] " + indent(zil_context.call_stack.length) + "} = " + result.to_s if @debug_flag
      result
    end

    def process_arguments_onto_stack(args, zil_context)
      num_processed = 0
      @arguments.each_with_index do |argument, i|
        log "[ROUTINE.CALL  ] " + indent(zil_context.call_stack.length) + argument.to_s if @debug_flag

        if argument[:arg_type] == :REQUIRED
          value = argument[:arg_quoted] ? args[i] : eval_zil(args[i], zil_context)
          zil_context.locals[argument[:arg_data]] = value
          log "[ROUTINE.CALL  ] " + indent(zil_context.call_stack.length) + "  " + value.to_s if @debug_flag
          num_processed += 1
        elsif argument[:arg_type] == :OPTIONAL
          provided = i < args.length
          arg_data = argument[:arg_data]
          if arg_data.class == Syntax::List
            arg_name, default_value_expression = arg_data.elements
            value = eval_zil(provided ? args[i] : default_value_expression, zil_context)
            zil_context.locals[arg_name] = value
            num_processed += 1
          else
            if provided
              # if provided, eval and add to stack
              value = argument[:arg_quoted] ? args[i] : eval_zil(args[i], zil_context)
              zil_context.locals[arg_data] = value
              num_processed += 1
            else
              # if NOT provided, do nothing (variable is unbound)
              num_processed += 1
            end
          end
        elsif argument[:arg_type] == :AUX # everything in AUX is EVAL'ed, AUX can use other AUX values left to right
          arg_data = argument[:arg_data]
          if arg_data.class == Syntax::List
            value = eval_zil(arg_data.elements[1], zil_context)
            zil_context.locals[arg_data.elements[0]] = value
          else
            # if stand alone AUX parameter, do nothing (variable is unbound)
          end
        else
          raise FunctionError, "Unknown arg_type #{argument[:arg_type]}!"
        end
      end

      raise FunctionError, "Too many arguments for #{@name}! (processed: #{num_processed}, received: #{args.length})" if num_processed < args.length
    end
  end
end
