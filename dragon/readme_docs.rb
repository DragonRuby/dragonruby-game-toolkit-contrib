# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# readme_docs.rb has been released under MIT (*only this file*).

module GTK
  module ReadMeDocs
    def docs_method_sort_order
      [
        :docs_usage,
        :docs_hello_world,
        :docs_deployment,
        :docs_deployment_mobile,
        :docs_dragonruby_philosophy,
        :docs_faq,
        :docs_ticks_and_frames,
        :docs_sprites,
        :docs_labels,
        :docs_sounds,
        :docs_game_state,
        :docs_troubleshooting_performance
      ]
    end

    def docs_usage
      <<-S
* DragonRuby Game Toolkit Live Docs

The information contained here is all available via the DragonRuby
Console. You can Open the DragonRuby Console by pressing [`] [~] [²]
[^] [º] or [§] within your game.

To search docs you can type ~docs_search "SEARCH TERM"~ or if you want
to get fancy you can provide a ~lambda~ to filter documentation:

#+begin_src
  docs_search { |entry| (entry.include? "Array") && (!entry.include? "Enumerable") }
#+end_src
S
    end

    def docs_hello_world
<<-S
* Hello World

Welcome to DragonRuby Game Toolkit. Take the steps below to get started.

* Join the Discord and Subscribe to the News Letter

Our Discord channel is [[http://discord.dragonruby.org]].

The News Letter will keep you in the loop with regards to current
DragonRuby Events: [[http://dragonrubydispatch.com]].

Those who use DragonRuby are called Dragon Riders. This identity is
incredibly important to us. When someone asks you:

#+begin_quote
What game engine do you use?
#+end_quote

Reply with:

#+begin_quote
I am a Dragon Rider.
#+end_quote

* Intro Videos

Here are some videos to help you get the lay of the land.

** Quick Api Tour

1. Beginner Introduction to DragonRuby Game Toolkit: [[https://youtu.be/ixw7TJhU08E]]

** If You Are Completely New to Ruby and Programming

1. Intermediate Introduction to Ruby Syntax: [[https://youtu.be/HG-XRZ5Ppgc]]
2. Intermediate Introduction to Arrays in Ruby: [[https://youtu.be/N72sEYFRqfo]]
3. You may also want to try this free course provided at [[http://dragonruby.school]].

** If You Have Game Dev Experience

1. Building Tetris - Part 1: [[https://youtu.be/xZMwRSbC4rY]]
2. Building Tetris - Part 2: [[https://youtu.be/C3LLzDUDgz4]]
3. Low Res Game Jam Tutorial: [[https://youtu.be/pCI90ukKCME]]

* Getting Started Tutorial

This is a tutorial written by Ryan C Gordon (a Juggernaut in the
industry who has contracted to Valve, Epic, Activision, and
EA... check out his Wikipedia page: [[https://en.wikipedia.org/wiki/Ryan_C._Gordon]]).

** Introduction

Welcome!

Here's just a little push to get you started if you're new to
programming or game development.

If you want to write a game, it's no different than writing any other
program for any other framework: there are a few simple rules that
might be new to you, but more or less programming is programming no
matter what you are building.

Did you not know that? Did you think you couldn't write a game because
you're a "web guy" or you're writing Java at a desk job? Stop letting
people tell you that you can't, because you already have everything
you need.

Here, we're going to be programming in a language called "Ruby." In
the interest of full disclosure, I (Ryan Gordon) wrote the C parts of
this toolkit and Ruby looks a little strange to me (Amir Rajan wrote
the Ruby parts, discounting the parts I mangled), but I'm going to
walk you through the basics because we're all learning together, and
if you mostly think of yourself as someone that writes C (or C++, C#,
Objective-C), PHP, or Java, then you're only a step behind me right
now.

** Prerequisites

Here's the most important thing you should know: Ruby lets you do some
complicated things really easily, and you can learn that stuff
later. I'm going to show you one or two cool tricks, but that's all.

Do you know what an if statement is? A for-loop? An array? That's all
you'll need to start.

** The Game Loop

Ok, here are few rules with regards to game development with GTK:

- Your game is all going to happen under one function ...
- that runs 60 times a second ...
- and has to tell the computer what to draw each time.

That's an entire video game in one run-on sentence.

Here's that function. You're going to want to put this in
mygame/app/main.rb, because that's where we'll look for it by
default. Load it up in your favorite text editor.

#+begin_src ruby
  def tick args
    args.outputs.labels << [580, 400, 'Hello World!']
  end
#+end_src

Now run ~dragonruby~ ...did you get a window with "Hello World!"
written in it? Good, you're officially a game developer!

** Breakdown Of The ~tick~ Method

~mygame/app/main.rb~, is where the Ruby source code is located. This
looks a little strange, so I'll break it down line by line. In Ruby, a
'#' character starts a single-line comment, so I'll talk about this
inline.

#+begin_src ruby
  # This "def"ines a function, named "tick," which takes a single argument
  # named "args". DragonRuby looks for this function and calls it every
  # frame, 60 times a second. "args" is a magic structure with lots of
  # information in it. You can set variables in there for your own game state,
  # and every frame it will updated if keys are pressed, joysticks moved,
  # mice clicked, etc.
  def tick args

    # One of the things in "args" is the "outputs" object that your game uses
    # to draw things. Afraid of rendering APIs? No problem. In DragonRuby,
    # you use arrays to draw things and we figure out the details.
    # If you want to draw text on the screen, you give it an array (the thing
    # in the [ brackets ]), with an X and Y coordinate and the text to draw.
    # The "<<" thing says "append this array onto the list of them at
    # args.outputs.labels)
    args.outputs.labels << [580, 400, 'Hello World!']
  end
#+end_src

Once your ~tick~ function finishes, we look at all the arrays you made
and figure out how to draw it. You don't need to know about graphics
APIs. You're just setting up some arrays! DragonRuby clears out these
arrays every frame, so you just need to add what you need _right now_
each time.

** Rendering A Sprite

Now let's spice this up a little.

We're going to add some graphics. Each 2D image in DragonRuby is
called a "sprite," and to use them, you just make sure they exist in a
reasonable file format (png, jpg, gif, bmp, etc) and specify them by
filename. The first time you use one, DragonRuby will load it and keep
it in video memory for fast access in the future. If you use a
filename that doesn't exist, you get a fun checkerboard pattern!

There's a "dragonruby.png" file included, just to get you
started. Let's have it draw every frame with our text:

#+begin_src ruby
  def tick args
    args.outputs.labels  << [580, 400, 'Hello World!']
    args.outputs.sprites << [576, 100, 128, 101, 'dragonruby.png']
  end
#+end_src

(Pro Tip: you don't have to restart DragonRuby to test your changes;
when you save main.rb, DragonRuby will notice and reload your
program.)

That ~.sprites~ line says "add a sprite to the list of sprites we're
drawing, and draw it at position (576, 100) at a size of 128x101
pixels". You can find the image to draw at dragonruby.png.

** Coordinate System and Virtual Canvas

Quick note about coordinates: (0, 0) is the bottom left corner of the
screen, and positive numbers go up and to the right. This is more
"geometrically correct," even if it's not how you remember doing 2D
graphics, but we chose this for a simpler reason: when you're making
Super Mario Brothers and you want Mario to jump, you should be able to
add to Mario's y position as he goes up and subtract as he falls. It
makes things easier to understand.

Also: your game screen is _always_ 1280x720 pixels. If you resize the
window, we will scale and letterbox everything appropriately, so you
never have to worry about different resolutions.

Ok, now we have an image on the screen, let's animate it:

#+begin_src ruby
  def tick args
    args.state.rotation  ||= 0
    args.outputs.labels  << [580, 400, 'Hello World!' ]
    args.outputs.sprites << [576, 100, 128, 101, 'dragonruby.png', args.state.rotation]
    args.state.rotation  -= 1
  end
#+end_src

Now you can see that this function is getting called a lot!

** Game State

Here's a fun Ruby thing: ~args.state.rotation ||= 0~ is shorthand for
"if args.state.rotation isn't initialized, set it to zero." It's a
nice way to embed your initialization code right next to where you
need the variable.


~args.state~ is a place you can hang your own data. It's an open data
structure that allows you to define properties that are arbitrarily
nested. You don't need to define any kind of class.

In this case, the current rotation of our sprite, which is happily
spinning at 60 frames per second. If you don't specify rotation (or
alpha, or color modulation, or a source rectangle, etc), DragonRuby
picks a reasonable default, and the array is ordered by the most
likely things you need to tell us: position, size, name.

** There Is No Delta Time

One thing we decided to do in DragonRuby is not make you worry about
delta time: your function runs at 60 frames per second (about 16
milliseconds) and that's that. Having to worry about framerate is
something massive triple-AAA games do, but for fun little 2D games?
You'd have to work really hard to not hit 60fps. All your drawing is
happening on a GPU designed to run Fortnite quickly; it can definitely
handle this.

Since we didn't make you worry about delta time, you can just move the
rotation by 1 every time and it works without you having to keep track
of time and math. Want it to move faster? Subtract 2.

** Handling User Input

Now, let's move that image around.

#+begin_src ruby
  def tick args
    args.state.rotation ||= 0
    args.state.x ||= 576
    args.state.y ||= 100

    if args.inputs.mouse.click
      args.state.x = args.inputs.mouse.click.point.x - 64
      args.state.y = args.inputs.mouse.click.point.y - 50
    end

    args.outputs.labels  << [580, 400, 'Hello World!']
    args.outputs.sprites << [args.state.x,
                             args.state.y,
                             128,
                             101,
                             'dragonruby.png',
                             args.state.rotation]

    args.state.rotation -= 1
  end
#+end_src

Everywhere you click your mouse, the image moves there. We set a
default location for it with ~args.state.x ||= 576~, and then we
change those variables when we see the mouse button in action. You can
get at the keyboard and game controllers in similar ways.

** Coding On A Raspberry Pi

We have only tested DragonRuby on a Raspberry Pi 3, Models B and B+, but we
believe it _should_ work on any model with comparable specs.

If you're running DragonRuby Game Toolkit on a Raspberry Pi, or trying to run
a game made with the Toolkit on a Raspberry Pi, and it's really really slow--
like one frame every few seconds--then there's likely a simple fix.

You're probably running a desktop environment: menus, apps, web browsers,
etc. This is okay! Launch the terminal app and type:

#+begin_src
sudo raspi-config
#+end_src

It'll ask you for your password (if you don't know, try "raspberry"), and then
give you a menu of options. Find your way to "Advanced Options", then "GL
Driver", and change this to "GL (Full KMS)"  ... not "fake KMS," which is
also listed there. Save and reboot. In theory, this should fix the problem.

If you're _still_ having problems and have a Raspberry Pi 2 or better, go back
to raspi-config and head over to "Advanced Options", "Memory split," and give
the GPU 256 megabytes. You might be able to avoid this for simple games, as
this takes RAM away from the system and reserves it for graphics. You can
also try 128 megabytes as a gentler option.

Note that you can also run DragonRuby without X11 at all: if you run it from
a virtual terminal it will render fullscreen and won't need the "Full KMS"
option. This might be attractive if you want to use it as a game console
sort of thing, or develop over ssh, or launch it from RetroPie, etc.

** Conclusion

There is a lot more you can do with DragonRuby, but now you've already
got just about everything you need to make a simple game. After all,
even the most fancy games are just creating objects and moving them
around. Experiment a little. Add a few more things and have them
interact in small ways. Want something to go away? Just don't add it
to ~args.output~ anymore.
S
    end

    def docs_deployment
<<-S

* Deploying To Itch.io

Once you've built your game, you're all set to deploy! Good luck in
your game dev journey and if you get stuck, come to the Discord
channel!

** Creating Your Game Landing Page

Log into Itch.io and go to [[https://itch.io/game/new]].

- Title: Give your game a Title. This value represents your `gametitle`.
- Project URL: Set your project url. This value represents your `gameid`.
- Classification: Keep this as Game.
- Kind of Project: Select HTML from the drop down list. Don't worry,
  the HTML project type _also supports binary downloads_.
- Uploads: Skip this section for now.

You can fill out all the other options later.

** Update Your Game's Metadata

Point your text editor at mygame/metadata/game_metadata.txt and
make it look like this:

NOTE: Remove the ~#~ at the beginning of each line.

#+begin_src
  devid=bob
  devtitle=Bob The Game Developer
  gameid=mygame
  gametitle=My Game
  version=0.1
#+end_src

The ~devid~ property is the username you use to log into Itch.io.
The ~devtitle~ is your name or company name (it can contain spaces).
The ~gameid~ is the Project URL value.
The ~gametitle~ is the name of your game (it can contain spaces).
The ~version~ can be any ~major.minor~ number format.

** Building Your Game For Distribution

Open up the terminal and run this from the command line:

#+begin_src
  ./dragonruby-publish --only-package mygame
#+end_src

(if you're on Windows, don't put the "./" on the front. That's a Mac and
Linux thing.)

A directory called ~./build~ will be created that contains your
binaries. You can upload this to Itch.io manually.

For the HTML version of your game after you upload it. Check the checkbox labeled
"This file will be played in the browser".

For subsequent updates you can use an automated deployment to Itch.io:

#+begin_src
  ./dragonruby-publish mygame
#+end_src

DragonRuby will package _and publish_ your game to itch.io! Tell your
friends to go to your game's very own webpage and buy it!

If you make changes to your game, just re-run dragonruby-publish and it'll
update the downloads for you.
S
    end

    def docs_deployment_mobile
<<-S

* Deploying To Mobile Devices

If you have a Pro subscription, you also have the capability to deploy
to mobile devices.

To deploy to iOS, you need to have a Mac running MacOS Catalina, an
iOS device, and an active/paid Developer Account with Apple. From the
Console type: ~$wizards.ios.start~ and you will be guided through the
deployment process.

To deploy to Android, you need to have an Android emulator/device, and
an environment that is able to run Android SDK. ~dragonruby-publish~
will create an APK for you. From there, you can sign the APK and
install it to your device. The signing and installation procedure
varies from OS to OS. Here's an example of what the command might look
like:

#+begin_src
  > adb logcat -e mygame # you'll want to run this in a separate terminal
  > keytool -genkey -v -keystore mygame.keystore -alias mygame -keyalg RSA -keysize 2048 -validity 10000
  > apksigner sign --ks mygame.keystore mygame-android.apk
  > adb install mygame-android.apk
#+end_src
S
    end

    def docs_dragonruby_philosophy
      <<-S
* DragonRuby's Philosophy

The following tenants of DragonRuby are what set us apart from other
game engines. Given that Game Toolkit is a relatively new engine,
there are definitely features that are missing. So having a big check
list of "all the cool things" is not this engine's forte. This is
compensated with a strong commitment to the following principles.

** Challenge The Status Quo

Game engines of today are in a local maximum and don't take into
consideration the challenges of this day and age. Unity and GameMaker
specifically rot your brain. It's not sufficient to say:

#+begin_quote
But that's how we've always done it.
#+end_quote

It's a hard pill to swallow, but forget blindly accepted best
practices and try to figure out the underlying motivation for a
specific approach to game development. Collaborate with us.

** Continuity of Design

There is a programming idiom in software called "The Pit of
Success". The term normalizes upfront pain as a necessity/requirement in the
hopes that the investment will yield dividends "when you become
successful" or "when the code becomes more complicated". This approach to
development is strongly discouraged by us. It leads to over-architected
and unnecessary code; creates barriers to rapid prototyping and shipping a game; and
overwhelms beginners who are new to the engine or programming in general.

DragonRuby's philosophy is to provide multiple options across the "make it
fast" vs "make it right" spectrum, with incremental/intuitive
transitions between the options provided. A concrete example of this philosophy
would be render primitives: the spectrum of options allows renderable constructs that
take the form of tuples/arrays (easy to pickup, simple, and fast to code/prototype with),
hashes (a little more work, but gives you the ability to add additional properties),
open and strict entities (more work than hashes, but yields cleaner apis),
and finally - if you really need full power/flexibility in rendering - classes
(which take the most amount of code and programming knowledge to create).

** Release Early and Often

The biggest mistake game devs make is spending too much time in
isolation building their game. Release something, however small, and
release it soon.

Stop worrying about everything being pixel perfect. Don't wait until
your game is 100% complete. Build your game publicly and
iterate. Post in the #show-and-tell channel in the community Discord.
You'll find a lot of support and encouragement there.

Real artists ship. Remember that.

** Sustainable And Ethical Monetization

We all aspire to put food on the table doing what we love. Whether it
is building games, writing tools to support game development, or
anything in between.

Charge a fair amount of money for the things you create. It's expected
and encouraged within the community. Give what you create away for
free to those that can't afford it.

If you are gainfully employed, pay full price for the things you use. If you
do end up getting something at a discount, pay the difference "forward" to
someone else.

** Sustainable And Ethical Open Source

This goes hand in hand with sustainable and ethical monetization. The
current state of open source is not sustainable. There is an immense
amount of contributor burnout. Users of open source expect everything
to be free, and few give back. This is a problem we want to fix (we're
still trying to figure out the best solution).

So, don't be "that guy" in the Discord that says "DragonRuby should be
free and open source!" You will be personally flogged by Amir.

** People Over Entities

We prioritize the endorsement of real people over faceless
entities. This game engine, and other products we create, are not
insignificant line items of a large company. And you aren't a generic
"commodity" or "corporate resource". So be active in the community
Discord and you'll reap the benefits as more devs use DragonRuby.

** Building A Game Should Be Fun And Bring Happiness

We will prioritize the removal of pain. The aesthetics of Ruby make it
such a joy to work with, and we want to capture that within the
engine.

** Real World Application Drives Features

We are bombarded by marketing speak day in and day out. We don't do
that here. There are things that are really great in the engine, and
things that need a lot of work. Collaborate with us so we can help you
reach your goals. Ask for features you actually need as opposed to
anything speculative.

We want DragonRuby to *actually* help you build the game you
want to build (as opposed to sell you something piece of demoware that
doesn't work).
S
    end

    def docs_ticks_and_frames
      <<-S
* RECIPIES:
** How To Determine What Frame You Are On

There is a property on ~state~ called ~tick_count~ that is incremented
by DragonRuby every time the ~tick~ method is called. The following
code renders a label that displays the current ~tick_count~.

#+begin_src ruby
  def tick args
    args.outputs.labels << [10, 670, "\#{args.state.tick_count}"]
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
      <<-S
** How To Render A Sprite Using An Array

All file paths should use the forward slash ~/~ *not* backslash
~\~. Game Toolkit includes a number of sprites in the ~sprites~
folder (everything about your game is located in the ~mygame~ directory).

The following code renders a sprite with a ~width~ and ~height~ of
~100~ in the center of the screen.

~args.outputs.sprites~ is used to render a sprite.

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

** More Sprite Properties As An Array

Here are all the properties you can set on a sprite.

#+begin_src ruby
  def tick args
    args.outputs.sprites << [
      100,                       # X
      100,                       # Y
      32,                        # W
      64,                        # H
      'sprites/square-blue.png', # PATH
      0,                         # ANGLE
      255,                       # ALPHA
      0,                         # RED_SATURATION
      255,                       # GREEN_SATURATION
      0                          # BLUE_SATURATION
    ]
  end
#+end_src

** Different Sprite Representations

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
      source_x:  0,
      source_y:  0,
      source_w: -1,
      source_h: -1,
      flip_vertically: false,
      flip_horizontally: false,
      angle_anchor_x: 0.5,
      angle_anchor_y: 1.0,
      blendmode_enum: 1
    }
  end
#+end_src

The ~blendmode_enum~ value can be set to ~0~ (no blending), ~1~ (alpha blending),
~2~ (additive blending), ~3~ (modulo blending), ~4~ (multiply blending).

You can represent a sprite as an ~object~:

#+begin_src ruby
  # Create type with ALL sprite properties AND primitive_marker
  class Sprite
    attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b,
                  :source_x, :source_y, :source_w, :source_h,
                  :tile_x, :tile_y, :tile_w, :tile_h,
                  :flip_horizontally, :flip_vertically,
                  :angle_anchor_x, :angle_anchor_y, :blendmode_enum

    def primitive_marker
      :sprite
    end
  end

  class BlueSquare < Sprite
    def initialize opts
      @x = opts[:x]
      @y = opts[:y]
      @w = opts[:w]
      @h = opts[:h]
      @path = 'sprites/square-blue.png'
    end
  end

  def tick args
    args.outputs.sprites << (BlueSquare.new x: 640 - 50,
                                            y: 360 - 50,
                                            w: 50,
                                            h: 50)
  end
#+end_src
S
    end

    def docs_labels
      <<-S
** How To Render A Label

~args.outputs.labels~ is used to render labels.

Labels are how you display text. This code will go directly inside of
the ~def tick args~ method.

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

#+begin_src
  def tick args
    args.outputs.labels << {
      x:                       200,
      y:                       550,
      text:                    "dragonruby",
      size_enum:               2,
      alignment_enum:          1,
      r:                       155,
      g:                       50,
      b:                       50,
      a:                       255,
      font:                    "fonts/manaspc.ttf",
      vertical_alignment_enum: 0, # 0 is bottom, 1 is middle, 2 is top
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
      # This string uses Ruby's string interpolation literal: \#{}
      "'some string' has width: \#{w}, and height: \#{h}."
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
      <<-S
** How To Play A Sound

Sounds that end ~.wav~ will play once:

#+begin_src ruby
  def tick args
    # Play a sound every second
    if (args.state.tick_count % 60) == 0
      args.outputs.sounds << 'something.wav'
    end
  end
#+end_src

Sounds that end ~.ogg~ is considered background music and will loop:

#+begin_src ruby
  def tick args
    # Start a sound loop at the beginning of the game
    if args.state.tick_count == 0
      args.outputs.sounds << 'background_music.ogg'
    end
  end
#+end_src

If you want to play a ~.ogg~ once as if it were a sound effect, you can do:

#+begin_src ruby
  def tick args
    # Play a sound every second
    if (args.state.tick_count % 60) == 0
      args.gtk.queue_sound 'some-ogg.ogg'
    end
  end
#+end_src
S
    end

    def docs_game_state
      <<-S
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

    def animate_a_sprite
      <<-S
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
      "sprites/dragon-\#{sprite_index}.png"
    ]
  end
#+end_src
S
    end

    def docs_troubleshooting_performance
<<-S
** Troubleshoot Performance

1. If you're using ~Array~s for your primitives (~args.outputs.sprites << []~), use ~Hash~ instead (~args.outputs.sprites << { x: ... }~).
2. If you're using ~Entity~ for your primitives (~args.outputs.sprites << args.state.new_entity~), use ~StrictEntity~ instead (~args.outputs.sprites << args.state.new_entity_strict~).
3. Use ~.each~ instead of ~.map~ if you don't care about the return value.
4. When concatenating primitives to outputs, do them in bulk. Instead of:
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
5. Use ~args.outputs.static_~ variant for things that don't change often (take a look at the Basic Gorillas sample app and Dueling Starships sample app to see how ~static_~ is leveraged.
6. Consider using a ~render_target~ if you're doing some form of a camera that moves a lot of primitives (take a look at the Render Target sample apps for more info).
S
    end

    def scale_sprites
      <<-S
** How to Scale a Sprite

The ~scale_rect~ method can be used to change the scale of a sprite by a given ~ratio~.

Optionally, you can scale the sprite around a specified anchor point. In the example below, setting both ~anchor_x~ and ~anchor_y~ to 0.5 scales the sprite proportionally on all four sides).

See also: DOCS: GTK::Geometry#scale_rect

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
<<-S
* Frequently Asked Questions, Comments, and Concerns

Here are questions, comments, and concerns that frequently come
up.

** Frequently Asked Questions

*** What is DragonRuby LLP?

DragonRuby LLP is a partnership of four devs who came together
with the goal of bringing the aesthetics and joy of Ruby, everywhere possible.

Under DragonRuby LLP, we offer a number of products (with more on the
way):

- Game Toolkit (GTK): A 2D game engine that is compatible with modern
  gaming platforms.
- RubyMotion (RM): A compiler toolchain that allows you to build native, cross-platform mobile
  apps. [[http://rubymotion.com]]

All of the products above leverage a shared core called DragonRuby.

NOTE: From an official branding standpoint each one of the products is
suffixed with "A DragonRuby LLP Product" tagline. Also, DragonRuby is
_one word, title cased_.

NOTE: We leave the "A DragonRuby LLP Product" off of this one because
that just sounds really weird.

NOTE: Devs who use DragonRuby are "Dragon Riders/Riders of Dragons". That's a bad ass
identifier huh?

*** What is DragonRuby?

The response to this question requires a few subparts. First we need
to clarify some terms. Specifically _language specification_ vs _runtime_.

**** Okay... so what is the difference between a language specification and a runtime?

A runtime is an _implementation_ of a language specification. When
people say "Ruby," they are usually referring to "the Ruby 3.0+ language
specification implemented via the CRuby/MRI Runtime."

But, there are many Ruby Runtimes: CRuby/MRI, JRuby, Truffle, Rubinius, Artichoke,
and (last but certainly not least) DragonRuby.

**** Okay... what language specification does DragonRuby use then?

DragonRuby's goal is to be compliant with the ISO/IEC 30170:2012 standard. It's
syntax is Ruby 2.x compatible, but also contains semantic changes that help
it natively interface with platform specific libraries.

**** So... why another runtime?

The elevator pitch is:

DragonRuby is a Multilevel Cross-platform Runtime. The "multiple levels"
within the runtime allows us to target platforms no other Ruby can
target: PC, Mac, Linux, Raspberry Pi, WASM, iOS, Android, Nintendo
Switch, PS4, Xbox, and Stadia.

**** What does Multilevel Cross-platform mean?

There are complexities associated with targeting all the platforms we
support. Because of this, the runtime had to be architected in such a
way that new platforms could be easily added (which lead to us partitioning the
runtime internally):

- Level 1 we leverage a good portion of mRuby.
- Level 2 consists of optimizations to mRuby we've made given that our
  target platforms are well known.
- Level 3 consists of portable C libraries and their Ruby
  C-Extensions.

Levels 1 through 3 are fairly commonplace in many runtime
implementations (with level 1 being the most portable, and level 3
being the fastest). But the DragonRuby Runtime has taken things a
bit further:

- Level 4 consists of shared abstractions around hardware I/O and operating
  system resources. This level leverages open source and proprietary
  components within Simple DirectMedia Layer (a low level multimedia
  component library that has been in active development for 22 years
  and counting).

- Level 5 is a code generation layer which creates metadata that allows
  for native interoperability with host runtime libraries. It also
  includes OS specific message pump orchestrations.

- Level 6 is a Ahead of Time/Just in Time Ruby compiler built with LLVM. This
  compiler outputs _very_ fast platform specific bitcode, but only
  supports a subset of the Ruby language specification.

These levels allow us to stay up to date with open source
implementations of Ruby; provide fast, native code execution
on proprietary platforms; ensure good separation between these two
worlds; and provides a means to add new platforms without going insane.

**** Cool cool. So given that I understand everything to this point, can we answer the original question? What is DragonRuby?

DragonRuby is a Ruby runtime implementation that takes all the lessons
we've learned from MRI/CRuby, and merges it with the latest and greatest
compiler and OSS technologies.

*** How is DragonRuby different than MRI?

DragonRuby supports a subset of MRI apis. Our target is to support all
of mRuby's standard lib. There are challenges to this given the number
of platforms we are trying to support (specifically console).

**** Does DragonRuby support Gems?

DragonRuby does not support gems because that requires the
installation of MRI Ruby on the developer's machine (which is a
non-starter given that we want DragonRuby to be a zero dependency
runtime). While this seems easy for Mac and Linux, it is much harder
on Windows and Raspberry Pi. mRuby has taken the approach of having a
git repository for compatible gems and we will most likely follow
suite: [[https://github.com/mruby/mgem-list]].

**** Does DragonRuby have a REPL/IRB?

You can use DragonRuby's Console within the game to inspect object and
execute small pieces of code. For more complex pieces of code create a
file called ~repl.rb~ and put it in ~mygame/app/repl.rb~:

- Any code you write in there will be executed when you change the file. You can organize different pieces of code using the ~repl~ method:

#+begin_src ruby
  repl do
    puts "hello world"
    puts 1 + 1
  end
#+end_src

- If you use the `repl` method, the code will be executed and the DragonRuby Console will automatically open so you can see the results (on Mac and Linux, the results will also be printed to the terminal).

- All ~puts~ statements will also be saved to ~logs/puts.txt~. So if you want to stay in your editor and not look at the terminal, or the DragonRuby Console, you can ~tail~ this file.

4. To ignore code in ~repl.rb~, instead of commenting it out, prefix ~repl~ with the letter ~x~ and it'll be ignored.

#+begin_src ruby
  xrepl do # <------- line is prefixed with an "x"
    puts "hello world"
    puts 1 + 1
  end

  # This code will be executed when you save the file.
  repl do
    puts "Hello"
  end

  repl do
    puts "This code will also be executed."
  end

  # use xrepl to "comment out" code
  xrepl do
    puts "This code will not be executed because of the x in front of repl".
  end
#+end_src

**** Does DragonRuby support ~pry~ or have any other debugging facilities?

~pry~ is a gem that assumes you are using the MRI Runtime (which is
incompatible with DragonRuby). Eventually DragonRuby will have a pry
based experience that is compatible with a debugging infrastructure
called LLDB. Take the time to read about LLDB as it shows the
challenges in creating something that is compatible.

You can use DragonRuby's replay capabilities to troubleshoot:

1. DragonRuby is hot loaded which gives you a very fast feedback loop (if the game throws an exception, it's because of the code you just added).
2. Use ~./dragonruby mygame --record~ to create a game play recording that you can use to find the exception (you can replay a recording by executing ~./dragonruby mygame --replay last_replay.txt~ or through the DragonRuby Console using ~$gtk.recording.start_replay "last_replay.txt"~.
3. DragonRuby also ships with a unit testing facility. You can invoke the following command to run a test: ~./dragonruby . --eval some_ruby_file.rb --no-tick~.
4. Get into the habit of adding debugging facilities within the game itself. You can add drawing primitives to ~args.outputs.debug~ that will render on top of your game but will be ignored in a production release.
5. Debugging something that runs at 60fps is (imo) not that helpful. The exception you are seeing could have been because of a change that occurred many frames ago.

** Frequent Comments About Ruby as a Language Choice

*** But Ruby is dead.

Let's check the official source for the answer to this question:
isrubydead.com: [[https://isrubydead.com/]].

On a more serious note, Ruby's _quantity_ levels aren't what they used
to be. And that's totally fine. Everyone chases the new and shiny.

What really matters is _quality/maturity_. Here is the latest (StackOverflow
Survey sorted by highest paid developers)[https://insights.stackoverflow.com/survey/2019#top-paying-technologies].

Let's stop making this comment shall we?

*** But Ruby is slow.

That doesn't make any sense. A language specification can't be
slow... it's a language spec. Sure, an _implementation/runtime_ can be slow though, but then we'd
have to talk about which runtime.

*** Dynamic languages are slow.

They are certainly slower than statically compiled languages. With the
processing power and compiler optimizations we have today,
dynamic languages like Ruby are _fast enough_.

Unless you are writing in some form of intermediate representation by hand,
your language of choice also suffers this same fallacy of slow. Like, nothing is
faster than a low level assembly-like language. So unless you're
writing in that, let's stop making this comment.

NOTE: If you _are_ hand writing LLVM IR, we are always open to
bringing on new partners with such a skill set. Email us ^_^.

** Frequent Concerns

*** DragonRuby is not open source. That's not right.

The current state of open source is unsustainable. Contributors work
for free, most all open source repositories are severely under-staffed,
and burnout from core members is rampant.

We believe in open source very strongly. Parts of DragonRuby are
in fact, open source. Just not all of it (for legal reasons, and
because the IP we've created has value). And we promise that we are
looking for (or creating) ways to _sustainably_ open source everything we do.

If you have ideas on how we can do this, email us!

If the reason above isn't sufficient, then definitely use something else.

All this being said, we do have parts of the engine open sourced on GitHub: [[https://github.com/dragonruby/dragonruby-game-toolkit-contrib/]]

*** DragonRuby is for pay. You should offer a free version.

If you can afford to pay for DragonRuby, you should (and will). We don't go
around telling writers that they should give us their books for free,
and only require payment if we read the entire thing. It's time we stop asking that
of software products.

That being said, we will _never_ put someone out financially. We have
income assistance for anyone that can't afford a license to any one of
our products.

You qualify for a free, unrestricted license to DragonRuby products if
any of the following items pertain to you:

- Your income is below $2,000.00 (USD) per month.
- You are under 18 years of age.
- You are a student of any type: traditional public school, home
  schooling, college, bootcamp, or online.
- You are a teacher, mentor, or parent who wants to teach a kid how to code.
- You work/worked in public service or at a charitable organization:
  for example public office, army, or any 501(c)(3) organization.

Just contact Amir at amir.rajan@dragonruby.org with a short
explanation of your current situation and he'll set you up. No
questions asked.

*** But still, you should offer a free version. So I can try it out and see if I like it.

You can try our web-based sandbox environment at [[http://fiddle.dragonruby.org]]. But it won't do the
runtime justice. Or just come to our Discord Channel at [[http://discord.dragonruby.org]] and ask questions.
We'd be happy to have a one on one video chat with you and show off all the cool stuff we're doing.

Seriously just buy it. Get a refund if you don't like it. We make it stupid easy to do so.

*** I still think you should do a free version. Think of all people who would give it a shot.

Free isn't a sustainable financial model. We don't want to spam your
email. We don't want to collect usage data off of you either. We just
want to provide quality toolchains to quality developers (as opposed
to a large quantity of developers).

The people that pay for DragonRuby and make an effort to understand it are the
ones we want to build a community around, partner with, and collaborate
with. So having that small monetary wall deters entitled individuals
that don't value the same things we do.

*** What if I build something with DragonRuby, but DragonRuby LLP becomes insolvent.

That won't happen if the development world stop asking for free stuff
and non-trivially compensate open source developers. Look, we want to be
able to work on the stuff we love, every day of our lives. And we'll go
to great lengths to make that happen.

But, in the event that sad day comes, our partnership bylaws state that
_all_ DragonRuby IP that can be legally open sourced, will be released
under a permissive license.
S
    end
  end

  class ReadMe
    extend Docs
    extend ReadMeDocs
  end
end
