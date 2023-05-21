# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# runtime_docs.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright:
# Ketan Patel: https://github.com/cookieoverflow

module RuntimeDocs
  def docs_method_sort_order
    [
      :docs_indie_pro_functions,
      # indie/pro
      :docs_get_pixels,
      :docs_dlopen,

      # environment
      :docs_environment_functions,
      :docs_calcstringbox,

      :docs_request_quit,
      :docs_quit_requested?,
      :docs_set_window_fullscreen,
      :docs_window_fullscreen?,
      :docs_set_window_scale,

      :docs_platform?,
      :docs_production?,
      :docs_platform_mappings,
      :docs_open_url,
      :docs_system,
      :docs_exec,

      :docs_show_cursor,
      :docs_hide_cursor,
      :docs_cursor_shown?,

      :docs_set_mouse_grab,
      :docs_set_system_cursor,
      :docs_set_cursor,

      # file
      :docs_file_access_functions,
      :docs_list_files,
      :docs_stat_file,
      :docs_read_file,
      :docs_write_file,
      :docs_append_file,
      :docs_delete_file,
      :docs_delete_file_if_exist,

      # encodings
      :docs_encoding_functions,
      :docs_parse_json,
      :docs_parse_json_file,
      :docs_parse_xml,
      :docs_parse_xml_file,

      #network
      :docs_network_functions,
      :docs_http_get,
      :docs_http_post,
      :docs_http_post_body,
      :docs_start_server!,

      #dev support
      :docs_dev_support_functions,
      :docs_version,
      :docs_version_pro?,

      :docs_reset,
      :docs_reset_next_tick,
      :docs_reset_sprite,
      :docs_calcspritebox,

      :docs_current_framerate,
      :docs_framerate_diagnostics_primitives,
      :docs_warn_array_primitives!,
      :docs_benchmark,

      :docs_notify!,
      :docs_notify_extended!,
      :docs_slowmo!,

      :docs_show_console,
      :docs_hide_console,
      :docs_enable_console,
      :docs_disable_console,

      :docs_start_recording,
      :docs_stop_recording,
      :docs_cancel_recording,
      :docs_start_replay,
      :docs_stop_replay,

      :docs_get_base_dir,
      :docs_get_game_dir,
      :docs_get_game_dir_url,
      :docs_open_game_dir,

      :docs_write_file_root,
      :docs_append_file_root,

      :docs_argv,
      :docs_cli_arguments,

      :docs_reload_history,
      :docs_reload_history_pending,
      :docs_reload_if_needed,

      :docs_api_summary_state,
      :docs_api_summary_inputs,
      :docs_api_summary_outputs,
      :docs_api_summary_easing,
      :docs_api_summary_grid,
    ]
  end

  def docs_indie_pro_functions
    <<-S
** Indie and Pro Functions
The following functions are only available at the Indie and Pro License tiers.
S
  end

  def docs_class
    <<-S
* ~Runtime~
The ~GTK::Runtime~ class is the core of DragonRuby. It is globally
accessible via ~$gtk~ or inside of the ~tick~ method through ~args~.

#+begin_src
  def tick args
    args.gtk # accessible like this
    $gtk # or like this
  end
#+end_src
S
  end

  def docs_get_pixels
    <<-S
*** ~get_pixels~
Given a ~file_path~ to a sprite, this function returns a one dimensional
array of hexadecimal values representing the ARGB of each pixel in
a sprite.

See the following sample app for a full demonstration of how to use
this function: ~./samples/07_advanced_rendering/06_pixel_arrays_from_file~
S
  end

  def docs_dlopen
    <<-S
*** ~dlopen~
Loads a precompiled C Extension into your game.

See the sample apps at ~./samples/12_c_extensions~ for detailed
walkthroughs of creating C extensions.
S
  end

  def docs_environment_functions
    <<-S
** Environment and Utility Functions
The following functions will help in interacting with the OS and rendering pipeline.
S
  end

  def docs_calcstringbox
    <<-S
*** ~calcstringbox~
Returns the render width and render height as a tuple for a piece of text. The
parameters this method takes are:
- ~text~: the text you want to get the width and height of.
- ~size_enum~: number representing the render size for the text. This
  parameter is optional and defaults to ~0~ which represents a
  baseline font size in units specific to DragonRuby (a negative value
  denotes a size smaller than what would be comfortable to read on a
  handheld device postive values above ~0~ represent larger font sizes).
- ~font~: path to a font file that the width and height will be based
  off of. This field is optional and defaults to the DragonRuby's
  default font.

#+begin_src
  def tick args
    text = "a piece of text"
    size_enum = 5 # "large font size"

    # path is relative to your game directory (eg mygame/fonts/courier-new.ttf)
    font = "fonts/courier-new.ttf"

    # get the render width and height
    string_w, string_h = args.gtk.calcstringbox text, size_enum, font

    # render the label
    args.outputs.labels << {
      x: 100,
      y: 100,
      text: text,
      size_enum: size_enum,
      font: font
    }

    # render a border around the label based on the results from calcstringbox
    args.outputs.borders << {
      x: 100,
      y: 100,
      w: string_w,
      h: string_h,
      r: 0,
      g: 0,
      b: 0
    }
  end
#+end_src
S
  end

  def docs_request_quit
    <<-S
*** ~request_quit~
Call this function to exit your game. You will be given one additional tick
if you need to perform any housekeeping before that game closes.

#+begin_src
  def tick args
    # exit the game after 600 frames (10 seconds)
    if args.state.tick_count == 600
      args.gtk.request_quit
    end
  end
#+end_src
S
  end

  def docs_quit_requested?
    <<-S
*** ~quit_requested?~
This function will return ~true~ if the game is about to exit (either
from the user closing the game or if ~request_quit~ was invoked).
S
  end

  def docs_set_window_scale
    <<-S
*** ~set_window_scale~
This function takes in a float value and uses that to resize the game window
to a percentage of 1280x720 (or 720x1280 in portrait mode). The valid scale options
are 0.1, 0.25, 0.5, 0.75, 1.25, 1.5, 2.0, 2.5, 3.0, and 4.0. The float value you
pass in will be floored to the nearest valid scale option.
S
  end

  def docs_set_window_fullscreen
    <<-S
*** ~set_window_fullscreen~
This function takes in a single boolean parameter. ~true~ to make the
game fullscreen, ~false~ to return the game back to windowed mode.

#+begin_src
  def tick args
    # make the game full screen after 600 frames (10 seconds)
    if args.state.tick_count == 600
      args.gtk.set_window_fullscreen true
    end

    # return the game to windowed mode after 20 seconds
    if args.state.tick_count == 1200
      args.gtk.set_window_fullscreen false
    end
  end
#+end_src
S
  end

  def docs_window_fullscreen?
    <<-S
*** ~window_fullscreen?~
Returns true if the window is currently in fullscreen mode.
S
  end

  def docs_open_url
    <<-S
*** ~open_url~
Given a uri represented as a string. This fuction will open the uri in the user's default browser.

#+begin_src
  def tick args
    # open a url after 600 frames (10 seconds)
    if args.state.tick_count == 600
      args.gtk.open_url "http://dragonruby.org"
    end
  end
#+end_src
S
  end

  def docs_system
    <<-S
*** ~system~
Given an OS dependent cli command represented as a string, this
function executes the command and ~puts~ the results to the DragonRuby
Console (returns ~nil~).

#+begin_src
  def tick args
    # execute ls on the current directory in 10 seconds
    if args.state.tick_count == 600
      args.gtk.system "ls ."
    end
  end
#+end_src
S
  end

  def docs_exec
    <<-S
*** ~exec~
Given an OS dependent cli command represented as a string, this
function executes the command and returns a ~string~ representing the results.

#+begin_src
  def tick args
    # execute ls on the current directory in 10 seconds
    if args.state.tick_count == 600
      results = args.gtk.exec "ls ."
      puts "The results of the command are:"
      puts results
    end
  end
#+end_src
S
  end

  def docs_show_cursor
    <<-S
*** ~show_cursor~
Shows the mouse cursor.
S
  end

  def docs_hide_cursor
 <<-S
*** ~hide_cursor~
Hides the mouse cursor.
S
  end

  def docs_cursor_shown?
 <<-S
*** ~cursor_shown?~
Returns ~true~ if the mouse cursor is visible.
S
  end

  def docs_set_mouse_grab
    <<-S
*** ~set_mouse_grab~
Takes in a numeric parameter representing the mouse grab mode.
- ~0~: Ungrabs the mouse.
- ~1~: Grabs the mouse.
- ~2~: Hides the cursor, grabs the mouse and puts it in relative position mode accessible via ~args.inputs.mouse.relative_(x|y)~.
S
  end

  def docs_set_system_cursor
    <<-S
*** ~set_system_cursor~
Takes in a string value of ~"arrow"~, ~"ibeam"~, ~"wait"~, or ~"hand"~
and sets the mouse curosor to the corresponding system cursor (if available on the OS).
S
  end

  def docs_set_cursor
    <<-S
*** ~set_cursor~
Replaces the mouse cursor with a sprite. Takes in a ~path~ to the sprite, and optionally an ~x~ and ~y~ value
representing the realtive positioning the sprite will have to the mouse cursor.

#+begin_src
  def tick args
    if args.state.tick_count == 0
      # assumes a sprite of size 80x80 and centers the sprite
      # relative to the cursor position.
      args.gtk.set_cursor "sprites/square/blue.png", 40, 40
    end
  end
#+end_src
S
  end

  def docs_read_file
    <<-S
*** ~read_file~
Given a file path, a string will be returned representing the contents
of the file. ~nil~ will be returned if the file does not exist. You
can use ~stat_file~ to get additional information of a
file.
S
  end

  def docs_delete_file_if_exist
    <<-S
*** ~delete_file_if_exist~
Has the same behavior as ~delete_file~ except this
function does not throw an exception.
S
  end

  def docs_encoding_functions
    <<-S
** XML and JSON
The following functions help with parsing xml and json.
S
  end

  def docs_parse_json
    <<-S
*** ~parse_json~
Given a json string, this function returns a hash representing the
json data.

#+begin_src
hash = args.gtk.parse_json '{ "name": "John Doe", "aliases": ["JD"] }'
# structure of hash: { "name"=>"John Doe", "aliases"=>["JD"] }
#+end_src
S
  end

  def docs_parse_json_file
    <<-S
*** ~parse_json_file~
Same behavior as ~parse_json_file~ except a file path is
read for the json string.
S
  end

  def docs_parse_xml
    <<-S
*** ~parse_xml~
Given xml data as a string, this function will return a hash that
represents the xml data in the following recursive structure:

#+begin_src
{
  type: :element,
  name: "Person",
  children: [...],
  attributes: {...}
}
#+end_src
S
  end

  def docs_parse_xml_file
    <<-S
*** ~parse_xml_file~
Function has the same behavior as ~parse_xml~ except that
the parameter must be a file path that contains xml contents.
S
  end

  def docs_network_functions
    <<-S
** Network IO Functions
The following functions help with interacting with the network.
S
  end

  def docs_http_get
    <<-S
*** ~http_get~
Returns an object that represents an http response which will
eventually have a value. This http_get method is invoked
asynchronously. Check for completion before attempting to read results.

#+begin_src
  def tick args
    # perform an http get and print the response when available
    args.state.result ||= args.gtk.http_get "https://httpbin.org/html"

    if args.state.result && args.state.result[:complete] && !args.state.printed
      if args.state.result[:http_response_code] == 200
        puts "The response was successful. The body is:"
        puts args.state.result[:response_data]
      else
        puts "The response failed. Status code:"
        puts args.state.result[:http_response_code]
      end
      # set a flag denoting that the response has been printed
      args.state.printed = true

      # show the console
      args.gtk.show_console
    end
  end
#+end_src
S
  end

  def docs_http_post
    <<-S
*** ~http_post~
Returns an object that represents an http response which will
eventually have a value. This http_post method is invoked
asynchronously. Check for completion before attempting to read results.

- First parameter: The url to send the request to.
- Second parameter: Hash that represents form fields to send.
- Third parameter: Headers. Note: Content-Type must be form encoded
                   flavor. If you are unsure of what to pass in, set the content type
                   to application/x-www-form-urlencoded

#+begin_src
  def tick args
    # perform an http get and print the response when available

    args.state.form_fields ||= { "userId" => "\#{Time.now.to_i}" }
    args.state.result ||= args.gtk.http_post "http://httpbin.org/post",
                                             form_fields,
                                             ["Content-Type: application/x-www-form-urlencoded"]


    if args.state.result && args.state.result[:complete] && !args.state.printed
      if args.state.result[:http_response_code] == 200
        puts "The response was successful. The body is:"
        puts args.state.result[:response_data]
      else
        puts "The response failed. Status code:"
        puts args.state.result[:http_response_code]
      end
      # set a flag denoting that the response has been printed
      args.state.printed = true

      # show the console
      args.gtk.show_console
    end
  end
#+end_src
S
  end

  def docs_http_post_body
    <<-S
*** ~http_post_body~
Returns an object that represents an http response which will
eventually have a value. This http_post_body method is invoked
asynchronously. Check for completion before attempting to read results.

- First parameter: The url to send the request to.
- Second parameter: String that represents the body that will be sent
- Third parameter: Headers. Be sure to populate the Content-Type that
                   matches the data you are sending.

#+begin_src
  def tick args
    # perform an http get and print the response when available

    args.state.json ||= "{ \"userId\": \"\#{Time.now.to_i}\"}"
    args.state.result ||= args.gtk.http_post_body "http://httpbin.org/post",
                                                  args.state.json,
                                                  ["Content-Type: application/json", "Content-Length: \#{args.state.json.length}"]


    if args.state.result && args.state.result[:complete] && !args.state.printed
      if args.state.result[:http_response_code] == 200
        puts "The response was successful. The body is:"
        puts args.state.result[:response_data]
      else
        puts "The response failed. Status code:"
        puts args.state.result[:http_response_code]
      end
      # set a flag denoting that the response has been printed
      args.state.printed = true

      # show the console
      args.gtk.show_console
    end
  end
#+end_src
S
  end

  def docs_start_server!
    <<-S
*** ~start_server!~
Starts a in-game http server that can be process http requests. When
your game is running in development mode. A dev server is started at
~http://localhost:9001~

You can start an in-game http server in production via:

#+begin_src
  def tick args
    # server explicitly enabled in production
    args.gtk.start_server! port: 9001, enable_in_prod: true
  end
#+end_src

Here's how you would responde to http requests:

#+begin_src
  def tick args
    # server explicitly enabled in production
    args.gtk.start_server! port: 9001, enable_in_prod: true

    # loop through pending requests and respond to them
    args.inputs.http_requests.each do |request|
      puts "\#{request}"
      request.respond 200, "ok"
    end
  end
#+end_src
S
  end

  def docs_dev_support_functions
    <<-S
** Developer Support Functions
The following functions help support the development process. It is not recommended to use this functions in "production" game logic.
S
  end

  def docs_version
    <<-S
*** ~version~
Returns a string representing the version of DragonRuby you are running.
S
  end

  def docs_version_pro?
    <<-S
*** ~version_pro?~
Returns ~true~ if the version of DragonRuby is NOT Standard Edition.
S
  end

  def docs_reset
    <<-S
*** ~reset~
Resets DragonRuby's internal state as if it were just
started. ~args.state.tick_count~ is set to ~0~ and ~args.state~ is
cleared of any values. This function is helpful when you are
developing your game and want to reset everything as if the game just
booted up.

#+begin_src
  def tick args
  end

  # reset the game if this file is hotloaded/required
  # (removes the need to press "r" when I file is updated)
  $gtk.reset
#+end_src

NOTE: ~args.gtk.reset~ does not reset global variables or instance of
classes you have have constructed.
S
  end

  def docs_reset_next_tick
    <<-S
*** ~reset_next_tick~
Has the same behavior as ~reset~ except the reset occurs
before ~tick~ is executed again. ~reset~ resets the
environment immediately (while the ~tick~ method is inflight). It's
recommended that ~reset~ should be called outside of the tick method
(invoked when a file is saved/hotloaded), and ~reset_next_tick~ be
used inside of the ~tick~ method so you don't accidentally blow away state
the your game depends on to complete the current ~tick~ without exceptions.

#+begin_src
  def tick args
    # reset the game if "r" is pressed on the keyboard
    if args.inputs.keyboard.key_down.r
      args.gtk.reset_next_tick # use reset_next_tick instead of reset
    end
  end

  # reset the game if this file is hotloaded/required
  # (removes the need to press "r" when I file is updated)
  $gtk.reset
#+end_src
S
  end

  def docs_reset_sprite
    <<-S
*** ~reset_sprite~
Sprites when loaded are cached. This method invalidates the cache
record of a sprite so that updates on from the disk can be loaded.
S
  end

  def docs_calcspritebox
    <<-S
*** ~calcspritebox~
Given a path to a sprite, this method returns the ~width~ and ~height~ of a sprite as a tuple.

NOTE: This method should be used for development purposes only and is
      expensive to call every frame. Do not use this method to set the
      size of sprite when rendering (hard code those values since you
      know what they are beforehand).
S
  end

  def docs_current_framerate
    <<-S
*** ~current_framerate~
Returns a float value representing the framerate of your game. This is
an approximation/moving average of your framerate and should
eventually settle to 60fps.

#+begin_src
  def tick args
    # render a label to the screen that shows the current framerate
    # formatted as a floating point number with two decimal places
    args.outputs.labels << { x: 30, y: 30.from_top, text: "\#{args.gtk.current_framerate.to_sf}" }
  end
#+end_src
S
  end

  def docs_framerate_diagnostics_primitives
    <<-S
*** ~framerate_diagnostics_primitives~
Returns a set of primitives that can be rendered to the screen which
provide more detailed information about the speed of your simulation
(framerate, draw call count, mouse position, etc).

#+begin_src
  def tick args
    args.outputs.primitives << args.gtk.framerate_diagnostics_primitives
  end
#+end_src
S
  end

  def docs_warn_array_primitives!
    <<-S
*** ~warn_array_primitives!~
This function helps you audit your game of usages of array-based
primitives. While array-based primitives are simple to create and use,
they are slower to process than ~Hash~ or ~Class~ based primitives.

#+begin_src
  def tick args
    # enable array based primitives warnings
    args.gtk.warn_array_primitives!

    # array-based primitive elsewhere in code
    # an log message will be posted giving the location of the array
    # based primitive usage
    args.outputs.sprites << [100, 100, 200, 200, "sprites/square/blue.png"]

    # instead of using array based primitives, migrate to hashes as needed
    args.outputs.sprites << {
      x: 100,
      y: 100,
      w: 200,
      h: 200, path:
      "sprites/square/blue.png"
    }
  end
#+end_src
S
  end

  def docs_notify!
    <<-S
*** ~notify!~
Given a string, this function will present a message at the bottom of
your game. This method is only invoked in dev mode and is useful for debugging.

An optional parameter of duration (number value representing ticks)
can also be passed in. The default value if ~300~ ticks (5 seconds).

#+begin_src
  def tick args
    if args.inputs.mouse.click
      args.gtk.notify! "Mouse was clicked!"
    end

    if args.inputs.keyboard.key_down.r
      # optional duration parameter
      args.gtk.notify! "R key was pressed!", 600 # present message for 10 seconds/600 frames
    end
  end
#+end_src
S
  end

  def docs_notify_extended!
    <<-S
*** ~notify_extended!~
Has similar behavior as notify! except you have additional options to
show messages in a production environment.
#+begin_src
  def tick args
    if args.inputs.mouse.click
      args.gtk.notify_extended! message: "message",
                                duration: 300,
                                env: :prod
    end
  end
#+end_src
S
  end

  def docs_slowmo!
    <<-S
*** ~slowmo!~
Given a numeric value representing the factor of 60fps. This function
will bring your simulation loop down to slower rate. This method is
intended to be used for debugging purposes.

#+begin_src
  def tick args
    # set your simulation speed to (15 fps): args.gtk.slowmo! 4
    # set your simulation speed to (1 fps): args.gtk.slowmo! 60
    # set your simulation speed to (30 fps):
    args.gtk.slowmo! 2
  end
#+end_src

Remove this line from your tick method will automatically set your
simulation speed back to 60 fps.
S
  end

  def docs_show_console
    <<-S
*** ~show_console~
Shows the DragonRuby console. Useful when debugging/customizing an
in-game dev workflow.
S
  end

  def docs_hide_console
    <<-S
*** ~hide_console~
Shows the DragonRuby console. Useful when debugging/customizing an
in-game dev workflow.
S
  end

  def docs_enable_console
    <<-S
*** ~enable_console~
Enables the DragonRuby Console so that it can be presented by pressing
the tilde key (the key next to the number 1 key).
S
  end

  def docs_disable_console
    <<-S
*** ~disable_console~
Disables the DragonRuby Console so that it won't show up even if you
press the tilde key or call ~args.gtk.show_console~.
S
  end

  def docs_start_recording
    <<-S
*** ~start_recording~
Resets the game to tick ~0~ and starts recording gameplay. Useful for
visual regression tests/verification.
S
  end

  def docs_stop_recording
    <<-S
*** ~stop_recording~
Function takes in a destination file for the currently recording
gameplay. This file can be used to replay a recording.
S
  end

  def docs_cancel_recording
    <<-S
*** ~cancel_recording~
Function cancels a gameplay recording session and discards the replay.
S
  end

  def docs_start_replay
    <<-S
*** ~start_replay~
Given a file that represents a recording, this method will run the
recording against the current codebase.

You can start a replay from the command line also:

#+begin_src
# first argument: the game directory
# --replay switch is the file path relative to the game directory
# --speed switch is optional. a value of 4 will run the replay and game at 4x speed
# cli command example is in the context of Linux and Mac, for Windows the binary would be ./dragonruby.exe
./dragonruby ./mygame --replay ./replay.txt --speed 4
#+end_src
S
  end

  def docs_stop_replay
    <<-S
*** ~stop_replay~
Function stops a replay that is currently executing.
S
  end

  def docs_get_base_dir
    <<-S
*** ~get_base_dir~
Returns the path to the location of the dragonruby binary. In
production mode, this value will be the same as the value returned by
~get_game_dir~. Function should only be used for
debugging/development workflows.
S
  end

  def docs_get_game_dir
    <<-S
*** ~get_game_dir~
Returns the location within sandbox storage that the game is
running. When developing your game, this value will be your ~mygame~
directory. In production, it'll return a value that is OS specific (eg
the Roaming directory on Windows or the Application Support directory
on Mac).

Invocations of ~(write|append)_file will write to this
sandboxed directory.
S
  end

  def docs_get_game_dir_url
    <<-S
*** ~get_game_dir_url~
Returns a url encoded string representing the sandbox location for
game data.
S
  end

  def docs_open_game_dir
    <<-S
*** ~open_game_dir~
Opens the game directory in the OS's file explorer. This should be
used for debugging purposes only.
S
  end

  def docs_write_file_root
    <<-S
*** ~write_file_root~
Given a file path and contents, the contents will be written to a
directory outside of the game directory. This method should be used
for development purposes only. In production this method will write to
the same sandboxed location as ~write_file~.
S
  end

  def docs_append_file_root
    <<-S
*** ~append_file_root~
Has the same behavior as ~write_file_root~ except that it
appends the contents as opposed to overwriting them.
S
  end

  def docs_argv
    <<-S
*** ~argv~
Returns a string representing the command line arguments passed to the
DragonRuby binary. This should be used for development/debugging purposes only.
S
  end

  def docs_cli_arguments
    <<-S
*** ~cli_arguments~
Returns a ~Hash~ for command line arguments in the format of ~--switch value~
(two hyphens preceding the switch flag with the value seperated by a
space). This should be used for development/debugging purposes only.
S
  end

  def docs_reload_history
    <<-S
*** ~reload_history~
Returns a ~Hash~ representing the code files that have be loaded for
your game along with timings for the events. This should be used for
development/debugging purposes only.
S
  end

  def docs_reload_history_pending
    <<-S
*** ~reload_history_pending~
Returns a ~Hash~ for files that have been queued for reload, but
haven't been processed yet. This should be used for
development/debugging purposes only.
S
  end

  def docs_reload_if_needed
    <<-S
*** ~reload_if_needed~
Given a file name, this function will queue the file for reload if
it's been modified. An optional second parameter can be passed in to
signify if the file should be forced loaded regardless of modified
time (~true~ means to force load, ~false~ means to load only if the
file has been modified). This function should be used for
development/debugging purposes only.
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
#+begin_src ruby
  args.state.player[:x] += args.inputs.left_right * args.state.speed
#+end_src
** ~args.inputs.up_down~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up) depending on results of ~args.inputs.down~ and ~args.inputs.up~.
#+begin_src ruby
  args.state.player[:y] += args.inputs.up_down * args.state.speed
#+end_src
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
*** ~args.inputs.mouse.wheel.x~
Returns the negative or positive number if the mouse wheel has changed in the ~x~ axis.
*** ~args.inputs.mouse.wheel.y~
Returns the negative or positive number if the mouse wheel has changed in the ~y~ axis.
*** ~args.inputs.mouse.click~ OR ~.down~, ~.previous_click~, ~.up~
The properties ~args.inputs.mouse.(click|down|previous_click|up)~ each return ~nil~ if the mouse button event didn't occur. And return an Entity
that has an ~x~, ~y~ properties along with helper functions to determine collision: ~inside_rect?~, ~inside_circle~.
** ~args.inputs.controller_(one-four)~
Represents controllers connected to the usb ports.
*** ~args.inputs.controller_(one-four).up~
Returns ~true~ if ~up~ is pressed or held on the directional or left analog.
*** ~args.inputs.controller_(one-four).down~
Returns ~true~ if ~down~ is pressed or held on the directional or left analog.
*** ~args.inputs.controller_(one-four).left~
Returns ~true~ if ~left~ is pressed or held on the directional or left analog.
*** ~args.inputs.controller_(one-four).right~
Returns ~true~ if ~right~ is pressed or held on the directional or left analog.
*** ~args.inputs.controller_(one-four).left_right~
Returns ~-1~ (left), ~0~ (neutral), or ~+1~ (right) depending on results of ~args.inputs.controller_(one-four).left~ and ~args.inputs.controller_(one-four).right~.
*** ~args.inputs.controller_(one-four).up_down~
Returns ~-1~ (down), ~0~ (neutral), or ~+1~ (up) depending on results of ~args.inputs.controller_(one-four).up~ and ~args.inputs.controller_(one-four).down~.
*** ~args.inputs.controller_(one-four).(left_analog_x_raw|right_analog_x_raw)~
Returns the raw integer value for the analog's horizontal movement (~-32,000 to +32,000~).
*** ~args.inputs.controller_(one-four).left_analog_y_raw|right_analog_y_raw)~
Returns the raw integer value for the analog's vertical movement (~-32,000 to +32,000~).
*** ~args.inputs.controller_(one-four).left_analog_x_perc|right_analog_x_perc)~
Returns a number between ~-1~ and ~1~ which represents the percentage the analog is moved horizontally as a ratio of the maximum horizontal movement.
*** ~args.inputs.controller_(one-four).left_analog_y_perc|right_analog_y_perc)~
Returns a number between ~-1~ and ~1~ which represents the percentage the analog is moved vertically as a ratio of the maximum vertical movement.
*** ~args.inputs.controller_(one-four).directional_up~
Returns ~true~ if ~up~ is pressed or held on the directional.
*** ~args.inputs.controller_(one-four).directional_down~
Returns ~true~ if ~down~ is pressed or held on the directional.
*** ~args.inputs.controller_(one-four).directional_left~
Returns ~true~ if ~left~ is pressed or held on the directional.
*** ~args.inputs.controller_(one-four).directional_right~
Returns ~true~ if ~right~ is pressed or held on the directional.
*** ~args.inputs.controller_(one-four).(a|b|x|y|l1|r1|l2|r2|l3|r3|start|select)~
Returns ~true~ if the specific button is pressed or held.
*** ~args.inputs.controller_(one-four).truthy_keys~
Returns a collection of ~Symbol~s that represent all keys that are in the pressed or held state.
*** ~args.inputs.controller_(one-four).key_down~
Returns ~true~ if the specific button was pressed on this frame. ~args.inputs.controller_(one-four).key_down.BUTTON~ will only be true on the frame it was pressed.
*** ~args.inputs.controller_(one-four).key_held~
Returns ~true~ if the specific button is being held. ~args.inputs.controller_(one-four).key_held.BUTTON~ will be true for all frames after ~key_down~ (until released).
*** ~args.inputs.controller_(one-four).key_up~
Returns ~true~ if the specific button was released. ~args.inputs.controller_(one-four).key_up.BUTTON~ will be true only on the frame the button was released.
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
Send a file path to this collection to play a sound. The sound file must be under the ~mygame~ directory.
#+begin_src ruby
  args.outputs.sounds << "sounds/jump.wav"
#+end_src
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

  def docs_production?
    <<-S
*** ~production?~
Returns true if the game is being run in a released/shipped state.
S
  end

  def docs_platform?
    <<-S
*** ~platform?~
You can ask DragonRuby which platform your game is currently being run on. This can be
useful if you want to perform different pieces of logic based on where the game is running.

The raw platform string value is available via ~args.gtk.platform~ which takes in a ~symbol~
representing the platform's categorization/mapping.

You can see all available platform categorizations via the ~args.gtk.platform_mappings~ function.

Here's an example of how to use ~args.gtk.platform? category_symbol~:
#+begin_src ruby
  def tick args
    if    args.gtk.platform? :macos
      args.outputs.labels << { x: 640, y: 360,
                               text: "I am running on MacOS.", alignment_enum: 1 }
    elsif args.gtk.platform? :win
      args.outputs.labels << { x: 640, y: 360,
                               text: "I am running on Windows.", alignment_enum: 1 }
    elsif args.gtk.platform? :linux
      args.outputs.labels << { x: 640, y: 360,
                               text: "I am running on Linux.", alignment_enum: 1 }
    elsif args.gtk.platform? :web
      args.outputs.labels << { x: 640, y: 360,
                               text: "I am running on a web page.", alignment_enum: 1 }
    elsif args.gtk.platform? :android
      args.outputs.labels << { x: 640, y: 360,
                               text: "I am running on Android.", alignment_enum: 1 }
    elsif args.gtk.platform? :ios
      args.outputs.labels << { x: 640, y: 360,
                               text: "I am running on iOS.", alignment_enum: 1 }
    end
  end
#+end_src
S
  end

  def docs_platform_mappings
    <<-S
*** ~platform_mappings~
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


  def docs_stat_file
    <<-S
*** ~stat_file~
This function takes in one parameter. The parameter is the file path and assumes the the game
directory is the root. The method returns ~nil~ if the file doesn't exist otherwise it returns
a ~Hash~ with the following information:

#+begin_src ruby
  # {
  #   path: String,
  #   file_size: Int,
  #   mod_time: Int,
  #   create_time: Int,
  #   access_time: Int,
  #   readonly: Boolean,
  #   file_type: Symbol (:regular, :directory, :symlink, :other),
  # }

  def tick args
    if args.inputs.mouse.click
      args.gtk.write_file "last-mouse-click.txt", "Mouse was clicked at \#{args.state.tick_count}."
    end

    file_info = args.gtk.stat_file "last-mouse-click.txt"

    if file_info
      args.outputs.labels << {
        x: 30,
        y: 30.from_top,
        text: file_info.to_s,
        size_enum: -3
      }
    else
      args.outputs.labels << {
        x: 30,
        y: 30.from_top,
        text: "file does not exist, click to create file",
        size_enum: -3
      }
    end
  end
#+end_src
S
  end

  def docs_file_access_functions
    <<-S
** File IO Functions
The following functions give you the ability to interact with the file system.
S
  end

  def docs_list_files
    <<-S
*** ~list_files~
This function takes in one parameter. The parameter is the directory path and assumes the the game
directory is the root. The method returns an ~Array~ of ~String~ representing all files
within the directory. Use ~stat_file~ to determine whether a specific path is a file
or a directory.
S
  end

  def docs_write_file
    <<-S
*** ~write_file~
This function takes in two parameters. The first parameter is the file path and assumes the the game
directory is the root. The second parameter is the string that will be written. The method **overwrites**
whatever is currently in the file. Use ~append_file~ to append to the file as opposed to overwriting.

#+begin_src ruby
  def tick args
    if args.inputs.mouse.click
      args.gtk.write_file "last-mouse-click.txt", "Mouse was clicked at \#{args.state.tick_count}."
    end
  end
#+end_src
S
  end

  def docs_append_file
    <<-S
*** ~append_file~
This function takes in two parameters. The first parameter is the file path and assumes the the game
directory is the root. The second parameter is the string that will be written. The method appends to
whatever is currently in the file (a new file is created if one does not alread exist). Use
~write_file~ to overwrite the file's contents as opposed to appending.

#+begin_src ruby
  def tick args
    if args.inputs.mouse.click
      args.gtk.write_file "last-mouse-click.txt", "Mouse was clicked at \#{args.state.tick_count}."
    end
  end
#+end_src
S
  end

  def docs_delete_file
    <<-S
*** ~delete_file~
This function takes in a single parameters. The parameter is the file path that should be deleted. This
function will raise an exception if the path requesting to be deleted does not exist.

Notes:

- Use ~delete_if_exist~ to only delete the file if it exists.
- Use ~stat_file~ to determine if a path exists.
- Use ~list_files~ to determine if a directory is empty.
- You cannot delete files outside of your sandboxed game environment.

Here is a list of reasons an exception could be raised:

  - If the path is not found.
  - If the path is still open (for reading or writing).
  - If the path is not a file or directory.
  - If the path is a circular symlink.
  - If you do not have permissions to delete the path.
  - If the directory attempting to be deleted is not empty.

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
*** ~benchmark~
You can use this function to compare the relative performance of blocks of code.

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
