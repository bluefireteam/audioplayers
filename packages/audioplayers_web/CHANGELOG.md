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

