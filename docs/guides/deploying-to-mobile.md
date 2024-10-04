# Deploying To Mobile Devices

If you have a Pro subscription, you also have the capability to deploy
to mobile devices.

## Deploying to iOS

To deploy to iOS, you need to have a Mac running MacOS Catalina, an
iOS device, and an active/paid Developer Account with Apple. From the
Console type: `$wizards.ios.start` and you will be guided through the
deployment process.

- `$wizards.ios.start env: :dev` will deploy to an iOS device connected via USB.
- `$wizards.ios.start env: :hotload` will deploy to an iOS device connected via USB with hotload enabled.
- `$wizards.ios.start env: :sim` will deploy to the iOS simulator.
- `$wizards.ios.start env: :prod` will package your game for distribution via Apple's AppStore.

## Deploying to Android

To deploy to Android, you need to have an Android emulator/device, and
an environment that is able to run Android SDK. `dragonruby-publish`
will create an APK for you. From there, you can sign the APK and
install it to your device. The signing and installation procedure
varies from OS to OS. Here's an example of what the command might look
like:

!> Be sure you specify `packageid=TLD.YOURCOMPANY.YOURGAME` (reverse domain name convention) within `metadata/game_metadata.txt` before running `dragonruby-publish` (for example: `packageid=com.tempuri.mygame`).

```sh
# generating a keystore (one time creation, save key to ./profiles for safe keeping)
keytool -genkey -v -keystore APP.keystore -alias mygame -keyalg RSA -keysize 2048 -validity 10000

# signing binaries
apksigner sign --min-sdk-version 26 --ks ./profiles/APP.keystore ./builds/APP-android.apk
apksigner sign --min-sdk-version 26 --ks ./profiles/APP.keystore ./builds/APP-googleplay.aab

# Deploying APK to a local device/emulator
adb install ./builds/APP-android.apk

# Deploying Google Play APK to a local device/emulator
bundletool build-apks --bundle=./builds/APP-googleplay.aab --output=./builds/app.apks --mode=universal
mv ./builds/app.apks ./builds/app.zip
cd ./builds
rm -rf tmp
mkdir tmp
cd tmp
unzip ../app.zip
cp ./universal.apk ./universal.zip
unzip ./universal.zip

# uninstall, install, launch
adb shell am force-stop PACKAGEID
adb uninstall PACKAGEID
adb install ./universal.apk
adb shell am start -n PACKAGEID/PACKAGEID.DragonRubyActivity

# read logs of device
adb logcat -e mygame
```
