# coding: utf-8
# MIT License
# tweetcart_docs.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# - https://github.com/HIRO-R-B
# - https://github.com/oeloeloel
# - https://github.com/leviongit

module TweetcartDocs
  def docs_method_sort_order
    [
      :docs_class,
      :docs_built_in_render_targets,
      :docs_persistent_outputs,
      :docs_math,
      :docs_summary,
      :docs_args,
      :docs_inputs,
      :docs_keyboard,
      :docs_mouse,
      :docs_outputs,
      :docs_geometry,
      :docs_primitive_conversions,
      :docs_enumerable,
      :docs_array,
      :docs_hash,
      :docs_numerics,
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
You can access it using ~outputs.ps~ and clear it with ~outputs.psc~
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
  F  | 255
  W  | args.grid.w
  H  | args.grid.h
  PI | Math::PI
  E  | Math::E
#+end_src

**** ~#CI~
#+begin_src
  def CI(x, y, radius, r = 0, g = 0, b = 0, a = 255)
    [radius.to_square(x, y), :c, 0, a, r, g, b].sprite
  end
#+end_src
#{ TweetcartDocs.format_aliases GTK::Tweetcart.aliases }

S
  end

  def docs_args
    <<-S
*** args
#{ TweetcartDocs.format_aliases GTK::Args::Tweetcart.aliases }

S
  end

  def docs_inputs
    <<-S
*** args.inputs
#{ TweetcartDocs.format_aliases GTK::Inputs::Tweetcart.aliases }

S
  end

  def docs_mouse
    <<-S
**** *.mouse
#{ TweetcartDocs.format_aliases GTK::Mouse::Tweetcart.aliases }

S
  end

  def docs_keyboard
    <<-S
**** *.keyboard
#{ TweetcartDocs.format_aliases GTK::Keyboard::Tweetcart.aliases }

S
  end

  def docs_outputs
    <<-S
*** args.outputs
#{ TweetcartDocs.format_aliases GTK::Outputs::Tweetcart.aliases }

S
  end

  def docs_geometry
    <<-S
*** args.geometry
Geometry methods available on Arrays and Hashes also include these aliases
#{ TweetcartDocs.format_aliases GTK::Geometry::Tweetcart.aliases + GTK::Geometry::Tweetcart.aliases_extended }

S
  end

  def docs_primitive_conversions
    <<-S
*** Primitive Conversions
Available on Arrays and Hashes
#{ TweetcartDocs.format_aliases GTK::Primitive::ConversionCapabilities::Tweetcart.aliases }

S
  end

  def docs_enumerable
    <<-S
*** Enumerable
#{ TweetcartDocs.format_aliases GTK::EnumerableTweetcart.aliases }

S
  end

  def docs_array
    <<-S
*** Array
#{ TweetcartDocs.format_aliases GTK::ArrayTweetcart.aliases - GTK::Geometry::Tweetcart.aliases }

S
  end

  def docs_hash
    <<-S
*** Hash
#{ TweetcartDocs.format_aliases GTK::HashTweetcart.aliases - GTK::Primitive::ConversionCapabilities::Tweetcart.aliases }

S
  end

  def docs_numerics
    <<-S
*** Numerics
**** ~#r~
#+begin_src
  def r
    rand_ratio.to_i
  end
#+end_src
**** ~#dm~
#+begin_src
  def dm x
    divmod x
  end
#+end_src
#{ TweetcartDocs.format_aliases GTK::NumericTweetcart.aliases + GTK::FixnumTweetcart.aliases }

S
  end

  def docs_symbol
    <<-S
*** Symbol
**** ~#[]~
#+begin_src
  def [] *args, &block
    -> caller, *rest { caller.send self, *rest, *args, &block }
  end
#+end_src
This allows for syntax like ~[1, 2, 3].map &:add[5]~

S
  end

  def docs_module
    <<-S
*** Module
#{ TweetcartDocs.format_aliases GTK::ModuleTweetcart.aliases }
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
#{ TweetcartDocs.format_aliases GTK::ObjectTweetcart.aliases }

S
  end

  def self.format_aliases aliases
    max_length = aliases.each_slice(2).map { |new, _| new.length }.max
    out = aliases.each_slice(2).map { |new, old| "  #{new}#{' ' * (max_length - new.length)} | #{old}" }.join("\n")
    "**** Aliases\n#+begin_src\n#{out}\n#+end_src"
  end
end

module GTK::Tweetcart
  extend Docs
  extend TweetcartDocs
end
