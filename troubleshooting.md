This file describes some common pitfalls and how to solve them. Please always refer to this before opening an issue.

## Both platforms

 - Asset not available/not found when playing local files. Flutter requires that files are specified on your pubspec.yaml file, under flutter > assets, check [this](https://github.com/luanpotter/bgug/blob/master/pubspec.yaml#L89) for an example. Also keep in mind that `AudioCache` class will look for files under the `assets` folder and this class must be used to play local files.

## Android

 - Can't play remote files on Android 9: Android 9 has changed some network security defaults, so it may prevent you from play files outside https by default, [this stackoverflow question](https://stackoverflow.com/questions/45940861/android-8-cleartext-http-traffic-not-permitted) is a good source to solving this.

## iOs

 - Project does not compile with plugin: First check your xcode version, for some unknow reason compilation seens to fail when using older versions of xcode. Also, always try to compile the example app of this plugin, we try to keep the example app always updated and working, so if you can't compile it, the problem may be on your xcode version/configuration.

 - Audio doens't keep playing on the background: Apparently there is a required configuration for that to happen on your app, you add the following lines to your `info.plist`:

 ```
  <key>UIBackgroundModes</key>
  <array>
  	<string>audio</string>
  </array>
```

 - Can't play stream audio: One of the know reasons for streams not playing on iOs, may be because the stream is been gziped by the server, as reported [here](https://github.com/luanpotter/audioplayers/issues/183).
