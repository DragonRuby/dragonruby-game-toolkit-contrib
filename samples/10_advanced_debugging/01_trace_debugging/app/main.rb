class Game
  attr_gtk

  def method1 num
    method2 num
  end

  def method2 num
    method3 num
  end

  def method3 num
    method4 num
  end

  def method4 num
    if num == 1
      puts "UNLUCKY #{num}."
      state.unlucky_count += 1
      if state.unlucky_count > 3
        raise "NAT 1 finally occurred. Check app/trace.txt for all method invocation history."
      end
    else
      puts "LUCKY #{num}."
    end
  end

  def tick
    state.roll_history ||= []
    state.roll_history << rand(20) + 1
    state.countdown ||= 600
    state.countdown  -= 1
    state.unlucky_count ||= 0
    outputs.labels << [640, 360, "A dice roll of 1 will cause an exception.", 0, 1]
    if state.countdown > 0
      outputs.labels << [640, 340, "Dice roll countdown: #{state.countdown}", 0, 1]
    else
      state.attempts ||= 0
      state.attempts  += 1
      outputs.labels << [640, 340, "ROLLING! #{state.attempts}", 0, 1]
    end
    return if state.countdown > 0
    method1 state.roll_history[-1]
  end
end

$game = Game.new

def tick args
  trace! $game # <------------------- TRACING ENABLED FOR THIS OBJECT
  $game.args = args
  $game.tick
end
