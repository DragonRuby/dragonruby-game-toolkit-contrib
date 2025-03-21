# Deploying To Steam

!> It's strongly recommended that you do NOT keep DragonRuby Game Toolkit in a shared location and
instead unzip a clean copy for every game (and commit everything to source control). <br/> <br/>
File access functions are sandoxed and assume that the `dragonruby` binary lives alongside
the game you are building. Do not expect file access functions to return correct values if you are attempting
to run the `dragonruby` binary from a shared location. It's recommended that the directory
structure contained in the zip is not altered and games are built using that starting directory structure.

If you have a Indie or Pro subscription, you also get streamlined deployment
to Steam via `dragonruby-publish`. Please note that games developed using the
Standard license can deploy to Steam using the Steamworks toolchain <https://partner.steamgames.com/doc/store/releasing>.

## Testing on Your Steam Deck

### Easy Setup

1.  Run `dragonruby-publish --only-package`.
2.  Find the Linux build of your game under the `./builds` directory and load it onto an SD Card.
3.  Restart the Steam Deck in Desktop Mode.
4.  Copy your game binary onto an SD card.
5.  Find the game on the SD card and double click binary.

### Advanced Setup

1.  Restart the Steam Deck in Desktop Mode.
2.  Open up Konsole and set an admin password via `passwd`.
3.  Disable readonly mode: `sudo steamos-readonly disable`.
4.  Update pacman `sudo pacman-key --populate archlinux`.
5.  Update sshd_config `sudo vim /etc/ssh/sshd_config` and uncomment the `PubkeyAuthentication yes` line.
6.  Enable ssh: `sudo systemctl enable sshd`.
7.  Start ssh: `sudo systemctl start sshd`.
8.  Run `dragonruby-publish --only-package`.
9.  Use `scp` to copy the game over from your dev machine without needing an SD Card: `scp -R ./builds/SOURCE.bin deck@IP_ADDRESS:/home/deck/Downloads`

Note: Steps 2 through 7 need only be done once.

Note: `scp` comes pre-installed on Mac and Linux. You can download the tool for Windows from <https://winscp.net/eng/index.php>

## Setting up the game on the Partner Site

### Getting your App ID

You'll need to create a product on Steam. This is unfortunately manual and requires identity verification for taxation purposes.
Valve offers pretty robust documentation on all this, though. Eventually, you'll have an
App ID for your game.

Go to <https://partner.steamgames.com/apps/view/$APPID>, where $APPID
is your game's App ID.

### Specifing Supported Operating Systems for your game

Find the "Supported Operating Systems" section and make sure these things
are checked:

-   Windows: 64 Bit Only
-   macOS: 64 Bit (Intel) and Apple Silicon
-   Linux: Including SteamOS

Click the "Save" button below it.

### Setting up SteamPipe Depots

Click the "SteamPipe" tab at the top of the page, click on "depots"

Click the "Add a new depot" button. Give it a name like "My Game Name
Linux Depot" and take whatever depot ID it offers you.

You'll see this new depot is listed on the page now. Fix its settings:

-   Language: All Languages
-   For DLC: Base App
-   Operating System: Linux + SteamOS
-   Architecture: 64-bit OS only
-   Platform: All

Do this again, make a "My Game Name Windows Depot", set it to the same
things, except "Operating System," which should be "Windows," of course.

Do this again, make a "My Game Name Mac Depot", set it to the same
things, except "Operating System," which should be "macOS," of course.

Push the big green "Save" button on the page. Now we have a place to
upload platform-specific builds of your game.

### Setting up Launch Options

Click on the "Installation" tab near the top of the page, then "General Installation".

Under "Launch Options," click the "Add new launch option" button, edit the new section
that just popped up, and set it like this:

(Whenever you see "mygamename" in here, this should be whatever your
`game_metadata`'s "gameid" value is set to. If you see "My Game Name", it's
whatever your `game_metadata`'s "gametitle" value is set to, but you'll have
to check in case we mangled it to work as a filename.)

-   Executable: mygamename.exe
-   Launch Type: Launch (Default)
-   Operating System: Windows
-   CPU Architecture: 64-bit only
-   Arguments: `./` (optionally set if you want to [Steam Console Commands](https://help.steampowered.com/en/faqs/view/7D01-D2DD-D75E-2955))
-   Everything else can be default/blank.

Click the "Update" button on that section.

Add another launch option, as before:

-   Executable: My Game Name.app
-   Launch Type: Launch (Default)
-   Arguments: `./` (optionally set if you want to [Steam Console Commands](https://help.steampowered.com/en/faqs/view/7D01-D2DD-D75E-2955))
-   Operating System: macOS

Add another launch option, as before:

-   Executable: mygamename
-   Launch Type: Launch (Default)
-   Operating System: Linux + SteamOS
-   Arguments: `./` (optionally set if you want to [Steam Console Commands](https://help.steampowered.com/en/faqs/view/7D01-D2DD-D75E-2955))
-   CPU Architecture: 64-bit only

### Publish Changes

Go to the "Publish" tab at near the top of the page. Click the "View Diffs"
button and make sure it looks sane (it should just be the things we've
changed in here), then click "Prepare for Publishing", then
"Publish to Steam" and follow the instructions to publish these changes.

Go to <https://partner.steamgames.com/apps/associated/$APPID> For each package,
make sure all three depots are included.

### Associated Packages

Once you have the bundles and launch options set up, go to your game's
Dashboard (the url is `https://partner.steamgames.com/apps/landing/APPID`).

Under the "View Associated Items" section, select "View Associated
Items All Associated Packages, DLC, Demos And Tools" (the url is
`https://partner.steamgames.com/apps/associated/APPID`) .

Under the "Store packages" section, select the row for your
game. Remove any invalid bundle ids and add the Windows, Mac, and
Linux repos you set up earlier.

There is a section called "Promotional or special-use packages" with
two rows, one called "Beta Test" and another called "Developer
Comp". Remove any invalid bundle ids and add the Windows, Mac, and Linux
repos you set up earlier.

## Configuring `dragonruby-publish`

You only have to do this part once when first setting up your game. Note that this
capability is only available for Indie and Pro license tiers. If you have a Standard
DragonRuby License, you'll need to use the Steamworks toolchains directly.

Go add a text file to your game's `metadata` directory called
`steam_metadata.txt` &#x2026; note that this file will be filtered out
`dragonruby-publish` packages the game and will not be distributed with
the published game.

    steam.publish=true
    steam.branch=public
    steam.username=AAA
    steam.appid=BBB
    steam.linux_depotid=CCC
    steam.windows_depotid=DDD
    steam.mac_depotid=EEE

If steam.publish is set to `false` then dragonruby-publish will not
attempt to upload to Steam. `false` is the default if this file, or
this setting, is missing.

Where "AAA" is the login name on the Steamworks Partner Site to use for
publishing builds, "BBB" is your game-specific AppID provided by Steam,
"CCC", "DDD", and "EEE" are the DepotIDs you created for Linux, Windows,
and macOS builds, respectively.

### Setting a branch live

Once your build is uploaded, you can assign it to a specific branch through
the interface on the Partner site. You can make arbitrary branches here, like
"beta" or "nightly" or "fixing-weird-bug" or whatever. The one that goes to
the end users without them switching branches, is "default" and you should
assume this is where paying customers live, so be careful before you set a
build live there.

You can have dragonruby-publish set the builds it publishes live on a branch
immediately, if you prefer. Simply add&#x2026;

    steam.branch=XXX

&#x2026;to `steam_metadata.txt`, where "XXX" is the branch name from the partner
website. If this is blank or unspecified, it will <span class="underline">not</span> set the build live on
<span class="underline">any</span> branch. Setting the value to `public` will push to production.

A reasonable strategy is to create a (possibly passworded) branch called
"staging" and have dragonruby-publish always push to there automatically.
Then you can test from a Steam install, pushing as often as you like, and
when you are satisfied, manually set the latest build live on default for
the general public to download.

If you are feeling brave, you can always just set all published builds live
on default, too. After all, if you break it, you can always just push a fix
right away, or use the Partner Site to roll back to a known-good build,
you know.

## Publishing Build

Run dragonuby-publish as you normally would. When it is time to publish
to Steam, it will set up any tools it needs, attempt to log you into Steam,
and upload the latest version of your game.

Steam login is handled by Valve's `steamcmd` command line program, not
`dragonruby-publish`. DragonRuby does not ever have access to your login
credentials. You may need to take steps to get an authorization token in
place if necessary, so you don't have to deal with Steam Guard in automated
build processes (documentation on how to do this is forthcoming, or read
Valve's SteamCMD manual for details).

You (currently) have to set the new build live on the partner site before
users will receive it. Optionally automating this step is coming soon!

## Questions/Need Help?

You probably have several. Please come visit the Discord and ask questions,
and we'll do our best to help, and update this document.
