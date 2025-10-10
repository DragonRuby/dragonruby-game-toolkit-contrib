# Grid

Provides information about the screen and game canvas.

?> All functions are available globally via `Grid.*`.
```ruby
def tick args
   puts Grid.function(...)
end
```

## `orientation`

Returns either `:landscape` (default) or `:portrait`. The orientation of your game is set within `./mygame/metadata/game_metadata.txt`.

## `orientation_changed?`

Returns `true` if the orientation for your game has changed because of a window resize (or handheld device rotation). This
value will only be true on the frame the orientation change occurred (and is dependent on the `orientation` value in `game_metadata.txt`
having comma delimited value of `portrait,landscape` or `landscape,portrait`). See the CVars section in the docs for more information.

## `origin_name`

Returns either `:bottom_left` (default) or `:center`.

## `origin_bottom_left!`

Change the grids coordinate system where `0, 0` is at the bottom left
corner. `origin_name` will be set to `:bottom_left`.

## `origin_center!`

Change the grids coordinate system where `0, 0` is at the center of the
screen. `origin_name` will be set to `:center`.

## `portrait?`

Returns `true` if `orientation` is `:portrait`.

## `landscape?`

Returns `true` if `orientation` is `:landscape`.

## Grid Property Categorizations

There are two categories of Grid properties that you should be aware of:

- Logical: Values are represented at the logical scale of `720p`
  (1280x720 for landscape orientation or 720x1280 portrait mode).
- Pixels: Values are represented in the context of Pixels for a given display.

!> You will almost always use the Logical Category's properties.
<br/>
<br/>
The Pixel is helpful for sanity checking of Texture Atlases, creating
C Extensions, and Shaders (Indie and Pro License features).  
<br/>
<br/>
For the Standard License, the Pixel Category
properties will all return values from the Logical Category.

Here's an example of what the property conventions look like:

```ruby
def tick args
  # Logical width
  Grid.w

  # Width in pixels
  Grid.w_px
end
```

Note: `Grid` properties are globally accessible via `$grid`.

!> All Grid properties that follow take `origin_name`, and `orientation` into consideration.

## `bottom`

Returns value that represents the bottom of the grid. 

Given that the logical canvas is `720p`, these are the values that
`bottom` may return:

- origin: `:bottom_left`, orientation: `:landscape`: `0`
- origin: `:bottom_left`, orientation: `:portrait`: `0`
- origin: `:center`, orientation: `:landscape`: `-360`
- origin: `:center`, orientation: `:portrait`: `-640`

## `top`

Returns value that represents the top of the grid (this is an alias for `Grid.h`).

## `left`

Returns value that represents the left of the grid.

## `right`

Returns the `x` value that represents the right of the grid.

## `rect`

Returns a rectangle Primitive that represents the grid.

## `w`

Returns the grid's width.

## `h`

Returns the grid's height.

## `aspect_ratio_w`

Returns either `16` or `9` based on orientation.

## `aspect_ratio_h`

Returns either `16` or `9` based on orientation.

## HD, HighDPI, and All Screen Modes

The following properties are available to Pro License holders. These
features are enabled via `./mygame/metadata/game_metadata.txt`:

- `hd=true`: Enable Texture Atlases and HD label/font rendering. Grid
  properties in the Pixel Category will reflect true values instead of values
  from the Logical Category.
- `highdpi=true`: HD must be enabled before this property will be
   respected. Texture Atlas selection and label/font rendering
   takes into consideration the hardware's resolution/rendering
   capabilities.
- `hd_letterbox=false`: Removes the game's 16:9 letterbox, allowing
  you to render edge to edge (All Screen). Game content will be
  centered within the 16:9 safe area.

!> For a demonstration of these configurations/property usages, see: `./samples/07_advanced_rendering/03_allscreen_properties`.

When All Screen mode is enabled (`hd_letterbox=false`), you can render
outside of the 1280x720 safe area. The 1280x720 logical canvas will be
centered within the screen and scaled to one of the following
closest/best-fit resolutions.

-   720p: 1280x720
-   HD+: 1600x900
-   1080p: 1920x1080
-   1440p: 2560x1440
-   1880p: 3200x1800
-   4k: 3840x2160
-   5k: 6400x2880

### All Screen Properties

?> All Screen Properties are pertinent for Pro license with `hd_letterbox=false` (setting `hd_letterbox=false` allows for edge to edge screen rendering). Take a look at the following sample to see how rendering can be applied to non-standard aspect ratios `samples/07_advanced_rendering_hd/05_camera_ultrawide_allscreen`.

The goal of All Screen Properties is to ensure that the safe area for your game is always centered in the display regardless of its aspect ratio.

When a non-standard aspect ratio (an aspect ratio that isn't 16:9 or 9:16), All Screen Properties will reflect the "overflow" for the game window.

All Screen Properties are always in **logical pixels**, you can see native pixel values - if you're curious about what they are - using the `_px` variant of All Screen Properties (they aren't really useful for rendering things on the screen since everything is in logical pixels and are there in preperation of shaders and computing UV coordinates).

- If your game is landscape, and your game window is wider than it is tall, then All Screen properties for height will match the logical pixels of the game. All Screen width properties for width will be different because the overflow occurs horizontally.

- If your game is landscape, and your game window is taller than it is wide, then All Screen properties for width will match the logical pixels of the game. All Screen width properties for height will be different because the overflow occurs vertically.

- If your game window is a perfect 16:9 aspect ratio (720p, 1080p, etc), then all All Screen properties will match logical pixels. There is no overflow in that case (your native scale will be a multiple of 720p).

You can use the following code to view all screen properties for different sizes of the game window. Try making the window really wide, but short and really tall but thin:

```ruby
def tick args
  # all screen rect properties
  args.outputs.primitives << {
    x: 640, y: 390,
    text: "allscreen_rect: #{Grid.allscreen_rect}",
    anchor_x: 0.5, anchor_y: 0.5, size_px: 30
  }

  # all screen left, right
  args.outputs.primitives << {
    x: 640, y: 360,
    text: "allscreen_left: #{Grid.allscreen_left}, allscreen_right: #{Grid.allscreen_right}",
    anchor_x: 0.5, anchor_y: 0.5, size_px: 30
  }

  # all screen bottom, top
  args.outputs.primitives << {
    x: 640, y: 330,
    text: "allscreen_bottom: #{Grid.allscreen_bottom}, allscreen_top: #{Grid.allscreen_top}",
    anchor_x: 0.5, anchor_y: 0.5, size_px: 30
  }

  # mouse location
  args.outputs.labels << {
    x: 640, y: 300,
    text: "Mouse: #{args.inputs.mouse.x}, #{args.inputs.mouse.y}",
    anchor_x: 0.5, anchor_y: 0.5, size_px: 30,
  }

  # edge to edge area
  args.outputs.sprites << {
    **Grid.allscreen_rect, path: :solid,
    r: 64, g: 64, b: 128, a: 255
  }

  # safe area
  args.outputs.sprites << {
    x: 0, y: 0, w: 1280, h: 720, path: :solid,
    r: 128, g: 64, b: 64, a: 255
  }
end
```

These properties provide dimensions of the screen outside of the 16:9
safe area as logical `720p` values.

- `allscreen_left`
- `allscreen_right`
- `allscreen_top`
- `allscreen_bottom`
- `allscreen_w`
- `allscreen_h`
- `allscreen_offset_x`
- `allscreen_offset_y`

!> With the main canvas being centered in the screen, `allscreen_left`
and `allscreen_bottom` may return negative numbers for origin
`:bottom_left` since `x: 0, y: 0` might not align with the bottom left border of the game window.

!> It is strongly recommended that you don't use All Screen properties
for any elements the player would interact with (eg buttons in an
options menu) as they could get rendered underneath a "notch" on a
mobile device or at the far edge of an ultrawide display.

#### Logical, Point, Pixel Category Value Comparisons

!> Reminder: it's unlikely that you'll use any of the
`_px` variants. The explanation that follows if for those
that want the nitty gritty details.

Here are the values that a 16-inch MacBook Pro would return for
`allscreen_` properties.

Device Specs:

<!-- org: #+begin_src text -->
| Spec               | Value       |
| ------------------ | ----------- |
| Aspect Ratio       | 16:10       |
| Points Resolution  | 1728x1080   |
| Screen Resolution  | 3456x2160   |
<!-- org: #+end_src -->

Game Settings:

- HD: Enabled
- HighDPI: Enabled

The property breakdown is:

<!-- org: #+begin_src text -->
| Property              | Value      |
| --------------------- | ---------- |
| Left/Right            |            |
| left                  | 0          |
| left_px               | 0          |
| right                 | 1280       |
| right_px              | 3456       |
| All Screen Left/Right |            |
| allscreen_left        | 0          |
| allscreen_left_px     | 0          |
| allscreen_right       | 1280      |
| allscreen_right_px    | 1728      |
| allscreen_offset_x    | 0         |
| allscreen_offset_x_px | 0         |
|Top/Bottom             |           |
| bottom                | 0         |
| bottom_px             | 0         |
| top                   | 720       |
| top_px                | 1944      |
| All Screen Top/Bottom |           |
| allscreen_bottom      | -40       |
| allscreen_bottom_px   | -108      |
| allscreen_top         | 780       |
| allscreen_top_px      | 2052      |
| allscreen_offset_y    | 40        |
| allscreen_offset_y_px | 108       |
<!-- org: #+end_src -->

### Texture Atlases

### `native_scale`

Represents the native scale of the window compared to 720p.

### `render_scale`

Represents the render scale of the window compared to 720p. This value
will be the same as `native_scale` if `game_metadata.hd_max_scale=0`
(stretch to fit). For values `100 through 400`, the `render_scale`
represents the best fit scale to render pixel perfect. See CVars /
Configuration (`args.cvars`), and `metadata/game_metadata.txt` for
details about `hd_max_scale`'s usage.

### `texture_scale`

Returns a decimal value representing the rendering scale for textures as a float.

-   720p: 1.0
-   HD+: 1.25
-   1080p, Full HD: 1.5
-   Full HD+: 1.75
-   1440p: 2.0
-   1880p: 2.5
-   4k: 3.0
-   5k: 4.0

### `texture_scale_enum`

Returns an integer value representing the rendering scale of the game
at a best-fit value. For example, given a render scale of 2.7, the
textures atlas that will be selected will be 1880p (enum_value `250`).

-   720p: 100
-   HD+: 125
-   1080p, Full HD: 150
-   Full HD+: 175
-   1440p: 200
-   1880p: 250
-   4k: 300
-   5k: 400

Given the following code:

```ruby
def tick args
  args.outputs.sprites << { x: 0, y: 0, w: 100, h: 100, path: "sprites/player.png" }
end
```

The sprite path of `sprites/player.png` will be replaced according to
the following naming conventions (fallback to a lower resolution is
automatically handled if a sprite with naming convention isn't found):

-   720p: `sprites/player.png` (100x100)
-   HD+: `sprites/player@125.png` (125x125)
-   1080p: `sprites/player@150.png` (150x150)
-   1440p: `sprites/player@200.png` (200x200)
-   1880p: `sprites/player@250.png` (250x250)
-   4k: `sprites/player@300.png` (300x300)
-   5k: `sprites/player@400.png` (400x400)
