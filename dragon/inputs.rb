# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# inputs.rb has been released under MIT (*only this file*).

module GTK
  # Represents all the keys available on the keyboard.
  # @gtk
  class KeyboardKeys
    include Serialize

    # @gtk
    attr_accessor :exclamation_point,
                  :zero, :one, :two, :three, :four,
                  :five, :six, :seven, :eight, :nine,
                  :backspace, :delete, :escape, :enter, :tab,
                  :open_round_brace, :close_round_brace,
                  :open_curly_brace, :close_curly_brace,
                  :open_square_brace, :close_square_brace,
                  :colon, :semicolon, :equal_sign,
                  :hyphen, :space, :dollar_sign,
                  :double_quotation_mark,
                  :single_quotation_mark,
                  :backtick,
                  :tilde, :period, :comma, :pipe,
                  :underscore,
                  :a, :b, :c, :d, :e, :f, :g, :h,
                  :i, :j, :k, :l, :m, :n, :o, :p,
                  :q, :r, :s, :t, :u, :v, :w, :x,
                  :y, :z,
                  :shift, :control, :alt, :meta,
                  :shift_left, :shift_right,
                  :control_left, :control_right,
                  :alt_left, :alt_right,
                  :meta_left, :meta_right,
                  :home, :end,
                  :left, :right, :up, :down, :pageup, :pagedown,
                  :char, :plus, :at, :forward_slash, :back_slash, :asterisk,
                  :less_than, :greater_than, :carat, :ampersand, :superscript_two,
                  :circumflex,
                  :question_mark, :section_sign, :ordinal_indicator,
                  :raw_key

    def self.sdl_to_key raw_key, modifier
      return nil unless (raw_key >= 0 && raw_key <= 255) ||
                        raw_key == 1073741903 ||
                        raw_key == 1073741904 ||
                        raw_key == 1073741905 ||
                        raw_key == 1073741906 ||
                        raw_key == 1073741899 ||
                        raw_key == 1073741902 ||
                        raw_key == 1073741898 ||
                        raw_key == 1073741901 ||
                        (raw_key >= 1073742048 && raw_key <= 1073742055) # Modifier Keys

      char = KeyboardKeys.char_with_shift raw_key, modifier
      names = KeyboardKeys.char_to_method char, raw_key
      names << :alt if (modifier & (256|512)) != 0    # alt key
      names << :meta if (modifier & (1024|2048)) != 0 # meta key (command/apple/windows key)
      names << :control if (modifier & (64|128)) != 0 # ctrl key
      names << :shift if (modifier & (1|2)) != 0      # shift key
      names
    end

    def self.utf_8_char raw_key
      return "²" if raw_key == 178
      return "§" if raw_key == 167
      return "º" if raw_key == 186
      return raw_key.chr
    end

    def self.char_with_shift raw_key, modifier
      return nil unless raw_key >= 0 && raw_key <= 255
      if modifier != 1 && modifier != 2 && modifier != 3
        return utf_8_char raw_key
      else
        @shift_keys ||= {
          '`' => '~', '-' => '_', "'" => '"', "1" => '!',
          "2" => '@', "3" => '#', "4" => '$', "5" => '%',
          "6" => '^', "7" => '&', "8" => '*', "9" => '(',
          "0" => ')', ";" => ":", "=" => "+", "[" => "{",
          "]" => "}", '\\'=> "|", '/' => "?", '.' => ">",
          ',' => "<", 'a' => 'A', 'b' => 'B', 'c' => 'C',
          'd' => 'D', 'e' => 'E', 'f' => 'F', 'g' => 'G',
          'h' => 'H', 'i' => 'I', 'j' => 'J', 'k' => 'K',
          'l' => 'L', 'm' => 'M', 'n' => 'N', 'o' => 'O',
          'p' => 'P', 'q' => 'Q', 'r' => 'R', 's' => 'S',
          't' => 'T', 'u' => 'U', 'v' => 'V', 'w' => 'W',
          'x' => 'X', 'y' => 'Y', 'z' => 'Z'
        }

        @shift_keys[raw_key.chr.to_s] || raw_key.chr.to_s
      end
    end

    def self.char_to_method_hash
      @char_to_method ||= {
        'A'  => [:a],
        'B'  => [:b],
        'C'  => [:c],
        'D'  => [:d],
        'E'  => [:e],
        'F'  => [:f],
        'G'  => [:g],
        'H'  => [:h],
        'I'  => [:i],
        'J'  => [:j],
        'K'  => [:k],
        'L'  => [:l],
        'M'  => [:m],
        'N'  => [:n],
        'O'  => [:o],
        'P'  => [:p],
        'Q'  => [:q],
        'R'  => [:r],
        'S'  => [:s],
        'T'  => [:t],
        'U'  => [:u],
        'V'  => [:v],
        'W'  => [:w],
        'X'  => [:x],
        'Y'  => [:y],
        'Z'  => [:z],
        "!"  => [:exclamation_point],
        "0"  => [:zero],
        "1"  => [:one],
        "2"  => [:two],
        "3"  => [:three],
        "4"  => [:four],
        "5"  => [:five],
        "6"  => [:six],
        "7"  => [:seven],
        "8"  => [:eight],
        "9"  => [:nine],
        "\b" => [:backspace],
        "\e" => [:escape],
        "\r" => [:enter],
        "\t" => [:tab],
        "("  => [:open_round_brace],
        ")"  => [:close_round_brace],
        "{"  => [:open_curly_brace],
        "}"  => [:close_curly_brace],
        "["  => [:open_square_brace],
        "]"  => [:close_square_brace],
        ":"  => [:colon],
        ";"  => [:semicolon],
        "="  => [:equal_sign],
        "-"  => [:hyphen],
        " "  => [:space],
        "$"  => [:dollar_sign],
        "\"" => [:double_quotation_mark],
        "'"  => [:single_quotation_mark],
        "`"  => [:backtick],
        "~"  => [:tilde],
        "."  => [:period],
        ","  => [:comma],
        "|"  => [:pipe],
        "_"  => [:underscore],
        "#"  => [:hash],
        "+"  => [:plus],
        "@"  => [:at],
        "/"  => [:forward_slash],
        "\\" => [:back_slash],
        "*"  => [:asterisk],
        "<"  => [:less_than],
        ">"  => [:greater_than],
        "^"  => [:circumflex],
        "&"  => [:ampersand],
        "²"  => [:superscript_two],
        "§"  => [:section_sign],
        "?"  => [:question_mark],
        '%'  => [:percent_sign],
        "º"  => [:ordinal_indicator],
        1073741898 => [:home],
        1073741901 => [:end],
        1073741903 => [:right],
        1073741904 => [:left],
        1073741905 => [:down],
        1073741906 => [:up],
        1073741899 => [:pageup],
        1073741902 => [:pagedown],
        127 => [:delete],
        1073742049 => [:shift_left, :shift],
        1073742053 => [:shift_right, :shift],
        1073742048 => [:control_left, :control],
        1073742052 => [:control_right, :control],
        1073742050 => [:alt_left, :alt],
        1073742054 => [:alt_right, :alt],
        1073742051 => [:meta_left, :meta],
        1073742055 => [:meta_right, :meta]
      }
    end

    def self.char_to_method char, int = nil
      methods = char_to_method_hash[char] || char_to_method_hash[int]
      methods ? methods.dup : [char.to_sym || int]
    end

    def clear
      set truthy_keys, false
      @scrubbed_ivars = nil
    end

    # @gtk
    def left_right
      return -1 if self.left
      return  1 if self.right
      return  0
    end

    # @gtk
    def up_down
      return  1 if self.up
      return -1 if self.down
      return  0
    end

    # @gtk
    def truthy_keys
      get(all).find_all { |_, v| v }
              .map { |k, _| k.to_sym }
    end

    # @gtk
    def all? keys
      values = get(keys.map { |k| k.without_ending_bang })
      all_true = values.all? do |k, v|
        v
      end

      if all_true
        keys.each do |k|
          clear_key k if k.end_with_bang?
        end
      end

      all_true
    end

    # @gtk
    def any? keys
      values = get(keys.map { |k| k.without_ending_bang })
      any_true = values.any? do |k, v|
        v
      end

      if any_true
        keys.each do |k|
          clear_key k if k.end_with_bang?
        end
      end

      any_true
    end

    # @gtk
    def clear_key key
      @scrubbed_ivars = nil
      self.instance_variable_set("@#{key.without_ending_bang}", false)
    end

    # @gtk
    def all
      @scrubbed_ivars ||= self.instance_variables
                              .reject { |i| i == :@all || i == :@scrubbed_ivars }
                              .map { |i| i.to_s.gsub("@", "") }

      get(@scrubbed_ivars).map { |k, _| k }
    end

    # @gtk
    def get collection
      return [] if collection.length == 0
      collection.map do |m|
        if m.end_with_bang?
          clear_after_return = true
        end

        value = self.instance_variable_get("@#{m.without_ending_bang}".to_sym)
        clear_key m if clear_after_return
        [m.without_ending_bang, value]
      end
    end

    # @gtk
    def set collection, value = true
      return if collection.length == 0
      @scrubbed_ivars = nil
      value = Kernel.tick_count if value

      collection.each do |m|
        self.instance_variable_set("@#{m.to_s}".to_sym, value)
      rescue Exception => e
        raise e, <<-S
* ERROR:
Attempted to set the a key on the DragonRuby GTK's Keyboard data
structure, but the property isn't available for raw_key #{raw_key} #{m}.

You should contact DragonRuby and tell them to associate the raw_key #{raw_key}
with a friendly property name (we are open to suggestions if you have any).
[GTK::KeyboardKeys#set, GTK::KeyboardKeys#char_to_method]

S
      end
    end

    def method_missing m, *args
      begin
        define_singleton_method(m) do
          r = self.instance_variable_get("@#{m.without_ending_bang}".to_sym)
          clear_key m
          return r
        end

        return self.send m
      rescue Exception => e
        log_important "#{e}"
      end

      raise <<-S
* ERROR:
There is no member on the keyboard called #{m}. Here is a to_s representation of what's available:

#{KeyboardKeys.char_to_method_hash.map { |k, v| "[#{k} => #{v.join(",")}]" }.join("  ")}

S
    end

    def serialize
      hash = super
      hash.delete(:scrubbed_ivars)
      hash[:truthy_keys] = self.truthy_keys
      hash
    end
  end
end

module GTK
  # @gtk
  class Keyboard

    # @return [KeyboardKeys]
    # @gtk
    attr_accessor :key_up

    # @return [KeyboardKeys]
    # @gtk
    attr_accessor :key_held

    # @return [KeyboardKeys]
    # @gtk
    attr_accessor :key_down

    # @return [Boolean]
    # @gtk
    attr_accessor :has_focus

    def initialize
      @key_up      = KeyboardKeys.new
      @key_held    = KeyboardKeys.new
      @key_down    = KeyboardKeys.new
      @has_focus   = false
    end

    def p
      @key_down.p || @key_held.p
    end

    # The left arrow or "a" was pressed.
    #
    # @return [Boolean]
    def left
      @key_up.left || @key_held.left || a
    end

    # The right arrow or "d" was pressed.
    #
    # @return [Boolean]
    def right
      @key_up.right || @key_held.right || d
    end

    # The up arrow or "w" was pressed.
    #
    # @return [Boolean]
    def up
      @key_up.up || @key_held.up || w
    end

    # The down arrow or "s" was pressed.
    #
    # @return [Boolean]
    def down
      @key_up.down || @key_held.down || s
    end

    # Clear all current key presses.
    #
    # @return [void]
    def clear
      @key_up.clear
      @key_held.clear
      @key_down.clear
    end

    def serialize
      {
        key_up: @key_up.serialize,
        key_held: @key_held.serialize,
        key_down: @key_down.serialize,
        has_focus: @has_focus
      }
    end
    alias_method :inspect, :serialize

    # @return [String]
    def to_s
      serialize.to_s
    end

    def key
      {
        down: @key_down.truthy_keys,
        held: @key_held.truthy_keys,
        down_or_held: (@key_down.truthy_keys + @key_held.truthy_keys).uniq,
        up: @key_up.truthy_keys,
      }
    end
    alias_method :keys, :key

    include DirectionalInputHelperMethods
  end
end

module GTK
  class MousePoint
    include GTK::Geometry

    # @gtk
    attr_accessor :x, :y, :point, :created_at, :global_created_at

    def initialize x, y
      @x = x
      @y = y
      @point = [x, y]
      @created_at = Kernel.tick_count
      @global_created_at = Kernel.global_tick_count
    end

    def w; 0; end
    def h; 0; end
    def left; x; end
    def right; x; end
    def top; y; end
    def bottom; y; end

    def created_at_elapsed
      @created_at.elapsed_time
    end

    def to_hash
      serialize
    end

    def serialize
      {
        x: @x,
        y: @y,
        created_at: @created_at,
        global_created_at: @global_created_at
      }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  # Provides access to the mouse.
  #
  # @gtk
  class Mouse

    # @gtk
    attr_accessor :moved,
                  :moved_at,
                  :global_moved_at,
                  :up, :has_focus,
                  :button_bits, :button_left,
                  :button_middle, :button_right,
                  :button_x1, :button_x2,
                  :wheel

    attr_accessor :click
    attr_accessor :previous_click
    attr_accessor :x
    attr_accessor :y

    def initialize
      @x = 0
      @y = 0
      @has_focus = false
      @button_bits = 0
      @button_left = false
      @button_middle = false
      @button_right = false
      @button_x1 = false
      @button_x2 = false
      clear
    end

    def point
      [@x, @y].point
    end

    def inside_rect? rect
      point.inside_rect? rect
    end

    def inside_circle? center, radius
      point.point_inside_circle? center, radius
    end

    def intersect_rect? other_rect
      { x: point.x, y: point.y, w: 0, h: 0 }.intersect_rect? other_rect
    end

    alias_method :position, :point

    def clear
      if @click
        @previous_click = MousePoint.new @click.point.x, @click.point.y
        @previous_click.created_at = @click.created_at
        @previous_click.global_created_at = @click.global_created_at
      end

      @click = nil
      @up    = nil
      @moved = nil
      @wheel = nil
    end

    def up
      @up
    end

    def down
      @click
    end

    def serialize
      result = {}

      if @click
        result[:click] = @click.to_hash
        result[:down] = @click.to_hash
      end

      result[:up] = @up.to_hash if @up
      result[:x] = @x
      result[:y] = @y
      result[:moved] = @moved
      result[:moved_at] = @moved_at
      result[:has_focus] = @has_focus

      result
    end

    def to_s
      serialize.to_s
    end

    alias_method :inspect, :to_s
  end

  # Provides access to multitouch input
  #
  # @gtk
  class FingerTouch

    # @gtk
    attr_accessor :moved,
                  :moved_at,
                  :global_moved_at,
                  :down_at,
                  :global_down_at,
                  :touch_order,
                  :first_tick_down,
                  :x, :y

    def initialize
      @moved = false
      @moved_at = 0
      @global_moved_at = 0
      @down_at = 0
      @global_down_at = 0
      @touch_order = 0
      @first_tick_down = true
      @x = 0
      @y = 0
    end

    def point
      [@x, @y].point
    end

    def inside_rect? rect
      point.inside_rect? rect
    end

    def inside_circle? center, radius
      point.point_inside_circle? center, radius
    end

    alias_method :position, :point

    def serialize
      result = {}
      result[:x] = @x
      result[:y] = @y
      result[:touch_order] = @touch_order
      result[:moved] = @moved
      result[:moved_at] = @moved_at
      result[:global_moved_at] = @global_moved_at
      result[:down_at] = @down_at
      result[:global_down_at] = @global_down_at

      result
    end

    def to_s
      serialize.to_s
    end

    alias_method :inspect, :to_s
  end
end

module GTK
  # @gtk
  class Inputs

    # A list of all controllers.
    #
    # @return [Controller[]]
    # @gtk
    attr_reader :controllers

    # @return [Keyboard]
    # @gtk
    attr_reader :keyboard

    # @return [Mouse]
    # @gtk
    attr_reader :mouse

    # @return [HTTPRequest[]]
    # @gtk
    attr_accessor :http_requests

    # @return {FingerTouch}
    # @gtk
    attr_reader :touch
    attr_accessor :finger_one, :finger_two

    # @gtk
    attr_accessor :text, :history

    def initialize
      @controllers = [Controller.new, Controller.new]
      @keyboard = Keyboard.new
      @mouse = Mouse.new
      @touch = {}
      @finger_one = nil
      @finger_two = nil
      @text = []
      @http_requests = []
    end

    def up
      keyboard.up ||
        (controller_one && controller_one.up)
    end

    def down
      keyboard.down ||
        (controller_one && controller_one.down)
    end

    def left
      keyboard.left ||
        (controller_one && controller_one.left)
    end

    def right
      keyboard.right ||
        (controller_one && controller_one.right)
    end

    def directional_vector
      keyboard.directional_vector ||
        (controller_one && controller_one.directional_vector)
    end

    # Returns a signal indicating right (`1`), left (`-1`), or neither ('0').
    #
    # @return [Integer]
    def left_right
      return -1 if self.left
      return  1 if self.right
      return  0
    end

    # Returns a signal indicating up (`1`), down (`-1`), or neither ('0').
    #
    # @return [Integer]
    def up_down
      return  1 if self.up
      return -1 if self.down
      return  0
    end

    # Returns the coordinates of the last click.
    #
    # @return [Float, Float]
    def click
      return nil unless @mouse.click
      return @mouse.click.point
    end

    # The first controller.
    #
    # @return [Controller]
    def controller_one
      @controllers[0]
    end

    # The second controller.
    #
    # @return [Controller]
    def controller_two
      @controllers[1]
    end

    # Clears all inputs.
    #
    # @return [void]
    def clear
      @mouse.clear
      @keyboard.clear
      @controllers.each(&:clear)
      @touch.clear
      @http_requests.clear
      @finger_one = nil
      @finger_two = nil
    end

    # @return [Hash]
    def serialize
      {
        controller_one: controller_one.serialize,
        controller_two: controller_two.serialize,
        keyboard: keyboard.serialize,
        mouse: mouse.serialize,
        text: text.serialize
      }
    end
  end
end
