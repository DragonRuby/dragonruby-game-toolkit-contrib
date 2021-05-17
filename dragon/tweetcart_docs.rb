# coding: utf-8
# MIT License
# tweetcart_docs.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - https://github.com/HIRO-R-B
# - https://github.com/oeloeloel
# - https://github.com/leviongit

module TweetcartDocs
  def self.format_aliases aliases
    en      = aliases.each_slice(2)
    max_len = en.map { |new, _| new.length }.max
    out     = en.map { |new, old| "  #{new.to_s.ljust(max_len)} | #{old}" }.join("\n")

    <<-S
**** Aliases
#+begin_src
#{out}
#+end_src

S
  end

  def docs_method_sort_order
    [
      :docs_class,
      :docs_built_in_render_targets,
      :docs_persistent_outputs,
      :docs_math,
      :docs_summary,
      :docs_args,
      :docs_outputs,
      :docs_inputs,
      :docs_keyboard,
      :docs_mouse,
      :docs_geometry,
      :docs_primitive_conversions,
      :docs_ffidraw,
      :docs_enumerable,
      :docs_array,
      :docs_hash,
      :docs_numeric,
      :docs_integral,
      :docs_fixnum,
      :docs_symbol,
      :docs_module,
      :docs_object
    ]
  end

  def docs_class
    <<-S
* DOCS: ~GTK::Tweetcart~
~GTK::Tweetcart~ provides short aliases for 'code golf' (making code as short as possible for fun) and creating Tweetcarts (a short program, game or artwork written in 280 characters or less and tweeted).\n
To make Tweetcart mode available, define your ~tick~ method as ~t~
#+begin_src
  def t a
    m = a.i.m                   # args.inputs.mouse
    a.o.s << [m.x, m.y, 10, 10] # args.outputs.solids
  end
#+end_src

S
  end

  def docs_built_in_render_targets
    <<-S
** Built-In Render Targets
~GTK::Tweetcart~ provides built-in circle and 1x1 pixel render targets, which you can access with ~:c~ and ~:p~ respectively.
#+begin_src
  def t a
    a.bg = [0, 0, 0] # a.outputs.background_color = [0, 0, 0]

    a.s.r ||= 0 # args.state.r ||= 0
    a.s.r += 1

    a.o.sp << [640 - 50, 360 - 50, 100, 100, :p, a.s.r] # args.outputs.sprites
    # Display a white rotating square in the middle of the screen

    m = a.i.m # a.inputs.mouse
    a.o.sp << [m.x - 50, m.y - 50, 100, 100, :c]
    # Display a white circle that follows your mouse cursor
  end
#+end_src
S
  end

  def docs_persistent_outputs
    <<-S
** Persistent Outputs
~GTK::Tweetcart~ provides a "persistent" outputs render target and whatever you draw with it persists to later frames.\n
You can access it using ~outputs.p~ and clear it with ~outputs.pc~
#+begin_src
  def t a
    a.bg = [0, 0, 0]

    m = a.i.m
    a.o.p.sp << [m.x - 25, m.y - 25, 50, 50, :p] # a.outputs.p.sprites
    # Draws white squares to your mouse's location that persist to your screen

    a.o.pc if m.c # Clear Persistent Outputs if you click the mouse
  end
#+end_src
S
  end

  def docs_math
    <<-S
** Math
All methods available to ~Math~ are included into ~main~ and are usable
#+begin_src
  def t a
    puts sin(a.t) # Math.sin(args.tick_count)
  end
#+end_src

S
  end

  def docs_summary
    <<-S
** Summary
*** main

**** CONSTANTS
#+begin_src
  F   | 255
  G   | 127
  W   | args.grid.w
  H   | args.grid.h
  N   | [nil]
  Z   | [0]
  S30 | 30.sin
  S60 | 60.sin
  PI  | Math::PI
  E   | Math::E
#+end_src

**** Methods
**** ~#CI x, y, radius, r = 0, g = 0, b = 0, a = 255~
Returns a circle sprite (as array) with a given ~radius~ that is centered at ~x~ and ~y~

**** ~#TR x, y, side_length, angle=0, r=0, g=0, b=0, a=255~
Returns an equilateral triangle sprite (as hash) with a given ~side_length~ centered at ~x~ and ~y~

**** ~#PLY points, r = nil, g = nil, b = nil, a = nil~
Returns an array of lines that form an unfilled polygon

**** ~#PLYP points, r = nil, g = nil, b = nil, a = nil~
Returns an array of lines that form a path

**** Modules
**** ~P~
P provides methods to facilitate the creation of primitive classes with draw overrides

**** ~#do *attrs, &draw_override~
Returns a class with the given attrs defined and block as its draw_override
The returned class can be initialized with key arguments
#+begin_src
  def t a
    Thing ||= P.do(:shift, :x, :y) { |ffi| ffi.dso(@x, @y, @shift, 100, 0, 0, 0, 255) }
    t = Thing.new(x: a.m.x, y: a.m.y)
    t.shift = (100 * a.t.sin).a
    a.o.pr << t # Displays a black square with a shifting width at your mouse location
  end
#+end_src

**** ~#(so|sp|la|li|bo) *attrs, &draw_override~
Like ~#do~ except they return a class with the relevant attrs for their primitives predefined
#+begin_src
  def t a
    Sprite ||= P.sp { |ffi| ffi.dsp(@x, @y, @w, @h, :p, @an, 255, 0, 0, 0) }
    s = Sprite.new(w: 100, h: 100)
    s.x, s.y = a.m.p
    a.o.sp << s # Displays a black square at your mouse location
  end
#+end_src

**** ~#d(so|sp|la|li|bo) *attrs, &block~
Returns more specialized primitive classes where you can give ordered and keyword arguments and the given block is called before draw_override  

Note: ~#dsp(path=nil, *attrs, &block)~ Dsp has an initial path argument. The path argument can be used as a default for any instanced sprites
#+begin_src
  # Creates moving white circles wherever you click
  def t a
    S ||= P.dsp(:c,:ix,:iy) do
      @dx = 25*a.t.sin
      @dy = 25*a.t.cos
      @x  = @ix + @dx
      @y  = @iy + @dy
    end
    a.bg=[0,0,0]
    _SP! S.new(w: 100, h: 100, ix: a.m.x, iy: a.m.y) if a.m.c
  end
#+end_src
#{TweetcartDocs.format_aliases GTK::MainTweetcart.aliases}

S
  end

  def docs_args
    <<-S
*** args
**** Methods
**** ~#vp x, y, w, h, r = 0, g = 0, b = 0~
Push solids into outputs.primitives that cover everything but the specified area
#{TweetcartDocs.format_aliases GTK::Args::Tweetcart.aliases}

S
  end

  def docs_outputs
    <<-S
*** args.outputs
#{TweetcartDocs.format_aliases GTK::Outputs::Tweetcart.aliases}

S
  end

  def docs_inputs
    <<-S
*** args.inputs
#{TweetcartDocs.format_aliases GTK::Inputs::Tweetcart.aliases}

S
  end

  def docs_mouse
    <<-S
**** *.mouse
#{TweetcartDocs.format_aliases GTK::Mouse::Tweetcart.aliases}

S
  end

  def docs_keyboard
    <<-S
**** *.keyboard
#{TweetcartDocs.format_aliases GTK::Keyboard::Tweetcart.aliases}

S
  end

  def docs_geometry
    <<-S
*** args.geometry
Geometry methods available on Arrays and Hashes also include these aliases
#{TweetcartDocs.format_aliases GTK::Geometry::Tweetcart.singleton_aliases}

S
  end

  def docs_primitive_conversions
    <<-S
*** Primitive Conversions
Available on Arrays and Hashes
#{TweetcartDocs.format_aliases GTK::Primitive::ConversionCapabilities::Tweetcart.aliases}

S
  end

  def docs_ffidraw
    <<-S
*** FFIDraw
**** Methods
**** ~#d(so|sp|la|li|bo)~
Short aliases for ffi_draw methods that are used in draw overrides
#+begin_src
  class SomeSolid
    # solid things

    def draw_override(ffi_draw)
      ffi_draw.dso(@x, @y, @w, @h) # Unspecified parameters will be set to nil
    end
  end
#+end_src
S
  end

  def docs_enumerable
    <<-S
*** Enumerable
#{TweetcartDocs.format_aliases GTK::EnumerableTweetcart.aliases}

S
  end

  def docs_array
    <<-S
*** Array
#{TweetcartDocs.format_aliases GTK::ArrayTweetcart.aliases - GTK::Geometry::Tweetcart.aliases}

S
  end

  def docs_hash
    <<-S
*** Hash
#{TweetcartDocs.format_aliases GTK::HashTweetcart.aliases - GTK::Primitive::ConversionCapabilities::Tweetcart.aliases}

S
  end

  def docs_numeric
    <<-S
*** Numeric
**** Methods
#+begin_src
  r   = rand_ratio.to_i
  fl  = floor
  ce  = ceil
  dm  = divmod
  sin
  cos
#+end_src
#{TweetcartDocs.format_aliases GTK::NumericTweetcart.aliases}

S
  end

  def docs_integral
    <<-S
*** Integral
Available on Integers and Floats
#{TweetcartDocs.format_aliases GTK::IntegralTweetcart.aliases}

S
  end

  def docs_fixnum
    <<-S
*** Fixnum
#{TweetcartDocs.format_aliases GTK::FixnumTweetcart.aliases}

S
  end

  def docs_symbol
    <<-S
*** Symbol
**** Methods
**** ~#(so|sp|pr|la|li|bo|de)~
Shorthand methods to access and push into render targets
#+begin_src
  def t a
    :apple.so << [0, 0, 50, 50, 0, 0, 0] # Create rt :apple and push a black square into solids
    a.o.sp << [0, 0, 1280, 720, :apple, a.t] # Display a rotating square using :apple
  end
#+end_src

**** ~#[] *args, &block~
Returns a lambda that will send the given method name and arguments to an object
#+begin_src
  def [] *args, &block
    -> caller, *rest { caller.send self, *rest, *args, &block }
  end

  # This allows for syntax like:
  #-> [1, 2, 3].map &:add[5]
  #=> [6, 7, 8]

  #-> fn = :map[] { |i| i.map { i } }
  #-> fn.call([1, 2, 3])
  #=> [[1],[2, 2],[3, 3, 3]]
#+end_src

S
  end

  def docs_module
    <<-S
*** Module
#{TweetcartDocs.format_aliases GTK::ModuleTweetcart.aliases}

S
  end

  def docs_object
    <<-S
*** Object

**** ~#(SO! | SP! | PR! | LA! | LI! | BO!) *opts~
Aliases for pushing into outputs
#+begin_src
  def t a
    SO! [0, 0, 10, 10], [100, 100, 200, 200]
    # a.so << [[0, 0, 10, 10], [100, 100, 200, 200]]
  end
#+end_src

**** ~#(_SO! | _SP! | _PR! | _LA! | _LI! | _BO!) *opts~
Static outputs variants

**** ~#(PSO! | PSP! | PPR! | PLA! | PLI! | PBO!) *opts~
Persistent outputs variants

**** ~#PC!~
Persistence Clear
#+begin_src
  def t a
    a.bg = [0, 0, 0]

    PSP! [1280.r, 720.r, 100, 100, :p, 360.r, 255, 255.r, 255.r, 255.r] # It's a squarepocolypse!
    PC! if a.mc # Clears them all
  end
#+end_src
#{TweetcartDocs.format_aliases GTK::ObjectTweetcart.aliases}

S
  end
end

module GTK::Tweetcart
  extend Docs
  extend TweetcartDocs
end
