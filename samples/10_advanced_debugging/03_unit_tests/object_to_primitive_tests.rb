class PlayerSpriteForTest
end

def test_array_to_sprite args, assert
  array = [[0, 0, 100, 100, "test.png"]].sprites
  puts "No exception was thrown. Sweet!"
end

def test_class_to_sprite args, assert
  array = [PlayerSprite.new].sprites
  assert.true! array.first.is_a?(PlayerSprite)
  puts "No exception was thrown. Sweet!"
end

$gtk.reset 100
$gtk.log_level = :off
