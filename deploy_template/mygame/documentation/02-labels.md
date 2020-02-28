# Labels

Labels display text.

## Sample Apps Related to Label Usage (ordered by size of codebase increasing)

- 01_api_01_labels
- 01_api_99_tech_demo (includes recording)
- 10_save_load_game (includes recording)
- 18_moddable_game
- 19_lowrez_jam_01_hello_world
- 99_sample_game_return_of_serenity

## Minimum Code

Creates a label with black text at location 100, 100.

```ruby
#                         X    Y  TEXT
args.outputs.labels << [100, 100, "Hello world"]
```

## Font Size

The size can be a number between `-10` and `+10`. The default size is `0`.

```ruby
#                        X    Y   TEXT           SIZE
args.outputs.labels << [100, 100, "Hello world",    5]
```

## Alignment

Alignment values are `0` (left, default), `1` (center), and `2`
(right). The value must come after the size.

A label smack dab in the center of the screen, with a center alignment:

```ruby
#                         X    Y  TEXT           SIZE  ALIGNMENT
args.outputs.labels << [640, 360, "Hello world",    0,         1]
```

## RGBA - Colors and Alpha

Labels can have colors. The value for the color is an number between
`0` and `255`.

A green label with 50% opacity.

```ruby
#                         X    Y  TEXT           RED  GREEN  BLUE  ALPHA
args.outputs.labels << [640, 360, "Hello world",   0,   255,    0,   128]
```

A green label with size and alignment.

```ruby
#                         X    Y  TEXT           SIZE  ALIGNMENT  RED  GREEN  BLUE  ALPHA
args.outputs.labels << [640, 360, "Hello world",    0,         1,   0,   255,    0,   128]
```

## Custom Font

You can override the font for a label. The font needs to be under the
`mygame` directory. It's recommended that you create a `fonts` folder
to keep things organized.

Here is how you create a label with a font named `coolfont.ttf` under a directory `mygame/fonts`.

```ruby
#                         X    Y  TEXT           SIZE  ALIGNMENT  RED  GREEN  BLUE  ALPHA  FONT FILE
args.outputs.labels << [640, 360, "Hello world",    0,         1,   0,     0,    0,   255, "fonts/coolfont.ttf"]
```

## Hashes (Advanced)

If you want a more readable invocation. You can use the following hash to create a label.
Any parameters that are not specified will be given a default value. The keys of the hash can
be provided in any order.

Here is how you create a green label with a font named `coolfont.ttf` under a directory `mygame/fonts`
using the helper method (providing all the parameters).

```ruby
args.outputs.labels << {
  x:              200,
  y:              550,
  text:           "dragonruby",
  size_enum:      2,
  alignment_enum: 1,
  r:              155,
  g:              50,
  b:              50,
  a:              255,
  font:           "fonts/manaspc.ttf"
}
```

## Duck Typing (Advanced)

You can also create a class with line properties and render it as a primitive.
ALL properties must on the class. ADDITIONALLY, a method called
`primitive_marker` must be defined on the class.

Here is an example:

```ruby
# Create type with ALL sprite properties AND primitive_marker
class Label
  attr_accessor :x, :y, :text, :size_enum, :alignment_enum, :font, :r, :g, :b, :a

  def primitive_marker
    :label
  end
end

# Inherit from type
class TitleLabel < Label

  # constructor
  def initialize x, y, text
    self.x = x
    self.y = y
    self.text = text
  end
end

# render layer label

args.outputs.label << TitleLabel.new(10, 10, "The Game")
```
