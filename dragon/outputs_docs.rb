# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# outputs_docs.rb has been released under MIT (*only this file*).

module OutputsDocs
  def docs_class
    <<-S
* DOCS: ~GTK::Outputs~

Outputs is how you render primitives to the screen. The minimal setup for
rendering something to the screen is via a ~tick~ method defined in
mygame/app/main.rb

#+begin_src
  def tick args
    # code goes here
  end
#+end_src

S
  end

  def docs_borders
    <<-S
* DOCS: ~GTK::Outputs#borders~

Add primitives to this collection to render an unfilled solid to the screen. Take a look at the
documentation for Outputs#solids.

The only difference between the two primitives is where they are added.

Instead of using ~args.outputs.solids~:

#+begin_src
  def tick args
    #                         X    Y  WIDTH  HEIGHT
    args.outputs.solids << [100, 100,   160,     90]
  end
#+end_src

You have to use ~args.outputs.borders~:

#+begin_src
  def tick args
    #                           X    Y  WIDTH  HEIGHT
    args.outputs.borders << [100, 100,   160,     90]
  end
#+end_src

S
  end

  def docs_solids
    <<-S
* DOCS: ~GTK::Outputs#solids~

Add primitives to this collection to render a solid to the screen.

** Rendering a solid using an Array

Creates a solid black rectangle located at 100, 100. 160 pixels
wide and 90 pixels tall.

#+begin_src
  def tick args
    #                         X    Y  WIDTH  HEIGHT
    args.outputs.solids << [100, 100,   160,     90]
  end
#+end_src

** Rendering a solid using an Array with colors and alpha

The value for the color and alpha is an number between ~0~ and ~255~. The
alpha property is optional and will be set to ~255~ if not specified.

Creates a green solid rectangle with an opacity of 50%.

#+begin_src
  def tick args
    #                         X    Y  WIDTH  HEIGHT  RED  GREEN  BLUE  ALPHA
    args.outputs.solids << [100, 100,   160,     90,   0,   255,    0,   128]
  end
#+end_src

** Rendering a solid using a Hash

If you want a more readable invocation. You can use the following hash to create a solid.
Any parameters that are not specified will be given a default value. The keys of the hash can
be provided in any order.

#+begin_src
  def tick args
    args.outputs.solids << {
      x:    0,
      y:    0,
      w:  100,
      h:  100,
      r:    0,
      g:  255,
      b:    0,
      a:  255
    }
  end
#+end_src

** Rendering a solid using a Class

You can also create a class with solid/border properties and render it as a primitive.
ALL properties must on the class. *Additionally*, a method called ~primitive_marker~
must be defined on the class.

Here is an example:

#+begin_src
  # Create type with ALL solid properties AND primitive_marker
  class Solid
    attr_accessor :x, :y, :w, :h, :r, :g, :b, :a

    def primitive_marker
      :solid
    end
  end

  # Inherit from type
  class Square < Solid
    # constructor
    def initialize x, y, size
      self.x = x
      self.y = y
      self.w = size
      self.h = size
    end
  end

  def tick args
    # render solid/border
    args.outputs.solids  << Square.new(10, 10, 32)
  end
#+end_src

S
  end
end

class GTK::Outputs
  extend Docs
  extend OutputsDocs
end
