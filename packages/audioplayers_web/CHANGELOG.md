## 5.0.0

> Note: This release has breaking changes.

 - **FEAT**: Support byte array and data URIs via mimeType ([#1763](https://github.com/bluefireteam/audioplayers/issues/1763)). ([eaf7ce86](https://github.com/bluefireteam/audioplayers/commit/eaf7ce86ad271097365fcf9e3a03fc341629ae47))
 - **FEAT**(web): Support compilation to Wasm ([#1766](https://github.com/bluefireteam/audioplayers/issues/1766)). ([1b1a0cf9](https://github.com/bluefireteam/audioplayers/commit/1b1a0cf92e950bc520598426d3f073c3bd5a6a28))
 - **BREAKING** **FEAT**: FramePositionUpdater & TimerPositionUpdater ([#1664](https://github.com/bluefireteam/audioplayers/issues/1664)). ([1ea93536](https://github.com/bluefireteam/audioplayers/commit/1ea93536b448fa5d43281cbc0a7b67445fc1a9a8))
 - **BREAKING** **DEPS**: Update min Flutter to v3.13.0, compatibility with v3.16.8 ([#1715](https://github.com/bluefireteam/audioplayers/issues/1715)). ([e4262f4c](https://github.com/bluefireteam/audioplayers/commit/e4262f4c0d6582c35738ace603583c81bd5a3b4b))

## 4.1.0

 - **FIX**: Improve Error handling for Unsupported Sources ([#1625](https://github.com/bluefireteam/audioplayers/issues/1625)). ([a4d84422](https://github.com/bluefireteam/audioplayers/commit/a4d84422f1421755b05aa7eff38b4d2ed0cf7482))
 - **FEAT**: Release source for Web, Linux, Windows ([#1517](https://github.com/bluefireteam/audioplayers/issues/1517)). ([09496dcb](https://github.com/bluefireteam/audioplayers/commit/09496dcbf478af330e37be833184439b43b5ac44))

## 4.0.0

> Note: This release has breaking changes.

 - **BREAKING** **CHORE**: Bump Flutter to version 3.10.x ([#1529](https://github.com/bluefireteam/audioplayers/issues/1529)). ([c1296c9b](https://github.com/bluefireteam/audioplayers/commit/c1296c9ba0cc43284b31d78f2f484454fbf6b773))

## 3.1.0

 - **REFACTOR**: Adapt to flame_lint v0.2.0+2 ([#1477](https://github.com/bluefireteam/audioplayers/issues/1477)). ([e1d7fb6a](https://github.com/bluefireteam/audioplayers/commit/e1d7fb6ab57c8a523c80dfc673bde3b7379b2add))
 - **FIX**: Timeout on setting same source twice  ([#1520](https://github.com/bluefireteam/audioplayers/issues/1520)). ([5d164d1f](https://github.com/bluefireteam/audioplayers/commit/5d164d1f20463a8a31a228cd1d85252d47ae256e))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: `AudioElement` is not getting released correctly ([#1516](https://github.com/bluefireteam/audioplayers/issues/1516)). ([32210f34](https://github.com/bluefireteam/audioplayers/commit/32210f34b186b44cc9c0484d7f67641162b325f6))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **FIX**(web): Avoid stutter when starting playback ([#1476](https://github.com/bluefireteam/audioplayers/issues/1476)). ([a28eed02](https://github.com/bluefireteam/audioplayers/commit/a28eed02f4e67e372d2b8f7c5bb271ffe6e09ec8))
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492](https://github.com/bluefireteam/audioplayers/issues/1492)). ([ab5bdf6a](https://github.com/bluefireteam/audioplayers/commit/ab5bdf6a2bcbf7e984d4d897e43a67b3684c52d8))

## 3.0.1

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))

## 3.0.0

> Note: This release has breaking changes.

 - **FIX**(web): make start and resume async ([#1436](https://github.com/bluefireteam/audioplayers/issues/1436)). ([b95bc8fa](https://github.com/bluefireteam/audioplayers/commit/b95bc8fa176e0d28a4d3d5ba6d26cafe699f1540))
 - **FEAT**: extract AudioContext from audio_context_config ([#1440](https://github.com/bluefireteam/audioplayers/issues/1440)). ([e59c3b9f](https://github.com/bluefireteam/audioplayers/commit/e59c3b9f07c1a72f9bf4e424fa3b011645f191d2))
 - **FEAT**(web): make setUrl async, make properties of `WrappedPlayer` private ([#1439](https://github.com/bluefireteam/audioplayers/issues/1439)). ([a051c335](https://github.com/bluefireteam/audioplayers/commit/a051c335a6cc0d1f6314f3f0c9f637920c3d6360))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **BREAKING** **REFACTOR**: prevent from confusing and conflicting class names ([#1465](https://github.com/bluefireteam/audioplayers/issues/1465)). ([7cdb8586](https://github.com/bluefireteam/audioplayers/commit/7cdb858605f24f0abd1a225e04922830233f3e96))
 - **BREAKING** **REFACTOR**: improve separation of global audioplayer interface ([#1443](https://github.com/bluefireteam/audioplayers/issues/1443)). ([c0b3f85c](https://github.com/bluefireteam/audioplayers/commit/c0b3f85c477f0313299cc2a2898840d6c7d8dcd9))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))
 - **BREAKING** **FEAT**: expose classes of package `audioplayers_platform_interface` ([#1442](https://github.com/bluefireteam/audioplayers/issues/1442)). ([a6f89be1](https://github.com/bluefireteam/audioplayers/commit/a6f89be181b7bd664eaf96cb9509bbc5adf5dbb9))

### Migration instructions

| Before | After |
|---|---|
| `AudioplayersPlugin` | `AudioplayersPlugin`, `WebAudioplayersPlatform` and `WebGlobalAudioplayersPlatform` |

## 2.2.0

 - **FIX**: use external factory for classes tagged with "@staticInterop" ([#1379](https://github.com/bluefireteam/audioplayers/issues/1379)). ([21d70504](https://github.com/bluefireteam/audioplayers/commit/21d7050455351b0c4ead9a3e2efbc8857115f247))

## 2.1.1

 - Update a dependency to the latest release.

## 2.1.0

 - **FIX**: handle infinite value on getDuration for live streams ([#1287](https://github.com/bluefireteam/audioplayers/issues/1287)). ([15f2c78f](https://github.com/bluefireteam/audioplayers/commit/15f2c78f79a68349fe33ac1a26ffc67cfaaf1211))
 - **FEAT**: add setBalance ([#58](https://github.com/bluefireteam/audioplayers/issues/58)) ([#1282](https://github.com/bluefireteam/audioplayers/issues/1282)). ([782fc9df](https://github.com/bluefireteam/audioplayers/commit/782fc9dff24a2ab9681496fd7c4c8fed451eac35))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))

## 2.0.1

 - **FIX**: handle infinite value on getDuration for live streams ([#1287](https://github.com/bluefireteam/audioplayers/issues/1287)). ([15f2c78f](https://github.com/bluefireteam/audioplayers/commit/15f2c78f79a68349fe33ac1a26ffc67cfaaf1211))

## 2.0.0

> Note: This release has breaking changes.

 - **FIX**: bugs from integration tests (#1268). ([d849c67f](https://github.com/bluefireteam/audioplayers/commit/d849c67f6916fb3800998d7d3f1c2752a5b9b9e7))
 - **FIX**: reset position, when stop or playing ended (#1246). ([d56f40fb](https://github.com/bluefireteam/audioplayers/commit/d56f40fbe89d2a5399f8cd0041b15150d6f72e01))
 - **FIX**: handle infinite duration (#1192). ([1d1600ba](https://github.com/bluefireteam/audioplayers/commit/1d1600bae372b1e07bd12966cd36571b6809d96a))
 - **BREAKING** **REFACTOR**: remove unused playerStateStream (#1280). ([27f9de22](https://github.com/bluefireteam/audioplayers/commit/27f9de224c7bc1f948356e917bf8b9c411fe9742))

## 1.0.0

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

## 1.0.0-rc.3

 - **FEAT**: Add onPlayerCompletion, onPlayerStateChanged and onDurationChanged for web (#1123). ([760e0c94](https://github.com/bluefireteam/audioplayers/commit/760e0c9443f4c63aadf4c5498767aeac6cd79346))

## 1.0.0-rc.2

## 1.0.0-rc.1

 - First release after federation

