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

```sh
# generating a keystore
keytool -genkey -v -keystore APP.keystore -alias mygame -keyalg RSA -keysize 2048 -validity 10000

# deploying to a local device/emulator
apksigner sign --min-sdk-version 26 --ks ./profiles/mygame.keystore ./builds/APP-android.apk
adb install ./builds/APP-android.apk
# read logs of device
adb logcat -e mygame

# signing for Google Play
apksigner sign --min-sdk-version 26 --ks ./profiles/APP.keystore ./builds/APP-googleplay.aab
```
