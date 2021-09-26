require 'app/syntax.rb'
require 'app/parser.rb'
require 'app/builtins.rb'
require 'app/zil_repl.rb'
require 'app/zil_context.rb'
require 'app/eval.rb'

def tick(args)
  setup(args) if args.tick_count.zero?
  # TODO:
  # - Render history
  # - Collect input
  # - Call send_input with input when pressing Enter
  $gtk.request_quit unless $interpreter.alive?
end

def setup(args)
  context = build_zil_context(args)
  args.state.zil_context = context
  $interpreter = Fiber.new {
    context.globals[:GO].call [], context
  }
  $interpreter.resume # Initial processing until first Fiber.yield
  process_outputs args, context.outputs # Process welcome message if existing

  # TODO:
  # Add other setup if necessary
end

# Call this method with the input after pressing enter
def send_input(args, input)
  $interpreter.resume input

  context = args.state.zil_context
  process_outputs(args, context.outputs)
  context.outputs.clear
end

def process_outputs(args, outputs)
  # TODO:
  # Replace with actual processing, e.g. adding it to the history of output lines etc
  outputs.each do |line|
    puts line
  end
end
