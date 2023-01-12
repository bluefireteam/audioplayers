This file describes some common pitfalls and how to solve them. Please always refer to this before opening an issue.

## Supported Formats / Encodings

Not all formats are supported by all platforms. Essentially `audioplayers` is just centralized interface that communicate with native audio players on each platform. We are not parsing the bytes of your song. Each platform has its own native support. Please do not open issues regarding encoding/file format compatibility unless it is an AudioPlayers specific issue.

You can check a list of supported formats below:

- [Android](https://developer.android.com/guide/topics/media/media-formats.html)
- [iOS](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MultimediaPG/UsingAudio/UsingAudio.html#//apple_ref/doc/uid/TP40009767-CH2-SW33)
- [macOS](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html#//apple_ref/doc/uid/TP40003577-CH7-SW1)
- Web: audio formats supported by the browser you are using ([more details](https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Audio_codecs))
- [Windows](https://learn.microsoft.com/en-us/windows/win32/medfound/supported-media-formats-in-media-foundation)
- Linux: List of defined [audio types](https://gstreamer.freedesktop.org/documentation/plugin-development/advanced/media-types.html?gi-language=c#table-of-audio-types) and their according [Plugins](https://gstreamer.freedesktop.org/documentation/plugins_doc.html?gi-language=c)

## Unsafe HTTP when playing remote URLs

It is very common for mobile platforms to forbid non-HTTPS traffic due to it's lack of encryption and severe security deficiency. However, there are ways to bypass this protection.

On iOS and macOS, edit your `.plist` and add:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

On Android, add `android:usesCleartextTraffic="true"` to your `AndroidManifest.xml` file located in `android/app/src/main/AndroidManifest.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest ...>
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        ...
        android:usesCleartextTraffic="true"
        ...
    >
        ...
    </application>
</manifest>
```

## Asset not found when playing local assets

Flutter requires that assets are specified on your `pubspec.yaml` file, under `flutter > assets`; check [this](https://github.com/luanpotter/bgug/blob/master/pubspec.yaml#L89) for an example.

**Note**: when playing local assets, by default every instance of AudioPlayers uses a [shared global instance of AudioCache](https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/lib/src/audioplayer.dart#L24), that will have a [default prefix "/assets"](https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/lib/src/audio_cache.dart#L41) configured, as per Flutter conventions. However you can easily changing that by specifying your own instance of AudioCache with any other (or no) prefix.

## Other errors when playing remote URLs

The remote URL must be accessible and not be a redirect. If it's not an audio file, it does a redirect, it requires some headers, cookies or authentication, it will not work. Please bundle the file on the app or host it somewhere that properly provides the file. If you are having issues with playing audio from an URL, please first download the file and try running it locally. If the issue persists, then open the issue, including the file so we can test. Otherwise, it's an issue with your URL, not audioplayers.

## Build issues

**Warning**: If you are having any sort of build issues, you must read this first.

Our [CI](https://github.com/bluefireteam/audioplayers/blob/master/.github/workflows/build.yml) builds our example app using audioplayers for Android, iOS, Linux, macOS, Windows, and web. So if the build is passing, any build errors (from android/ios sdk, gradle, java, kotlin, cocoa pods, swift, flutter, etc) is not a global issue and likely is something on your setup.

Before opening an issue, you **must** try these steps:

1. Run this on your project and try again:
```bash
flutter clean
rm -rf build
rm -rf ~/.pub-cache

flutter pub get
```
1. Update xcode, android studio, android sdks, to the latest versions.
1. If the issue persists, clone the audioplayers repo and run the `example` app on the platform you are having issues. If it works, then there is something wrong with your project, and you can compare it to the `example` app to see what the problem is.
1. If the problem still persists, and no existing (open or closed) issue on this repo, no stack overflow question or existing discord discussion solves you problem, then you can open an issue. But you must follow the issue template, and refer to the problem on the example app (or start with its code and make only the necessary modifications to trigger the issue), not on your own app that we don't have access (because since step 2 the error must be reproducible on the example app).
1. Again, only open an issue if you reached step 3 and follow the issue template closely. Build issues that do not follow these steps will be closed without warning.

### [Linux] Build Requirements
In order to use the package `audioplayers_linux` you need to fulfill [these requirements](packages/audioplayers_linux/requirements.md).

## [iOS] Background Audio

There is a required configuration to enable audio do be playing on the background; add the following lines to your `info.plist`:

 ```
  <key>UIBackgroundModes</key>
  <array>
  	<string>audio</string>
  </array>
```

Or on XCode you can add it as a capability; more details [here](https://developer.apple.com/documentation/avfoundation/media_assets_playback_and_editing/creating_a_basic_video_player_ios_and_tvos/enabling_background_audio).

## Audio Stream Issues

One of the know reasons for streams not playing is that the stream is being gziped by the server, as described [here](https://github.com/bluefireteam/audioplayers/issues/183).

## Gapless Looping

Depending on the file format and platform, when audioplayers uses the native implementation of the "looping" feature, there will be gaps between plays, which might not be noticeable for non-continuous SFX but will definitely be noticeable for looping songs.

TODO(luan): break down alternatives here, low latency mode, audio pool, gapless_audioplayer, ocarina, etc

## [macOS] Outgoing Connections

By default, macOS apps don't allow outgoing connections; so playing audio files/streams from the internet won't work. To fix this, add the following to the `.entitlements` files for your app:

```xml
<key>com.apple.security.network.client</key>
<true/>
```
