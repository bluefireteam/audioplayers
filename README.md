# AudioPlayers

This is a fork of [rxlabz's audioplayer](https://github.com/rxlabz/audioplayer), with the difference that it supports playing multiple audios at the same time, and exposes volume controls.

It has the exact same API, but now you can create several new AudioPlayers, each will be handled individually.

Before you could only ever have one instance of the player, otherwise one would override the other.

Just import the fork, which is named `audioplayers` (mind the 's'), instead of the original:

```
  dependencies:
    ...
    audioplayers: ^0.5.2
```

Also, in `0.2.0`, I've added the ability to disable logs with:

```
    AudioPlayer.logEnabled = false;
```

In `0.3.0`, it supports iOS as well (thanks, @feroult)

In `0.4.0`, volume control support was added (thanks, @pauldemarco)

In `0.4.1`, a bug in iOS regard the seek functionality was fixed (thanks, @cosmok)

In `0.5.0`, there was a huge change on Android code to improve performance (thanks, @the4thfloor)

In `0.5.1`, there was a fix to work with Dart 2 (thanks, @efortuna)

# Original Readme

A Flutter audio plugin. 
 
## Features
 
- [x] Android & iOS
  - [x] play (remote and local file)
  - [x] stop
  - [x] pause
  - [x] seek
  - [x] onComplete
  - [x] onDuration / onCurrentPosition

- Supported formats 
  - [Android](https://developer.android.com/guide/topics/media/media-formats.html)
  - [iOS](http://www.techotopia.com/index.php/Playing_Audio_on_iOS_8_using_AVAudioPlayer#Supported_Audio_Formats)

![screenshot](https://github.com/rxlabz/audioplayer/blob/master/screenshot.png?raw=true)

## Usage

[Example](https://github.com/rxlabz/audioplayer/blob/master/example/lib/main.dart) 

To use this plugin : 

- add the dependency to your [pubspec.yaml](https://github.com/rxlabz/audioplayer/blob/master/example/pubspec.yaml) file.

```yaml
  dependencies:
    flutter:
      sdk: flutter
    audioplayer:
```

- instantiate an AudioPlayer instance

```dart
//...
AudioPlayer audioPlayer = new AudioPlayer();
//...
```

### play, pause , stop, seek

```dart
play() async {
  final result = await audioPlayer.play(kUrl);
  if (result == 1) setState(() => playerState = PlayerState.playing);
}

// add a isLocal parameter to play a local file
playLocal() async {
  final result = await audioPlayer.play(kUrl);
  if (result == 1) setState(() => playerState = PlayerState.playing);
}


pause() async {
  final result = await audioPlayer.pause();
  if (result == 1) setState(() => playerState = PlayerState.paused);
}

stop() async {
  final result = await audioPlayer.stop();
  if (result == 1) setState(() => playerState = PlayerState.stopped);
}

// seek 5 seconds from the beginning
audioPlayer.seek(5.0);

```

### duration, position, complete, error (temporary api) 

The Dart part of the plugin listen for platform calls :

```dart
//...
audioPlayer.setDurationHandler((Duration d) => setState(() {
  duration = d;
}));

audioPlayer.setPositionHandler((Duration  p) => setState(() {
  position = p;
}));

audioPlayer.setCompletionHandler(() {
  onComplete();
  setState(() {
    position = duration;
  });
});

audioPlayer.setErrorHandler((msg) {
  print('audioPlayer error : $msg');
  setState(() {
    playerState = PlayerState.stopped;
    duration = new Duration(seconds: 0);
    position = new Duration(seconds: 0);
  });
});
```

## iOS
   
### :warning: Swift project

- this plugin is written in swift, so to use with in a Flutter/ObjC project, 
you need to convert the project to "Current swift syntax" ( Edit/Convert/current swift syntax)  

## :warning: iOS App Transport Security

By default iOS forbids loading from non-https url. To cancel this restriction edit your .plist and add :
 
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
