# coding: utf-8
# MIT License
# tweetcart.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - https://github.com/HIRO-R-B
# - https://github.com/oeloeloel
# - https://github.com/leviongit

module GTK
  ##
  # Tweetcart: The main module
  module Tweetcart
    ##
    # Tweetcart Modules can extend `Tweetcart::(Include|Extend)`
    #
    # Provide an included/extended that define aliases (or log if they're missing)
    # on a base when the module's mixed
    ##

    ##
    # `aliases` must be defined on the module
    # and return an array of the form
    # [ new_method_alias, old_method_name,
    #   new_method_alias, old_method_name,
    #   ... ]
    module Include
      def included(base)
        tweetcart_aliases = aliases
        base.class_eval do
          tweetcart_aliases.each_slice(2) do |new, old|
            begin
              alias_method new, old
            rescue NameError => e
              Tweetcart.error_log << "#{e}"
            end
          end
        end
      end
    end

    ##
    # `singleton_aliases` must be defined on the module
    module Extend
      def extended(base)
        tweetcart_aliases = singleton_aliases
        base.singleton_class.class_eval do
          tweetcart_aliases.each_slice(2) do |new, old|
            begin
              alias_method new, old
            rescue NameError => e
              Tweetcart.error_log << "#{e}"
            end
          end
        end
      end
    end

    ##
    # Depreciated/Nonexistent methods will get collected here when Tweetcart modules get included
    def self.error_log
      @error_log ||= []
    end

    def self.error_log?
      !@error_log.nil?
    end

    ##
    # Tweetcart entry point
    def self.setup args
      setup_patches
      setup_textures args
    end

    def self.setup_patches
      GTK::Args.include                              ::GTK::Args::Tweetcart
      GTK::Outputs.include                           ::GTK::Outputs::Tweetcart
      GTK::Inputs.include                            ::GTK::Inputs::Tweetcart
      GTK::Keyboard.include                          ::GTK::Keyboard::Tweetcart
      GTK::KeyboardKeys.include                      ::GTK::KeyboardKeys::Tweetcart
      GTK::Mouse.include                             ::GTK::Mouse::Tweetcart
      GTK::Grid.include                              ::GTK::Grid::Tweetcart
      GTK::Geometry.include                          ::GTK::Geometry::Tweetcart
      GTK::Geometry.extend                           ::GTK::Geometry::Tweetcart
      GTK::Primitive::ConversionCapabilities.include ::GTK::Primitive::ConversionCapabilities::Tweetcart
      FFI::Draw.include                              ::GTK::FFIDrawTweetcart
      Enumerator.include                             ::GTK::EnumeratorTweetcart
      Enumerable.include                             ::GTK::EnumerableTweetcart
      Array.include                                  ::GTK::ArrayTweetcart
      Hash.include                                   ::GTK::HashTweetcart
      Numeric.include                                ::GTK::NumericTweetcart
      Integral.include                               ::GTK::IntegralTweetcart
      Fixnum.include                                 ::GTK::FixnumTweetcart
      Symbol.include                                 ::GTK::SymbolTweetcart
      Module.include                                 ::GTK::ModuleTweetcart
      Object.include                                 ::GTK::ObjectTweetcart
      $top_level.include                             ::GTK::MainTweetcart
    end

    def self.setup_textures args
      # setup :p 1 pixel texture
      args.outputs[:p].w = 1
      args.outputs[:p].h = 1
      args.outputs[:p].solids << { x: 0, y: 0, w: 1, h: 1, r: 255, g: 255, b: 255 }

      # setup :c 720 diameter circle
      r = 360
      d = r * 2

      args.outputs[:c].w = d
      args.outputs[:c].h = d

      d.times do |i|
        h = i - r
        l = Math.sqrt(r * r - h * h)
        args.outputs[:c].lines << { x: i, y: r - l, x2: i, y2: r + l, r: 255, g: 255, b: 255 }
      end

      # setup :t, an equilateral triangle with 720 px sides
      m = Math.sqrt(3) / 2
      b = 720
      h = m * b

      v1 = [  0, 0]
      v2 = [720, 0]
      v3 = [360, h]

      is1 = (v3.x - v1.x) / (v3.y - v1.y)
      is2 = (v3.x - v2.x) / (v3.y - v2.y)

      x1 = x2 = v3.x

      args.outputs[:t].w = b
      args.outputs[:t].h = h
      args.outputs[:t].lines << v3.y.downto(v1.y).map do |y|
        line = [x1, y, x2, y, 255, 255, 255]
        x1 -= is1
        x2 -= is2
        line
      end

      # setup :tr, an isosceles right triangle
      v3 = [  0, b]

      is1 = (v3.x - v1.x) / (v3.y - v1.y)
      is2 = (v3.x - v2.x) / (v3.y - v2.y)

      x1 = x2 = v3.x

      args.outputs[:tr].w = b
      args.outputs[:tr].h = b
      args.outputs[:tr].lines << v3.y.downto(v1.y).map do |y|
        line = [x1, y, x2, y, 255, 255, 255]
        x1 -= is1
        x2 -= is2
        line
      end
    end
  end

  module MainTweetcart
    include Math

    F   = 255
    G   = 127
    W   = $args.grid.w
    H   = $args.grid.h
    N   = [nil]
    Z   = [0]
    S30 = 30.sin
    S60 = 60.sin

    ##
    # Provides methods to define classes in a shorter manner
    module P
      def self.do *attrs, &block
        Class.new do
          attr_accessor *attrs

          ##
          # NOTE: Yea, this class might not be a sprite,
          # but you can't push instances into primitives without a valid primitive marker
          # even if you have draw_override defined
          # So... ehh, for all intents and purposes, it's a "sprite"
          def primitive_marker
            :sprite
          end

          def initialize **opts
            opts.each { |k, v| send :"#{k}=", v }
          end

          define_method :draw_override, &block
        end
      end

      def self.so *attrs, &block
        self.do(:x, :y, :w, :h, :r, :g, :b, :a, *attrs, &block)
      end

      def self.sp *attrs, &block
        self.do(:x, :y, :w, :h, :p, :an, :a,
                :r, :g, :b,
                :tx, :ty, :tw, :th,
                :fh, :fv,
                :aax, :aay,
                :sx, :sy, :sw, :sh,
                *attrs, &block)
      end

      def self.la *attrs, &block
        self.do(:x, :y, :t, :sen, :aen, :r, :g, :b, :a, :f, *attrs, &block)
      end

      def self.li *attrs, &block
        self.do(:x, :y, :x2, :y2, :r, :g, :b, :a, *attrs, &block)
      end

      def self.bo *attrs, &block
        self.so(*attrs, &block)
      end

      def self.dso *attrs, &draw_call
        Class.new do
          attr_accessor :x, :y, :w, :h, :r, :g, :b, :a
          attr_accessor *attrs

          def primitive_marker
            :solid
          end

          def initialize x=nil, y=nil, w=nil, h=nil, r=nil, g=nil, b=nil, a=nil, **opts
            @x = x
            @y = y
            @w = w
            @h = h
            @r = r
            @g = g
            @b = b
            @a = a
            opts.each { |k, v| send :"#{k}=", v }
          end

          define_method :draw_call, &draw_call

          def draw_override(ffi)
            draw_call
            ffi.draw_solid(@x, @y, @w, @h, @r, @g, @b, @a)
          end
        end
      end

      def self.dsp path=nil, *attrs, &draw_call
        path &&= path.to_s

        Class.new do
          attr_accessor :x, :y, :w, :h, :p, :an, :a,
                        :r, :g, :b,
                        :tx, :ty, :tw, :th,
                        :fh, :fv,
                        :aax, :aay,
                        :sx, :sy, :sw, :sh
          attr_accessor *attrs

          def primitive_marker
            :sprite
          end

          # Yea this is long... sorry
          define_method :initialize do |x=nil, y=nil, w=nil, h=nil, p=path, an=nil, a=nil, r=nil, g=nil, b=nil, tx=nil, ty=nil, tw=nil, th=nil, fh=nil, fv=nil, aax=nil, aay=nil, sx=nil, sy=nil, sw=nil, sh=nil, **opts|
            @x   = x
            @y   = y
            @w   = w
            @h   = h
            @p   = p
            @an  = an
            @a   = a
            @r   = r
            @g   = g
            @b   = b
            @tx  = tx
            @ty  = ty
            @tw  = tw
            @th  = th
            @fh  = fh
            @fv  = fv
            @aax = aax
            @aay = aay
            @sx  = sx
            @sy  = sy
            @sw  = sw
            @sh  = sh
            opts.each { |k, v| send :"#{k}=", v }
          end

          define_method :draw_call, &draw_call

          def draw_override(ffi)
            draw_call
            ffi.draw_sprite_3(@x, @y, @w, @h, @p, @an, @a,
                              @r, @g, @b,
                              @tx, @ty, @tw, @th,
                              @fh, @fv,
                              @aax, @aay,
                              @sx, @sy, @sw, @sh)
          end
        end
      end

      def self.dla *attrs, &draw_call
        Class.new do
          attr_accessor :x, :y, :t, :sen, :aen, :r, :g, :b, :a, :f
          attr_accessor *attrs

          def primitive_marker
            :label
          end

          def initialize x=nil, y=nil, t=nil, sen=nil, aen=nil, r=nil, g=nil, b=nil, a=nil, f=nil, **opts
            @x   = x
            @y   = y
            @t   = t
            @sen = sen
            @aen = aen
            @r   = r
            @g   = g
            @b   = b
            @a   = a
            @f   = f
            opts.each { |k, v| send :"#{k}=", v }
          end

          define_method :draw_call, &draw_call

          def draw_override(ffi)
            draw_call
            ffi.draw_label(@x, @y, @t, @sen, @aen, @r, @g, @b, @a, @f)
          end
        end
      end

      def self.dli *attrs, &draw_call
        Class.new do
          attr_accessor :x, :y, :x2, :y2, :r, :g, :b, :a
          attr_accessor *attrs

          def primitive_marker
            :line
          end

          def initialize x=nil, y=nil, x2=nil, y2=nil, r=nil, g=nil, b=nil, a=nil, **opts
            @x  = x
            @y  = y
            @x2 = x2
            @y2 = y2
            @r  = r
            @g  = g
            @b  = b
            @a  = a
            opts.each { |k, v| send :"#{k}=", v }
          end

          define_method :draw_call, &draw_call

          def draw_override(ffi)
            draw_call
            ffi.draw_line(@x, @y, @x2, @y2, @r, @g, @b, @a)
          end
        end
      end

      def self.dbo *attrs, &draw_call
        Class.new do
          attr_accessor :x, :y, :w, :h, :r, :g, :b, :a
          attr_accessor *attrs

          def primitive_marker
            :border
          end

          def initialize x=nil, y=nil, w=nil, h=nil, r=nil, g=nil, b=nil, a=nil, **opts
            @x = x
            @y = y
            @w = w
            @h = h
            @r = r
            @g = g
            @b = b
            @a = a
            opts.each { |k, v| send :"#{k}=", v }
          end

          define_method :draw_call, &draw_call

          def draw_override(ffi)
            draw_call
            ffi.draw_border(@x, @y, @w, @h, @r, @g, @b, @a)
          end
        end
      end
    end

    ##
    # General circle centered at x and y
    def CI(x, y, radius, r=0, g=0, b=0, a=255)
      [(2*radius).to_square(x, y), :c, 0, a, r, g, b].sprite
    end

    ##
    # Equilateral triangle centered at x and y
    def TR(x, y, side_length, angle=0, r=0, g=0, b=0, a=255)
      height = side_length * S60
      { x: x - side_length / 2,
        y: y - height / 3,
        w: side_length,
        h: height,
        path: :t, angle: angle,
        a: a, r: r, g: g, b: b,
        angle_anchor_y: 0.333 }
    end

    ##
    # Closed polygon
    def PLY(points, r=nil, g=nil, b=nil, a=nil)
      ply = PLYP(points, r, g, b, a)
      l1  = ply[0]
      l2  = ply[-1]
      ply << [l1[0], l2[1], r, g, b, a]
    end

    ##
    # Poly path (array of connected lines)
    def PLYP(points, r=nil, g=nil, b=nil, a=nil)
      points.flatten.each_slice(2).each_cons(2).map { |p1, p2| [p1, p2, r, g, b, a] }
    end

    ##
    # Alias for calcstringbox
    def csb(string, size_enum=nil, font='font.ttf')
      $gtk.calcstringbox(string, size_enum, font)
    end

    ##
    # Quick sum option
    def sum(*args)
      $args.fn.+(*args)
    end

    def self.aliases
      [
        :csb, 'args.gtk.calcstringbox',
        :sum, 'args.fn.+',
      ]
    end
  end

  module Args::Tweetcart
    ##
    # Viewport
    def vp(x, y, w, h, r = 0, g = 0, b = 0)
      self.outputs.primitives << [
        {x: 0, y: 0, w: x, h: self.grid.h, r: r, g: g, b: b}.solid,
        {x: 0, y: 0, w: self.grid.w, h: y, r: r, g: g, b: b}.solid,
        {x: x + w, y: 0, w: self.grid.w - x, h: self.grid.h, r: r, g: g, b: b}.solid,
        {x: 0, y: y + h, w: self.grid.w, h: self.grid.h - y, r: r, g: g, b: b}.solid
      ]
    end

    def self.aliases
      [
        :t,   'tick_count',
        :s,   'state',
        :i,   'inputs',
        :it,  'inputs.text',
        :k,   'inputs.keyboard',
        :l,   'inputs.left',
        :r,   'inputs.right',
        :u,   'inputs.up',
        :d,   'inputs.down',
        :kd,  'inputs.keyboard.key_down',
        :kh,  'inputs.keyboard.key_held',
        :ku,  'inputs.keyboard.key_up',
        :m,   'inputs.mouse',
        :mx,  'inputs.mouse.x',
        :my,  'inputs.mouse.y',
        :mc,  'inputs.mouse.click',
        :mw,  'inputs.mouse.wheel',
        :ml,  'inputs.mouse.button_left',
        :mm,  'inputs.mouse.button_middle',
        :mr,  'inputs.mouse.button_right',
        :o,   'outputs',
        :bc=, 'outputs.background_color=',
        :so,  'outputs.solids',
        :_so, 'outputs.static_solids',
        :sp,  'outputs.sprites',
        :_sp, 'outputs.static_sprites',
        :pr,  'outputs.primitives',
        :_pr, 'outputs.static_primitives',
        :la,  'outputs.labels',
        :_la, 'outputs.static_labels',
        :li,  'outputs.lines',
        :_li, 'outputs.static_lines',
        :bo,  'outputs.borders',
        :_bo, 'outputs.static_borders',
        :p,   'outputs.p',  # Persistent Outputs
        :pc,  'outputs.pc', # Persistent Outputs clear
        :g,   'grid',
        :gre, 'grid.rect',
        :w,   'grid.w',
        :h,   'grid.h'
      ]
    end

    aliases.each_slice(2) do |m, ref|
      next instance_eval "define_method(:#{m}) { |arg| #{ref} arg }" if m.include?('=')
      instance_eval "define_method(:#{m}) { #{ref} }"
    end
  end

  module Outputs::Tweetcart
    extend Tweetcart::Include

    ##
    # Persistent Outputs
    def p
      if @persistence_initialized
        if !@buffer_swap.new? # Swap buffers if haven't done so
          @buffer_a, @buffer_b = @buffer_b, @buffer_a
          @buffer[:path] = @buffer_b

          self[@buffer_a].sprites << @buffer
          self.sprites << @buffer

          @buffer_swap = Kernel.tick_count
        end
      else
        @buffer_a = :persistent_buffer_a
        @buffer_b = :persistent_buffer_b

        self[@buffer_a]
        self[@buffer_b]

        @buffer = { w: 1280, h: 720 }.sprite
        @buffer_swap = Kernel.tick_count

        @persistence_initialized = true
      end

      self[@buffer_a]
    end

    ##
    # Persistent Outputs Clear
    def pc
      self[@buffer_a]
      self[@buffer_b]

      nil
    end

    def self.aliases
      [
        :so,  :solids,
        :sp,  :sprites,
        :pr,  :primitives,
        :la,  :labels,
        :li,  :lines,
        :bo,  :borders,
        :de,  :debug,
        :_so, :static_solids,
        :_sp, :static_sprites,
        :_pr, :static_primitives,
        :_la, :static_labels,
        :_li, :static_lines,
        :_bo, :static_borders,
        :_de, :static_debug,
        :bc=, :background_color=
      ]
    end
  end

  module Inputs::Tweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :u,  :up,
        :d,  :down,
        :l,  :left,
        :r,  :right,
        :lr, :left_right,
        :ud, :up_down,
        :dv, :directional_vector,
        :t,  :text,
        :m,  :mouse,
        :c,  :click,
        :c1, :controller_one,
        :c2, :controller_two,
        :k,  :keyboard
      ]
    end
  end

  module Keyboard::Tweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :ku, :key_up,
        :kd, :key_down,
        :kh, :key_held,
        :hf, :has_focus,
        :l,  :left,
        :u,  :up,
        :r,  :right,
        :d,  :down,
        :k,  :key
      ]
    end
  end

  module KeyboardKeys::Tweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :lr, :left_right,
        :ud, :up_down,
        :tk, :truthy_keys,
      ]
    end
  end

  module Mouse::Tweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :p,    :point,
        :inr?, :inside_rect?,
        :ic?,  :inside_circle?,
        :ir?,  :intersect_rect?,
        :c,    :click,
        :pc,   :previous_click,
        :m,    :moved,
        :ma,   :moved_at,
        :gma,  :global_moved_at,
        :u,    :up,
        :d,    :down,
        :b,    :button_bits,
        :l,    :button_left,
        :m,    :button_middle,
        :r,    :button_right,
        :x1,   :button_x1,
        :x2,   :button_x2,
        :w,    :wheel,
        :hf,   :has_focus
      ]
    end
  end

  module Grid::Tweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :n,    :name,
        :b,    :bottom,
        :t,    :top,
        :l,    :left,
        :r,    :right,
        :re,   :rect,
        :obl!, :origin_bottom_left!,
        :oc!,  :origin_center!
      ]
    end
  end

  module Geometry::Tweetcart
    extend Tweetcart::Include
    extend Tweetcart::Extend

    def self.aliases
      [
        :inr?, :inside_rect?,
        :ir?,  :intersect_rect?,
        :sr,   :scale_rect,
        :ant,  :angle_to,
        :anf,  :angle_from,
        :pic?, :point_inside_circle?,
        :cir,  :center_inside_rect,
        :cirx, :center_inside_rect_x,
        :ciry, :center_inside_rect_y,
        :ar,   :anchor_rect
      ]
    end

    # NOTE:: `anchor_rect` doesn't exist on the Geometry Class, I assume that'll be added in the future?
    def self.singleton_aliases
      aliases + [
        :sl,  :shift_line,
        :lyi, :line_y_intercept,
        :abl, :angle_between_lines,
        :ls,  :line_slope,
        :lrr, :line_rise_run,
        :rt,  :ray_test,
        :lr,  :line_rect,
        :li,  :line_intersect,
        :d,   :distance,
        :cb,  :cubic_bezier
      ]
    end
  end

  module Primitive::ConversionCapabilities::Tweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :so, :solid,
        :sp, :sprite,
        :la, :label,
        :li, :line,
        :bo, :border
      ]
    end
  end

  module FFIDrawTweetcart
    def dso(x, y, w, h, r=nil, g=nil, b=nil, a=nil)
      draw_solid(x, y, w, h, r, g, b, a)
    end

    def dsp(x, y, w, h, path, angle=nil, a=nil,
            r=nil, g=nil, b=nil,
            tile_x=nil, tile_y=nil, tile_w=nil, tile_h=nil,
            flip_horizontally=nil, flip_vertically=nil,
            angle_anchor_x=nil, angle_anchor_y=nil,
            source_x=nil, source_y=nil, source_w=nil, source_h=nil)

      draw_sprite_3(x, y, w, h, path,
                    angle,
                    a, r, g, b,
                    tile_x, tile_y, tile_w, tile_h,
                    flip_horizontally, flip_vertically,
                    angle_anchor_x, angle_anchor_y,
                    source_x, source_y, source_w, source_h)
    end

    def dla(x, y, text, size_enum=nil, alignment_enum=nil, r=nil, g=nil, b=nil, a=nil, font=nil)
      draw_label(x, y, text, size_enum, alignment_enum, r, g, b, a, font)
    end

    def dli(x, y, x2, y2, r=nil, g=nil, b=nil, a=nil)
      draw_line(x, y, x2, y2, r, g, b, a)
    end

    def dbo(x, y, w, h, r=nil, g=nil, b=nil, a=nil)
      draw_border(x, y, w, h, r, g, b, a)
    end
  end

  module EnumeratorTweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :e,  :each,
        :ei, :each_with_index
      ]
    end
  end

  module EnumerableTweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :cy,  :cycle,
        :dw,  :drop_while,
        :ec,  :each_cons,
        :es,  :each_slice,
        :ewi, :each_with_index,
        :ewo, :each_with_object,
        :en,  :entries,
        :fa,  :find_all,
        :fi,  :find_index,
        :f,   :first,
        :fm,  :flat_map,
        :gb,  :group_by,
        :i?,  :include?,
        :m,   :map,
        :m?,  :member?,
        :mx,  :max,
        :mxb, :max_by,
        :mn,  :min,
        :mnb, :min_by,
        :mm,  :minmax,
        :mmb, :minmax_by,
        :n?,  :none?,
        :o?,  :one?,
        :pa,  :partition,
        :rd,  :reduce,
        :rj,  :reject,
        :rve, :reverse_each,
        :se,  :select,
        :stb, :sort_by,
        :tw,  :take_while
      ]
    end
  end

  module ArrayTweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :an,   :angle,
        :an=,  :angle=,
        :ant,  :angle_to,
        :anf,  :angle_from,
        :agp,  :angle_given_point,
        :air?, :any_intersect_rect?,
        :ap,   :append,
        :cir,  :center_inside_rect,
        :c,    :clear,
        :cl,   :clone,
        :co,   :combination,
        :cp,   :compact,
        :cp!,  :compact!,
        :d,    :delete,
        :da,   :delete_at,
        :di,   :delete_if,
        :e,    :each,
        :ei,   :each_index,
        :e?,   :empty?,
        :fe,   :fetch,
        :fl,   :flatten,
        :fl!,  :flatten!,
        :ir?,  :intersect_rect?,
        :j,    :join,
        :ki,   :keep_if,
        :l,    :length,
        :m!,   :map!,
        :mwi,  :map_with_index,
        :pe,   :permutation,
        :p,    :point,
        :pr,   :product,
        :re,   :rect,
        :rs,   :rect_shift,
        :rj!,  :reject!,
        :rjf,  :reject_false,
        :rjy,  :reject_falsey,
        :rjn,  :reject_nil,
        :rp,   :replace,
        :rv,   :reverse,
        :rv!,  :reverse!,
        :ro,   :rotate,
        :ro!,  :rotate!,
        :sa,   :sample,
        :sr,   :scale_rect,
        :sre,  :scale_rect_extended,
        :se!,  :select!,
        :st,   :shift,
        :str,  :shift_rect,
        :sh,   :shuffle,
        :sh!,  :shuffle!,
        :sl,   :slice,
        :sl!,  :slice!,
        :s,    :sort,
        :s!,   :sort!,
        :tr,   :transpose,
        :ust,  :unshift,
        :va,   :values_at
      ]
    end
  end

  module HashTweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :so,   :solid,
        :sp,   :sprite,
        :la,   :label,
        :li,   :line,
        :bo,   :border,

        :sen,  :size_enum,
        :sen=, :size_enum=,
        :aen,  :alignment_enum,
        :aen=, :alignment_enum=,
        :an,   :angle,
        :an=,  :angle=,
        :aax,  :angle_anchor_x,
        :aax=, :angle_anchor_x=,
        :aay,  :angle_anchor_y,
        :aay=, :angle_anchor_y=,
        :agp,  :angle_given_point,
        :fh,   :flip_horizontally,
        :fh=,  :flip_horizontally=,
        :fv,   :flip_vertically,
        :fv=,  :flip_vertically=,
        :sx,   :source_x,
        :sx=,  :source_x=,
        :sy,   :source_y,
        :sy=,  :source_y=,
        :sw,   :source_w,
        :sw=,  :source_w=,
        :sh,   :source_h,
        :sh=,  :source_h=,

        :c,    :clear,
        :cl,   :clone,
        :co,   :compact,
        :co!,  :compact!,
        :df,   :default,
        :df=,  :default=,
        :dp,   :default_proc,
        :dp=,  :default_proc=,
        :d,    :delete,
        :di,   :delete_if,
        :dt,   :detect,
        :e,    :each,
        :e?,   :empty?,
        :ev,   :each_value,
        :fe,   :fetch,
        :fev,  :fetch_values,
        :fl,   :flatten,
        :hk?,  :has_key?,
        :hv?,  :has_value?,
        :ki,   :keep_if,
        :l,    :length,
        :me,   :merge,
        :me!,  :merge!,
        :rj!,  :reject!,
        :rp,   :replace,
        :sre,  :scale_rect_extended,
        :se!,  :select!,
        :st,   :shift,
        :str,  :shift_rect,
        :sl,   :slice,
        :s,    :sort
      ]
    end
  end

  module NumericTweetcart
    extend Tweetcart::Include

    def r
      rand_ratio.to_i
    end

    def i
      to_i
    end

    def fl
      floor
    end

    def ce
      ceil
    end

    def rn
      round
    end

    def dm(x)
      divmod(x)
    end

    def sin
      Math.sin(self.to_radians)
    end

    def cos
      Math.cos(self.to_radians)
    end

    def self.aliases
      [
        :a,   :abs,

        :s,   :seconds,
        :h,   :half,
        :tb,  :to_byte,
        :cl,  :clamp,
        :cw,  :clamp_wrap,
        :et,  :elapsed_time,
        :etp, :elapsed_time_percent,
        :n?,  :new?,
        :e?,  :elapsed?,
        :fi,  :frame_index,
        :z?,  :zero?,
        :rs,  :rand_sign,
        :rr,  :rand_ratio,
        :rd,  :remainder_of_divide,
        :ea,  :ease,
        :ee,  :ease_extended,
        :ge,  :global_ease,
        :ese, :ease_spline_extended,
        :es,  :ease_spline,
        :tr,  :to_radians,
        :td,  :to_degrees,
        :ts,  :to_square,
        :v,   :vector,
        :vy,  :vector_y,
        :vx,  :vector_x,
        :xv,  :x_vector,
        :yv,  :y_vector,
        :mz?, :mod_zero?,
        :zm?, :zmod?,
        :fd,  :fdiv,
        :d,   :idiv,
        :to,  :towards,
        :mwy, :map_with_ys,
        :co,  :combinations,
        :c,   :cap,
        :cmm, :cap_min_max,
        :n,   :numbers,
        :m,   :map,
        :e,   :each,
        :fr,  :from_right,
        :ft,  :from_top
      ]
    end
  end

  module IntegralTweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :dt,  :downto,
        :ne?, :negative?,
        :nb?, :nobits?,
        :nz?, :nonzero?,
        :po?, :positive?,
        :st,  :step,
        :sc,  :succ,
        :ut,  :upto,
        :z?,  :zero?
      ]
    end
  end

  module FixnumTweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :t,   :times,
        :ev?, :even?,
        :od?, :odd?
      ]
    end
  end

  module SymbolTweetcart
    def so
      $args.outputs[self].solids
    end

    def sp
      $args.outputs[self].sprites
    end

    def pr
      $args.outputs[self].primitives
    end

    def la
      $args.outputs[self].labels
    end

    def li
      $args.outputs[self].lines
    end

    def bo
      $args.outputs[self].borders
    end

    def de
      $args.outputs[self].debug
    end

    def [] *args, &block
      -> caller, *rest { caller.send self, *rest, *args, &block }
    end
  end

  module ModuleTweetcart
    extend Tweetcart::Include

    def self.aliases
      [
        :dm, :define_method
      ]
    end
  end

  module ObjectTweetcart
    extend Tweetcart::Include

    def SO! *opts
      $args.outputs.solids << opts
    end

    def SP! *opts
      $args.outputs.sprites << opts
    end

    def PR! *opts
      $args.outputs.primitives << opts
    end

    def LA! *opts
      $args.outputs.labels << opts
    end

    def LI! *opts
      $args.outputs.lines << opts
    end

    def BO! *opts
      $args.outputs.borders << opts
    end

    def _SO! *opts
      $args.outputs.static_solids << opts
    end

    def _SP! *opts
      $args.outputs.static_sprites << opts
    end

    def _PR! *opts
      $args.outputs.static_primitives << opts
    end

    def _LA! *opts
      $args.outputs.static_labels << opts
    end

    def _LI! *opts
      $args.outputs.static_labels << opts
    end

    def _BO! *opts
      $args.outputs.static_borders << opts
    end

    def PSO! *opts
      $args.outputs.p.solids << opts
    end

    def PSP! *opts
      $args.outputs.p.sprites << opts
    end

    def PPR! *opts
      $args.outputs.p.primitives << opts
    end

    def PLA! *opts
      $args.outputs.p.labels << opts
    end

    def PLI! *opts
      $args.outputs.p.lines << opts
    end

    def PBO! *opts
      $args.outputs.p.borders << opts
    end

    def PC!
      $args.outputs.pc
    end

    def self.aliases
      [
        :dsm, :define_singleton_method
      ]
    end
  end
end
