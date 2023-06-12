# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2023-05-29

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers` - `v4.1.0`](#audioplayers---v410)
 - [`audioplayers_android` - `v3.0.2`](#audioplayers_android---v302)
 - [`audioplayers_darwin` - `v4.1.0`](#audioplayers_darwin---v410)
 - [`audioplayers_linux` - `v2.1.0`](#audioplayers_linux---v210)
 - [`audioplayers_platform_interface` - `v5.0.1`](#audioplayers_platform_interface---v501)
 - [`audioplayers_web` - `v3.1.0`](#audioplayers_web---v310)
 - [`audioplayers_windows` - `v2.0.2`](#audioplayers_windows---v202)

---

#### `audioplayers` - `v4.1.0`

 - **REFACTOR**: Adapt to flame_lint v0.2.0+2 ([#1477](https://github.com/bluefireteam/audioplayers/issues/1477)). ([e1d7fb6a](https://github.com/bluefireteam/audioplayers/commit/e1d7fb6ab57c8a523c80dfc673bde3b7379b2add))
 - **FIX**: Timeout on setting same source twice  ([#1520](https://github.com/bluefireteam/audioplayers/issues/1520)). ([5d164d1f](https://github.com/bluefireteam/audioplayers/commit/5d164d1f20463a8a31a228cd1d85252d47ae256e))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492](https://github.com/bluefireteam/audioplayers/issues/1492)). ([ab5bdf6a](https://github.com/bluefireteam/audioplayers/commit/ab5bdf6a2bcbf7e984d4d897e43a67b3684c52d8))
 - **DOCS**: Improve docs ([#1518](https://github.com/bluefireteam/audioplayers/issues/1518)). ([4c0d5546](https://github.com/bluefireteam/audioplayers/commit/4c0d55465a8e75c13987b970dee648657eba4384))

#### `audioplayers_android` - `v3.0.2`

 - **FIX**(android): `onComplete` is not called when audio has completed playing ([#1523](https://github.com/bluefireteam/audioplayers/issues/1523)). ([293d6c0e](https://github.com/bluefireteam/audioplayers/commit/293d6c0eec1d89ad200b2914cae0adf644b25013))
 - **FIX**: Timeout on setting same source twice  ([#1520](https://github.com/bluefireteam/audioplayers/issues/1520)). ([5d164d1f](https://github.com/bluefireteam/audioplayers/commit/5d164d1f20463a8a31a228cd1d85252d47ae256e))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**(android): Add AGP 8 support with namespace property ([#1514](https://github.com/bluefireteam/audioplayers/issues/1514)). ([8d7b322e](https://github.com/bluefireteam/audioplayers/commit/8d7b322e79fd802fb75ca72f5c8ac388754cd406))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))

#### `audioplayers_darwin` - `v4.1.0`

 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492](https://github.com/bluefireteam/audioplayers/issues/1492)). ([ab5bdf6a](https://github.com/bluefireteam/audioplayers/commit/ab5bdf6a2bcbf7e984d4d897e43a67b3684c52d8))

#### `audioplayers_linux` - `v2.1.0`

 - **FIX**: Timeout on setting same source twice  ([#1520](https://github.com/bluefireteam/audioplayers/issues/1520)). ([5d164d1f](https://github.com/bluefireteam/audioplayers/commit/5d164d1f20463a8a31a228cd1d85252d47ae256e))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492](https://github.com/bluefireteam/audioplayers/issues/1492)). ([ab5bdf6a](https://github.com/bluefireteam/audioplayers/commit/ab5bdf6a2bcbf7e984d4d897e43a67b3684c52d8))

#### `audioplayers_platform_interface` - `v5.0.1`

 - **FIX**: AudioEvent missing `isPrepared` logic ([#1521](https://github.com/bluefireteam/audioplayers/issues/1521)). ([1fa46c2c](https://github.com/bluefireteam/audioplayers/commit/1fa46c2cd28a4640c4aae65deee91ffe46cc4425))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **DOCS**: Improve doc for 'AudioContextConfig.respectSilence' ([#1490](https://github.com/bluefireteam/audioplayers/issues/1490)) ([#1500](https://github.com/bluefireteam/audioplayers/issues/1500)). ([415dda3b](https://github.com/bluefireteam/audioplayers/commit/415dda3b1621c57ea4b0366187f27f6a189555bf))

#### `audioplayers_web` - `v3.1.0`

 - **REFACTOR**: Adapt to flame_lint v0.2.0+2 ([#1477](https://github.com/bluefireteam/audioplayers/issues/1477)). ([e1d7fb6a](https://github.com/bluefireteam/audioplayers/commit/e1d7fb6ab57c8a523c80dfc673bde3b7379b2add))
 - **FIX**: Timeout on setting same source twice  ([#1520](https://github.com/bluefireteam/audioplayers/issues/1520)). ([5d164d1f](https://github.com/bluefireteam/audioplayers/commit/5d164d1f20463a8a31a228cd1d85252d47ae256e))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: `AudioElement` is not getting released correctly ([#1516](https://github.com/bluefireteam/audioplayers/issues/1516)). ([32210f34](https://github.com/bluefireteam/audioplayers/commit/32210f34b186b44cc9c0484d7f67641162b325f6))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **FIX**(web): Avoid stutter when starting playback ([#1476](https://github.com/bluefireteam/audioplayers/issues/1476)). ([a28eed02](https://github.com/bluefireteam/audioplayers/commit/a28eed02f4e67e372d2b8f7c5bb271ffe6e09ec8))
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492](https://github.com/bluefireteam/audioplayers/issues/1492)). ([ab5bdf6a](https://github.com/bluefireteam/audioplayers/commit/ab5bdf6a2bcbf7e984d4d897e43a67b3684c52d8))

#### `audioplayers_windows` - `v2.0.2`

 - **FIX**: Timeout on setting same source twice  ([#1520](https://github.com/bluefireteam/audioplayers/issues/1520)). ([5d164d1f](https://github.com/bluefireteam/audioplayers/commit/5d164d1f20463a8a31a228cd1d85252d47ae256e))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))


## 2023-04-12

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers` - `v4.0.1`](#audioplayers---v401)
 - [`audioplayers_android` - `v3.0.1`](#audioplayers_android---v301)
 - [`audioplayers_darwin` - `v4.0.1`](#audioplayers_darwin---v401)
 - [`audioplayers_linux` - `v2.0.1`](#audioplayers_linux---v201)
 - [`audioplayers_web` - `v3.0.1`](#audioplayers_web---v301)
 - [`audioplayers_windows` - `v2.0.1`](#audioplayers_windows---v201)

---

#### `audioplayers` - `v4.0.1`

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))

#### `audioplayers_android` - `v3.0.1`

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))

#### `audioplayers_darwin` - `v4.0.1`

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))

#### `audioplayers_linux` - `v2.0.1`

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))

#### `audioplayers_web` - `v3.0.1`

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))

#### `audioplayers_windows` - `v2.0.1`

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))


## 2023-04-10

### Changes

---

Packages with breaking changes:

 - [`audioplayers` - `v4.0.0`](#audioplayers---v400)
 - [`audioplayers_android` - `v3.0.0`](#audioplayers_android---v300)
 - [`audioplayers_darwin` - `v4.0.0`](#audioplayers_darwin---v400)
 - [`audioplayers_linux` - `v2.0.0`](#audioplayers_linux---v200)
 - [`audioplayers_platform_interface` - `v5.0.0`](#audioplayers_platform_interface---v500)
 - [`audioplayers_web` - `v3.0.0`](#audioplayers_web---v300)
 - [`audioplayers_windows` - `v2.0.0`](#audioplayers_windows---v200)

Packages with other changes:

 - There are no other changes in this release.

---

#### `audioplayers` - `v4.0.0`

 - **FIX**(android): Avoid calling onDuration on position event (closes [#136](https://github.com/bluefireteam/audioplayers/issues/136)) ([#1460](https://github.com/bluefireteam/audioplayers/issues/1460)). ([6cfb3753](https://github.com/bluefireteam/audioplayers/commit/6cfb3753cd8003f341d97e0b2417d4512f452267))
 - **FEAT**: replace `Platform.isX` with `defaultTargetPlatform` ([#1446](https://github.com/bluefireteam/audioplayers/issues/1446)). ([6cd5656c](https://github.com/bluefireteam/audioplayers/commit/6cd5656c0c5deaab1fb4af78a5b7632402c3a1d3))
 - **FEAT**(example): add invalid asset, small refactor, colored source buttons ([#1445](https://github.com/bluefireteam/audioplayers/issues/1445)). ([92a20fad](https://github.com/bluefireteam/audioplayers/commit/92a20fadd6f549d44b7055b38a48fad2861a05c8))
 - **FEAT**(android): add `setBalance` ([#58](https://github.com/bluefireteam/audioplayers/issues/58)) ([#1444](https://github.com/bluefireteam/audioplayers/issues/1444)). ([3b5de50e](https://github.com/bluefireteam/audioplayers/commit/3b5de50ea7fa5248165616fc1ffd80da6c66583a))
 - **FEAT**: extract AudioContext from audio_context_config ([#1440](https://github.com/bluefireteam/audioplayers/issues/1440)). ([e59c3b9f](https://github.com/bluefireteam/audioplayers/commit/e59c3b9f07c1a72f9bf4e424fa3b011645f191d2))
 - **FEAT**(ios): set player context globally on `setAudioContext` for iOS only ([#1416](https://github.com/bluefireteam/audioplayers/issues/1416)). ([19af364b](https://github.com/bluefireteam/audioplayers/commit/19af364b7d0404ae436c54cdaa18d50f3a2aacd6))
 - **FEAT**(example): update app icons ([#1417](https://github.com/bluefireteam/audioplayers/issues/1417)). ([ac35df89](https://github.com/bluefireteam/audioplayers/commit/ac35df895cefe3d69dac4c8b1cf07c7f7ed56ca7))
 - **FEAT**: AudioPool (moved and improved from flame_audio) ([#1403](https://github.com/bluefireteam/audioplayers/issues/1403)). ([ab15cb02](https://github.com/bluefireteam/audioplayers/commit/ab15cb02cf939347772ac9fc961b5f01d7bad94b))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **DOCS**: update example app and screenshots ([#1419](https://github.com/bluefireteam/audioplayers/issues/1419)). ([c48eaf38](https://github.com/bluefireteam/audioplayers/commit/c48eaf389ab5b1cf1d51fadc814f473b8ea813cb))
 - **BREAKING** **REFACTOR**: prevent from confusing and conflicting class names ([#1465](https://github.com/bluefireteam/audioplayers/issues/1465)). ([7cdb8586](https://github.com/bluefireteam/audioplayers/commit/7cdb858605f24f0abd1a225e04922830233f3e96))
 - **BREAKING** **REFACTOR**: improve separation of global audioplayer interface ([#1443](https://github.com/bluefireteam/audioplayers/issues/1443)). ([c0b3f85c](https://github.com/bluefireteam/audioplayers/commit/c0b3f85c477f0313299cc2a2898840d6c7d8dcd9))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))
 - **BREAKING** **FEAT**: expose classes of package `audioplayers_platform_interface` ([#1442](https://github.com/bluefireteam/audioplayers/issues/1442)). ([a6f89be1](https://github.com/bluefireteam/audioplayers/commit/a6f89be181b7bd664eaf96cb9509bbc5adf5dbb9))

##### Migration instructions

| Before | After |
|---|---|
| deprecated `AudioPlayer.global.changeLogLevel(LogLevel.info)` | `AudioLogger.logLevel = AudioLogLevel.info` |
| deprecated `AudioPlayer.global.logLevel` | `AudioLogger.logLevel` |
| deprecated `AudioPlayer.global.log()` | `AudioLogger.log()` or `AudioLogger.error()` |
| deprecated `AudioPlayer.global.info()` | `AudioLogger.log()` |
| deprecated `AudioPlayer.global.error()` | `AudioLogger.error()` |
| `GlobalPlatformInterface` | `GlobalAudioScope` |
| deprecated `AudioPlayer.global.setGlobalAudioContext()` | `AudioPlayer.global.setAudioContext()` |
| `ForPlayer<>` | _removed_ |

#### `audioplayers_android` - `v3.0.0`

 - **FIX**(android): Avoid calling onDuration on position event (closes [#136](https://github.com/bluefireteam/audioplayers/issues/136)) ([#1460](https://github.com/bluefireteam/audioplayers/issues/1460)). ([6cfb3753](https://github.com/bluefireteam/audioplayers/commit/6cfb3753cd8003f341d97e0b2417d4512f452267))
 - **FIX**(android): reset prepared state on player error ([#1425](https://github.com/bluefireteam/audioplayers/issues/1425)). ([6f24c8f5](https://github.com/bluefireteam/audioplayers/commit/6f24c8f57e4549edbf7d68a021d1d94371c23f3f))
 - **FEAT**(android): add `setBalance` ([#58](https://github.com/bluefireteam/audioplayers/issues/58)) ([#1444](https://github.com/bluefireteam/audioplayers/issues/1444)). ([3b5de50e](https://github.com/bluefireteam/audioplayers/commit/3b5de50ea7fa5248165616fc1ffd80da6c66583a))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))

#### `audioplayers_darwin` - `v4.0.0`

 - **FIX**(iOS): Default to speaker instead of earpiece on iOS ([#1408](https://github.com/bluefireteam/audioplayers/issues/1408)). ([4ea5907b](https://github.com/bluefireteam/audioplayers/commit/4ea5907bfe5ce83a0d1c100acfc0760d00c2b448))
 - **FEAT**(ios): set player context globally on `setAudioContext` for iOS only ([#1416](https://github.com/bluefireteam/audioplayers/issues/1416)). ([19af364b](https://github.com/bluefireteam/audioplayers/commit/19af364b7d0404ae436c54cdaa18d50f3a2aacd6))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))

#### `audioplayers_linux` - `v2.0.0`

 - **FEAT**(windows): show nuget download info explicitely in verbose mode ([#1449](https://github.com/bluefireteam/audioplayers/issues/1449)). ([136028fa](https://github.com/bluefireteam/audioplayers/commit/136028fa1cbcf38f80e9cc7ad78b3bb89d2c6d30))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **DOCS**: Fix LICENSE files for windows and linux ([#1431](https://github.com/bluefireteam/audioplayers/issues/1431)). ([1f84e857](https://github.com/bluefireteam/audioplayers/commit/1f84e857a112e663fff73c4e7c6875ebb72c783d))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))

#### `audioplayers_platform_interface` - `v5.0.0`

 - **FEAT**: replace `Platform.isX` with `defaultTargetPlatform` ([#1446](https://github.com/bluefireteam/audioplayers/issues/1446)). ([6cd5656c](https://github.com/bluefireteam/audioplayers/commit/6cd5656c0c5deaab1fb4af78a5b7632402c3a1d3))
 - **FEAT**: extract AudioContext from audio_context_config ([#1440](https://github.com/bluefireteam/audioplayers/issues/1440)). ([e59c3b9f](https://github.com/bluefireteam/audioplayers/commit/e59c3b9f07c1a72f9bf4e424fa3b011645f191d2))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **BREAKING** **REFACTOR**: prevent from confusing and conflicting class names ([#1465](https://github.com/bluefireteam/audioplayers/issues/1465)). ([7cdb8586](https://github.com/bluefireteam/audioplayers/commit/7cdb858605f24f0abd1a225e04922830233f3e96))
 - **BREAKING** **REFACTOR**: improve separation of global audioplayer interface ([#1443](https://github.com/bluefireteam/audioplayers/issues/1443)). ([c0b3f85c](https://github.com/bluefireteam/audioplayers/commit/c0b3f85c477f0313299cc2a2898840d6c7d8dcd9))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))
 - **BREAKING** **FEAT**: expose classes of package `audioplayers_platform_interface` ([#1442](https://github.com/bluefireteam/audioplayers/issues/1442)). ([a6f89be1](https://github.com/bluefireteam/audioplayers/commit/a6f89be181b7bd664eaf96cb9509bbc5adf5dbb9))


##### Migration instructions

**audioplayers_platform_interface**:
| Before | After |
|---|---|
| `LogLevel` | _moved_ to `audioplayers` package as `AudioLogLevel` |
| `AudioplayersPlatform` | `AudioplayersPlatformInterface` |
| `MethodChannelAudioplayersPlatform` | `AudioplayersPlatform` |
| `GlobalPlatformInterface` | `GlobalAudioplayersPlatformInterface` |
| `MethodChannelGlobalPlatform` | `GlobalAudioplayersPlatform` |
| `StreamsInterface` | _removed_ |
| `ForPlayer<>` | _removed_ |


#### `audioplayers_web` - `v3.0.0`

 - **FIX**(web): make start and resume async ([#1436](https://github.com/bluefireteam/audioplayers/issues/1436)). ([b95bc8fa](https://github.com/bluefireteam/audioplayers/commit/b95bc8fa176e0d28a4d3d5ba6d26cafe699f1540))
 - **FEAT**: extract AudioContext from audio_context_config ([#1440](https://github.com/bluefireteam/audioplayers/issues/1440)). ([e59c3b9f](https://github.com/bluefireteam/audioplayers/commit/e59c3b9f07c1a72f9bf4e424fa3b011645f191d2))
 - **FEAT**(web): make setUrl async, make properties of `WrappedPlayer` private ([#1439](https://github.com/bluefireteam/audioplayers/issues/1439)). ([a051c335](https://github.com/bluefireteam/audioplayers/commit/a051c335a6cc0d1f6314f3f0c9f637920c3d6360))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **BREAKING** **REFACTOR**: prevent from confusing and conflicting class names ([#1465](https://github.com/bluefireteam/audioplayers/issues/1465)). ([7cdb8586](https://github.com/bluefireteam/audioplayers/commit/7cdb858605f24f0abd1a225e04922830233f3e96))
 - **BREAKING** **REFACTOR**: improve separation of global audioplayer interface ([#1443](https://github.com/bluefireteam/audioplayers/issues/1443)). ([c0b3f85c](https://github.com/bluefireteam/audioplayers/commit/c0b3f85c477f0313299cc2a2898840d6c7d8dcd9))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))
 - **BREAKING** **FEAT**: expose classes of package `audioplayers_platform_interface` ([#1442](https://github.com/bluefireteam/audioplayers/issues/1442)). ([a6f89be1](https://github.com/bluefireteam/audioplayers/commit/a6f89be181b7bd664eaf96cb9509bbc5adf5dbb9))

##### Migration instructions

**audioplayers_web**:
| Before | After |
|---|---|
| `AudioplayersPlugin` | `AudioplayersPlugin`, `WebAudioplayersPlatform` and `WebGlobalAudioplayersPlatform` |

#### `audioplayers_windows` - `v2.0.0`

 - **FEAT**(windows): show nuget download info explicitely in verbose mode ([#1449](https://github.com/bluefireteam/audioplayers/issues/1449)). ([136028fa](https://github.com/bluefireteam/audioplayers/commit/136028fa1cbcf38f80e9cc7ad78b3bb89d2c6d30))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **DOCS**: Fix LICENSE files for windows and linux ([#1431](https://github.com/bluefireteam/audioplayers/issues/1431)). ([1f84e857](https://github.com/bluefireteam/audioplayers/commit/1f84e857a112e663fff73c4e7c6875ebb72c783d))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))


## 2023-01-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers_darwin` - `v3.0.1`](#audioplayers_darwin---v301)
 - [`audioplayers` - `v3.0.1`](#audioplayers---v301)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `audioplayers` - `v3.0.1`

---

#### `audioplayers_darwin` - `v3.0.1`

 - Fix duplicated path_providers plugins


## 2023-01-24

### Changes

---

Packages with breaking changes:

 - [`audioplayers` - `v3.0.0`](#audioplayers---v300)
 - [`audioplayers_android` - `v2.0.0`](#audioplayers_android---v200)
 - [`audioplayers_platform_interface` - `v4.0.0`](#audioplayers_platform_interface---v400)

Packages with other changes:

 - [`audioplayers_web` - `v2.2.0`](#audioplayers_web---v220)

---

#### `audioplayers` - `v3.0.0`

 - **FEAT**: add and remove player actions ([#1394](https://github.com/bluefireteam/audioplayers/issues/1394)). ([f06cab91](https://github.com/bluefireteam/audioplayers/commit/f06cab91fbae65d7fdc9e3fbd75171b391ac0b96))
 - **FEAT**: example improvements ([#1392](https://github.com/bluefireteam/audioplayers/issues/1392)). ([002e2fc9](https://github.com/bluefireteam/audioplayers/commit/002e2fc950145e3231ab79a5ef399024d62f6fb1))
 - **BREAKING** **REFACTOR**: rename logger_platform_interface.dart to global_platform_interface.dart ([#1385](https://github.com/bluefireteam/audioplayers/issues/1385)). ([6e837c1c](https://github.com/bluefireteam/audioplayers/commit/6e837c1ccd93b95d10843a403674128cf303c0ab))
 - **BREAKING** **FEAT**: configurable SoundPool and `AudioManager.mode` ([#1388](https://github.com/bluefireteam/audioplayers/issues/1388)). ([5697f187](https://github.com/bluefireteam/audioplayers/commit/5697f187bcca64de2e519f8f49aaf4817fcf6398))

#### `audioplayers_android` - `v2.0.0`

 - **FIX**: playing at playback rate `1.0` in android API level < 23 (fixes [#1344](https://github.com/bluefireteam/audioplayers/issues/1344)) ([#1390](https://github.com/bluefireteam/audioplayers/issues/1390)). ([b248e71d](https://github.com/bluefireteam/audioplayers/commit/b248e71dabf923072f1fd14355b4e0230c9a6593))
 - **BREAKING** **FEAT**: configurable SoundPool and `AudioManager.mode` ([#1388](https://github.com/bluefireteam/audioplayers/issues/1388)). ([5697f187](https://github.com/bluefireteam/audioplayers/commit/5697f187bcca64de2e519f8f49aaf4817fcf6398))

#### `audioplayers_platform_interface` - `v4.0.0`

 - **BREAKING** **REFACTOR**: rename logger_platform_interface.dart to global_platform_interface.dart ([#1385](https://github.com/bluefireteam/audioplayers/issues/1385)). ([6e837c1c](https://github.com/bluefireteam/audioplayers/commit/6e837c1ccd93b95d10843a403674128cf303c0ab))
 - **BREAKING** **FEAT**: configurable SoundPool and `AudioManager.mode` ([#1388](https://github.com/bluefireteam/audioplayers/issues/1388)). ([5697f187](https://github.com/bluefireteam/audioplayers/commit/5697f187bcca64de2e519f8f49aaf4817fcf6398))

#### `audioplayers_web` - `v2.2.0`

 - **FIX**: use external factory for classes tagged with "@staticInterop" ([#1379](https://github.com/bluefireteam/audioplayers/issues/1379)). ([21d70504](https://github.com/bluefireteam/audioplayers/commit/21d7050455351b0c4ead9a3e2efbc8857115f247))


## 2023-01-10

### Changes

---

Packages with breaking changes:

 - [`audioplayers` - `v2.0.0`](#audioplayers---v200)
 - [`audioplayers_darwin` - `v2.0.0`](#audioplayers_darwin---v200)
 - [`audioplayers_platform_interface` - `v3.0.0`](#audioplayers_platform_interface---v300)

Packages with other changes:

 - [`audioplayers_android` - `v1.1.4`](#audioplayers_android---v114)
 - [`audioplayers_windows` - `v1.1.2`](#audioplayers_windows---v112)
 - [`audioplayers_linux` - `v1.0.3`](#audioplayers_linux---v103)
 - [`audioplayers_web` - `v2.1.1`](#audioplayers_web---v211)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `audioplayers_android` - `v1.1.4`
 - `audioplayers_windows` - `v1.1.2`
 - `audioplayers_linux` - `v1.0.3`
 - `audioplayers_web` - `v2.1.1`

---

#### `audioplayers` - `v2.0.0`

 - **BREAKING** **FIX**: remove unused `defaultToSpeaker` in `AudioContextIOS` and replace with `AVAudioSessionOptions.defaultToSpeaker` ([#1374](https://github.com/bluefireteam/audioplayers/issues/1374)). ([d844ef9d](https://github.com/bluefireteam/audioplayers/commit/d844ef9def06fd5047076d9f4c371ad3be4c8dd5))

#### `audioplayers_darwin` - `v2.0.0`

 - **BREAKING** **FIX**: remove unused `defaultToSpeaker` in `AudioContextIOS` and replace with `AVAudioSessionOptions.defaultToSpeaker` ([#1374](https://github.com/bluefireteam/audioplayers/issues/1374)). ([d844ef9d](https://github.com/bluefireteam/audioplayers/commit/d844ef9def06fd5047076d9f4c371ad3be4c8dd5))

#### `audioplayers_platform_interface` - `v3.0.0`

 - **BREAKING** **FIX**: remove unused `defaultToSpeaker` in `AudioContextIOS` and replace with `AVAudioSessionOptions.defaultToSpeaker` ([#1374](https://github.com/bluefireteam/audioplayers/issues/1374)). ([d844ef9d](https://github.com/bluefireteam/audioplayers/commit/d844ef9def06fd5047076d9f4c371ad3be4c8dd5))


## 2023-01-01

### Changes

---

Packages with breaking changes:

 - [`audioplayers` - `v1.2.0`](#audioplayers---v120)
 - [`audioplayers_platform_interface` - `v2.1.0`](#audioplayers_platform_interface---v210)

Packages with other changes:

 - [`audioplayers_android` - `v1.1.3`](#audioplayers_android---v113)
 - [`audioplayers_darwin` - `v1.0.4`](#audioplayers_darwin---v104)
 - [`audioplayers_linux` - `v1.0.2`](#audioplayers_linux---v102)
 - [`audioplayers_web` - `v2.1.0`](#audioplayers_web---v210)
 - [`audioplayers_windows` - `v1.1.1`](#audioplayers_windows---v111)

---

#### `audioplayers` - `v1.2.0`

 - **FIX**: Duration precision on Windows ([#1342](https://github.com/bluefireteam/audioplayers/issues/1342)). ([3cda1a65](https://github.com/bluefireteam/audioplayers/commit/3cda1a65dc0425c332ed2eb3619cd88531f0ea49))
 - **FIX**: infinity / nan on getDuration ([#1298](https://github.com/bluefireteam/audioplayers/issues/1298)). ([a4474dcf](https://github.com/bluefireteam/audioplayers/commit/a4474dcf5e14fbd74db8b4f19223b9bfa40ed5f5))
 - **FEAT**: upgrade flutter to v3.0.0 and dart 2.17 to support "Super initializers" ([#1355](https://github.com/bluefireteam/audioplayers/issues/1355)). ([4af417b4](https://github.com/bluefireteam/audioplayers/commit/4af417b4c91ed5c22d6c48e05080c3018ccaee42))
 - **FEAT**: local test server ([#1354](https://github.com/bluefireteam/audioplayers/issues/1354)). ([06be429a](https://github.com/bluefireteam/audioplayers/commit/06be429a0078456a989b9afc3abc68164c4abaab))
 - **FEAT**: get current source ([#1350](https://github.com/bluefireteam/audioplayers/issues/1350)). ([7a10be38](https://github.com/bluefireteam/audioplayers/commit/7a10be38ec6613c8ef45bb33d1e81f11bb5988f9))
 - **FEAT**: log path and url of sources ([#1334](https://github.com/bluefireteam/audioplayers/issues/1334)). ([8a13f96d](https://github.com/bluefireteam/audioplayers/commit/8a13f96dbb14be0d1d80577816246109c42b7983))
 - **FEAT**: add setBalance ([#58](https://github.com/bluefireteam/audioplayers/issues/58)) ([#1282](https://github.com/bluefireteam/audioplayers/issues/1282)). ([782fc9df](https://github.com/bluefireteam/audioplayers/commit/782fc9dff24a2ab9681496fd7c4c8fed451eac35))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))
 - **BREAKING** **FIX**: Cache should take key to be properly cleared ([#1347](https://github.com/bluefireteam/audioplayers/issues/1347)). ([1a410bba](https://github.com/bluefireteam/audioplayers/commit/1a410bba578af506637b026bb2c4ace03a161a69))

#### `audioplayers_platform_interface` - `v2.1.0`

 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))
 - **BREAKING** **FIX**: Change the default value of iOS audio context to force speakers ([#1363](https://github.com/bluefireteam/audioplayers/issues/1363)). ([cb16c12d](https://github.com/bluefireteam/audioplayers/commit/cb16c12d35655bbde5cd94ae1d6f2a03fd6eba1e))

#### `audioplayers_android` - `v1.1.3`

 - **FIX**: Avoid ConcurrentModificationException ([#1297](https://github.com/bluefireteam/audioplayers/issues/1297)). ([d15ef5ab](https://github.com/bluefireteam/audioplayers/commit/d15ef5ab93f11e2f19089af08f1533fcdc1397e6))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))

#### `audioplayers_darwin` - `v1.0.4`

 - **FIX**: infinity / nan on getDuration ([#1298](https://github.com/bluefireteam/audioplayers/issues/1298)). ([a4474dcf](https://github.com/bluefireteam/audioplayers/commit/a4474dcf5e14fbd74db8b4f19223b9bfa40ed5f5))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))

#### `audioplayers_linux` - `v1.0.2`

 - **FIX**: play sound, when initialized ([#1332](https://github.com/bluefireteam/audioplayers/issues/1332)). ([2ed91fee](https://github.com/bluefireteam/audioplayers/commit/2ed91feec4d3528a4edff635331bd3aad938afd7))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))

#### `audioplayers_web` - `v2.1.0`

 - **FIX**: handle infinite value on getDuration for live streams ([#1287](https://github.com/bluefireteam/audioplayers/issues/1287)). ([15f2c78f](https://github.com/bluefireteam/audioplayers/commit/15f2c78f79a68349fe33ac1a26ffc67cfaaf1211))
 - **FEAT**: add setBalance ([#58](https://github.com/bluefireteam/audioplayers/issues/58)) ([#1282](https://github.com/bluefireteam/audioplayers/issues/1282)). ([782fc9df](https://github.com/bluefireteam/audioplayers/commit/782fc9dff24a2ab9681496fd7c4c8fed451eac35))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))

#### `audioplayers_windows` - `v1.1.1`

 - **FIX**: Duration precision on Windows ([#1342](https://github.com/bluefireteam/audioplayers/issues/1342)). ([3cda1a65](https://github.com/bluefireteam/audioplayers/commit/3cda1a65dc0425c332ed2eb3619cd88531f0ea49))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))


## 2022-10-08

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers` - `v1.1.1`](#audioplayers---v111)
 - [`audioplayers_android` - `v1.1.1`](#audioplayers_android---v111)
 - [`audioplayers_darwin` - `v1.0.3`](#audioplayers_darwin---v103)
 - [`audioplayers_web` - `v2.0.1`](#audioplayers_web---v201)

---

#### `audioplayers` - `v1.1.1`

 - **FIX**: infinity / nan on getDuration ([#1298](https://github.com/bluefireteam/audioplayers/issues/1298)). ([a4474dcf](https://github.com/bluefireteam/audioplayers/commit/a4474dcf5e14fbd74db8b4f19223b9bfa40ed5f5))

#### `audioplayers_android` - `v1.1.1`

 - **FIX**: Avoid ConcurrentModificationException ([#1297](https://github.com/bluefireteam/audioplayers/issues/1297)). ([d15ef5ab](https://github.com/bluefireteam/audioplayers/commit/d15ef5ab93f11e2f19089af08f1533fcdc1397e6))

#### `audioplayers_darwin` - `v1.0.3`

 - **FIX**: infinity / nan on getDuration ([#1298](https://github.com/bluefireteam/audioplayers/issues/1298)). ([a4474dcf](https://github.com/bluefireteam/audioplayers/commit/a4474dcf5e14fbd74db8b4f19223b9bfa40ed5f5))

#### `audioplayers_web` - `v2.0.1`

 - **FIX**: handle infinite value on getDuration for live streams ([#1287](https://github.com/bluefireteam/audioplayers/issues/1287)). ([15f2c78f](https://github.com/bluefireteam/audioplayers/commit/15f2c78f79a68349fe33ac1a26ffc67cfaaf1211))


## 2022-09-26

### Changes

---

Packages with breaking changes:

 - [`audioplayers_platform_interface` - `v2.0.0`](#audioplayers_platform_interface---v200)
 - [`audioplayers_web` - `v2.0.0`](#audioplayers_web---v200)

Packages with other changes:

 - [`audioplayers` - `v1.1.0`](#audioplayers---v110)
 - [`audioplayers_android` - `v1.1.0`](#audioplayers_android---v110)
 - [`audioplayers_darwin` - `v1.0.2`](#audioplayers_darwin---v102)
 - [`audioplayers_linux` - `v1.0.1`](#audioplayers_linux---v101)
 - [`audioplayers_windows` - `v1.1.0`](#audioplayers_windows---v110)

---

#### `audioplayers_platform_interface` - `v2.0.0`

 - **FIX**: handle platform exception via logger (#1254). ([56df6edf](https://github.com/bluefireteam/audioplayers/commit/56df6edfa1475e471c322c1180fd6f47d99c6610))
 - **BREAKING** **REFACTOR**: remove unused playerStateStream (#1280). ([27f9de22](https://github.com/bluefireteam/audioplayers/commit/27f9de224c7bc1f948356e917bf8b9c411fe9742))

#### `audioplayers_web` - `v2.0.0`

 - **FIX**: bugs from integration tests (#1268). ([d849c67f](https://github.com/bluefireteam/audioplayers/commit/d849c67f6916fb3800998d7d3f1c2752a5b9b9e7))
 - **FIX**: reset position, when stop or playing ended (#1246). ([d56f40fb](https://github.com/bluefireteam/audioplayers/commit/d56f40fbe89d2a5399f8cd0041b15150d6f72e01))
 - **FIX**: handle infinite duration (#1192). ([1d1600ba](https://github.com/bluefireteam/audioplayers/commit/1d1600bae372b1e07bd12966cd36571b6809d96a))
 - **BREAKING** **REFACTOR**: remove unused playerStateStream (#1280). ([27f9de22](https://github.com/bluefireteam/audioplayers/commit/27f9de224c7bc1f948356e917bf8b9c411fe9742))

#### `audioplayers` - `v1.1.0`

 - **FIX**: player state not being updated to completed (#1257). ([70a37afb](https://github.com/bluefireteam/audioplayers/commit/70a37afb6ce4fbb8b8c680ca9b6804b005012446))
 - **FIX**: lowLatency bugs (closes #1176, closes #1193, closes #1165) (#1272). ([541578cc](https://github.com/bluefireteam/audioplayers/commit/541578cc50f3856c23c393faa1a71380b3b49222))
 - **FIX**: ios/macos no longer start audio when calling only setSourceUrl (#1206). ([c0e97f04](https://github.com/bluefireteam/audioplayers/commit/c0e97f04fb05fb109830d6363f5c44dccbd327b4))
 - **FEAT**: improve example (#1267). ([a8154da1](https://github.com/bluefireteam/audioplayers/commit/a8154da1cc6fdec80d80fa538d65cb491a33db78))
 - **FEAT**: Platform integration tests 🤖 (#1128). ([b0c84aab](https://github.com/bluefireteam/audioplayers/commit/b0c84aabea8af28f693941c1b3bf2b1fa1048833))
 - **DOCS**: Remove 11-month old outdated doc file (#1180). ([bae43cb1](https://github.com/bluefireteam/audioplayers/commit/bae43cb10a27eff23ebaf2a6ac796fd61039f359))

#### `audioplayers_android` - `v1.1.0`

 - **FIX**: lowLatency bugs (closes #1176, closes #1193, closes #1165) (#1272). ([541578cc](https://github.com/bluefireteam/audioplayers/commit/541578cc50f3856c23c393faa1a71380b3b49222))
 - **FIX**: revert compileSdkVersion to be compatible with flutter.compileSdkVersion (#1273). ([0b9fed43](https://github.com/bluefireteam/audioplayers/commit/0b9fed43d9dfa90870826dc9a34d1a0d730bd78d))
 - **FIX**: emit onPositionChanged when seek is completed (closes #1259) (#1265). ([be7ac6a9](https://github.com/bluefireteam/audioplayers/commit/be7ac6a957fccadf5bcecf0f1fbea197d32bda21))
 - **FIX**: bugs from integration tests (#1247). ([6fad1cc4](https://github.com/bluefireteam/audioplayers/commit/6fad1cc4443e623e5c94519f130b4004b2dc3857))
 - **FIX**: Fix lowLatency mode for Android (#1193) (#1224). ([a25ca284](https://github.com/bluefireteam/audioplayers/commit/a25ca284835252147c85944575c7e71a3ef6abc4))
 - **FEAT**: wait for source to be prepared (#1191). ([5eeca894](https://github.com/bluefireteam/audioplayers/commit/5eeca8940e764546023567fa2f6b1bc3802f97d3))

#### `audioplayers_darwin` - `v1.0.2`

 - **FIX**: update platform to 9.0 in podspec. (#1171). ([f8cbd972](https://github.com/bluefireteam/audioplayers/commit/f8cbd972b56b75c8cf204af38f953f322dc98ab1))
 - **FIX**: ios/macos no longer start audio when calling only setSourceUrl (#1206). ([c0e97f04](https://github.com/bluefireteam/audioplayers/commit/c0e97f04fb05fb109830d6363f5c44dccbd327b4))

#### `audioplayers_linux` - `v1.0.1`

 - **FIX**: emit position event immediately when resume (#1222). ([94c73482](https://github.com/bluefireteam/audioplayers/commit/94c73482b0141d5f6c202219948fc79bac40b288))
 - **DOCS**: update README, Linux: replace with symlink, update Requirements (#1190). ([72e3d500](https://github.com/bluefireteam/audioplayers/commit/72e3d50067e274a8efb6b646a3318ae5fa097a77))

#### `audioplayers_windows` - `v1.1.0`

 - **FIX**: send onDuration event when play/resume (#1245). ([8108ff42](https://github.com/bluefireteam/audioplayers/commit/8108ff42d05c7f995d8289345302c6ac6d298f67))
 - **FEAT**: select decoder automatically on windows (#1221). ([ff78a42f](https://github.com/bluefireteam/audioplayers/commit/ff78a42f842e146df7dc98d6d00ae27821355653))


## 2022-06-18

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers` - `v1.0.1`](#audioplayers---v101)
 - [`audioplayers_android` - `v1.0.1`](#audioplayers_android---v101)
 - [`audioplayers_darwin` - `v1.0.1`](#audioplayers_darwin---v101)

---

#### `audioplayers` - `v1.0.1`

 - **FIX**: Make sure onComplete resets the position even when not looping (#1175). ([6e6005ac](https://github.com/bluefireteam/audioplayers/commit/6e6005ac98765aeeea62208b58a6cc6d0cb4b084))

#### `audioplayers_android` - `v1.0.1`

 - **FIX**: getDuration, getPosition causes MEDIA_ERROR_UNKNOWN (#1172). ([51b4c73e](https://github.com/bluefireteam/audioplayers/commit/51b4c73eaff5c60d1c3c3e42ae783df07d34be09))

#### `audioplayers_darwin` - `v1.0.1`

 - **FIX**: Make sure onComplete resets the position even when not looping (#1175). ([6e6005ac](https://github.com/bluefireteam/audioplayers/commit/6e6005ac98765aeeea62208b58a6cc6d0cb4b084))


## 2022-06-12

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers` - `v1.0.0`](#audioplayers---v100)
 - [`audioplayers_android` - `v1.0.0`](#audioplayers_android---v100)
 - [`audioplayers_darwin` - `v1.0.0`](#audioplayers_darwin---v100)
 - [`audioplayers_linux` - `v1.0.0`](#audioplayers_linux---v100)
 - [`audioplayers_platform_interface` - `v1.0.0`](#audioplayers_platform_interface---v100)
 - [`audioplayers_web` - `v1.0.0`](#audioplayers_web---v100)
 - [`audioplayers_windows` - `v1.0.0`](#audioplayers_windows---v100)

---

#### `audioplayers` - `v1.0.0`

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

#### `audioplayers_android` - `v1.0.0`

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

#### `audioplayers_darwin` - `v1.0.0`

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

#### `audioplayers_linux` - `v1.0.0`

 - **FIX**: missing onDuration event, free previous source when set url on Linux (#1129). ([b523a39e](https://github.com/bluefireteam/audioplayers/commit/b523a39e253dd461b07c360d7547eef9bb54cd65))
 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

#### `audioplayers_platform_interface` - `v1.0.0`

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

#### `audioplayers_web` - `v1.0.0`

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

#### `audioplayers_windows` - `v1.0.0`

 - **FIX**: Windows Failed to seekTo longer than 3:30s (#1125). ([8db4dcaa](https://github.com/bluefireteam/audioplayers/commit/8db4dcaa1446e1442c63134df80b95af852c078f))
 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))


## 2022-05-08

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers_darwin` - `v1.0.0-rc.4`](#audioplayers_darwin---v100-rc4)
 - [`audioplayers_web` - `v1.0.0-rc.3`](#audioplayers_web---v100-rc3)
 - [`audioplayers` - `v1.0.0-rc.4`](#audioplayers---v100-rc4)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `audioplayers` - `v1.0.0-rc.4`

---

#### `audioplayers_darwin` - `v1.0.0-rc.4`

 - **FIX**: Fix iOS code that was missing from previous push (melos vs pub get issue) (#1122). ([fe737849](https://github.com/bluefireteam/audioplayers/commit/fe737849811d0de02cac56b73a613e4ceb78c218))

#### `audioplayers_web` - `v1.0.0-rc.3`

 - **FEAT**: Add onPlayerCompletion, onPlayerStateChanged and onDurationChanged for web (#1123). ([760e0c94](https://github.com/bluefireteam/audioplayers/commit/760e0c9443f4c63aadf4c5498767aeac6cd79346))


## 2022-05-08

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers_linux` - `v1.0.0-rc.3`](#audioplayers_linux---v100-rc3)
 - [`audioplayers` - `v1.0.0-rc.3`](#audioplayers---v100-rc3)
 - [`audioplayers_darwin` - `v1.0.0-rc.3`](#audioplayers_darwin---v100-rc3)
 - [`audioplayers_windows` - `v1.0.0-rc.3`](#audioplayers_windows---v100-rc3)

---

#### `audioplayers_linux` - `v1.0.0-rc.3`

 - **FEAT**: Linux platform support (closes #798) (#1110). ([74616c54](https://github.com/bluefireteam/audioplayers/commit/74616c5471fb942d8f08c41de50c93d4387f8916))

#### `audioplayers` - `v1.0.0-rc.3`

 - **FIX**: Volume and rate can be set before audio playing on iOS (#1113). ([eca1dd0e](https://github.com/bluefireteam/audioplayers/commit/eca1dd0e85abd72dc6c17bd2b7a24912664b98a5))
 - **FEAT**: Linux platform support (closes #798) (#1110). ([74616c54](https://github.com/bluefireteam/audioplayers/commit/74616c5471fb942d8f08c41de50c93d4387f8916))

#### `audioplayers_darwin` - `v1.0.0-rc.3`

 - **FIX**: Volume and rate can be set before audio playing on iOS (#1113). ([eca1dd0e](https://github.com/bluefireteam/audioplayers/commit/eca1dd0e85abd72dc6c17bd2b7a24912664b98a5))

#### `audioplayers_windows` - `v1.0.0-rc.3`

 - **FEAT**: Linux platform support (closes #798) (#1110). ([74616c54](https://github.com/bluefireteam/audioplayers/commit/74616c5471fb942d8f08c41de50c93d4387f8916))


## 2022-04-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers` - `v1.0.0-rc.2`](#audioplayers---v100-rc2)
 - [`audioplayers_windows` - `v1.0.0-rc.2`](#audioplayers_windows---v100-rc2)
 - [`audioplayers_darwin` - `v1.0.0-rc.2`](#audioplayers_darwin---v100-rc2)
 - [`audioplayers_android` - `v1.0.0-rc.2`](#audioplayers_android---v100-rc2)
 - [`audioplayers_platform_interface` - `v1.0.0-rc.2`](#audioplayers_platform_interface---v100-rc2)
 - [`audioplayers_web` - `v1.0.0-rc.2`](#audioplayers_web---v100-rc2)

---

#### `audioplayers` - `v1.0.0-rc.2`

 - Bump "audioplayers" to `1.0.0-rc.2`.

#### `audioplayers_windows` - `v1.0.0-rc.2`

#### `audioplayers_darwin` - `v1.0.0-rc.2`

#### `audioplayers_android` - `v1.0.0-rc.2`

#### `audioplayers_platform_interface` - `v1.0.0-rc.2`

#### `audioplayers_web` - `v1.0.0-rc.2`


## 2022-04-01

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers` - `v1.0.0-rc.1`](#audioplayers---v100-rc1)

---

#### `audioplayers` - `v1.0.0-rc.1`

 - First release after federation


## 2022-04-01

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers_windows` - `v1.0.0-rc.1`](#audioplayers_windows---v100-rc1)
 - [`audioplayers_android` - `v1.0.0-rc.1`](#audioplayers_android---v100-rc1)
 - [`audioplayers_darwin` - `v1.0.0-rc.1`](#audioplayers_darwin---v100-rc1)

---

#### `audioplayers_windows` - `v1.0.0-rc.1`

 - First release after federation

#### `audioplayers_android` - `v1.0.0-rc.1`

 - First release after federation

#### `audioplayers_darwin` - `v1.0.0-rc.1`

 - First release after federation


## 2022-04-01

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers_web` - `v1.0.0-rc.1`](#audioplayers_web---v100-rc1)

---

#### `audioplayers_web` - `v1.0.0-rc.1`

 - First release after federation


## 2022-03-31

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers_web` - `v1.0.0-rc.1`](#audioplayers_web---v100-rc1)

---

#### `audioplayers_web` - `v1.0.0-rc.1`

 - First release after federation


## 2022-03-30

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`audioplayers_platform_interface` - `v1.0.0-rc.1`](#audioplayers_platform_interface---v100-rc1)

---

#### `audioplayers_platform_interface` - `v1.0.0-rc.1`

 - First release after federation

