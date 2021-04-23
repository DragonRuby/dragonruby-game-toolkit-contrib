# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# outputs_docs.rb has been released under MIT (*only this file*).

module OutputsDocs
  def docs_method_sort_order
    [
      :docs_class,
      :docs_solids,
      :docs_borders,
      :docs_sprites
    ]
  end

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

The value for the color and alpha is a number between ~0~ and ~255~. The
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
ALL properties must be on the class. *Additionally*, a method called ~primitive_marker~
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
  
  def docs_sprites
    <<-S
* DOCS: ~GTK::Outputs#sprites~

Add primitives to this collection to render a sprite to the screen.

** Rendering a sprite using an Array

Creates a sprite of a white circle located at 100, 100. 160 pixels
wide and 90 pixels tall.

#+begin_src
  def tick args
    #                         X    Y   WIDTH   HEIGHT                      PATH
    args.outputs.sprites << [100, 100,   160,     90, "sprites/circle/white.png]
  end
#+end_src

** Rendering a sprite using an Array with colors and alpha

The value for the color and alpha is a number between ~0~ and ~255~. The
alpha property is optional and will be set to ~255~ if not specified.

Creates a green circle sprite with an opacity of 50%.

#+begin_src
  def tick args
    #                         X    Y  WIDTH  HEIGHT           PATH                ANGLE  ALPHA  RED  GREEN  BLUE
    args.outputs.sprites << [100, 100,  160,     90, "sprites/circle/white.png",     0,    128,   0,   255,    0]
  end
#+end_src

** Rendering a sprite using a Hash

If you want a more readable invocation. You can use the following hash to create a sprite.
Any parameters that are not specified will be given a default value. The keys of the hash can
be provided in any order.

#+begin_src
  def tick args
    args.outputs.sprites << {
      x:                             0,
      y:                             0,
      w:                           100,
      h:                           100,
      path: "sprites/circle/white.png",
      angle:                         0,
      a:                           255,
      r:                             0,
      g:                           255,
      b:                             0
    }
  end
#+end_src

** Rendering a solid using a Class

You can also create a class with solid/border properties and render it as a primitive.
ALL properties must be on the class. *Additionally*, a method called ~primitive_marker~
must be defined on the class.

Here is an example:

#+begin_src
  # Create type with ALL sprite properties AND primitive_marker
  class Sprite
    attr_accessor :x, :y, :w, :h, :path, :angle, :angle_anchor_x, :angle_anchor_y,  :tile_x, :tile_y, :tile_w, :tile_h, :source_x, :source_y, :source_w, :source_h, :flip_horizontally, :flip_vertically, :a, :r, :g, :b

    def primitive_marker
      :sprite
    end
  end

  # Inherit from type
  class Circle < Sprite
  # constructor
    def initialize x, y, size, path
      self.x = x
      self.y = y
      self.w = size
      self.h = size
      self.path = path
    end
    def serlialize
      {x:self.x, y:self.y, w:self.w, h:self.h, path:self.path}
    end

    def inspect
      serlialize.to_s
    end

    def to_s
      serlialize.to_s
    end
  end
  def tick args
    # render circle sprite
    args.outputs.sprites  << Circle.new(10, 10, 32,"sprites/circle/white.png")
  end
#+end_src

S
  end


  def docs_screenshots
    <<-S
* DOCS: ~GTK::Outputs#screenshots~

Add a hash to this collection to take a screenshot and save as png file.
The keys of the hash can be provided in any order.

#+begin_src
  def tick args
    args.outputs.screenshots << {
      x: 0, y: 0, w: 100, h: 100,    # Which portion of the screen should be captured
      path: 'screenshot.png',        # Output path of PNG file (inside game directory)
      r: 255, g: 255, b: 255, a: 0   # Optional chroma key
    }
  end
#+end_src

** Chroma key (Making a color transparent)

By specifying the r, g, b and a keys of the hash you change the transparency of a color in the resulting PNG file.
This can be useful if you want to create files with transparent background like spritesheets.
The transparency of the color specified by ~r~, ~g~, ~b~ will be set to the transparency specified by ~a~.

The example above sets the color white (255, 255, 255) as transparent.
S
  end
end

class GTK::Outputs
  extend Docs
  extend OutputsDocs
end
