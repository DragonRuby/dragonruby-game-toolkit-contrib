# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# runtime_docs.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# Ketan Patel: https://github.com/cookieoverflow

module RuntimeDocs
  def docs_method_sort_order
    [
      :docs_api_summary,
      :docs_reset,
      :docs_calcstringbox,
      :docs_write_file
    ]
  end

  def docs_class
    <<-S
* DOCS: ~GTK::Runtime~
The GTK::Runtime class is the core of DragonRuby. It is globally accessible via ~$gtk~.
S
  end

  def docs_api_summary
    <<-S
* SUMMARY: ~def tick args; end;~
Most everything you will need to build your game is in the ~args~ parameter that is provided to your ~tick~ method. Follows is a high level summary of each function that is available from ~args~.

All the properties below hang off of ~args~ and can be accessed in the ~tick~ method:
#+begin_src
  def tick args
    args.PROPERTY
  end
#+end_src
** ~args.state~
Store your game state inside of this ~state~. Properties with arbitrary nesting is allowed and a backing Entity will be created on your behalf.
#+begin_src
  def tick args
    args.state.player.x ||= 0
    args.state.player.y ||= 0
  end
#+end_src
*** ~.*.entity_id~
Entities automatically receive an ~entity_id~ of type ~Fixnum~.
*** ~.*.entity_type~
Entities can have an ~entity_type~ which is represented as a ~Symbol~.
*** ~.*.created_at~
Entities have ~created_at~ set to ~args.state.tick_count~ when they are created.
*** ~.*.created_at_elapsed~
Returns the elapsed number of ticks since creation.
*** ~.*.global_created_at~
Entities have ~global_created_at~ set to ~Kernel.global_tick_count~ when they are created.
*** ~.*.global_created_at_elapsed~
Returns the elapsed number of global ticks since creation.
*** ~.*.as_hash~
Entity cast to a ~Hash~ so you can update values as if you were updating a ~Hash~.
*** ~.new_entity~
Creates a new Entity with a ~type~, and initial properties. An option block can be passed to change the newly created entity:
#+begin_src ruby
  def tick args
    args.state.player ||= args.state.new_entity :player, x: 0, y: 0 do |e|
      e.max_hp = 100
      e.hp     = e.max_hp * rand
    end
  end
#+end_src
*** ~.new_entity_strict~
Creates a new Strict Entity. While Entities created via ~args.state.new_entity~ can have new properties added later on, Entities created
using ~args.state.new_entity~ must define all properties that are allowed during its initialization. Attempting to add new properties after
initialization will result in an exception.
*** ~.tick_count~
Returns the current tick of the game. ~args.state.tick_count~ is ~0~ when the game is first started or if the game is reset via ~$gtk.reset~.
** ~args.inputs~
Access using input using ~args.inputs~.
*** ~.up~
Returns ~true~ if: the ~up~ arrow or ~w~ key is pressed or held on the ~keyboard~; or if ~up~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted upwards.
*** ~.down~
Returns ~true~ if: the ~down~ arrow or ~s~ key is pressed or held on the ~keyboard~; or if ~down~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted downwards.
*** ~.left~
Returns ~true~ if: the ~left~ arrow or ~a~ key is pressed or held on the ~keyboard~; or if ~left~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted to the left.
*** ~.right~
Returns ~true~ if: the ~right~ arrow or ~d~ key is pressed or held on the ~keyboard~; or if ~right~ is pressed or held on ~controller_one~; or if the ~left_analog~ on ~controller_one~ is tilted to the right.
*** ~.left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.left~ and ~args.inputs.right~.
*** ~.up_down~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up) depending on results of ~args.inputs.down~ and ~args.inputs.up~.
*** ~.text~ OR ~.history~
Returns a string that represents the last key that was pressed on the keyboard.
*** ~.mouse~
Represents the user's
**** ~.x~
Returns the current ~x~ location of the mouse.
**** ~mouse.y~
Return.
**** ~.inside_rect? rect~
Return. ~args.inputs.mouse.inside_rect?~ takes in any primitive that responds to ~x, y, w, h~:
**** ~.inside_circle? center_point, radius~
Returns ~true~ if the mouse is inside of a specified circle. ~args.inputs.mouse.inside_circle?~ takes in any primitive that responds to ~x, y~ (which represents the circle's center), and takes in a ~radius~:
**** ~.moved~
Returns ~true~ if the mouse has moved on the current frame.
**** ~.button_left~
Returns ~true~ if the left mouse button is down.
**** ~.button_middle~
Returns ~true~ if the middle mouse button is down.
**** ~.button_right~
Returns ~true~ if the right mouse button is down.
**** ~.button_bits~
Returns a bitmask for all buttons on the mouse: ~1~ for a button in the ~down~ state, ~0~ for a button in the ~up~ state.
**** ~mouse.wheel~
Represents the mouse wheel. Returns ~nil~ if no mouse wheel actions occurred.
***** ~.x~
Returns the negative or positive number if the mouse wheel has changed in the ~x~ axis.
***** ~.y~
Returns the negative or positive number if the mouse wheel has changed in the ~y~ axis.
**** ~.click~ OR ~.down~, ~.previous_click~, ~.up~
The properties ~args.inputs.mouse.(click|down|previous_click|up)~ each return ~nil~ if the mouse button event didn't occur. And return an Entity
that has an ~x~, ~y~ properties along with helper functions to determine collision: ~inside_rect?~, ~inside_circle~.
*** ~.controller_one~, ~.controller_two~
Represents controllers connected to the usb ports.
**** ~.up
Returns ~true~ if ~up~ is pressed or held on the directional or left analog.
**** ~.down
Returns ~true~ if ~down~ is pressed or held on the directional or left analog.
**** ~.left
Returns ~true~ if ~left~ is pressed or held on the directional or left analog.
**** ~.right
Returns ~true~ if ~right~ is pressed or held on the directional or left analog.
**** ~.left_right
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.controller_(one|two).left~ and ~args.inputs.controller_(one|two).right~.
**** ~.up_down
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up) depending on results of ~args.inputs.controller_(one|two).down~ and ~args.inputs.controller_(one|two).up~.
**** ~.(left_analog_x_raw|right_analog_x_raw)~
Returns the raw integer value for the analog's horizontal movement (~-32,000 to +32,000~).
**** ~.left_analog_y_raw|right_analog_y_raw)~
Returns the raw integer value for the analog's vertical movement (~-32,000 to +32,000~).
**** ~.left_analog_x_perc|right_analog_x_perc)~
Returns a number between ~-1~ and ~1~ which represents the percentage the analog is moved horizontally as a ratio of the maximum horizontal movement.
**** ~.left_analog_y_perc|right_analog_y_perc)~
Returns a number between ~-1~ and ~1~ which represents the percentage the analog is moved vertically as a ratio of the maximum vertical movement.
**** ~.directional_up)~
Returns ~true~ if ~up~ is pressed or held on the directional.
**** ~.directional_down)~
Returns ~true~ if ~down~ is pressed or held on the directional.
**** ~.directional_left)~
Returns ~true~ if ~left~ is pressed or held on the directional.
**** ~.directional_right)~
Returns ~true~ if ~right~ is pressed or held on the directional.
**** ~.(a|b|x|y|l1|r1|l2|r2|l3|r3|start|select)~
Returns ~true~ if the specific button is pressed or held.
**** ~.truthy_keys~
Returns a collection of ~Symbol~s that represent all keys that are in the pressed or held state.
**** ~.key_down~
Returns ~true~ if the specific button was pressed on this frame. ~args.inputs.controller_(one|two).key_down.BUTTON~ will only be true on the frame it was pressed.
**** ~.key_held~
Returns ~true~ if the specific button is being held. ~args.inputs.controller_(one|two).key_held.BUTTON~ will be true for all frames after ~key_down~ (until released).
**** ~.key_up~
Returns ~true~ if the specific button was released. ~args.inputs.controller_(one|two).key_up.BUTTON~ will be true only on the frame the button was released.
*** ~.keyboard~
Represents the user's keyboard
**** ~.up~
Returns ~true~ if ~up~ or ~w~ is pressed or held on the keyboard.
**** ~.down~
Returns ~true~ if ~down~ or ~s~ is pressed or held on the keyboard.
**** ~.left~
Returns ~true~ if ~left~ or ~a~ is pressed or held on the keyboard.
**** ~.right~
Returns ~true~ if ~right~ or ~d~ is pressed or held on the keyboard.
**** ~.left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.keyboard.left~ and ~args.inputs.keyboard.right~.
**** ~.up_down~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up) depending on results of ~args.inputs.keyboard.down~ and ~args.inputs.keyboard.up~.
**** keyboard properties
The following properties represent keys on the keyboard and are available on ~args.inputs.keyboard.KEY~, ~args.inputs.keyboard.key_down.KEY~, ~args.inputs.keyboard.key_held.KEY~, and ~args.inputs.keyboard.key_up.KEY~:
- ~alt~
- ~meta~
- ~control~
- ~shift~
- ~ctrl_KEY~ (dynamic method, eg ~args.inputs.keyboard.ctrl_a~)
- ~exclamation_point~
- ~zero~
- ~one~
- ~two~
- ~three~
- ~four~
- ~five~
- ~six~
- ~seven~
- ~eight~
- ~nine~
- ~backspace~
- ~delete~
- ~escape~
- ~enter~
- ~tab~
- ~open_round_brace~
- ~close_round_brace~
- ~open_curly_brace~
- ~close_curly_brace~
- ~open_square_brace~
- ~close_square_brace~
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
- ~a~
- ~b~
- ~c~
- ~d~
- ~e~
- ~f~
- ~g~
- ~h~
- ~i~
- ~j~
- ~k~
- ~l~
- ~m~
- ~n~
- ~o~
- ~p~
- ~q~
- ~r~
- ~s~
- ~t~
- ~u~
- ~v~
- ~w~
- ~x~
- ~y~
- ~z~
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
- ~raw_key~
- ~left_right~
- ~up_down~
- ~directional_vector~
- ~truthy_keys~
**** ~inputs.keyboard.keys~
Returns a ~Hash~ with all keys on the keyboard in their respective state. The ~Hash~ contains the following ~keys~
- ~:down~
- ~:held~
- ~:down_or_held~
- ~:up~
** ~args.outputs~
~args.outputs.PROPERTY~ is how you render to the screen.
*** ~.background_color~
Set ~args.outputs.background_color~ to an ~Array~ with ~RGB~ values (eg. ~[255, 255, 255]~ for the color white).
*** ~.sounds~
Send a file path to this collection to play a sound. The sound file must be under the ~mygame~ directory. Example: ~args.outputs.sounds << "sounds/jump.wav"~.
*** ~.solids~
Send a Primitive to this collection to render a filled in rectangle to the screen. This collection is cleared at the end of every frame.
*** ~.static_solids~
Send a Primitive to this collection to render a filled in rectangle to the screen. This collection is not cleared at the end of every frame. And objects can be mutated by reference.
*** ~.sprites~, ~.static_sprites~
Send a Primitive to this collection to render a sprite to the screen.
*** ~.primitives~, ~.static_primitives~
Send a Primitive of any type and it'll be rendered. The Primitive must have a ~primitive_marker~ that returns ~:solid~, ~:sprite~, ~:label~, ~:line~, ~:border~.
*** ~.labels~, ~.static_labels~
Send a Primitive to this collection to render text to the screen.
*** ~.lines~, ~.static_lines~
Send a Primitive to this collection to render a line to the screen.
*** ~.borders~, ~.static_borders~
Send a Primitive to this collection to render an unfilled rectangle to the screen.
*** ~.debug~, ~.static_debug~
Send any Primitive to this collection which represents things you render to the screen for debugging purposes. Primitives in this collection will not be rendered in a production release of your game.
** ~args.geometry~
This property contains geometric functions. Functions can be invoked via ~args.geometry.FUNCTION~.
*** ~.inside_rect? rect_1, rect_2~
Returns ~true~ if ~rect_1~ is inside ~rect_2~.
*** ~.intersect_rect? rect_2, rect_2~
Returns ~true~ if ~rect_1~ intersects ~rect_2~.
*** ~.scale_rect rect, x_percentage, y_percentage~
Returns a new rectangle that is scaled by the percentages provided.
*** ~.angle_to start_point, end_point~
Returns the angle in degrees between two points ~start_point~ to ~end_point~.
*** ~.angle_from start_point, end_point~
Returns the angle in degrees between two points ~start_point~ from ~end_point~.
*** ~.point_inside_circle? point, circle_center_point, radius~
Returns ~true~ if a point is inside a circle defined by its center and radius.
*** ~.center_inside_rect rect, other_rect~
Returns a new rectangle based of off ~rect~ that is centered inside of ~other_rect~.
*** ~.center_inside_rect_x rect, other_rect~
Returns a new rectangle based of off ~rect~ that is centered horizontally inside of ~other_rect~.
*** ~.center_inside_rect_y rect, other_rect~
Returns a new rectangle based of off ~rect~ that is centered vertically inside of ~other_rect~.
*** ~.anchor_rect rect, anchor_x, anchor_y~
Returns a new rectangle based of off ~rect~ that has been repositioned based on the percentages passed into anchor_x, and anchor_y.
*** ~.shift_line line, x, y~
Returns a line that is offset by ~x~, and ~y~.
*** ~.line_y_intercept line~
Given a line, the ~b~ value is determined for the point slope form equation: ~y = mx + b~.
*** ~.angle_between_lines line_one, line_two, replace_infinity:~
Returns the angle between two lines as if they were infinitely long. A numeric value can be passed in for the last parameter which would represent lines that do not intersect.
*** ~.line_slope line, replace_infinity:~
Given a line, the ~m~ value is determined for the point slope form equation: ~y = mx + b~.
*** ~.line_rise_run~
Given a line, a ~Hash~ is returned that returns the slope as ~x~ and ~y~ properties with normalized values (the number is between -1 and 1).
*** ~.ray_test point, line~
Given a point and a line, ~:on~, ~:left~, or ~:right~ which represents the location of the point relative to the line.
*** ~.line_rect line~
Returns the bounding rectangle for a line.
*** ~.line_intersect line_one, line_two~
Returns a point that represents the intersection of the lines.
*** ~.distance point_one, point_two~
Returns the distance between two points.
*** ~.cubic_bezier t, a, b, c, d~
Returns the cubic bezier function for tick_count ~t~ with anchors ~a~, ~b~, ~c~, and ~d~.
** ~args.easing~
A set of functions that allow you to determine the current progression of an easing function.
*** ~.ease start_tick, current_tick, duration, easing_functions~
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
*** ~.ease_spline start_tick, current_tick, duration, spline~
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
** ~args.string~
Useful string functions not included in Ruby core libraries.
*** ~.wrapped_lines string, max_character_length~
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
** ~args.grid~
Returns the virtual grid for the game.
*** ~.name~
Returns either ~:origin_bottom_left~ or ~:origin_center~.
*** ~.bottom~
Returns the ~y~ value that represents the bottom of the grid.
*** ~.top~
Returns the ~y~ value that represents the top of the grid.
*** ~.left~
Returns the ~x~ value that represents the left of the grid.
*** ~.right~
Returns the ~x~ value that represents the right of the grid.
*** ~.rect~
Returns a rectangle Primitive that represents the grid.
*** ~.origin_bottom_left!~
Change the grids coordinate system to 0, 0 at the bottom left corner.
*** ~.origin_center!~
Change the grids coordinate system to 0, 0 at the center of the screen.
*** ~.w~
Returns the grid's width (always 1280).
*** ~.h~
Returns the grid's height (always 720).
** ~args.gtk~
This represents the DragonRuby Game Toolkit's Runtime Environment and can be accessed via ~args.gtk.METHOD~.
*** ~.argv~
Returns a ~String~ that represents the parameters passed into the ~./dragonruby~ binary.
*** ~.platform~
Returns a ~String~ representing the operating system the game is running on.
*** ~.request_quit~
Request that the runtime quit the game.
*** ~.write_file path, contents~
Writes/overwrites a file within the game directory + path.
*** ~.write_file_root~
Writes/overwrites a file within the root dragonruby binary directory + path.
*** ~.append_file path, contents~
Append content to a file located at the game directory + path.
*** ~.append_file_root path, contents~
Append content to a file located at the root dragonruby binary directory + path.
*** ~.read_file path~
Reads a file from the sandboxed file system.
*** ~.parse_xml string, parse_xml_file path~
Returns a ~Hash~ for a ~String~ that represents XML.
*** ~.parse_json string, parse_json_file path~
Returns a ~Hash~ for a ~String~ that represents JSON.
*** ~.http_get url, extra_headers = {}~
Creates an async task to perform an HTTP GET.
*** ~.http_post url, form_fields = {}, extra_headers = {}~
Creates an async task to perform an HTTP POST.
*** ~.reset~
Resets the game by deleting all data in ~args.state~ and setting ~args.state.tick_count~ back to ~0~.
*** ~.stop_music~
Stops all background music.
*** ~.calcstringbox str, size_enum, font~
Returns a tuple with width and height of a string being rendered.
*** ~.slowmo! factor~
Slows the game down by the factor provided.
*** ~.notify! string~
Renders a toast message at the bottom of the screen.
*** ~.system~
Invokes a shell command and prints the result to the console.
*** ~.exec~
Invokes a shell command and returns a ~String~ that represents the result.
*** ~.save_state~
Saves the game state to ~game_state.txt~.
*** ~.load_state~
Load ~args.state~ from ~game_state.txt~.
*** ~.serialize_state file, state~
Saves entity state to a file. If only one parameter is provided a string is returned for state instead of writing to a file.
*** ~.deserialize_state file~
Returns entity state from a file or serialization data represented as a ~String~.
*** ~.reset_sprite path~
Invalids the texture cache of a sprite.
*** ~.show_cursor~
Shows the mouse cursor.
*** ~.hide_cursor~
Hides the mouse cursor.
*** ~.cursor_shown?~
Returns ~true~ if the mouse cursor is shown.
*** ~.set_window_fullscreen enabled~
Sets the game to either fullscreen (~enabled=true~) or windowed (~enabled=false)~.
*** ~.openurl url~
Opens a url using the Operating System's default browser.
*** ~.get_base_dir~
Returns the full path of the DragonRuby binary directory.
*** ~.get_game_dir~
Returns the full path of the game directory in its sandboxed environment.
S

  end



  def docs_reset
    <<-S
* DOCS: ~GTK::Runtime#reset~
This function will reset Kernel.tick_count to 0 and will remove all data from args.state.
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
end

class GTK::Runtime
  extend Docs
  extend RuntimeDocs
end
