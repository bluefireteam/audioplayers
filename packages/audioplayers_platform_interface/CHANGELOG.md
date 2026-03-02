## 7.1.1

 - **FIX**: Migrate to Melos v7 and Pub Workspaces ([#1929]). ([9d0bfe0b])

## 7.1.0

 - **FEAT**: Dispose players on Hot restart (closes [#1120]) ([#1905]). ([92bcb19e])

## 7.0.1

 - **DOCS**: Fix status badge ([#1899]). ([a0c6c4fa])

## 7.0.0

> Note: This release has breaking changes.

 - **FEAT**: Support byte array and data URIs via mimeType ([#1763]). ([eaf7ce86])
 - **FEAT**(ios): Improved AudioContextConfig assertions, fix example ([#1619]). ([df342c52])
 - **DOCS**: Improve Docs ([#1710]). ([4208463a])
 - **BREAKING** **FEAT**: Extend `AudioContextConfig.duckAudio` to `AudioContextConfig.focus` ([#1720]). ([87f3cb7e])
 - **BREAKING** **FEAT**: FramePositionUpdater & TimerPositionUpdater ([#1664]). ([1ea93536])
 - **BREAKING** **FEAT**(ios): Improve AudioContextIOS ([#1591]). ([25fbec05])
 - **BREAKING** **DEPS**: Update min Flutter to v3.13.0, compatibility with v3.16.8 ([#1715]). ([e4262f4c])

## 6.1.0

 - **FIX**: Return null for duration and position, if not available ([#1606]). ([2a79644a])
 - **FEAT**: create, dispose & reuse event stream ([#1609]). ([efbabf5c])

## 6.0.0

> Note: This release has breaking changes.

 - **FIX**(android): Allow AudioFocus.none ([#1534]). ([858d3f44])
 - **BREAKING** **FIX**: Default audio output to system preferences ([#1563]). ([381c43e3])
 - **BREAKING** **CHORE**: Bump Flutter to version 3.10.x ([#1529]). ([c1296c9b])

## 5.0.1

 - **FIX**: AudioEvent missing `isPrepared` logic ([#1521]). ([1fa46c2c])
 - **FIX**: test and fix compatibility with min flutter version ([#1510]). ([9f39e95f])
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469]). ([50f56365])
 - **FIX**: rework dispose ([#1480]). ([c64ef6d9])
 - **DOCS**: Improve doc for 'AudioContextConfig.respectSilence' ([#1490]) ([#1500]). ([415dda3b])

## 5.0.0

> Note: This release has breaking changes.

 - **FEAT**: replace `Platform.isX` with `defaultTargetPlatform` ([#1446]). ([6cd5656c])
 - **FEAT**: extract AudioContext from audio_context_config ([#1440]). ([e59c3b9f])
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457]). ([b8eb1974])
 - **BREAKING** **REFACTOR**: prevent from confusing and conflicting class names ([#1465]). ([7cdb8586])
 - **BREAKING** **REFACTOR**: improve separation of global audioplayer interface ([#1443]). ([c0b3f85c])
 - **BREAKING** **FEAT**: event channel ([#1352]). ([c9fd6a76])
 - **BREAKING** **FEAT**: expose classes of package `audioplayers_platform_interface` ([#1442]). ([a6f89be1])

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

 - **BREAKING** **REFACTOR**: rename logger_platform_interface.dart to global_platform_interface.dart ([#1385]). ([6e837c1c])
 - **BREAKING** **FEAT**: configurable SoundPool and `AudioManager.mode` ([#1388]). ([5697f187])

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: remove unused `defaultToSpeaker` in `AudioContextIOS` and replace with `AVAudioSessionOptions.defaultToSpeaker` ([#1374]). ([d844ef9d])

## 2.1.0

> Note: This release has breaking changes.

 - **DOCS**: Fix repos and homepages on pubspecs ([#1349]). ([0bdde4d9])
 - **BREAKING** **FIX**: Change the default value of iOS audio context to force speakers ([#1363]). ([cb16c12d])

## 2.0.0

> Note: This release has breaking changes.

 - **FIX**: handle platform exception via logger (#1254). ([56df6edf])
 - **BREAKING** **REFACTOR**: remove unused playerStateStream (#1280). ([27f9de22])

## 1.0.0

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e])

## 1.0.0-rc.2

## 1.0.0-rc.1

 - First release after federation

