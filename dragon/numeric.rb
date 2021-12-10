# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# numeric.rb has been released under MIT (*only this file*).

class Numeric
  include ValueType
  include NumericDeprecated

  alias_method :gt,  :>
  alias_method :gte, :>=
  alias_method :lt,  :<
  alias_method :lte, :<=
  alias_method :__original_eq_eq__, :== unless Numeric.instance_methods.include? :__original_eq_eq__

  def to_layout_row opts = {}
    $layout.rect(row: self,
                 col: opts.col || 0,
                 w:   opts.w || 0,
                 h:   opts.h || 0).y
  end

  def to_layout_col opts = {}
    $layout.rect(row: 0,
                 col: self,
                 w:   opts.w || 0,
                 h:   opts.h || 0).x
  end

  def to_layout_w
    $layout.rect(row: 0, col: 0, w: self, h: 1).w
  end

  def to_layout_h
    $layout.rect(row: 0, col: 0, w: 1, h: self).h
  end

  def to_layout_row_from_bottom opts = {}
    ($layout.row_max_index - self).to_layout_row opts
  end

  def to_layout_col_from_right opts = {}
    ($layout.col_max_index - self).to_layout_col opts
  end

  # Converts a numeric value representing seconds into frames.
  #
  # @gtk
  def seconds
    self * 60
  end

  # Divides the number by `2.0` and returns a `float`.
  #
  # @gtk
  def half
    self / 2.0
  end

  def third
    self / 3.0
  end

  def quarter
    self / 4.0
  end

  def to_byte
    clamp(0, 255).to_i
  end

  def clamp *opts
    min = (opts.at 0)
    max = (opts.at 1)
    return min if min && self < min
    return max if max && self > max
    return self
  end

  def clamp_wrap min, max
    max, min = min, max if min > max
    return self if self >= min && self <= max
    return min if min == max
    if self < min
      overflow = min - self
      return (max - overflow).clamp_wrap min, max
    end

    if self > max
      overflow = self - max
      return (min + overflow).clamp_wrap min, max
    end

    return self
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

  # Returns `true` if the numeric value has passed a duration/offset number.
  # `Kernel.tick_count` is used to determine if a number represents an elapsed
  # moment in time.
  #
  # @gtk
  def elapsed? offset = 0, tick_count_override = Kernel.tick_count
    (self + offset) < tick_count_override
  end

  def frame_index *opts
    frame_count_or_hash, hold_for, repeat, tick_count_override = opts
    if frame_count_or_hash.is_a? Hash
      frame_count         = frame_count_or_hash[:count]
      hold_for            = frame_count_or_hash[:hold_for]
      repeat              = frame_count_or_hash[:repeat]
      tick_count_override = frame_count_or_hash[:tick_count_override]
    else
      frame_count = frame_count_or_hash
    end

    tick_count_override ||= Kernel.tick_count
    animation_frame_count = frame_count
    animation_frame_hold_time = hold_for
    animation_length = animation_frame_hold_time * animation_frame_count
    return nil if Kernel.tick_count < self

    if !repeat && (self + animation_length) < (tick_count_override - 1)
      return nil
    else
      return self.elapsed_time.-(1).idiv(animation_frame_hold_time) % animation_frame_count
    end
  rescue Exception => e
    raise <<-S
* ERROR:
#{opts}
#{e}
S
  end

  def zero?
    self == 0
  end

  def zero
    0
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

  alias_method :gt,        :>
  alias_method :above?,    :>
  alias_method :right_of?, :>

  alias_method :lt,       :<
  alias_method :below?,   :<
  alias_method :left_of?, :<

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

  # This provides a way for a numeric value to be randomized based on a combination
  # of two options: `:sign` and `:ratio`.
  #
  # @gtk
  def randomize *definitions
    result = self

    if definitions.include?(:sign)
      result = rand_sign
    end

    if definitions.include?(:ratio)
      result = rand * result
    elsif definitions.include?(:int)
      result = (rand result)
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

  def remainder_of_divide n
    mod n
  end

  # Easing function progress/percentage for a specific point in time.
  #
  # @gtk
  def ease_extended tick_count_override, duration, default_before, default_after, *definitions
    GTK::Easing.ease_extended self,
                              tick_count_override,
                              self + duration,
                              default_before,
                              default_after,
                              *definitions
  end

  # Easing function progress/percentage for a specific point in time.
  #
  # @gtk
  def global_ease duration, *definitions
    ease_extended Kernel.global_tick_count,
                  duration,
                  GTK::Easing.initial_value(*definitions),
                  GTK::Easing.final_value(*definitions),
                  *definitions
  end

  # Easing function progress/percentage for a specific point in time.
  #
  # @gtk
  def ease duration, *definitions
    ease_extended Kernel.tick_count,
                  duration,
                  GTK::Easing.initial_value(*definitions),
                  GTK::Easing.final_value(*definitions),
                  *definitions
  end

  # Easing function progress/percentage for a specific point in time.
  #
  # @gtk
  def ease_spline_extended tick_count_override, duration, spline
    GTK::Easing.ease_spline_extended self,
                                     tick_count_override,
                                     self + duration,
                                     spline
  end

  # Easing function progress/percentage for a specific point in time.
  #
  # @gtk
  def global_ease_spline duration, spline
    ease_spline_extended Kernel.global_tick_count,
                         duration,
                         spline
  end

  # Easing function progress/percentage for a specific point in time.
  #
  # @gtk
  def ease_spline duration, spline
    ease_spline_extended Kernel.tick_count,
                         duration,
                         spline
  end

  # Converts a number representing an angle in degrees to radians.
  #
  # @gtk
  def to_radians
    self * Math::PI.fdiv(180)
  end

  # Converts a number representing an angle in radians to degrees.
  #
  # @gtk
  def to_degrees
    self / Math::PI.fdiv(180)
  end

  # Given `self`, a rectangle primitive is returned.
  #
  # @example
  #   5.to_square 100, 300 # returns [100, 300, 5, 5]
  #
  # @gtk
  def to_square x, y, anchor_x = 0.5, anchor_y = nil
    GTK::Geometry.to_square(self, x, y, anchor_x, anchor_y)
  end

  # Returns a normal vector for a number that represents an angle in degrees.
  #
  # @gtk
  def vector max_value = 1
    [vector_x(max_value), vector_y(max_value)]
  end

  # Returns the y component of a normal vector for a number that represents an angle in degrees.
  #
  # @gtk
  def vector_y max_value = 1
    max_value * Math.sin(self.to_radians)
  end

  # Returns the x component of a normal vector for a number that represents an angle in degrees.
  #
  # @gtk
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

  def zmod? n
    (self % n) == 0
  end

  def multiply n
    self * n
  end

  def fmult n
    self * n.to_f
  end

  def imult n
    (self * n).to_i
  end

  def mult n
    self * n
  end

  # @gtk
  def fdiv n
    self / n.to_f
  end

  # Divides `self` by a number `n` as a float, and converts it `to_i`.
  #
  # @gtk
  def idiv n
    (self / n.to_f).to_i
  end

  # Returns a numeric value that is a quantity `magnitude` closer to
  #`self`. If the distance between `self` and `target` is less than
  #the `magnitude` then `target` is returned.
  #
  # @gtk
  def towards target, magnitude
    return self if self == target
    delta = (self - target).abs
    return target if delta < magnitude
    return self - magnitude if self > target
    return self + magnitude
  end

  # Given `self` and a number representing `y` of a grid. This
  # function will return a one dimensional array containing the value
  # yielded by an implicit block.
  #
  # @example
  #   3.map_with_ys 2 do |x, y|
  #     x * y
  #   end
  #   #     x y   x y  x y  x y  x y  x y
  #   #     0*0,  0*1  1*0  1*1  2*0  2*1
  #   # => [  0,    0,   0,   1,   0,   2]
  #
  # @gtk
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

  # @gtk
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

  def each
    unless block_given?
      raise <<-S
* ERROR:
A block is required for Numeric#each.

S
    end

    self.to_i.times do
      yield
    end
  end

  def times_with_index
    unless block_given?
      raise <<-S
* ERROR:
A block is required for Numeric#times_with_index.

S
    end

    self.to_i.times.with_index do |i|
      yield i
    end
  end

  def each_with_index
    unless block_given?
      raise <<-S
* ERROR:
A block is required for Numeric#each_with_index.

S
    end

    self.to_i.times.with_index do |i|
      yield i
    end
  end

  # @gtk
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

  def __raise_arithmetic_exception__ other, m, e
    raise <<-S
* ERROR:
Attempted to invoke :#{m} on #{self} with the right hand argument of:

#{other}

The object above is not a Numeric.

#{e}
S
  end

  def serialize
    self
  end

  def self.from_top n
    return 720 - n unless $gtk
    $gtk.args.grid.top - n
  end

  def from_top
    Numeric.from_top self
  end

  def self.from_right n
    return 1280 - n unless $gtk
    $gtk.args.grid.right - n
  end

  def from_right
    Numeric.from_right self
  end

  def self.clamp n, min, max
    n.clamp min, max
  end

  def mid? l, r
    (between? l, r) || (between? r, l)
  end
end

class Fixnum
  include ValueType

  alias_method :__original_eq_eq__,    :== unless Fixnum.instance_methods.include? :__original_eq_eq__
  alias_method :__original_add__,      :+  unless Fixnum.instance_methods.include? :__original_add__
  alias_method :__original_subtract__, :-  unless Fixnum.instance_methods.include? :__original_subtract__
  alias_method :__original_multiply__, :*  unless Fixnum.instance_methods.include? :__original_multiply__
  alias_method :__original_divide__,   :-  unless Fixnum.instance_methods.include? :__original_divide__

  # Returns `true` if the numeric value is evenly divisible by 2.
  #
  # @gtk
  def even?
    return (self % 2) == 0
  end

  # Returns `true` if the numeric value is *NOT* evenly divisible by 2.
  #
  # @gtk
  def odd?
    return !even?
  end

  # Returns `-1` if the number is less than `0`. `+1` if the number
  # is greater than `0`. Returns `0` if the number is equal to `0`.
  #
  # @gtk
  def sign
    return -1 if self < 0
    return  1 if self > 0
    return  0
  end

  # Returns `true` if number is greater than `0`.
  #
  # @gtk
  def pos?
    sign > 0
  end

  # Returns `true` if number is less than `0`.
  #
  # @gtk
  def neg?
    sign < 0
  end

  # Returns the cosine of a represented in degrees (NOT radians).
  #
  # @gtk
  def cos
    Math.cos(self.to_radians)
  end

  # Returns the cosine of a represented in degrees (NOT radians).
  #
  # @gtk
  def sin
    Math.sin(self.to_radians)
  end

  def to_sf
    "%.2f" % self
  end

  def ifloor int
    (self.idiv int.to_i) * int.to_i
  end
end

class Float
  include ValueType

  alias_method :__original_add__,      :+ unless Float.instance_methods.include? :__original_add__
  alias_method :__original_subtract__, :- unless Float.instance_methods.include? :__original_subtract__
  alias_method :__original_multiply__, :* unless Float.instance_methods.include? :__original_multiply__
  alias_method :__original_divide__,   :- unless Float.instance_methods.include? :__original_divide__

  def serialize
    self
  end

  # @gtk
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

  def to_sf
    "%.2f" % self
  end

  def ifloor int
    (self.idiv int.to_i) * int.to_i
  end
end

class Integer
  alias_method :__original_round__,    :round  unless Integer.instance_methods.include? :__original_round__
  alias_method :__original_add__,      :+      unless Integer.instance_methods.include? :__original_add__
  alias_method :__original_subtract__, :-      unless Integer.instance_methods.include? :__original_subtract__
  alias_method :__original_multiply__, :*      unless Integer.instance_methods.include? :__original_multiply__
  alias_method :__original_divide__,   :-      unless Integer.instance_methods.include? :__original_divide__

  def round *args
    __original_round__
  end

  def nan?
    false
  end

  def center other
    (self - other).abs.fdiv(2)
  end
end
