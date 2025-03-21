# For advanced users:
# You can put some quick verification tests here, any method
# that starts with the `test_` will be run when you save this file.

# Here is an example test and game

# To run the test: ./dragonruby mygame --eval app/tests.rb --no-tick

class MySuperHappyFunGame
  attr_gtk

  def tick
    outputs.solids << [100, 100, 300, 300]
  end
end

def test_universe args, assert
  game = MySuperHappyFunGame.new
  game.args = args
  game.tick
  assert.true!  args.outputs.solids.length == 1, "failure: a solid was not added after tick"
  assert.false! 1 == 2, "failure: some how, 1 equals 2, the world is ending"
  puts "test_universe completed successfully"
end

puts "running tests"
GTK.reset 100
GTK.log_level = :off
GTK.tests.start
