This file describes some common pitfalls and how to solve them. Please always refer to this before opening an issue.

## Both platforms

### Asset not available/not found when playing local files
 
Flutter requires that files are specified on your pubspec.yaml file, under flutter > assets, check [this](https://github.com/luanpotter/bgug/blob/master/pubspec.yaml#L89) for an example. Also keep in mind that `AudioCache` class will look for files under the `assets` folder and this class must be used to play local files.
 
### How to pause/stop audio?

The basic class of this package is the AudioPlayer class, which represents a single player playing a single audio, and it has methods `pause` and `stop` and `resume` to be used as you wish.

If you are using the `AudioCache` class, though, it does not have a pause method because that class generates new audio players every time you play, in order to allow for simultaneously playing. So the `play` or `loop` methods on that class returns the instance of `AudioPlayer` created, and you can save that to a variable and call `pause`/`stop`/`resume` on that instead. There is also a mode where `AudioCache` uses the same, `fixedPlayer`, but that is also returned in the method. Please take a look at the docs and source code for the `AudioCache` class for more details. Also, cf. [this stack overflow question](https://stackoverflow.com/questions/59229935/when-using-flame-audioplayers-how-to-stop-audios-from-audiocache/59229936#59229936).

## Android

 - Can't play remote files on Android 9: Android 9 has changed some network security defaults, so it may prevent you from play files outside https by default, [this stackoverflow question](https://stackoverflow.com/questions/45940861/android-8-cleartext-http-traffic-not-permitted) is a good source to solving this.

 - Some old Samsung devices have a bug that prevents certain types of audio from being played, [see more here](https://stackoverflow.com/questions/16238218/android-media-player-streaming-issue-on-samsung-devices).
 
 - minSdkVersion: we only support SDK version 23 or up.
 
 Supporting bellow API 23 was turning the maintenance of the package quite complicated. We looked on many sources before increasing the min version; for example, as you can see [here](https://www.appbrain.com/stats/top-android-sdk-versions), uses of SDK 16 and below are from less than 1% of users.

Currently, we don't plan on decreasing minSdkVersion to less than 23. Jelly Bean (SDK 16) was launched almost 10 years ago. Using such an old piece of software can in of itself lead to many performance and security issues and bugs. Please update your devices' android version to at least 23, and you will be able to enjoy audioplayers without any issues :)

## iOs

 - Project does not compile with plugin: First check your xcode version, for some unknow reason compilation seens to fail when using older versions of xcode. Also, always try to compile the example app of this plugin, we try to keep the example app always updated and working, so if you can't compile it, the problem may be on your xcode version/configuration.

 - Audio doens't keep playing on the background: Apparently there is a required configuration for that to happen on your app, you add the following lines to your `info.plist`:

 ```
  <key>UIBackgroundModes</key>
  <array>
  	<string>audio</string>
  </array>
```

Or on XCode you can add it as a capability; more details [here](https://developer.apple.com/documentation/avfoundation/media_assets_playback_and_editing/creating_a_basic_video_player_ios_and_tvos/enabling_background_audio).

 - Can't play stream audio: One of the know reasons for streams not playing on iOs, may be because the stream is been gziped by the server, as reported [here](https://github.com/luanpotter/audioplayers/issues/183).

 ## macOS

 - Project does not compile with plugin: First check your xcode version, for some unknow reason compilation seens to fail when using older versions of xcode. Also, always try to compile the example app of this plugin, we try to keep the example app always updated and working, so if you can't compile it, the problem may be on your xcode version/configuration.

 - Can't play stream audio: One of the reasons for streams not playing on macOS, may be because the stream is been gziped by the server, as reported [here](https://github.com/luanpotter/audioplayers/issues/183).
