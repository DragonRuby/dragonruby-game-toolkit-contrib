# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# numeric.rb has been released under MIT (*only this file*).

class Numeric
  include ValueType
  include NumericDeprecated

  alias_method :gte, :>=
  alias_method :lte, :<=
  alias_method :gt,  :>
  alias_method :lt,  :<
  alias_method(:original_eq_eq, :==) unless Numeric.instance_methods.include?(:original_eq_eq)

  def seconds
    self * 60
  end

  def half
    return self / 2.0
  end

  def to_byte
    return 0 if self < 0
    return 255 if self > 255
    return self.to_i
  end

  def elapsed_time tick_count_override = nil
    (tick_count_override || Kernel.tick_count) - self
  end

  def elapsed_time_percent duration
    elapsed_time.percentage_of duration
  end

  def new?
    elapsed_time == 0
  end

  def elapsed? offset, tick_count_override = nil
    (self + offset) < (tick_count_override || Kernel.tick_count)
  end

  def frame_index frame_count, hold_for, repeat, tick_count_override = nil
    animation_frame_count = frame_count
    animation_frame_hold_time = hold_for
    animation_length = animation_frame_hold_time * animation_frame_count
    if !repeat && self.+(animation_length) < (tick_count_override || Kernel.tick_count).-(1)
      return nil
    else
      return self.elapsed_time.-(1).idiv(animation_frame_hold_time) % animation_frame_count
    end
  end

  def zero
    0
  end

  def zero?
    self == 0
  end

  def one
    1
  end

  def two
    2
  end

  def five
    5
  end

  def ten
    10
  end

  def above? v
    self > v
  end

  def below? v
    self < v
  end

  def left_of? v
    self < v
  end

  def right_of? v
    self > v
  end

  def shift_right i
    self + i
  end

  def shift_left i
    shift_right(i * -1)
  rescue Exception => e
    raise_immediately e, :shift_left, i
  end

  def shift_up i
    self + i
  rescue Exception => e
    raise_immediately e, :shift_up, i
  end

  def shift_down i
    shift_up(i * -1)
  rescue Exception => e
    raise_immediately e, :shift_down, i
  end

  def randomize *definitions
    result = self

    if definitions.include?(:sign)
      result = rand_sign
    end

    if definitions.include?(:ratio)
      result = rand * result
    end

    result
  end

  def rand_sign
    return self * -1 if rand > 0.5
    self
  end

  def rand_ratio
    self * rand
  end

  def between? n, n2
    self >= n && self <= n2 || self >= n2 && self <= n
  end

  def remainder_of_divide n
    mod n
  end

  def ease_extended tick_count_override, duration, default_before, default_after, *definitions
    GTK::Easing.exec_definitions(self,
                                 tick_count_override,
                                 self + duration,
                                 default_before,
                                 default_after,
                                 *definitions)
  end

  def ease_initial_value *definitions
    GTK::Easing.initial_value(*definitions)
  end

  def ease_final_value *definitions
    GTK::Easing.final_value(*definitions)
  end

  def global_ease duration, *definitions
    ease_extended Kernel.global_tick_count,
                  duration,
                  GTK::Easing.initial_value(*definitions),
                  GTK::Easing.final_value(*definitions),
                  *definitions
  end

  def ease duration, *definitions
    ease_extended Kernel.tick_count,
                  duration,
                  GTK::Easing.initial_value(*definitions),
                  GTK::Easing.final_value(*definitions),
                  *definitions
  end

  def to_radians
    self * Math::PI.fdiv(180)
  end

  def to_degrees
    self / Math::PI.fdiv(180)
  end

  def to_square x, y, anchor_x = 0.5, anchor_y = nil
    GTK::Geometry.to_square(self, x, y, anchor_x, anchor_y)
  end

  def vector max_value = 1
    [vector_x(max_value), vector_y(max_value)]
  end

  def vector_y max_value = 1
    max_value * Math.sin(self.to_radians)
  end

  def vector_x max_value = 1
    max_value * Math.cos(self.to_radians)
  end

  def x_vector max_value = 1
    vector_x max_value
  end

  def y_vector max_value = 1
    vector_y max_value
  end

  def mod n
    self % n
  end

  def mod_zero? *ns
    ns.any? { |n| mod(n) == 0 }
  end

  def mult n
    self * n
  end

  def fdiv n
    self / n.to_f
  end

  def idiv n
    (self / n.to_f).to_i
  end

  def towards target, magnitude
    return self if self == target
    delta = (self - target).abs
    return target if delta < magnitude
    return self - magnitude if self > target
    return self + magnitude
  end

  def map_with_ys ys, &block
    self.times.flat_map do |x|
      ys.map_with_index do |y|
        yield x, y
      end
    end
  rescue Exception => e
    raise_immediately e, :map_with_ys, [self, ys]
  end

  def combinations other_int
    self.numbers.product(other_int.numbers)
  end

  def percentage_of n
    (self / n.to_f).cap_min_max(0, 1)
  end

  def cap i
    return i if self > i
    self
  end

  def cap_min_max min, max
    return min if self < min
    return max if self > max
    self
  end

  def lesser other
    return other if other < self
    self
  end

  def greater other
    return other if other > self
    self
  end

  def subtract i
    self - i
  end

  def minus i
    self - i
  end

  def add i
    self + i
  end

  def plus i
    self + i
  end

  def numbers
    (0..self).to_a
  end

  def >= other
    return false if !other
    return gte other
  end

  def > other
    return false if !other
    return gt other
  end

  def <= other
    return false if !other
    return lte other
  end

  def < other
    return false if !other
    return gt other
  end

  def == other
    return true if self.original_eq_eq(other)
    if other.is_a?(OpenEntity)
      return self.original_eq_eq(other.entity_id)
    end
    return self.original_eq_eq(other)
  end

  def map
    unless block_given?
      raise <<-S
* ERROR:
A block is required for Numeric#map.

S
    end

    self.to_i.times.map do
      yield
    end
  end

  def map_with_index
    unless block_given?
      raise <<-S
* ERROR:
A block is required for Numeric#map.

S
    end

    self.to_i.times.map do |i|
      yield i
    end
  end

  def check_numeric! sender, other
    return if other.is_a? Numeric

    raise <<-S
* ERROR:
Attempted to invoke :+ on #{self} with the right hand argument of:

#{other}

The object above is not a Numeric.

S
  end

  def - other
    return nil unless other
    check_numeric! :-, other
    super
  end

  def + other
    return nil unless other
    check_numeric! :+, other
    super
  end

  def * other
    return nil unless other
    check_numeric! :*, other
    super
  end

  def / other
    return nil unless other
    check_numeric! :/, other
    super
  end

  def serialize
    self
  end
end

class Fixnum
  include ValueType

  alias_method(:original_eq_eq, :==) unless Fixnum.instance_methods.include?(:original_eq_eq)

  def - other
    return nil unless other
    check_numeric! :-, other
    super
  end

  def even?
    return true if self % 2 == 1
    return false
  end

  def odd?
    return !even?
  end

  def + other
    return nil unless other
    check_numeric! :+, other
    super
  end

  def * other
    return nil unless other
    check_numeric! :*, other
    super
  end

  def / other
    return nil unless other
    check_numeric! :/, other
    super
  end

  def == other
    return true if self.original_eq_eq(other)
    if other.is_a?(GTK::OpenEntity)
      return self.original_eq_eq(other.entity_id)
    end
    return self.original_eq_eq(other)
  end

  def sign
    return -1 if self < 0
    return  1 if self > 0
    return  0
  end

  def pos?
    sign > 0
  end

  def neg?
    sign < 0
  end

  def cos
    Math.cos(self.to_radians)
  end

  def sin
    Math.sin(self.to_radians)
  end
end

class Float
  include ValueType

  def - other
    return nil unless other
    check_numeric! :-, other
    super
  end

  def + other
    return nil unless other
    check_numeric! :+, other
    super
  end

  def * other
    return nil unless other
    check_numeric! :*, other
    super
  end

  def / other
    return nil unless other
    check_numeric! :/, other
    super
  end

  def serialize
    self
  end

  def clamp lower, higher
    return lower  if self < lower
    return higher if self > higher
    return self
  end

  def sign
    return -1 if self < 0
    return  1 if self > 0
    return  0
  end

  def replace_infinity scalar
    return self if !scalar
    return self unless self.infinite?
    return -scalar if self < 0
    return  scalar if self > 0
  end

  def pos?
    sign > 0
  end

  def neg?
    sign < 0
  end
end
