# AudioPlayer

A Flutter audio plugin. 
 
## Features
 
- [x] Android & iOS
  - [x] play (remote file)
  - [x] stop
  - [x] pause
  - [x] onComplete
  - [x] onDuration / onCurrentPosition

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
AudioPlayer audioPlugin = new AudioPlayer();
//...
```

### play, pause , stop

```dart
Future play() async {
  final result = await audioPlayer.play(kUrl);
  if (result == 1) setState(() => playerState = PlayerState.playing);
}
  
Future pause() async {
  final result = await audioPlayer.pause();
  if (result == 1) setState(() => playerState = PlayerState.paused);
}

Future stop() async {
  final result = await audioPlayer.stop();
  if (result == 1)
    setState(() {
    playerState = PlayerState.stopped;
    position = new Duration();
  });
}

```

### duration, position, complete, error (temporary api) 

The dart part of the plugin listen for platform calls :

```dart
//...
audioPlayer.setDurationHandler((d) => setState(() {
  duration = d;
}));

audioPlayer.setPositionHandler((p) => setState(() {
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
## Troubleshooting

If you get a MissingPluginException, try to `flutter build apk` on Android, or `flutter build ios`

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).