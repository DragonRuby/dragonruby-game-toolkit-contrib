# Pixel Arrays (`args.pixel_arrays`)

A `PixelArray` object with a width, height and an Array of pixels which are hexadecimal color values in ABGR format.

You can create a pixel array like this:

```ruby
w = 200
h = 100
args.pixel_array(:my_pixel_array).w = w
args.pixel_array(:my_pixel_array).h = h
```

You'll also need to fill the pixels with values, if they are `nil`, the array will render with the checkerboard texture. You can use #00000000 to fill with transparent pixels if desired.

```ruby
args.pixel_array(:my_pixel_array).pixels.fill #FF00FF00, 0, w * h
```

Note: To convert from rgb hex (like skyblue #87CEEB) to abgr hex, you split it in pairs pair (eg `87` `CE` `EB`) and reverse the order (eg `EB` `CE` `87`) add join them again: `#EBCE87`. Then add the alpha component in front ie: `FF` for full opacity: `#FFEBCE87`.

You can draw it by using the symbol for `:path`

```ruby
args.outputs.sprites << { x: 500, y: 300, w: 200, h: 100, path: :my_pixel_array) }
```

If you want access a specific x, y position, you can do it like this for a bottom-left coordinate system:

```ruby
x = 150
y = 33
args.pixel_array(:my_pixel_array).pixels[(height - y) * width + x] = 0xFFFFFFFF
```

## Related Sample Apps

-   Animation using pixel arrays: `./samples/07_advanced_rendering/06_pixel_arrays`
-   Load a pixel array from a png: `./samples/07_advanced_rendering/06_pixel_arrays_from_file/`
