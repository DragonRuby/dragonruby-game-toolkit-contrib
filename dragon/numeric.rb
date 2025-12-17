# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# numeric.rb has been released under MIT (*only this file*).

class Numeric
  include ValueType
  include NumericDeprecated

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
  def seconds
    self * 60
  end

  # Divides the number by `2.0` and returns a `float`.
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

  def clamp min, max = nil
    return min if min && self < min
    return max if max && self > max
    return self
  end

  def clamp_wrap min, max
    max, min = min, max if min > max
    range = max - min + 1

    min + (self - min) % range
  end

  def elapsed_time tick_count_override = nil
    (tick_count_override || Kernel.tick_count) - self
  end

  def elapsed_time_percent duration
    elapsed_time.percentage_of duration
  end

  def new? tick_count_override
    elapsed_time(tick_count_override) == 0
  end

  # Returns `true` if the numeric value has passed a duration/offset number.
  # `Kernel.tick_count` is used to determine if a number represents an elapsed
  # moment in time.
  def elapsed? offset = 0, tick_count_override = Kernel.tick_count
    (self + offset) < tick_count_override
  end

  def Numeric.frame_index_no_repeat(start_at: 0,
                                    count: nil,
                                    frame_count: nil,
                                    hold_for: 1,
                                    tick_count_override: Kernel.tick_count,
                                    tick_count: nil,
                                    **ignored)
    hold_for ||= 1
    frame_count ||= count
    tick_count_override = tick_count || tick_count_override

    if !frame_count
      raise <<-S
* ERROR:
Numeric::frame_index_no_repeat must be given either ~count~ or ~frame_count~.

Example:
#+begin_src
  Numeric.frame_index_no_repeat start_at: 0, count: 5, hold_for: 5
  # OR
  Numeric.frame_index_no_repeat start_at: 0, frame_count: 5, hold_for: 5
#+end_src
S
    end

    return nil if tick_count_override < start_at
    animation_length = hold_for * frame_count
    current_elapsed_time = start_at.elapsed_time tick_count_override

    if (start_at + animation_length) <= (tick_count_override)
      return nil
    end

    current_elapsed_time.idiv(hold_for) % frame_count
  end

  def Numeric.frame(start_at: 0,
                    count: nil,
                    frame_count: nil,
                    hold_for: 1,
                    repeat: false,
                    repeat_index: 0,
                    tick_count: nil,
                    tick_count_override: Kernel.tick_count,
                    metadata: nil,
                    **ignored)
    frame_index = Numeric.frame_index(start_at: start_at,
                                      count: count,
                                      frame_count: frame_count,
                                      hold_for: hold_for,
                                      repeat: repeat,
                                      repeat_index: repeat_index,
                                      tick_count: tick_count,
                                      tick_count_override: tick_count_override)
    frame_count ||= count
    tick_count ||= tick_count_override
    duration = hold_for * frame_count
    elapsed_time = tick_count - start_at
    frame_elapsed_time = if frame_index
                           (elapsed_time % duration) - (frame_index * hold_for)
                         else
                           nil
                         end

    if start_at > tick_count
      {
        frame_index: nil,
        frame_count: frame_count,
        frames_left: frame_count,
        started: false,
        completed: false,
        elapsed_time: elapsed_time,
        frame_elapsed_time: frame_elapsed_time,
        duration: duration,
        metadata: metadata,
      }
    elsif !frame_index
      {
        frame_index: nil,
        frame_count: frame_count,
        frames_left: 0,
        started: true,
        completed: true,
        elapsed_time: elapsed_time,
        frame_elapsed_time: frame_elapsed_time,
        duration: duration,
        metadata: metadata,
      }
    else
      {
        frame_index: frame_index,
        frame_count: frame_count,
        frames_left: frame_count - frame_index,
        started: true,
        completed: false,
        duration: duration,
        elapsed_time: elapsed_time,
        frame_elapsed_time: frame_elapsed_time,
        metadata: metadata,
      }
    end
  end

  def Numeric.frame_index(start_at: 0,
                          count: nil,
                          frame_count: nil,
                          hold_for: 1,
                          repeat: false,
                          repeat_index: 0,
                          tick_count: nil,
                          tick_count_override: Kernel.tick_count,
                          **ignored)
    hold_for ||= 1
    frame_count ||= count
    tick_count_override = tick_count || tick_count_override
    if !frame_count
      raise <<-S
* ERROR:
Numeric::frame_index must be given either ~count~ or ~frame_count~.

Example:
#+begin_src
  Numeric.frame_index start_at: 0, count: 5, hold_for: 5
  # OR
  Numeric.frame_index start_at: 0, frame_count: 5, hold_for: 5
#+end_src
S
    end

    return nil if tick_count_override < start_at
    frame_count ||= count

    animation_length = hold_for * frame_count

    if !repeat && (start_at + animation_length) <= (tick_count_override)
      return frame_index_no_repeat start_at: start_at,
                                   frame_count: frame_count,
                                   hold_for: hold_for,
                                   tick_count_override: tick_count_override
    else
      current_elapsed_time = start_at.elapsed_time tick_count_override
      first_run = current_elapsed_time < animation_length

      if first_run
        return frame_index_no_repeat start_at: start_at,
                                     frame_count: frame_count,
                                     hold_for: hold_for,
                                     tick_count_override: tick_count_override
      else
        repeat_elapsed_time = current_elapsed_time - animation_length
        repeat_frame_count = frame_count - repeat_index
        repeat_animation_length = hold_for * repeat_frame_count

        repeat_iteration = repeat_elapsed_time.idiv repeat_animation_length
        repeat_start_at = repeat_iteration * repeat_animation_length

        repeat_frame_index = frame_index_no_repeat start_at: repeat_start_at,
                                                   frame_count: repeat_frame_count,
                                                   hold_for: hold_for,
                                                   tick_count_override: repeat_elapsed_time
        repeat_frame_index + repeat_index
      end
    end
  end

  def frame_index *opts
    frame_count_or_hash, hold_for, repeat, tick_count_override = opts
    if frame_count_or_hash.is_a? Hash
      frame_count         = frame_count_or_hash[:frame_count] || frame_count_or_hash[:count]
      hold_for            = frame_count_or_hash[:hold_for]
      repeat              = frame_count_or_hash[:repeat]
      tick_count_override = frame_count_or_hash[:tick_count] || frame_count_or_hash[:tick_count_override]
      repeat_index        = frame_count_or_hash[:repeat_index]
    else
      frame_count = frame_count_or_hash
    end

    repeat_index ||= 0
    tick_count_override ||= Kernel.tick_count

    Numeric.frame_index start_at: self,
                        frame_count: frame_count,
                        hold_for: hold_for,
                        repeat: repeat,
                        tick_count_override: tick_count_override,
                        repeat_index: repeat_index
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
    def_0 = definitions[0]
    def_0 = :ratio if def_0 == :float

    def_1 = definitions[1]
    def_1 = :ratio if def_1 == :float

    if definitions.length == 1 && def_0 == :ratio
      return Kernel.rand * self
    elsif definitions.length == 1 && def_0 == :int
      return Kernel.rand self
    elsif definitions.length == 1 && def_0 == :sign
      return rand_sign * self
    elsif def_0 == :ratio && def_1 == :sign
      return rand_sign * Kernel.rand * self
    elsif def_0 == :sign && def_1 == :ratio
      return rand_sign * Kernel.rand * self
    elsif def_0 == :int && def_1 == :sign
      result = rand_sign
      return Kernel.rand(self) * result
    elsif def_0 == :sign && def_1 == :int
      result = rand_sign
      return Kernel.rand(self) * result
    end

    self
  end

  def rand_sign
    return -1 if Kernel.rand > 0.5
    1
  end

  def rand_ratio
    self * Kernel.rand
  end

  def remainder_of_divide n
    mod n
  end

  # Easing function progress/percentage for a specific point in time.
  def ease_extended tick_count_override, duration, default_before, default_after, *definitions
    GTK::Easing.ease_extended self,
                              tick_count_override,
                              self + duration,
                              default_before,
                              default_after,
                              *definitions
  end

  # Easing function progress/percentage for a specific point in time.
  def global_ease duration, *definitions
    ease_extended Kernel.global_tick_count,
                  duration,
                  GTK::Easing.initial_value(*definitions),
                  GTK::Easing.final_value(*definitions),
                  *definitions
  end

  # Easing function progress/percentage for a specific point in time.
  def ease duration, *definitions
    ease_extended Kernel.tick_count,
                  duration,
                  GTK::Easing.initial_value(*definitions),
                  GTK::Easing.final_value(*definitions),
                  *definitions
  end

  # Easing function progress/percentage for a specific point in time.
  def ease_spline_extended tick_count_override, duration, spline
    GTK::Easing.ease_spline_extended self,
                                     tick_count_override,
                                     self + duration,
                                     spline
  end

  # Easing function progress/percentage for a specific point in time.
  def global_ease_spline duration, spline
    ease_spline_extended Kernel.global_tick_count,
                         duration,
                         spline
  end

  # Easing function progress/percentage for a specific point in time.
  def ease_spline duration, spline
    ease_spline_extended Kernel.tick_count,
                         duration,
                         spline
  end

  # Converts a number representing an angle in degrees to radians.
  def to_radians
    self * Math::PI.fdiv(180)
  end

  alias_method :to_radians_from_degrees, :to_radians
  alias_method :to_r, :to_radians

  # Converts a number representing an angle in radians to degrees.
  def to_degrees
    self / Math::PI.fdiv(180)
  end

  alias_method :to_degrees_from_radians, :to_degrees
  alias_method :to_d, :to_degrees

  # Given `self`, a rectangle primitive is returned.
  #
  # @example
  #   5.to_square 100, 300 # returns [100, 300, 5, 5]
  def to_square x, y, anchor_x = 0.5, anchor_y = nil
    GTK::Geometry.to_square(self, x, y, anchor_x, anchor_y)
  end

  # Returns a normal vector for a number that represents an angle in degrees.
  def vector max_value = 1
    log_once :consider_to_vector!, <<-S
* WARNGING: ~Numeric#vector~ is deprecated. Use ~Numeric#to_vector~.
~Numeric#to_vector~ is more preformant and returns a ~Hash~ containing the keys ~x~ and ~y~ as opposed
to an ~Array~ of ~[x, y]~. Please note that you will lose the ability to destucture the values of a ~Hash~.

S
    [vector_x(max_value), vector_y(max_value)]
  end

  def to_vector_r max_value = 1
    { x: vector_x_r(max_value), y: vector_y_r(max_value) }
  end

  def vector_x_r max_value = 1
    max_value * Math.cos(self)
  end

  def vector_y_r max_value = 1
    max_value * Math.sin(self)
  end

  def to_vector max_value = 1
    { x: vector_x(max_value), y: vector_y(max_value) }
  end

  def vector_y max_value = 1
    max_value * Math.sin(self.to_radians)
  end

  def vector_x max_value = 1
    max_value * Math.cos(self.to_radians)
  end

  alias_method :vector_x_d, :vector_x
  alias_method :vector_y_d, :vector_y
  alias_method :to_vector_d, :to_vector

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

  def fdiv n
    self / n.to_f
  end

  # Divides `self` by a number `n` as a float, and converts it `to_i`.
  def idiv n
    (self / n.to_f).floor
  end

  # Returns a numeric value that is a quantity `magnitude` closer to
  #`self`. If the distance between `self` and `target` is less than
  #the `magnitude` then `target` is returned.
  def towards target, magnitude
    return self if self == target
    delta = (self - target).abs
    return target if delta < magnitude
    return self - magnitude if self > target
    return self + magnitude
  end

  def lerp to, step, tolerance: 0
    diff = (to - self)
    if diff.abs < tolerance
      return to
    else
      self + step * (to - self)
    end
  end

  def remap r1_begin, r1_end, r2_begin, r2_end
    r2_begin + (r2_end - r2_begin) * ((self - r1_begin) / (r1_end - r1_begin))
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
  def map_with_ys ys, &block
    results = []
    x_i = 0
    xs = self

    while x_i < xs
      y_i = 0
      while y_i < ys
        results << yield(x_i, y_i)
        y_i += 1
      end
      x_i += 1
    end
    results
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

  def each(&blk)
    return to_enum(:each) if !blk

    i = 0
    _self = self.to_i
    while i < _self
      blk[i]
      i += 1
    end

    self
  end

  def each_with_index(&blk)
    return to_enum(:each_with_index) if !blk

    i = 0
    _self = self.to_i
    while i < _self
      blk[i, i]
      i += 1
    end

    self
  end

  def map(&blk)
    return to_enum(:map) if !blk

    i = 0
    acc = []
    _self = self.to_i
    while i < _self
      acc << blk[i]
      i += 1
    end

    acc
  end

  def map_with_index(&blk)
    return to_enum(:map_with_index) if !blk

    i = 0
    acc = []
    _self = self.to_i
    while i < _self
      acc << blk[i, i]
      i += 1
    end

    acc
  end

  def times_with_index(&blk)
    return to_enum(:times_with_index) if !blk

    i = 0
    _self = self.to_i
    while i < _self
      blk[i, i]
      i += 1
    end

    self
  end

  def flat_map(&blk)
    return to_enum(:map) if !blk

    i = 0
    acc = []
    _self = self.to_i
    while i < _self
      acc.concat blk[i]
      i += 1
    end

    acc
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

  def self.from_left n
    return n unless $gtk
    $gtk.args.grid.left + n
  end

  def from_left
    Numeric.from_left self
  end

  def self.from_bottom n
    return n unless $gtk
    $gtk.args.grid.bottom + n
  end

  def from_bottom
    Numeric.from_bottom self
  end
end

class Fixnum
  include ValueType

  # Returns `true` if the numeric value is evenly divisible by 2.
  def even?
    return (self % 2) == 0
  end

  # Returns `true` if the numeric value is *NOT* evenly divisible by 2.
  def odd?
    return !even?
  end

  # Returns `-1` if the number is less than `0`. `+1` if the number
  # is greater than `0`. Returns `0` if the number is equal to `0`.
  def sign
    return -1 if self < 0
    return  1 if self > 0
    return  0
  end

  # Returns `true` if number is greater than `0`.
  def pos?
    sign > 0
  end

  # Returns `true` if number is less than `0`.
  def neg?
    sign < 0
  end

  def cos
    Math.cos self.to_radians
  end

  def cos_r
    Math.cos self
  end

  def cos_d
    Math.cos self.to_radians
  end

  def sin
    Math.sin self.to_radians
  end

  def sin_r
    Math.sin self
  end

  def sin_d
    Math.sin self.to_radians
  end

  def tan
    Math.tan self.to_radians
  end

  def tan_d
    Math.tan self.to_radians
  end

  def tan_r
    Math.tan self
  end

  def to_sf(decimal_places: 2, include_sign: false)
    if include_sign
      "%+.#{decimal_places}f" % self
    else
      "%.#{decimal_places}f" % self
    end
  end

  def to_si
    to_i.to_s
        .reverse
        .each_char
        .each_slice(3)
        .map(&:join)
        .join("_")
        .reverse
  end

  def ifloor int
    (self.idiv int.to_i) * int.to_i
  end
end

class Float
  include ValueType

  def serialize
    self
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

  def to_sf(decimal_places: 2, include_sign: false)
    if include_sign
      "%+.#{decimal_places}f" % self
    else
      "%.#{decimal_places}f" % self
    end
  end

  def ifloor int
    (self.idiv int.to_i) * int.to_i
  end

  def sin
    Math.sin self.to_radians
  end

  def cos
    Math.cos self.to_radians
  end

  def sin_r
    Math.sin self
  end

  def sin_d
    Math.sin self.to_radians
  end

  def cos_r
    Math.cos self
  end

  def cos_d
    Math.cos self.to_radians
  end

  def tan
    Math.tan self.to_radians
  end

  def tan_d
    Math.tan self.to_radians
  end

  def tan_r
    Math.tan self
  end
end

class Integer
  def round *args
    self
  end

  def nan?
    false
  end

  def center other
    (self - other).abs.fdiv(2)
  end

  def to_sf
    "#{self}"
  end
end

class Numeric
  def self.rand(arg = nil)
    case arg
    when nil
      Kernel.rand
    when Integer
      Kernel.rand arg
    when Float
      Kernel.rand * arg
    when Range
      if arg.size == 0
        nil
      elsif arg.min > arg.max
        nil
      elsif arg.min.is_a?(Float) || arg.max.is_a?(Float)
        min = arg.min
        max = arg.max
        Kernel.rand * (max - min) + min
      else
        min = arg.min
        max = arg.max + 1
        diff = max - min
        Kernel.rand(diff) + min
      end
    else
      raise <<-S
* ERROR: Numeric::rand does not support the argument type: #{arg.class}.
** Usage:
- No arguments: ~Numeric.rand()~ will return a random float between 0.0 and 1.0.
- Numeric argument: ~Numeric.rand(10)~ will return a random integer between 0 and 10 (exclusive).
- Range argument (integer values): ~Numeric.rand(1..10)~ will return a random integer between 1 and 10 (inclusive).
- Range argument (integer values): ~Numeric.rand(-10..10)~ will return a random integer between -10 and 10 (inclusive).
- Range argument (float values): ~Numeric.rand(1.0..10.0)~ will return a random float between 1.0 and 10.0.
- Range argument (float values): ~Numeric.rand(-10.0..10.0)~ will return a random float between -10.0 and 10.0.
S
    end
  end
end

class Float
  def rand(*definitions)
    arg_0 = definitions[0]
    arg_0 = :ratio if arg_0 == :float
    arg_1 = definitions[1]
    arg_1 = :ratio if arg_1 == :float

    if definitions.length == 1 && arg_0 == :ratio
      return Numeric.rand * self
    elsif definitions.length == 1 && arg_0 == :int
      return Numeric.rand(self.to_i)
    elsif definitions.length == 1 && arg_0 == :sign
      return rand_sign * self
    elsif arg_0 == :ratio && arg_1 == :sign
      return Numeric.rand((self * -1)..self)
    elsif arg_0 == :sign && arg_1 == :ratio
      return Numeric.rand((self * -1)..self)
    elsif arg_0 == :int && arg_1 == :sign
      return Numeric.rand((self.to_i * -1)..self.to_i)
    elsif arg_0 == :sign && arg_1 == :int
      return Numeric.rand((self.to_i * -1)..self.to_i)
    end

    Kernel.rand * self
  end
end

class Integer
  def rand(*definitions)
    arg_0 = definitions[0]
    arg_0 = :ratio if arg_0 == :float
    arg_1 = definitions[1]
    arg_1 = :ratio if arg_1 == :float

    if definitions.length == 1 && arg_0 == :ratio
      return Numeric.rand * self.to_f
    elsif definitions.length == 1 && arg_0 == :int
      return Numeric.rand(self)
    elsif definitions.length == 1 && arg_0 == :sign
      return rand_sign * self
    elsif arg_0 == :ratio && arg_1 == :sign
      return Numeric.rand((self.to_f * -1)..self)
    elsif arg_0 == :sign && arg_1 == :ratio
      return Numeric.rand((self.to_f * -1)..self)
    elsif arg_0 == :int && arg_1 == :sign
      return Numeric.rand((self * -1)..self)
    elsif arg_0 == :sign && arg_1 == :int
      return Numeric.rand((self * -1)..self)
    end

    Kernel.rand self
  end
end
