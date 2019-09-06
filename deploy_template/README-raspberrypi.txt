We have only tested DragonRuby on a Raspberry Pi 3, Models B and B+, but we
believe it _should_ work on any model, including the Pi Zero.

If you're running DragonRuby Game Toolkit on a Raspberry Pi, or trying to run
a game made with the Toolkit on a Raspberry Pi, and it's really really slow--
like one frame every few seconds--then there's likely a simple fix.

You're proabably running a desktop environment: menus, apps, web browsers,
etc. This is okay! Launch the terminal app and type:

    sudo raspi-config

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

If you have questions or problems, please let us know! You can find us on
the forums at https://dragonruby.itch.io/dragonruby-gtk or our Discord channel
at https://discord.dragonruby.org/ ...

