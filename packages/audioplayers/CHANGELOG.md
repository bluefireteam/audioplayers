## 6.0.0

> Note: This release has breaking changes.

 - **FIX**: Use unique tmp location for each AudioCache ([#1724](https://github.com/bluefireteam/audioplayers/issues/1724)). ([2333cb7f](https://github.com/bluefireteam/audioplayers/commit/2333cb7f5a9fcd84bdd477120d1f53f346c3b10d))
 - **FIX**: Race condition when playing/pausing audio ([#1705](https://github.com/bluefireteam/audioplayers/issues/1705)). ([463b2a11](https://github.com/bluefireteam/audioplayers/commit/463b2a1149105a25f81d708533d13cc2dd277d6b))
 - **FIX**: Seek not applied in `play` method ([#1695](https://github.com/bluefireteam/audioplayers/issues/1695)). ([f6138fef](https://github.com/bluefireteam/audioplayers/commit/f6138fef97ccd5b78b44dbe85f7d41e16b3662f6))
 - **FIX**: Propagate Stream Errors through the same Future ([#1732](https://github.com/bluefireteam/audioplayers/issues/1732)). ([00d041df](https://github.com/bluefireteam/audioplayers/commit/00d041df11c26fd96f480782f2787f857c77daa0))
 - **FIX**: Wait for seek to complete ([#1712](https://github.com/bluefireteam/audioplayers/issues/1712)). ([fd33b1d0](https://github.com/bluefireteam/audioplayers/commit/fd33b1d073280797cdd88fb6324cc1906bfd5957))
 - **FEAT**: Support byte array and data URIs via mimeType ([#1763](https://github.com/bluefireteam/audioplayers/issues/1763)). ([eaf7ce86](https://github.com/bluefireteam/audioplayers/commit/eaf7ce86ad271097365fcf9e3a03fc341629ae47))
 - **FEAT**(ios): Improved AudioContextConfig assertions, fix example ([#1619](https://github.com/bluefireteam/audioplayers/issues/1619)). ([df342c52](https://github.com/bluefireteam/audioplayers/commit/df342c529b0b13abd0515c5dc762987293ebc4c1))
 - **FEAT**(web): Support compilation to Wasm ([#1766](https://github.com/bluefireteam/audioplayers/issues/1766)). ([1b1a0cf9](https://github.com/bluefireteam/audioplayers/commit/1b1a0cf92e950bc520598426d3f073c3bd5a6a28))
 - **DOCS**: Improve Docs ([#1710](https://github.com/bluefireteam/audioplayers/issues/1710)). ([4208463a](https://github.com/bluefireteam/audioplayers/commit/4208463a4110ed117eebe28e170872817712ff53))
 - **BREAKING** **REFACTOR**: Remove deprecated methods ([#1583](https://github.com/bluefireteam/audioplayers/issues/1583)). ([8d0cbeda](https://github.com/bluefireteam/audioplayers/commit/8d0cbeda6babea69b1753340f9cec3d246d7e29a))
 - **BREAKING** **FEAT**: FramePositionUpdater & TimerPositionUpdater ([#1664](https://github.com/bluefireteam/audioplayers/issues/1664)). ([1ea93536](https://github.com/bluefireteam/audioplayers/commit/1ea93536b448fa5d43281cbc0a7b67445fc1a9a8))
 - **BREAKING** **FEAT**: Extend `AudioContextConfig.duckAudio` to `AudioContextConfig.focus` ([#1720](https://github.com/bluefireteam/audioplayers/issues/1720)). ([87f3cb7e](https://github.com/bluefireteam/audioplayers/commit/87f3cb7e47e2103d2079a3dfe6aebe80c8a76c3d))
 - **BREAKING** **FEAT**(ios): Improve AudioContextIOS ([#1591](https://github.com/bluefireteam/audioplayers/issues/1591)). ([25fbec05](https://github.com/bluefireteam/audioplayers/commit/25fbec051a4f521f73c473cdad20f88c7907d7b1))
 - **BREAKING** **DEPS**: Update min Flutter to v3.13.0, compatibility with v3.16.8 ([#1715](https://github.com/bluefireteam/audioplayers/issues/1715)). ([e4262f4c](https://github.com/bluefireteam/audioplayers/commit/e4262f4c0d6582c35738ace603583c81bd5a3b4b))
 - **BREAKING** **CHORE**: Upgrade to Flutter 3.13.0 ([#1612](https://github.com/bluefireteam/audioplayers/issues/1612)). ([1a3de1ac](https://github.com/bluefireteam/audioplayers/commit/1a3de1acd5a8b90b6d9c0d0f2a7141723c277c24))

## 5.2.1

 - **FIX**: Avoid decoding already encoded character in URI ([#1679](https://github.com/bluefireteam/audioplayers/issues/1679)). ([1923205c](https://github.com/bluefireteam/audioplayers/commit/1923205c4cde70e2915e6e6c6afeb2fec27a08e8))
 - **FIX**(android): Released wrong source in LOW_LATENCY mode ([#1672](https://github.com/bluefireteam/audioplayers/issues/1672)). ([d9c5f693](https://github.com/bluefireteam/audioplayers/commit/d9c5f693cafab21b67b785de6244c3c371344a53))

## 5.2.0

 - **REFACTOR**: Lint Swift ([#1613](https://github.com/bluefireteam/audioplayers/issues/1613)). ([737aa94f](https://github.com/bluefireteam/audioplayers/commit/737aa94f7edb076d622c34e498b90f17c9959e9c))
 - **REFACTOR**: Lint Kotlin, C and C++ code ([#1610](https://github.com/bluefireteam/audioplayers/issues/1610)). ([05394668](https://github.com/bluefireteam/audioplayers/commit/0539466850aaa49a0bde9448939c6c3d536dd6e2))
 - **FIX**: Cancel `onPreparedSubscription` on error ([#1660](https://github.com/bluefireteam/audioplayers/issues/1660)). ([c11dbf30](https://github.com/bluefireteam/audioplayers/commit/c11dbf3094457799a3b89fd6f0b386799b2f943c))
 - **FIX**: Set playback rate only when playing ([#1658](https://github.com/bluefireteam/audioplayers/issues/1658)). ([d73c7d5c](https://github.com/bluefireteam/audioplayers/commit/d73c7d5c2ef13e8eff2c438b96ade6e2483a2014))
 - **FIX**: Improve Error handling for Unsupported Sources ([#1625](https://github.com/bluefireteam/audioplayers/issues/1625)). ([a4d84422](https://github.com/bluefireteam/audioplayers/commit/a4d84422f1421755b05aa7eff38b4d2ed0cf7482))
 - **FIX**: Return null for duration and position, if not available ([#1606](https://github.com/bluefireteam/audioplayers/issues/1606)). ([2a79644a](https://github.com/bluefireteam/audioplayers/commit/2a79644a2064ccc5d8e9a31aaf888b0b60ee321d))
 - **FEAT**(windows): Support for BytesSource on Windows ([#1601](https://github.com/bluefireteam/audioplayers/issues/1601)). ([a9e14710](https://github.com/bluefireteam/audioplayers/commit/a9e147107aa31072d4bcc69a02b2ee287d4b366b))
 - **FEAT**: Allow adding custom media sources to example ([#1637](https://github.com/bluefireteam/audioplayers/issues/1637)). ([1eabe619](https://github.com/bluefireteam/audioplayers/commit/1eabe61957caf969f132ce6fad7b99208887466b))
 - **DOCS**: Deploy live example app to GH pages ([#1623](https://github.com/bluefireteam/audioplayers/issues/1623)). ([fe81f3b1](https://github.com/bluefireteam/audioplayers/commit/fe81f3b1e600fe005febbe7cd3da02735a3de004))

## 5.1.0

 - **REFACTOR**(darwin): Rearrange code ([#1585](https://github.com/bluefireteam/audioplayers/issues/1585)). ([13639d1f](https://github.com/bluefireteam/audioplayers/commit/13639d1f2fe5afbc17f4e862e2da0f7551b8fc3e))
 - **FEAT**: Get current volume, balance and playbackRate ([#1582](https://github.com/bluefireteam/audioplayers/issues/1582)). ([0c2ff7b1](https://github.com/bluefireteam/audioplayers/commit/0c2ff7b1289238150388e571396ac92b28a8ea5d))

## 5.0.0

> Note: This release has breaking changes.

 - **REFACTOR**(windows): simplify position and duration processing ([#1553](https://github.com/bluefireteam/audioplayers/issues/1553)). ([ca63c5a4](https://github.com/bluefireteam/audioplayers/commit/ca63c5a4b120e0d1ea421e6ab30f590c314a33f2))
 - **FIX**(example): Use kotlin version compatible with AGP8 ([#1577](https://github.com/bluefireteam/audioplayers/issues/1577)). ([8f4b1bb0](https://github.com/bluefireteam/audioplayers/commit/8f4b1bb0bc93df095bff2a4d4c2f92a4c4a85d17))
 - **FIX**(linux): allow reusing event channel with same name ([#1555](https://github.com/bluefireteam/audioplayers/issues/1555)). ([5471189f](https://github.com/bluefireteam/audioplayers/commit/5471189f9469e973f9262a120b02b321ca0dce24))
 - **FEAT**(android): Add support for AGP 8 in example, add compileOptions to build.gradle ([#1503](https://github.com/bluefireteam/audioplayers/issues/1503)). ([7c08e4e1](https://github.com/bluefireteam/audioplayers/commit/7c08e4e1a524f53294f6967996fd31837e62cb81))
 - **BREAKING** **FIX**: Default audio output to system preferences ([#1563](https://github.com/bluefireteam/audioplayers/issues/1563)). ([381c43e3](https://github.com/bluefireteam/audioplayers/commit/381c43e3725fbb0cb4fd35982893a3c92b188886))
 - **BREAKING** **CHORE**: Bump Flutter to version 3.10.x ([#1529](https://github.com/bluefireteam/audioplayers/issues/1529)). ([c1296c9b](https://github.com/bluefireteam/audioplayers/commit/c1296c9ba0cc43284b31d78f2f484454fbf6b773))

## 4.1.0

 - **REFACTOR**: Adapt to flame_lint v0.2.0+2 ([#1477](https://github.com/bluefireteam/audioplayers/issues/1477)). ([e1d7fb6a](https://github.com/bluefireteam/audioplayers/commit/e1d7fb6ab57c8a523c80dfc673bde3b7379b2add))
 - **FIX**: Timeout on setting same source twice  ([#1520](https://github.com/bluefireteam/audioplayers/issues/1520)). ([5d164d1f](https://github.com/bluefireteam/audioplayers/commit/5d164d1f20463a8a31a228cd1d85252d47ae256e))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492](https://github.com/bluefireteam/audioplayers/issues/1492)). ([ab5bdf6a](https://github.com/bluefireteam/audioplayers/commit/ab5bdf6a2bcbf7e984d4d897e43a67b3684c52d8))
 - **DOCS**: Improve docs ([#1518](https://github.com/bluefireteam/audioplayers/issues/1518)). ([4c0d5546](https://github.com/bluefireteam/audioplayers/commit/4c0d55465a8e75c13987b970dee648657eba4384))

## 4.0.1

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))

## 4.0.0

> Note: This release has breaking changes.

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

### Migration instructions

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

## 3.0.1

 - Update a dependency to the latest release.

## 3.0.0

> Note: This release has breaking changes.

 - **FEAT**: add and remove player actions ([#1394](https://github.com/bluefireteam/audioplayers/issues/1394)). ([f06cab91](https://github.com/bluefireteam/audioplayers/commit/f06cab91fbae65d7fdc9e3fbd75171b391ac0b96))
 - **FEAT**: example improvements ([#1392](https://github.com/bluefireteam/audioplayers/issues/1392)). ([002e2fc9](https://github.com/bluefireteam/audioplayers/commit/002e2fc950145e3231ab79a5ef399024d62f6fb1))
 - **BREAKING** **REFACTOR**: rename logger_platform_interface.dart to global_platform_interface.dart ([#1385](https://github.com/bluefireteam/audioplayers/issues/1385)). ([6e837c1c](https://github.com/bluefireteam/audioplayers/commit/6e837c1ccd93b95d10843a403674128cf303c0ab))
 - **BREAKING** **FEAT**: configurable SoundPool and `AudioManager.mode` ([#1388](https://github.com/bluefireteam/audioplayers/issues/1388)). ([5697f187](https://github.com/bluefireteam/audioplayers/commit/5697f187bcca64de2e519f8f49aaf4817fcf6398))

## 2.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: remove unused `defaultToSpeaker` in `AudioContextIOS` and replace with `AVAudioSessionOptions.defaultToSpeaker` ([#1374](https://github.com/bluefireteam/audioplayers/issues/1374)). ([d844ef9d](https://github.com/bluefireteam/audioplayers/commit/d844ef9def06fd5047076d9f4c371ad3be4c8dd5))

## 1.2.0

> Note: This release has breaking changes.

 - **FIX**: Duration precision on Windows ([#1342](https://github.com/bluefireteam/audioplayers/issues/1342)). ([3cda1a65](https://github.com/bluefireteam/audioplayers/commit/3cda1a65dc0425c332ed2eb3619cd88531f0ea49))
 - **FIX**: infinity / nan on getDuration ([#1298](https://github.com/bluefireteam/audioplayers/issues/1298)). ([a4474dcf](https://github.com/bluefireteam/audioplayers/commit/a4474dcf5e14fbd74db8b4f19223b9bfa40ed5f5))
 - **FEAT**: upgrade flutter to v3.0.0 and dart 2.17 to support "Super initializers" ([#1355](https://github.com/bluefireteam/audioplayers/issues/1355)). ([4af417b4](https://github.com/bluefireteam/audioplayers/commit/4af417b4c91ed5c22d6c48e05080c3018ccaee42))
 - **FEAT**: local test server ([#1354](https://github.com/bluefireteam/audioplayers/issues/1354)). ([06be429a](https://github.com/bluefireteam/audioplayers/commit/06be429a0078456a989b9afc3abc68164c4abaab))
 - **FEAT**: get current source ([#1350](https://github.com/bluefireteam/audioplayers/issues/1350)). ([7a10be38](https://github.com/bluefireteam/audioplayers/commit/7a10be38ec6613c8ef45bb33d1e81f11bb5988f9))
 - **FEAT**: log path and url of sources ([#1334](https://github.com/bluefireteam/audioplayers/issues/1334)). ([8a13f96d](https://github.com/bluefireteam/audioplayers/commit/8a13f96dbb14be0d1d80577816246109c42b7983))
 - **FEAT**: add setBalance ([#58](https://github.com/bluefireteam/audioplayers/issues/58)) ([#1282](https://github.com/bluefireteam/audioplayers/issues/1282)). ([782fc9df](https://github.com/bluefireteam/audioplayers/commit/782fc9dff24a2ab9681496fd7c4c8fed451eac35))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))
 - **BREAKING** **FIX**: Cache should take key to be properly cleared ([#1347](https://github.com/bluefireteam/audioplayers/issues/1347)). ([1a410bba](https://github.com/bluefireteam/audioplayers/commit/1a410bba578af506637b026bb2c4ace03a161a69))

## 1.1.1

 - **FIX**: infinity / nan on getDuration ([#1298](https://github.com/bluefireteam/audioplayers/issues/1298)). ([a4474dcf](https://github.com/bluefireteam/audioplayers/commit/a4474dcf5e14fbd74db8b4f19223b9bfa40ed5f5))

## 1.1.0

 - **FIX**: player state not being updated to completed (#1257). ([70a37afb](https://github.com/bluefireteam/audioplayers/commit/70a37afb6ce4fbb8b8c680ca9b6804b005012446))
 - **FIX**: lowLatency bugs (closes #1176, closes #1193, closes #1165) (#1272). ([541578cc](https://github.com/bluefireteam/audioplayers/commit/541578cc50f3856c23c393faa1a71380b3b49222))
 - **FIX**: ios/macos no longer start audio when calling only setSourceUrl (#1206). ([c0e97f04](https://github.com/bluefireteam/audioplayers/commit/c0e97f04fb05fb109830d6363f5c44dccbd327b4))
 - **FEAT**: improve example (#1267). ([a8154da1](https://github.com/bluefireteam/audioplayers/commit/a8154da1cc6fdec80d80fa538d65cb491a33db78))
 - **FEAT**: Platform integration tests 🤖 (#1128). ([b0c84aab](https://github.com/bluefireteam/audioplayers/commit/b0c84aabea8af28f693941c1b3bf2b1fa1048833))
 - **DOCS**: Remove 11-month old outdated doc file (#1180). ([bae43cb1](https://github.com/bluefireteam/audioplayers/commit/bae43cb10a27eff23ebaf2a6ac796fd61039f359))

## 1.0.1

 - **FIX**: Make sure onComplete resets the position even when not looping (#1175). ([6e6005ac](https://github.com/bluefireteam/audioplayers/commit/6e6005ac98765aeeea62208b58a6cc6d0cb4b084))

## 1.0.0

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

## 1.0.0-rc.4

 - Update a dependency to the latest release.

## 1.0.0-rc.3

 - **FIX**: Volume and rate can be set before audio playing on iOS (#1113). ([eca1dd0e](https://github.com/bluefireteam/audioplayers/commit/eca1dd0e85abd72dc6c17bd2b7a24912664b98a5))
 - **FEAT**: Linux platform support (closes #798) (#1110). ([74616c54](https://github.com/bluefireteam/audioplayers/commit/74616c5471fb942d8f08c41de50c93d4387f8916))

## 1.0.0-rc.2

 - Bump "audioplayers" to `1.0.0-rc.2`.

## 1.0.0-rc.1

 - First release after federation

# Changelog

## 0.20.2
- Fix bug with inversed log levels

## 0.20.1
- Fix enum parsing on release mode on android

## 0.20.0
- Fix android/kotlin build for old projects
- Add method to clearNotification
- Add currentPosition stream on web
- Add seek on web
- Add a proper Logger
- Make setPlaybackRate signature consistent
- Fix fatal exception on Android API < 21 in WrappedMediaPlayer.kt setAttributes
- Add clearNotification method

## 0.19.1
- Add missing awaits for AudioCache
- Fix Kotlin Core version to v1.6.0
- Fix iOS warning
- Fix README link to audio_cache.md to work on pub
- Fix documentation referencing old class
- Add web support for audioPlayer.getCurrentPosition
- Add web support for audioPlayer.getDuration
- Add web support for audioPlayer.setPlaybackRate
- Fix local file playback in LOW_LATENCY mode on Android

## 0.19.0
- Refactor Notifications code (small breaking changes)
- AudioCache for web
- Fixing basic features for Android lower than API 23
- Fixing error after playing music several times with AudioCache
- Re-organize folder and file structure on the Dart side (project layout)
- Re-organize folders into a mono-repo
- Fix several bugs

## 0.18.3
- Fix Float vs Double mixup on Swift that prevent non-integer values for volume/playback
- Fix open sink issue / resource leak

## 0.18.2
- Changing Android minSdk verison to 16
- Improve build processes and other small bug fixes

## 0.18.1
- Fix kotlin config issue for some apps
- Fix warning from pub
- Fix iOS lock screen
- Fix setUrl method

## 0.18.0
- Stable null-safety release
- Removed all the `@deprecated` code blocks

## 0.17.4
- Fix java.lang.UnsupportedOperationException on read-only kotlin map

## 0.17.3
- Backport some code to old kt (for now)

## 0.17.2
- Fix macos compilation issue
- Fix android for non-kotlin projects

## 0.17.1
- Use better algorithm for speed modulation on iOS
- Extracted and refactored all the notifications code onto the new file
- Add more checks and make sure notifcations code is not ran when it shouldn't
- Add more useful info to the troubleshoot guide

## 0.17.0
- Swift conversion of the darwin code

## 0.16.2
- Overhauled our contributing guidelines
- Improve docs around player state
- Update dependencies versions

## 0.16.1
- Fix Exception thrown when calling audioPlayer.dispose
- Fix bug with AudioCache crash on iOS

## 0.16.0
- Implemented stream routing for iOS
- Call release on dispose
- Fix iOS build
- Breaking change audio cache prefix in order to allow override 'assets'

## audioplayers 0.15.1
- Fix web for release mode

## audioplayers 0.15.0
- Improve loop/readme for web support
- Audio cache support for web
- Re-adding partial web support

## audioplayers 0.14.3
- Add next and previous command for ios 

## audioplayers 0.14.2
- Fix pubspec problem because of web file

## audioplayers 0.14.1
- Adding linter, tests and flutter_driver integration tests to a CI (github actions)
- Minor fixes to the APIs and documentation
- Fix restarting the playback of a failed AVPlayerItem
- Prevent exceptions when null values are passed to notifications center
- Prevent crash by checking if headlessServiceInitialized before invoking onNotificationBackgroundPlayerStateChanged

## audioplayers 0.14.0
- Adding macOs support
- ios:fix lack of seek completion handle
- ios Delay start fixed

## audioplayers 0.13.7
- Bump dependencies, improve gitignore
- Upgrade pubspec pattern

## audioplayers 0.13.6
- added `setPlaybackRate` feature for Android
- Automatic detect address is local or remote (thanks, @saeed-golshan)

## audioplayers 0.13.5
- fixed crash on iOS when `startHeadlessService()` wasn't called on `AudioPlayer` (by @JesseScott)

## audioplayers 0.13.4
- fixing missing cleanup on hot restart on Android
- Background notification updates on iOS

## audioplayers 0.13.3
- audio notification area fixes
- fix when other apps are playing sounds
- fix android race condition
- Support for registering plugin in background enviroment
- fix typos and docs

## audioplayers 0.13.2
- Handling plugin dealloc and onTimeInterval crashs (thanks @chedechao111)
- Audio position update when the audio is paused (thanks @bjornjacobs)

## audioplayers 0.13.1
- Added stayAwake feature (thanks, @danielR2001)
- Improved dispose method (thanks, @hugocbpassos)
- Added getCurrentPosition (thanks, @hariom08)
- Some bug fixes and small changes

## audioplayers 0.13.0
- Call onDurationChanged after setUrl() to be consistent with ios version (thanks @subhash279)
- Adding getDuration feature iOS/Android (thanks @alecorsino)

## audioplayers 0.12.1
- Fixes bug where the stream handlers were not called due to exception on the handler
- Proper error message when errors in the dart handler occurs

## audioplayers 0.12.0
- Update to path_provider 1.1.0
- Upgrade to Swift 5 in example project setting (thanks @jerryzhoujw)

## audioplayers 0.11.0
- **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## audioplayers 0.10.1
- Seek and play now works with milliseconds instead of second (thanks, @catoldcui and @erickzanardo)

## audioplayers 0.10.0
- Added a low latency api for android (thanks, @feroult)

## audioplayers 0.9.0
- Improved callbacks using Streams to allow for multiple subscibers (thanks, @LucasCLuk)
- Update uuid version to 2.0.0 (thanks, @BeMacized)

## audioplayers 0.8.2
- Update path_provider version (thanks, @apiraino)

## audioplayers 0.8.1
- Fix for duration when playing a stream
- Added respectSilence flag in audioplayers, or isNotification for play methos in audio_cache
  False by default, to use player for local notification. Silent when device is in silent mode.

## audioplayers 0.8.0
- Allow setting seek position in play function (thanks @rob-patchett)
- Get duration from the underlaying asset instead of from AVPlayerItem (thanks @andressade)
- Adding player state (thanks @renancaraujo)
- Set the audio session to active (thanks @benwicks)
- Delay seek operations on Android until player is ready (thanks @jeffmikels)

## audioplayers 0.7.8
- Fix bug regarding name clash with other plugins (thanks @imtaehyun)

## audioplayers 0.7.7
- Fix bug when using nested files with audio cache (thanks @hotstu for reporting and @eclewlow for fixing)

## audioplayers 0.7.6
- Fix the nefarious bug of 'sound only playing through headphones' (thanks so much, @tsun424)

## audioplayers 0.7.5
- Fix SDK constraint for Dart 2.1 (thanks @snoofer and @sroddy)

## audioplayers 0.7.4
- Some more fixes to work without errors with Dart 2 stronger types

## audioplayers 0.7.3
- Support Android SDK 16-20 (thanks, @sroddy)
- Avoid restarting a looping player if is stopped (thanks, @sroddy)

## audioplayers 0.7.2
- Bug fixes for iOS

## audioplayers 0.7.1
- Formatting

## audioplayers 0.7.0

- Improved lifecycle handling for android
- Big performance boots
- Allows for finer control of releasing (with setReleaseMode, setUrl, resume, release)
- Allows for setting the volume at any time (with setVolume)
- Added LOOP as a ReleaseMode options, making it significantly faster
- Some other refactorings

## audioplayers 0.6.0

- Major Refactoring!
- Renaming everything to audioplayers (mind the s)
- Better logging
- Added AudioCache (imported from Flame)
- Adding tests!
- Adding better example
- Greatly improving README
- Lots of other minor tweaks

## audioplayers 0.5.2

- don't call the onClomplete hook when you manually stop the audio

## audioplayers 0.5.1

- fix for dart 2 (thanks to @efortuna)

## audioplayers 0.5.0

- improves Android performance by not calling `prepare` on the main thread

## audioplayers 0.4.1

- fix `seek` for iOS

## audioplayers 0.4.0

- volume controls

## audioplayers 0.3.0

- working on iOS (thanks @feroult <3)

## audioplayers 0.2.0

- adding disable log option

## audioplayers 0.1.0

- support for multiple audios simultaneously

## 0.2.0

- support for local files

## 0.1.0

- update to the current Plugin API
- move to https://github.com/rxlabz/audioplayer

## 0.0.2

Separated handlers for position, duration, completion and errors 
 
- setDurationHandler(TimeChangeHandler handler)
- setPositionHandler(TimeChangeHandler handler)
- setCompletionHandler(VoidCallback callback)
- setErrorHandler(ErrorHandler handler)
  
- new typedef 
```dart
typedef void TimeChangeHandler(Duration duration);
typedef void ErrorHandler(String message);
```

## 0.0.1

- first POC :
  - methods : play, pause, stop
  - a globalHandler for position, duration, completion and errors
