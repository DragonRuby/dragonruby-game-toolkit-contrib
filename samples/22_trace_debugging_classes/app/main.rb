class Foobar
  def initialize
    trace! # Trace is added to the constructor.
  end

  def clicky args
    return unless args.inputs.mouse.click
    try_rand rand
  end

  def try_rand num
    return if num < 0.9
    raise "Exception finally occurred. Take a look at logs/trace.txt #{num}."
  end
end

def tick args
  args.labels << [640, 360, "Start clicking. Eventually an exception will be thrown. Then look at logs/trace.txt.", 0, 1]
  args.state.foobar = Foobar.new if args.tick_count
  return unless args.state.foobar
  args.state.foobar.clicky args
end
