# DragonRuby C Extension for Android

C Extensions for Android work similarly to C Extensions for other
platforms, with one caveat with respect to accessing Java classes.

Access to Java classes is performed through a pre-defined Java class
called org.dragonruby.app.Bridge. This sample app shows how to build
this bridge class and generate a `.dex` that is released with your
app.

1.  Install Java Version 21.0.5 from the [Oracle Website](https://www.oracle.com/cis/java/technologies/downloads/#java21).
2.  Download Android command line tools from the [Android Website](https://developer.android.com/studio#command-line-tools-only).
3.  Unzip the download (it should contain a single folder called `./cmdline-tools`).
4.  Download `bundletool` from [GitHub](https://github.com/google/bundletool/releases).
5.  Create a directory at the root of dragonruby with the following path: `./android/`.
6.  Put `cmdline-tools`, and the `bundletool` jar into the `./android` directory. (eg `./android/cmdline-tools`, and `./android/bundletool.jar`).
7.  Using `sdkmanager` install Android NDK version 26.3.11579264, Build Tools for SDK 30, and Platform SDK 34:
    ```
    ./android/cmdline-tools/bin/sdkmanager --install "ndk;26.3.11579264" --sdk_root=./android
    ./android/cmdline-tools/bin/sdkmanager --install "build-tools;30.0.0" --sdk_root=./android
    ./android/cmdline-tools/bin/sdkmanager --install "platforms;android-34" --sdk_root=./android
    ```
10. Delete contents of `./mygame` and copy over this directory's contents.
11. Under the `./android/ndk/26.3.11579264/toolchains/llvm/prebuilt/` directory, locate the binary called `./PLATFORM/bin/aarch64-linux-android33-clang`
    and also locate the `./PLATFORM/sysroot` directory.
    For example, on MacOS the location would be
    `./android/ndk/26.3.11579264/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android33-clang` and
    `./android/ndk/26.3.11579264/toolchains/llvm/prebuilt/darwin-x86_64/sysroot`.
12. Build the C Extension:
    ```
    mkdir -p ./mygame/native/googleplay-arm64
    ./android/ndk/26.3.11579264/toolchains/llvm/prebuilt/PLATFORM/bin/aarch64-linux-android33-clang --sysroot=./android/ndk/26.3.11579264/toolchains/llvm/prebuilt/PLATFORM/sysroot -shared -Wl,-undefined -Wl,dynamic_lookup -fPIC -I ./include ./mygame/app-native/ext.c -o ./mygame/native/googleplay-arm64/ext.so
    # eg (macos):
    # ./android/ndk/26.3.11579264/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android33-clang --sysroot=./android/ndk/26.3.11579264/toolchains/llvm/prebuilt/darwin-x86_64/sysroot -shared -Wl,-undefined -Wl,dynamic_lookup -fPIC -I ./include ./mygame/app-native/ext.c -o ./mygame/native/googleplay-arm64/ext.so
    ```
13. Build Java Class and generate dex file:
    ```
    rm ./.dragonruby/stubs/googleplay/stub/dex/classes3.dex
    rm -rf ./android-build
    mkdir ./android-build
    javac -d ./android-build ./mygame/app-android/**/*.java -source 1.8 -target 1.8 -classpath ./android/platforms/android-34/android.jar
    pushd ./android-build
    jar cvf Extension.jar *
    ../android/build-tools/30.0.0/dx --dex --output=./classes3.dex ./Extension.jar
    cp ./classes3.dex ../.dragonruby/stubs/googleplay/stub/dex/
    popd
    ls ./.dragonruby/stubs/googleplay/stub/dex/
    ```
14. Create the Google Play package, extract the APK, and install to your device:
    ```
    ./dragonruby-publish --package --platforms=googleplay
    java -jar ./android/bundletool.jar build-apks --bundle=./builds/mygame-googleplay.aab --output=./builds/app.apks --mode=universal
    mv ./builds/app.apks ./builds/app.zip
    rm -rf ./builds/tmp
    mkdir ./builds/tmp
    unzip ./builds/app.zip -d ./builds/tmp
    cp ./builds/tmp/universal.apk ./builds/tmp/universal.zip
    ./android/platform-tools/adb shell am force-stop com.dev.mygame
    ./android/platform-tools/adb uninstall com.dev.mygame
    ./android/platform-tools/adb install ./builds/tmp/universal.apk
    ./android/platform-tools/adb shell am start -n com.dev.mygame/com.dev.mygame.DragonRubyActivity
    ```
15. Process log after starting the app:
    ```
    adb logcat --pid=$(adb shell pidof -s com.dev.mygame)
    ```
