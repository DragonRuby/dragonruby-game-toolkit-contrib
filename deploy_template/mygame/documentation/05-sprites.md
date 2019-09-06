# Sprites

Sprites are the most important visual component of a game.

## Sample Apps Related to Sprite Usage (ordered by size of codebase increasing)

- 01_api_04_sprites
- 01_api_99_tech_demo (includes recording)
- 02_sprite_animation_and_keyboard_input (includes recording)
- 08_platformer_collisions_metroidvania
- 09_controller_analog_usage_advanced_sprites
- 99_sample_game_basic_gorillas (includes recording)
- 99_sample_game_dueling_starships (includes recording)
- 99_sample_game_flappy_dragon (includes recording)
- 99_sample_game_return_of_serenity

## Minimum Code

Sprites need to be under the `mygame` directory. It's recommended that you create a `sprites` folder
to keep things organized. All sprites must be `.png` files

Here is how you create an sprite with located at 100, 100, that is 32 pixels wide and 64 pixels tall.
In this example the sprite name is `player.png` and is located under a directory `mygame/sprites`.

```ruby
#                          X    Y  WIDTH  HEIGHT  PATH
args.outputs.sprites << [100, 100,    32,     64, "sprites/player.png"]
```

## Rotation / Angle

Unlike `solids` and `borders`, sprites can be rotated. This is how you rotate a sprite 90 degress.

Note: All angles in DragonRuby Game Toolkit are represented in degrees (not radians).

```ruby
#                          X    Y  WIDTH  HEIGHT  PATH                  ANGLE
args.outputs.sprites << [100, 100,    32,     64, "sprites/player.png",    90]
```

## Alpha

Sprites can also have a transparency associated with them. The transparency value must come after
the angle value and supports a number between 0 and 255.

This is how you would define a sprite with no rotation, and a 50% transparency.

```ruby
#                          X    Y  WIDTH  HEIGHT  PATH                  ANGLE  ALPHA
args.outputs.sprites << [100, 100,    32,     64, "sprites/player.png",     0,   128]
```

## Color Saturations

A Sprite's color levels can be changed. The color saturations must come after `angle` and
`alpha` values.

This is a sprite with no rotation, fully opaque, and with a green tint.

```ruby
args.outputs.sprites << [100,                     # X
                         100,                     # Y
                          32,                     # W
                          64,                     # H
                         "sprites/player.png",    # PATH
                         0,                       # ANGLE
                         255,                     # ALPHA
                         0,                       # RED_SATURATION
                         255,                     # GREEN_SATURATION
                         0]                       # BLUE_SATURATION
```

## Sprite Sub Division / Tile

You can render a portion of a sprite (a tile). The sub division of the sprite is denoted as a rectangle
directly related to the original size of the png.

This is a sprite scaled to 100 pixels where the source "tile" is located at the bottom left corner
within a 32 pixel square. The angle, opacity, and color levels of the tile are unaltered.

```ruby
args.outputs.sprites << [                 100,    # X
                                          100,    # Y
                                           32,    # W
                                           64,    # H
                         "sprites/player.png",    # PATH
                                            0,    # ANGLE
                                          255,    # ALPHA
                                            0,    # RED_SATURATION
                                          255,    # GREEN_SATURATION
                                            0,    # BLUE_SATURATION
                                            0,    # TILE_X
                                            0,    # TILE_Y
                                           32,    # TILE_W
                                           32]    # TILE_H
```

## Flipping a Sprite Horizontally and Vertically

A sprite can be flipped horizontally and vertically.

This is a sprite that has been flipped horizontally. The sprites's angle, alpha, color saturations,
and tile subdivision are unaltered.

```ruby
args.outputs.sprites << [                 100,    # X
                                          100,    # Y
                                           32,    # W
                                           64,    # H
                         "sprites/player.png",    # PATH
                                            0,    # ANGLE
                                          255,    # ALPHA
                                            0,    # RED_SATURATION
                                          255,    # GREEN_SATURATION
                                            0,    # BLUE_SATURATION
                                            0,    # TILE_X
                                            0,    # TILE_Y
                                           32,    # TILE_W
                                           32,    # TILE_H
                                         true,    # FLIP_HORIZONTALLY
                                        false]    # FLIP_VERTICALLY
```

This is a sprite that has been flipped vertically. The sprites's angle, alpha, color saturations,
and tile subdivision are unaltered.

```ruby
args.outputs.sprites << [                 100,    # X
                                          100,    # Y
                                           32,    # W
                                           64,    # H
                         "sprites/player.png",    # PATH
                                            0,    # ANGLE
                                          255,    # ALPHA
                                            0,    # RED_SATURATION
                                          255,    # GREEN_SATURATION
                                            0,    # BLUE_SATURATION
                                            0,    # TILE_X
                                            0,    # TILE_Y
                                           32,    # TILE_W
                                           32,    # TILE_H
                                        false,    # FLIP_HORIZONTALLY
                                         true]    # FLIP_VERTICALLY
```

## Rotation Center

A sprites center of rotation can be altered.

This is a sprite that has its rotation center set to the top-middle. The sprites's angle, alpha, color saturations,
tile subdivision, and projectsions are unaltered.

```ruby
args.outputs.sprites << [                 100,    # X
                                          100,    # Y
                                           32,    # W
                                           64,    # H
                         "sprites/player.png",    # PATH
                                            0,    # ANGLE
                                          255,    # ALPHA
                                          255,    # RED_SATURATION
                                          255,    # GREEN_SATURATION
                                            0,    # BLUE_SATURATION
                                            0,    # TILE_X
                                            0,    # TILE_Y
                                           -1,    # TILE_W
                                           -1,    # TILE_H
                                        false,    # FLIP_HORIZONTALLY
                                        false,    # FLIP_VERTICALLY
                                          0.5,    # ANGLE_ANCHOR_X
                                          1.0]    # ANCHOR_Y
```

## Hash (Advanced)

If you want a more readable invocation. You can use the following hash to create a sprite.
Any parameters that are not specified will be given a default value. The keys of the hash can
be provided in any order.

```ruby
args.outputs.sprites << {
  x: 100,
  y: 100,
  w: 100,
  h: 100,
  path: "sprites/player.png",
  angle: 0,
  a, 255
  r: 255,
  g: 255,
  b: 255,
  tile_x:  0,
  tile_y:  0,
  tile_w: -1,
  tile_h: -1,
  flip_vertically: false,
  flip_horizontally: false,
  angle_anchor_x: 0.5,
  angle_anchor_y: 1.0
}
```

## Duck Typing (Advanced)

You can also create a class with sprite properties and render it as a primitive.
ALL properties must on the class. ADDITIONALLY, a method called `primitive_marker`
must be defined on the class.

Here is an example:

```ruby
# Create type with ALL sprite properties AND primitive_marker
class Sprite
  attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b, :tile_x,
                :tile_y, :tile_w, :tile_h, :flip_horizontally,
                :flip_vertically, :angle_anchor_x, :angle_anchor_y

  def primitive_marker
    :sprite
  end
end

# Inherit from type
class PlayerSprite < Sprite

  # constructor
  def initialize x, y, w, h
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.path = 'sprites/player.png'
  end
end

#render player sprite

args.outputs.sprites << PlayerSprite.new(10, 10, 32, 64)
```
