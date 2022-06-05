# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# runtime_docs.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# Ketan Patel: https://github.com/cookieoverflow

module RuntimeDocs
  def docs_method_sort_order
    [
      :docs_api_summary_gtk,
      :docs_api_summary_state,
      :docs_api_summary_inputs,
      :docs_api_summary_outputs,
      :docs_api_summary_geometry,
      :docs_api_summary_easing,
      :docs_api_summary_grid,
      :docs_platform?,
      :docs_calcstringbox,
      :docs_write_file,
      :docs_benchmark
    ]
  end

  def docs_class
    <<-S
* DOCS: ~GTK::Runtime~
The GTK::Runtime class is the core of DragonRuby. It is globally accessible via ~$gtk~.
S
  end

  def docs_api_summary_state
    <<-S
* ~args.state~
Store your game state inside of this ~state~. Properties with arbitrary nesting is allowed and a backing Entity will be created on your behalf.
#+begin_src
  def tick args
    args.state.player.x ||= 0
    args.state.player.y ||= 0
  end
#+end_src
** ~args.state.*.entity_id~
Entities automatically receive an ~entity_id~ of type ~Fixnum~.
** ~args.state.*.entity_type~
Entities can have an ~entity_type~ which is represented as a ~Symbol~.
** ~args.state.*.created_at~
Entities have ~created_at~ set to ~args.state.tick_count~ when they are created.
** ~args.state.*.created_at_elapsed~
Returns the elapsed number of ticks since creation.
** ~args.state.*.global_created_at~
Entities have ~global_created_at~ set to ~Kernel.global_tick_count~ when they are created.
** ~args.state.*.global_created_at_elapsed~
Returns the elapsed number of global ticks since creation.
** ~args.state.*.as_hash~
Entity cast to a ~Hash~ so you can update values as if you were updating a ~Hash~.
** ~args.state.new_entity~
Creates a new Entity with a ~type~, and initial properties. An option block can be passed to change the newly created entity:
#+begin_src ruby
  def tick args
    args.state.player ||= args.state.new_entity :player, x: 0, y: 0 do |e|
      e.max_hp = 100
      e.hp     = e.max_hp * rand
    end
  end
#+end_src
** ~args.state.new_entity_strict~
Creates a new Strict Entity. While Entities created via ~args.state.new_entity~ can have new properties added later on, Entities created
using ~args.state.new_entity~ must define all properties that are allowed during its initialization. Attempting to add new properties after
initialization will result in an exception.
** ~args.state.tick_count~
Returns the current tick of the game. ~args.state.tick_count~ is ~0~ when the game is first started or if the game is reset via ~$gtk.reset~.
S
  end

  def docs_api_summary_inputs
    <<-S
* ~args.inputs~
Access using input using ~args.inputs~.
** ~args.inputs.up~
Returns ~true~ if: the ~up~ arrow or ~w~ key is pressed or held on the ~keyboard~; or if ~up~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted upwards.
** ~args.inputs.down~
Returns ~true~ if: the ~down~ arrow or ~s~ key is pressed or held on the ~keyboard~; or if ~down~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted downwards.
** ~args.inputs.left~
Returns ~true~ if: the ~left~ arrow or ~a~ key is pressed or held on the ~keyboard~; or if ~left~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted to the left.
** ~args.inputs.right~
Returns ~true~ if: the ~right~ arrow or ~d~ key is pressed or held on the ~keyboard~; or if ~right~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted to the right.
** ~args.inputs.left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.left~ and ~args.inputs.right~.
** ~args.inputs.up_down~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up) depending on results of ~args.inputs.down~ and ~args.inputs.up~.
** ~args.inputs.text~ OR ~args.inputs.history~
Returns a string that represents the last key that was pressed on the keyboard.
** ~args.inputs.mouse~
Represents the user's mouse.
*** ~args.inputs.mouse.has_focus~
Return's true if the game has mouse focus.
*** ~args.inputs.mouse.x~
Returns the current ~x~ location of the mouse.
*** ~args.inputs.mouse.y~
Returns the current ~y~ location of the mouse.
*** ~args.inputs.mouse.inside_rect? rect~
Return. ~args.inputs.mouse.inside_rect?~ takes in any primitive that responds to ~x, y, w, h~:
*** ~args.inputs.mouse.inside_circle? center_point, radius~
Returns ~true~ if the mouse is inside of a specified circle. ~args.inputs.mouse.inside_circle?~ takes in any primitive that responds to ~x, y~ (which represents the circle's center), and takes in a ~radius~:
*** ~args.inputs.mouse.moved~
Returns ~true~ if the mouse has moved on the current frame.
*** ~args.inputs.mouse.button_left~
Returns ~true~ if the left mouse button is down.
*** ~args.inputs.mouse.button_middle~
Returns ~true~ if the middle mouse button is down.
*** ~args.inputs.mouse.button_right~
Returns ~true~ if the right mouse button is down.
*** ~args.inputs.mouse.button_bits~
Returns a bitmask for all buttons on the mouse: ~1~ for a button in the ~down~ state, ~0~ for a button in the ~up~ state.
*** ~args.inputs.mouse.wheel~
Represents the mouse wheel. Returns ~nil~ if no mouse wheel actions occurred.
**** ~args.inputs.mouse.wheel.x~
Returns the negative or positive number if the mouse wheel has changed in the ~x~ axis.
**** ~args.inputs.mouse.wheel.y~
Returns the negative or positive number if the mouse wheel has changed in the ~y~ axis.
*** ~args.inputs.mouse.click~ OR ~.down~, ~.previous_click~, ~.up~
The properties ~args.inputs.mouse.(click|down|previous_click|up)~ each return ~nil~ if the mouse button event didn't occur. And return an Entity
that has an ~x~, ~y~ properties along with helper functions to determine collision: ~inside_rect?~, ~inside_circle~.
** ~args.inputs.controller_one~, ~.controller_two~
Represents controllers connected to the usb ports.
*** ~args.inputs.controller_(one|two|three|four).up~
Returns ~true~ if ~up~ is pressed or held on the directional or left analog.
*** ~args.inputs.controller_(one|two|three|four).down~
Returns ~true~ if ~down~ is pressed or held on the directional or left analog.
*** ~args.inputs.controller_(one|two|three|four).left~
Returns ~true~ if ~left~ is pressed or held on the directional or left analog.
*** ~args.inputs.controller_(one|two|three|four).right~
Returns ~true~ if ~right~ is pressed or held on the directional or left analog.
*** ~args.inputs.controller_(one|two|three|four).left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.controller_(one|two|three|four).left~ and ~args.inputs.controller_(one|two|three|four).right~.
*** ~args.inputs.controller_(one|two|three|four).up_down~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up) depending on results of ~args.inputs.controller_(one|two|three|four).up~ and ~args.inputs.controller_(one|two|three|four).down~.
*** ~args.inputs.controller_(one|two|three|four).(left_analog_x_raw|right_analog_x_raw)~
Returns the raw integer value for the analog's horizontal movement (~-32,000 to +32,000~).
*** ~args.inputs.controller_(one|two|three|four).left_analog_y_raw|right_analog_y_raw)~
Returns the raw integer value for the analog's vertical movement (~-32,000 to +32,000~).
*** ~args.inputs.controller_(one|two|three|four).left_analog_x_perc|right_analog_x_perc)~
Returns a number between ~-1~ and ~1~ which represents the percentage the analog is moved horizontally as a ratio of the maximum horizontal movement.
*** ~args.inputs.controller_(one|two|three|four).left_analog_y_perc|right_analog_y_perc)~
Returns a number between ~-1~ and ~1~ which represents the percentage the analog is moved vertically as a ratio of the maximum vertical movement.
*** ~args.inputs.controller_(one|two|three|four).directional_up~
Returns ~true~ if ~up~ is pressed or held on the directional.
*** ~args.inputs.controller_(one|two|three|four).directional_down~
Returns ~true~ if ~down~ is pressed or held on the directional.
*** ~args.inputs.controller_(one|two|three|four).directional_left~
Returns ~true~ if ~left~ is pressed or held on the directional.
*** ~args.inputs.controller_(one|two|three|four).directional_right~
Returns ~true~ if ~right~ is pressed or held on the directional.
*** ~args.inputs.controller_(one|two|three|four).(a|b|x|y|l1|r1|l2|r2|l3|r3|start|select)~
Returns ~true~ if the specific button is pressed or held.
*** ~args.inputs.controller_(one|two|three|four).truthy_keys~
Returns a collection of ~Symbol~s that represent all keys that are in the pressed or held state.
*** ~args.inputs.controller_(one|two|three|four).key_down~
Returns ~true~ if the specific button was pressed on this frame. ~args.inputs.controller_(one|two|three|four).key_down.BUTTON~ will only be true on the frame it was pressed.
*** ~args.inputs.controller_(one|two|three|four).key_held~
Returns ~true~ if the specific button is being held. ~args.inputs.controller_(one|two|three|four).key_held.BUTTON~ will be true for all frames after ~key_down~ (until released).
*** ~args.inputs.controller_(one|two|three|four).key_up~
Returns ~true~ if the specific button was released. ~args.inputs.controller_(one|two|three|four).key_up.BUTTON~ will be true only on the frame the button was released.
** ~args.inputs.keyboard~
Represents the user's keyboard
*** ~args.inputs.keyboard.has_focus~
Returns ~true~ if the game has keyboard focus.
*** ~args.inputs.keyboard.up~
Returns ~true~ if ~up~ or ~w~ is pressed or held on the keyboard.
*** ~args.inputs.keyboard.down~
Returns ~true~ if ~down~ or ~s~ is pressed or held on the keyboard.
*** ~args.inputs.keyboard.left~
Returns ~true~ if ~left~ or ~a~ is pressed or held on the keyboard.
*** ~args.inputs.keyboard.right~
Returns ~true~ if ~right~ or ~d~ is pressed or held on the keyboard.
*** ~args.inputs.keyboard.left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.keyboard.left~ and ~args.inputs.keyboard.right~.
*** ~args.inputs.keyboard.up_down~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.keyboard.up~ and ~args.inputs.keyboard.up~.
*** keyboard properties
The following properties represent keys on the keyboard and are available on ~args.inputs.keyboard.KEY~, ~args.inputs.keyboard.key_down.KEY~, ~args.inputs.keyboard.key_held.KEY~, and ~args.inputs.keyboard.key_up.KEY~:
- ~alt~
- ~meta~
- ~control~
- ~shift~
- ~ctrl_KEY~ (dynamic method, eg ~args.inputs.keyboard.ctrl_a~)
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
- ~equal_sign~
- ~hyphen~
- ~space~
- ~dollar_sign~
- ~double_quotation_mark~
- ~single_quotation_mark~
- ~backtick~
- ~tilde~
- ~period~
- ~comma~
- ~pipe~
- ~underscore~
- ~a~ - ~z~
- ~shift~
- ~control~
- ~alt~
- ~meta~
- ~left~
- ~right~
- ~up~
- ~down~
- ~pageup~
- ~pagedown~
- ~char~
- ~plus~
- ~at~
- ~forward_slash~
- ~back_slash~
- ~asterisk~
- ~less_than~
- ~greater_than~
- ~carat~
- ~ampersand~
- ~superscript_two~
- ~circumflex~
- ~question_mark~
- ~section_sign~
- ~ordinal_indicator~
- ~raw_key~
- ~left_right~
- ~up_down~
- ~directional_vector~
- ~truthy_keys~
*** ~inputs.keyboard.keys~
Returns a ~Hash~ with all keys on the keyboard in their respective state. The ~Hash~ contains the following ~keys~
- ~:down~
- ~:held~
- ~:down_or_held~
- ~:up~
** ~args.inputs.touch~
Returns a ~Hash~ representing all touch points on a touch device. This api is only available in Indie, and Pro versions.
** ~args.inputs.finger_left~
Returns a ~Hash~ with ~x~ and ~y~ denoting a touch point that is on the left side of the screen. This api is only available in Indie, and Pro versions.
** ~args.inputs.finger_right~
Returns a ~Hash~ with ~x~ and ~y~ denoting a touch point that is on the right side of the screen. This api is only available in Indie, and Pro versions.
S
  end

  def docs_api_summary_outputs
    <<-S
* ~args.outputs~

Outputs is how you render primitives to the screen. The minimal setup for
rendering something to the screen is via a ~tick~ method defined in
mygame/app/main.rb

#+begin_src
  def tick args
    args.outputs.solids     << [0, 0, 100, 100]
    args.outputs.sprites    << [100, 100, 100, 100, "sprites/square/blue.png"]
    args.outputs.labels     << [200, 200, "Hello World"]
    args.outputs.lines      << [300, 300, 400, 400]
  end
#+end_src

Primitives are rendered first-in, first-out. The rendering order (sorted by bottom-most to top-most):

- ~solids~
- ~sprites~
- ~primitives~: Accepts all render primitives. Useful when you want to bypass the default rendering orders for rendering (eg. rendering solids on top of sprites).
- ~labels~
- ~lines~
- ~borders~
- ~debug~: Accepts all render primitives. Use this to render primitives for debugging (production builds of your game will not render this layer).

** ~args.outputs.background_color~
Set ~args.outputs.background_color~ to an ~Array~ with ~RGB~ values (eg. ~[255, 255, 255]~ for the color white).
** ~args.outputs.sounds~
Send a file path to this collection to play a sound. The sound file must be under the ~mygame~ directory. Example: ~args.outputs.sounds << "sounds/jump.wav"~.
** ~args.outputs.solids~
Send a Primitive to this collection to render a filled in rectangle to the screen. This collection is cleared at the end of every frame.
** ~args.outputs.static_solids~
Send a Primitive to this collection to render a filled in rectangle to the screen. This collection is not cleared at the end of every frame. And objects can be mutated by reference.
** ~args.outputs.sprites~, ~.static_sprites~
Send a Primitive to this collection to render a sprite to the screen.
** ~args.outputs.primitives~, ~.static_primitives~
Send a Primitive of any type and it'll be rendered. The Primitive must have a ~primitive_marker~ that returns ~:solid~, ~:sprite~, ~:label~, ~:line~, ~:border~.
** ~args.outputs.labels~, ~.static_labels~
Send a Primitive to this collection to render text to the screen.
** ~args.outputs.lines~, ~.static_lines~
Send a Primitive to this collection to render a line to the screen.
** ~args.outputs.borders~, ~.static_borders~
Send a Primitive to this collection to render an unfilled rectangle to the screen.
** ~args.outputs.debug~, ~.static_debug~
Send any Primitive to this collection which represents things you render to the screen for debugging purposes. Primitives in this collection will not be rendered in a production release of your game.
S
  end

  def docs_api_summary_geometry
    <<-S
* ~args.geometry~
This property contains geometric functions. Functions can be invoked via ~args.geometry.FUNCTION~.

Here are some general notes with regards to the arguments these geometric functions accept.

1. ~Rectangles~ can be represented as an ~Array~ with four (or more) values ~[x, y, w, h]~, as a ~Hash~ ~{ x:, y:, w:, h: }~ or an object that responds to ~x~, ~y~, ~w~, and ~h~.
2. ~Points~ can be represent as an ~Array~ with two (or more) values ~[x, y]~, as a ~Hash~ ~{ x:, y:}~ or an object that responds to ~x~, and ~y~.
3. ~Lines~ can be represented as an ~Array~ with four (or more) values ~[x, y, x2, y2]~, as a ~Hash~ ~{ x:, y:, x2:, y2: }~ or an object that responds to ~x~, ~y~, ~x2~, and ~y2~.
4. ~Angles~ are represented as degrees (not radians).

** ~args.geometry.inside_rect? rect_1, rect_2~
Returns ~true~ if ~rect_1~ is inside ~rect_2~.
** ~args.geometry.intersect_rect? rect_2, rect_2~
Returns ~true~ if ~rect_1~ intersects ~rect_2~.
** ~args.geometry.scale_rect rect, x_percentage, y_percentage~
Returns a new rectangle that is scaled by the percentages provided.
** ~args.geometry.angle_to start_point, end_point~
Returns the angle in degrees between two points ~start_point~ to ~end_point~.
** ~args.geometry.angle_from start_point, end_point~
Returns the angle in degrees between two points ~start_point~ from ~end_point~.
** ~args.geometry.point_inside_circle? point, circle_center_point, radius~
Returns ~true~ if a point is inside a circle defined by its center and radius.
** ~args.geometry.center_inside_rect rect, other_rect~
Returns a new rectangle based of off ~rect~ that is centered inside of ~other_rect~.
** ~args.geometry.center_inside_rect_x rect, other_rect~
Returns a new rectangle based of off ~rect~ that is centered horizontally inside of ~other_rect~.
** ~args.geometry.center_inside_rect_y rect, other_rect~
Returns a new rectangle based of off ~rect~ that is centered vertically inside of ~other_rect~.
** ~args.geometry.anchor_rect rect, anchor_x, anchor_y~
Returns a new rectangle based of off ~rect~ that has been repositioned based on the percentages passed into anchor_x, and anchor_y.
** ~args.geometry.shift_line line, x, y~
Returns a line that is offset by ~x~, and ~y~.
** ~args.geometry.line_y_intercept line~
Given a line, the ~b~ value is determined for the point slope form equation: ~y = mx + b~.
** ~args.geometry.angle_between_lines line_one, line_two, replace_infinity:~
Returns the angle between two lines as if they were infinitely long. A numeric value can be passed in for the last parameter which would represent lines that do not intersect.
** ~args.geometry.line_slope line, replace_infinity:~
Given a line, the ~m~ value is determined for the point slope form equation: ~y = mx + b~.
** ~args.geometry.line_rise_run~
Given a line, a ~Hash~ is returned that returns the slope as ~x~ and ~y~ properties with normalized values (the number is between -1 and 1).
** ~args.geometry.ray_test point, line~
Given a point and a line, ~:on~, ~:left~, or ~:right~ which represents the location of the point relative to the line.
** ~args.geometry.line_rect line~
Returns the bounding rectangle for a line.
** ~args.geometry.line_intersect line_one, line_two~
Returns a point that represents the intersection of the lines.
** ~args.geometry.distance point_one, point_two~
Returns the distance between two points.
** ~args.geometry.cubic_bezier t, a, b, c, d~
Returns the cubic bezier function for tick_count ~t~ with anchors ~a~, ~b~, ~c~, and ~d~.
S
  end

  def docs_api_summary_easing
    <<-S
* ~args.easing~
A set of functions that allow you to determine the current progression of an easing function.
** ~args.easing.ease start_tick, current_tick, duration, easing_functions~
Given a start, current, duration, and easing function names, ~ease~ returns a number between 0 and 1 that represents the progress of an easing function.

The built in easing definitions you have access to are ~:identity~, ~:flip~, ~:quad~, ~:cube~, ~:quart~, and ~:quint~.

This example will move a box at a linear speed from 0 to 1280.

#+begin_src ruby
  def tick args
    start_time = 10
    duration = 60
    current_progress = args.easing.ease start_time,
                                        args.state.tick_count,
                                        duration,
                                        :identity
    args.outputs.solids << { x: 1280 * current_progress, y: 360, w: 10, h: 10 }
  end
#+end_src
** ~args.easing.ease_spline start_tick, current_tick, duration, spline~
Given a start, current, duration, and a multiple bezier values, this function returns a number between 0 and 1 that represents the progress of an easing function.

This example will move a box at a linear speed from 0 to 1280 and then back to 0 using two bezier definitions (represented as an array with four values).

#+begin_src ruby
  def tick args
    start_time = 10
    duration = 60
    spline = [
      [  0, 0.25, 0.75, 1.0],
      [1.0, 0.75, 0.25,   0]
    ]
    current_progress = args.easing.ease_spline start_time,
                                               args.state.tick_count,
                                               duration,
                                               spline
    args.outputs.solids << { x: 1280 * current_progress, y: 360, w: 10, h: 10 }
  end
#+end_src
* ~args.string~
Useful string functions not included in Ruby core libraries.
** ~args.string.wrapped_lines string, max_character_length~
This function will return a collection of strings given an input
~string~ and ~max_character_length~. The collection of strings returned will split the
input string into strings of ~length <= max_character_length~.

The following example takes a string with new lines and creates a label for each one.
Labels (~args.outputs.labels~) ignore newline characters ~\\n~.

#+begin_src ruby
  def tick args
    long_string = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nInteger dolor velit, ultricies vitae libero vel, aliquam imperdiet enim."
    max_character_length = 30
    long_strings_split = args.string.wrapped_lines long_string, max_character_length
    args.outputs.labels << long_strings_split.map_with_index do |s, i|
      { x: 10, y: 600 - (i * 20), text: s }
    end
  end
#+end_src
S
  end

  def docs_api_summary_grid
    <<-S
* ~args.grid~
Returns the virtual grid for the game.
** ~args.grid.name~
Returns either ~:origin_bottom_left~ or ~:origin_center~.
** ~args.grid.bottom~
Returns the ~y~ value that represents the bottom of the grid.
** ~args.grid.top~
Returns the ~y~ value that represents the top of the grid.
** ~args.grid.left~
Returns the ~x~ value that represents the left of the grid.
** ~args.grid.right~
Returns the ~x~ value that represents the right of the grid.
** ~args.grid.rect~
Returns a rectangle Primitive that represents the grid.
** ~args.grid.origin_bottom_left!~
Change the grids coordinate system to 0, 0 at the bottom left corner.
** ~args.grid.origin_center!~
Change the grids coordinate system to 0, 0 at the center of the screen.
** ~args.grid.w~
Returns the grid's width (always 1280).
** ~args.grid.h~
Returns the grid's height (always 720).
S
  end

  def docs_api_summary_gtk
    <<-S
* ~args.gtk~
This represents the DragonRuby Game Toolkit's Runtime Environment and can be accessed via ~args.gtk.METHOD~.
** ~args.gtk.argv~
Returns a ~String~ that represents the parameters passed into the ~./dragonruby~ binary.
** ~args.gtk.platform~
Returns a ~String~ representing the operating system the game is running on.
** ~args.gtk.request_quit~
Request that the runtime quit the game.
** ~args.gtk.write_file path, contents~
Writes/overwrites a file within the game directory + path.
** ~args.gtk.write_file_root~
Writes/overwrites a file within the root dragonruby binary directory + path.
** ~args.gtk.append_file path, contents~
Append content to a file located at the game directory + path.
** ~args.gtk.append_file_root path, contents~
Append content to a file located at the root dragonruby binary directory + path.
** ~args.gtk.read_file path~
Reads a file from the sandboxed file system.
** ~args.gtk.parse_xml string, parse_xml_file path~
Returns a ~Hash~ for a ~String~ that represents XML.
** ~args.gtk.parse_json string, parse_json_file path~
Returns a ~Hash~ for a ~String~ that represents JSON.
** ~args.gtk.http_get url, extra_headers = {}~
Creates an async task to perform an HTTP GET.
** ~args.gtk.http_post url, form_fields = {}, extra_headers = {}~
Creates an async task to perform an HTTP POST.
** ~args.gtk.reset~
Resets the game by deleting all data in ~args.state~ and setting ~args.state.tick_count~ back to ~0~.
** ~args.gtk.stop_music~
Stops all background music.
** ~args.gtk.calcstringbox str, size_enum, font~
Returns a tuple with width and height of a string being rendered.
** ~args.gtk.calcspritebox path~
Returns a tuple with width and height of a sprite.
** ~args.gtk.reset_sprite path~
Invalidates the cache of a sprite that as already been rendered.
** ~args.gtk.slowmo! factor~
Slows the game down by the factor provided. ~args.gtk.slowmo! 60~ would mean that ~tick~ will be called once per second ~(fps = factor / 60)~.
** ~args.gtk.notify! string~
Renders a toast message at the bottom of the screen.
** ~args.gtk.system~
Invokes a shell command and prints the result to the console.
** ~args.gtk.exec~
Invokes a shell command and returns a ~String~ that represents the result.
** ~args.gtk.save_state~
Saves the game state to ~game_state.txt~.
** ~args.gtk.load_state~
Load ~args.state~ from ~game_state.txt~.
** ~args.gtk.serialize_state file, state~
Saves entity state to a file. If only one parameter is provided a string is returned for state instead of writing to a file.
** ~args.gtk.deserialize_state file~
Returns entity state from a file or serialization data represented as a ~String~.
** ~args.gtk.reset_sprite path~
Invalids the texture cache of a sprite.
** ~args.gtk.show_cursor~
Shows the mouse cursor.
** ~args.gtk.hide_cursor~
Hides the mouse cursor.
** ~args.gtk.set_cursor path, dx, dy~
Sets the system cursor to a sprite ~path~ with an offset of ~dx~ and ~dy~.
** ~args.gtk.cursor_shown?~
Returns ~true~ if the mouse cursor is shown.
** ~args.gtk.set_window_fullscreen enabled~
Sets the game to either fullscreen (~enabled=true~) or windowed (~enabled=false)~.
** ~args.gtk.openurl url~
Opens a url using the Operating System's default browser.
** ~args.gtk.get_base_dir~
Returns the full path of the DragonRuby binary directory.
** ~args.gtk.get_game_dir~
Returns the full path of the game directory in its sandboxed environment.
S
  end

  def docs_platform?
    <<-S
* DOCS: ~GTK::Runtime#platform?~
You can ask DragonRuby which platform your game is currently being run on. This can be
useful if you want to perform different pieces of logic based on where the game is running.

The raw platform string value is available via ~args.gtk.platform~ which takes in a ~symbol~
representing the platform's categorization/mapping.

You can see all available platform categorizations via the ~args.gtk.platform_mappings~ function.

Here's an example of how to use ~args.gtk.platform? category_symbol~:
#+begin_src ruby
  def tick args
    if    args.gtk.platform? :macos
      args.outputs.labels << { x: 640, y: 360, text: "I am running on MacOS.", alignment_enum: 1 }
    elsif args.gtk.platform? :win
      args.outputs.labels << { x: 640, y: 360, text: "I am running on Windows.", alignment_enum: 1 }
    elsif args.gtk.platform? :linux
      args.outputs.labels << { x: 640, y: 360, text: "I am running on Linux.", alignment_enum: 1 }
    elsif args.gtk.platform? :web
      args.outputs.labels << { x: 640, y: 360, text: "I am running on a web page.", alignment_enum: 1 }
    elsif args.gtk.platform? :android
      args.outputs.labels << { x: 640, y: 360, text: "I am running on Android.", alignment_enum: 1 }
    elsif args.gtk.platform? :ios
      args.outputs.labels << { x: 640, y: 360, text: "I am running on iOS.", alignment_enum: 1 }
    end
  end
#+end_src

These are the current platform categorizations (~args.gtk.platform_mappings~):
#+begin_src ruby
  {
    "Mac OS X"   => [:desktop, :macos, :osx, :mac, :macosx],
    "Windows"    => [:desktop, :windows, :win],
    "Linux"      => [:desktop, :linux, :nix],
    "Emscripten" => [:web,     :wasm, :html, :emscripten],
    "iOS"        => [:mobile,  :ios, ],
    "Android"    => [:mobile,  :android],
  }
#+end_src

Given the mappings above, ~args.gtk.platform? :desktop~ would return ~true~ if the game is running
on a player's computer irrespective of OS (MacOS, Linux, and Windows are all categorized
as ~:desktop~ platforms).
S
  end

  def docs_calcstringbox
    <<-S
* DOCS: ~GTK::Runtime#calcstringbox~
This function returns the width and height of a string.

#+begin_src ruby
  def tick args
    args.state.string_size           ||= args.gtk.calcstringbox "Hello World"
    args.state.string_size_font_size ||= args.gtk.calcstringbox "Hello World"
  end
#+end_src
S
  end

  def docs_write_file
    <<-S
* DOCS: ~GTK::Runtime#write_file~
This function takes in two parameters. The first parameter is the file path and assumes the the game
directory is the root. The second parameter is the string that will be written. The method overwrites whatever
is currently in the file. Use ~GTK::Runtime#append_file~ to append to the file as opposed to overwriting.

#+begin_src ruby
  def tick args
    if args.inputs.mouse.click
      args.gtk.write_file "last-mouse-click.txt", "Mouse was clicked at \#{args.state.tick_count}."
    end
  end
#+end_src
S
  end

      def docs_benchmark
<<-S
* DOCS: ~GTK::Runtime#benchmark~
You can use this function to compare the relative performance of methods.

#+begin_src ruby
  def tick args
    # press r to run benchmark
    if args.inputs.keyboard.key_down.r
      args.gtk.console.show
      args.gtk.benchmark iterations: 1000, # number of iterations
                         # label for experiment
                         using_numeric_map: -> () {
                           # experiment body
                           v = 100.map_with_index do |i|
                             i * 100
                           end
                         },
                         # label for experiment
                         using_numeric_times: -> () {
                           # experiment body
                           v = []
                           100.times do |i|
                             v << i * 100
                           end
                         }
    end
  end
#+end_src
S
      end

end

class GTK::Runtime
  extend Docs
  extend RuntimeDocs
end
