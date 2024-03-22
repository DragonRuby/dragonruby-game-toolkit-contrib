# Getting Started

This is a tutorial written by Ryan C Gordon (a Juggernaut in the industry who has contracted to Valve,
Epic, Activision, and EA... check out his Wikipedia page: https://en.wikipedia.org/wiki/Ryan_C._Gordon).

## Introduction

Welcome!

Here's just a little push to get you started if you're new to programming or game development.

If you want to write a game, it's no different than writing any other program for any other framework: there are a few simple rules that might be new to you, but more or less programming is programming no matter what you are building.

Did you not know that? Did you think you couldn't write a game because you're a "web guy" or you're writing Java at a desk job? Stop letting people tell you that you can't, because you already have everything you need.

Here, we're going to be programming in a language called "Ruby." In the interest of full disclosure, I (Ryan Gordon) wrote the C parts of this toolkit and Ruby looks a little strange to me (Amir Rajan wrote the Ruby parts, discounting the parts I mangled), but I'm going to walk you through the basics because we're all learning together, and if you mostly think of yourself as someone that writes C (or C++, C#, Objective-C), PHP, or Java, then you're only a step behind me right now.

## Prerequisites

Here's the most important thing you should know: Ruby lets you do some complicated things really easily, and you can learn that stuff later. I'm going to show you one or two cool tricks, but that's all.

Do you know what an if statement is? A for-loop? An array? That's all you'll need to start.

## The Game Loop

Ok, here are few rules with regards to game development with GTK:

* Your game is all going to happen under one function ...
* that runs 60 times a second ...
* and has to tell the computer what to draw each time.

That's an entire video game in one run-on sentence.

Here's that function. You're going to want to put this in mygame/app/main.rb, because that's where we'll look for it by default. Load it up in your favorite text editor.

```ruby
def tick args
  args.outputs.labels << [580, 400, 'Hello World!']
end
```

Now run dragonruby ...did you get a window with "Hello World!" written in it? Good, you're officially a game developer!

## Breakdown Of The tick Method

`mygame/app/main.rb`, is where the Ruby source code is located. This looks a little strange, so I'll break it down line by line. In Ruby, a '#' character starts a single-line comment, so I'll talk about this inline.

```ruby
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
```

Once your `tick` function finishes, we look at all the arrays you made and figure out how to draw it. You don't need to know about graphics APIs. You're just setting up some arrays! DragonRuby clears out these arrays every frame, so you just need to add what you need _right now_ each time.

## Rendering A Sprite

Now let's spice this up a little.

We're going to add some graphics. Each 2D image in DragonRuby is called a "sprite," and to use them, you just make sure they exist in a reasonable file format (png, jpg, gif, bmp, etc) and specify them by filename. The first time you use one, DragonRuby will load it and keep it in video memory for fast access in the future. If you use a filename that doesn't exist, you get a fun checkerboard pattern!

There's a "dragonruby.png" file included, just to get you started. Let's have it draw every frame with our text:

```ruby
def tick args
  args.outputs.labels  << [580, 400, 'Hello World!']
  args.outputs.sprites << [576, 100, 128, 101, 'dragonruby.png']
end
```

!> Pro Tip: you don't have to restart DragonRuby to test your changes; when you save main.rb, DragonRuby will notice and reload your program.

That `.sprites` line says "add a sprite to the list of sprites we're drawing, and draw it at position (576, 100) at a size of 128x101 pixels". You can find the image to draw at dragonruby.png.

## Coordinate System and Virtual Canvas

Quick note about coordinates: (0, 0) is the bottom left corner of the screen, and positive numbers go up and to the right. This is more "geometrically correct," even if it's not how you remember doing 2D graphics, but we chose this for a simpler reason: when you're making Super Mario Brothers and you want Mario to jump, you should be able to add to Mario's y position as he goes up and subtract as he falls. It makes things easier to understand.

Also: your game screen is _always_ 1280x720 pixels. If you resize the window, we will scale and letterbox everything appropriately, so you never have to worry about different resolutions.

Ok, now we have an image on the screen, let's animate it:

```ruby
def tick args
  args.state.rotation  ||= 0
  args.outputs.labels  << [580, 400, 'Hello World!' ]
  args.outputs.sprites << [576, 100, 128, 101, 'dragonruby.png', args.state.rotation]
  args.state.rotation  -= 1
end
```

Now you can see that this function is getting called a lot!

## Game State

Here's a fun Ruby thing: `args.state.rotation ||= 0` is shorthand for "if args.state.rotation isn't initialized, set it to zero." It's a nice way to embed your initialization code right next to where you need the variable.

`args.state` is a place you can hang your own data. It's an open data structure that allows you to define properties that are arbitrarily nested. You don't need to define any kind of class.

In this case, the current rotation of our sprite, which is happily spinning at 60 frames per second. If you don't specify rotation (or alpha, or color modulation, or a source rectangle, etc), DragonRuby picks a reasonable default, and the array is ordered by the most likely things you need to tell us: position, size, name.

## There Is No Delta Time

One thing we decided to do in DragonRuby is not make you worry about delta time: your function runs at 60 frames per second (about 16 milliseconds) and that's that. Having to worry about framerate is something massive triple-AAA games do, but for fun little 2D games? You'd have to work really hard to not hit 60fps. All your drawing is happening on a GPU designed to run Fortnite quickly; it can definitely handle this.

Since we didn't make you worry about delta time, you can just move the rotation by 1 every time and it works without you having to keep track of time and math. Want it to move faster? Subtract 2.

## Handling User Input

Now, let's move that image around.

```ruby
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
```

Everywhere you click your mouse, the image moves there. We set a default location for it with `args.state.x ||= 576`, and then we change those variables when we see the mouse button in action. You can get at the keyboard and game controllers in similar ways.

## Coding On A Raspberry Pi

We have only tested DragonRuby on a Raspberry Pi 3, Models B and B+, but we believe it _should_ work on any model with comparable specs.

If you're running DragonRuby Game Toolkit on a Raspberry Pi, or trying to run a game made with the Toolkit on a Raspberry Pi, and it's really really slow-- like one frame every few seconds--then there's likely a simple fix.

You're probably running a desktop environment: menus, apps, web browsers, etc. This is okay! Launch the terminal app and type:

```bash
do raspi-config
```

It'll ask you for your password (if you don't know, try "raspberry"), and then give you a menu of options. Find your way to "Advanced Options", then "GL Driver", and change this to "GL (Full KMS)" ... not "fake KMS," which is also listed there. Save and reboot. In theory, this should fix the problem.

If you're _still_ having problems and have a Raspberry Pi 2 or better, go back to raspi-config and head over to "Advanced Options", "Memory split," and give the GPU 256 megabytes. You might be able to avoid this for simple games, as this takes RAM away from the system and reserves it for graphics. You can also try 128 megabytes as a gentler option.

Note that you can also run DragonRuby without X11 at all: if you run it from a virtual terminal it will render fullscreen and won't need the "Full KMS" option. This might be attractive if you want to use it as a game console sort of thing, or develop over ssh, or launch it from RetroPie, etc.

## Conclusion

There is a lot more you can do with DragonRuby, but now you've already got just about everything you need to make a simple game. After all, even the most fancy games are just creating objects and moving them around. Experiment a little. Add a few more things and have them interact in small ways. Want something to go away? Just don't add it to `args.output` anymore.
