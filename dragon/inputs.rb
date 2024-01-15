# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# inputs.rb has been released under MIT (*only this file*).

module GTK
  class KeyboardKeys
    include Serialize

    def self.alias_method from, to
      @aliases ||= {}
      @aliases[from] = to
      super from, to
    end

    def self.aliases
      @aliases
    end

    attr_accessor :tilde, :underscore, :double_quotation_mark,
                  :exclamation_point, :at, :hash, :dollar,
                  :percent, :caret, :ampersand, :asterisk,
                  :open_round_brace, :close_round_brace,
                  :open_curly_brace, :close_curly_brace, :colon,
                  :plus, :pipe, :question_mark, :less_than,
                  :greater_than

    attr_accessor :section, :ordinal_indicator, :superscript_two

    attr_accessor :raw_key, :char

    attr_accessor :zero, :one, :two, :three, :four,
                  :five, :six, :seven, :eight, :nine,
                  :backspace, :delete, :escape, :enter, :tab,
                  :open_square_brace, :close_square_brace,
                  :semicolon, :equal,
                  :hyphen, :space,
                  :single_quotation_mark,
                  :backtick,
                  :period, :comma,
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
                  :left_arrow, :right_arrow, :up_arrow, :down_arrow, :page_up, :page_down,
                  :forward_slash, :back_slash

    attr_accessor :w_scancode, :a_scancode, :s_scancode, :d_scancode

    alias_method :section_sign, :section
    alias_method :equal_sign, :equal
    alias_method :dollar_sign, :dollar
    alias_method :percent_sign, :percent
    alias_method :circumflex, :caret
    alias_method :less_than_sign, :less_than
    alias_method :greater_than_sign, :greater_than
    alias_method :left_shift, :shift_left
    alias_method :right_shift, :shift_right
    alias_method :section_sign=, :section=
    alias_method :equal_sign=, :equal=
    alias_method :dollar_sign=, :dollar=
    alias_method :percent_sign=, :percent=
    alias_method :circumflex=, :caret=
    alias_method :less_than_sign=, :less_than=
    alias_method :greater_than_sign=, :greater_than=
    alias_method :left_shift=, :shift_left=
    alias_method :right_shift=, :shift_right=

    alias_method :option, :alt
    alias_method :option_left, :alt_left
    alias_method :option_right, :alt_right
    alias_method :left_alt, :alt_left
    alias_method :right_alt, :alt_right
    alias_method :left_option, :alt_left
    alias_method :right_option, :alt_right
    alias_method :option=, :alt=
    alias_method :option_left=, :alt_left=
    alias_method :option_right=, :alt_right=
    alias_method :left_alt=, :alt_left=
    alias_method :right_alt=, :alt_right=
    alias_method :left_option=, :alt_left=
    alias_method :right_option=, :alt_right=

    alias_method :command, :meta
    alias_method :command_left, :meta_left
    alias_method :command_right, :meta_right
    alias_method :left_meta, :meta_left
    alias_method :right_meta, :meta_right
    alias_method :left_command, :meta_left
    alias_method :right_command, :meta_right
    alias_method :command=, :meta=
    alias_method :command_left=, :meta_left=
    alias_method :command_right=, :meta_right=
    alias_method :left_meta=, :meta_left=
    alias_method :right_meta=, :meta_right=
    alias_method :left_command=, :meta_left=
    alias_method :right_command=, :meta_right=

    alias_method :ctrl, :control
    alias_method :left_control, :control_left
    alias_method :right_control, :control_right
    alias_method :left_ctrl, :control_left
    alias_method :right_ctrl, :control_right
    alias_method :ctrl=, :control=
    alias_method :left_control=, :control_left=
    alias_method :right_control=, :control_right=
    alias_method :left_ctrl=, :control_left=
    alias_method :right_ctrl=, :control_right=

    alias_method :backslash, :back_slash
    alias_method :forwardslash, :forward_slash
    alias_method :minus, :hyphen
    alias_method :dash, :hyphen
    alias_method :pageup, :page_up
    alias_method :pagedown, :page_down
    alias_method :backslash, :back_slash
    alias_method :forwardslash, :forward_slash
    alias_method :backslash=, :back_slash=
    alias_method :forwardslash=, :forward_slash=
    alias_method :minus=, :hyphen=
    alias_method :dash=, :hyphen=
    alias_method :pageup=, :page_up=
    alias_method :pagedown=, :page_down=
    alias_method :backslash=, :back_slash=
    alias_method :forwardslash=, :forward_slash=

    alias_method :left, :left_arrow
    alias_method :right, :right_arrow
    alias_method :up, :up_arrow
    alias_method :down, :down_arrow
    alias_method :left=, :left_arrow=
    alias_method :right=, :right_arrow=
    alias_method :up=, :up_arrow=
    alias_method :down=, :down_arrow=

    def self.sdl_shift_key? raw_key
      sdl_lshift_key?(raw_key) || sdl_rshift_key?(raw_key)
    end

    def self.sdl_lshift_key? raw_key
      raw_key == 1073742049
    end

    def self.sdl_rshift_key? raw_key
      raw_key == 1073742053
    end

    def self.sdl_modifier_key? raw_key
      (raw_key >= 1073742048 && raw_key <= 1073742055) # Modifier Keys
    end

    def self.sdl_modifier_key_methods modifier
      names = []
      if (modifier & 1) != 0
        names << :shift_left
        names << :shift
      end

      if (modifier & 2) != 0
        names << :shift_right
        names << :shift
      end

      if (modifier & 256) != 0
        names << :alt_left
        names << :alt
      end

      if (modifier & 512) != 0
        names << :alt_right
        names << :alt
      end

      if (modifier & 1024) != 0
        names << :meta_left
        names << :meta
      end

      if (modifier & 2048) != 0
        names << :meta_right
        names << :meta
      end

      if (modifier & 64) != 0
        names << :control_left
        names << :control
      end

      if (modifier & 128) != 0
        names << :control_right
        names << :control
      end

      names.uniq!
      names
    end

    def self.char_to_shift_char_hash
      @char_to_shift_char ||= shift_char_to_char_hash.invert
    end

    def self.shift_char_to_char_hash
      @shift_char_to_char ||= {
        tilde: :backtick,
        underscore: :hyphen,
        double_quotation_mark: :single_quotation_mark,
        exclamation_point: :one,
        at: :two,
        hash: :three,
        dollar: :four,
        percent: :five,
        caret: :six,
        ampersand: :seven,
        asterisk: :eight,
        open_round_brace: :nine,
        close_round_brace: :zero,
        open_curly_brace: :open_square_brace,
        close_curly_brace: :close_square_brace,
        colon: :semicolon,
        plus: :equal,
        pipe: :back_slash,
        question_mark: :forward_slash,
        less_than: :comma,
        greater_than: :period
      }
    end

    def self.scancode_to_method_hash
      @scancode_to_method ||= {
        26 => :w_scancode,
        4  => :a_scancode,
        22 => :s_scancode,
        7  => :d_scancode
      }
    end

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
                        sdl_modifier_key?(raw_key)

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
        "="  => [:equal],
        "-"  => [:hyphen, :minus],
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
        "^"  => [:caret],
        "&"  => [:ampersand],
        "²"  => [:superscript_two],
        "§"  => [:section],
        "?"  => [:question_mark],
        '%'  => [:percent],
        "º"  => [:ordinal_indicator],
        1073741898 => [:home],
        1073741901 => [:end],
        1073741903 => [:right_arrow],
        1073741904 => [:left_arrow],
        1073741905 => [:down_arrow],
        1073741906 => [:up_arrow],
        1073741899 => [:page_up],
        1073741902 => [:page_down],
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

    def self.method_to_key_hash
      return @method_to_key_hash if @method_to_key_hash
      @method_to_key_hash = {}
      string_representation_overrides ||= {
        backspace: '\b'
      }
      char_to_method_hash.each do |k, v|
        v.each do |vi|
          t = { char_or_raw_key: k }

          if k.is_a? Numeric
            t[:raw_key] = k
            t[:string_representation] = "raw_key == #{k}"
          else
            t[:char] = k
            t[:string_representation] = "\"#{k.strip}\""
          end

          @method_to_key_hash[vi] = t
        end
      end
      @method_to_key_hash
    end

    def self.char_to_method char, int = nil
      methods = char_to_method_hash[char] || char_to_method_hash[int]
      methods ? methods.dup : [char.to_sym || int]
    end

    def clear
      set truthy_keys, false
      @scrubbed_ivars = nil
    end

    def left_right
      return -1 if self.left
      return  1 if self.right
      return  0
    end

    def up_down
      return  1 if self.up
      return -1 if self.down
      return  0
    end

    def truthy_keys
      get(all).find_all { |_, v| v }
              .map { |k, _| k.to_sym }
    end

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
        resolved_m = KeyboardKeys.aliases[m] || m
        if resolved_m.end_with_bang?
          clear_after_return = true
        end

        value = self.instance_variable_get("@#{resolved_m.without_ending_bang}".to_sym)
        clear_key resolved_m if clear_after_return
        [m.without_ending_bang, value]
      end
    end

    def set collection, value
      return if collection.length == 0
      @scrubbed_ivars = nil

      collection.each do |m|
        resolved_m = KeyboardKeys.aliases[m] || m
        m_to_s = resolved_m.to_s
        self.instance_variable_set("@#{m_to_s}".to_sym, value) if m_to_s.strip.length > 0
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
      without_bang = m.without_ending_bang.to_sym
      without_bang_equal = "#{without_bang}=".to_sym
      if respond_to? without_bang
        begin
          define_singleton_method(m) do
            r = send(without_bang)
            send(without_bang_equal, nil)
            return r
          end

          return self.send m
        rescue Exception => e
          log_important "#{e}"
        end
      end

      did_you_mean = KeyboardKeys.method_to_key_hash.find_all do |k, v|
        k.to_s[0..1] == m.to_s[0..1]
      end.map {|k, v| ":#{k} (#{v[:string_representation]})" }
      did_you_mean_string = ""
      did_you_mean_string = ". Did you mean #{did_you_mean.join ", "}?"

      raise <<-S
* ERROR:
#{KeyboardKeys.method_to_key_hash.map { |k, v| "** :#{k} #{v.string_representation}" }.join("\n")}

There is no key on the keyboard called :#{m}#{did_you_mean_string}.
Full list of available keys =:points_up:=.
S
    end

    def serialize
      hash = super
      hash.delete(:scrubbed_ivars)
      hash[:truthy_keys] = self.truthy_keys
      hash
    end

    def ctrl
      @control
    end

    def ctrl= value
      @control = value
    end
  end
end

module GTK
  class Keyboard

    attr_accessor :key_up
    attr_accessor :key_held
    attr_accessor :key_down
    attr_accessor :has_focus

    attr :active

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
      @key_up.left || @key_held.left || a_scancode || false
    end

    def left_arrow
      @key_up.left || @key_held.left || false
    end

    # The right arrow or "d" was pressed.
    #
    # @return [Boolean]
    def right
      @key_up.right || @key_held.right || d_scancode || false
    end

    def right_arrow
      @key_up.right || @key_held.right || false
    end

    # The up arrow or "w" was pressed.
    #
    # @return [Boolean]
    def up
      @key_up.up || @key_held.up || w_scancode || false
    end

    def up_arrow
      @key_up.up || @key_held.up || false
    end

    # The down arrow or "s" was pressed.
    #
    # @return [Boolean]
    def down
      @key_up.down || @key_held.down || s_scancode || false
    end

    def down_arrow
      @key_up.down || @key_held.down || false
    end

    # Clear all current key presses.
    #
    # @return [void]
    def clear
      @key_up.clear
      @key_held.clear
      @key_down.clear
      @active = nil
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

    def method_missing m, *args
      if m.to_s.start_with?("ctrl_") || m.to_s.start_with?("control_")
        other_key = m.to_s.split("_").last
        define_singleton_method(m) do
          return self.key_down.send(other_key.to_sym) && self.control
        end

        return send(m)
      elsif m.to_s.start_with?("shift_")
        other_key = m.to_s.split("_").last
        define_singleton_method(m) do
          return self.key_down.send(other_key.to_sym) && self.shift
        end

        return send(m)
      elsif m.to_s.start_with?("alt_")
        other_key = m.to_s.split("_").last
        define_singleton_method(m) do
          return self.key_down.send(other_key.to_sym) && self.alt
        end

        return send(m)
      elsif m.to_s.start_with?("meta_")
        other_key = m.to_s.split("_").last
        define_singleton_method(m) do
          return self.key_down.send(other_key.to_sym) && self.meta
        end

        return send(m)
      else
        define_singleton_method(m) do
          self.key_down.send(m) || self.key_held.send(m)
        end

        return send(m)
      end
    end
  end
end

module GTK
  class MousePoint
    include GTK::Geometry

    attr_accessor :x, :y, :point, :created_at, :global_created_at

    def initialize x, y
      @x = x
      @y = y
      @point = { x: @x, y: @y, w: 0, h: 0 }
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

  class Mouse
    attr_accessor :moved,
                  :moved_at,
                  :global_moved_at,
                  :up, :has_focus,
                  :button_bits, :button_left,
                  :button_middle, :button_right,
                  :button_x1, :button_x2,
                  :wheel, :relative_x, :relative_y,
                  :active

    attr_accessor :click
    attr_accessor :click_at
    attr_accessor :global_click_at
    attr_accessor :up_at
    attr_accessor :global_up_at
    attr_accessor :previous_click
    attr_accessor :x
    attr_accessor :y
    attr_accessor :previous_x
    attr_accessor :previous_y

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
      @relative_x = 0
      @relative_y = 0
      clear
    end

    def held
      return false if !global_click_at
      return true if global_click_at && !global_up_at
      return global_up_at < global_click_at
    end

    def held_at
      return nil if !held
      return click_at + 1
    end

    def global_held_at
      return nil if !held
      return global_click_at + 1
    end

    def point
      { x: @x, y: @y, w: 0, h: 0 }
    end

    def inside_rect? rect
      point.inside_rect? rect
    end

    def inside_circle? center, radius
      point.point_inside_circle? center, radius
    end

    def intersect_rect? other_rect
      rect.intersect_rect? other_rect
    end

    def rect
      { x: point.x, y: point.y, w: 0, h: 0 }
    end

    def merge o
      rect.merge o
    end

    def w
      0
    end

    def h
      0
    end

    alias_method :position, :point

    def clear
      if @click
        @previous_click = MousePoint.new @click.point.x, @click.point.y
        @previous_click.created_at = @click.created_at
        @previous_click.global_created_at = @click.global_created_at
      end

      @active = nil
      @click = nil
      @up    = nil
      @moved = nil
      @wheel = nil
      @relative_x = 0
      @relative_y = 0
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

  class FingerTouch
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
  class Inputs
    attr_reader :controllers
    attr_reader :keyboard
    attr_reader :mouse
    attr_accessor :http_requests
    attr_reader :touch
    attr_accessor :finger_one, :finger_two
    attr_accessor :finger_left, :finger_right
    attr_accessor :text, :history
    attr_accessor :headset
    attr :last_active
    attr :touch_enabled
    attr :locale, :locale_raw

    def initialize
      @controllers = [Controller.new, Controller.new, Controller.new, Controller.new]
      @keyboard = Keyboard.new
      @mouse = Mouse.new
      @touch = {}
      @finger_one = nil
      @finger_two = nil
      @text = []
      @http_requests = []
      @headset = {
        position: { x: 0, y: 0, z: 0 },
        orientation: { x: 0, y: 0, z: 0 }
      }
    end

    def up
      keyboard.up || (controller_one && controller_one.up)
    end

    alias_method :up_with_wasd, :up

    def down
      keyboard.down || (controller_one && controller_one.down)
    end

    alias_method :down_with_wasd, :down

    def left
      keyboard.left || (controller_one && controller_one.left)
    end

    alias_method :left_with_wasd, :left

    def right
      keyboard.right || (controller_one && controller_one.right)
    end

    alias_method :right_with_wasd, :right

    def directional_vector
      keyboard.directional_vector ||
        (controller_one && controller_one.directional_vector)
    end

    def directional_angle
      keyboard.directional_angle || (controller_one && controller_one.directional_angle)
    end

    def left_right
      return -1 if self.left
      return  1 if self.right
      return  0
    end

    alias_method :left_right_with_wasd, :left_right

    def left_right_arrow
      return -1 if keyboard.left_arrow || (controller_one && controller_one.directional_left)
      return  1 if keyboard.right_arrow || (controller_one && controller_one.directional_right)
      return  0
    end

    alias_method :left_right_directional, :left_right_arrow

    def left_right_perc
      if controller_one && controller_one.left_analog_x_perc != 0
        controller_one.left_analog_x_perc
      else
        left_right
      end
    end

    alias_method :left_right_perc_with_wasd, :left_right_perc

    def left_right_directional_perc
      if controller_one && controller_one.left_analog_x_perc != 0
        controller_one.left_analog_x_perc
      else
        left_right_directional
      end
    end

    def up_down
      return  1 if self.up
      return -1 if self.down
      return  0
    end

    alias_method :up_down_with_wasd, :up_down

    def up_down_arrow
      return  1 if keyboard.up_arrow || (controller_one && controller_one.directional_up)
      return -1 if keyboard.down_arrow || (controller_one && controller_one.directional_down)
      return  0
    end

    alias_method :up_down_directional, :up_down_arrow

    def up_down_perc
      if controller_one && controller_one.left_analog_y_perc != 0
        controller_one.left_analog_y_perc
      else
        up_down_directional
      end
    end

    def click
      return nil unless @mouse.click
      return @mouse.click.point
    end

    def controller_one
      @controllers[0]
    end

    def controller_two
      @controllers[1]
    end

    def controller_three
      @controllers[2]
    end

    def controller_four
      @controllers[3]
    end

    def clear
      @mouse.clear
      @keyboard.clear
      @controllers.each(&:clear)
      @touch.clear
      @http_requests.clear
      @finger_one = nil
      @finger_two = nil
    end

    def serialize
      {
        controller_one: controller_one.serialize,
        controller_two: controller_two.serialize,
        controller_three: controller_three.serialize,
        controller_four: controller_four.serialize,
        keyboard: keyboard.serialize,
        mouse: mouse.serialize,
        text: text.serialize
      }
    end

    def touch_enabled?
      @touch_enabled
    end
  end
end
