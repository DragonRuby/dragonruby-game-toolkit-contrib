# Solids and Borders

Solids and Borders are great to use as place holders for sprites.

## Sample Apps Releated to Solid/Borders Usage (ordered by size of codebase increasing)

- 01_api_03_rects
- 01_api_99_tech_demo (includes recording)
- 02_collisions
- 12_top_down_area (includes recording)
- 99_sample_game_flappy_dragon (includes recording)
- 08_platformer_collisions
- 20_roguelike_starting_point
- 99_sample_game_pong (includes recording)

## Minimum Code

Creates a solid black rectangle located at 100, 100. 160 pixels
wide and 90 pixels tall.

```ruby
#                         X    Y  WIDTH  HEIGHT
args.outputs.solids << [100, 100,   160,     90]
```

Creates an unfilled black-bordered rectangle located at 100, 100.
160 pixels wide and 90 pixels tall.

```ruby
#                          X    Y  WIDTH  HEIGHT
args.outputs.borders << [100, 100,   160,     90]
```

## RGBA - Colors and Alpha

The value for the color and alpha is an number between `0` and `255`. The
alpha property is optional and will be set to `255` if not specified.

Creates a green solid rectangle with an opacity of 50%.

```ruby
#                         X    Y  WIDTH  HEIGHT  RED  GREEN  BLUE  ALPHA
args.outputs.solids << [100, 100,   160,     90,   0,   255,    0,   128]
```

Creates an unfilled green-bordered rectangle located at 100, 100.
160 pixels wide and 90 pixels tall and an opacity of 50%.

```ruby
#                          X    Y  WIDTH  HEIGHT  RED  GREEN  BLUE  ALPHA
args.outputs.borders << [100, 100,   160,     90,   0,   255,    0,   128]
```

Creates a solid gray rectangle that covers the entire scene. Like a background.
The opacity is excluded because it's 100% opaque (which has a value of 255).

```ruby
#                          X    Y  WIDTH  HEIGHT  RED  GREEN  BLUE
args.outputs.solids << [   0,   0,  1280,    720, 128,   128,  128]
```

## Hash (Advanced)

If you want a more readable invocation. You can use the following hash to create a solid.
Any parameters that are not specified will be given a default value. The keys of the hash can
be provided in any order.

```ruby
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


args.outputs.borders << {
  x:    0,
  y:    0,
  w:  100,
  h:  100,
  r:    0,
  g:  255,
  b:    0,
  a:  255
}
```

## Duck Typing (Advanced)

You can also create a class with solid/border properties and render it as a primitive.
ALL properties must on the class. ADDITIONALLY, a method called `primitive_marker`
must be defined on the class.

Here is an example:

```ruby
# Create type with ALL solid/border properties AND primitive_marker
class Solid (or Border)
  attr_accessor :x, :y, :w, :h, :r, :g, :b, :a_x

  def primitive_marker
    :solid (or :border)
  end
end

# Inherit from type
class Square < Solid (or Border)
  # constructor
  def initialize x, y, size
    self.x = x
    self.y = y
    self.w = size
    self.h = size
  end
end

# render solid/border

args.outputs.solids  << Square.new(10, 10, 32)
args.outputs.borders << Square.new(10, 10, 32)
```
