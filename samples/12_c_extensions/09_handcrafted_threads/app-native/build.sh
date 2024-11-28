# run sh ./mygame/app-native/build.sh from root DR directory
mkdir -p ./mygame/native/macos
clang -isystem . -fPIC -shared    \
      -I ./include                \
      -I ./mygame/app-native      \
      ./mygame/app-native/ext.c   \
      -o ./mygame/native/macos/ext.dylib
