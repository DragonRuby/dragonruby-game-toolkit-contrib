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
can be created.

### Windows (Standard License)

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

### Windows (Indie/Pro License)

```powershell
# Retrieve zip
Invoke-RestMethod -Uri 'https://dragonruby.org/api/download_pro_subscription_windows' -Credential (Get-Credential) -OutFile 'dragonruby.zip'
# Invoke-RestMethod -Uri 'https://dragonruby.org/api/download_indie_subscription_windows' -Credential (Get-Credential) -OutFile 'dragonruby.zip'

# Create staging directory
Remove-Item -Path './upgrade-working-directory' -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path './upgrade-working-directory' -ItemType Directory -Force

# Unzip binary
Expand-Archive -Path './dragonruby.zip' -DestinationPath './upgrade-working-directory'

# Sync all files except for the mygame directory using robocopy
$source = './upgrade-working-directory/dragonruby-macos/'
$destination = './'
$excludeDir = 'mygame'
robocopy $source $destination /MIR /XD $excludeDir
```

### MacOS (Standard License)

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

### MacOS (Indie/Pro License)

```sh
# retrieve zip
wget "$(curl -u USERNAME:PASSWORD https://dragonruby.org/api/download_pro_subscription_mac)" -O dragonruby.zip
# wget "$(curl -u USERNAME:PASSWORD https://dragonruby.org/api/download_indie_subscription_mac)" -O dragonruby.zip

# create staging directory
rm -rf ./upgrade-working-directory
mkdir -p ./upgrade-working-directory

# unzip binary
unzip ./dragonruby.zip -d ./upgrade-working-directory

# sync all files except for the mygame directory using rsync
rsync -av --exclude='mygame' ./upgrade-working-directory/dragonruby-macos/ ./
```

### Linux (Standard License)

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

### Linux (Indie/Pro License)

```sh
# retrieve zip
wget "$(curl -u USERNAME:PASSWORD https://dragonruby.org/api/download_pro_subscription_linux)" -O dragonruby.zip
# wget "$(curl -u USERNAME:PASSWORD https://dragonruby.org/api/download_indie_subscription_linux)" -O dragonruby.zip

# create staging directory
rm -rf ./upgrade-working-directory
mkdir -p ./upgrade-working-directory

# unzip binary
unzip ./dragonruby.zip -d ./upgrade-working-directory

# sync all files except for the mygame directory using rsync
rsync -av --exclude='mygame' ./upgrade-working-directory/dragonruby-macos/ ./
```
