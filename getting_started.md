# Getting Started

This tutorial should help you get started with the audioplayers library, covering the basics but guiding you all the way through advanced features.
You can also play around with our [official example app](https://bluefireteam.github.io/audioplayers/) and [explore the code](https://github.com/bluefireteam/audioplayers/tree/main/packages/audioplayers/example), that showcases every feature the library has to offer.

In order to install this package, add the [latest version](pub.dev/packages/audioplayers) of `audioplayers` to your `pubspec.yaml` file.
This package uses [the Federated Plugin](https://docs.flutter.dev/development/packages-and-plugins/developing-packages) guidelines to support multiple platforms, so it should just work on all supported platforms your app is built for without any extra configuration.
You do not need to add the `audioplayers_*` packages directly.

## Setup Platforms

For building and running for certain platforms you need pay attention to additional steps:

* [Linux Setup](packages/audioplayers_linux/README.md#setup-for-linux) (`audioplayers_linux`).
* [Windows Setup](packages/audioplayers_windows/README.md#setup-for-windows) (`audioplayers_windows`).

## AudioPlayer

An `AudioPlayer` instance can play a single audio at a time (think of it as a single boombox). To create it, simply call the constructor:

```dart
  final player = AudioPlayer();
```

You can create as many instances as you wish to play multiple audios simultaneously, or just to more easily control separate sources.

## Sources

Each AudioPlayer is created empty and has to be configured with an audio source (and it can only have one; changing it will replace the previous source).

The source (cf. packages/audioplayers/lib/src/source.dart) is basically what audio you are playing (a song, sound effect, radio stream, etc), and it can have one of 4 types:

1. **UrlSource**: get the audio from a remote URL from the Internet. This can be a direct link to a supported file to be downloaded, or a radio stream.
1. **DeviceFileSource**: access a file in the user's device, probably selected by a file picker.
1. **AssetSource**: play an asset bundled with your app, by default within the `assets` directory.
   To customize the prefix, see [AudioCache](#audiocache).
1. **BytesSource** (only some platforms): pass in the bytes of your audio directly (read it from anywhere).

In order to set the source on your player instance, call `setSource` with the appropriate source object:

```dart
  await player.setSource(AssetSource('sounds/coin.wav'));
```

Alternatively, call the shortcut method:

```dart
  await player.setSourceUrl(url); // equivalent to setSource(UrlSource(url));
```

Or, if you want to set the url and start playing, using the `play` shortcut:

```dart
  await player.play(DeviceFileSource(localFile)); // will immediately start playing
```

## Controls

After the URL is set, you can use the following methods to control the player:

### resume

Starts playback from current position (by default, from the start).

```dart
  await player.resume();
```

### seek

Changes the current position (note: this does not affect the "playing" status).

```dart
  await player.seek(Duration(milliseconds: 1200));
```

### pause

Stops the playback but keeps the current position.

```dart
  await player.pause();
```

### stop

Stops the playback and also resets the current position.

```dart
  await player.stop();
```

### release

Equivalent to calling `stop` and then releasing of any resources associated with this player.

This means that memory might be de-allocated, etc.

Note that the player is also in a ready-to-use state; if you call `resume` again any necessary resources will be re-fetch.

Particularly on Android, the media player is quite resource-intensive, and this will let it go. Data will be buffered again when needed (if it's a remote file, it will be downloaded again.

### dispose

Disposes the player. It is calling `release` and also closes all open streams. This player instance must not be used anymore!

```dart
  await player.dispose();
```

### play

Play is just a shortcut method that allows you to:

  * set a source
  * configure some player parameters (volume)
  * configure audio attributes
  * resume (start playing immediately)

All in a single function call. For most simple use cases, it might be the only method you need.

## Player Parameters

You can also change the following parameters:

### Volume

Changes the audio volume. Defaults to `1.0`. It can go from `0.0` (mute) to `1.0` (max; some platforms allow bigger than 1), varying linearly.

```dart
  await player.setVolume(0.5);
```

### Balance

Changes stereo balance. Defaults to `0.0` (both channels). `1.0` - right channel only, `-1.0` - left channel only.

```dart
  await player.setBalance(1.0); // right channel only
```

### Playback Rate

Changes the playback rate (i.e. the "speed" of playback). Defaults to `1.0` (normal speed). `2.0` would be 2x speed, etc.

```dart
  await player.setPlaybackRate(0.5); // half speed
```

### Release Mode

The release mode is controlling what happens when the playback ends. There are 3 options:

1. `.stop`: just stops the playback but keep all associated resources.
1. `.release` (default): releases all resources associated with this player, equivalent to calling the `release` method.
1. `.loop`: starts over after completion, looping over and over again.

```dart
  await player.setReleaseMode(ReleaseMode.loop);
```

**Note**: you can control exactly what happens when the playback ends using the `onPlayerComplete` stream (see Streams below).

**Note**: there are caveats when looping audio without gaps. Depending on the file format and platform, when audioplayers uses the native implementation of the "looping" feature, there will be gaps between plays, which might not be noticeable for non-continuous SFX but will definitely be noticeable for looping songs. Please check out the Gapless Loop section on our [Troubleshooting Guide](https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md) for more details.


### Player Mode

The Player Mode represents what kind of native SDK is used to playback audio, when multiple options are available (currently only relevant for Android). There are 2 options:

1. `.mediaPlayer` (default): for long media files or streams.
1. `.lowLatency`: for short audio files, since it reduces the impacts on visuals or UI performance.

**Note**: on low latency mode, these features are NOT available:
- get duration & duration event
- get position & position event
- playback completion event (this means you are responsible for stopping the player)
- seeking & seek completion event

Normally you want to use `.mediaPlayer` unless you care about performance and your audios are short (i.e. for sound effects in games).

## Logs

You can globally control the amount of log messages that are emitted by this package:

```dart
  AudioLogger.logLevel = AudioLogLevel.info;
```

You can pick one of 3 options:

1. `.info`: show any log messages, include info/debug messages
1. `.error` (default): show only error messages
1. `.none`: show no messages at all (not recommended)

**Note**: before opening any issue, always try changing the log level to `.info` to gather any information that might assist you with solving the problem.

**Note**: despite our best efforts, some native SDK implementations that we use spam a lot of log messages that we currently haven't figured out how to conform to this configuration (specially noticeable on Android). If you would like to contribute with a PR, they are more than welcome!

You can also listen for [Log events](#Log event).

## Audio Context

An Audio Context is a (mostly mobile-specific) set of secondary, platform-specific aspects of audio playback, typically related to how the act of playing audio interacts with other features of the device. In most cases, you do not need to change this.

The Audio Context configuration can be set globally for all players via:

```dart
  AudioPlayer.global.setAudioContext(AudioContextConfig(/*...*/).build());
```

To configure a player specific Audio Context (if desired), use:

```dart
  player.setAudioContext(AudioContextConfig(/*...*/).build());
```

**Note:** As the iOS platform can not handle contexts for each player individually, for convenience this would also set the Audio Context globally.

While each platform has its own set of configurations, they are somewhat related, and you can create them using a unified interface call [`AudioContextConfig`](https://pub.dev/documentation/audioplayers/latest/audioplayers/AudioContextConfig-class.html).
It provides generic abstractions that convey intent, that are then converted to platform specific configurations.

Note that if this process is not perfect, you can create your configuration from scratch by providing exact details for each platform via
[AudioContextAndroid](https://pub.dev/documentation/audioplayers_platform_interface/latest/audioplayers_platform_interface/AudioContextAndroid-class.html) and 
[AudioContextIOS](https://pub.dev/documentation/audioplayers_platform_interface/latest/audioplayers_platform_interface/AudioContextIOS-class.html).

```dart
  player.setAudioContext(AudioContext(
    android: AudioContextAndroid(/*...*/),
    iOS: AudioContextIOS(/*...*/),
  ));
```

## Streams

Each player has a variety of streams that can be used to listen to events, state changes, and other useful information coming from the player.
All streams also emit the same native platform errors via the `onError` callback.

#### Duration Event

This event returns the duration of the file, when it's available (it might take a while because it's being downloaded or buffered).

```dart
  player.onDurationChanged.listen((Duration d) {
    print('Max duration: $d');
    setState(() => duration = d);
  });
```

#### Position Event

This Event updates the current position of the audio. You can use it to make a progress bar, for instance.

```dart
  player.onPositionChanged.listen((Duration  p) => {
    print('Current position: $p');
    setState(() => position = p);
  });
```

#### State Event

This Event returns the current player state. You can use it to show if player playing, or stopped, or paused.

```dart
  player.onPlayerStateChanged.listen((PlayerState s) => {
    print('Current player state: $s');
    setState(() => playerState = s);
  });
```

#### Completion Event

This Event is called when the audio finishes playing; it's used in the loop method, for instance.

It does not fire when you interrupt the audio with pause or stop.

```dart
  player.onPlayerComplete.listen((_) {
    onComplete();
    setState(() {
      position = duration;
    });
  });
```

### Log event

This event returns the log messages from the native platform. 
The logs are handled by default via `Logger.log()`, and errors via `Logger.error()`, see [Logs](#Logs).

```dart
  player.onLog.listen(
    (String message) => Logger.log(message),
    onError: (Object e, [StackTrace? stackTrace]) => Logger.error(e, stackTrace),
  );
```

Or to handle global logs:

```dart
  AudioPlayer.global.onLog.listen(
    (String message) => Logger.log(message),
    onError: (Object e, [StackTrace? stackTrace]) => Logger.error(e, stackTrace),
  );
```

### Event Stream

All mentioned events can also be obtained by a combined event stream.

```dart
  player.eventStream.listen((AudioEvent event) {
    print(event.eventType);
  });
```

Or to handle global events:

```dart
  AudioPlayer.global.eventStream.listen((GlobalAudioEvent event) {
    print(event.eventType);
  });
```

## Advanced Concepts

### AudioCache

Flutter does not provide an easy way to play audio on your local assets, but that's where the `AudioCache` class comes into play. 
It actually copies the asset to a temporary folder in the device, where it is then played as a Local File.
It works as a cache because it keeps track of the copied files so that you can replay them without delay.

If desired, you can change the `AudioCache` per player via the `AudioPlayer().audioCache` property or for all players via `AudioCache.instance`.

#### Local Assets

When playing local assets, by default every instance of AudioPlayers uses a [shared global instance of AudioCache](https://pub.dev/documentation/audioplayers/latest/audioplayers/AudioPlayer/audioCache.html), that will have a [default prefix "/assets"](https://pub.dev/documentation/audioplayers/latest/audioplayers/AudioCache/prefix.html) configured, as per Flutter conventions.
However, you can easily change that by specifying your own instance of AudioCache with any other (or no) prefix.

Default behavior, presuming that your audio is stored in `/assets/audio/my-audio.wav`:
```dart
final player = AudioPlayer();
await player.play(AssetSource('audio/my-audio.wav'));
```

Remove the asset prefix for all players:
```dart
AudioCache.instance = AudioCache(prefix: '')
final player = AudioPlayer();
await player.play(AssetSource('assets/audio/my-audio.wav'));
```

Set a different prefix for only one player (e.g. when using assets from another package):
```dart
final player = AudioPlayer();
player.audioCache = AudioCache(prefix: 'packages/OTHER_PACKAGE/assets/')
await player.play(AssetSource('other-package-audio.wav'));
```

### playerId

By default, each time you initialize a new instance of AudioPlayer, a unique playerId is generated and assigned to it using the [uuid package](https://pub.dev/packages/uuid). 
This is used internally to route messages between multiple players, and it allows you to control multiple audios at the same time. 
If you want to specify the playerId, you can do so when creating the playing:

```dart
  final player = AudioPlayer(playerId: 'my_unique_playerId');
```

Two players with the same id will point to the same media player on the native side.

### PositionUpdater

By default, the position stream is updated on every new frame. You can change this behavior to e.g. update on a certain
interval with the `TimerPositionUpdater` or implement your own `PositionUpdater`:

```dart
  player.positionUpdater = TimerPositionUpdater(
    interval: const Duration(milliseconds: 100),
    getPosition: player.getCurrentPosition,
  );
```
