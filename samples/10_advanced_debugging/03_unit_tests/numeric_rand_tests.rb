def test_randomize_int args, assert
  srand(100)
  assert.equal!(10.randomize(:ratio).round(5),         5.43405)
  assert.equal!(10.randomize(:ratio).round(5),         6.71156)
  assert.equal!(10.randomize(:ratio).round(5),         2.78369)
  assert.equal!(10.randomize(:ratio).round(5),         4.12046)
  assert.equal!(10.randomize(:sign),                   10)
  assert.equal!(10.randomize(:sign),                  -10)
  assert.equal!(10.randomize(:sign),                  -10)
  assert.equal!(10.randomize(:sign),                   10)
  assert.equal!(10.randomize(:ratio, :sign).round(5),  1.56711)
  assert.equal!(10.randomize(:ratio, :sign).round(5),  1.86467)
  assert.equal!(10.randomize(:ratio, :sign).round(5), -2.10108)
  assert.equal!(10.randomize(:ratio, :sign).round(5), -4.52740)
  assert.equal!(10.randomize(:int, :sign),             0)
  assert.equal!(10.randomize(:int, :sign),            -3)
  assert.equal!(10.randomize(:int, :sign),            -7)
  assert.equal!(10.randomize(:int, :sign),             6)
  assert.equal!(10.randomize(:int),                    0)
  assert.equal!(10.randomize(:int),                    1)
  assert.equal!(10.randomize(:int),                    9)
  assert.equal!(10.randomize(:int),                    9)
end

def test_randomize_float args, assert
  srand(100)
  assert.equal!(10.0.randomize(:ratio).round(5),         5.43405)
  assert.equal!(10.0.randomize(:ratio).round(5),         6.71156)
  assert.equal!(10.0.randomize(:ratio).round(5),         2.78369)
  assert.equal!(10.0.randomize(:ratio).round(5),         4.12046)
  assert.equal!(10.4.randomize(:sign),                   10.4)
  assert.equal!(10.4.randomize(:sign),                  -10.4)
  assert.equal!(10.4.randomize(:sign),                  -10.4)
  assert.equal!(10.4.randomize(:sign),                   10.4)
  assert.equal!(10.0.randomize(:ratio, :sign).round(5),  1.56711)
  assert.equal!(10.0.randomize(:ratio, :sign).round(5),  1.86467)
  assert.equal!(10.0.randomize(:ratio, :sign).round(5), -2.10108)
  assert.equal!(10.0.randomize(:ratio, :sign).round(5), -4.52740)
  assert.equal!(10.4.randomize(:int, :sign),             0)
  assert.equal!(10.4.randomize(:int, :sign),            -3)
  assert.equal!(10.4.randomize(:int, :sign),            -7)
  assert.equal!(10.4.randomize(:int, :sign),             6)
  assert.equal!(10.4.randomize(:int),                    0)
  assert.equal!(10.4.randomize(:int),                    1)
  assert.equal!(10.4.randomize(:int),                    9)
  assert.equal!(10.4.randomize(:int),                    9)
end

def test_ratio_float_alias args, assert
  srand(100)
  assert.equal!(10.0.randomize(:float).round(5),         5.43405)
  assert.equal!(10.0.randomize(:float).round(5),         6.71156)
  assert.equal!(10.0.randomize(:float).round(5),         2.78369)
  assert.equal!(10.0.randomize(:float).round(5),         4.12046)
  assert.equal!(10.4.randomize(:sign),                   10.4)
  assert.equal!(10.4.randomize(:sign),                  -10.4)
  assert.equal!(10.4.randomize(:sign),                  -10.4)
  assert.equal!(10.4.randomize(:sign),                   10.4)
  assert.equal!(10.0.randomize(:float, :sign).round(5),  1.56711)
  assert.equal!(10.0.randomize(:float, :sign).round(5),  1.86467)
  assert.equal!(10.0.randomize(:float, :sign).round(5), -2.10108)
  assert.equal!(10.0.randomize(:float, :sign).round(5), -4.52740)
  assert.equal!(10.4.randomize(:int, :sign),             0)
  assert.equal!(10.4.randomize(:int, :sign),            -3)
  assert.equal!(10.4.randomize(:int, :sign),            -7)
  assert.equal!(10.4.randomize(:int, :sign),             6)
  assert.equal!(10.4.randomize(:int),                    0)
  assert.equal!(10.4.randomize(:int),                    1)
  assert.equal!(10.4.randomize(:int),                    9)
  assert.equal!(10.4.randomize(:int),                    9)

  srand(100)
  assert.equal!(10.randomize(:float).round(5),         5.43405)
  assert.equal!(10.randomize(:float).round(5),         6.71156)
  assert.equal!(10.randomize(:float).round(5),         2.78369)
  assert.equal!(10.randomize(:float).round(5),         4.12046)
  assert.equal!(10.randomize(:sign),                   10)
  assert.equal!(10.randomize(:sign),                  -10)
  assert.equal!(10.randomize(:sign),                  -10)
  assert.equal!(10.randomize(:sign),                   10)
  assert.equal!(10.randomize(:float, :sign).round(5),  1.56711)
  assert.equal!(10.randomize(:float, :sign).round(5),  1.86467)
  assert.equal!(10.randomize(:float, :sign).round(5), -2.10108)
  assert.equal!(10.randomize(:float, :sign).round(5), -4.52740)
  assert.equal!(10.randomize(:int, :sign),             0)
  assert.equal!(10.randomize(:int, :sign),            -3)
  assert.equal!(10.randomize(:int, :sign),            -7)
  assert.equal!(10.randomize(:int, :sign),             6)
  assert.equal!(10.randomize(:int),                    0)
  assert.equal!(10.randomize(:int),                    1)
  assert.equal!(10.randomize(:int),                    9)
  assert.equal!(10.randomize(:int),                    9)
end

def test_numeric_instance_rand_sign args, assert
  srand(100)
  assert.equal!(10.rand(:sign), -10)
  assert.equal!(10.rand(:sign), -10)
  assert.equal!(10.rand(:sign),  10)
  assert.equal!(10.rand(:sign),  10)
  assert.equal!(10.rand(:sign),  10)
  assert.equal!(10.4.rand(:sign), -10.4)
  assert.equal!(10.4.rand(:sign), -10.4)
  assert.equal!(10.4.rand(:sign), 10.4)
  assert.equal!(10.4.rand(:sign), 10.4)
  assert.equal!(10.4.rand(:sign), 10.4)
end

def test_numeric_self_rand_vs_instance_rand args, assert
  value_comparison = [
    {
      name: "rand for integer",
      klass:    -> { Numeric.rand(10) },
      instance: -> { 10.rand }
    },
    {
      name: "rand for integer from float",
      klass:    -> { Numeric.rand(10) },
      instance: -> { 10.0.rand(:int) }
    },
    {
      name: "rand for float",
      klass:    -> { Numeric.rand(10.0).round(5) },
      instance: -> { 10.0.rand.round(5) }
    },
    {
      name: "rand for float from int",
      klass:    -> { Numeric.rand(10.0).round(5) },
      instance: -> { 10.rand(:ratio).round(5) }
    },
    {
      name: "rand for float from int",
      klass:    -> { Numeric.rand(10.0).round(5) },
      instance: -> { 10.rand(:float).round(5) }
    },
    {
      name: "rand int range (sign)",
      klass:    -> { Numeric.rand(-10..10) },
      instance: -> { 10.rand(:int, :sign) }
    },
    {
      name: "rand int range from float (sign)",
      klass:    -> { Numeric.rand(-10..10) },
      instance: -> { 10.0.rand(:int, :sign) }
    },
    {
      name: "rand ratio range (sign)",
      klass:    -> { Numeric.rand(-10.0..10.0) },
      instance: -> { 10.0.rand(:float, :sign) }
    },
    {
      name: "rand ratio range from int (sign)",
      klass:    -> { Numeric.rand(-10.0..10.0) },
      instance: -> { 10.rand(:float, :sign) }
    },
    {
      name: "rand ratio range (sign)",
      klass:    -> { Numeric.rand(-10.0..10.0) },
      instance: -> { 10.0.rand(:ratio, :sign) }
    },
    {
      name: "rand ratio range from int (sign)",
      klass:    -> { Numeric.rand(-10.0..10.0) },
      instance: -> { 10.rand(:ratio, :sign) }
    },
  ]

  value_comparison.each do |h|
    srand(100)
    klass_value = h.klass.call
    srand(100)
    instance_value = h.instance.call
    assert.equal!(klass_value, instance_value, "comparison label: #{h.name}")
  end
end
