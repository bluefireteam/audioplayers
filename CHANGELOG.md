# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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

