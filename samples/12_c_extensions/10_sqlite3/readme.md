# About

Sample app shows out to integrate SQLite 3 into your game. The source
code for the C Extension is located at `./app-native/ext.c`.

# Clone and perform an amalgamation of SQLite 3

Here is an example of how you'd clone the repo and compile SQLite.

```
git clone https://github.com/sqlite/sqlite.git # clone the repo outside of your dragonruby root directory
cd ./sqlite
git checkout version-3.9.3
./configure
CFLAGS="-DSQLITE_ENABLE_JSON1" make sqlite3.c
```

When the build completes, `sqlite3.c` and `sqlite3.h` will be created.

Copy those files into your dragonruby directory under `./mygame/app-native`.

# Compile the C Extension

Here is an example of a `./compile-extension.sh` file which you'd
create within the DR root directory.

The script assumes that you have copied the contents of this sample
into the `./mygame` directory at the root.

```sh
#!/bin/sh

clang -isystem ./include -I ./include -fPIC -shared \
      -DSQLITE_ENABLE_JSON1 \
      ./mygame/app-native/ext.c \
      ./mygame/app-native/sqlite3.c \
      -o ./mygame/native/macos/ext.dylib # platform specific path
```

