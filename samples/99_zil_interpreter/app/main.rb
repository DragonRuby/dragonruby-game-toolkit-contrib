require 'app/syntax.rb'
require 'app/parser.rb'
require 'app/builtins.rb'
require 'app/zil_repl.rb'
require 'app/zil_context.rb'
require 'app/eval.rb'

def tick(args)
  setup(args) if args.tick_count.zero?
end

def setup(args)
  args.state.zil_context = build_zil_context(args)
  $interpreter = Fiber.new {
    args.state.zil_context.globals[:GO].call [], args.state.zil_context
  }
  $interpreter.resume

  # Add other processing if necessary
end

# Call this method with the input after pressing enter
def send_input(args, input)
  $interpreter.resume input

  context = args.state.zil_context
  process_outputs(args, context.outputs)
  context.outputs.clear
end

def process_outputs(args, outputs)
  outputs.each do |line|
    puts line # Replace with actual processing, e.g. adding it to the history of output lines etc
  end
end
