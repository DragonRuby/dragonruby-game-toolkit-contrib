# coding: utf-8
# MIT License
# tweetcart.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - https://github.com/HIRO-R-B
# - https://github.com/oeloeloel
# - https://github.com/leviongit

module GTK
  module Args::Tweetcart
    def t
      self.tick_count
    end

    def s
      self.state
    end

    def i
      self.inputs
    end

    def it
      self.inputs.text
    end

    def k
      self.inputs.keyboard
    end

    def l
      self.inputs.left
    end

    def r
      self.inputs.right
    end

    def u
      self.inputs.up
    end

    def d
      self.inputs.down
    end

    def kd
      self.inputs.keyboard.key_down
    end

    def kh
      self.inputs.keyboard.key_held
    end

    def ku
      self.inputs.keyboard.key_up
    end

    def m
      self.inputs.mouse
    end

    def mx
      self.inputs.mouse.x
    end

    def my
      self.inputs.mouse.y
    end

    def mc
      self.inputs.mouse.click
    end

    def mw
      self.inputs.mouse.wheel
    end

    def ml
      self.inputs.mouse.button_left
    end

    def mm
      self.inputs.mouse.button_middle
    end

    def mr
      self.inputs.mouse.button_right
    end

    def o
      self.outputs
    end

    def bg= color
      self.outputs.background_color= color
    end

    def so
      self.outputs.solids
    end

    def _so
      self.outputs.static_solids
    end

    def sp
      self.outputs.sprites
    end

    def _sp
      self.outputs.static_sprites
    end

    def pr
      self.outputs.primitives
    end

    def _pr
      self.outputs.static_primitives
    end

    def la
      self.outputs.labels
    end

    def _la
      self.outputs.static_labels
    end

    def li
      self.outputs.lines
    end

    def _li
      self.outputs.static_lines
    end

    def bo
      self.outputs.borders
    end

    def _bo
      self.outputs.static_borders
    end

    # Persistent Outputs
    def p 
      self.outputs.p
    end

    # Persistent Outputs Clear
    def pc
      self.outputs.pc
    end

    def w
      self.grid.w
    end

    def h
      self.grid.h
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
        :mc,  'inputs.mouse.click',
        :mw,  'inputs.mouse.wheel',
        :ml,  'inputs.mouse.button_left',
        :mm,  'inputs.mouse.button_middle',
        :mr,  'inputs.mouse.button_right',
        :o,   'outputs',
        :bg=, 'outputs.background_color=',
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
        :p,   'outputs.p',
        :pc,  'outputs.pc',
        :w,   'grid.width',
        :h,   'grid.height',
      ]
    end
  end

  tweetcart_included = Module.new do
    def included(base)
      tweetcart_aliases = aliases
      base.class_eval do
        tweetcart_aliases.each_slice(2) { |new, old| alias_method new, old }
      end
    end
  end

  Outputs::Tweetcart = Module.new do
    extend tweetcart_included

    def p # Persistent Outputs
      if @persistence_initialized
        unless @buffer_swap.new?
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
        :bg=, :background_color=,
      ]
    end
  end

  Inputs::Tweetcart = Module.new do
    extend tweetcart_included

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

  Keyboard::Tweetcart = Module.new do
    extend tweetcart_included

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

  KeyboardKeys::Tweetcart = Module.new do
    extend tweetcart_included

    def self.aliases
      [
        :lr, :left_right,
        :ud, :up_down,
        :tk, :truthy_keys,
      ]
    end
  end

  Mouse::Tweetcart = Module.new do
    extend tweetcart_included

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

  Grid::Tweetcart = Module.new do
    extend tweetcart_included

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

  Geometry::Tweetcart = Module.new do
    extend tweetcart_included

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

    def self.aliases_extended
      [
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

    def self.extended(base)
      tweetcart_aliases = aliases + aliases_extended
      tweetcart_aliases -= [:ar, :anchor_rect] # FIXME:: Anchor rect doesn't exist on the Geometry Class atm
      base.singleton_class.module_eval do
        tweetcart_aliases.each_slice(2) { |new, old| alias_method new, old }
      end
    end
  end

  Primitive::ConversionCapabilities::Tweetcart = Module.new do
    extend tweetcart_included

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

  ModuleTweetcart = Module.new do
    extend tweetcart_included

    def self.aliases
      [
        :dm, :define_method,
      ]
    end
  end

  EnumerableTweetcart = Module.new do
    extend tweetcart_included

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

  ArrayTweetcart = Module.new do
    extend tweetcart_included

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

  HashTweetcart = Module.new do
    extend tweetcart_included

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
        :s,    :sort,
      ]
    end
  end

  NumericTweetcart = Module.new do
    extend tweetcart_included

    def r
      rand_ratio.to_i
    end

    def dm(x)
      divmod(x)
    end

    def self.aliases
      [
        :a,   :abs,

        :s,   :seconds,
        :tb,  :to_byte,
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

  FixnumTweetcart = Module.new do
    extend tweetcart_included

    def self.aliases
      [
        :t,   :times,
        :ev?, :even?,
        :od?, :odd?
      ]
    end
  end

  SymbolTweetcart = Module.new do
    def [] *args, &block
      -> caller, *rest { caller.send self, *rest, *args, &block }
    end
  end

  ObjectTweetcart = Module.new do
    extend tweetcart_included

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
      $args.outputs.labels << opts
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

  module Tweetcart
    include Math

    F = 255
    W = $args.grid.w
    H = $args.grid.h

    def CI(x, y, radius, r = 0, g = 0, b = 0, a = 255)
      [radius.to_square(x, y), :c, 0, a, r, g, b].sprite
    end

    def csb(string, size_enum = nil, font = 'font.ttf')
      $gtk.calcstringbox(string, size_enum, font)
    end

    def sum(*args)
      $args.fn.+(*args)
    end

    def self.aliases
      [
        :csb, 'args.gtk.calcstringbox',
        :sum, 'args.fn.+',
      ]
    end

    def self.setup_monkey_patches args
      args.class.include                             ::GTK::Args::Tweetcart
      args.outputs.class.include                     ::GTK::Outputs::Tweetcart
      args.inputs.class.include                      ::GTK::Inputs::Tweetcart
      args.inputs.keyboard.class.include             ::GTK::Keyboard::Tweetcart
      args.inputs.keyboard.key_down.class.include    ::GTK::KeyboardKeys::Tweetcart
      args.inputs.mouse.class.include                ::GTK::Mouse::Tweetcart
      args.grid.class.include                        ::GTK::Grid::Tweetcart
      args.geometry.include                          ::GTK::Geometry::Tweetcart
      args.geometry.extend                           ::GTK::Geometry::Tweetcart
      GTK::Primitive::ConversionCapabilities.include ::GTK::Primitive::ConversionCapabilities::Tweetcart
      Object.include                                 ::GTK::ObjectTweetcart
      Module.include                                 ::GTK::ModuleTweetcart
      Enumerable.include                             ::GTK::EnumerableTweetcart
      Array.include                                  ::GTK::ArrayTweetcart
      Hash.include                                   ::GTK::HashTweetcart
      Numeric.include                                ::GTK::NumericTweetcart
      Fixnum.include                                 ::GTK::FixnumTweetcart
      Symbol.include                                 ::GTK::SymbolTweetcart
      $top_level.include                             ::GTK::Tweetcart
    end

    def self.setup_textures args
      # setup :p 1 pixel texture
      args.outputs[:p].w = 1
      args.outputs[:p].h = 1
      args.outputs[:p].solids << {x: 0, y: 0, w: 1, h: 1, r: 255, g: 255, b: 255}

      # setup :c 720 diameter circle
      r = 360
      d = r * 2

      args.outputs[:c].w = d
      args.outputs[:c].h = d

      d.times do |i|
        h = i - r
        l = Math.sqrt(r * r - h * h)
        args.outputs[:c].lines << {x: i, y: r - l, x2: i, y2: r + l, r: 255, g: 255, b: 255}
      end
    end

    def self.setup args
      setup_monkey_patches args
      setup_textures args
    end
  end
end
