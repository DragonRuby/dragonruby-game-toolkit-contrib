# Scaling

The general idea is (for example): You'll have `sprite.png`
`sprite@1080p.png`, `sprite@1440p.png`, `spite@4k.png`, ...

- If you are missing `@1080p`, `sprite.png` will be scaled 1.5.
- If you're missing `@1440p`, `sprite.png`.

And so on. In code, always use `sprite.png` paths withouth the @, and GTK will figure out the right png to use.

```
+------------+-------+------+------+------+------+------+------+------+------+
| Resolution | @Name | Unit |  720 | 1080 | 1440 |   4K |   5K |   6K |   8K |
+------------+-------+-----:+-----:+-----:+-----:+-----:+-----:+-----:+-----:+
| 1280x720   | 720p  |  2px |   1x |    - |    - |    - |    - |    - |    - |
| 1920x1080  | 1080p |  3px | 1.5x |   1x |    - |    - |    - |    - |    - |
| 2560x1440  | 1440p |  4px |   2x |    - |   1x |    - |    - |    - |    - |
| 3840x2160  | 4K    |  6px |   3x |   2x |    - |   1x |    - |    - |    - |
| 5120x2880  | 5K    |  8px |   4x |    - |   2x |    - |   1x |    - |    - |
| 5760x3240  | 6K    |  9px | 4.5x |   3x |    - |    - |    - |   1x |    - |
| 7680x4320  | 8K    | 12px |   6x |   4x |   3x |   2x |    - |    - |   1x |
+------------+-------+------+------+------+------+------+------+------+------+
| 640x360    | 360p  |  2px | 0.5x |    - |    - |    - |    - |    - |    - |
+------------+-------+------+------+------+------+------+------+------+------+
```

# Layout Theory (work in progress)

Where it gets tricky is mobile. The algorithm there would be to find
the nearest pixel perfect resolution and then allow for rendering
outside of the logical canvas, which will be centered in the
screen. `grid.left` in these cases will be a negative number and will
exclude "unsafe" areas (which are only applicable to phones with edge
to edge screens... god help us all if I have to introduce a
`grid.(left|right|top|bottom)_unsafe`).

## Variables that need to be considered.

- logical  pixel  of device
- logical  pixels of canvas (720p)
- physical pixel  of device

## Well known aspect ratios

  - 720p
  - 1080p
  - 1440p
  - 4k
  - 5k
  - 6k
  - 8k

## Laws that support Layout Theory

  - Logical pixels is 720p for a game.
  - The logical pixels for the game is centered in the device.
  - The logical pixesl is the only safe area for the game.

## Math

  1. Take the logical widht and height of the iphone, assume the thinner part is the "9" of the "16:9" aspect ratio. Example: 414 / 896 = 720 / x ... x = 1558
  2. Determine the scale down from the 720 to the target "9". Example: 720 * x = 414 ... x = .575
  3. Determine the "other side" of the 16?? : 9 aspect ratio for the target device (which might not be 16). Example: 1280 / 1558 = x / 896 ... x = 736
  4. And then scale that down. Example: 1558.3 * .575 ... x = 896
  5. Determine the 16:9 scaled. Example 414 x 736
  6. Determine the unsafe area. Example: (896 - 736) / 2 = 65
  7. Verify the math and make sure the aspect ratio makes sense. Example: 1558 / (720 / 9) = 19.5
  8. Verify result. Example: 9 : 19.5 with 1.75 unsafe on either side = 140 logical pixels on
     either side  To support iPhone 11 Pro, you must render a game where you render -140 to 1420. 720 x 1280 logical.

## Scale Table

The Physical pixels for the iPhone 11 is 1242 X 2688. This is used to determine which texture will be used from the texture atlas.

```
+------------+-------+------+------+------+------+------+------+------+------+
| Resolution | @Name | Unit |  720 | 1080 | 1440 |   4K |   5K |   6K |   8K |
+------------+-------+-----:+-----:+-----:+-----:+-----:+-----:+-----:+-----:+
| 1280x720   |   -   |  2px |   1x |    - |    - |    - |    - |    - |    - |
| 1920x1080  | 1080p |  3px | 1.5x |   1x |    - |    - |    - |    - |    - |
| 2560x1440  | 1440p |  4px |   2x |    - |   1x |    - |    - |    - |    - |
| 3840x2160  | 4K    |  6px |   3x |   2x |    - |   1x |    - |    - |    - |
| 5120x2880  | 5K    |  8px |   4x |    - |   2x |    - |   1x |    - |    - |
| 5760x3240  | 6K    |  9px | 4.5x |   3x |    - |    - |    - |   1x |    - |
| 7680x4320  | 8K    | 12px |   6x |   4x |   3x |   2x |    - |    - |   1x |
+------------+-------+------+------+------+------+------+------+------+------+
```
