class GeometryTests
  def test_find_collisions args, assert
    rects_1 = [
      { id: :a, x: 0, y: 0, w: 100, h: 100 },
      { id: :b, x: 0, y: 0, w: 25, h: 25 },
      { id: :c, x: 0, y: 0, w: 50, h: 50 },
    ]

    expected = [
      [:a, :c],
      [:b, :a],
      [:c, :a],
    ]

    collisions = Geometry.find_collisions(rects_1)

    collision_tuples = collisions.map do |k, v|
      [k.id, v.id]
    end

    collision_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end

    assert.equal! collision_tuples.length, expected.length
  end

  def test_find_collisions_two_collections_variant_1 args, assert
    rects_1 = [
      { id: :a, x: 0, y: 0, w: 100, h: 100 },
    ]

    rects_2 = [
      { id: :b, x: 0, y: 0, w: 25, h: 25 },
      { id: :c, x: 0, y: 0, w: 50, h: 50 },
    ]

    expected = [
      [:a, :c],
    ]

    actual = Geometry.find_collisions(rects_1, rects_2)

    actual_tuples = actual.map do |k, v|
      [k.id, v.id]
    end

    actual_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end

    assert.equal! actual.length, expected.length
  end

  def test_find_collisions_two_collections_variant_2 args, assert
    rects_1 = [
      { id: :a, x: 0, y: 0, w: 100, h: 100 },
    ]

    rects_2 = [
      { id: :b, x: 0, y: 0, w: 25, h: 25 },
      { id: :c, x: 0, y: 0, w: 50, h: 50 },
    ]

    expected = [
      [:b, :a],
      [:c, :a],
    ]

    actual = Geometry.find_collisions(rects_2, rects_1)

    actual_tuples = actual.map do |k, v|
      [k.id, v.id]
    end

    actual_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end

    assert.equal! actual.length, expected.length
  end

  def test_each_intersect_rect_simple args, assert
    rects_1 = [{ id: :a, x: 0, y: 0, w: 100, h: 100 }, { id: :b, x: 0, y: 0, w: 50, h: 50 }]
    rects_2 = [{ id: :c, x: 50, y: 50, w: 100, h: 100 }, { id: :d, x: 100, y: 100, w: 100, h: 100 }]
    collision_tuples = []
    expected = [
      [:a, :d],
      [:a, :c],
      [:b, :c]
    ]

    Geometry.each_intersect_rect(rects_1, rects_2) do |rect_1, rect_2|
      collision_tuples << [rect_1.id, rect_2.id]
    end

    collision_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end

    assert.equal! collision_tuples.length, expected.length
  end

  def test_each_intersect_rect_simple_single_collection args, assert
    rects_1 = [{ id: :a, x: 0, y: 0, w: 100, h: 100 }, { id: :b, x: 0, y: 0, w: 50, h: 50 }]
    collision_tuples = []
    expected = [
      [:a, :b],
      [:b, :a],
    ]

    Geometry.each_intersect_rect(rects_1) do |rect_1, rect_2|
      collision_tuples << [rect_1.id, rect_2.id]
    end

    collision_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end
  end

  def test_each_intersect_rect_simple_single_collection_using_proc args, assert
    rects_1 = [{ id: :a, x: 0, y: 0, w: 100, h: 100 }, { id: :b, x: 0, y: 0, w: 50, h: 50 }]
    collision_tuples = []
    expected = [
      [:a, :b],
      [:b, :a],
    ]

    Geometry.each_intersect_rect(rects_1, using: ->(o) { o }) do |rect_1, rect_2|
      collision_tuples << [rect_1.id, rect_2.id]
    end

    collision_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end
  end

  class Player
    attr :id, :x, :y, :w, :h

    def initialize id:, x:, y:, w:, h:;
      @id = id
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def box
      { x: @x, y: @y, w: @w, h: @h }
    end
  end

  class Bullet
    attr :id, :x, :y, :w, :h

    def initialize id:, x:, y:, w:, h:;
      @id = id
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def box
      { x: @x, y: @y, w: @w, h: @h }
    end
  end

  def test_each_intersect_rect_class args, assert
    players = [
      Player.new(id: :a, x: 0, y: 0, w: 100, h: 100),
      Player.new(id: :b, x: 0, y: 0, w: 50, h: 50)
    ]

    bullets = [
      Bullet.new(id: :c, x: 50, y: 50, w: 100, h: 100),
      Bullet.new(id: :d, x: 100, y: 100, w: 100, h: 100)
    ]

    collision_tuples = []

    expected = [
      [:a, :d],
      [:a, :c],
      [:b, :c]
    ]

    Geometry.each_intersect_rect(players, bullets) do |player, bullet|
      collision_tuples << [player.id, bullet.id]
    end

    collision_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end
  end

  def test_each_intersect_rect_class_using_symbol args, assert
    players = [
      Player.new(id: :a, x: 0, y: 0, w: 100, h: 100),
      Player.new(id: :b, x: 0, y: 0, w: 50, h: 50)
    ]

    bullets = [
      Bullet.new(id: :c, x: 50, y: 50, w: 100, h: 100),
      Bullet.new(id: :d, x: 100, y: 100, w: 100, h: 100)
    ]

    collision_tuples = []

    expected = [
      [:a, :d],
      [:a, :c],
      [:b, :c]
    ]

    Geometry.each_intersect_rect(players, bullets, using: :box) do |player, bullet|
      collision_tuples << [player.id, bullet.id]
    end

    collision_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end
  end

  def test_each_intersect_rect_class_using_proc args, assert
    players = [
      Player.new(id: :a, x: 0, y: 0, w: 100, h: 100),
      Player.new(id: :b, x: 0, y: 0, w: 50, h: 50)
    ]

    bullets = [
      Bullet.new(id: :c, x: 50, y: 50, w: 100, h: 100),
      Bullet.new(id: :d, x: 100, y: 100, w: 100, h: 100)
    ]

    collision_tuples = []

    expected = [
      [:a, :d],
      [:a, :c],
      [:b, :c]
    ]

    Geometry.each_intersect_rect(players, bullets, using: ->(o) { o.box }) do |player, bullet|
      collision_tuples << [player.id, bullet.id]
    end

    collision_tuples.each do |actual|
      assert.true! expected.include?(actual)
    end
  end
end
