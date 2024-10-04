# Deploying To Itch.io

Once you've built your game, you're all set to deploy! Good luck in
your game dev journey and if you get stuck, come to the Discord
channel!

## Creating Your Game Landing Page

Log into Itch.io and go to <https://itch.io/game/new>.

-   Title: Give your game a Title. This value represents your \`gametitle\`.
-   Project URL: Set your project url. This value represents your \`gameid\`.
-   Classification: Keep this as Game.
-   Kind of Project: Select HTML from the drop down list. Don't worry,
    the HTML project type <span class="underline">also supports binary downloads</span>.
-   Uploads: Skip this section for now.

You can fill out all the other options later.

## Update Your Game's Metadata

Point your text editor at `mygame/metadata/game_metadata.txt` and
make it look like this:

NOTE: Remove the `#` at the beginning of each line.

```txt
devid=bob
devtitle=Bob The Game Developer
gameid=mygame
gametitle=My Game
version=0.1
```

The `devid` property is the username you use to log into Itch.io.
The `devtitle` is your name or company name (it can contain spaces).
The `gameid` is the Project URL value.
The `gametitle` is the name of your game (it can contain spaces).
The `version` can be any `major.minor` number format.

## Building Your Game For Distribution

Open up the terminal and run this from the command line:

```sh
./dragonruby-publish --package mygame
```

!> If you're on Windows, don't put the "./" on the front. That's a Mac and
Linux thing.

A directory called `./build` will be created that contains your
binaries. You can upload this to Itch.io manually.

### Browser Game Settings

For the HTML version of your game, the following configuration is required for your game to run correctly:

-   Check the checkbox labeled `This file will be played in the browser` for the html version of your game (it's one of the zip files you'll upload).
-   Ensure that `Embed options -> SharedArrayBuffer support` is checked.
-   Be sure to set the `Viewport dimensions` to `1280x720` for landscape games or your game will not be positioned correctly on your Itch.io page.
-   Be sure to set the `Viewport dimensions` to `540x960` for portrait games or your game will not be positioned correctly on your Itch.io page.

For subsequent updates you can use an automated deployment to Itch.io:

```sh
./dragonruby-publish mygame
```

DragonRuby will package <span class="underline">and publish</span> your game to itch.io! Tell your
friends to go to your game's very own webpage and buy it!

If you make changes to your game, just re-run dragonruby-publish and it'll
update the downloads for you.

### Consider Adding Pause When Game is In Background

It's a good idea to pause the game if it doesn't have focus. Here's an example of how to do that

```ruby
def tick args
  # if the keyboard doesn't have focus, and the game is in production mode, and it isn't the first tick
  if (!args.inputs.keyboard.has_focus &&
      args.gtk.production &&
      Kernel.tick_count != 0)
    args.outputs.background_color = [0, 0, 0]
    args.outputs.labels << { x: 640,
                             y: 360,
                             text: "Game Paused (click to resume).",
                             alignment_enum: 1,
                             r: 255, g: 255, b: 255 }
    # consider setting all audio volume to 0.0
  else
    # perform your regular tick function
  end
end
```

If you want your game to run at full speed even when it's in the background, add the following line to `mygame/metadata/cvars.txt`:

    renderer.background_sleep=0

### Consider Adding a Request to Review Your Game In-Game

Getting reviews of your game are extremely important and it's recommended that you put an option to review
within the game itself. You can use `args.gtk.open_url` plus a review URL. Here's an example:
```ruby
def tick args
  # render the review button
  args.state.review_button ||= { x:    640 - 50,
                                 y:    360 - 25,
                                 w:    100,
                                 h:    50,
                                 path: :pixel,
                                 r:    0,
                                 g:    0,
                                 b:    0 }
  args.outputs.sprites << args.state.review_button
  args.outputs.labels << { x: 640,
                           y: 360,
                           anchor_x: 0.5,
                           anchor_y: 0.5,
                           text: "Review" }

  # check to see if the review button was clicked
  if args.inputs.mouse.intersect_rect? args.state.review_button
    # open platform specific review urls
    if args.gtk.platform? :ios
      # your app id is provided at Apple's Developer Portal (numeric value)
      args.gtk.openurl "itms-apps://itunes.apple.com/app/idYOURGAMEID?action=write-review"
    elsif args.gtk.platform? :android
      # your app id is the name of your android package
      args.gtk.openurl "https://play.google.com/store/apps/details?id=YOURGAMEID"
    elsif args.gtk.platform? :web
      # if they are playing the web version of the game, take them to the purchase page on itch
      args.gtk.openurl "https://amirrajan.itch.io/YOURGAMEID/purchase"
    else
      # if they are playing the desktop version of the game, take them to itch's rating page
      args.gtk.openurl "https://amirrajan.itch.io/YOURGAMEID/rate?source=game"
    end
  end
end
```
