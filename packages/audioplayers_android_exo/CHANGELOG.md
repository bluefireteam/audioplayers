## 0.2.0-dev.0

> Note: This release has breaking changes.

 - **REFACTOR**: Handle common ReleaseMode.release logic in Dart ([#2017](https://github.com/bluefireteam/audioplayers/issues/2017)). ([6efd636b](https://github.com/bluefireteam/audioplayers/commit/6efd636b639ff144abfcf2423ee13aa7e2dc2239))
 - **FIX**(android_exo): Differentiate playback rate from playback status ([#2036](https://github.com/bluefireteam/audioplayers/issues/2036)). ([91750730](https://github.com/bluefireteam/audioplayers/commit/917507301a90289ecd34809da9302fefb782a8f2))
 - **FEAT**: Support Flutter v3.47.x, update CI ([#2028](https://github.com/bluefireteam/audioplayers/issues/2028)). ([9041a491](https://github.com/bluefireteam/audioplayers/commit/9041a491aedc90754a465835cddc36943eddc0a0))
 - **BREAKING** **FEAT**(android): Make audioplayers_android_exo the default on Android  ([#2031](https://github.com/bluefireteam/audioplayers/issues/2031)). ([df3a0ced](https://github.com/bluefireteam/audioplayers/commit/df3a0cedbc478eb2f5ecb197e56458925e4bce1a))
 - **BREAKING** **FEAT**(android): Replace AudioContextAndroid.stayAwake with wakeMode ([#2033](https://github.com/bluefireteam/audioplayers/issues/2033)). ([8b96fc58](https://github.com/bluefireteam/audioplayers/commit/8b96fc58157769cedb62dc3d9674dbeb6e004463))
 - **BREAKING** **FEAT**: Add PlayingStateUpdate event ([#1995](https://github.com/bluefireteam/audioplayers/issues/1995)). ([fa6ec8e8](https://github.com/bluefireteam/audioplayers/commit/fa6ec8e8112f1d73fdae843e24a59ad2553c2f66))

## 0.1.4

 - **FEAT**(android): Compatibility with Built-In Kotlin ([#1991](https://github.com/bluefireteam/audioplayers/issues/1991)). ([687218b9](https://github.com/bluefireteam/audioplayers/commit/687218b96682a7bcadd9490572db692dbc9a2f07))

## 0.1.3+1

 - **FIX**(audioplayers_android_exo): apply setVolume to mono audio sources ([#1987](https://github.com/bluefireteam/audioplayers/issues/1987)). ([c3f8fab0](https://github.com/bluefireteam/audioplayers/commit/c3f8fab0d9e6c7d72fe477accda31daecd5f60c6))

## 0.1.3

 - **FEAT**: Async swift code, align release functionality, align Android initialization error ([#1964](https://github.com/bluefireteam/audioplayers/issues/1964)). ([65c8f373](https://github.com/bluefireteam/audioplayers/commit/65c8f37314e7e023814bb77c9474c8a076f288cb))

## 0.1.2+1

 - **FIX**: Migrate to Melos v7 and Pub Workspaces ([#1929](https://github.com/bluefireteam/audioplayers/issues/1929)). ([9d0bfe0b](https://github.com/bluefireteam/audioplayers/commit/9d0bfe0be5cba0ce4fb3a75912b41117a8996bfe))

## 0.1.2

 - **FIX**: Make FocusManager compatible with Android API <= 25 (closes [#1895](https://github.com/bluefireteam/audioplayers/issues/1895)) ([#1904](https://github.com/bluefireteam/audioplayers/issues/1904)). ([41238d48](https://github.com/bluefireteam/audioplayers/commit/41238d4837fb5c59b8aaf2e7e8087268a160ebe7))
 - **FEAT**: Dispose players on Hot restart (closes [#1120](https://github.com/bluefireteam/audioplayers/issues/1120)) ([#1905](https://github.com/bluefireteam/audioplayers/issues/1905)). ([92bcb19e](https://github.com/bluefireteam/audioplayers/commit/92bcb19e10c462cb749e1209c5e066efc5581728))

## 0.1.1

 - **FEAT**(android): ExoPlayer for Android ([#1691](https://github.com/bluefireteam/audioplayers/issues/1691)). ([a91c5b18](https://github.com/bluefireteam/audioplayers/commit/a91c5b185054986a2390d41593b5ee502ef96bdd))
 - **DOCS**: Fix status badge ([#1899](https://github.com/bluefireteam/audioplayers/issues/1899)). ([a0c6c4fa](https://github.com/bluefireteam/audioplayers/commit/a0c6c4fabff19e943dced1070c1be3541668dce9))

## 0.1.0

- **FEAT**: AudioPlayers for Android based on ExoPlayer
