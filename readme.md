# How to Use

This repository requires DragonRuby Game Toolkit. You can purchase a license from http://dragonruby.org.

If your income is below $1000 per month, are a "student", or are a "big time Raspberry PI enthusiast", contact Amir at ar@amirrajan.net with a short explanation of your current situation, and he'll set you up with a free license, no questions asked.

1. Download DragonRuby Game Toolkit.
2. Unzip.
3. Navigate to your game folder using terminal (the default game folder is `./mygame/app`)
4. `git clone https://github.com/DragonRuby/dragonruby-game-toolkit-contrib` or download and unzip into the `./mygame/app` directory.
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
      +- dragon/ (this repository)
         |
         +- index.rb
         +- other source files
```

5. Open `main.rb` and add the following to the top of the file: `require "app/dragon/index.rb"`
