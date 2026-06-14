# DragonRuby C Extension for Android

C Extensions for Android work similarly to C Extensions for other
platforms, with one caveat with respect to accessing Java classes.

Access to Java classes is performed through a pre-defined Java class
called org.dragonruby.app.Bridge. This sample app shows how to build
this bridge class and generate a `.dex` that is released with your
app.

1.  Install Java Version 17.0.15 from the either OpenJDK or from the [Oracle Website](https://www.oracle.com/cis/java/technologies/downloads/#java17).
2.  Download Android command line tools from the [Android Website](https://developer.android.com/studio#command-line-tools-only).
3.  Unzip the download to `./.android/cmdline-tools/latest` (`ls ./.android/cmdline-tools/latest` should yield `bin`, `lib`, `NOTICE.txt`, and `source.properties`).
4.  Download `bundletool` from [GitHub](https://github.com/google/bundletool/releases).
7.  Using `sdkmanager` install Android NDK version 28.2.13676358, Build Tools for SDK 35, and Platform SDK 35:
    ```
    ./.android/cmdline-tools/latest/bin/sdkmanager --install 'ndk;28.2.13676358'
    ./.android/cmdline-tools/latest/bin/sdkmanager --install "build-tools;35.0.0"
    ./.android/cmdline-tools/latest/bin/sdkmanager --install 'platform-tools'
    ./.android/cmdline-tools/latest/bin/sdkmanager --install "platforms;android-35"
    ```
10. Delete contents of `./mygame` and copy over this directory's contents.
11. Under the `./android/ndk/28.2.13676358/toolchains/llvm/prebuilt/` directory, locate the binary called `./PLATFORM/bin/aarch64-linux-android33-clang`
    and also locate the `./PLATFORM/sysroot` directory.
    For example, on MacOS the location would be
    `./.android/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android33-clang` and
    `./.android/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/sysroot`.
12. Build the C Extension:
    ```
    mkdir -p ./mygame/native/googleplay-arm64
    ./.android/ndk/28.2.13676358/toolchains/llvm/prebuilt/PLATFORM/bin/aarch64-linux-android33-clang --sysroot=./.android/ndk/28.2.13676358/toolchains/llvm/prebuilt/PLATFORM/sysroot -shared -Wl,-undefined -Wl,dynamic_lookup -fPIC -I ./include ./mygame/app-native/ext.c -o ./mygame/native/googleplay-arm64/ext.so
    # eg (macos):
    # ./.android/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android33-clang --sysroot=./.android/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/sysroot -shared -Wl,-undefined -Wl,dynamic_lookup -fPIC -I ./include ./mygame/app-native/ext.c -o ./mygame/native/googleplay-arm64/ext.so
    ```
13. Build Java Class and generate dex file:
    ```
    rm ./.dragonruby/stubs/googleplay/stub/dex/classes3.dex
    rm -rf ./android-build
    mkdir ./android-build
    javac -d ./android-build ./mygame/app-android/**/*.java -classpath ./.android/platforms/android-35/android.jar
    pushd ./android-build
    ../.android/build-tools/35.0.0/d8 ./**/*.class
    cp ./classes.dex ../.dragonruby/stubs/googleplay/stub/dex/classes3.dex
    popd
    ls ./.dragonruby/stubs/googleplay/stub/dex/
    ```
14. Create the Google Play package, extract the APK, and install to your device:
    ```
    # assuming the following contents of game_metadata.txt
    # devid=developer
    # devtitle=Developer Name
    # gameid=mygame
    # gametitle=My Game
    # version=1.0
    # icon=metadata/icon.png
    # packageid=com.developer.mygame

    ./dragonruby-publish --package --platforms=googleplay
    java -jar ./.android/bundletool.jar build-apks --bundle=./builds/mygame-googleplay.aab --output=./builds/app.apks --mode=universal
    mv ./builds/app.apks ./builds/app.zip
    rm -rf ./builds/tmp
    mkdir ./builds/tmp
    unzip ./builds/app.zip -d ./builds/tmp
    cp ./builds/tmp/universal.apk ./builds/tmp/universal.zip
    ./.android/platform-tools/adb shell am force-stop com.dev.mygame
    ./.android/platform-tools/adb uninstall com.dev.mygame
    ./.android/platform-tools/adb install ./builds/tmp/universal.apk
    ./.android/platform-tools/adb shell am start -n com.dev.mygame/com.dev.mygame.DragonRubyActivity
    ```
15. Process log after starting the app:
    ```
    adb logcat --pid=$(adb shell pidof -s com.dev.mygame)
    ```
