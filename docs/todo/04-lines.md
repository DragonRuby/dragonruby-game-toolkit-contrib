# Lines

Lines are 1 pixel wide and can be diagonal.

## Sample Apps Related to Line Usage (ordered by size of codebase increasing)

- 01_api_02_lines
- 01_api_99_tech_demo (includes recording)
- 06_coordinate_systems (includes recording)
- 19_lowrez_jam_01_hello_world
- 99_sample_game_pong (includes recording)

## Minimum Code

Creates a black line from the bottom left corner to the top right corner.

```ruby
#                       X1  Y1    X2   Y2
args.outputs.lines << [  0,  0, 1280, 720]
```

Creates a black vertical line through the center of the scene.

```ruby
#                        X1  Y1    X2   Y2
args.outputs.lines << [ 640,  0,  640, 720]
```

Creates a black horizontal line through the center of the scene.

```ruby
#                       X1   Y1     X2   Y2
args.outputs.lines << [  0, 360,  1280, 360]
```

## RGBA - Colors and Alpha

The value for the color and alpha is an number between `0` and `255`. The
alpha property is optional and will be set to `255` if not specified.

Creates a green horizontal line through the center of the scene with an opacity of 50%.

```ruby
#                       X1   Y1     X2   Y2   RED  GREEN  BLUE  ALPHA
args.outputs.lines << [  0, 360,  1280, 360,    0,   255,    0,   128]
```

Creates a green vertical line through the center of the scene.
The opacity is excluded because it's 100% opaque (which has a value of 255).

```ruby
#                        X1   Y1    X2    Y2  RED  GREEN  BLUE
args.outputs.lines << [ 640,   0,  640,  720,   0,   255,    0]
```

## Hash (Advanced)

If you want a more readable invocation. You can use the following hash to create a line.
Any parameters that are not specified will be given a default value. The keys of the hash can
be provided in any order.

```ruby
args.outputs.lines << {
  x:    0,
  y:    0,
  x2: 1280,
  y2:  720,
  r:    0,
  g:  255,
  b:    0,
  a:  255
}
```

## Duck Typing (Advanced)

You can also create a class with line properties and render it as a primitive.
ALL properties must on the class. ADDITIONALLY, a method called `primitive_marker`
must be defined on the class.

Here is an example:

```ruby
# Create type with ALL line properties AND primitive_marker
class Line
  attr_accessor :x, :y, :x2, :y2, :r, :g, :b, :a

  def primitive_marker
    :line
  end
end

# Inherit from type
class VerticalLine < Line

  # constructor
  def initialize x, y, h
    self.x = x
    self.y = y
    self.x2 = x
    self.y2 = y + h
  end
end

# render line

args.outputs.lines << VerticalLine.new(10, 10, 100)
```
