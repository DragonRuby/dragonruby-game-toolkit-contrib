# Updating DragonRuby

## Option 1

If there is a new release of DragonRuby, you can update a current game
you are working on using the following steps:

1. Download the latest version of the DragonRuby zip file.
2. Unzip.
3. Copy over all the files in the zip except for the `mygame`
   directory.

!> If you are on Mac or Linux, there is a hidden directory
   called `.dragonruby` that needs to be copied over too. You can show
   hidden files in Finder (MacOS) using `command + shift + .`.
   On Linux you can show hidden files in File Manager using `control + h`.

## Option 2 (Advanced)

If you are comfortable in the terminal, a script such as the following
can be created:

?> The following script assumes that you got DragonRuby from
Itch.io. For Indie and Pro License holders, use
https://dragonruby.org/api to retrieve the zip.

### Windows

```powershell
# delete wget artifact
Remove-Item -Path default

# delete working directories
Remove-Item -Path butler-tmp -Recurse -Force
Remove-Item -Path dragonruby-tmp -Recurse -Force

# retrieve butler zip
Invoke-WebRequest -Uri https://broth.itch.ovh/butler/windows-amd64/LATEST/archive/default -OutFile ./default

# unzip it
Expand-Archive -Path default -DestinationPath butler-tmp

# specify where you want files to be copied
$INSTALLDIR = "$HOME\projects\fancy-game"

# login to butler
& .\butler-tmp\butler login

# get dragonruby
& .\butler-tmp\butler fetch dragonruby/dragonruby-gtk:windows-amd64 dragonruby-tmp

# delete the ./mygame directory from the fresh download of dragonruby
Remove-Item -Path dragonruby-tmp\dragonruby-windows-amd64\mygame -Recurse -Force

# copy all files recursively to install directory
Copy-Item -Path .\dragonruby-tmp\dragonruby-windows-amd64\* -Destination $INSTALLDIR -Recurse
```

### MacOS

```sh
# delete wget artifact
rm ./default

# delete working directories
rm -rf ./butler-tmp
rm -rf ./dragonruby-tmp

# retrieve butler zip
wget https://broth.itch.ovh/butler/darwin-amd64/LATEST/archive/default

# unzip it
unzip ./default -d ./butler-tmp

# specify where you want files to be copied
INSTALLDIR=~/projects/fancy-game

# login to butler
./butler-tmp/butler login

# get dragonruby
./butler-tmp/butler fetch dragonruby/dragonruby-gtk:macos ./dragonruby-tmp

# delete the ./mygame directory from the fresh download of dragonruby
rm -rf ./dragonruby-tmp/dragonruby-macos/mygame

# copy all files recursively to install directory
cp -R ./dragonruby-tmp/dragonruby-macos/* $INSTALLDIR
```

### Linux

```sh
# delete wget artifact
rm ./default

# delete working directories
rm -rf ./butler-tmp
rm -rf ./dragonruby-tmp

# retrieve butler zip
wget https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default

# unzip it
unzip ./default -d ./butler-tmp

# specify where you want files to be copied
INSTALLDIR=~/projects/fancy-game

# login to butler
./butler-tmp/butler login

# get dragonruby
./butler-tmp/butler fetch dragonruby/dragonruby-gtk:linux-amd64 ./dragonruby-tmp

# delete the ./mygame directory from the fresh download of dragonruby
rm -rf ./dragonruby-tmp/dragonruby-linux-amd64/mygame

# copy all files recursively to install directory
cp -R ./dragonruby-tmp/dragonruby-linux-amd64/* $INSTALLDIR
```
