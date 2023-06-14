## 5.0.1

 - **FIX**: AudioEvent missing `isPrepared` logic ([#1521](https://github.com/bluefireteam/audioplayers/issues/1521)). ([1fa46c2c](https://github.com/bluefireteam/audioplayers/commit/1fa46c2cd28a4640c4aae65deee91ffe46cc4425))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **DOCS**: Improve doc for 'AudioContextConfig.respectSilence' ([#1490](https://github.com/bluefireteam/audioplayers/issues/1490)) ([#1500](https://github.com/bluefireteam/audioplayers/issues/1500)). ([415dda3b](https://github.com/bluefireteam/audioplayers/commit/415dda3b1621c57ea4b0366187f27f6a189555bf))

## 5.0.0

> Note: This release has breaking changes.

 - **FEAT**: replace `Platform.isX` with `defaultTargetPlatform` ([#1446](https://github.com/bluefireteam/audioplayers/issues/1446)). ([6cd5656c](https://github.com/bluefireteam/audioplayers/commit/6cd5656c0c5deaab1fb4af78a5b7632402c3a1d3))
 - **FEAT**: extract AudioContext from audio_context_config ([#1440](https://github.com/bluefireteam/audioplayers/issues/1440)). ([e59c3b9f](https://github.com/bluefireteam/audioplayers/commit/e59c3b9f07c1a72f9bf4e424fa3b011645f191d2))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **BREAKING** **REFACTOR**: prevent from confusing and conflicting class names ([#1465](https://github.com/bluefireteam/audioplayers/issues/1465)). ([7cdb8586](https://github.com/bluefireteam/audioplayers/commit/7cdb858605f24f0abd1a225e04922830233f3e96))
 - **BREAKING** **REFACTOR**: improve separation of global audioplayer interface ([#1443](https://github.com/bluefireteam/audioplayers/issues/1443)). ([c0b3f85c](https://github.com/bluefireteam/audioplayers/commit/c0b3f85c477f0313299cc2a2898840d6c7d8dcd9))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))
 - **BREAKING** **FEAT**: expose classes of package `audioplayers_platform_interface` ([#1442](https://github.com/bluefireteam/audioplayers/issues/1442)). ([a6f89be1](https://github.com/bluefireteam/audioplayers/commit/a6f89be181b7bd664eaf96cb9509bbc5adf5dbb9))

### Migration instructions

| Before | After |
|---|---|
| `LogLevel` | _moved_ to `audioplayers` package as `AudioLogLevel` |
| `AudioplayersPlatform` | `AudioplayersPlatformInterface` |
| `MethodChannelAudioplayersPlatform` | `AudioplayersPlatform` |
| `GlobalPlatformInterface` | `GlobalAudioplayersPlatformInterface` |
| `MethodChannelGlobalPlatform` | `GlobalAudioplayersPlatform` |
| `StreamsInterface` | _removed_ |
| `ForPlayer<>` | _removed_ |

## 4.0.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: rename logger_platform_interface.dart to global_platform_interface.dart ([#1385](https://github.com/bluefireteam/audioplayers/issues/1385)). ([6e837c1c](https://github.com/bluefireteam/audioplayers/commit/6e837c1ccd93b95d10843a403674128cf303c0ab))
 - **BREAKING** **FEAT**: configurable SoundPool and `AudioManager.mode` ([#1388](https://github.com/bluefireteam/audioplayers/issues/1388)). ([5697f187](https://github.com/bluefireteam/audioplayers/commit/5697f187bcca64de2e519f8f49aaf4817fcf6398))

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: remove unused `defaultToSpeaker` in `AudioContextIOS` and replace with `AVAudioSessionOptions.defaultToSpeaker` ([#1374](https://github.com/bluefireteam/audioplayers/issues/1374)). ([d844ef9d](https://github.com/bluefireteam/audioplayers/commit/d844ef9def06fd5047076d9f4c371ad3be4c8dd5))

## 2.1.0

> Note: This release has breaking changes.

 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))
 - **BREAKING** **FIX**: Change the default value of iOS audio context to force speakers ([#1363](https://github.com/bluefireteam/audioplayers/issues/1363)). ([cb16c12d](https://github.com/bluefireteam/audioplayers/commit/cb16c12d35655bbde5cd94ae1d6f2a03fd6eba1e))

## 2.0.0

> Note: This release has breaking changes.

 - **FIX**: handle platform exception via logger (#1254). ([56df6edf](https://github.com/bluefireteam/audioplayers/commit/56df6edfa1475e471c322c1180fd6f47d99c6610))
 - **BREAKING** **REFACTOR**: remove unused playerStateStream (#1280). ([27f9de22](https://github.com/bluefireteam/audioplayers/commit/27f9de224c7bc1f948356e917bf8b9c411fe9742))

## 1.0.0

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

## 1.0.0-rc.2

## 1.0.0-rc.1

 - First release after federation

