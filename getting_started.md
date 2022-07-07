# Getting Started

This tutorial should help you get started with the audioplayers library, covering the basics but guiding you all the way through advanced features. For a more code-based approach, check the code for [our official example app](https://github.com/bluefireteam/audioplayers/tree/main/packages/audioplayers/example), that showcases every feature the library has to offer.

In order to install this package, add the [latest version](pub.dev/packages/audioplayers) of `audioplayers` to your `pubspec.yaml` file. This packages uses [the Federated Plugin](https://docs.flutter.dev/development/packages-and-plugins/developing-packages) guidelines to support multiple platforms, so it should just work on all supported platforms your app is built for without any extra configuration. You should not need to add the `audioplayers_*` packages directly.

## Build Requirements

Audioplayers for Linux (`audioplayers_linux`) is the only platform implementation which relies on additional dependencies. You need to fulfill [these requirements](packages/audioplayers_linux/requirements.md).

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
1. **DeviceFileSource**: access a file in the user's device, probably selected by a file picker
1. **AssetSource**: play an asset bundled with your app, normally within the `assets` directory
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

### pause

Stops the playback but keeps the current position.

```dart
  await player.pause(); // will resume where left off
```

### stop

Stops the playback and also resets the current position.

```dart
  await player.stop(); // will resume from beginning
```

### release

Equivalent to calling `stop` and then disposing of any resources associated with this player.

This means that any streams will be disposed, memory might be de-allocated, etc.

Note that the player is also in a ready-to-use state; if you call `resume` again any necessary resources will be re-fetch.

Particularly on Android, the media player is quite resource-intensive, and this will let it go. Data will be buffered again when needed (if it's a remote file, it will be downloaded again.

### resume

Starts playback from current position (by default, from the start).

```dart
  await player.resume();
```

### play

Play is just a shortcut method that allows you to:

  * set a source
  * configure some player parameters (volume)
  * configure audio attributes
  * resume (start playing immediately)

All in a single function call. For most simple use cases, it might be the only method you need.

### seek

Changes the current position (note: this does not affect the "playing" status).

```dart
  await player.seek(Duration(milliseconds: 1200));
```

## Player Parameters

You can also change the following parameters:

### Volume

Changes the audio volume. Defaults to `1.0`. It can go from `0.0` (mute) to `1.0` (max; some platforms allow bigger than 1), varying linearly.

```dart
  await player.setVolume(0.5);
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

**Note**: you can control exactly what happens when the playback ends using the `onPlayerComplete` stream (see Streams below).

**Note**: there are caveats when looping audio without gaps. Depending on the file format and platform, when audioplayers uses the native implementation of the "looping" feature, there will be gaps between plays, witch might not be noticeable for non-continuous SFX but will definitely be noticeable for looping songs. Please check out the Gapless Loop section on our [Troubleshooting Guide](https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md) for more details.

### Player Mode

The Player Mode represents what kind of native SDK is used to playback audio, when multiple options are available (currently only relevant for Android). There are 2 options:

1. `.mediaPlayer` (default): for long media files or streams.
1. `.lowLatency`: for short audio files, since it reduces the impacts on visuals or UI performance.

**Note**: on low latency mode, the player won't fire any duration or position updates. Also, it is not possible to use the seek method to set the audio a specific position.

Normally you want to use `.mediaPlayer` unless you care about performance and your audios are short (i.e. for sound effects in games).

## Logs

You can globally control the amount of log messages that are emitted by this package:

```dart
  await AudioPlayer.global.changeLogLevel(LogLevel.info);
```

You can pick one of 3 options:

1. `.info`: show any log messages, include info/debug messages
1. `.error` (default): show only error messages
1. `.none`: show no messages at all (not recommended)

**Note**: before opening any issue, always try changing the log level to `.info` to gather any information that my assist you on solving the problem.

**Note**: despite our best efforts, some native SDK implementations that we use spam a lot of log messages that we currently haven't figured out how to conform to this configuration (specially noticeable on Android). If you would like to contribute with a PR, they are more than welcome!

## Audio Context

An Audio Context is a (mostly mobile-specific) set of secondary, platform-specific aspects of audio playback, typically related to how the act of playing audio interacts with other features of the device. In most cases, you do not need to change this.

The Audio Context configuration can be set globally via:

```dart
  AudioPlayer.global.setGlobalAudioContext(config);
```

This will naturally apply to all players. On iOS, that is the only option.
On Android only, each player can have different Audio Context configuration.
To configure player specific Audio Context (if desired), use:

```dart
  player.setAudioContext(config);
```

While each platform has its own set of configurations, they are somewhat related, and you can create them using a unified interface call `AudioContextConfig` -- it provides generic abstractions that convey intent, that are then converted to platform specific configurations.

Note that if this process is not perfect, you can create your configuration from scratch by providing exact details for each platform.

The [`AudioContextConfig` class has documentation about each parameter](https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers_platform_interface/lib/api/audio_context_config.dart), what they are for, and what configurations they reflect on native code.

## Streams

Each player has a variety of streams that can be used to listen to events, state changes, and other useful information coming from the player.

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
  player.onAudioPositionChanged.listen((Duration  p) => {
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
  player.onPlayerComplete.listen((event) {
    onComplete();
    setState(() {
      position = duration;
    });
  });
```

#### Error Event

This is called when an unexpected error is thrown in the native code.

```dart
  player.onPlayerError.listen((msg) {
    print('audioPlayer error : $msg');
    setState(() {
      playerState = PlayerState.stopped;
      duration = Duration(seconds: 0);
      position = Duration(seconds: 0);
    });
  });
```

## Advanced Concepts

### AudioCache

In order to play Local Assets, you must use the `AudioCache` class. AudioCache is not available for Flutter Web.

Flutter does not provide an easy way to play audio on your assets, but this class helps a lot. It actually copies the asset to a temporary folder in the device, where it is then played as a Local File.

It works as a cache because it keeps track of the copied files so that you can replay them without delay.

### playerId

By default, each time you initialize a new instance of AudioPlayer, a unique playerId is generated and assigned to it using the [uuid package](https://pub.dev/packages/uuid). This is used internally to route messages between multiple players, and it allows you to control multiple audios at the same time. If you want to specify the playerId, you can do so when creating the playing:

```dart
  final player = AudioPlayer(playerId: 'my_unique_playerId');
```

Two players with the same id will point to the same media player on the native side.
