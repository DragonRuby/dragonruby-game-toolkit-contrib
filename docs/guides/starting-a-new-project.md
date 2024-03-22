# Starting a New DragonRuby Project

The DragonRuby zip that contains the engine is a complete, self contained project
structure. To create a new project, unzip the zip file again in its entirety
and use that as a starting point for another game. This is the recommended
approach to starting a new project.

!> It's strongly recommended that you do NOT keep DragonRuby Game Toolkit in a shared location and
instead unzip a clean copy for every game (and commit everything to source control). <br/> <br/>
File access functions are sandoxed and assume that the `dragonruby` binary lives alongside
the game you are building. Do not expect file access functions to return correct values if you are attempting
to run the `dragonruby` binary from a shared location. It's recommended that the directory
structure contained in the zip is not altered and games are built using that starting directory structure.

## Public Repos

### Option 1 (Recommended)

Your public repository needs only to contain the contents of `./mygame`. This approach
is the cleanest and doesn't require your `.gitignore` to be polluted with DragonRuby
specific files.

### Option 2 (Restrictions Apply)

!> Do NOT commit `dragonruby-publish(.exe)`, or `dragonruby-bind(.exe)`.

```
dragonruby
dragonruby.exe
dragonruby-publish
dragonruby-publish.exe
dragonruby-bind
dragonruby-bind.exe
/tmp/
/builds/
/logs/
/samples/
/docs/
/.dragonruby/
```

If you'd like people who do not own a DragonRuby license to run your game, you may include
the `dragonruby(.exe)` binary within the repo. This permission is granted in good-faith
and can be revoked if abused.

## Private Repos / Commercial Games

The following `.gitignore` should be used for private repositories (commercial games).

```
/tmp/
/logs/
```
You'll notice that everything else is committed to source control (even the `./samples`, `./docs`, and `./builds` directory).

!> The DragonRuby binary/package is designed to be committed in its entirety
with your source code (it’s why we keep it small). This protects the “shelf life”
for commercial games. 3 years from now, we might be on a vastly different version
of the engine. But you know that the code you’ve written will definitely work with the
version that was committed to source control.
