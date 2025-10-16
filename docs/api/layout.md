# Layout

Layout provides apis for placing primitives on a virtual grid that's
within the "safe area" accross all platforms. This virtual grid is
useful for rendering static controls (buttons, menu items,
configuration screens, etc). 

?> All functions are available globally via `Layout.*`.
```ruby
def tick args
   puts args.layout.function(...)

   # OR available globally
   puts Layout.function(...)
end
```

For reference implementations, take a look at the following sample apps:

-   `./samples/07_advanced_rendering/18_layouts`
-   `./samples/07_advanced_rendering_hd/04_layouts_and_portrait_mode`
-   `./samples/99_genre_jrpg/turn_based_battle`
-   `./samples/09_ui_controls/02_menu_navigation_advanced`

The following example creates two menu items and updates a label with the button that was clicked:

```ruby
def tick args
  # render debug_primitives of args.layout for help with placement
  # args.outputs.primitives << args.layout.debug_primitives

  # capture the location for a label centered at the top
  args.state.label_rect ||= args.layout.rect(row: 0, col: 10, w: 4, h: 1)
  # state variable to hold the current click status
  args.state.label_message ||= "click a menu item"

  # capture the location of two menu items positioned in the center
  # with a cell width of 4 and cell height of 2
  args.state.menu_item_1_rect ||= args.layout.rect(row: 1, col: 10, w: 4, h: 2)
  args.state.menu_item_2_rect ||= args.layout.rect(row: 3, col: 10, w: 4, h: 2)

  # render the label at the center of the label_rect
  args.outputs.labels << args.state.label_rect.center.merge(text: args.state.label_message,
                                                            anchor_x: 0.5,
                                                            anchor_y: 0.5)

  # render menu items
  args.outputs.sprites << args.state.menu_item_1_rect.merge(path: :solid,
                                                            r: 100,
                                                            g: 100,
                                                            b: 200)
  args.outputs.labels << args.state.menu_item_1_rect.center.merge(text: "item 1",
                                                                  r: 255,
                                                                  g: 255,
                                                                  b: 255,
                                                                  anchor_x: 0.5,
                                                                  anchor_y: 0.5)

  args.outputs.sprites << args.state.menu_item_2_rect.merge(path: :solid,
                                                            r: 100,
                                                            g: 100,
                                                            b: 200)
  args.outputs.labels << args.state.menu_item_2_rect.center.merge(text: "item 2",
                                                                  r: 255,
                                                                  g: 255,
                                                                  b: 255,
                                                                  anchor_x: 0.5,
                                                                  anchor_y: 0.5)

  # if click occurs, then determine which menu item was clicked
  if args.inputs.mouse.click
    if args.inputs.mouse.intersect_rect?(args.state.menu_item_1_rect)
      args.state.label_message = "menu item 1 clicked"
    elsif args.inputs.mouse.intersect_rect?(args.state.menu_item_2_rect)
      args.state.label_message = "menu item 2 clicked"
    else
      args.state.label_message = "click a menu item"
    end
  end
end
```

## `rect`

Given a `row:`, `col:`, `w:`, `h:`, returns a `Hash` with properties `x`, `y`, `w`, `h`, and `center` (which contains a `Hash` with `x`, `y`). The virtual grid is 12 rows by 24 columns (or 24 columns by 12 rows in portrait mode).

## `debug_primitives`

Function returns an array of primitives that can be rendered to the screen to help you place items within the grid.

Example:

```ruby
def tick args
  ...

  # at the end of tick method, render the
  # grid overlay to static_primitives on
  # tick_count=0 to help with positioning
  if Kernel.tick_count == 0
    # Layout.debug_primitives returns a flat hash of values
    # so you can customize the colors/alphas if needed
    # args.outputs.static_primitives << Layout.debug_primitives.map do |primitive|
    #   primitive.merge(r: ..., g: ..., b: ..., etc)
    # end
    args.outputs.static_primitives << Layout.debug_primitives
  end
end
```

## `portrait?`

Alias for `Grid.portrait?`.

## `landscape?`

Alias for `Grid.landscape?`.

## `row_count`

Gives the number of rows in the Layout grid. In landscape mode the value is set to `12` In portrait mode the value is set to `24`.

## `row_max_index`

Returns the maximum row count index.

## `col_count`

Gives the number of columns in the Layout grid. In landscape mode the value is set to `24` In portrait mode the value is set to `12`.

## `col_max_index`

Returns the maximum column count index.
