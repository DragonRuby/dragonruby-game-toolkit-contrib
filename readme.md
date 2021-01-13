# How to Use

This repository requires DragonRuby Game Toolkit. You can purchase a license from http://dragonruby.org.

If your income is below $1000 per month, are a "student", or are a "big time Raspberry PI enthusiast", contact Amir at ar@amirrajan.net with a short explanation of your current situation, and he'll set you up with a free license, no questions asked.

1. Download DragonRuby Game Toolkit.
2. Unzip.
3. Navigate to your game folder using terminal (the default game folder is `./mygame/app`).
4. `git clone https://github.com/DragonRuby/dragonruby-game-toolkit-contrib` or download and unzip into the `./mygame/app` directory. 

IMPORTANT: _do not_ try to symlink the git repo into the `./mygame/app` directory (or anything else fancy), the DragonRuby Runtime requires everything to reside in the game directory and will not allow access outside of it.

IMPORTANT: make sure Git is configured to not change line endings (especially if you're cloning on Windows):

```
git config --system core.autocrlf false
git config --global core.autocrlf false
```

5. Your directory structures should look  like the following:

```
DragonRuby
|
+- mygame/
   |
   +- app/
      |
      +- main.rb
      +- repl.rb
      +- documentation/
      |
      +- dragonruby-game-toolkit-contrib/ (this repository)
         |
         +- dragon/
         |  |
         |  +- docs.rb
         |  +- [other source files]
```

6. Open `main.rb` and add a `require` statement for the source file you want to edit. For example, if you want to edit `docs.rb`, your `mygame/main.rb` would look like this:

```ruby
require 'app/dragonruby-game-toolkit-contrib/dragon/docs.rb'

def tick args
end
```

[Here is the final result](final-result.mp4)

# Instructions on how to fork and contribute

TODO
