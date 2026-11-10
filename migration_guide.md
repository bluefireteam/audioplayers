# Migration Guide

## Migrate from v6 to v7

### `audioplayers_android_exo` is the default on Android ([#2031](https://github.com/bluefireteam/audioplayers/pull/2031))

The Android implementation is now based on [Media3 ExoPlayer](https://developer.android.com/media/media3/exoplayer)
(`audioplayers_android_exo`). The former `audioplayers_android` (`MediaPlayer` / `SoundPool`) is deprecated.

- **Most apps:** nothing to do, the new implementation is picked up automatically.
- **Apps already depending on `audioplayers_android_exo`:** remove it from your `pubspec.yaml`, it is included now.
- **Opt out (temporarily):** add `audioplayers_android` to your app's `pubspec.yaml` to keep the old implementation,
  and please [open an issue](https://github.com/bluefireteam/audioplayers/issues) for any regression you encounter:

  ```yaml
  dependencies:
    audioplayers: ^7.0.0
    audioplayers_android: ^6.0.0
  ```

- **`PlayerMode` is deprecated** (`PlayerMode`, `AudioPlayer.setPlayerMode`, `AudioPlayer.mode`,
  `AudioPlayer.play(mode: ...)`, `AudioPool.playerMode`), as `PlayerMode.lowLatency` was only supported by
  `audioplayers_android`. On `audioplayers_android_exo`, it falls back to `PlayerMode.mediaPlayer` (the default).
  Remove any usage:

  ```dart
  // Before
  await player.setPlayerMode(PlayerMode.lowLatency);
  await player.play(AssetSource('sfx/click.wav'));

  // After
  await player.play(AssetSource('sfx/click.wav'));
  ```

  For short, frequently played sounds use an `AudioPool`
  (`await AudioPool.createFromAsset(path: 'sfx/click.wav', maxPlayers: 4)`), or for very low latency (e.g. games)
  consider [`flutter_soloud`](https://pub.dev/packages/flutter_soloud).

### `AudioContextAndroid.stayAwake` is replaced by `wakeMode` ([#2033](https://github.com/bluefireteam/audioplayers/pull/2033))

| Before                                     | After                                                                                                       |
|--------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `AudioContextAndroid(stayAwake: true)`     | `AudioContextAndroid(wakeMode: AndroidWakeMode.local)` (or `AndroidWakeMode.network` to also hold a wifi lock while streaming) |
| `AudioContextAndroid(stayAwake: false)`    | `AudioContextAndroid(wakeMode: AndroidWakeMode.none)`                                                       |
| `audioContextAndroid.copy(stayAwake: ...)` | `audioContextAndroid.copy(wakeMode: ...)`                                                                   |
| `AudioContextConfig(stayAwake: ...)`       | unchanged (`true` maps to `local`, `false` to `none`)                                                       |

The default is `AndroidWakeMode.none`. If playback must continue with the screen turned off, set a wake mode other
than `none` and add the `android.permission.WAKE_LOCK` permission to your `AndroidManifest.xml`.

### Playing state is reported by the platform ([#1995](https://github.com/bluefireteam/audioplayers/pull/1995))

The native players now emit a `PlayingStateUpdate` event, so `AudioPlayer.state` reflects the actual playback state:

- `resume()` / `play()` complete once playback has actually started, `pause()` / `stop()` once it has actually stopped.
  If you relied on these calls returning immediately, don't `await` them or adjust your timing logic.
- The player state also changes when playback is started or stopped from outside the app (e.g. by the system or via
  media controls), so listen to `onPlayerStateChanged` instead of tracking the state yourself.

**Federated platform implementations** must emit the event whenever the native player starts or stops playing:

```
{ "event": "audio.onPlayingStateUpdate", "value": <bool isPlaying> }
```

Otherwise `resume()`, `pause()` and `stop()` fail after `AudioPlayer.playingStateUpdateTimeout` (30 seconds by default).

## Migrate from v1 to higher versions

We recommend following the migration instructions for the breaking changes in the [changelog](CHANGELOG.md).

## Migrate from v0 to v1

Despite several major infrastructural changes in v1.0.0, it should be very easy to migrate for end users, as things overall just got simpler.

This document contains the list of major changes to be aware of.

First step is to add the latest version (see [pub.dev](https://pub.dev/packages/audioplayers) for the latest version) to your `pubspec.yaml`:

```yaml
  dependencies:
    audioplayers: ^2.0.0
```

### Federation, simplified platform interface

This change is here as an introduction but should require no change whatsoever on users side. But we split the package using the official [Federation](https://docs.flutter.dev/development/packages-and-plugins/developing-packages) process from Flutter. You still only need to import the final package `audioplayers` into your project, but know that that will fetch the relevant implementations for each platform you support as `audioplayers_x` packages.

In order to support this, we also created a vastly simplified `audioplayers_platform_interface` that is allowing us to add support for other platforms (eg desktop) much easier but removing any shortcuts or duplicated methods and leaving everything that can, to be implemented on the Dart side. Platforms have to deal with only the most basic building blocks they have to implement, and nothing else.

### AudioCache is dead, long live Sources

One of the main changes was my desire to "kill" the AudioCache API due to the vast confusion that it caused with users (despite our best efforts documenting everything).

We still have the AudioCache class but its APIs are _exclusively_ dedicated to transforming asset files into local files, cache them, and provide the path. It however doesn't normally need be used by end users because the AudioPlayer itself is now capable of playing audio from any Source.

What is a Source? It's a sealed class that can be one of:

1. **UrlSource**: get the audio from a remote URL from the Internet
1. **DeviceFileSource**: access a file in the user's device, probably selected by a file picker
1. **AssetSource**: play an asset bundled with your app, normally within the `assets` directory
1. **BytesSource** (only some platforms): pass in the bytes of your audio directly (read it from anywhere).

If you use **AssetSource**, the AudioPlayer will use its instance of AudioCache (which defaults to the global cache if unchanged) automatically. This unifies all playing APIs under AudioPlayer and entirely removes the AudioCache detail for most users.

### Simplified APIs, one method per task

We removed multiple overrides and used the concept of Sources to unify methods under AP. Now we have base, separated methods for:

1. `setSource` (taking a Source object; we also provide `setSourceX` as shortcuts)
1. `setVolume`
1. `setAudioContext` (though consider using `AudioPlayer.global.setGlobalAudioContext` instead)
1. `resume` (actually starts playing)

We still have (other than the handy `setSourceX` methods) one shortcut left: the `play` method. I think it's important to keep that as it might be easiest way for the most simple operation; it does:

1. set the source via a Source object
1. optionally sets the volume
1. optionally sets the audio context
1. optionally sets the position to seek
1. optionally sets the player mode
1. resumes (starts playing)

All in one go. We might decide whether to keep this shortcut or what parameters exactly to have on a next refactor. But for now we are very happy that we no longer have `play` and `playBytes` being essentially clones with different sources on `AudioPlayer` and then `AudioCache` having its own versions + looping versions (it was chaotic before).

### Enum name consolidation, some files were shuffled around

As per Dart's new best practices, all enums on the Dart side now have lowercase constants.

Also, some files might have been shuffled around (even between packages), but nothing that your IDE won't be able to quickly sort out.

### AudioContext

For some people, this will be irrelevant. For others, this might be the biggest change. Basically we collected all the random flags and parameters that were related to audio context/session configuration spread through the codebase on different methods, at different stages, into a single, unified configuration object called AudioContext, that can be set globally or per player (only for Android).

For more details, check the Audio Context section on the [Getting Started tutorial](getting_started.md), or the [class documentation itself](https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers_platform_interface/lib/api/audio_context_config.dart) (which is very comprehensive).
