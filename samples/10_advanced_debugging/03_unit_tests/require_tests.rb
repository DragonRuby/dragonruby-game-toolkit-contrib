def write_src path, src
  GTK.write_file path, src
end

write_src 'app/unit_testing_game.rb', <<-S
module UnitTesting
  class Game
  end
end
S

write_src 'lib/unit_testing_lib.rb', <<-S
module UnitTesting
  class Lib
  end
end
S

write_src 'app/nested/unit_testing_nested.rb', <<-S
module UnitTesting
  class Nested
  end
end
S

require 'app/unit_testing_game.rb'
require 'app/nested/unit_testing_nested.rb'
require 'lib/unit_testing_lib.rb'

def test_require args, assert
  UnitTesting::Game.new
  UnitTesting::Lib.new
  UnitTesting::Nested.new
  GTK.exec 'rm ./mygame/app/unit_testing_game.rb'
  GTK.exec 'rm ./mygame/app/nested/unit_testing_nested.rb'
  GTK.exec 'rm ./mygame/lib/unit_testing_lib.rb'
  assert.ok!
end
