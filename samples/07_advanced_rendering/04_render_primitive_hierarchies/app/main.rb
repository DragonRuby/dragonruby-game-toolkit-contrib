=begin

 APIs listing that haven't been encountered in previous sample apps:

 - Nested array: An array whose individual elements are also arrays; useful for
   storing groups of similar data.  Also called multidimensional arrays.

   In this sample app, we see nested arrays being used in object definitions.
   Notice the parameters for solids, listed below. Parameters 1-3 set the
   definition for the rect, and parameter 4 sets the definition of the color.

   Instead of having a solid definition that looks like this,
   [X, Y, W, H, R, G, B]
   we can separate it into two separate array definitions in one, like this
   [[X, Y, W, H], [R, G, B]]
   and both options work fine in defining our solid (or any object).

 - Collections: Lists of data; useful for organizing large amounts of data.
   One element of a collection could be an array (which itself contains many elements).
   For example, a collection that stores two solid objects would look like this:
   [
    [100, 100, 50, 50, 0, 0, 0],
    [100, 150, 50, 50, 255, 255, 255]
   ]
   If this collection was added to args.outputs.solids, two solids would be output
   next to each other, one black and one white.
   Nested arrays can be used in collections, as you will see in this sample app.

 Reminders:

 - args.outputs.solids: An array. The values generate a solid.
   The parameters for a solid are
   1. The position on the screen (x, y)
   2. The width (w)
   3. The height (h)
   4. The color (r, g, b) (if a color is not assigned, the object's default color will be black)
   NOTE: THE PARAMETERS ARE THE SAME FOR BORDERS!

   Here is an example of a (red) border or solid definition:
   [100, 100, 400, 500, 255, 0, 0]
   It will be a solid or border depending on if it is added to args.outputs.solids or args.outputs.borders.
   For more information about solids and borders, go to mygame/documentation/03-solids-and-borders.md.

 - args.outputs.sprites: An array. The values generate a sprite.
   The parameters for sprites are
   1. The position on the screen (x, y)
   2. The width (w)
   3. The height (h)
   4. The image path (p)

   Here is an example of a sprite definition:
   [100, 100, 400, 500, 'sprites/dragonruby.png']
   For more information about sprites, go to mygame/documentation/05-sprites.md.

=end

# This code demonstrates the creation and output of objects like sprites, borders, and solids
# If filled in, they are solids
# If hollow, they are borders
# If images, they are sprites

# Solids are added to args.outputs.solids
# Borders are added to args.outputs.borders
# Sprites are added to args.outputs.sprites

# The tick method runs 60 frames every second.
# Your game is going to happen under this one function.
def tick args
  border_as_solid_and_solid_as_border args
  sprite_as_border_or_solids args
  collection_of_borders_and_solids args
  collection_of_sprites args
end

# Shows a border being output onto the screen as a border and a solid
# Also shows how colors can be set
def border_as_solid_and_solid_as_border args
  border = [0, 0, 50, 50]
  args.outputs.borders << border
  args.outputs.solids  << border

  # Red, green, blue saturations (last three parameters) can be any number between 0 and 255
  border_with_color = [0, 100, 50, 50, 255, 0, 0]
  args.outputs.borders << border_with_color
  args.outputs.solids  << border_with_color

  border_with_nested_color = [0, 200, 50, 50, [0, 255, 0]] # nested color
  args.outputs.borders << border_with_nested_color
  args.outputs.solids  << border_with_nested_color

  border_with_nested_rect = [[0, 300, 50, 50], 0, 0, 255] # nested rect
  args.outputs.borders << border_with_nested_rect
  args.outputs.solids  << border_with_nested_rect

  border_with_nested_color_and_rect = [[0, 400, 50, 50], [255, 0, 255]] # nested rect and color
  args.outputs.borders << border_with_nested_color_and_rect
  args.outputs.solids  << border_with_nested_color_and_rect
end

# Shows a sprite output onto the screen as a sprite, border, and solid
# Demonstrates that all three outputs appear differently on screen
def sprite_as_border_or_solids args
  sprite = [100, 0, 50, 50, 'sprites/ship.png']
  args.outputs.sprites << sprite

  # Sprite_as_border variable has same parameters (excluding position) as above object,
  # but will appear differently on screen because it is added to args.outputs.borders
  sprite_as_border = [100, 100, 50, 50, 'sprites/ship.png']
  args.outputs.borders << sprite_as_border

  # Sprite_as_solid variable has same parameters (excluding position) as above object,
  # but will appear differently on screen because it is added to args.outputs.solids
  sprite_as_solid = [100, 200, 50, 50, 'sprites/ship.png']
  args.outputs.solids << sprite_as_solid
end

# Holds and outputs a collection of borders and a collection of solids
# Collections are created by using arrays to hold parameters of each individual object
def collection_of_borders_and_solids args
  collection_borders = [
    [
      [200,  0, 50, 50],                    # black border
      [200,  100, 50, 50, 255, 0, 0],       # red border
      [200,  200, 50, 50, [0, 255, 0]],     # nested color
    ],
    [[200, 300, 50, 50], 0, 0, 255],        # nested rect
    [[200, 400, 50, 50], [255, 0, 255]]     # nested rect and nested color
  ]

  args.outputs.borders << collection_borders

  collection_solids = [
    [
      [[300, 300, 50, 50], 0, 0, 255],      # nested rect
      [[300, 400, 50, 50], [255, 0, 255]]   # nested rect and nested color
    ],
    [300,  0, 50, 50],
    [300,  100, 50, 50, 255, 0, 0],
    [300,  200, 50, 50, [0, 255, 0]],       # nested color
  ]

  args.outputs.solids << collection_solids
end

# Holds and outputs a collection of sprites by adding it to args.outputs.sprites
# Also outputs a collection with same parameters (excluding position) by adding
# it to args.outputs.solids and another to args.outputs.borders
def collection_of_sprites args
  sprites_collection = [
    [
      [400, 0, 50, 50, 'sprites/ship.png'],
      [400, 100, 50, 50, 'sprites/ship.png'],
    ],
    [400, 200, 50, 50, 'sprites/ship.png']
  ]

  args.outputs.sprites << sprites_collection

  args.outputs.solids << [
    [500, 0, 50, 50, 'sprites/ship.png'],
    [500, 100, 50, 50, 'sprites/ship.png'],
    [[[500, 200, 50, 50, 'sprites/ship.png']]]
  ]

  args.outputs.borders << [
    [
      [600, 0, 50, 50, 'sprites/ship.png'],
      [600, 100, 50, 50, 'sprites/ship.png'],
    ],
    [600, 200, 50, 50, 'sprites/ship.png']
  ]
end
