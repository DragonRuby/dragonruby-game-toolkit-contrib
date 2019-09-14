# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# inputs.rb has been released under MIT (*only this file*).

module GTK
  class KeyboardKeys
    include Serialize

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
                  :left, :right, :up, :down, :pageup, :pagedown,
                  :char, :plus, :at, :forward_slash, :back_slash, :asterisk,
                  :less_than, :greater_than, :carat, :ampersand, :superscript_two,
                  :question_mark, :section_sign, :ordinal_indicator,
                  :raw_key

    def self.sdl_to_key raw_key, modifier
      return nil unless (raw_key >= 0 && raw_key <= 255) ||
                        raw_key == 1073741903 ||
                        raw_key == 1073741904 ||
                        raw_key == 1073741905 ||
                        raw_key == 1073741906 ||
                        raw_key == 1073741899 ||
                        raw_key == 1073741902

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
        'A'  => [:a, :shift],
        'B'  => [:b, :shift],
        'C'  => [:c, :shift],
        'D'  => [:d, :shift],
        'E'  => [:e, :shift],
        'F'  => [:f, :shift],
        'G'  => [:g, :shift],
        'H'  => [:h, :shift],
        'I'  => [:i, :shift],
        'J'  => [:j, :shift],
        'K'  => [:k, :shift],
        'L'  => [:l, :shift],
        'M'  => [:m, :shift],
        'N'  => [:n, :shift],
        'O'  => [:o, :shift],
        'P'  => [:p, :shift],
        'Q'  => [:q, :shift],
        'R'  => [:r, :shift],
        'S'  => [:s, :shift],
        'T'  => [:t, :shift],
        'U'  => [:u, :shift],
        'V'  => [:v, :shift],
        'W'  => [:w, :shift],
        'X'  => [:x, :shift],
        'Y'  => [:y, :shift],
        'Z'  => [:z, :shift],
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
        "^"  => [:greater_than],
        "&"  => [:ampersand],
        "²"  => [:superscript_two],
        "§"  => [:section_sign],
        "?"  => [:question_mark],
        "%"  => [:percent_sign],
        "º"  => [:ordinal_indicator],
        1073741903 => [:right],
        1073741904 => [:left],
        1073741905 => [:down],
        1073741906 => [:up],
        1073741899 => [:pageup],
        1073741902 => [:pagedown],
        127 => [:delete]
      }
    end

    def self.char_to_method char, int = nil
      char_to_method_hash[char] || char_to_method_hash[int] || [char.to_sym || int]
    end

    def clear
      set truthy_keys, false
      @scrubbed_ivars = nil
    end

    def left_right
      return -1 if @left
      return  1 if @right
      return  0
    end

    def up_down
      return  1 if @up
      return -1 if @down
      return  0
    end

    def truthy_keys
      get(all).find_all { |_, v| v }
        .map { |k, _| k.to_sym }
    end

    def truthy_keys_hash
      get(all).to_h.delete_if {|_, v| !v })
    end

    def all? keys
      values = keys_to_get(keys.map { |k| k.without_ending_bang })
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

    def any? keys
      values = keys_to_get(keys.map { |k| k.without_ending_bang })
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

    def clear_key key
      @scrubbed_ivars = nil
      self.instance_variable_set("@#{key.without_ending_bang}", false)
    end

    def all
      @scrubbed_ivars ||= self.instance_variables
                            .reject { |i| i == :@all || i == :@scrubbed_ivars }
                            .map { |i| i.to_s.gsub("@", "") }

      get(@scrubbed_ivars).map { |k, _| k }
    end

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

    def set collection, value = true
      return if collection.length == 0
      @scrubbed_ivars = nil
      value = Kernel.tick_count if value

      collection.each do |m|
        self.instance_variable_set("@#{m.to_s}".to_sym, value)
      rescue
        raise <<-S
ERROR:
Attempted to set the a key on the DragonRuby GTK's Keyboard data
structure, but the property isn't available for raw_key #{raw_key} #{m}.

You should contact DragonRuby and tell them to associate the raw_key #{raw_key}
with a friendly property name (we are open to suggestions if you have any).
[GTK::KeyboardKeys#set, GTK::KeyboardKeys#char_to_method]

S
      end
    end

    def method_missing m, *args
      if m.to_s.length != 1 && m.end_with_bang?
        begin
          define_singleton_method(m) do
            r = self.instance_variable_get("@#{m.without_ending_bang}".to_sym)
            clear_key m
            return r
          end

          return self.send m
        rescue Exception => e
          log "#{e}}"
        end
      end

      raise <<-S
ERROR:
There is no member on the keyboard called #{m}. Here is a to_s representation of what's available:

#{KeyboardKeys.char_to_method_hash}

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
  class Keyboard
    attr_accessor :key_up, :key_held, :key_down, :has_focus

    def initialize
      @key_up      = KeyboardKeys.new
      @key_held    = KeyboardKeys.new
      @key_down    = KeyboardKeys.new
      @has_focus   = false
    end

    def left_right
      return -1 if left
      return  1 if right
      return  0
    end

    def up_down
      return  1 if up
      return -1 if down
      return  0
    end

    def left
      @key_down.left || @key_held.left
    end

    def right
      @key_down.right  || @key_held.right
    end

    def up
      @key_down.up || @key_held.up
    end

    def down
      @key_down.down  || @key_held.down
    end

    def w
      @key_down.w || @key_held.w
    end

    def a
      @key_down.a || @key_held.a
    end

    def s
      @key_down.s || @key_held.s
    end

    def d
      @key_down.d || @key_held.d
    end

    def method_missing m, *args
      if @key_down.respond_to? m
        define_singleton_method(m) do
          @key_down.send(m) || @key_held.send(m)
        end

        return send(m)
      end

      super
    end

    def clear
      @key_up.clear
      @key_held.clear
      @key_down.clear
    end

    def serialize
      {
        key_up:      @key_up.serialize,
        key_held:    @key_held.serialize,
        key_down:    @key_down.serialize,
        has_focus:   @has_focus
      }
    end

    def inspect
      serialize
    end

    def to_s
      serialize.to_s
    end
  end
end

module GTK
  class ControllerKeys
    include Serialize
    attr_accessor :up, :down, :left, :right,
                  :a, :b, :x, :y,
                  :l1, :r1,
                  :l2, :r2,
                  :l3, :r3,
                  :start, :select,
                  :directional_up,
                  :directional_down,
                  :directional_left,
                  :directional_right
    def clear
      @up = nil
      @down = nil
      @left = nil
      @right = nil
      @a = nil
      @b = nil
      @x = nil
      @y = nil
      @l1 = nil
      @r1 = nil
      @l2 = nil
      @r2 = nil
      @l3 = nil
      @r3 = nil
      @start = nil
      @select = nil
      @directional_up = nil
      @directional_down = nil
      @directional_left = nil
      @directional_right = nil
    end

    def truthy_keys
      [
        :up, :down, :left, :right,
        :a, :b, :x, :y,
        :l1, :r1, :l2, :r2, :l3, :r3,
        :start, :select,
        :directional_up, :directional_down, :directional_left, :directional_right,
      ].find_all { |attr| send(attr) }.to_a
    end
  end
end

module GTK
  class Controller
    attr_accessor :key_down, :key_up, :key_held, :left_right, :up_down,
                  :left_analog_x_raw,
                  :left_analog_y_raw,
                  :left_analog_x_perc,
                  :left_analog_y_perc,
                  :right_analog_x_raw,
                  :right_analog_y_raw,
                  :right_analog_x_perc,
                  :right_analog_y_perc


    def initialize
      @key_down = ControllerKeys.new
      @key_up   = ControllerKeys.new
      @key_held = ControllerKeys.new
      @left_analog_x_raw = 0
      @left_analog_y_raw = 0
      @left_analog_x_perc = 0
      @left_analog_y_perc = 0
      @right_analog_x_raw = 0
      @right_analog_y_raw = 0
      @right_analog_x_perc = 0
      @right_analog_y_perc = 0
    end

    def left_right
      return -1 if @key_down.left  || @key_held.left
      return  1 if @key_down.right || @key_held.right
      return  0
    end

    def up_down
      return  1 if @key_down.up || @key_held.up
      return -1 if @key_down.down  || @key_held.down
      return  0
    end

    def serialize
      {
        key_down: @key_down.serialize,
        key_held: @key_held.serialize,
        key_up:   @key_up.serialize
      }
    end

    def clear
      @key_down.clear
      @key_up.clear
      @key_held.clear
    end
  end
end

module GTK
  class Mouse
    attr_accessor :click,
                  :previous_click,
                  :moved,
                  :moved_at,
                  :moved_at_time,
                  :x, :y, :up, :has_focus,
                  :button_bits, :button_left,
                  :button_middle, :button_right,
                  :button_x1, :button_x2,
                  :wheel

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

    def clear
      if @click
        @previous_click = OpenEntity.new
        @previous_click.point = [@click.point.x, @click.point.y]
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

    def position
      [@x, @y]
    end

    def serialize
      result = {}

      if @click
        result[:click] = @click.hash
        result[:down] = @click.hash
      end

      result[:up] = @up.hash if @up
      result[:x] = @x
      result[:y] = @y
      result[:moved] = @moved
      result[:moved_at] = @moved_at
      result[:has_focus] = @has_focus

      result
    end
  end
end

module GTK
  class Inputs
    attr_accessor :controllers, :keyboard, :mouse, :text, :history

    def initialize
      @controllers = [Controller.new, Controller.new]
      @keyboard = Keyboard.new
      @mouse = Mouse.new
      @text = []
    end

    def controller_one
      @controllers.value(0)
    end

    def controller_two
      @controllers.value(1)
    end

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
