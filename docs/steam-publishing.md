# Steam Publishing Quickstart

This documentation is going to improve, hopefully, since there are a million
steps to manage on the Steamworks partner site if you are starting from 
scratch, but here's the barest walkthrough of publishing to Steam possible.

Note that Steam publishing requires an Indie or Pro license of DragonRuby
game toolkit, and can be done from Linux/amd64, Windows, or macOS. Other
platforms that support dragonruby-publish, like the Raspberry Pi build, do
not support Steam publishing, because Valve does not make their tools
available for those platforms at the moment.

## Setting up the game on the Partner Site.

You only have to do this part once when first setting up your game.

- Create a product on Steam. This has a million steps, including paying a
  fee. Valve offers pretty robust documentation on all this, though.
  Eventually, you'll have an App ID for your game.

- Go to https://partner.steamgames.com/apps/view/$APPID, where $APPID
  is your game's App ID.

- Find the "Supported Operating Systems" section and make sure these things
  are checked:

  * Windows
  * * 64 Bit Only
  * macOS
  * * 64 Bit (Intel) Binaries Included
  * * Apple Silicon Binaries Included
  * Linux + SteamOS

- Click the "Save" button below it.

- Click the "SteamPipe" tab at the top of the page, click on "depots"

- If there's already a default depot listed, remove it.

- Click the "Add a new depot" button. Give it a name like "My Game Name
  Linux Depot" and take whatever depot ID it offers you.

- You'll see this new depot is listed on the page now. Fix its settings:

  * Language: All Languages
  * For DLC: Base App
  * Operating System: Linux + SteamOS
  * Architecture: 64-bit OS only
  * Platform: All

- Do this again, make a "My Game Name Windows Depot", set it to the same
  things, except "Operating System," which should be "Windows," of course.

- Do this again, make a "My Game Name Mac Depot", set it to the same
  things, except "Operating System," which should be "macOS," of course.

- Push the big green "Save" button on the page. Now we have a place to
  upload platform-specific builds of your game.

- Click on the "Installation" tab near the top of the page, then
  "General Installation".

- Under "Launch Options," click the "Add new launch option" button, edit
  the new section that just popped up, and set it like this:

  (Whenever you see "mygamename" in here, this should be whatever your
  game_metadata's "gameid" value is set to. If you see "My Game Name", it's
  whatever your game_metadata's "gametitle" value is set to, but you'll have
  to check in case we mangled it to work as a filename.)

  * Executable: mygamename.exe
  * Launch Type: Launch (Default)
  * Operating System: Windows
  * CPU Architecture: 64-bit only
  * Everything else can be default/blank.

- Click the "Update" button on that section.

- Add another launch option, as before:

  * Executable: My Game Name.app
  * Launch Type: Launch (Default)
  * Operating System: macOS

- Add another launch option, as before:

  * Executable: mygamename
  * Launch Type: Launch (Default)
  * Operating System: Linux + SteamOS
  * CPU Architecture: 64-bit only

- Go to the "Publish" tab at near the top of the page. Click the "View Diffs"
  button and make sure it looks sane (it should just be the things we've
  changed in here), then click "Prepare for Publishing", then
  "Publish to Steam" and follow the instructions to publish these changes.

- Go to https://partner.steamgames.com/apps/associated/$APPID
  For each package, make sure all three depots are included.

- Again, there are a million more things to configure on the Partner site
  for the game and the store page, this is just what you need to make
  dragonruby-publish work.


## Setting up dragonruby-publish.

You only have to do this part once when first setting up your game.

- Go add a text file to your game's "metadata" directory called
  "steam_metadata.txt" ... note that this file will be filtered out
  when dragonruby-publish packages the game and will not be distributed
  with the published game.

      steam.publish=true
      steam.username=AAA
      steam.appid=BBB
      steam.linux_depotid=CCC
      steam.windows_depotid=DDD
      steam.mac_depotid=EEE

  If steam.publish is set to "false" than dragonruby-publish will not
  attempt to upload to Steam. "false" is the default if this file, or
  this setting, is missing.

  Where "AAA" is the login name on the Steamworks Partner Site to use for
  publishing builds, "BBB" is your game-specific AppID provided by Steam,
  "CCC", "DDD", and "EEE" are the DepotIDs you created for Linux, Windows,
  and macOS builds, respectively.

  Save this file. You're ready.


## Publishing a build.

- Run dragonuby-publish as you normally would. When it is time to publish
  to Steam, it will set up any tools it needs, attempt to log you into Steam,
  and upload the latest version of your game.

- Steam login is handled by Valve's "steamcmd" command line program, not
  dragonruby-publish. DragonRuby does not ever have access to your login
  credentials. You may need to take steps to get an authorization token in
  place if necessary, so you don't have to deal with Steam Guard in automated
  build processes (documentation on how to do this is forthcoming, or read
  Valve's SteamCMD manual for details).

- You (currently) have to set the new build live on the partner site before
  users will receive it. Optionally automating this step is coming soon!


## Setting a branch live.

Once your build is uploaded, you can assign it to a specific branch through
the interface on the Partner site. You can make arbitrary branches here, like
"beta" or "nightly" or "fixing-weird-bug" or whatever. The one that goes to
the end users without them switching branches, is "default" and you should
assume this is where paying customers live, so be careful before you set a
build live there.

You can have dragonruby-publish set the builds it publishes live on a branch
immediately, if you prefer. Simply add...

    steam.branch=XXX

...to steam_metadata.txt, where "XXX" is the branch name from the partner
website. If this is blank or unspecified, it will _not_ set the build live on
_any_ branch.

A reasonable strategy is to create a (possibly passworded) branch called
"staging" and have dragonruby-publish always push to there automatically.
Then you can test from a Steam install, pushing as often as you like, and
when you are satisfied, manually set the latest build live on default for
the general public to download.

If you are feeling brave, you can always just set all published builds live
on default, too. After all, if you break it, you can always just push a fix
right away.  :)   (or use the Partner Site to roll back to a known-good build,
you know.)


## Questions?

You probably have several.

These are early times, so things will go wrong and we're still improving the
code and documentation. Please come visit the Discord and ask questions, and
we'll do our best to help, and update this information with your feedback!

