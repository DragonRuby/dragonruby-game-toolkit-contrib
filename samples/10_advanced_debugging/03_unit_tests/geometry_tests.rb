begin :shared
  def primitive_representations x, y, w, h
    [
      [x, y, w, h],
      { x: x, y: y, w: w, h: h },
      RectForTest.new(x, y, w, h)
    ]
  end

  class RectForTest
    attr_sprite

    def initialize x, y, w, h
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def to_s
      "RectForTest: #{[x, y, w, h]}"
    end
  end
end

begin :intersect_rect?
  def test_intersect_rect_point args, assert
    assert.true! [16, 13].intersect_rect?([13, 12, 4, 4]), "point intersects with rect."
  end

  def test_intersect_rect args, assert
    intersecting = primitive_representations(0, 0, 100, 100) +
                   primitive_representations(20, 20, 20, 20)

    intersecting.product(intersecting).each do |rect_one, rect_two|
      assert.true! rect_one.intersect_rect?(rect_two),
                   "intersect_rect? assertion failed for #{rect_one}, #{rect_two} (expected true)."
    end

    not_intersecting = [
      [ 0, 0, 5, 5],
      { x: 10, y: 10, w: 5, h: 5 },
      RectForTest.new(20, 20, 5, 5)
    ]

    not_intersecting.product(not_intersecting)
      .reject { |rect_one, rect_two| rect_one == rect_two }
      .each do |rect_one, rect_two|
      assert.false! rect_one.intersect_rect?(rect_two),
                    "intersect_rect? assertion failed for #{rect_one}, #{rect_two} (expected false)."
    end
  end
end

begin :inside_rect?
  def assert_inside_rect outer: nil, inner: nil, expected: nil, assert: nil
    assert.true! inner.inside_rect?(outer) == expected,
                 "inside_rect? assertion failed for outer: #{outer} inner: #{inner} (expected #{expected})."
  end

  def test_inside_rect args, assert
    outer_rects = primitive_representations(0, 0, 10, 10)
    inner_rects = primitive_representations(1, 1, 5, 5)
    primitive_representations(0, 0, 10, 10).product(primitive_representations(1, 1, 5, 5))
      .each do |outer, inner|
      assert_inside_rect outer: outer, inner: inner,
                         expected: true, assert: assert
    end
  end
end

begin :angle_to
  def test_angle_to args, assert
    origins = primitive_representations(0, 0, 0, 0)
    rights = primitive_representations(1, 0, 0, 0)
    aboves = primitive_representations(0, 1, 0, 0)

    origins.product(aboves).each do |origin, above|
      assert.equal! origin.angle_to(above), 90,
                    "A point directly above should be 90 degrees."

      assert.equal! above.angle_from(origin), 90,
                    "A point coming from above should be 90 degrees."
    end

    origins.product(rights).each do |origin, right|
      assert.equal! origin.angle_to(right) % 360, 0,
                    "A point directly to the right should be 0 degrees."

      assert.equal! right.angle_from(origin) % 360, 0,
                    "A point coming from the right should be 0 degrees."

    end
  end
end

begin :scale_rect
  def test_scale_rect args, assert
    assert.equal! [0, 0, 100, 100].scale_rect(0.5, 0.5),
                  [25.0, 25.0, 50.0, 50.0]

    assert.equal! [0, 0, 100, 100].scale_rect(0.5),
                  [0.0, 0.0, 50.0, 50.0]

    assert.equal! [0, 0, 100, 100].scale_rect_extended(percentage_x: 0.5, percentage_y: 0.5, anchor_x: 0.5, anchor_y: 0.5),
                  [25.0, 25.0, 50.0, 50.0]

    assert.equal! [0, 0, 100, 100].scale_rect_extended(percentage_x: 0.5, percentage_y: 0.5, anchor_x: 0, anchor_y: 0),
                  [0.0, 0.0, 50.0, 50.0]
  end
end

$gtk.reset 100
$gtk.log_level = :off
