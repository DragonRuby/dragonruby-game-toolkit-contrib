# 1. download Steamworks SDK: https://partner.steamgames.com/downloads/list
# 2. unzip and copy contents "sdk" directory to ./mygame/app-native/steam
# 3. fill in ./mygame/app-native/steam_appid.txt
# 4. start up steam and log in with a user that owns the app
# 5. run sh ./mygame/app-native/build-macos.sh from root DR directory

mkdir -p ./mygame/native/macos
clang++ -c -isystem . -fPIC    \
        -I ./mygame/app-native \
        -I ./mygame/app-native/steam/public \
        ./mygame/app-native/steam_api_wrapper.cpp \
        -o ./mygame/app-native/steam_api_wrapper.o

clang   -isystem . -fPIC -shared    \
        -framework Foundation       \
        -framework AppKit           \
        -framework CoreGraphics     \
        -I ./include                \
        -I ./mygame/app-native      \
        -L ./mygame/app-native/steam/redistributable_bin/osx/ \
        ./mygame/app-native/steam_api_wrapper.o \
        ./mygame/app-native/ext.c \
        -lsteam_api \
        -o ./mygame/native/macos/ext.dylib

cp ./mygame/app-native/steam_appid.txt ./
cp ./mygame/app-native/steam/redistributable_bin/osx/libsteam_api.dylib ./mygame/native/macos
sudo xattr -r -d com.apple.quarantine ./mygame/native/macos/libsteam_api.dylib
