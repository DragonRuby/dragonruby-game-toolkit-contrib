# Grid (`args.grid`)

Returns the virtual grid for the game.

## `name`

Returns either `:origin_bottom_left` or `:origin_center`.

## `bottom`

Returns the `y` value that represents the bottom of the grid.

## `top`

Returns the `y` value that represents the top of the grid.

## `left`

Returns the `x` value that represents the left of the grid.

## `right`

Returns the `x` value that represents the right of the grid.

## `rect`

Returns a rectangle Primitive that represents the grid.

## `origin_bottom_left!`

Change the grids coordinate system to 0, 0 at the bottom left corner.

## `origin_center!`

Change the grids coordinate system to 0, 0 at the center of the screen.

## `orientation`

Returns either `:portrait` or `:landscape`. The orientation of your game is set within `./mygame/metadata/game_metadata.txt`.

## `w`

Returns the grid's width (value is 1280 if orientation `:landscape`, and 720 if orientation is `:portrait`).

## `h`

Returns the grid's width (value is 720 if orientation `:landscape`, and 1280 if orientation is `:portrait`).

## Grid HD Properties

The following properties are available to Pro license holders. Setting `hd=true` and `hd=true` in `./mygame/metadata/game_metadata.txt` will enable All Screen Mode.

Please review the sample app located at `./samples/07_advanced_rendering_hd/03_allscreen_properties`.

When All Screen mode is enabled, you can render outside of the 1280x720 safe area. The 1280x720 logical canvas will be centered within the screen and scaled to one of the following closest/bess-fit resolutions.

-   720p: 1280x720
-   HD+: 1600x900
-   1080p: 1920x1080
-   1440p: 2560x1440
-   1880p: 3200x1800
-   4k: 3840x2160
-   5k: 6400x2880

Regardless of the rendering resolution, your logical canvas will always be 1280x720 and all `hd_*` values will be at this same logical scale.

### `hd_left`

Returns the position of the left edge of the screen at the logical scale of 1280x720. For example, if the window's width is 1290x720, then `hd_left` will be -5.

### `hd_right`

Returns the position of the right edge of the screen at the logical scale of 1280x720. For example, if the window's width is 1290x720, then `hd_right` will be 1285.

### `hd_bottom`

Returns the position of the bottom edge of the screen at the logical scale of 1280x720. For example, if the window's width is 1280x730, then `hd_bottom` will be -5.

### `hd_top`

Returns the position of the top edge of the screen at the logical scale of 1280x720. For example, if the window's width is 1280x730, then `hd_top` will be 725.

### `hd_offset_x`

Returns the number of pixels that the 1280x720 canvas is offset from the left so that it's centered in the screen.

### `hd_offset_y`

Returns the number of pixels that the 1280x720 canvas is offset from the bottom so that it's centered in the screen.

### `window_width`

Returns the true width of the window. High DPI settings are not taken into consideration.

### `window_height`

Returns the true height of the window. High DPI settings are not taken into consideration.

### `native_width`

Returns the true width of the window. High DPI settings (macOS, iOS, Android) are taken into consideration.

### `native_height`

Returns the true height of the window. High DPI settings (macOS, iOS, Android) are taken into consideration.

### `native_scale`

Returns a decimal value representing the rendering scale of the game.

-   720p: 1.0
-   HD+: 1.25
-   1080p, Full HD: 1.5
-   Full HD+: 1.75
-   1440p: 2.0
-   1880p: 2.5
-   4k: 3.0
-   5k: 4.0

### `native_scale_enum`

Returns an integer value representing the rendering scale of the game.

-   720p: 100
-   HD+: 125
-   1080p, Full HD: 150
-   Full HD+: 175
-   1440p: 200
-   1880p: 250
-   4k: 300
-   5k: 400

The enum value is taken into consideration when rendering a sprite through texture atlases.

Given the following code:

```ruby
def tick args
  args.outputs.sprites << { x: 0, y: 0, w: 100, h: 100, path: "sprites/player.png" }
end
```

The sprite path of `sprites/player.png` will be replaced according to the following naming conventions (fallback to a lower resolution is automatically handled if a sprite with naming convention isn't found):

-   720p: `sprites/player.png` (100x100)
-   HD+: `sprites/player@125.png` (125x125)
-   1080p: `sprites/player@150.png` (150x150)
-   1440p: `sprites/player@200.png` (200x200)
-   1880p: `sprites/player@250.png` (250x250)
-   4k: `sprites/player@300.png` (300x300)
-   5k: `sprites/player@400.png` (400x400)
