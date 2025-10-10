# Inputs (`args.inputs`)

Access using input using `args.inputs`.

## `last_active`

This function returns the last active input which will be set to
either `:keyboard`, `:mouse`, or `:controller`. The function is
helpful when you need to present on screen instructions based on the
input the player chose to play with. 

```ruby
def tick args
  if args.inputs.last_active == :controller
    args.outputs.labels << { x: 60, y: 60, text: "Use the D-Pad to move around." }
  else
    args.outputs.labels << { x: 60, y: 60, text: "Use the arrow keys to move around." }
  end
end
```

## `last_active_at`

Returns `Kernel.tick_count` of which the specific input was last active.

## `last_active_global_at`

Returns the `Kernel.global_tick_count` of which the specific input was last active.

## `locale`

Returns the ISO 639-1 two-letter language code based on OS preferences. Refer to the following link for locale strings: <https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes>).

Defaults to "en" if locale can't be retrieved (`args.inputs.locale_raw` will be nil in this case).

## `up`

Returns `true` if: the `up` arrow or `w` key is pressed or held on the `keyboard`; or if `up` is pressed or held on `controller_one`; or if the `left_analog` on `controller_one` is tilted upwards.

## `down`

Returns `true` if: the `down` arrow or `s` key is pressed or held on the `keyboard`; or if `down` is pressed or held on `controller_one`; or if the `left_analog` on `controller_one` is tilted downwards.

## `left`

Returns `true` if: the `left` arrow or `a` key is pressed or held on the `keyboard`; or if `left` is pressed or held on `controller_one`; or if the `left_analog` on `controller_one` is tilted to the left.

## `right`

Returns `true` if: the `right` arrow or `d` key is pressed or held on the `keyboard`; or if `right` is pressed or held on `controller_one`; or if the `left_analog` on `controller_one` is tilted to the right.

## `left_right`

Returns `-1` (left), `0` (neutral), or `+1` (right). This method is aliased to `args.inputs.left_right_with_wasd`.

The following inputs are inspected to determine the result:

-   Keyboard's left, right arrow keys: `args.inputs.keyboard.(left|right)_arrow`
-   Keyboard's a, d keys (WASD): `args.inputs.keyboard.(a|d)`
-   Controller One's DPAD (if a controller is connected): `args.inputs.controller_one.dpad_left`, `args.inputs.controller_one.dpad_right`
-   Controller One's Left Analog (if a controller is connected): `args.inputs.controller_one.left_analog_x_perc.abs >= 0.6`

## `left_right_perc`

Returns a floating point value between `-1` and `1`. This method is aliased to `args.inputs.left_right_perc_with_wasd`

The following inputs are inspected to determine the result:

-   Controller One's Left Analog (if a controller is connected and the value is not 0.0): `args.inputs.controller_one.left_analog_x_perc`
-   If the left analog isn't being used, then Controller One's DPAD is consulted: `args.inputs.controller_one.dpad_left`, `args.inputs.controller_one.dpad_right`
-   Keyboard's a, d keys (WASD): `args.inputs.keyboard.(a|d)`
-   Keyboard's left/right arrow keys: `args.inputs.keyboard.(left|right)_arrow`

## `left_right_directional`

Returns `-1` (left), `0` (neutral), or `+1` (right). This method is aliased to `args.inputs.left_right_arrow`.

The following inputs are inspected to determine the result:

-   Keyboard's left/right arrow keys: `args.inputs.keyboard.(left|right)_arrow`
-   Controller One's DPAD (if a controller is connected): `args.inputs.controller_one.dpad_left`, `args.inputs.controller_one.dpad_right`
-   WASD and Controller One's Left Analog Stick are NOT consulted.

## `left_right_directional_perc`

Returns a floating point value between `-1` and `1`. The following inputs are inspected to determine the result:

-   Controller One's Left Analog (if a controller is connected and the value is not 0.0): `args.inputs.controller_one.left_analog_x_perc`
-   If the left analog isn't being used, then Controller One's DPAD is consulted: `args.inputs.controller_one.dpad_left`, `args.inputs.controller_one.dpad_right`
-   Keyboard's left/right arrow keys: `args.inputs.keyboard.(left|right)_arrow`
-   WASD is NOT consulted.

Here is some sample code to help visualize the `left_right` functions.

```ruby
def tick args
  args.outputs.debug << "* Variations of args.inputs.left_right"
  args.outputs.debug << "  args.inputs.left_right(_with_wasd) #{args.inputs.left_right}"
  args.outputs.debug << "  args.inputs.left_right_perc(_with_wasd) #{args.inputs.left_right_perc}"
  args.outputs.debug << "  args.inputs.left_right_directional #{args.inputs.left_right_directional}"
  args.outputs.debug << "  args.inputs.left_right_directional_perc #{args.inputs.left_right_directional_perc}"
  args.outputs.debug << "** Keyboard"
  args.outputs.debug << "   args.inputs.keyboard.a #{args.inputs.keyboard.a}"
  args.outputs.debug << "   args.inputs.keyboard.d #{args.inputs.keyboard.d}"
  args.outputs.debug << "   args.inputs.keyboard.left_arrow #{args.inputs.keyboard.left_arrow}"
  args.outputs.debug << "   args.inputs.keyboard.right_arrow #{args.inputs.keyboard.right_arrow}"
  args.outputs.debug << "** Controller"
  args.outputs.debug << "   args.inputs.controller_one.dpad_left #{args.inputs.controller_one.dpad_left}"
  args.outputs.debug << "   args.inputs.controller_one.dpad_right #{args.inputs.controller_one.dpad_right}"
  args.outputs.debug << "   args.inputs.controller_one.left_analog_x_perc #{args.inputs.controller_one.left_analog_x_perc}"
end
```

## `up_down`

Returns `-1` (down), `0` (neutral), or `+1` (up). This method is aliased to `args.inputs.up_down_with_wasd`.

The following inputs are inspected to determine the result:

-   Keyboard's up/down arrow keys: `args.inputs.keyboard.(up|down)_arrow`
-   Keyboard's w, s keys (WASD): `args.inputs.keyboard.(w|s)`
-   Controller One's DPAD (if a controller is connected): `args.inputs.controller_one.dpad_up`, `args.inputs.controller_one.dpad_down`
-   Controller One's Up Analog (if a controller is connected): `args.inputs.controller_one.up_analog_y_perc.abs >= 0.6`

## `up_down_directional`

Returns `-1` (down), `0` (neutral), or `+1` (up). This method is aliased to `args.inputs.up_down_arrow`.

The following inputs are inspected to determine the result:

-   Keyboard's up/down arrow keys: `args.inputs.keyboard.(up|down)_arrow`
-   Controller One's DPAD (if a controller is connected): `args.inputs.controller_one.dpad_up`, `args.inputs.controller_one.dpad_down`
-   WASD and Controller One's Left Analog Stick are NOT consulted.

## `up_down_perc`

Returns a floating point value between `-1` and `1`. The following inputs are inspected to determine the result:

-   Controller One's Left Analog (if a controller is connected and the value is not 0.0): `args.inputs.controller_one.up_analog_y_perc`
-   If the left analog isn't being used, then Controller One's DPAD is consulted: `args.inputs.controller_one.dpad_up`, `args.inputs.controller_one.dpad_down`
-   Keyboard's up/down arrow keys: `args.inputs.keyboard.(up|down)_arrow`

Here is some sample code to help visualize the `up_down` functions.

```ruby
def tick args
  args.outputs.debug << "* Variations of args.inputs.up_down"
  args.outputs.debug << "  args.inputs.up_down(_with_wasd) #{args.inputs.up_down}"
  args.outputs.debug << "  args.inputs.up_down_perc(_with_wasd) #{args.inputs.up_down_perc}"
  args.outputs.debug << "  args.inputs.up_down_directional #{args.inputs.up_down_directional}"
  args.outputs.debug << "  args.inputs.up_down_directional_perc #{args.inputs.up_down_directional_perc}"
  args.outputs.debug << "** Keyboard"
  args.outputs.debug << "   args.inputs.keyboard.w #{args.inputs.keyboard.w}"
  args.outputs.debug << "   args.inputs.keyboard.s #{args.inputs.keyboard.s}"
  args.outputs.debug << "   args.inputs.keyboard.up_arrow #{args.inputs.keyboard.up_arrow}"
  args.outputs.debug << "   args.inputs.keyboard.down_arrow #{args.inputs.keyboard.down_arrow}"
  args.outputs.debug << "** Controller"
  args.outputs.debug << "   args.inputs.controller_one.dpad_up #{args.inputs.controller_one.dpad_up}"
  args.outputs.debug << "   args.inputs.controller_one.dpad_down #{args.inputs.controller_one.dpad_down}"
  args.outputs.debug << "   args.inputs.controller_one.left_analog_y_perc #{args.inputs.controller_one.left_analog_y_perc}"
end
```

## `text`

Returns a string that represents the last key that was pressed on the keyboard.

## Mouse (`args.inputs.mouse`)

Represents the user's mouse.

### `has_focus`

Returns true if the game has mouse focus.

### `x`

Returns the current `x` location of the mouse.

### `y`

Returns the current `y` location of the mouse.

### `previous_x`

Returns the x location of the mouse on the previous frame.

### `previous_y`

Returns the y location of the mouse on the previous frame.

### `relative_x`

Returns the difference between the current x location of the mouse and its previous x location.

### `relative_y`

Returns the difference between the current y location of the mouse and its previous y location.

### `inside_rect? rect`

Return. `args.inputs.mouse.inside_rect?` takes in any primitive that responds to `x, y, w, h`:

### `inside_circle? center_point, radius`

Returns `true` if the mouse is inside of a specified circle. `args.inputs.mouse.inside_circle?` takes in any primitive that responds to `x, y` (which represents the circle's center), and takes in a `radius`:

### `moved`

Returns `true` if the mouse has moved on the current frame.

### `button_left`

Returns `true` if the left mouse button is down.

### `button_middle`

Returns `true` if the middle mouse button is down.

### `button_right`

Returns `true` if the right mouse button is down.

### `button_bits`

Returns a bitmask for all buttons on the mouse: `1` for a button in the `down` state, `0` for a button in the `up` state.

Here is a snippet to help visualize all mouse button states:
```ruby
def tick args
  args.outputs.debug.watch "button_left:   #{inputs.mouse.button_left}"
  args.outputs.debug.watch "button_middle: #{inputs.mouse.button_middle}"
  args.outputs.debug.watch "button_right:  #{inputs.mouse.button_right}"
  args.outputs.debug.watch "button_bits:   #{inputs.mouse.button_bits.to_s(2)}"
end
```

### `wheel`

Represents the mouse wheel. Returns `nil` if no mouse wheel actions occurred. Otherwise `args.inputs.mouse.wheel` will return a `Hash` with `x`, and `y` (representing movement on each axis).

### `click` OR `down`, `previous_click`, `up`

The properties `args.inputs.mouse.(click|down|previous_click|up)` each return `nil` if the mouse button event didn't occur. And return an Entity that has an `x`, `y` properties along with helper functions to determine collision: `inside_rect?`, `inside_circle`. This value will be true if any of the mouse's buttons caused these events. To scope to a specific button use `.button_left`, `.button_middle`, `.button_right`, or `.button_bits`.

### `key_down`

Returns `true` if the specific button was pressed on this frame. `args.inputs.mouse.key_down.BUTTON` will only be true on the frame it was pressed.

The following `BUTTON` values are applicable for `key_down`,
`key_held`, and `key_up`:

- `left` (eg `args.inputs.mouse.key_down.left`)
- `middle`
- `right`
- `x1`
- `x2`

### `key_held`

Returns `true` if the specific button is being held. `args.inputs.mouse.key_held.BUTTON` will be true for all frames after `key_down` (until released).

### `key_up`

Returns `true` if the specific button was released. `args.inputs.mouse.key_up.BUTTON` will be true only on the frame the button was released.

?> For a full demonstration of all mouse button states, refer to the
sample app located at `./samples/02_input_basics/02_mouse_properties`

### `buttons`

`args.inputs.mouse.buttons` provides additional mouse properties,
specifically for determining if a specific button is held and dragging
vs just being clicked.

Properites for `args.inputs.mouse.buttons` are:
- `left`
- `middle`
- `right`
- `x1`
- `x2`

Example:

```ruby
def tick args
  if args.inputs.mouse.buttons.left.buffered_click
    GTK.notify "buffered_click occurred #{args.inputs.mouse.buttons.left.id}"
  end
  
  if args.inputs.mouse.buttons.left.buffered_held
    GTK.notify "buffered_held occurred"
  end
end
```

Button properties:

- `id`: returns `:left`, `:middle`, `:right`, `:x1`, `:x2`
- `index`: returns `0`, `1`, `2`, `3`, `4`
- `click`: Returns a truthy value for if button was clicked/down.
- `click_at`: Returns `Kernel.tick_count` that button was clicked/down.
- `global_click_at`: Returns `Kernel.global_tick_count` that button was clicked/down.
- `up`: Returns a truthy value for if button was up/released.
- `up_at`: Returns `Kernel.tick_count` that button was up/released.
- `global_up_at`: Returns `Kernel.global_tick_count` that button was up/released.
- `held`: Returns a truthy value for if button was held.
- `held_at`: Returns `Kernel.tick_count` that button was held.
- `global_held_at`: Returns `Kernel.global_tick_count` that button was held.
- `buffered_click`: Returns `true` if button has been exclusively determined to be a click (and won't be considered held).
- `buffered_held`: Returns `true` if button has been exclusively determined to be hed (and won't be considered clicked).

## Touch

The following touch apis are available on touch devices (iOS, Android, Mobile Web, Surface).

### `args.inputs.touch`

Returns a `Hash` representing all touch points on a touch device.

### `args.inputs.finger_left`

Returns a `Hash` with `x` and `y` denoting a touch point that is on the left side of the screen.

### `args.inputs.finger_right`

Returns a `Hash` with `x` and `y` denoting a touch point that is on the right side of the screen.

## Controller (`args.inputs.controller_(one-four)`)

Represents controllers connected to the usb ports. There is also `args.inputs.controllers` which returns controllers one through four as an array (`args.inputs.controllers[0]` points to `args.inputs.controller_one`).

### `connected`

Returns `true` if a controller is connected. If this value is `false`, controller properties
will not be `nil`, but return `0` for directional based properties and `false` button state properties.

### `name`

String value representing the controller's name.

### `active`

Returns true if any of the controller's buttons were used.

### `up`

Returns `true` if `up` is pressed or held on the directional or left analog.

### `down`

Returns `true` if `down` is pressed or held on the directional or left analog.

### `left`

Returns `true` if `left` is pressed or held on the directional or left analog.

### `right`

Returns `true` if `right` is pressed or held on the directional or left analog.

### `left_right`

Returns `-1` (left), `0` (neutral), or `+1` (right) depending on results of `args.inputs.controller_(one-four).left` and `args.inputs.controller_(one-four).right`.

### `up_down`

Returns `-1` (down), `0` (neutral), or `+1` (up) depending on results of `args.inputs.controller_(one-four).up` and `args.inputs.controller_(one-four).down`.

### `(left|right)_analog_x_raw`

Returns the raw integer value for the analog's horizontal movement (`-32,767 to +32,767`).

### `(left|right)_analog_y_raw`

Returns the raw integer value for the analog's vertical movement (`-32,767 to +32,767`).

### `(left|right)_analog_x_perc`

Returns a number between `-1` and `1` which represents the percentage the analog is moved horizontally as a ratio of the maximum horizontal movement.

### `(left|right)_analog_y_perc`

Returns a number between `-1` and `1` which represents the percentage the analog is moved vertically as a ratio of the maximum vertical movement.

### `dpad_up`, `directional_up`

Returns `true` if `up` is pressed or held on the dpad.

### `dpad_down`, `directional_down`

Returns `true` if `down` is pressed or held on the dpad.

### `dpad_left`, `directional_left`

Returns `true` if `left` is pressed or held on the dpad.

### `dpad_right`, `directional_right`

Returns `true` if `right` is pressed or held on the dpad.

### `(a|b|x|y|l1|r1|l2|r2|l3|r3|start|select)`

Returns `true` if the specific button is pressed or held. Note: For PS4 and PS5 controllers `a` maps to Cross, `b` maps to Circle, `x` maps to Square, and `y` maps to Triangle.

### `truthy_keys`

Returns a collection of ~Symbol~s that represent all keys that are in the pressed or held state.

### `key_down`

Returns `true` if the specific button was pressed on this frame. `args.inputs.controller_(one-four).key_down.BUTTON` will only be true on the frame it was pressed.

### `key_held`

Returns `true` if the specific button is being held. `args.inputs.controller_(one-four).key_held.BUTTON` will be true for all frames after `key_down` (until released).

### `key_up`

Returns `true` if the specific button was released. `args.inputs.controller_(one-four).key_up.BUTTON` will be true only on the frame the button was released.

### `left_analog_active?(threshold_raw:, threshold_perc:)`

Returns true if the Left Analog Stick is tilted. The `threshold_raw`
and `threshold_perc` are optional parameters that can be used to set
the minimum threshold for the analog stick to be considered
active. The `threshold_raw` is a number between 0 and 32,767, and the
`threshold_perc` is a number between 0 and 1.

### `right_analog_active?(threshold_raw:, threshold_perc:)`

Returns true if the Right Analog Stick is tilted. The `threshold_raw`
and `threshold_perc` are optional parameters that can be used to set
the minimum threshold for the analog stick to be considered
active. The `threshold_raw` is a number between 0 and 32,767, and the
`threshold_perc` is a number between 0 and 1.

### `(left|right)_analog_angle`

Returns the angle of the analog in degrees for each analog stick. You
can call `.to_radius` on the return value to get the angle in radians.

### `analog_dead_zone`

The default value for this property is `3600`. You can set this to a
lower value for a more responsive analog stick, though it's not
recommended (the Steam Deck analog sticks don't always settle back to
a value lower than `3600`).

### `key_STATE?(key)`

There are situations where you may want to get the status of a key
dynamically as opposed to accessing a property. The following methods
are provided to assist in this:

- `key_down?(key)`
- `key_up?(key)`
- `key_held?(key)`
- `key_down_or_held?(key)`

Given a symbol, these functions return `true` or `false` if the key is in the
current state.

Here's how each of these methods are equivalent to key-based methods:

```ruby
# key_down equivalent
args.inputs.controller_one.key_down.enter
args.inputs.controller_one.key_down?(:enter)

# key_up
args.inputs.controller_one.key_up.enter
args.inputs.controller_one.key_up?(:enter)

# key held
args.inputs.controller_one.key_held.enter
args.inputs.controller_one.key_held?(:enter)

# key down or held
args.inputs.controller_one.enter
args.inputs.controller_one.key_down_or_held?(:enter)
```

## Keyboard or Controller On (`args.inputs.key_(down|up|held)`)

Represents directional input that is shared between keyboard and
controller. Useful for supporting directional input that can come from
keyboard or controller.

Shared keys:
- `left`
- `right`
- `up`
- `down`

Demonstration:
```ruby
def tick args
  args.outputs.watch "args.inputs.left                         #{args.inputs.left}"
  args.outputs.watch "args.inputs.keyboard.left                #{args.inputs.keyboard.left}"
  args.outputs.watch "args.inputs.controller_one.left          #{args.inputs.controller_one.left}"
  args.outputs.watch "args.inputs.key_down.left                #{args.inputs.key_down.left}"
  args.outputs.watch "args.inputs.keyboard.key_down.left       #{args.inputs.keyboard.key_down.left}"
  args.outputs.watch "args.inputs.controller_one.key_down.left #{args.inputs.controller_one.key_down.left}"
  args.outputs.watch "args.inputs.key_held.left                #{args.inputs.key_held.left}"
  args.outputs.watch "args.inputs.keyboard.key_held.left       #{args.inputs.keyboard.key_held.left}"
  args.outputs.watch "args.inputs.controller_one.key_held.left #{args.inputs.controller_one.key_held.left}"
  args.outputs.watch "args.inputs.key_up.left                  #{args.inputs.key_up.left}"
  args.outputs.watch "args.inputs.keyboard.key_up.left         #{args.inputs.keyboard.key_up.left}"
  args.outputs.watch "args.inputs.controller_one.key_up.left   #{args.inputs.controller_one.key_up.left}"
end
```

## Keyboard (`args.inputs.keyboard`)

Represents the user's keyboard.

### `active`

Returns `Kernel.tick_count` if any keys on the keyboard were pressed.

### `has_focus`

Returns `true` if the game has keyboard focus.

### `up`

Returns `true` if `up` or `w` is pressed or held on the keyboard.

### `down`

Returns `true` if `down` or `s` is pressed or held on the keyboard.

### `left`

Returns `true` if `left` or `a` is pressed or held on the keyboard.

### `right`

Returns `true` if `right` or `d` is pressed or held on the keyboard.

### `left_right`

Returns `-1` (left), `0` (neutral), or `+1` (right) depending on results of `args.inputs.keyboard.left` and `args.inputs.keyboard.right`.

### `up_down`

Returns `-1` (left), `0` (neutral), or `+1` (right) depending on results of `args.inputs.keyboard.up` and `args.inputs.keyboard.up`.

### Keyboard properties

The following properties represent keys on the keyboard and are available on `args.inputs.keyboard.KEY`, `args.inputs.keyboard.key_down.KEY`, `args.inputs.keyboard.key_held.KEY`, `args.inputs.keyboard.key_up.KEY`, `args.inputs.keyboard.key_repeat.KEY`:

Here is an example showing all the ways to access a key's state:

```ruby
def tick args
  # create a value in state to
  # track tick_count of the G key
  args.state.g_key ||= {
    ctrl_at: nil,
    key_down_at: nil,
    key_repeat_at: nil,
    key_last_repeat_at: nil,
    key_held_at: nil,
    key_down_or_held_at: nil,
    key_up_at: nil,
  }

  # for each keyboard event, capture the tick_count
  # that the event occurred
  # Ctrl + G
  if args.inputs.keyboard.ctrl_g
    args.state.g_key.ctrl_at = args.inputs.keyboard.ctrl_g
  end

  # G pressed/down
  if args.inputs.keyboard.key_down.g
    args.state.g_key.key_down_at = args.inputs.keyboard.key_down.g
  end

  # G pressed or repeated (based on OS key repeat speed)
  if args.inputs.keyboard.key_repeat.g
    args.state.g_key.key_last_repeat_at = args.state.g_key.key_repeat_at
    args.state.g_key.key_repeat_at = args.inputs.keyboard.key_repeat.g
  end

  # G held
  if args.inputs.keyboard.key_held.g
    args.state.g_key.key_held_at = args.inputs.keyboard.key_held.g
  end

  # G down or held
  if args.inputs.keyboard.g
    args.state.g_key.key_down_or_held_at = args.inputs.keyboard.g
  end

  # G up
  if args.inputs.keyboard.key_up.g
    args.state.g_key.key_up_at = args.inputs.keyboard.key_up.g
  end

  # display the tick_count of each event
  args.outputs.debug.watch "ctrl+g?         #{args.state.g_key.ctrl_at}"
  args.outputs.debug.watch "g down?         #{args.state.g_key.key_down_at}"
  args.outputs.debug.watch "g repeat?       #{args.state.g_key.key_repeat_at}"
  args.outputs.debug.watch "g last_repeat?  #{args.state.g_key.key_last_repeat_at}"
  args.outputs.debug.watch "g held?         #{args.state.g_key.key_held_at}"
  args.outputs.debug.watch "g down or held? #{args.state.g_key.key_down_or_held_at}"
  args.outputs.debug.watch "g up?           #{args.state.g_key.key_up_at}"
end
```

-   `alt`
-   `meta`
-   `control`, `ctrl`
-   `shift`
-   `control_KEY`, `ctrl_KEY` (dynamic method, eg `args.inputs.keyboard.ctrl_a`)
-   `exclamation_point`
-   `zero` - `nine`
-   `backspace`
-   `delete`
-   `escape`
-   `enter`
-   `tab`
-   `(open|close)_round_brace`
-   `(open|close)_curly_brace`
-   `(open|close)_square_brace`
-   `colon`
-   `semicolon`
-   `equal`
-   `hyphen`
-   `space`
-   `dollar`
-   `percent`
-   `double_quotation_mark`
-   `single_quotation_mark`
-   `backtick`
-   `tilde`
-   `period`
-   `comma`
-   `pipe`
-   `underscore`
-   `ac_back` (`ac` stands for Application Control, with `ac_back` representing Back button on a device (eg Android back button)
-   `ac_home`
-   `ac_forward`
-   `ac_stop`
-   `ac_refresh`
-   `ac_bookmarks`
-   `a` - `z`
-   `w_scancode` (key location for w in WASD layout across regions)
-   `a_scancode` (key location for a in WASD layout across regions)
-   `s_scancode` (key location for s in WASD layout across regions)
-   `d_scancode` (key location for d in WASD layout across regions)
-   `shift`
-   `shift_left`
-   `shift_right`
-   `control`, `ctrl`
-   `control_left`, `ctrl_left`
-   `control_right`, `ctrl_right`
-   `alt`, `option`
-   `alt_left`, `option_left`
-   `alt_right`, `option_right`
-   `meta`, `command`
-   `meta_left`, `command_left`
-   `meta_right`, `command_right`
-   `left_arrow`
-   `right_arrow`
-   `up_arrow`
-   `down_arrow`
-   `left_arrow`, `left`
-   `right_arrow`, `right`
-   `up_arrow`, `up`
-   `down_arrow` `down`
-   `pageup`
-   `pagedown`
-   `plus`
-   `at`
-   `hash`
-   `forward_slash`
-   `back_slash`
-   `asterisk`
-   `less_than`
-   `greater_than`
-   `ampersand`
-   `superscript_two`
-   `caret`
-   `question_mark`
-   `section`
-   `ordinal_indicator`
-   `raw_key` (unique numeric identifier for key)
-   `caps_lock`
-   `f1`
-   `f2`
-   `f3`
-   `f4`
-   `f5`
-   `f6`
-   `f7`
-   `f8`
-   `f9`
-   `f10`
-   `f11`
-   `f12`
-   `print_screen`
-   `scroll_lock`
-   `pause`
-   `insert`
-   `home`
-   `page_up`
-   `delete`
-   `end`
-   `page_down`
-   `num_lock`
-   `kp_divide`
-   `kp_multiply`
-   `kp_minus`
-   `kp_plus`
-   `kp_enter`
-   `kp_one`
-   `kp_two`
-   `kp_three`
-   `kp_four`
-   `kp_five`
-   `kp_six`
-   `kp_seven`
-   `kp_eight`
-   `kp_nine`
-   `kp_zero`
-   `kp_period`
-   `kp_equals`
-   `left_right`
-   `last_left_right`
-   `up_down`
-   `last_up_down`
-   `directional_vector` (returns normalized vector based off of WASD/arrow keys, `nil` if no keys are down/held)
-   `last_directional_vector` (returns normalized vector based off of WASD/arrow keys, `nil` if no keys are down/held)
-   `directional_angle` (returns angle in degrees based off of WASD/arrow keys, `nil` if no keys are down/held)
-   `truthy_keys` (array of `Symbols`)

### `keycodes`

If the explicit named key isn't in the list above, you can still get the raw keycode via `args.inputs.keyboard.key_(down|held|up).keycodes[KEYCODE_NUMBER]`. The `KEYCODE_NUMBER` represents the keycode provided by SDL.

Here is a list SDL Keycodes: <https://wiki.libsdl.org/SDL2/SDLKeycodeLookup>

### `char`

Method is available under `inputs.key_down`, `inputs.key_held`, and `inputs.key_up`. Take note that
`args.inputs.keyboard.key_held.char` will only return the ascii value of the last key that was held. Use
`args.inputs.keyboard.key_held.truthy_keys` to get an `Array` of `Symbols` representing all keys being held.

To get a picture of all key states `args.inputs.keyboard.keys` returns a `Hash` with the following keys: `:down`, `:held`, `:down_or_held`, `:up`.

NOTE: `args.inputs.keyboard.key_down.char` will be set in line with key repeat behavior of your OS.

This is a demonstration of the behavior (see `./samples/02_input_basics/01_keyboard` for a more detailed example):

```ruby
def tick args
  # uncomment the line below to see the value changes at a slower rate
  # $gtk.slowmo! 30

  keyboard = args.inputs.keyboard

  args.outputs.labels << { x: 30,
                           y: 720,
                           text: "use the J key to test" }

  args.outputs.labels << { x: 30,
                           y: 720 - 30,
                           text: "key_down.char: #{keyboard.key_down.char.inspect}" }

  args.outputs.labels << { x: 30,
                           y: 720 - 60,
                           text: "key_down.j:    #{keyboard.key_down.j}" }

  args.outputs.labels << { x: 30,
                           y: 720 - 30,
                           text: "key_held.char: #{keyboard.key_held.char.inspect}" }

  args.outputs.labels << { x: 30,
                           y: 720 - 60,
                           text: "key_held.j:    #{keyboard.key_held.j}" }

  args.outputs.labels << { x: 30,
                           y: 720 - 30,
                           text: "key_up.char:   #{keyboard.key_up.char.inspect}" }

  args.outputs.labels << { x: 30,
                           y: 720 - 60,
                           text: "key_up.j:      #{keyboard.key_up.j}" }
end
```

### `key_STATE?(key)`

There are situations where you may want to get the status of a key
dynamically as opposed to accessing a property. The following methods
are provided to assist in this:

- `key_down?(key)`
- `key_up?(key)`
- `key_held?(key)`
- `key_down_or_held?(key)`
- `key_repeat?(key)`

Given a symbol, these methods return `true` or `false` if the key is in the
current state.

Here's how each of these methods are equivalent to key-based methods:

```ruby
# key_down equivalent
args.inputs.keyboard.key_down.enter
args.inputs.keyboard.key_down?(:enter)

# key_up
args.inputs.keyboard.key_up.enter
args.inputs.keyboard.key_up?(:enter)

# key held
args.inputs.keyboard.key_held.enter
args.inputs.keyboard.key_held?(:enter)

# key down or held
args.inputs.keyboard.enter
args.inputs.keyboard.key_down_or_held?(:enter)
```

### `keys`

Returns a `Hash` with all keys on the keyboard in their respective state. The `Hash` contains the following `keys`

-   `:down`
-   `:held`
-   `:down_or_held`
-   `:up`
-   `:repeat`
