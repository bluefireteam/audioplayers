## 5.1.1

 - **FIX**: Migrate to Melos v7 and Pub Workspaces ([#1929]). ([9d0bfe0b])

## 5.1.0

 - **FEAT**: Dispose players on Hot restart (closes [#1120]) ([#1905]). ([92bcb19e])

## 5.0.2

 - **DOCS**: Fix status badge ([#1899]). ([a0c6c4fa])

## 5.0.1

 - **DEPS**: Consider web:1.0.0 ([#1828]). ([9d25e78d])

## 5.0.0

> Note: This release has breaking changes.

 - **FEAT**: Support byte array and data URIs via mimeType ([#1763]). ([eaf7ce86])
 - **FEAT**(web): Support compilation to Wasm ([#1766]). ([1b1a0cf9])
 - **BREAKING** **FEAT**: FramePositionUpdater & TimerPositionUpdater ([#1664]). ([1ea93536])
 - **BREAKING** **DEPS**: Update min Flutter to v3.13.0, compatibility with v3.16.8 ([#1715]). ([e4262f4c])

## 4.1.0

 - **FIX**: Improve Error handling for Unsupported Sources ([#1625]). ([a4d84422])
 - **FEAT**: Release source for Web, Linux, Windows ([#1517]). ([09496dcb])

## 4.0.0

> Note: This release has breaking changes.

 - **BREAKING** **CHORE**: Bump Flutter to version 3.10.x ([#1529]). ([c1296c9b])

## 3.1.0

 - **REFACTOR**: Adapt to flame_lint v0.2.0+2 ([#1477]). ([e1d7fb6a])
 - **FIX**: Timeout on setting same source twice  ([#1520]). ([5d164d1f])
 - **FIX**: test and fix compatibility with min flutter version ([#1510]). ([9f39e95f])
 - **FIX**: `AudioElement` is not getting released correctly ([#1516]). ([32210f34])
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469]). ([50f56365])
 - **FIX**: rework dispose ([#1480]). ([c64ef6d9])
 - **FIX**(web): Avoid stutter when starting playback ([#1476]). ([a28eed02])
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492]). ([ab5bdf6a])

## 3.0.1

 - **FIX**: dispose player implementation ([#1470]). ([d9026c15])

## 3.0.0

> Note: This release has breaking changes.

 - **FIX**(web): make start and resume async ([#1436]). ([b95bc8fa])
 - **FEAT**: extract AudioContext from audio_context_config ([#1440]). ([e59c3b9f])
 - **FEAT**(web): make setUrl async, make properties of `WrappedPlayer` private ([#1439]). ([a051c335])
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457]). ([b8eb1974])
 - **BREAKING** **REFACTOR**: prevent from confusing and conflicting class names ([#1465]). ([7cdb8586])
 - **BREAKING** **REFACTOR**: improve separation of global audioplayer interface ([#1443]). ([c0b3f85c])
 - **BREAKING** **FEAT**: event channel ([#1352]). ([c9fd6a76])
 - **BREAKING** **FEAT**: expose classes of package `audioplayers_platform_interface` ([#1442]). ([a6f89be1])

### Migration instructions

| Before | After |
|---|---|
| `AudioplayersPlugin` | `AudioplayersPlugin`, `WebAudioplayersPlatform` and `WebGlobalAudioplayersPlatform` |

## 2.2.0

 - **FIX**: use external factory for classes tagged with "@staticInterop" ([#1379]). ([21d70504])

## 2.1.1

 - Update a dependency to the latest release.

## 2.1.0

 - **FIX**: handle infinite value on getDuration for live streams ([#1287]). ([15f2c78f])
 - **FEAT**: add setBalance ([#58]) ([#1282]). ([782fc9df])
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349]). ([0bdde4d9])

## 2.0.1

 - **FIX**: handle infinite value on getDuration for live streams ([#1287]). ([15f2c78f])

## 2.0.0

> Note: This release has breaking changes.

 - **FIX**: bugs from integration tests (#1268). ([d849c67f])
 - **FIX**: reset position, when stop or playing ended (#1246). ([d56f40fb])
 - **FIX**: handle infinite duration (#1192). ([1d1600ba])
 - **BREAKING** **REFACTOR**: remove unused playerStateStream (#1280). ([27f9de22])

## 1.0.0

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e])

## 1.0.0-rc.3

 - **FEAT**: Add onPlayerCompletion, onPlayerStateChanged and onDurationChanged for web (#1123). ([760e0c94])

## 1.0.0-rc.2

## 1.0.0-rc.1

 - First release after federation

