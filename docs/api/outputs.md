# Outputs (`args.outputs`)

Outputs is how you render primitives to the screen. The minimal setup for
rendering something to the screen is via a `tick` method defined in
mygame/app/main.rb

```ruby
def tick args
  args.outputs.solids     << { x: 0, y: 0, w: 100, h: 100 }
  args.outputs.sprites    << { x: 100, y: 100, w: 100, h: 100, path: "sprites/square/blue.png" }
  args.outputs.labels     << { x: 200, y: 200, text: "Hello World" }
  args.outputs.borders    << { x: 0, y: 0, w: 100, h: 100 }
  args.outputs.lines      << { x: 300, y: 300, x2: 400, y2: 400 }
end
```

## Collection Render Orders

Primitives are rendered first-in, first-out. The rendering order (sorted by bottom-most to top-most):

- `solids`
- `sprites`
- `primitives`: Accepts all render primitives. Useful when you want to bypass the default rendering orders for rendering (eg. rendering solids on top of sprites).
- `labels`
- `lines`
- `borders`
- `debug`: Accepts all render primitives. Use this to render primitives for debugging (production builds of your game will not render this layer).

## `primitives`

`args.outputs.primitives` can take in any primitive and will render first in, first out.

For example, you can render a `solid` above a `sprite`:

```ruby
def tick args
  # sprite
  args.outputs.primitives << { x: 100, y: 100,
                               w: 100, h: 100,
                               path: "sprites/square/blue.png" }

  # solid
  args.outputs.primitives << { x: 0,
                               y: 0,
                               w: 100,
                               h: 100,
                               primitive_marker: :solid }

  # border
  args.outputs.primitives << { x: 0,
                               y: 0,
                               w: 100,
                               h: 100,
                               primitive_marker: :border }

  # label
  args.outputs.primitives << { x: 100, y: 100,
                               text: "hello world" }

  # line
  args.outputs.primitives << { x: 100, y: 100, x2: 150, y2: 150 }
end
```

## `debug`

`args.outputs.debug` will not render in production mode and behaves like `args.outputs.primitives`. Objects in this collection
are rendered above everything.

### String Primitives

Additionally, `args.outputs.debug` allows you to pass in a `String` as a primitive type. This is helpful for quickly showing the
value of a variable on the screen. A label with black text and a white background will be created for each `String` sent in. The
labels will be automatically stacked vertically for you. New lines in the string will be respected.

Example:

```ruby
def tick args
  args.state.player ||= { x: 100, y: 100 }
  args.state.player.x += 1
  args.state.player.x = 0 if args.state.player.x > 1280

  # the following string values will generate labels with backgrounds
  # and will auto stack vertically
  args.outputs.debug << "current tick: #{Kernel.tick_count}"
  args.outputs.debug << "player x: #{args.state.player.x}"
  args.outputs.debug << "hello\nworld"
end
```

### `watch`

If you need additional control over a string value, you can use the `args.outputs.debug.watch` function.

The functions takes in the following parameters:

- Object to watch. This object will be converted to a string.
- The `label_style`: optional, named argument can be passed in with a `Hash` to override the default label style for watch variables.
- The `background_style`: optional named argument can be passed in with a `Hash` to override the default background style for the watch variables.

Example:

```ruby
def tick args
  args.state.player ||= { x: 100, y: 100 }
  args.state.player.x += 1
  args.state.player.x = 0 if args.state.player.x > 1280

  args.outputs.debug.watch args.state.player
  args.outputs.debug.watch pretty_format(args.state.player),
                           label_style: { r: 0,
                                          g: 0,
                                          b: 255,
                                          size_px: 10 },
                           background_style: { r: 0,
                                               g: 255,
                                               b: 0,
                                               a: 128,
                                               path: :solid }
end
```

## `solids`

Add primitives to this collection to render a solid to the screen.

!> This render primitive is fine to use sparingly. If you find
yourself rendering a large number of solids, render `sprites` instead
(the textures that solid primitives generate are not cached and do not
perform as well as rendering sprites).

For example, the following `solid` and `sprite` are equivalent:

```ruby
def tick args
  args.outputs.solids << {
    x: 0,
    y: 0,
    w: 100,
    h: 100,
    r: 255,
    g: 255,
    b: 255,
    a: 128
  }

  # is equivalent to

  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 100,
    h: 100,
    path: :solid,
    r: 255,
    g: 255,
    b: 255,
    a: 128
  }
end
```

### Array Render Primitive

Creates a solid black rectangle located at 100, 100. 160 pixels
wide and 90 pixels tall.

```ruby
def tick args
  #                         X    Y  WIDTH  HEIGHT
  args.outputs.solids << [100, 100,   160,     90]
end
```

!> `Array`-based primitives are find for debugging purposes/quick prototypes. But should
not be used as the default rendering approach. Use `Hash`-based or `Class`-based primitives.

While not recommended for long term maintainability, you can also set the following properties.

Example Creates a green solid rectangle with an opacity of 50% (the value for the color and alpha is a number between `0` and `255`, the alpha property is optional and will be set to `255` if not specified):

```ruby
def tick args
  #                         X    Y  WIDTH  HEIGHT  RED  GREEN  BLUE  ALPHA
  args.outputs.solids << [100, 100,   160,     90,   0,   255,    0,   128]
end
```

### Hash Render Primitive

If you want a more readable invocation. You can use the following hash to create a solid.
Any parameters that are not specified will be given a default value. The keys of the hash can
be provided in any order.

```ruby
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
```

### Class Render Primitive

You can also create a class with solid properties and render it as a primitive.
ALL properties must be on the class. **Additionally**, a method called `primitive_marker`
must be defined on the class.

Here is an example:

```ruby
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
```

## `borders`

Add primitives to this collection to render an unfilled solid to the screen. Take a look at the
documentation for Outputs#solids.

The only difference between the two primitives is where they are added.

Instead of using `args.outputs.solids`:

```ruby
def tick args
  #                         X    Y  WIDTH  HEIGHT
  args.outputs.solids << [100, 100,   160,     90]
end
```

You have to use `args.outputs.borders`:

```ruby
def tick args
  #                           X    Y  WIDTH  HEIGHT
  args.outputs.borders << [100, 100,   160,     90]
end
```

## `sprites`

Add primitives to this collection to render a sprite to the screen.

### Properties

Here are all the properties that you can set on a sprite. The only required ones are `x`, `y`, `w`, `h`, and `path`.

#### Required

- `x`: X position of the sprite. Note: the bottom left corner of the sprite is used for positioning (this can be changed using `anchor_x`, and `anchor_y`).
- `y`: Y position of the sprite. Note: The origin 0,0 is at the bottom left corner. Setting `y` to a higher value will move the sprite upwards.
- `w`: The render width.
- `h`: The render height.
- `path`: The path of the sprite relative to the game folder.

#### Anchors and Rotations

- `flip_horizontally`: This value can be either `true` or `false` and controls if the sprite will be flipped horizontally (default value is false).
- `flip_vertically`: This value can be either `true` or `false` and controls if the sprite will be flipped vertically (default value is false).
- `anchor_x`: Used to determine anchor point of the sprite's X position (relative to the render width).
- `anchor_y`: Used to determine anchor point of the sprite's Y position (relative to the render height).
- `angle`: Rotation of the sprite in degrees (default value is 0). Rotation occurs around the center of the sprite. The point of rotation can be changed using `angle_anchor_x` and `angle_anchor_y`.
- `angle_anchor_x`: Controls the point of rotation for the sprite (relative to the render width).
- `angle_anchor_y`: Controls the point of rotation for the sprite (relative to the render height).
    
Here's an example of rendering a 80x80 pixel sprite in the center of the screen:

```ruby
def tick args
  args.outputs.sprites << {
    x: 640 - 40, # the logical center of the screen horizontally is 640, minus half the width of the sprite
    y: 360 - 40, # the logical center of the screen vertically is 360, minus half the height of the sprite
    w: 80,
    h: 80,
    path: "sprites/square/blue.png"
 }
end
```

Instead of computing the offset, you can use `anchor_x`, and `anchor_y` to center the sprite. The following is equivalent to the code above:

```ruby
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
```

#### Cropping

- `tile_(x|y|w|h)`: Defines the crop area to use for a sprite. The origin for `tile_` properties uses the TOP LEFT as its origin (useful for cropping tiles from a sprite sheet).
- `source_(x|y|w|h)`: Defines the crop area to use for a sprite. The origin for `source_` properties uses the BOTTOM LEFT as its origin.

See the sample apps under `./samples/03_rendering_sprites` for examples of how to use this properties non-trivially.

#### Blending

- `a`: Alpha/transparency of the sprite from 0 to 255 (default value is 255).
- `r`: Level of red saturation for the sprite (default value is 255). Example: Setting the value to zero will remove all red coloration from the sprite.
- `g`: Level of green saturation for the sprite (default value is 255).
- `b`: Level of blue saturation for the sprite (default value is 255).
- `blendmode_enum`: Valid options are `0`: no blending, `1`: default/alpha blending, `2`: additive blending, `3`: modulo blending, `4`: multiply blending.
- `scale_quality_enum`: Valid options are `0`: nearest neighbor, `1`: linear scaling, `2`: anti-aliasing. If the value is `nil` then the `scale_quality` value that was set in `mygame/game_metadata.txt` will be used.

The following sample apps show how `blendmode_enum` can be leveraged to create coloring and lighting effects:

- `./samples/07_advanced_rendering/11_blend_modes`
- `./samples/07_advanced_rendering/13_lighting`

#### Triangles

To rendering using triangles, instead of providing a `w`, `h` property, provide `x2`, `y2`, `x3`, `y3`. This applies for positioning and cropping.

Here is an example:

```ruby
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
```

For more example of rendering using triangles see:

- `./samples/07_advanced_rendering/14_triangles`
- `./samples/07_advanced_rendering/15_triangles_trapezoid`
- `./samples/07_advanced_rendering/16_matrix_and_triangles_2d`
- `./samples/07_advanced_rendering/16_matrix_and_triangles_3d`
- `./samples/07_advanced_rendering/16_matrix_cubeworld`

### Array Render Primitive

Creates a sprite of a white circle located at 100, 100. 160 pixels
wide and 90 pixels tall.

```ruby
def tick args
  #                         X    Y   WIDTH   HEIGHT                      PATH
  args.outputs.sprites << [100, 100,   160,     90, "sprites/circle/white.png"]
end
```

!> Array-based sprites have limited access to sprite properties, but
nice for quick prototyping. Use a `Hash` or `Class` to 
gain access to all properties, gain long term maintainability of code,
and a boost in rendering performance. 

### Hash Render Primitive

If you want a more readable (and faster) invocation, you can use the following hash to create a sprite.
Any parameters that are not specified will be given a default value. The keys of the hash can
be provided in any order.

```ruby
def tick args
  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 100,
    h: 100,
    path: "sprites/circle/white.png",
    angle: 0,
    a: 255
  }
end
```

### Class Render Primitive

You can also create a class with sprite properties and render it as a primitive.
ALL properties must be on the class. **Additionally**, a method called `primitive_marker`
must be defined on the class.

Here is an example:

```ruby
# Create type with ALL sprite properties AND primitive_marker
class Sprite
  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x,
                :tile_y, :tile_w, :tile_h, :flip_horizontally,
                :flip_vertically, :angle_anchor_x, :angle_anchor_y, :id,
                :angle_x, :angle_y, :z,
                :source_x, :source_y, :source_w, :source_h, :blendmode_enum,
                :source_x2, :source_y2, :source_x3, :source_y3, :x2, :y2, :x3, :y3,
                :anchor_x, :anchor_y, :scale_quality_enum

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
```

### `attr_sprite`

The `attr_sprite` class macro adds all properties needed to render a sprite to a class. This removes
the need to manually define all sprites properties that DragonRuby offers for rendering.

Instead of manually defining the properties, you can represent a sprite using the `attr_sprite` class macro:

```ruby
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
```

## `lines`

Add primitives to this collection to render a line.

### Array Render Primitive

```ruby
def tick args
                         #  X    Y   X2   Y2
  args.outputs.lines << [100, 100, 150, 150]
end
```

!> `Array`-based primitives are find for debugging purposes/quick prototypes. But should
not be used as the default rendering approach. Use `Hash`-based or `Class`-based primitives.

### Hash Render Primitive

```ruby
def tick args
  args.outputs.lines << {
    x:  100,
    y:  100,
    x2: 150,
    y2: 150,
    r:  0,
    g:  0,
    b:  0,
    a:  255,
    blendmode_enum: 1
  }
end
```

### Class Render Primitive

```ruby
# Create type with ALL line properties AND primitive_marker
class Line
  attr_accessor :x, :y, :x2, :y2, :r, :g, :b, :a, :blendmode_enum

  def primitive_marker
    :line
  end
end

# Inherit from type
class RedLine < Line
  # constructor
  def initialize x, y, x2, y2
    self.x = x
    self.y = y
    self.x2 = x2
    self.y2 = y2
    self.r  = 255
    self.g  = 0
    self.b  = 0
    self.a  = 255
  end
end

def tick args
  # render line
  args.outputs.lines << RedLine.new(100, 100, 150, 150)
end

```

## `labels`

Add primitives to this collection to render a label.

### Array Render Primitive

Labels represented as Arrays/Tuples:

```ruby
def tick args
                         #        X         Y              TEXT   SIZE_ENUM
  args.outputs.labels << [175 + 150, 610 - 50, "Smaller label.",         0]
end
```

Here are all the properties that you can set with a
label represented as an Array. It's recommended to move over to
using Hashes once you've specified a lot of properties.

```ruby
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
```

!> `Array`-based primitives are find for debugging purposes/quick prototypes. But should
not be used as the default rendering approach. Use `Hash`-based or `Class`-based primitives.

### Hash Render Primitive

?> `size_enum` is an opaque unit and signifies the recommended size for labels. The default `size_enum` of `0`
means "this size is the smallest font size that is comfortable to read on a hand-held device". `size_enum` of `0`
corresponds to `22px` at `720p`. Each increment of `size_enum` increases/decreases the pixels by `2` (`size_enum` of `1` means `24px`,
`size_enum` of `-1` means `20px`, etc). If you want to control the size of a label explicitly, use `size_px` instead.

```ruby
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
      vertical_alignment_enum: 0  # 0 = bottom, 1 = center, 2 = top,
      anchor_x:                0, # if provided, alignment_enum is ignored
      anchor_y:                1, # if provided, vertical_alignment_enum is ignored,
      size_px:                 30, # if provided, size_enum is ignored.
      blendmode_enum:          1
  }
end
```

### Class Render Primitive

```ruby
# Create type with ALL label properties AND primitive_marker
class Label
  attr_accessor :x, :y, :w, :h, :r, :g, :b, :a, :text, :font, :anchor_x,
                :anchor_y, :blendmode_enum, :size_px, :size_enum, :alignment_enum,
                :vertical_alignment_enum

  def primitive_marker
    :label
  end
end
```

## Render Targets (`[]` operator)

The `args.outputs` structure renders to the screen. You can render to
a texture/virtual canvas using `args.outputs[SYMBOL]`. What ever
primitives are sent to the virtual canvas are cached and reused (the
cache is invalidated whenever you render to virtual canvas).

?> You can also use render targets to accomplish many complex layouts
such as a game camera, perform scene management, or add lighting.
<br/>
<br/>
Take a look at the following sample apps:
<br/>
&nbsp;&nbsp;&nbsp;&nbsp;All sample apps under `./samples/07_advanced_rendering`.
<br/>
&nbsp;&nbsp;&nbsp;&nbsp;The Map Editor reference implementation (`samples/99_genre_platformer/map_editor`).
<br/>
&nbsp;&nbsp;&nbsp;&nbsp;The arcade game Square Fall (`samples/99_genre_arcade/squares`).
<br/>
<br/>
Many of the sample apps use render targets, so be sure to explore as
many as you can!

Here's an example that programmatically creates a `:combined` sprite composed of
two pngs and a label:

```ruby
def tick args
  # on tick 0, create a render target composed of two sprites and a label
  if Kernel.tick_count == 0
    # to reiterate, this sprite will be cached until it's written to again
    # the :combined sprite has a w/h of 200
    args.outputs[:combined].w = 200
    args.outputs[:combined].h = 200

    # and a black transparent background
    args.outputs[:combined].background_color = [0, 0, 0, 0]

    # add two sprites to the render target
    args.outputs[:combined].primitives << {
      x: 0,
      y: 0,
      w: 100,
      h: 200,
      path: "sprites/square/blue.png"
    }

    args.outputs[:combined].primitives << {
      x: 100,
      y: 0,
      w: 100,
      h: 200,
      path: "sprites/square/red.png"
    }

    # add a label in the center of the render target
    args.outputs[:combined].primitives << {
      x: 100,
      y: 100,
      text: "COMBINED!",
      anchor_x: 0.5,
      anchor_y: 0.5,
    }
  end

  # rendered the :combined sprite in multiple
  # places on the screen
  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 400,
    h: 400,
    path: :combined,
    angle: 33
  }

  args.outputs.sprites << {
    x: 640,
    y: 360,
    w: 100,
    h: 100,
    path: :combined,
    angle: 180,
    a: 128
  }
end
```

Render targets are extremely powerful and you'll end up using them a
lot (so be sure to get familiar with them by studying the sample apps).

!> Take note that simply accessing a render target via `args.outputs[]` will invalidate the cached texture. Proceed with caution!

Here's an example of this side-effect:

```ruby
def tick args
  # Create the render target only on the first tick.
  # It's then cached and used indefinitely until it's 
  # accessed again.
  if Kernel.tick_count <= 0
    args.outputs[:render_target].w = 100
    args.outputs[:render_target].h = 100
    args.outputs[:render_target].sprites << {
      x: 0,
      y: 0,
      w: 100,
      h: 100,
      r: 0,
      b: 0,
      g: 0,
      a: 64,
      path: :solid
    }
  end

  # CAUTION: accessing the render target will invalidate it! 
  #          don't do this unless you're wanting to update the
  #          texture
  render_target = args.outputs[:render_target]
  
  # store information you need about a render target in state
  # or an iVar/member variable instead of accessing the render target
  args.outputs.sprites << {
    x: 100,
    y: 100,
    w: render_target.w,
    h: render_target.h,
    path: :render_target,
  }
end
```

## `screenshots`

Add a hash to this collection to take a screenshot and save as png file.
The keys of the hash can be provided in any order.

```ruby
def tick args
  args.outputs.screenshots << {
    x: 0, y: 0, w: 100, h: 100,    # Which portion of the screen should be captured
    path: 'screenshot.png',        # Output path of PNG file (inside game directory)
    r: 255, g: 255, b: 255, a: 0   # Optional chroma key
  }
end
```

### Chroma key (Making a color transparent)

By specifying the r, g, b and a keys of the hash you change the transparency of a color in the resulting PNG file.
This can be useful if you want to create files with transparent background like spritesheets.
The transparency of the color specified by `r`, `g`, `b` will be set to the transparency specified by `a`.

The example above sets the color white (255, 255, 255) as transparent.

## Shaders

Shaders are available to Indie and Pro license holders via
`dragonruby-shadersim`. Download DragonRuby ShaderSim at [dragonruby.org](https://dragonruby.org).

!> Shaders are currently in Beta.
<br/>
<br/>
Shaders must be GLSL ES2 compatible.
<br/>
<br/>
The long term goal is for DR Shaders to baseline to GLSL
version 300 and cross-compile to Vulkan, WebGL 2, Metal, and HLSL.

Here is a minimal example of using shaders:

```ruby
# mygame/app/main.rb
def tick args
  args.outputs.shader_path ||= "shaders/example.glsl"
end
```

```glsl
// mygame/shaders/example.glsl
uniform sampler2D tex0;

varying vec2 v_texCoord;

void main() {
  gl_FragColor = texture2D(tex0, v_texCoord);
}
```

### `shader_path`

Setting `shader_path` on `outputs` signifies to DragonRuby that a
shader should be compiled and loaded. 

### `shader_uniforms`

You can bind uniforms to a shader by providing an `Array` of `Hashes`
to `shader_uniforms` with keys `name:`, `value:`, and `type:` which
currently supports `:int` and `:float`.

```ruby
def tick args
  args.outputs.shader_path ||= "shaders/example.glsl"

  args.outputs.shader_uniforms = [
    {
      name: :mouse_coord_x,
      value: args.inputs.mouse.x.fdiv(1280),
      type: :float
    },
    {
      name: :mouse_coord_y,
      value: 1.0 - args.inputs.mouse.y.fdiv(720),
      type: :float
    },
    {
      name: :tick_count,
      value: Kernel.tick_count,
      type: :int
    }
  ]
end
```

```glsl
// mygame/shaders/example.glsl
uniform sampler2D tex0;

uniform float mouse_coord_x;
uniform float mouse_coord_y;
uniform int tick_count;

varying vec2 v_texCoord;

void main() {
  gl_FragColor = texture2D(tex0, v_texCoord);
}
```

### `shader_tex(1-15)`

You can bind up to 15 additional render targets via `shaders_tex1`,
`shaders_tex2`, `shaders_tex3`, etc. `tex0` is reserved for what has
been rendered to the screen and cannot be set.

```ruby
def tick args
  args.outputs.shader_path = "shaders/example.glsl"
  args.outputs.shader_tex1 = :single_blue_square
  
  args.outputs[:single_blue_square].background_color = { r: 255, g: 255, b: 255, a: 255 }
  args.outputs[:single_blue_square].w = 1280;
  args.outputs[:single_blue_square].h = 720;
  args.outputs[:single_blue_square].sprites << {
    x: 0,
    y: 0,
    w: 100,
    h: 100,
    path:
    "sprites/square/blue.png"
  }
  
  args.outputs.background_color = { r: 0, g: 0, b: 0 }
  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 200,
    h: 200,
    path:
    "sprites/square/red.png"
  }
end
```

```glsl
uniform sampler2D tex0;
uniform sampler2D tex1; // :single_blue_square render target

varying vec2 v_texCoord;

void noop() {
  vec4 pixel_from_rt = texture2D(tex1, v_texCoord);

  // if the pixel from the render target isn't white
  // then render the pixel from the RT
  // otherwise render the pixel from the screen
  if (pixel_from_rt.r < 1.0 ||
      pixel_from_rt.g < 1.0 ||
      pixel_from_rt.b < 1.0) {
    gl_FragColor.r = pixel_from_rt.r;
    gl_FragColor.g = pixel_from_rt.g;
    gl_FragColor.b = pixel_from_rt.b;
  } else {
    gl_FragColor = texture2D(tex0, v_texCoord);
  }
}
```
