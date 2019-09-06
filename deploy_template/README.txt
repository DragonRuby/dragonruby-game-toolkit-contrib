Join the Discord: http://discord.dragonruby.org
Community Forums: https://dragonruby.itch.io/dragonruby-gtk/community
Free Training Course: http://dragonruby.school

Welcome!

Here's just a little push to get you started.

If you want to write a game, it's no different than writing any other
program for any other framework: there are a few simple rules that might be
new to you, but more or less programming is programming no matter what you
are building.

Did you not know that? Did you think you couldn't write a game because you're
a "web guy" or you're writing Java at a desk job? Stop letting people tell
you that you can't, because you already have everything you need.

Here, we're going to be programming in a language called "Ruby." In the
interest of full disclosure, I wrote the C parts of this toolkit and Ruby
looks a little strange to me, but I'm going to walk you through the basics
because we're all learning together, and if you mostly think of yourself as
someone that writes C (or C++, C#, Objective-C), PHP, or Java, then you're
only a step behind me right now.

Here's the most important thing you should know: Ruby lets you do some
complicated things really easily, and you can learn that stuff later. I'm
going to show you one or two cool tricks, but that's all.

Do you know what an if statement is? A for-loop? An array? That's all you'll
need to start.

If you don't know how to program, no worries! Watching these two videos will
help tremendously:

- https://s3.amazonaws.com/s3.dragonruby.org/dragonruby-gtk-primer.mp4
- https://s3.amazonaws.com/s3.dragonruby.org/dragonruby-gtk-intermediate.mp4

Did you watch the videos? Great!

Ok, here are few rules with regards to game development with GTK:

- Your game is all going to happen under one function...
- ...that runs 60 times a second...
- ...and has to tell the computer what to draw each time.

That's an entire video game in one run-on sentence.

Here's that function. You're going to want to put this in mygame/app/main.rb,
because that's where we'll look for it by default. Load it up in your favorite
text editor.


def tick args
  args.outputs.labels << [ 580, 400, 'Hello World!' ]
end

Now run "dragonruby" ...did you get a window with "Hello World!" written in
it? Good, you're officially a game developer!

mygame/app/main.rb, is where the Ruby source code is located. This looks a little strange, so
I'll break it down line by line. In Ruby, a '#' character starts a single-line
comment, so I'll talk about this inline.

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

# Once your "tick" function finishes, we look at all the arrays you made and
# figure out how to draw it. You don't need to know about graphics APIs.
# You're just setting up some arrays! DragonRuby clears out these arrays
# every frame, so you just need to add what you need _right now_ each time.

Now let's spice this up a little.

We're going to add some graphics. Each 2D image in DragonRuby is called a
"sprite," and to use them, you just make sure they exist in a reasonable file
format (png, jpg, gif, bmp, etc) and specify them by filename. The first time
you use one, DragonRuby will load it and keep it in video memory for fast
access in the future. If you use a filename that doesn't exist, you get a fun
checkerboard pattern!

There's a "dragonruby.png" file included, just to get you started. Let's have
it draw every frame with our text:

def tick args
  args.outputs.labels << [ 580, 400, 'Hello World!' ]
  args.outputs.sprites << [ 576, 100, 128, 101, 'dragonruby.png' ]
end

(ProTip: you don't have to restart DragonRuby to test your changes; when you
save main.rb, DragonRuby will notice and reload your program.)

That ".sprites" line says "add a sprite to the list of sprites we're drawing,
and draw it at position (576, 100) at a size of 128x101 pixels, and you can
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

def tick args
  args.state.rotation ||= 0
  args.outputs.labels << [ 580, 400, 'Hello World!' ]
  args.outputs.sprites << [ 576, 100, 128, 101, 'dragonruby.png', args.state.rotation ]
  args.state.rotation -= 1
end

Now you can see that this function is getting called a lot!

Here's a fun Ruby thing: "args.state.rotation ||= 0" is shorthand for "if
args.state.rotation isn't initialized, set it to zero." It's a nice way to
embed your initialization code right next to where you need the variable.

args.state is a place you can hang your own data and have it survive past the
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

Everywhere you click your mouse, the image moves there. We set a default
location for it with args.state.x ||= 576, and then we change those variables
when we see the mouse button in action. You can get at the keyboard and game
controllers in similar ways.

There is a lot more you can do with DragonRuby, but now you've already got
just about everything you need to make a simple game. After all, even the
most fancy games are just creating objects and moving them around. Experiment
a little. Add a few more things and have them interact in small ways. Want
something to go away? Just don't add it to args.output anymore.

If you want to get a good idea of what's available to you, please check out
the "samples" directory: in there, the "tech_demo" directory is a good dumping
ground of features, and many of the others are little starter games. Just
go to the samples directory, find the sample you want to run, and double click
"dragonruby" within the sample folder.

There is also a lot more you _can't_ do with DragonRuby, at least not yet.
We are excited about the potential of this, so we wanted to get it in your
hands right away. We intend to add a bunch of features and we would love
feedback on what needs work and what you want that isn't there.

But now, it's time to show your friends and family that you're a real game
developer! Let's package up what we have and let them play it!

Let's just give it a few bits of information. Point your text editor at
mygame/metadata/game_metadata.txt and make it look like this:

devid=bob
devtitle=Bob The Game Developer
gameid=mygame
gametitle=My Game
version=0.1

(obviously you should change it if your name isn't Bob.)

See that other program? dragonruby-publish? Let's use that to package up your
game. Run this from the command line:

./dragonruby-publish --only-package mygame

(if you're on Windows, don't put the "./" on the front. That's a Mac and
Linux thing.)

This should spit out packaged versions of your game for Windows, Linux and
macOS that you can hand out to friends and family however you like. They
just have to download and double-click it!

But if you want to get _really_ fancy: Set up a free account on
https://itch.io/, with the same login as you specified for "devid" in
game_metadata.txt, and a product with the gameid. Set a price for it. And
then run...

./dragonruby-publish mygame

...and DragonRuby will package _and publish_ your game to itch.io! Tell your
friends to go to your game's very own webpage and buy it!

If you make changes to your game, just re-run dragonruby-publish and it'll
update the downloads for you.

And that's all! We hope you find DragonRuby useful, and more importantly we
hope you have fun playing around with it. Please check out
https://dragonruby.itch.io/dragonruby-gtk as we add new features and improve
this toolkit based on your feedback!

BORING LEGAL STUFF AND CREDIT WHERE CREDIT IS DUE:
(if you don't read software licenses, you're done with this README now. IT IS
STRONGLY RECOMMENDED THAT YOU GO THROUGH ALL THE SAMPLE APPS!!)

DragonRuby uses the following open source libraries!

- mRuby: https://mruby.org/

Copyright (c) 2019 mruby developers

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.


- Simple Directmedia Layer: https://www.libsdl.org/

Simple DirectMedia Layer
Copyright (C) 1997-2019 Sam Lantinga <slouken@libsdl.org>

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.


- stb_vorbis, stb_image, stb_truetype: https://github.com/nothings/stb/

This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


- lodepng: https://lodev.org/lodepng/

Copyright (c) 2005-2018 Lode Vandevenne

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

    3. This notice may not be removed or altered from any source
    distribution.


- miniz: https://github.com/richgel999/miniz

Copyright 2013-2014 RAD Game Tools and Valve Software
Copyright 2010-2014 Rich Geldreich and Tenacious Software LLC

All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


- MojoAL: https://hg.icculus.org/icculus/mojoAL/

   Copyright (c) 2018 Ryan C. Gordon and others.

   This software is provided 'as-is', without any express or implied warranty.
   In no event will the authors be held liable for any damages arising from
   the use of this software.

   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software in a
   product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source distribution.

       Ryan C. Gordon <icculus@icculus.org>


- PhysicsFS: https://icculus.org/physfs/

   Copyright (c) 2001-2019 Ryan C. Gordon and others.

   This software is provided 'as-is', without any express or implied warranty.
   In no event will the authors be held liable for any damages arising from
   the use of this software.

   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software in a
   product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source distribution.

       Ryan C. Gordon <icculus@icculus.org>
