# Runtime (`GTK`)

The `GTK::Runtime` class is the core of DragonRuby.

?> All functions `$gtk`, `GTK`, via `args.gtk` (it's recommended to use `GTK`).
```ruby
def tick args
  # recommended access to GTK
  GTK.function(...)
end
```

## Top Level Functions

DragonRuby is aware of the following top level functions (top level functions are functions defined outside of a class or a module).

### `tick`

This is the main entry point for your game and will be called at 60 fps.

```ruby
def tick args
  args.outputs.labels << {
    x: 640,
    y: 360,
    text: "current tick count is: #{Kernel.tick_count}"
  }
end
```

### `boot`

This function will be called once when your game boots. It will never be called again after that initial startup.

```ruby
def boot args
  puts "The current tick count is: #{Kernel.tick_count}"
  puts "The global tick count is: #{Kernel.global_tick_count}"
end
```

### `reset`

This function will be called if `GTK.reset` is invoked. It will be called before DragonRuby resets game state and
is useful for capturing state information before a reset occurs (you can use this override to reset state external
to DragonRuby's `args.state` construct).

```ruby
# class that handles your game loop
class MyGame
  attr :foo
  
  # initialization method that sets member variables
  # external to args.state
  def initialize args
    puts "initializing game"
    @foo = 0
    args.state.bar ||= 0
  end

  # game logic
  def tick args
    args.state.bar += 1
    @foo += 1
    args.outputs.labels << {
      x: 640,
      y: 360,
      text: "#{$game.foo}, #{args.state.bar}"
    }
  end
end

def tick args
  # initialize global game variable if it's nil
  $game ||= MyGame.new(args)
  
  # run tick
  $game.tick args
  
  # at T=600, invoke reset
  if Kernel.tick_count == 600
    GTK.reset
  end
end

# this function will be invoked before
# GTK.reset occurs
def reset args
  puts "resetting"
  puts "foo is: #{$game.foo}"
  puts "bar is: #{args.state.bar}"
  puts "tick count: #{Kernel.tick_count}"
  
  # reset global game to nil so that it will be re-initialized next tick
  $game = nil
end
```

### `reboot`

Invoking `GTK.reboot` will reset your game as if it were started for the first time. Any
methods that were added to classes during hotload will be removed (leaving you with a pristine
environment). This function is in a beta state (report issues on the Discord Server).

### `shutdown`

This function will be called before your game exits.

```ruby
def shutdown args
  puts "Shutting down at #{Kernel.tick_count}"
end
```

## Class Macros

The following class macros are available within DragonRuby.

### `attr`

The `attr` class macro is an alias to `attr_accessor`.

Instead of:

```ruby
class Player
  attr_accessor :hp, :armor
end
```

You can do:

```ruby
class Player
  attr :hp, :armor
end
```

### `attr_gtk`

As the size/complexity of your game increases. You may want to create classes to organize everything. The `attr_gtk` class macro adds DragonRuby's environment methods (such as `args.state`, `args.inputs`, `args.outputs`, `args.audio`, etc) to your class so you don't have to pass `args` around everywhere.

Instead of:

```ruby
class Game
  def tick args
    defaults args
    calc args
    render args
  end

  def defaults args
    args.state.space_pressed_at ||= 0
  end

  def calc args
    if args.inputs.keyboard.key_down.space
      args.state.space_pressed_at = Kernel.tick_count
    end
  end

  def render args
    if args.state.space_pressed_at == 0
      args.outputs.labels << { x: 100, y: 100,
                               text: "press space" }
    else
      args.outputs.labels << { x: 100, y: 100,
                               text: "space was pressed at: #{args.state.space_pressed_at}" }
    end
  end
end

def tick args
  $game ||= Game.new
  $game.tick args
end
```

You can do:

```ruby
class Game
  attr_gtk # attr_gtk class macro

  def tick
    defaults
    calc
    render
  end

  def defaults
    state.space_pressed_at ||= 0
  end

  def calc
    if inputs.keyboard.key_down.space
      state.space_pressed_at = Kernel.tick_count
    end
  end

  def render
    if state.space_pressed_at == 0
      outputs.labels << { x: 100, y: 100,
                          text: "press space" }
    else
      outputs.labels << { x: 100, y: 100,
                          text: "space was pressed at: #{state.space_pressed_at}" }
    end
  end
end

def tick args
  $game ||= Game.new
  $game.args = args # set args property on game
  $game.tick        # call tick without passing in args
end

$game = nil
```

## Indie and Pro Functions

The following functions are only available at the Indie and Pro License tiers.

### `dlopen`

Loads a precompiled C Extension into your game given the `name` of the library (without the `lib` prefix or platform sepcific file extension).

See the sample apps at `./samples/12_c_extensions` for detailed walkthroughs of creating C extensions.

?> All license tiers can load C Extensions in dev mode. The Standard
license **does not include the dependencies required to create C
Extensions however**.<br/><br/> During the publishing process, any C Extension
directories will be ignored during packaging and an exception will be
thrown if `dlopen` is called in Production (for Standard license
only).<br/><br/> This gives Standard license users the ability to load/try out C
Extensions in development mode. An [Indie or Pro license](https://dragonruby.org#purchase) is required to
compile C Extensions/publish games that have C Extensions. 

### `get_dlopen_path`

Returns the path that will be searched for dynamic libraries when using `dlopen`. You can optionally pass in a `String` representing the library name to get the full path to the library.

## Window Functions

### `window_fullscreen?`

Returns `true` if the window is currently in fullscreen mode.

### `can_resize_window?`

Returns `true` if the window can be resized on the platform the game
is running on. This is useful for conditionally showing a "Toggle
Fullscreen" option in your game.

### `set_window_fullscreen`

This function takes in a single `boolean` parameter. `true` to make the game fullscreen, `false` to return the game back to windowed mode.

```ruby
def tick args
  # make the game full screen after 600 frames (10 seconds)
  if Kernel.tick_count == 600
    GTK.set_window_fullscreen true
  end

  # return the game to windowed mode after 20 seconds
  if Kernel.tick_count == 1200
    GTK.set_window_fullscreen false
  end
end
```

### `toggle_window_fullscreen`

Toggles the fullscreen state of the window.

### `set_window_size`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

Takes in two parameters representing the width and height of the window. The window will be resized to the specified dimensions.

```ruby
# setting window size to 720p
GTK.set_window_size 1280, 720

# setting window size to 1080p
GTK.set_window_size 1920, 1080

# setting window to a non-standard 16:9 aspect ratio
# for letterbox/allscreen testing purposes
GTK.set_window_size 720, 720
```

### `set_window_position`

!> This function should only be used for debugging/development
purposes and is not guaranteed to work cross platform. Do not use as a
in-game feature in production. 

Takes in two parameters representing the `x` and `y` destination position (the
`x`, `y` values assumes that the origin is top left... to reiterate,
only use this function for development/debugging purposes).

```ruby
GTK.set_window_position 0, 0
```

### `set_window_scale`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

The first parameter is a float value used to resize the game
window to a percentage of 1280x720 (or 720x1280 in portrait mode). The
valid scale options are 0.1, 0.25, 0.5, 0.75, 1.25, 1.5, 2.0, 2.5,
3.0, and 4.0. The float value you pass in will be floored to the
nearest valid scale option.

The second and third parameters are optional and default to `16` and
`9` (representing with width and height aspect ratios for the
window). Providing these parameters will resize the window with the 
non-standard aspect ratio. This is useful for testing letter-boxing
and All Screen modes (Pro feature).

Setting the window scale to the following will give a good
representation of your game on various form factors.

```ruby
# how your game will look on an iPad
GTK.set_window_scale 1.0, 4, 3

# how your game will look on a wide aspect ratio
GTK.set_window_scale 1.0, 21, 9
```

### `set_window_title`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

This function takes in a string updates the title of the game in the Menu Bar.

Note: The default title for your game is specified in via the `gametitle` property in `mygame/metadata/game_metadata.txt`.

### `can_close_window?`

Returns `true` if quitting is allowed on the platform you are releasing to (eg: iOS and Web games do not allow exiting).

### `move_window_to_next_display`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

If you have multiple monitors, this function can be used to move the
game to the next monitor. The function will cycle back to the first
monitor if needed. 

```ruby
def boot args
  if !GTK.production?
    GTK.move_window_to_next_display
  end
end

def tick args
  if args.inputs.keyboard.key_down.zero && !GTK.production?
    GTK.move_window_to_next_display
  end
end
```

### `maximize_window`

If `can_resize_window?` returns `true`, this functions will maximize the game window.

### `can_change_orientation?`

Returns `true` if the game's orientation can be altered while the game is running.

### `toggle_orientation`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

If `can_change_orientation?` returns `true`, the orientation of the
game will be changed from landscape to portrait (or portrait to
landscape) while the game is running. This function is useful for
testing rendering of games that support both portrait and landscape orientations.

### `set_orientation`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

Function accepts `:landscape`, or `:portrait` as the first
parameter and sets the game's orientation while the game is running.

### `set_hd_max_scale`

?> The ability to set your game's HD Max Scale is available to Pro license holders (the function no-ops otherwise).

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

Function accepts on of the following `Integer` values:

- `100`: 720p (1280x720)
- `125`: HD+ (1600x900)
- `150`: 1080p/Full HD (1920x1080)
- `175`: Full HD+ (2240x1260)
- `200`: 1440p (2560x1440)
- `250`: 1800p (3200x1800)
- `300`: 4k (3840x2160)
- `400`: 5k (6400x2880)

Updates the `hd_max_scale` metadata value for your game while it's
running. This is useful for testing the scaling of your game on edge
to edge displays.

### `toggle_hd_letterbox`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

Adds or removes the letterbox within your game while it's
running. This is useful for testing how your game renders on edge to 
edge displays.

### `set_hd_letterbox`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

?> `toggle_hd_letterbox` and `set_hd_letterbox` correlates to the
`hd_letterbox` configuration value in =metadata/game_metadata.txt=
(which allows you to render outside of the 16:9 safe area). 

?> The ability to remove the letterbox for you game is available to Pro
license holders (these functions no-ops otherwise).

Function requires one `Boolean` parameter (`true` or `false`). The
letter boxing for your game will be added or removed while the game is
running. 

### `raise_window`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

Function when invoked will bring the game window to the very front and give it focus (does nothing in production mode).

## Environment and Utility Functions

The following functions will help in interacting with the OS and render/execution pipeline.

### `on_tick_count`

Given a tick_count and a block, this function will schedule the block to be executed at the beginning of the frame provided.

```ruby
def tick args
  # if space is pressed, show a notification 5 seconds (300 frames) later
  if args.inputs.keyboard.key_down.space
    GTK.notify "Scheduling block to be executed... (tick_count: #{Kernel.tick_count})"
    # schedule a block to be executed (with an optional
    # argument being the args at that point in time)
    GTK.on_tick_count Kernel.tick_count + 300 do |args_300|
      GTK.notify "Block executed! (tick_count: #{Kernel.tick_count})"
      # within the execution of this block, schedule another execution
      GTK.on_tick_count Kernel.tick_count + 300 do
        GTK.notify "Nested block executed! (tick_count: #{Kernel.tick_count})"
      end
    end
  end
end
```

### `calcstringbox`

Returns the render width and render height as a tuple for a piece of text. The parameters this method takes are:

-   `text`: the text you want to get the width and height of.
-   `size_enum`: number representing the render size for the text. This parameter is optional and defaults to `0` which represents a baseline font size in units specific to DragonRuby (a negative value denotes a size smaller than what would be comfortable to read on a handheld device positive values above `0` represent larger font sizes).
-   `font`: path to a font file that the width and height will be based off of. This field is optional and defaults to the DragonRuby's default font.

```ruby
def tick args
  text = "a piece of text"
  size_enum = 5 # "large font size"

  # path is relative to your game directory (eg mygame/fonts/courier-new.ttf)
  font = "fonts/courier-new.ttf"

  # get the render width and height
  string_w, string_h = GTK.calcstringbox text, size_enum, font

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
```

`calcstringbox` also supports named parameters for `size_enum` and `size_px`.

```ruby
  # size_enum, and font named parameters
  string_w, string_h = GTK.calcstringbox text, size_enum: 0, font: "fonts/example.ttf"
  
  # size_px, and font named parameters
  string_w, string_h = GTK.calcstringbox text, size_px: 20, font: "fonts/example.ttf"
```

### `calcstringbox_h`

Performs the same function as `calcstringbox`, but returns a `Hash` with keys `w`, and `h`.

### `get_string_rect`

Performs the same function as `calcstringbox`, but returns a `Hash` with keys `x` (always `0`), `y` (always `0`), `w`, `h`, and `center` (`Hash` with `x`, `y`).

### `get_pixels`

Given a `file_path` to a sprite, this function returns a `Hash` with
`w`, `h`, and `pixels`. The `pixels` key contains an array of
hexadecimal values representing the ABGR of each pixel in a sprite
with item `0` representing the top left corner of the `png`.

Here's an example of how to get the color data for a pixel:

```ruby
def tick args
  # load the pixels from the image
  args.state.image ||= GTK.get_pixels "sprites/square/blue.png"

  # initialize state variables for the pixel coordinates
  args.state.x_px ||= 0
  args.state.y_px ||= 0

  sprite_pixels = args.state.image.pixels
  sprite_h = args.state.image.h
  sprite_w = args.state.image.w

  # move the pixel coordinates using keyboard
  args.state.x_px += args.inputs.left_right
  args.state.y_px += args.inputs.up_down

  # get pixel at the current coordinates
  args.state.x_px = args.state.x_px.clamp(0, sprite_w - 1)
  args.state.y_px = args.state.y_px.clamp(0, sprite_h - 1)
  row = sprite_h - args.state.y_px - 1
  col = args.state.x_px
  abgr = sprite_pixels[sprite_h * row + col]
  a = (abgr >> 24) & 0xff
  b = (abgr >> 16) & 0xff
  g = (abgr >> 8) & 0xff
  r = (abgr >> 0) & 0xff

  # render debug information
  args.outputs.debug << "row: #{row} col: #{col}"
  args.outputs.debug << "pixel entry 0: rgba #{r} #{g} #{b} #{a}"

  # render the sprite plus crosshairs
  args.outputs.sprites << { x: 0, y: 0, w: 80, h: 80, path: "sprites/square/blue.png" }
  args.outputs.lines << { x: args.state.x_px, y: 0, h: 720 }
  args.outputs.lines << { x: 0, y: args.state.y_px, w: 1280 }
end
```

See the following sample apps for how to use pixel arrays:

-   `./samples/07_advanced_rendering/06_pixel_arrays`
-   `./samples/07_advanced_rendering/06_pixel_arrays_from_file`

### `request_quit`

Call this function to exit your game. You will be given one additional tick if you need to perform any housekeeping before that game closes.

```ruby
def tick args
  # exit the game after 600 frames (10 seconds)
  if Kernel.tick_count == 600
    GTK.request_quit
  end
end
```

### `quit_requested?`

This function will return `true` if the game is about to exit (either from the user closing the game or if `request_quit` was invoked).

### `platform?`

You can ask DragonRuby which platform your game is currently being run on. This can be useful if you want to perform different pieces of logic based on where the game is running.

The raw platform string value is available via `GTK.platform` which takes in a `symbol` representing the platform's categorization/mapping.

You can see all available platform categorizations via the `GTK.platform_mappings` function.

Here's an example of how to use `GTK.platform? category_symbol`:

```ruby
def tick args
  label_style = { x: 640, y: 360, anchor_x: 0.5, anchor_y: 0.5 }
  if    GTK.platform? :macos
    args.outputs.labels << { text: "I am running on MacOS.", **label_style }
  elsif GTK.platform? :win
    args.outputs.labels << { text: "I am running on Windows.", **label_style }
  elsif GTK.platform? :linux
    args.outputs.labels << { text: "I am running on Linux.", **label_style }
  elsif GTK.platform? :web
    args.outputs.labels << { text: "I am running on a web page.", **label_style }
  elsif GTK.platform? :android
    args.outputs.labels << { text: "I am running on Android.", **label_style }
  elsif GTK.platform? :ios
    args.outputs.labels << { text: "I am running on iOS.", **label_style }
  elsif GTK.platform? :touch
    args.outputs.labels << { text: "I am running on a device that supports touch (either iOS/Android native or mobile web).", **label_style }
  elsif GTK.platform? :steam
    args.outputs.labels << { text: "I am running via steam (covers both desktop and steamdeck).", **label_style }
  elsif GTK.platform? :steam_deck
    args.outputs.labels << { text: "I am running via steam on the Steam Deck (not steam desktop).", **label_style }
  elsif GTK.platform? :steam_desktop
    args.outputs.labels << { text: "I am running via steam on desktop (not steam deck).", **label_style }
  end
end
```

### `production?`

Returns true if the game is being run in a released/shipped state.

If you want to simulate a production build. Add an empty file called `dragonruby_production_build` inside of the `metadata` folder. This will turn of all logging and all creation of temp files used for development purposes.

### `platform_mappings`

These are the current platform categorizations (`GTK.platform_mappings`):

```ruby
{
  "Mac OS X"   => [:desktop, :macos, :osx, :mac, :macosx], # may also include :steam and :steam_desktop run via steam
  "Windows"    => [:desktop, :windows, :win],              # may also include :steam and :steam_desktop run via steam
  "Linux"      => [:desktop, :linux, :nix],                # may also include :steam and :steam_desktop run via steam
  "Emscripten" => [:web, :wasm, :html, :emscripten],       # may also include :touch if running in the web browser on mobile
  "iOS"        => [:mobile, :ios, :touch],
  "Android"    => [:mobile, :android, :touch],
  "Steam Deck" => [:steamdeck, :steam_deck, :steam],
}
```

Given the mappings above, `GTK.platform? :desktop` would return `true` if the game is running on a player's computer irrespective of OS (MacOS, Linux, and Windows are all categorized as `:desktop` platforms).

### `openurl`

Given a uri represented as a string. This function will open the uri in the user's default browser.

```ruby
def tick args
  # open a url after 600 frames (10 seconds)
  if Kernel.tick_count == 600
    GTK.openurl "http://dragonruby.org"
  end
end
```

### `system`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

Given an OS dependent cli command represented as a string, this function executes the command and `puts` the results to the DragonRuby Console (returns `nil`).

```ruby
def tick args
  # execute ls on the current directory in 10 seconds
  if Kernel.tick_count == 600
    GTK.system "ls ."
  end
end
```

### `exec`

!> This function should only be used for debugging/development purposes and is not guaranteed to work cross platform. Do not use as a in-game feature in production.

Given an OS dependent cli command represented as a string, this function executes the command and returns a `string` representing the results.

```ruby
def tick args
  # execute ls on the current directory in 10 seconds
  if Kernel.tick_count == 600
    results = GTK.exec "ls ."
    puts "The results of the command are:"
    puts results
  end
end
```

### `show_cursor`

Shows the mouse cursor.

### `hide_cursor`

Hides the mouse cursor.

### `cursor_shown?`

Returns `true` if the mouse cursor is visible.

### `set_mouse_grab`

Takes in a numeric parameter representing the mouse grab mode.

-   `0`: Ungrabs the mouse.
-   `1`: Grabs the mouse.
-   `2`: Hides the cursor, grabs the mouse and puts it in relative position mode accessible via `args.inputs.mouse.relative_(x|y)`.

### `set_system_cursor`

Takes in a string value of `"arrow"`, `"ibeam"`, `"wait"`, or `"hand"` and sets the mouse cursor to the corresponding system cursor (if available on the OS).

### `set_cursor`

Replaces the mouse cursor with a sprite. Takes in a `path` to the sprite, and optionally an `x` and `y` value representing the relative positioning the sprite will have to the mouse cursor.

```ruby
def tick args
  if Kernel.tick_count == 0
    # assumes a sprite of size 80x80 and centers the sprite
    # relative to the cursor position.
    GTK.set_cursor "sprites/square/blue.png", 40, 40
  end
end
```

### `create_uuid`

Returns a `UUID`/`GUID` as a `String` value. The UUID uses `srand` and is not cryptographically secure.

### `getenv`

Given a `String`, this function will return the value of the environment variable represented as a `String`. `nil` will be returned if the environment variable does not exist.

### `setenv`

Function sets an environment variable. The function takes in three parameters:

- `String` representing the environment variable `name`.
- `String` representing the `value`.
- `Boolean` representing whether the environment variable should `overwrite` if it already exists.

## File IO Functions

!> File access functions are sandboxed and assume that the
`dragonruby` binary lives alongside the game you are building. **Do not
expect these functions to return correct values if you are attempting
to run the `dragonruby` binary from a shared location**. It's **strongly**
recommended that the directory structure contained in the zip is not
altered and games are built using that starter template. 

The following functions give you the ability to interact with the file system.

DragonRuby uses a sandboxed filesystem which will automatically read from and write to a location appropriate for your platform so you don't have to worry about theses details in your code. You can just use `GTK.read_file`, `GTK.write_file`, and `GTK.append_file` with a relative path and the engine will take care of the rest.

The data directories that will be written to in a production build are:
- Windows: `C:\Users\YourWindowsUsername\AppData\Roaming\[devtitle]\[gametitle]`
- MacOS: `$HOME/Library/Application Support/[gametitle]`
- Linux: `$HOME/.local/share/[gametitle]`
- HTML5: The data will be written to the browser's IndexedDB.

The values in square brackets are the values you set in your `app/metadata/game_metadata.txt` file.

When reading files, the engine will first look in the game's data directory and then in the game directory itself. This means that if you write a file to the data directory that already exists in your game directory, the file in the data directory will be used instead of the one that is in your game.

When running a development build you will directly write to your game directory (and thus overwrite existing files). This can be useful for built-in development tools like level editors.

For more details on the implementation of the sandboxed filesystem, see Ryan C. Gordon's PhysicsFS documentation: [https://icculus.org/physfs/](https://icculus.org/physfs/)

### `list_files`

This function takes in one parameter. The parameter is the directory path and assumes the the game directory is the root. The method returns an `Array` of `String` representing all files within the directory. Use `stat_file` to determine whether a specific path is a file or a directory.

### `stat_file`

This function takes in one parameter. The parameter is the file path and assumes the the game directory is the root. The method returns `nil` if the file doesn't exist otherwise it returns a `Hash` with the following information:

```ruby
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
    GTK.write_file "last-mouse-click.txt", "Mouse was clicked at #{Kernel.tick_count}."
  end

  file_info = GTK.stat_file "last-mouse-click.txt"

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
```

### `read_file`

Given a file path, a string will be returned representing the contents of the file. `nil` will be returned if the file does not exist. You can use `stat_file` to get additional information of a file.

### `write_file`

This function takes in two parameters. The first parameter is the file path and assumes the the game directory is the root. The second parameter is the string that will be written. The method ****overwrites**** whatever is currently in the file. Use `append_file` to append to the file as opposed to overwriting.

```ruby
def tick args
  if args.inputs.mouse.click
    GTK.write_file "last-mouse-click.txt", "Mouse was clicked at #{Kernel.tick_count}."
  end
end
```

### `append_file`

This function takes in two parameters. The first parameter is the file path and assumes the the game directory is the root. The second parameter is the string that will be written. The method appends to whatever is currently in the file (a new file is created if one does not already exist). Use `write_file` to overwrite the file's contents as opposed to appending.

```ruby
def tick args
  if args.inputs.mouse.click
    GTK.append_file "click-history.txt", "Mouse was clicked at #{Kernel.tick_count}.\n"
    puts GTK.read_file("click-history.txt")
  end
end
```

### `delete_file`

This function takes in a single parameters. The parameter is the file or directory path that should be deleted. This function will raise an exception if the path requesting to be deleted does not exist.

Here is a list of reasons an exception could be raised:

-   If the path is still open (for reading or writing).
-   If the path is not a file or directory.
-   If the path is a circular symlink.
-   If you do not have permissions to delete the path.
-   If the directory attempting to be deleted is not empty.

Notes:

-   Use `stat_file` to determine if a path exists.
-   Use `list_files` to determine if a directory is empty.
-   You cannot delete files outside of your sandboxed game environment.

```ruby
def tick args
  if args.inputs.keyboard.key_down.w
    # press w to write file
    GTK.append_file "example-file.txt", "File written at #{Kernel.tick_count}\n"
    GTK.notify "File written/appended."
  elsif args.inputs.keyboard.key_down.d
    # press d to delete file "unsafely"
    GTK.delete_file "example-file.txt"
    GTK.notify "File deleted."
  elsif args.inputs.keyboard.key_down.r
    # press r to read file
    contents = GTK.read_file "example-file.txt"
    GTK.notify "File contents written to console."
    puts contents
  end
end
```

## XML and JSON

The following functions help with parsing xml and json.

### `parse_json`

Given a json string, this function returns a hash representing the json data.

```
hash = GTK.parse_json '{ "name": "John Doe", "aliases": ["JD"] }'
# structure of hash: { "name"=>"John Doe", "aliases"=>["JD"] }
```

### `parse_json_file`

Same behavior as `parse_json` except a file path is read for the json string.

### `parse_xml`

Given xml data as a string, this function will return a hash that represents the xml data in the following recursive structure:

```ruby
{
  type: :element,
  name: "Person",
  children: [...]
}
```

### `parse_xml_file`

Function has the same behavior as `parse_xml` except that the parameter must be a file path that contains xml contents.

## Network IO Functions

The following functions help with interacting with the network.

### `http_get`

Returns an object that represents an http response which will eventually have a value. This `http_get` method is invoked asynchronously. Check for completion before attempting to read results.

```ruby
def tick args
  # perform an http get and print the response when available
  args.state.result ||= GTK.http_get "https://httpbin.org/html"

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
    GTK.show_console
  end
end
```

### `http_post`

Returns an object that represents an http response which will eventually have a value. This `http_post` method is invoked asynchronously. Check for completion before attempting to read results.

-   First parameter: The url to send the request to.
-   Second parameter: Hash that represents form fields to send.
-   Third parameter: Headers. Note: Content-Type must be form encoded flavor. If you are unsure of what to pass in, set the content type to application/x-www-form-urlencoded

```ruby
def tick args
  # perform an http get and print the response when available

  args.state.form_fields ||= { "userId" => "#{Time.now.to_i}" }
  args.state.result ||= GTK.http_post "http://httpbin.org/post",
                                           args.state.form_fields,
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
    GTK.show_console
  end
end
```

### `http_post_body`

Returns an object that represents an http response which will eventually have a value. This `http_post_body` method is invoked asynchronously. Check for completion before attempting to read results.

-   First parameter: The url to send the request to.
-   Second parameter: String that represents the body that will be sent
-   Third parameter: Headers. Be sure to populate the Content-Type that matches the data you are sending.

```ruby
def tick args
  # perform an http get and print the response when available

  args.state.json ||= "{ "userId": "#{Time.now.to_i}"}"
  args.state.result ||= GTK.http_post_body "http://httpbin.org/post",
                                                args.state.json,
                                                ["Content-Type: application/json", "Content-Length: #{args.state.json.length}"]


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
    GTK.show_console
  end
end
```

### `start_server!`

Starts a in-game http server that can be process http requests. When your game is running in development mode. A dev server is started at `http://localhost:9001`

?> You must set `webserver.enabled=true` in `metadata/cvars.txt` to view docs locally. These docs are also available under `./docs` within the zip file in markdown format.

You can start an in-game http server in production via:

```ruby
def tick args
  # server explicitly enabled in production
  GTK.start_server! port: 9001, enable_in_prod: true
end
```

Here's how you would respond to http requests:

```ruby
def tick args
  # server explicitly enabled in production
  GTK.start_server! port: 9001, enable_in_prod: true

  # loop through pending requests and respond to them
  args.inputs.http_requests.each do |request|
    puts "#{request}"
    request.respond 200, "ok"
  end
end
```

## Developer Support Functions

The following functions help support the development process. It is not recommended to use this functions in "production" game logic.

### `version`

Returns a string representing the version of DragonRuby you are running.

### `version_pro?`

Returns `true` if the version of DragonRuby is NOT Standard Edition.

### `game_version`

Returns a version string within `mygame/game_metadata.txt`.

To get other values from `mygame/game_metadata.txt`, you can do:

```ruby
def tick args
  if Kernel.tick_count == 0
    puts GTK.game_version
    args.cvars["game_metadata.version"].value
  end
end
```

### `reset`

Resets DragonRuby's internal state as if it were just started. `Kernel.tick_count` is set to `0` and `args.state` is cleared of any values. This function is helpful when you are developing your game and want to reset everything as if the game just booted up.

```ruby
def tick args
end

# reset the game if this file is hotloaded/required
# (removes the need to press "r" when I file is updated)
GTK.reset
```

1.  Resetting iVars (advanced)

    NOTE: `GTK.reset` does not reset global variables or instance of classes you have have constructed. If you want to also reset global variables or instances of classes when `GTK.reset` is called. Define a `reset` method. Here's an example:
    
    ```ruby
    class Game
      def initialize
        puts "Game initialize called"
      end
    end
    
    def tick args
      $game ||= Game.new
    
      if Kernel.tick_count == 0
        puts "tick_count is 0"
      end
    
      # if r is pressed on the keyboard, reset the game
      if args.inputs.keyboard.key_down.r
        GTK.reset
      end
    end
    
    # custom reset function
    def reset
      puts "Custom reset function was called."
      $game = nil
    end
    ```

2.  `rng_seed` RNG (advanced)

    Optionally, `GTK.reset` can take in a named parameter for RNG called `seed:`. Passing in `seed:` will reset RNG so that `rand` returns a repeatable set of random numbers. This `seed` value is initialized with the start time of your game (`GTK.started_at`). Having this option is is helpful for replays and unit tests.
    
    Don't worry about this capability if you aren't using DragonRuby's unit testing, or replay capabilities.
    
    Here is the behavior of `GTK.reset` when given a seed:
    
    -   RNG is seeded initially with the `Time` value of the launch of your game (retrievable via `GTK.started_at`).
    -   Calling `GTK.reset` will reset your game and re-initialize your RNG with this initial seed value.
    -   Calling `GTK.reset` with a `:seed` parameter will update the seed value for the current and subsequent resets.
    -   You can get the value used to seed RNG via `GTK.seed`.
    -   You can set your RNG seed back to its original value by using `GTK.started_at`.
    
    ```ruby
    def tick args
      if Kernel.tick_count == 0
        puts rand
        puts rand
        puts rand
        puts rand
      end
    end
    
    puts "Started at (RNG seed initial value)"
    puts GTK.started_at # Time as an integer that your game was started at
    
    puts "Seed value that will be used on reset"
    puts GTK.seed # current value that RNG was seeded with
    
    # reset the game and use the last seed to reset RNG
    GTK.reset
    
    # === OR ===
    # sets the seed value to predefined value
    # subsequent resets will use the new predefined value
    # GTK.reset seed: 100
    # (or shorthand)
    # GTK.reset 100
    
    # sets the seed back to its original value
    # GTK.reset seed: GTK.started_at
    ```
    
    If you want a new RNG seed with every reset while in dev mode:

    ```ruby
    # reset is a top-level function that DR is aware of
    # and will be invoked before GTK.reset occurs.
    def reset args
      # A new rng will be used GTK.reset is invoked
      GTK.set_rng (Time.now.to_f * 100).to_i
    end
    ```

    If you want to set RNG without resetting your game state, you can use `GTK.set_rng VALUE`.

### `reset_next_tick`

Has the same behavior as `reset` except the reset occurs before `tick` is executed again. `reset` resets the environment immediately (while the `tick` method is in-flight). It's recommended that `reset` should be called outside of the tick method (invoked when a file is saved/hotloaded), and `reset_next_tick` be used inside of the `tick` method so you don't accidentally blow away state the your game depends on to complete the current `tick` without exceptions.

```ruby
def tick args
  # reset the game if "r" is pressed on the keyboard
  if args.inputs.keyboard.key_down.r
    GTK.reset_next_tick # use reset_next_tick instead of reset
  end
end

# reset the game if this file is hotloaded/required
# (removes the need to press "r" when I file is updated)
GTK.reset
```

### `reset_and_replay`

DragonRuby has the ability to record game play that is executed against your current game code (which is helpful when refactoring):

1. Bring up the In-Game Console using `~`.
2. Click the "Show Menu" button.
3. Click "Record Gameplay".
4. Play your game and when you've got a replay you like, press `~` again to stop recording.
5. The console will be populated with a command to save the replay as `replay.txt`.
6. You can then put `GTK.reset_and_replay` at the bottom of `main.rb`. Every time you save, the replay will be automatically executed against your current code.

```ruby
def tick args
  # game code
end

# speed parameter can be increased to run the replay at a higher speed
GTK.reset_and_replay "replay.txt", speed: 1
```

### `reset_sprite`

Sprites when loaded are cached. Given a string parameter, this method
invalidates the cache record of a sprite so that updates on from the
disk can be loaded (this can also be used to reduce VRAM usage for
sprites you no longer need). 

This function can also be used to delete/garbage collect render
targets you are no longer using. 

`reset_sprite` and `reset_sprites` takes in an optional argument
`log`. Setting `log: false` will supress logging of sprites paths that
were reset (default value for `log:` is `true`). 

### `reset_sprites`

Sprites when loaded are cached. This method invalidates the cache record of all sprites so that updates on from the disk can be loaded. This function is automatically called when `GTK.reset` is invoked.

### `calcspritebox`

!> This method should be used for development purposes only and is expensive to call every frame. Do not use this method to set the size of sprite when rendering (hard code those values since you know what they are beforehand).

Given a path to a sprite, this method returns the `width` and `height` of a sprite as a tuple.

### `get_sprite_rect`

Performs the same function as `calcspritebox`, but returns a `Hash` with keys `x` (always `0`), `y` (always `0`), `w`, `h`, and `center` (`Hash` with `x`, `y`).

### `current_framerate`

Returns a float value representing the framerate of your game. This is an approximation/moving average of your framerate and should eventually settle to 60fps.

```ruby
def tick args
  # render a label to the screen that shows the current framerate
  # formatted as a floating point number with two decimal places
  args.outputs.labels << { x: 30, y: 30.from_top, text: "#{GTK.current_framerate.to_sf}" }
end
```

### `framerate_diagnostics_primitives`

Returns a set of primitives that can be rendered to the screen which provide more detailed information about the speed of your simulation (framerate, draw call count, mouse position, etc).

```ruby
def tick args
  args.outputs.primitives << GTK.framerate_diagnostics_primitives
end
```

### `warn_array_primitives!`

This function helps you audit your game of usages of array-based primitives. While array-based primitives are simple to create and use, they are slower to process than `Hash` or `Class` based primitives.

```ruby
def tick args
  # enable array based primitives warnings
  GTK.warn_array_primitives!

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
```

### `benchmark`

You can use this function to compare the relative performance of blocks of code.

Function takes in either `iterations` or `seconds` along with a collection of `lambdas`.

If `iterations` is provided, the winner will be determined by the fastest completion time.

If `seconds` is provided, the winner will be determined by the most completed iterations.

```ruby
def tick args
  # press i to run benchmark using iterations
  if args.inputs.keyboard.key_down.i
    GTK.console.show
    GTK.benchmark iterations: 1000, # number of iterations
                       # label for experiment
                       using_numeric_map: lambda {
                         # experiment body
                         v = 100.map_with_index do |i|
                           i * 100
                         end
                       },
                       # label for experiment
                       using_numeric_times: lambda {
                         # experiment body
                         v = []
                         100.times do |i|
                           v << i * 100
                         end
                       }
  end

  # press s to run benchmark using seconds
  if args.inputs.keyboard.key_down.s
    GTK.console.show
    GTK.benchmark seconds: 1, # number of seconds to run each experiment
                       # label for experiment
                       using_numeric_map: lambda {
                         # experiment body
                         v = 100.map_with_index do |i|
                           i * 100
                         end
                       },
                       # label for experiment
                       using_numeric_times: lambda {
                         # experiment body
                         v = []
                         100.times do |i|
                           v << i * 100
                         end
                       }
  end
end
```

### `notify!`

Given a string, this function will present a message at the bottom of your game. This method is only invoked in dev mode and is useful for debugging.

An optional parameter of duration (number value representing ticks) can also be passed in. The default value if `300` ticks (5 seconds).

```ruby
def tick args
  if args.inputs.mouse.click
    GTK.notify! "Mouse was clicked!"
  end

  if args.inputs.keyboard.key_down.r
    # optional duration parameter
    GTK.notify! "R key was pressed!", 600 # present message for 10 seconds/600 frames
  end
end
```

### `notify_extended!`

Has similar behavior as notify! except you have additional options to show messages in a production environment.

```ruby
def tick args
  if args.inputs.mouse.click
    GTK.notify_extended! message: "message",
                              duration: 300,
                              env: :prod
  end
end
```

### `slowmo!`

Given a numeric value representing the factor of 60fps. This function will bring your simulation loop down to slower rate. This method is intended to be used for debugging purposes.

```ruby
def tick args
  # set your simulation speed to (15 fps): GTK.slowmo! 4
  # set your simulation speed to (1 fps): GTK.slowmo! 60
  # set your simulation speed to (30 fps):
  GTK.slowmo! 2
end
```

Remove this line from your tick method will automatically set your simulation speed back to 60 fps.

### `show_console`

Shows the DragonRuby console. Useful when debugging/customizing an in-game dev workflow.

### `hide_console`

Hides the DragonRuby console. Useful when debugging/customizing an in-game dev workflow.

### `enable_console`

Enables the DragonRuby Console so that it can be presented by pressing the tilde key (the key next to the number 1 key).

### `disable_console`

Disables the DragonRuby Console so that it won't show up even if you press the tilde key or call `GTK.show_console`.

### `disable_reset_via_ctrl_r`

By default, pressing `CTRL+R` invokes `GTK.reset_next_tick` (safely resetting your game with a convenient key combo).

If you want to disable this behavior, add the following to the `main.rb`:

```ruby
def tick args
  ...
end

GTK.disable_reset_via_ctrl_r
```

NOTE: `GTK.disable_console` will also disable the `CTRL+R` reset behavior.

### `disable_controller_config`

DragonRuby has a built-in controller configuration/mapping wizard. You can disable this wizard by adding `GTK.disable_controller_config` at the top of main.rb.

### `enable_controller_config`

DragonRuby has a built-in controller configuration/mapping wizard. You can re-enable this wizard by adding `GTK.enable_controller_config` at the top of main.rb (this is enabled by default).

### `start_recording`

Resets the game to tick `0` and starts recording gameplay. Useful for visual regression tests/verification.

### `stop_recording`

Function takes in a destination file for the currently recording gameplay. This file can be used to replay a recording.

### `cancel_recording`

Function cancels a gameplay recording session and discards the replay.

### `start_replay`

Given a file that represents a recording, this method will run the recording against the current codebase.

You can start a replay from the command line also:

```bash
# first argument: the game directory
# --replay switch is the file path relative to the game directory
# --speed switch is optional. a value of 4 will run the replay and game at 4x speed
# cli command example is in the context of Linux and Mac, for Windows the binary would be ./dragonruby.exe
./dragonruby ./mygame --replay replay.txt --speed 4
```

### `stop_replay`

Function stops a replay that is currently executing.

### `get_base_dir`

Returns the path to the location of the dragonruby binary. In production mode, this value will be the same as the value returned by `get_game_dir`. Function should only be used for debugging/development workflows.

### `get_game_dir`

Returns the location within sandbox storage that the game is running. When developing your game, this value will be your `mygame` directory. In production, it'll return a value that is OS specific (eg the Roaming directory on Windows or the Application Support directory on Mac).

Invocations of `(write|append)_file` will write to this sandboxed directory.

### `get_game_dir_url`

Returns a url encoded string representing the sandbox location for game data.

### `open_game_dir`

Opens the game directory in the OS's file explorer. This should be used for debugging purposes only.

### `write_file_root`

Given a file path and contents, the contents will be written to a directory outside of the game directory. This method should be used for development purposes only. In production this method will write to the same sandboxed location as `write_file`.

### `append_file_root`

Has the same behavior as `write_file_root` except that it appends the contents as opposed to overwriting them.

### `argv`

Returns a string representing the command line arguments passed to the DragonRuby binary. This should be used for development/debugging purposes only.

### `cli_arguments`

Returns a `Hash` for command line arguments in the format of `--switch value` (two hyphens preceding the switch flag with the value separated by a space). This should be used for development/debugging purposes only.

### `download_lib(_raw)`

These two functions can help facilitate the integration of external code files. OSS contributors are encouraged to create libraries that all fit in one file (lowering the barrier to entry for adoption).

Examples:

```ruby
def tick args
end

# option 1:
# source code will be downloaded from the specified GitHub url, and saved locally with a
# predefined folder convention.
GTK.download_lib "https://github.com/xenobrain/ruby_vectormath/blob/main/vectormath_2d.rb"

# option 2:
# source code will be downloaded from the specified GitHub username, repository, and file.
# code will be saved locally with a predefined folder convention.
GTK.download_lib "xenobrain", "ruby_vectormath", "vectormath_2d.rb"

# option 3:
# source code will be downloaded from a direct/raw url and saved to a direct/raw local path.
GTK.download_lib_raw "https://raw.githubusercontent.com/xenobrain/ruby_vectormath/main/vectormath_2d.rb",
                     "lib/xenobrain/ruby_vectionmath/vectormath_2d.rb"
```

### `reload_history`

Returns a `Hash` representing the code files that have be loaded for your game along with timings for the events. This should be used for development/debugging purposes only.

```ruby
def tick args
  # every second print the reload history
  if Kernel.tick_count % 60 == 0
    puts GTK.reload_history
  end
end
```

### `reload_history_pending`

Returns a `Hash` for files that have been queued for reload, but haven't been processed yet. This should be used for development/debugging purposes only.

### `reload_if_needed`

Given a file name, this function will queue the file for reload if it's been modified. An optional second parameter can be passed in to signify if the file should be forced loaded regardless of modified time (`true` means to force load, `false` means to load only if the file has been modified). This function should be used for development/debugging purposes only.

### `trace_puts!`

If you need to hunt down rogue `puts` statements in your code do:

```ruby
def tick args
  # adding the following line to the TOP of your tick method
  # will print ~caller~ along side each ~puts~ statement
  GTK.trace_puts!
end
```

### `current_thermal_state`

iOS only (returns `nil` for other platforms). Returns a symbol representing the thermal state of the device: `:unknown`, `:nominal`, `:fair`, `:serious`, `:critical`.

When deploying to your local dev device, if the value is `:serious` or `:critical`, you will be notified via a toast message.

Here's how you can explicitly display the thermal state on the screen:

```ruby
def tick args
  args.outputs.labels << { x: Grid.w / 2,
                           y: Grid.h / 2,
                           text: "thermal state: #{GTK.current_thermal_state || :unknown}",
                           r: 255,
                           g: 255,
                           b: 255,
                           size_px: 30,
                           anchor_x: 0.5,
                           anchor_y: 0.5 }
end
```

# State (`args.state`)

Store your game state inside of this `state`. Properties with arbitrary nesting is allowed and a backing Entity will be created on your behalf.

```ruby
def tick args
  args.state.player.x ||= 0
  args.state.player.y ||= 0
end
```

## `entity_id`

Entities automatically receive an `entity_id` of type `Fixnum`.

## `entity_type`

Entities can have an `entity_type` which is represented as a `Symbol`.

## `created_at`

Entities have `created_at` set to `Kernel.tick_count` when they are created.

## `created_at_elapsed`

Returns the elapsed number of ticks since creation.

## `global_created_at`

Entities have `global_created_at` set to `Kernel.global_tick_count` when they are created.

## `global_created_at_elapsed`

Returns the elapsed number of global ticks since creation.

## `as_hash`

Entity cast to a `Hash` so you can update values as if you were updating a `Hash`.

## `tick_count`

Returns the current tick of the game. `Kernel.tick_count` is `0` when the game is first started or if the game is reset via `GTK.reset`.

# `Kernel`

Kernel in the DragonRuby Runtime has patches for how standard out is handled and also contains a unit of time in games called a tick.

## `tick_count`

Returns the current tick of the game. This value is reset if you call GTK.reset.

## `global_tick_count`

Returns the current tick of the application from the point it was started. This value is never reset.
