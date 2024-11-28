# run sh ./mygame/app-native/build.sh from root DR directory
clang -isystem . -fPIC -shared    \
      -framework Foundation       \
      -framework AppKit           \
      -framework CoreGraphics     \
      -I ./include                \
      -I ./mygame/app-native      \
      ./mygame/app-native/ext.c   \
      ./mygame/app-native/hello.m \
      ./mygame/app-native/bye.m   \
      -o ./mygame/native/macos/ext.dylib
