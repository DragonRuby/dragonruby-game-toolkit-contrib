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
      :docs_sprites,
      :docs_labels,
      :docs_primitives
    ]
  end

  def docs_class
    <<-'S'
* Outputs (~args.outputs~)

Outputs is how you render primitives to the screen. The minimal setup for
rendering something to the screen is via a ~tick~ method defined in
mygame/app/main.rb

#+begin_src
  def tick args
    args.outputs.solids     << { x: 0, y: 0, w: 100, h: 100 }
    args.outputs.sprites    << { x: 100, y: 100, w: 100, h: 100, path: "sprites/square/blue.png" }
    args.outputs.labels     << { x: 200, y: 200, text: "Hello World" }
    args.outputs.borders    << { x: 0, y: 0, w: 100, h: 100 }
    args.outputs.lines      << { x: 300, y: 300, x2: 400, y2: 400 }
  end
#+end_src

** Collection Render Orders

Primitives are rendered first-in, first-out. The rendering order (sorted by bottom-most to top-most):

- ~solids~
- ~sprites~
- ~primitives~: Accepts all render primitives. Useful when you want to bypass the default rendering orders for rendering (eg. rendering solids on top of sprites).
- ~labels~
- ~lines~
- ~borders~
- ~debug~: Accepts all render primitives. Use this to render primitives for debugging (production builds of your game will not render this layer).

** Primitives Collection (~args.outputs.primitives~)

~args.outputs.primitives~ can take in any primitive and will render first in, first out.

For example, you can render a ~solid~ above a ~sprite~:

#+begin_src
  def tick args
    args.outputs.primitives << { x: 100, y: 100,
                                 w: 100, h: 100,
                                 path: "sprites/square/blue.png" }
    args.outputs.primitives << { x: 0, y: 0, w: 100, h: 100, primitive_marker: :solid }
    args.outputs.primitives << { x: 0, y: 0, w: 100, h: 100, primitive_marker: :border }
  end
#+end_src

** Debug Collection (~args.outputs.debug~)

~args.outputs.debug~ will not render in production mode and behaves like ~args.outputs.primitives~. Objects in this collection
are rendered above everything.

Additionally, ~args.outputs.debug~ allows you to pass in a ~String~ as a primitive type. This is helpful for quickly showing the
value of a variable on the screen. A label with black text and a white background will be created for each ~String~ sent in. The
labels will be automatically stacked vertically for you.

Example:

#+begin_src
  def tick args
    args.state.player ||= { x: 100, y: 100 }
    args.state.player.x += 1
    args.state.player.x = 0 if args.state.player.x > 1280

    # the following string values will generate labels with backgrounds
    # and will auto stack vertically
    args.outputs.debug << "current tick: #{args.state.tick_count}"
    args.outputs.debug << "player x: #{args.state.player.x}"
  end
#+end_src
S
  end

  def docs_borders
    <<-'S'
** ~borders~

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
    <<-'S'
** ~solids~

Add primitives to this collection to render a solid to the screen.

*** Rendering a solid using an Array

Creates a solid black rectangle located at 100, 100. 160 pixels
wide and 90 pixels tall.

#+begin_src
  def tick args
    #                         X    Y  WIDTH  HEIGHT
    args.outputs.solids << [100, 100,   160,     90]
  end
#+end_src

*** Rendering a solid using an Array with colors and alpha

The value for the color and alpha is a number between ~0~ and ~255~. The
alpha property is optional and will be set to ~255~ if not specified.

Creates a green solid rectangle with an opacity of 50%.

#+begin_src
  def tick args
    #                         X    Y  WIDTH  HEIGHT  RED  GREEN  BLUE  ALPHA
    args.outputs.solids << [100, 100,   160,     90,   0,   255,    0,   128]
  end
#+end_src

*** Rendering a solid using a Hash

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
      a:  255,
      anchor_x: 0,
      anchor_y: 0,
      blendmode_enum: 1
    }
  end
#+end_src

*** Rendering a solid using a Class

You can also create a class with solid properties and render it as a primitive.
ALL properties must be on the class. *Additionally*, a method called ~primitive_marker~
must be defined on the class.

Here is an example:

#+begin_src
  # Create type with ALL solid properties AND primitive_marker
  class Solid
    attr_accessor :x, :y, :w, :h, :r, :g, :b, :a, :anchor_x, :anchor_y, :blendmode_enum

    def primitive_marker
      :solid # or :border
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
    <<-'S'
** ~sprites~

Add primitives to this collection to render a sprite to the screen.

*** Rendering a sprite using an Array

Creates a sprite of a white circle located at 100, 100. 160 pixels
wide and 90 pixels tall.

#+begin_src
  def tick args
    #                         X    Y   WIDTH   HEIGHT                      PATH
    args.outputs.sprites << [100, 100,   160,     90, "sprites/circle/white.png"]
  end
#+end_src

*** Rendering a sprite using a Hash

If you want a more readable (and faster) invocation, you can use the following hash to create a sprite.
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

Here are all the properties that you can set on a sprite. The only required ones are ~x~, ~y~, ~w~, ~h~, and ~path~.

**** Required properties
- ~x~: X position of the sprite. Note: the botton left corner of the sprite is used for positioning (this can be changed using ~anchor_x~, and ~anchor_y~).
- ~y~: Y position of the sprite. Note: The origin 0,0 is at the bottom left corner. Setting ~y~ to a higher value will move the sprite upwards.
- ~w~: The render width.
- ~h~: The render height.
- ~path~: The path of the sprite relative to the game folder.

**** Anchors and Rotations
- ~flip_horizonally~: This value can be either ~true~ or ~false~ and controls if the sprite will be flipped horizontally (default value is false).
- ~flip_vertically~: This value can be either ~true~ or ~false~ and controls if the sprite will be flipped horizontally (default value is false).
- ~anchor_x~: Used to determine anchor point of the sprite's X position (relative to the render width).
- ~anchor_y~: Used to determine anchor point of the sprite's Y position (relative to the render height).
- ~angle~: Rotation of the sprite in degrees (default value is 0). Rotation occurs around the center of the sprite. The point of rotation can be changed using ~angle_anchor_x~ and ~angle_anchor_y~.
- ~angle_anchor_x~: Controls the point of rotation for the sprite (relative to the render width).
- ~angle_anchor_y~: Controls the point of rotation for the sprite (relative to the render height).

Here's an example of rendering a 80x80 pixel sprite in the center of the screen:

#+begin_src
  def tick args
    args.outputs.sprites << {
      x: 640 - 40, # the logical center of the screen horizontally is 640, minus half the width of the sprite
      y: 360 - 40, # the logical center of the screen vertically is 360, minus half the height of the sprite
      w: 80,
      h: 80,
      path: "sprites/square/blue.png"
   }
  end
#+end_src

Instead of computing the offset, you can use ~anchor_x~, and ~anchor_y~ to center the sprite. The following is equivalent to the code above:

#+begin_src
  def tick args
    args.outputs.sprites << {
      x: 640,
      y: 360,
      w: 80,
      h: 80,
      path: "sprites/square/blue.png",
      anchor_x: 0.5, # position horizontally at 0.5 of the sprite's width
      anchor_y: 0.5  # position vertically at 0.5 of the sprite's height
   }
  end
#+end_src

**** Cropping Properties
- ~tile_(x|y|w|h)~: Defines the crop area to use for a sprite. The origin for ~tile_~ properties uses the TOP LEFT as its origin (useful for cropping tiles from a sprite sheet).
- ~source_(x|y|w|h)~: Defines the crop area to use for a sprite. The origin for ~tile_~ properties uses the BOTTOM LEFT as its origin.

See the sample apps under ~./samples/03_rendering_sprites~ for examples of how to use this properties non-trivially.

**** Blending Options
- ~a~: Alpha/transparency of the sprite from 0 to 255 (default value is 255).
- ~r~: Level of red saturation for the sprite (default value is 255). Example: Setting the value to zero will remove all red coloration from the sprite.
- ~g~: Level of green saturation for the sprite (default value is 255).
- ~b~: Level of blue saturation for the sprite (default value is 255).
- ~blendmode_enum~: Valid options are ~0~: no blending, ~1~: default/alpha blending, ~2~: addative blending, ~3~: modulo blending, ~4~: multiply blending.

The following sample apps show how ~blendmode_enum~ can be leveraged to create coloring and lighting effects:

- ~./samples/07_advanced_rendering/11_blend_modes~
- ~./samples/07_advanced_rendering/13_lighting~

**** Triagles (Indie, Pro Feature)
Sprites can be rendered as triangles at the Indie and Pro License Tiers. To rendering using triangles,
instead of providing a ~w~, ~h~ property, provide ~x2~, ~y2~, ~x3~, ~y3~. This applies for positioning and cropping.

Here is an example:

#+begin_src
  def tick args
    args.outputs.sprites << {
      x: 0,
      y: 0,
      x2: 80,
      y2: 0,
      x3: 0,
      y3: 80,
      source_x: 0,
      source_y: 0,
      source_x2: 80,
      source_y2: 0,
      source_x3: 0,
      source_y3: 80,
      path: "sprites/square/blue.png"
    }
  end
#+end_src

For more example of rendering using triangles see:

- ~./samples/07_advanced_rendering/14_triangles~
- ~./samples/07_advanced_rendering/15_triangles_trapezoid~
- ~./samples/07_advanced_rendering/16_matrix_and_triangles_2d~
- ~./samples/07_advanced_rendering/16_matrix_and_triangles_3d~
- ~./samples/07_advanced_rendering/16_matrix_cubeworld~

*** Rendering a sprite using a Class

You can also create a class with solid/border properties and render it as a primitive.
ALL properties must be on the class. *Additionally*, a method called ~primitive_marker~
must be defined on the class.

Here is an example:

#+begin_src
  # Create type with ALL sprite properties AND primitive_marker
  class Sprite
    attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x,
                  :tile_y, :tile_w, :tile_h, :flip_horizontally,
                  :flip_vertically, :angle_anchor_x, :angle_anchor_y, :id,
                  :angle_x, :angle_y, :z,
                  :source_x, :source_y, :source_w, :source_h, :blendmode_enum,
                  :source_x2, :source_y2, :source_x3, :source_y3, :x2, :y2, :x3, :y3,
                  :anchor_x, :anchor_y

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

    def serialize
      {x:self.x, y:self.y, w:self.w, h:self.h, path:self.path}
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  def tick args
    # render circle sprite
    args.outputs.sprites  << Circle.new(10, 10, 32,"sprites/circle/white.png")
  end
#+end_src

*** ~attr_sprite~
The ~attr_sprite~ class macro adds all properties needed to render a sprite to a class. This removes
the need to manually define all sprites properties that DragonRuby offers for rendering.

Instead of manually defining the properties, you can represent a sprite using the ~attr_sprite~ class macro:

#+begin_src
  class BlueSquare
    # invoke the helper function at the class level for
    # anything you want to represent as a sprite
    attr_sprite

    def initialize(x: 0, y: 0, w: 0, h: 0)
      @x = x
      @y = y
      @w = w
      @h = h
      @path = 'sprites/square-blue.png'
    end
  end

  def tick args
    args.outputs.sprites << BlueSquare.new(x: 640 - 50,
                                           y: 360 - 50,
                                           w: 50,
                                           h: 50)
  end
#+end_src
S
  end

  def docs_labels
    <<-'S'
** ~labels~

Add primitives to this collection to render a label.

*** Rendering a label using an Array

Labels represented as Arrays/Tuples:

#+begin_src
  def tick args
                           #        X         Y              TEXT   SIZE_ENUM
    args.outputs.labels << [175 + 150, 610 - 50, "Smaller label.",         0]
  end
#+end_src

Here are all the properties that you can set with a
label represented as an Array. It's recommended to move over to
using Hashes once you've specified a lot of properties.

#+begin_src
  def tick args
    args.outputs.labels << [
      640,                   # X
      360,                   # Y
      "Hello world",         # TEXT
      0,                     # SIZE_ENUM
      1,                     # ALIGNMENT_ENUM
      0,                     # RED
      0,                     # GREEN
      0,                     # BLUE
      255,                   # ALPHA
      "fonts/coolfont.ttf"   # FONT
    ]
  end
end
#+end_src

*** Rendering a label using a Hash

#+begin_src
  def tick args
    args.outputs.labels << {
        x:                       200,
        y:                       550,
        text:                    "dragonruby",
        size_enum:               2,
        alignment_enum:          1, # 0 = left, 1 = center, 2 = right
        r:                       155,
        g:                       50,
        b:                       50,
        a:                       255,
        font:                    "fonts/manaspc.ttf",
        vertical_alignment_enum: 0  # 0 = bottom, 1 = center, 2 = top
    }
  end
#+end_src
S
  end

  def docs_screenshots
    <<-'S'
** ~Screenshots~

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

*** Chroma key (Making a color transparent)

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
