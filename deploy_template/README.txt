* Introduction

  Hello world! Do the things in this README file and you'll be well on your way to
  building video games!

* Join the community!

  Those who use DragonRuby are called Dragon Riders. This identity is
  incredibly important to us. When someone asks you:

  > What game engine do you use?

  You can proudly reply with:

  > I am a Dragon Rider.

** Subscribe to the News Letter

   The News Letter will keep you in the loop with regards to
   http://dragonrubydispatch.com/

** Join the Discord

   Amir (one of the creators of DragonRuby) is always available to help
   you out. So take the time to join the community Discord. The invite linke is located at:

   DragonRuby Discord: http://discord.dragonruby.org

** Introduce Yourself on the Forums

   Take a moment to introducing yourself on the community forum:

   Stickied Community Post: https://itch.io/t/526689/dragonruby-gtk-discord-server-created-join-it-dammit

   This provides community members a registry of everyone using
   DragonRuby. Itch.io holds a lot of game jams, and it'd be awesome if
   Dragon Riders had a central place to find each other.

* Determine how you want to start learning based on your experience level!

  Follows are sections pertaining to your experience level as a
  programer and experience level with coding in a dynamic language.

** If you have zero experience with programming.

   If you have no programing experience at all. You'll want to take the
   time to see what DragonRuby is like before jumping in to code. Watch
   the following videos in order (each one is only ~20 minutes long).

   Don't attempt to code anything shown in the video yet, just watch them to
   get familiar with the language and how games are built.

   1. Beginner Introduction to Ruby: https://www.youtube.com/watch?v=ixw7TJhU08E
   2. Intermediate Introduction to Ruby Syntax: https://www.youtube.com/watch?v=HG-XRZ5Ppgc
   3. Intermediate Introduction to Arrays in Ruby: https://www.youtube.com/watch?v=N72sEYFRqfo

   Once you have watched all the videos. Then (and only then) go back
   through the videos and follow along. Here are the locations for the
   samples:

   1. Beginner Introduction to Ruby: samples/00_beginner_ruby_primer
   2. Intermediate Tutorials: samples/00_intermediate_ruby_primer

** If you do not know Ruby, but have experience with C# (Unity) or GML (GameMaker)

   Those engines rot your brain. Forget the concepts that the forced you
   to learn. Game development is so much simpler than what they make you
   do. Please, try your best to set aside the concepts those engines
   teach (we promise our approach to game development is much much easier).

   Watch these videos to get familiar with the Ruby language and
   programming environment (they are ~20 min each so it'll be quick):

   1. Beginner Introduction to Ruby: https://www.youtube.com/watch?v=ixw7TJhU08E
   2. Intermediate Introduction to Ruby Syntax: https://www.youtube.com/watch?v=HG-XRZ5Ppgc
   3. Intermediate Introduction to Arrays in Ruby: https://www.youtube.com/watch?v=N72sEYFRqfo

   You may also want to try this free course provided at http://dragonruby.school.

   After you've watch the videos, you'll be ready to go to the next section.

** You are a dev that is familiar with a dynamically typed language (Ruby, Lua, Python, or JavaScript).

*** STEP 1: Work through this Hello World tutorial

    This tutorial is provided by Ryan C Gordon (check out his wikipedia
    page). We call him "The Juggernaut":

    Welcome!

    Here's just a little push to get you started if you're new to programming or
    game development.

    If you want to write a game, it's no different than writing any other
    program for any other framework: there are a few simple rules that might be
    new to you, but more or less programming is programming no matter what you
    are building.

    Did you not know that? Did you think you couldn't write a game because you're
    a "web guy" or you're writing Java at a desk job? Stop letting people tell
    you that you can't, because you already have everything you need.

    Here, we're going to be programming in a language called "Ruby." In the
    interest of full disclosure, I (Ryan "The Juggernaut" Gordon) wrote the C
    parts of this toolkit and Ruby looks a little strange to me (Amir Rajan wrote the
    Ruby parts), but I'm going to walk you through the basics because we're all
    learning together, and if you mostly think of yourself as someone that writes
    C (or C++, C#, Objective-C), PHP, or Java, then you're only a step behind me right now.

    Here's the most important thing you should know: Ruby lets you do some
    complicated things really easily, and you can learn that stuff later. I'm
    going to show you one or two cool tricks, but that's all.

    Do you know what an if statement is? A for-loop? An array? That's all you'll
    need to start.

    Ok, here are few rules with regards to game development with GTK:

    - Your game is all going to happen under one function...
    - ...that runs 60 times a second...
    - ...and has to tell the computer what to draw each time.

    That's an entire video game in one run-on sentence.

    Here's that function. You're going to want to put this in mygame/app/main.rb,
    because that's where we'll look for it by default. Load it up in your favorite
    text editor.

    #+begin_src ruby
      def tick args
        args.outputs.labels << [ 580, 400, 'Hello World!' ]
      end
    #+end_src

    Now run `dragonruby` ...did you get a window with "Hello World!" written in
    it? Good, you're officially a game developer!

    `mygame/app/main.rb`, is where the Ruby source code is located. This looks a little strange, so
    I'll break it down line by line. In Ruby, a '#' character starts a single-line
    comment, so I'll talk about this inline.

    #+begin_src ruby

      # This "def"ines a function, named "tick," which takes a single argument
      #  named "args". DragonRuby looks for this function and calls it every
      #  frame, 60 times a second. "args" is a magic structure with lots of
      #  information in it. You can set variables in there for your own game state,
      #  and every frame it will updated if keys are pressed, joysticks moved,
      #  mice clicked, etc.
      def tick args

        # One of the things in "args" is the "outputs" object that your game uses
        #  to draw things. Afraid of rendering APIs? No problem. In DragonRuby,
        #  you use arrays to draw things and we figure out the details.
        #  If you want to draw text on the screen, you give it an array (the thing
        #  in the [ brackets ]), with an X and Y coordinate and the text to draw.
        #  The "<<" thing says "append this array onto the list of them at
        #  args.outputs.labels)
        args.outputs.labels << [ 580, 400, 'Hello World!' ]
      end

    #+end_src

    Once your `tick` function finishes, we look at all the arrays you made and
    figure out how to draw it. You don't need to know about graphics APIs.
    You're just setting up some arrays! DragonRuby clears out these arrays
    every frame, so you just need to add what you need _right now_ each time.

    Now let's spice this up a little.

    We're going to add some graphics. Each 2D image in DragonRuby is called a
    "sprite," and to use them, you just make sure they exist in a reasonable file
    format (png, jpg, gif, bmp, etc) and specify them by filename. The first time
    you use one, DragonRuby will load it and keep it in video memory for fast
    access in the future. If you use a filename that doesn't exist, you get a fun
    checkerboard pattern!

    There's a "dragonruby.png" file included, just to get you started. Let's have
    it draw every frame with our text:

    #+begin_src ruby

      def tick args
        args.outputs.labels << [ 580, 400, 'Hello World!' ]
        args.outputs.sprites << [ 576, 100, 128, 101, 'dragonruby.png' ]
      end

    #+end_src

    (ProTip: you don't have to restart DragonRuby to test your changes; when you
    save main.rb, DragonRuby will notice and reload your program.)

    That `.sprites` line says "add a sprite to the list of sprites we're drawing,
    and draw it at position (576, 100) at a size of 128x101 pixels". You can
    find the image to draw at dragonruby.png.

    Quick note about coordinates: (0, 0) is the bottom left corner of the screen,
    and positive numbers go up and to the right. This is more "geometrically
    correct," even if it's not how you remember doing 2D graphics, but we chose
    this for a simpler reason: when you're making Super Mario Brothers and you
    want Mario to jump, you should be able to add to Mario's y position as he
    goes up and subtract as he falls. It makes things easier to understand.

    Also: your game screen is _always_ 1280x720 pixels. If you resize the window,
    we will scale and letterbox everything appropriately, so you never have to
    worry about different resolutions.

    Ok, now we have an image on the screen, let's animate it:

    #+begin_src ruby

      def tick args
        args.state.rotation ||= 0
        args.outputs.labels << [ 580, 400, 'Hello World!' ]
        args.outputs.sprites << [ 576, 100, 128, 101, 'dragonruby.png', args.state.rotation ]
        args.state.rotation -= 1
      end

    #+end_src

    Now you can see that this function is getting called a lot!

    Here's a fun Ruby thing: `args.state.rotation ||= 0` is shorthand for "if
    args.state.rotation isn't initialized, set it to zero." It's a nice way to
    embed your initialization code right next to where you need the variable.

    `args.state` is a place you can hang your own data and have it survive past the
    life of the function call. In this case, the current rotation of our sprite,
    which is happily spinning at 60 frames per second. If you don't specify
    rotation (or alpha, or color modulation, or a source rectangle, etc),
    DragonRuby picks a reasonable default, and the array is ordered by the most
    likely things you need to tell us: position, size, name.

    One thing we decided to do in DragonRuby is not make you worry about delta
    time: your function runs at 60 frames per second (about 16 milliseconds) and
    that's that. Having to worry about framerate is something massive triple-AAA
    games do, but for fun little 2D games? You'd have to work really hard to not
    hit 60fps. All your drawing is happening on a GPU designed to run Fortnite
    quickly; it can definitely handle this.

    Since we didn't make you worry about delta time, you can just move the
    rotation by 1 every time and it works without you having to keep track of
    time and math. Want it to move faster? Subtract 2.

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

        args.outputs.labels << [ 580, 400, 'Hello World!' ]
        args.outputs.sprites << [ args.state.x, args.state.y, 128, 101, 'dragonruby.png', args.state.rotation ]

        args.state.rotation -= 1
      end

    #+end_src

    Everywhere you click your mouse, the image moves there. We set a default
    location for it with args.state.x ||= 576, and then we change those variables
    when we see the mouse button in action. You can get at the keyboard and game
    controllers in similar ways.

    There is a lot more you can do with DragonRuby, but now you've already got
    just about everything you need to make a simple game. After all, even the
    most fancy games are just creating objects and moving them around. Experiment
    a little. Add a few more things and have them interact in small ways. Want
    something to go away? Just don't add it to args.output anymore.

*** STEP 2: Read the CHEATSHEET.txt

    Go to the file CHEATSHEET.txt and skim through it quickly to get a
    feel for some of the other APIs you have access to. If you need even
    more details you'll find them at `mygame/documentation`.

*** STEP 3: Run each sample app in order and read the code.

    The sample apps located in the `sample` directory are ordered by
    increasing complexity. Run each one of them and read through the
    code. Play around by changing values and see how they change the game.

*** STEP 4: Editor integration.

    There is a file called `vim-ctags` and `emacs-ctags`. The data in
    these files are standard output provided by Exuberent CTAGS. Most
    editors have a "ctags plugin" so just search for that plugin for your
    editor and point it to these files.

*** STEP 5: Get in the habit of reading the CHANGELOG

    We are constantly adding new features to the engine. Be sure to read
    the changelog with every release.

* How to publish your game.

  Once you've built your game, you're all set to deploy! Good luck in
  your game dev journey and if you get stuck, come to the Discord
  channel!

** STEP 1: Create a new Game in Itch.io.

   Log into Itch.io and go to https://itch.io/game/new.

   - Title: Give your game a Title. This value represents your `gametitle`.
   - Project URL: Set your project url. This value represents your `gameid`.
   - Classification: Keep this as Game.
   - Kind of Project: Select HTML from the drop down list. Dont worry,
     the HTML project type _aslo supports binary downloads_.
   - Uploads: Skip this section for now.
   - Embed Options: Set the dropdown value to "Click to launch in fullscreen".
     DO NOT use the Embed in page option. iFrames are not reliable with
     regards to capturing input.

   You can fill out all the other options later.

** STEP 2: Go to mygame/metadata/metadata.txt and update it.

   Point your text editor at mygame/metadata/game_metadata.txt and
   make it look like this: (Remove the `#` at the beginning of each line).

   #+begin_src text
   devid=bob
   devtitle=Bob The Game Developer
   gameid=mygame
   gametitle=My Game
   version=0.1
   #+end_src

   The `devid` property is the username you use to log into Itch.io.
   The `devtitle` is your name or company name (it can contain spaces).
   The `gameid` is the Project URL value (see details in STEP 1).
   The `gametitle` is the name of your game (it can contain spaces).
   The `version` can be any `major.minor` number format.

** STEP 3: Build your game for distribution.

   Open up the terminal and run this from the command line:

   #+begin_src sh
     ./dragonruby-publish --only-package mygame
   #+end_src

   (if you're on Windows, don't put the "./" on the front. That's a Mac and
   Linux thing.)

   A directory called `./build` will be created that contains your
   binaries. You can upload this to Itch.io manually. For the HTML
   version of your game after you upload it. Check the checkbox labeled
   "This file will be played in the browser".

   For subsequent updates you can use an automated deployment to Itch.io:

   #+begin_src sh
     ./dragonruby-publish mygame
   #+end_src

   DragonRuby will package _and publish_ your game to itch.io! Tell your
   friends to go to your game's very own webpage and buy it!

   If you make changes to your game, just re-run dragonruby-publish and it'll
   update the downloads for you.
