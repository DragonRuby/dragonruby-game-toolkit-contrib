# coding: utf-8
# Copyright 2020 DragonRuby LLC
# MIT License
# inputs_docs.rb has been released under MIT (*only this file*).

module InputsDocs
  def docs_api_summary_inputs
    <<-S
* Inputs (~args.inputs~)
Access using input using ~args.inputs~.
** ~last_active~
This function returns the last active input which will be set to either ~:keyboard~,
~:mouse~, or ~:controller~. The function is helpful when you need to present on screen
instructions based on the input the player chose to play with.

#+begin_src
  def tick args
    if args.inputs.last_active == :controller
      args.outputs.labels << { x: 60, y: 60, text: "Use the D-Pad to move around." }
    else
      args.outputs.labels << { x: 60, y: 60, text: "Use the arrow keys to move around." }
    end
  end
#+end_src
~:mouse~, or ~:controller~. The function is helpful when you need to present on screen
instructions based on the input the player chose to play with.
** ~locale~
Returns the ISO 639-1 two-letter langauge code based on OS preferences. Refer to the following link for locale strings: [[https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes]]).

Defaults to "en" if locale can't be retrieved (~args.inputs.locale_raw~ will be nil in this case).
** ~up~
Returns ~true~ if: the ~up~ arrow or ~w~ key is pressed or held on the ~keyboard~; or if ~up~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted upwards.
** ~down~
Returns ~true~ if: the ~down~ arrow or ~s~ key is pressed or held on the ~keyboard~; or if ~down~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted downwards.
** ~left~
Returns ~true~ if: the ~left~ arrow or ~a~ key is pressed or held on the ~keyboard~; or if ~left~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted to the left.
** ~right~
Returns ~true~ if: the ~right~ arrow or ~d~ key is pressed or held on the ~keyboard~; or if ~right~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted to the right.
** ~left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right). This method is aliased to ~args.inputs.left_right_with_wasd~.

The following inputs are inspected to determine the result:
- Keyboard's left, right arrow keys: ~args.inputs.keyboard.(left|right)_arrow~
- Keyboard's a, d keys (WASD): ~args.inputs.keyboard.(a|d)~
- Controller One's DPAD (if a controller is connected): ~args.inputs.controller_one.dpad_left~, ~args.inputs.controller_one.dpad_right~
- Controller One's Left Analog (if a controller is connected): ~args.inputs.controller_one.left_analog_x_perc.abs >= 0.6~
** ~left_right_perc~
Returns a floating point value between ~-1~ and ~1~. This method is aliased to ~args.inputs.left_right_perc_with_wasd~

The following inputs are inspected to dermine the result:
- Controller One's Left Analog (if a controller is connected and the value is not 0.0): ~args.inputs.controller_one.left_analog_x_perc~
- If the left analog isn't being used, then Controller One's DPAD is consulted: ~args.inputs.controller_one.dpad_left~, ~args.inputs.controller_one.dpad_right~
- Keyboard's a, d keys (WASD): ~args.inputs.keyboard.(a|d)~
- Keyboard's left/right arrow keys: ~args.inputs.keyboard.(left|right)_arrow~
** ~left_right_directional~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right). This method is aliased to ~args.inputs.left_right_arrow~.

The following inputs are inspected to determine the result:
- Keyboard's left/right arrow keys: ~args.inputs.keyboard.(left|right)_arrow~
- Controller One's DPAD (if a controller is connected): ~args.inputs.controller_one.dpad_left~, ~args.inputs.controller_one.dpad_right~
- WASD and Controller One's Left Analog Stick are NOT consulted.
** ~left_right_directional_perc~
Returns a floating point value between ~-1~ and ~1~.
The following inputs are inspected to dermine the result:
- Controller One's Left Analog (if a controller is connected and the value is not 0.0): ~args.inputs.controller_one.left_analog_x_perc~
- If the left analog isn't being used, then Controller One's DPAD is consulted: ~args.inputs.controller_one.dpad_left~, ~args.inputs.controller_one.dpad_right~
- Keyboard's left/right arrow keys: ~args.inputs.keyboard.(left|right)_arrow~
- WASD is NOT consulted.

Here is some sample code to help visualize the ~left_right~ functions.

#+begin_src
  def tick args
    args.outputs.debug << "* Variations of args.inputs.left_right"
    args.outputs.debug << "  args.inputs.left_right(_with_wasd) \#{args.inputs.left_right}"
    args.outputs.debug << "  args.inputs.left_right_perc(_with_wasd) \#{args.inputs.left_right_perc}"
    args.outputs.debug << "  args.inputs.left_right_directional \#{args.inputs.left_right_directional}"
    args.outputs.debug << "  args.inputs.left_right_directional_perc \#{args.inputs.left_right_directional_perc}"
    args.outputs.debug << "** Keyboard"
    args.outputs.debug << "   args.inputs.keyboard.a \#{args.inputs.keyboard.a}"
    args.outputs.debug << "   args.inputs.keyboard.d \#{args.inputs.keyboard.d}"
    args.outputs.debug << "   args.inputs.keyboard.left_arrow \#{args.inputs.keyboard.left_arrow}"
    args.outputs.debug << "   args.inputs.keyboard.right_arrow \#{args.inputs.keyboard.right_arrow}"
    args.outputs.debug << "** Controller"
    args.outputs.debug << "   args.inputs.controller_one.dpad_left \#{args.inputs.controller_one.dpad_left}"
    args.outputs.debug << "   args.inputs.controller_one.dpad_right \#{args.inputs.controller_one.dpad_right}"
    args.outputs.debug << "   args.inputs.controller_one.left_analog_x_perc \#{args.inputs.controller_one.left_analog_x_perc}"
  end
#+end_src
** ~up_down~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up). This method is aliased to ~args.inputs.up_down_with_wasd~.

The following inputs are inspected to determine the result:
- Keyboard's up/down arrow keys: ~args.inputs.keyboard.(up|down)_arrow~
- Keyboard's w, s keys (WASD): ~args.inputs.keyboard.(w|s)~
- Controller One's DPAD (if a controller is connected): ~args.inputs.controller_one.dpad_up~, ~args.inputs.controller_one.dpad_down~
- Controller One's Up Analog (if a controller is connected): ~args.inputs.controller_one.up_analog_y_perc.abs >= 0.6~
** ~up_down_directional~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up). This method is aliased to ~args.inputs.up_down_arrow~.

The following inputs are inspected to determine the result:
- Keyboard's up/down arrow keys: ~args.inputs.keyboard.(up|down)_arrow~
- Controller One's DPAD (if a controller is connected): ~args.inputs.controller_one.dpad_up~, ~args.inputs.controller_one.dpad_down~
- WASD and Controller One's Left Analog Stick are NOT consulted.
** ~up_down_perc~
Returns a floating point value between ~-1~ and ~1~.
The following inputs are inspected to dermine the result:
- Controller One's Left Analog (if a controller is connected and the value is not 0.0): ~args.inputs.controller_one.up_analog_y_perc~
- If the left analog isn't being used, then Controller One's DPAD is consulted: ~args.inputs.controller_one.dpad_up~, ~args.inputs.controller_one.dpad_down~
- Keyboard's up/down arrow keys: ~args.inputs.keyboard.(up|down)_arrow~
- WASD is NOT consulted.

Here is some sample code to help visualize the ~up_down~ functions.

#+begin_src
  def tick args
    args.outputs.debug << "* Variations of args.inputs.up_down"
    args.outputs.debug << "  args.inputs.up_down \#{args.inputs.up_down}"
    args.outputs.debug << "  args.inputs.up_down_directional \#{args.inputs.up_down_directional}"
    args.outputs.debug << "  args.inputs.up_down_perc \#{args.inputs.up_down_perc}"
    args.outputs.debug << "** Keyboard"
    args.outputs.debug << "   args.inputs.keyboard.a \#{args.inputs.keyboard.a}"
    args.outputs.debug << "   args.inputs.keyboard.d \#{args.inputs.keyboard.d}"
    args.outputs.debug << "   args.inputs.keyboard.up_arrow \#{args.inputs.keyboard.up_arrow}"
    args.outputs.debug << "   args.inputs.keyboard.down_arrow \#{args.inputs.keyboard.down_arrow}"
    args.outputs.debug << "** Controller"
    args.outputs.debug << "   args.inputs.controller_one.dpad_up \#{args.inputs.controller_one.dpad_up}"
    args.outputs.debug << "   args.inputs.controller_one.dpad_down \#{args.inputs.controller_one.dpad_down}"
    args.outputs.debug << "   args.inputs.controller_one.up_analog_x_perc \#{args.inputs.controller_one.up_analog_x_perc}"
  end
#+end_src
** ~text~
Returns a string that represents the last key that was pressed on the keyboard.
** Mouse (~args.inputs.mouse~)
Represents the user's mouse.
*** ~has_focus~
Return's true if the game has mouse focus.
*** ~x~
Returns the current ~x~ location of the mouse.
*** ~y~
Returns the current ~y~ location of the mouse.
*** ~inside_rect? rect~
Return. ~args.inputs.mouse.inside_rect?~ takes in any primitive that responds to ~x, y, w, h~:
*** ~inside_circle? center_point, radius~
Returns ~true~ if the mouse is inside of a specified circle. ~args.inputs.mouse.inside_circle?~ takes in any primitive that responds to ~x, y~ (which represents the circle's center), and takes in a ~radius~:
*** ~moved~
Returns ~true~ if the mouse has moved on the current frame.
*** ~button_left~
Returns ~true~ if the left mouse button is down.
*** ~button_middle~
Returns ~true~ if the middle mouse button is down.
*** ~button_right~
Returns ~true~ if the right mouse button is down.
*** ~button_bits~
Returns a bitmask for all buttons on the mouse: ~1~ for a button in the ~down~ state, ~0~ for a button in the ~up~ state.
*** ~wheel~
Represents the mouse wheel. Returns ~nil~ if no mouse wheel actions occurred. Otherwise ~args.inputs.mouse.wheel~ will
return a ~Hash~ with ~x~, and ~y~ (representing movement on each axis).
*** ~click~ OR ~down~, ~previous_click~, ~up~
The properties ~args.inputs.mouse.(click|down|previous_click|up)~ each return ~nil~ if the mouse button event didn't occur. And return an Entity
that has an ~x~, ~y~ properties along with helper functions to determine collision: ~inside_rect?~, ~inside_circle~. This value will be true if any
of the mouse's buttons caused these events. To scope to a specific button use ~.button_left~, ~.button_middle~, ~.button_right~, or ~.button_bits~.
** Touch
The following touch apis are available on touch devices (iOS, Android, Mobile Web, Surface).
*** ~args.inputs.touch~
Returns a ~Hash~ representing all touch points on a touch device.
*** ~args.inputs.finger_left~
Returns a ~Hash~ with ~x~ and ~y~ denoting a touch point that is on the left side of the screen.
*** ~args.inputs.finger_right~
Returns a ~Hash~ with ~x~ and ~y~ denoting a touch point that is on the right side of the screen.
** Controller (~args.inputs.controller_(one-four)~)
Represents controllers connected to the usb ports. There is also ~args.inputs.controllers~ which returns controllers
one through four as an array (~args.inputs.controllers[0]~ points to ~args.inputs.controller_one~).
*** ~active~
Returns true if any of the controller's buttons were used.
*** ~up~
Returns ~true~ if ~up~ is pressed or held on the directional or left analog.
*** ~down~
Returns ~true~ if ~down~ is pressed or held on the directional or left analog.
*** ~left~
Returns ~true~ if ~left~ is pressed or held on the directional or left analog.
*** ~right~
Returns ~true~ if ~right~ is pressed or held on the directional or left analog.
*** ~left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.controller_(one-four).left~ and ~args.inputs.controller_(one-four).right~.
*** ~up_down~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up) depending on results of ~args.inputs.controller_(one-four).up~ and ~args.inputs.controller_(one-four).down~.
*** ~(left|right)_analog_x_raw~
Returns the raw integer value for the analog's horizontal movement (~-32,767 to +32,767~).
*** ~(left|right)_analog_y_raw~
Returns the raw integer value for the analog's vertical movement (~-32,767 to +32,767~).
*** ~(left|right)_analog_x_perc~
Returns a number between ~-1~ and ~1~ which represents the percentage the analog is moved horizontally as a ratio of the maximum horizontal movement.
*** ~(left|right)_analog_y_perc~
Returns a number between ~-1~ and ~1~ which represents the percentage the analog is moved vertically as a ratio of the maximum vertical movement.
*** ~dpad_up~, ~directional_up~
Returns ~true~ if ~up~ is pressed or held on the dpad.
*** ~dpad_down~, ~directional_down~
Returns ~true~ if ~down~ is pressed or held on the dpad.
*** ~dpad_left~, ~directional_left~
Returns ~true~ if ~left~ is pressed or held on the dpad.
*** ~dpad_right~, ~directional_right~
Returns ~true~ if ~right~ is pressed or held on the dpad.
*** ~(a|b|x|y|l1|r1|l2|r2|l3|r3|start|select)~
Returns ~true~ if the specific button is pressed or held.
Note: For PS4 and PS5 controllers ~a~ maps to Cross, ~b~ maps to Circle, ~x~ maps to Square, and ~y~ maps to Triangle.
*** ~truthy_keys~
Returns a collection of ~Symbol~s that represent all keys that are in the pressed or held state.
*** ~key_down~
Returns ~true~ if the specific button was pressed on this frame. ~args.inputs.controller_(one-four).key_down.BUTTON~ will only be true on the frame it was pressed.
*** ~key_held~
Returns ~true~ if the specific button is being held. ~args.inputs.controller_(one-four).key_held.BUTTON~ will be true for all frames after ~key_down~ (until released).
*** ~key_up~
Returns ~true~ if the specific button was released. ~args.inputs.controller_(one-four).key_up.BUTTON~ will be true only on the frame the button was released.
** Keyboard (~args.inputs.keyboard~)
Represents the user's keyboard.
*** ~active~
Returns ~Kernel.tick_count~ (~args.state.tick_count~) if any keys on the keyboard were pressed.
*** ~has_focus~
Returns ~true~ if the game has keyboard focus.
*** ~up~
Returns ~true~ if ~up~ or ~w~ is pressed or held on the keyboard.
*** ~down~
Returns ~true~ if ~down~ or ~s~ is pressed or held on the keyboard.
*** ~left~
Returns ~true~ if ~left~ or ~a~ is pressed or held on the keyboard.
*** ~right~
Returns ~true~ if ~right~ or ~d~ is pressed or held on the keyboard.
*** ~left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.keyboard.left~ and ~args.inputs.keyboard.right~.
*** ~up_down~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.keyboard.up~ and ~args.inputs.keyboard.up~.
*** keyboard properties
The following properties represent keys on the keyboard and are available on ~args.inputs.keyboard.KEY~, ~args.inputs.keyboard.key_down.KEY~, ~args.inputs.keyboard.key_held.KEY~, and ~args.inputs.keyboard.key_up.KEY~:
- ~alt~
- ~meta~
- ~control~, ~ctrl~
- ~shift~
- ~control_KEY~, ~ctrl_KEY~ (dynamic method, eg ~args.inputs.keyboard.ctrl_a~)
- ~exclamation_point~
- ~zero~ - ~nine~
- ~backspace~
- ~delete~
- ~escape~
- ~enter~
- ~tab~
- ~(open|close)_round_brace~
- ~(open|close)_curly_brace~
- ~(open|close)_square_brace~
- ~colon~
- ~semicolon~
- ~equal~
- ~hyphen~
- ~space~
- ~dollar~
- ~percent~
- ~double_quotation_mark~
- ~single_quotation_mark~
- ~backtick~
- ~tilde~
- ~period~
- ~comma~
- ~pipe~
- ~underscore~
- ~ac_back~ (~ac~ stands for Application Control, with ~ac_back~ representing Back button on a device (eg Android back button)
- ~ac_home~
- ~ac_forward~
- ~ac_stop~
- ~ac_refresh~
- ~ac_bookmarks~
- ~a~ - ~z~
- ~w_scancode~ (key location for w in WASD layout across regions)
- ~a_scancode~ (key location for a in WASD layout across regions)
- ~s_scancode~ (key location for s in WASD layout across regions)
- ~d_scancode~ (key location for d in WASD layout across regions)
- ~shift~
- ~shift_left~
- ~shift_right~
- ~control~, ~ctrl~
- ~contro_left~, ~ctrl_left~
- ~contro_right~, ~ctrl_right~
- ~alt~, ~option~
- ~alt_left~, ~option_left~
- ~alt_right~, ~option_right~
- ~meta~, ~command~
- ~meta_left~, ~command_left~
- ~meta_right~, ~command_right~
- ~left_arrow~
- ~right_arrow~
- ~up_arrow~
- ~down_arrow~
- ~left_arrow~, ~left~
- ~right_arrow~, ~right~
- ~up_arrow~, ~up~
- ~down_arrow~ ~down~
- ~pageup~
- ~pagedown~
- ~plus~
- ~at~
- ~hash~
- ~forward_slash~
- ~back_slash~
- ~asterisk~
- ~less_than~
- ~greater_than~
- ~ampersand~
- ~superscript_two~
- ~caret~
- ~question_mark~
- ~section~
- ~ordinal_indicator~
- ~raw_key~ (unique numeric identifier for key)
- ~left_right~
- ~up_down~
- ~directional_vector~
- ~truthy_keys~ (array of ~Symbols~)
*** ~keycodes~
If the explicit named key isn't in the list above, you can still get the raw keycode via
~args.inputs.keyboard.key_(down|held|up).keycodes[KEYCODE_NUMBER]~. The ~KEYCODE_NUMBER~ represents
the keycode provided by SDL: https://wiki.libsdl.org/SDL2/SDLKeycodeLookup
*** ~char~
Method is available under ~inputs.key_down~, ~inputs.key_held~, and ~inputs.key_up~.  Take note that

~args.inputs.keyboard.key_held.char~ will only return the ascii value
of the last key that was held. Use ~args.inputs.keyboard.key_held.truthy_keys~
to get an ~Array~ of ~Symbols~ representing all keys being held.

To get a picture of all key states ~args.inputs.keyboard.keys~ returns a ~Hash~
with the following keys: ~:down~, ~:held~, ~:down_or_held~, ~:up~.

NOTE: ~args.inputs.keyboard.key_down.char~ will be set in line with key repeat behavior of your OS.

This is a demonstration of the behavior (see ~./samples/02_input_basics/01_keyboard~ for a more detailed example):

#+begin_src
  def tick args
    # uncomment the line below to see the value changes at a slower rate
    # $gtk.slowmo! 30

    keyboard = args.inputs.keyboard

    args.outputs.labels << { x: 30,
                             y: 720,
                             text: "use the J key to test" }

    args.outputs.labels << { x: 30,
                             y: 720 - 30,
                             text: "key_down.char: \#{keyboard.key_down.char.inspect}" }

    args.outputs.labels << { x: 30,
                             y: 720 - 60,
                             text: "key_down.j:    \#{keyboard.key_down.j}" }

    args.outputs.labels << { x: 30,
                             y: 720 - 30,
                             text: "key_held.char: \#{keyboard.key_held.char.inspect}" }

    args.outputs.labels << { x: 30,
                             y: 720 - 60,
                             text: "key_held.j:    \#{keyboard.key_held.j}" }

    args.outputs.labels << { x: 30,
                             y: 720 - 30,
                             text: "key_up.char:   \#{keyboard.key_up.char.inspect}" }

    args.outputs.labels << { x: 30,
                             y: 720 - 60,
                             text: "key_up.j:      \#{keyboard.key_up.j}" }
  end
#+end_src

*** ~keys~
Returns a ~Hash~ with all keys on the keyboard in their respective state. The ~Hash~ contains the following ~keys~
- ~:down~
- ~:held~
- ~:down_or_held~
- ~:up~
S
  end

end

class GTK::Inputs
  extend Docs
  extend InputsDocs
end
