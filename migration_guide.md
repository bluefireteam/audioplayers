# Migration Guide

## Migrate from v6 to v7

### `audioplayers_android_exo` is the default on Android ([#2031](https://github.com/bluefireteam/audioplayers/pull/2031))

The Android implementation is now based on [Media3 ExoPlayer](https://developer.android.com/media/media3/exoplayer).
If you already depend on `audioplayers_android_exo`, remove it from your `pubspec.yaml`, it is included now.

The player mode API (`PlayerMode`, `setPlayerMode`, `mode`, `AudioPool.playerMode`) is deprecated, as
`PlayerMode.lowLatency` has no effect anymore. You have the following options:

#### 1. Remove the player mode (recommended)

```dart
// Before
await player.setPlayerMode(PlayerMode.lowLatency);
await player.play(AssetSource('sfx/click.wav'));

// After
await player.play(AssetSource('sfx/click.wav'));
```

#### 2. Use an `AudioPool`

For short, frequently played sound effects:

```dart
final pool = await AudioPool.createFromAsset(path: 'sfx/click.wav', maxPlayers: 4);
final stop = await pool.start();
```

#### 3. Switch to `flutter_soloud`

If you need an even lower latency, e.g. for games, have a look at [`flutter_soloud`](https://pub.dev/packages/flutter_soloud).

#### 4. Opt out: keep using the deprecated `audioplayers_android`

```yaml
dependencies:
  audioplayers: ^7.0.0
  audioplayers_android: ^6.0.0
```

Please [open an issue](https://github.com/bluefireteam/audioplayers/issues) for any regression, so we can fix it
before `audioplayers_android` is discontinued.

### `AudioContextAndroid.stayAwake` is replaced by `wakeMode` ([#2033](https://github.com/bluefireteam/audioplayers/pull/2033))

- `AudioContextAndroid(stayAwake: true)` → `AudioContextAndroid(wakeMode: AndroidWakeMode.local)`
  (or `AndroidWakeMode.network` to also keep wifi awake while streaming)
- `AudioContextAndroid(stayAwake: false)` → `AudioContextAndroid(wakeMode: AndroidWakeMode.none)`
- `AudioContextConfig(stayAwake: ...)` is unchanged.

The default is now `none`. Wake modes other than `none` require the `android.permission.WAKE_LOCK` permission.

### Playing state is reported by the platform ([#1995](https://github.com/bluefireteam/audioplayers/pull/1995))

`resume()` / `play()` and `pause()` / `stop()` now complete once playback has actually started / stopped.

**Federated platform implementations** must emit `audio.onPlayingStateUpdate` (`value: <bool isPlaying>`) whenever
the native player starts or stops playing.

## Migrate from v5 to v6

- Minimum Flutter version is 3.13.0 ([#1612](https://github.com/bluefireteam/audioplayers/pull/1612)).
- Methods deprecated in v4 are removed, see [v3 to v4](#migrate-from-v3-to-v4) ([#1583](https://github.com/bluefireteam/audioplayers/pull/1583)).
- `AudioContextConfig(duckAudio: true)` → `AudioContextConfig(focus: AudioContextConfigFocus.duckOthers)` ([#1720](https://github.com/bluefireteam/audioplayers/pull/1720)).
- `AudioContextIOS(options: [...])` → `AudioContextIOS(options: {...})`, and `AudioContext` / `AudioContextIOS` are no longer `const` ([#1591](https://github.com/bluefireteam/audioplayers/pull/1591)).
- Position updates are handled in Dart, configurable via `AudioPlayer.positionUpdater`.
  Platform implementations no longer emit `AudioEventType.position` ([#1664](https://github.com/bluefireteam/audioplayers/pull/1664)).

## Migrate from v4 to v5

- Minimum Dart version is 3.0.0, minimum Flutter version is 3.10.0 ([#1529](https://github.com/bluefireteam/audioplayers/pull/1529)).
- The audio output defaults to the system preferences ([#1563](https://github.com/bluefireteam/audioplayers/pull/1563)).
  To keep the previous behavior, set `AudioContextConfig(route: AudioContextConfigRoute.speaker, stayAwake: true)`.

## Migrate from v3 to v4

| Before                                             | After                                        |
|----------------------------------------------------|----------------------------------------------|
| `AudioPlayer.global.changeLogLevel(LogLevel.info)` | `AudioLogger.logLevel = AudioLogLevel.info`  |
| `AudioPlayer.global.logLevel`                      | `AudioLogger.logLevel`                       |
| `AudioPlayer.global.log()`                         | `AudioLogger.log()` or `AudioLogger.error()` |
| `AudioPlayer.global.info()`                        | `AudioLogger.log()`                          |
| `AudioPlayer.global.error()`                       | `AudioLogger.error()`                        |
| `GlobalPlatformInterface`                          | `GlobalAudioScope`                           |
| `AudioPlayer.global.setGlobalAudioContext()`       | `AudioPlayer.global.setAudioContext()`       |
| `ForPlayer<>`                                      | _removed_                                    |

**Federated platform implementations:** import `package:audioplayers_platform_interface/audioplayers_platform_interface.dart`
and see [#1352](https://github.com/bluefireteam/audioplayers/pull/1352),
[#1442](https://github.com/bluefireteam/audioplayers/pull/1442) and
[#1443](https://github.com/bluefireteam/audioplayers/pull/1443) for renamed classes.

## Migrate from v2 to v3

- `PlayerMode.lowLatency` takes its presets from the `AudioContext`, e.g. set
  `AudioContextAndroid(usageType: AndroidUsageType.game)` ([#1388](https://github.com/bluefireteam/audioplayers/pull/1388)).
- `logger_platform_interface.dart` is renamed to `global_platform_interface.dart` ([#1385](https://github.com/bluefireteam/audioplayers/pull/1385)).

## Migrate from v1 to v2

- `AudioContextIOS(defaultToSpeaker: true)` → `AudioContextIOS(options: [AVAudioSessionOptions.defaultToSpeaker])` ([#1374](https://github.com/bluefireteam/audioplayers/pull/1374)).
- `AudioCache.clear` takes the file name as `String` instead of a `Uri` (v1.2.0, [#1347](https://github.com/bluefireteam/audioplayers/pull/1347)).

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
