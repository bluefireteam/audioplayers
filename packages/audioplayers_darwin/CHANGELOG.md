## 6.3.0

 - **FIX**: Migrate to Melos v7 and Pub Workspaces ([#1929]). ([9d0bfe0b])
 - **FEAT**: Support for Swift Package Manager ([#1908]). ([e8f86e7b])

## 6.2.0

 - **FEAT**: Dispose players on Hot restart (closes [#1120]) ([#1905]). ([92bcb19e])

## 6.1.1

 - **DOCS**: Fix status badge ([#1899]). ([a0c6c4fa])

## 6.1.0

 - **FIX**: No-op on single player setAudioContext in desktop platforms ([#1888]). ([50d7a8b8])
 - **FEAT**: ReleaseMode.release for ios, macos, windows, web, linux ([#1790]). ([4ffc4029])

## 6.0.0

> Note: This release has breaking changes.

 - **FIX**(ios): 'audioProcessing' deprecated in iOS 10 ([#1756]). ([81e5ea54])
 - **FEAT**: Support byte array and data URIs via mimeType ([#1763]). ([eaf7ce86])
 - **BREAKING** **FEAT**: FramePositionUpdater & TimerPositionUpdater ([#1664]). ([1ea93536])
 - **BREAKING** **DEPS**: Update min Flutter to v3.13.0, compatibility with v3.16.8 ([#1715]). ([e4262f4c])

## 5.0.2

 - **REFACTOR**: Lint Swift ([#1613]). ([737aa94f])
 - **REFACTOR**: Lint Kotlin, C and C++ code ([#1610]). ([05394668])
 - **FIX**: Set playback rate only when playing ([#1658]). ([d73c7d5c])
 - **FIX**: Improve Error handling for Unsupported Sources ([#1625]). ([a4d84422])
 - **FIX**(darwin): Start observing `AVPlayerItem.status` before being assigned to `AVPlayer` ([#1549]). ([8c3a2138])
 - **FIX**: Return null for duration and position, if not available ([#1606]). ([2a79644a])

## 5.0.1

 - **REFACTOR**(darwin): Rearrange code ([#1585]). ([13639d1f])

## 5.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: Default audio output to system preferences ([#1563]). ([381c43e3])
 - **BREAKING** **CHORE**: Bump Flutter to version 3.10.x ([#1529]). ([c1296c9b])

## 4.1.0

 - **FIX**: test and fix compatibility with min flutter version ([#1510]). ([9f39e95f])
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469]). ([50f56365])
 - **FIX**: rework dispose ([#1480]). ([c64ef6d9])
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492]). ([ab5bdf6a])

## 4.0.1

 - **FIX**: dispose player implementation ([#1470]). ([d9026c15])

## 4.0.0

> Note: This release has breaking changes.

 - **FIX**(iOS): Default to speaker instead of earpiece on iOS ([#1408]). ([4ea5907b])
 - **FEAT**(ios): set player context globally on `setAudioContext` for iOS only ([#1416]). ([19af364b])
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457]). ([b8eb1974])
 - **BREAKING** **FEAT**: event channel ([#1352]). ([c9fd6a76])

## 3.0.1

 - **FIX**: Remove one of the duplicated path_providers plugins

## 3.0.0

> Note: This release does not have breaking changes, it was an accidental bump.

## 2.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: remove unused `defaultToSpeaker` in `AudioContextIOS` and replace with `AVAudioSessionOptions.defaultToSpeaker` ([#1374]). ([d844ef9d])

## 1.0.4

 - **FIX**: infinity / nan on getDuration ([#1298]). ([a4474dcf])
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349]). ([0bdde4d9])

## 1.0.3

 - **FIX**: infinity / nan on getDuration ([#1298]). ([a4474dcf])

## 1.0.2

 - **FIX**: update platform to 9.0 in podspec. (#1171). ([f8cbd972])
 - **FIX**: ios/macos no longer start audio when calling only setSourceUrl (#1206). ([c0e97f04])

## 1.0.1

 - **FIX**: Make sure onComplete resets the position even when not looping (#1175). ([6e6005ac])

## 1.0.0

 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e])

## 1.0.0-rc.4

 - **FIX**: Fix iOS code that was missing from previous push (melos vs pub get issue) (#1122). ([fe737849])

## 1.0.0-rc.3

 - **FIX**: Volume and rate can be set before audio playing on iOS (#1113). ([eca1dd0e])

## 1.0.0-rc.2

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
