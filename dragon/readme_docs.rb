# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# readme_docs.rb has been released under MIT (*only this file*).

module GTK
  module ReadMeDocs
    def docs_method_sort_order
      %i[
        docs_hello_world
        docs_new_project
        docs_deployment
        docs_deployment_mobile
        docs_deployment_steam
        docs_dragonruby_philosophy
        docs_faq
        docs_troubleshooting_performance
      ]
    end

    def docs_hello_world
      DocsOrganizer.get_docsify_content path: "docs/guides/getting-started.md",
                                        heading_level: 1,
                                        heading_include: "Getting Started"
    end

    def docs_new_project
      DocsOrganizer.get_docsify_content path: "docs/guides/starting-a-new-project.md",
                                        heading_level: 1,
                                        heading_include: "Starting a New DragonRuby Project"
    end

    def docs_deployment
      DocsOrganizer.get_docsify_content path: "docs/guides/deploying-to-itch.md",
                                        heading_level: 1,
                                        heading_include: "Deploying To Itch.io"
    end

    def docs_deployment_mobile
      DocsOrganizer.get_docsify_content path: "docs/guides/deploying-to-mobile.md",
                                        heading_level: 1,
                                        heading_include: "Deploying To Mobile Devices"
    end

    def docs_deployment_steam
      DocsOrganizer.get_docsify_content path: "docs/guides/deploying-to-mobile.md",
                                        heading_level: 1,
                                        heading_include: "Deploying To Steam"
    end

    def docs_dragonruby_philosophy
      DocsOrganizer.get_docsify_content path: "docs/misc/philosophy.md",
                                        heading_level: 1,
                                        heading_include: "DragonRuby's Philosophy"
    end

    def docs_ticks_and_frames
      <<-'S'
* RECIPIES:
** How To Determine What Frame You Are On

There is a property on ~state~ called ~tick_count~ that is incremented
by DragonRuby every time the ~tick~ method is called. The following
code renders a label that displays the current ~tick_count~.

#+begin_src ruby
  def tick args
    args.outputs.labels << [10, 670, "\#{Kernel.tick_count}"]
  end
#+end_src

** How To Get Current Framerate

Current framerate is a top level property on the Game Toolkit Runtime
and is accessible via ~args.gtk.current_framerate~.

#+begin_src ruby
  def tick args
    args.outputs.labels << [10, 710, "framerate: \#{args.gtk.current_framerate.round}"]
  end
#+end_src
S
    end

    def docs_sprites
      <<-'S'
** How To Render A Sprite Using An Array

All file paths should use the forward slash ~/~ *not* backslash
~\~. Game Toolkit includes a number of sprites in the ~sprites~
folder (everything about your game is located in the ~mygame~ directory).

The following code renders a sprite with a ~width~ and ~height~ of
~100~ in the center of the screen.

~args.outputs.sprites~ is used to render a sprite.

NOTE: Rendering using an ~Array~ is "quick and dirty". It's generally recommended that
      you render using ~Hashes~ long term.

#+begin_src ruby
  def tick args
    args.outputs.sprites << [
      640 - 50,                 # X
      360 - 50,                 # Y
      100,                      # W
      100,                      # H
      'sprites/square-blue.png' # PATH
   ]
  end
#+end_src

** Rendering a Sprite Using a ~Hash~

Using ordinal positioning can get a little unruly given so many
properties you have control over.

You can represent a sprite as a ~Hash~:

#+begin_src ruby
  def tick args
    args.outputs.sprites << {
      x: 640 - 50,
      y: 360 - 50,
      w: 100,
      h: 100,

      path: 'sprites/square-blue.png',
      angle: 0,

      a: 255,
      r: 255,
      g: 255,
      b: 255,

      # source_ properties have origin of bottom left
      source_x:  0,
      source_y:  0,
      source_w: -1,
      source_h: -1,

      # tile_ properties have origin of top left
      tile_x:  0,
      tile_y:  0,
      tile_w: -1,
      tile_h: -1,

      flip_vertically: false,
      flip_horizontally: false,

      angle_anchor_x: 0.5,
      angle_anchor_y: 1.0,

      blendmode_enum: 1

      # sprites anchor/alignment (default is nil)
      anchor_x: 0.5,
      anchor_y: 0.5
    }
  end
#+end_src

The ~blendmode_enum~ value can be set to ~0~ (no blending), ~1~ (alpha blending),
~2~ (additive blending), ~3~ (modulo blending), ~4~ (multiply blending).
S
    end

    def docs_labels
      <<-'S'
** How To Render A Label

~args.outputs.labels~ is used to render labels.

Labels are how you display text. This code will go directly inside of
the ~def tick args~ method.

NOTE: Rendering using an ~Array~ is "quick and dirty". It's generally recommended that
      you render using ~Hashes~ long term.

Here is the minimum code:

#+begin_src
  def tick args
    #                       X    Y    TEXT
    args.outputs.labels << [640, 360, "I am a black label."]
  end
#+end_src

** A Colored Label

#+begin_src
  def tick args
    # A colored label
    #                       X    Y    TEXT,                   RED    GREEN  BLUE  ALPHA
    args.outputs.labels << [640, 360, "I am a redish label.", 255,     128,  128,   255]
  end
#+end_src

** Extended Label Properties

#+begin_src
  def tick args
    # A colored label
    #                       X    Y     TEXT           SIZE  ALIGNMENT  RED  GREEN  BLUE  ALPHA  FONT FILE
    args.outputs.labels << [
      640,                   # X
      360,                   # Y
      "Hello world",         # TEXT
      0,                     # SIZE_ENUM
      1,                     # ALIGNMENT_ENUM
      0,                     # RED
      0,                     # GREEN
      0,                     # BLUE
      255,                   # ALPHA
      "fonts/coolfont.ttf"   # FONT
    ]
  end
#+end_src

A ~SIZE_ENUM~ of ~0~ represents "default size". A ~negative~ value
will decrease the label size. A ~positive~ value will increase the
label's size.

An ~ALIGNMENT_ENUM~ of ~0~ represents "left aligned". ~1~ represents
"center aligned". ~2~ represents "right aligned".

** Rendering A Label As A ~Hash~

You can add additional metadata about your game within a label, which requires you to use a `Hash` instead.

If you use a ~Hash~ to render a label, you can set the label's size using either ~SIZE_ENUM~ or ~SIZE_PX~. If
both options are provided, ~SIZE_PX~ will be used.

#+begin_src
  def tick args
    args.outputs.labels << {
      x:                       200,
      y:                       550,
      text:                    "dragonruby",
      # size specification can be either size_enum or size_px
      size_enum:               2,
      size_px:                 22,
      alignment_enum:          1,
      r:                       155,
      g:                       50,
      b:                       50,
      a:                       255,
      font:                    "fonts/manaspc.ttf",
      vertical_alignment_enum: 0, # 0 is bottom, 1 is middle, 2 is top
      anchor_x: 0.5,
      anchor_y: 0.5
      # You can add any properties you like (this will be ignored/won't cause errors)
      game_data_one:  "Something",
      game_data_two: {
         value_1: "value",
         value_2: "value two",
         a_number: 15
      }
    }
  end
#+end_src

** Getting The Size Of A Piece Of Text

You can get the render size of any string using ~args.gtk.calcstringbox~.

#+begin_src ruby
  def tick args
    #                             TEXT           SIZE_ENUM  FONT
    w, h = args.gtk.calcstringbox("some string",         0, "font.ttf")

    # NOTE: The SIZE_ENUM and FONT are optional arguments.

    # Render a label showing the w and h of the text:
    args.outputs.labels << [
      10,
      710,
      # This string uses Ruby's string interpolation literal: #{}
      "'some string' has width: #{w}, and height: #{h}."
    ]
  end
#+end_src

** Rendering Labels With New Line Characters And Wrapping

You can use a strategy like the following to create multiple labels from a String.

#+begin_src ruby
  def tick args
    long_string = "Lorem ipsum dolor sit amet, consectetur adipiscing elitteger dolor velit, ultricies vitae libero vel, aliquam imperdiet enim."
    max_character_length = 30
    long_strings_split = args.string.wrapped_lines long_string, max_character_length
    args.outputs.labels << long_strings_split.map_with_index do |s, i|
      { x: 10, y: 600 - (i * 20), text: s }
    end
  end
#+end_src
S
    end

    def docs_sounds
      <<-'S'
** How To Play A Sound

Sounds that end ~.wav~ will play once:

#+begin_src ruby
  def tick args
    # Play a sound every second
    if (Kernel.tick_count % 60) == 0
      args.outputs.sounds << 'something.wav'
    end
  end
#+end_src

Sounds that end ~.ogg~ is considered background music and will loop:

#+begin_src ruby
  def tick args
    # Start a sound loop at the beginning of the game
    if Kernel.tick_count == 0
      args.outputs.sounds << 'background_music.ogg'
    end
  end
#+end_src

If you want to play a ~.ogg~ once as if it were a sound effect, you can do:

#+begin_src ruby
  def tick args
    # Play a sound every second
    if (Kernel.tick_count % 60) == 0
      args.gtk.queue_sound 'some-ogg.ogg'
    end
  end
#+end_src
S
    end

    def docs_game_state
      <<-'S'
** Using ~args.state~ To Store Your Game State

~args.state~ is a open data structure that allows you to define
properties that are arbitrarily nested. You don't need to define any kind of
~class~.

To initialize your game state, use the ~||=~ operator. Any value on
the right side of ~||=~ will only be assigned _once_.

To assign a value every frame, just use the ~=~ operator, but _make
sure_ you've initialized a default value.

#+begin_src
  def tick args
    # initialize your game state ONCE
    args.state.player.x  ||= 0
    args.state.player.y  ||= 0
    args.state.player.hp ||= 100

    # increment the x position of the character by one every frame
    args.state.player.x += 1

    # Render a sprite with a label above the sprite
    args.outputs.sprites << [
      args.state.player.x,
      args.state.player.y,
      32, 32,
      "player.png"
    ]

    args.outputs.labels << [
      args.state.player.x,
      args.state.player.y - 50,
      args.state.player.hp
    ]
  end
#+end_src
S
    end

    def docs_accessing_files
      <<-'S'
** Accessing files

DragonRuby uses a sandboxed filesystem which will automatically read from and
write to a location appropriate for your platform so you don't have to worry
about theses details in your code. You can just use ~gtk.read_file~,
~gtk.write_file~, and ~gtk.append_file~ with a relative path and the engine
will take care of the rest.

The data directories that will be written to in a production build are:

- Windows: ~C:\Users\[username]\AppData\Roaming\[devtitle]\[gametitle]~
- MacOS: ~$HOME/Library/Application Support/[gametitle]~
- Linux: ~$HOME/.local/share/[gametitle]~
- HTML5: The data will be written to the browser's IndexedDB.

The values in square brackets are the values you set in your
~app/metadata/game_metadata.txt~ file.

When reading files, the engine will first look in the game's data directory
and then in the game directory itself. This means that if you write a file
to the data directory that already exists in your game directory, the file
in the data directory will be used instead of the one that is in your game.

When running a development build you will directly write to your game
directory (and thus overwrite existing files). This can be useful for built-in
development tools like level editors.

For more details on the implementation of the sandboxed filesystem, see Ryan
C. Gordon's PhysicsFS documentation: [[https://icculus.org/physfs/]]

IMPORTANT: File access functions are sandoxed and assume that the
~dragonruby~ binary lives alongside the game you are building. Do not
expect file access functions to return correct values if you are attempting
to run the ~dragonruby~ binary from a shared location. It's
recommended that the directory structure contained in the zip is not
altered and games are built using that starter template.
S
    end

    def animate_a_sprite
      <<-'S'
** How To Animate A Sprite Using Separate PNGs

DragonRuby has a property on ~Numeric~ called ~frame_index~ that can
be used to determine what frame of an animation to show. Here is an
example of how to cycle through 6 sprites every 4 frames.

#+begin_src ruby
  def tick args
    start_looping_at = 0
    number_of_sprites = 6
    number_of_frames_to_show_each_sprite = 4
    does_sprite_loop = true

    sprite_index =
      start_looping_at.frame_index number_of_sprites,
                                   number_of_frames_to_show_each_sprite,
                                   does_sprite_loop

    sprite_index ||= 0

    args.outputs.sprites << [
      640 - 50,
      360 - 50,
      100,
      100,
      "sprites/dragon-#{sprite_index}.png"
    ]
  end
#+end_src
S
    end

    def docs_troubleshooting_performance
<<-'S'
** Troubleshoot Performance

- Avoid deep recursive calls.
- If you're using ~Array~s for your primitives (~args.outputs.sprites << []~), use ~Hash~ instead (~args.outputs.sprites << { x: ... }~).
- If you're using ~Entity~ for your primitives (~args.outputs.sprites << args.state.new_entity~), use ~StrictEntity~ instead (~args.outputs.sprites << args.state.new_entity_strict~).
- Use ~.each~ instead of ~.map~ if you don't care about the return value.
- When concatenating primitives to outputs, do them in bulk. Instead of:
#+begin_src ruby
  args.state.bullets.each do |bullet|
    args.outputs.sprites << bullet.sprite
  end
#+end_src
do
#+begin_src
  args.outputs.sprites << args.state.bullets.map do |b|
    b.sprite
  end
#+end_src
- Use ~args.outputs.static_~ variant for things that don't change often (take a look at the Basic Gorillas sample app and Dueling Starships sample app to see how ~static_~ is leveraged.
- Consider using a ~render_target~ if you're doing some form of a camera that moves a lot of primitives (take a look at the Render Target sample apps for more info).
- Avoid deleting or adding to an array during iteration. Instead of:
#+begin_src ruby
  args.state.fx_queue.each |fx|
    fx.count_down ||= 255
    fx.countdown -= 5
    if fx.countdown < 0
      args.state.fx_queue.delete fx
    end
  end
#+end_src
Do:
#+begin_src ruby
  args.state.fx_queue.each |fx|
    fx.countdown ||= 255
    fx.countdown -= 5
  end

  args.state.fx_queue.reject! { |fx| fx.countdown < 0 }
#+end_src
S
    end

    def scale_sprites
      <<-'S'
** How to Scale a Sprite

The ~scale_rect~ method can be used to change the scale of a sprite by a given ~ratio~.

Optionally, you can scale the sprite around a specified anchor point. In the example below, setting both ~anchor_x~ and ~anchor_y~ to 0.5 scales the sprite proportionally on all four sides).

See also: ~Geometry#scale_rect~

#+begin_src ruby
  def tick args
    #            x,   y,   w,   h,   path
    my_sprite = [590, 310, 100, 100, 'sprites/circle.png']

    # scale a sprite with a ratio of 2 (double the size)
    # and anchor the transformation around the center of the sprite

    #                                       ratio, anchor_x, anchor_y
    my_scaled_sprite = my_sprite.scale_rect(2,     0.5,      0.5)

    args.outputs.sprites << [my_scaled_sprite, "sprites/circle.png"]
  end
#+end_src
S
    end

    def docs_faq
      DocsOrganizer.get_docsify_content path: "docs/misc/faq.md",
                                        heading_level: 1,
                                        heading_include: "Frequently Asked Questions, Comments, and Concerns"
    end
  end

  class ReadMe
    extend Docs
    extend ReadMeDocs
  end
end
