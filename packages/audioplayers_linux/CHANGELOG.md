## 4.0.0

> Note: This release has breaking changes.

 - **FIX**(linux): Handle failures of OnMediaStateChange in OnMediaError ([#1731](https://github.com/bluefireteam/audioplayers/issues/1731)). ([3a5c6dca](https://github.com/bluefireteam/audioplayers/commit/3a5c6dca5dd9476765a976724e3ca89574794cb0))
 - **FIX**: Wait for seek to complete ([#1712](https://github.com/bluefireteam/audioplayers/issues/1712)). ([fd33b1d0](https://github.com/bluefireteam/audioplayers/commit/fd33b1d073280797cdd88fb6324cc1906bfd5957))
 - **BREAKING** **FEAT**: FramePositionUpdater & TimerPositionUpdater ([#1664](https://github.com/bluefireteam/audioplayers/issues/1664)). ([1ea93536](https://github.com/bluefireteam/audioplayers/commit/1ea93536b448fa5d43281cbc0a7b67445fc1a9a8))
 - **BREAKING** **DEPS**: Update min Flutter to v3.13.0, compatibility with v3.16.8 ([#1715](https://github.com/bluefireteam/audioplayers/issues/1715)). ([e4262f4c](https://github.com/bluefireteam/audioplayers/commit/e4262f4c0d6582c35738ace603583c81bd5a3b4b))
 - **BREAKING** **CHORE**: Upgrade to Flutter 3.13.0 ([#1612](https://github.com/bluefireteam/audioplayers/issues/1612)). ([1a3de1ac](https://github.com/bluefireteam/audioplayers/commit/1a3de1acd5a8b90b6d9c0d0f2a7141723c277c24))

## 3.1.0

 - **REFACTOR**: Lint Kotlin, C and C++ code ([#1610](https://github.com/bluefireteam/audioplayers/issues/1610)). ([05394668](https://github.com/bluefireteam/audioplayers/commit/0539466850aaa49a0bde9448939c6c3d536dd6e2))
 - **FIX**: Improve Error handling for Unsupported Sources ([#1625](https://github.com/bluefireteam/audioplayers/issues/1625)). ([a4d84422](https://github.com/bluefireteam/audioplayers/commit/a4d84422f1421755b05aa7eff38b4d2ed0cf7482))
 - **FIX**: Return null for duration and position, if not available ([#1606](https://github.com/bluefireteam/audioplayers/issues/1606)). ([2a79644a](https://github.com/bluefireteam/audioplayers/commit/2a79644a2064ccc5d8e9a31aaf888b0b60ee321d))
 - **FEAT**: Release source for Web, Linux, Windows ([#1517](https://github.com/bluefireteam/audioplayers/issues/1517)). ([09496dcb](https://github.com/bluefireteam/audioplayers/commit/09496dcbf478af330e37be833184439b43b5ac44))
 - **DOCS**: Manual Flutter installation on Linux setup ([#1631](https://github.com/bluefireteam/audioplayers/issues/1631)). ([9086e75a](https://github.com/bluefireteam/audioplayers/commit/9086e75a9503bdb84f372b5e09a4b225d3fae5f6))

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **CHORE**: Bump Flutter to version 3.10.x ([#1529](https://github.com/bluefireteam/audioplayers/issues/1529)). ([c1296c9b](https://github.com/bluefireteam/audioplayers/commit/c1296c9ba0cc43284b31d78f2f484454fbf6b773))

## 2.1.0

 - **FIX**: Timeout on setting same source twice  ([#1520](https://github.com/bluefireteam/audioplayers/issues/1520)). ([5d164d1f](https://github.com/bluefireteam/audioplayers/commit/5d164d1f20463a8a31a228cd1d85252d47ae256e))
 - **FIX**: test and fix compatibility with min flutter version ([#1510](https://github.com/bluefireteam/audioplayers/issues/1510)). ([9f39e95f](https://github.com/bluefireteam/audioplayers/commit/9f39e95ff7913d8fc30fff27fef7aefc32de26fb))
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469](https://github.com/bluefireteam/audioplayers/issues/1469)). ([50f56365](https://github.com/bluefireteam/audioplayers/commit/50f56365f8e512df0fc5bdb7222614389cbd4ea0))
 - **FIX**: rework dispose ([#1480](https://github.com/bluefireteam/audioplayers/issues/1480)). ([c64ef6d9](https://github.com/bluefireteam/audioplayers/commit/c64ef6d914a52743128c717b90c4da0abbd7538d))
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492](https://github.com/bluefireteam/audioplayers/issues/1492)). ([ab5bdf6a](https://github.com/bluefireteam/audioplayers/commit/ab5bdf6a2bcbf7e984d4d897e43a67b3684c52d8))

## 2.0.1

 - **FIX**: dispose player implementation ([#1470](https://github.com/bluefireteam/audioplayers/issues/1470)). ([d9026c15](https://github.com/bluefireteam/audioplayers/commit/d9026c1538cc83dfba5745771ad71c307b6da852))

## 2.0.0

> Note: This release has breaking changes.

 - **FEAT**(windows): show nuget download info explicitely in verbose mode ([#1449](https://github.com/bluefireteam/audioplayers/issues/1449)). ([136028fa](https://github.com/bluefireteam/audioplayers/commit/136028fa1cbcf38f80e9cc7ad78b3bb89d2c6d30))
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457](https://github.com/bluefireteam/audioplayers/issues/1457)). ([b8eb1974](https://github.com/bluefireteam/audioplayers/commit/b8eb197435631fafeaa9a26eb76aca8e43e86420))
 - **DOCS**: Fix LICENSE files for windows and linux ([#1431](https://github.com/bluefireteam/audioplayers/issues/1431)). ([1f84e857](https://github.com/bluefireteam/audioplayers/commit/1f84e857a112e663fff73c4e7c6875ebb72c783d))
 - **BREAKING** **FEAT**: event channel ([#1352](https://github.com/bluefireteam/audioplayers/issues/1352)). ([c9fd6a76](https://github.com/bluefireteam/audioplayers/commit/c9fd6a762c8c346d8d5598e3550c5571a5e460f0))

## 1.0.4

> Note: This release was an accidental bump.

## 1.0.3

 - Update a dependency to the latest release.

## 1.0.2

 - **FIX**: play sound, when initialized ([#1332](https://github.com/bluefireteam/audioplayers/issues/1332)). ([2ed91fee](https://github.com/bluefireteam/audioplayers/commit/2ed91feec4d3528a4edff635331bd3aad938afd7))
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349](https://github.com/bluefireteam/audioplayers/issues/1349)). ([0bdde4d9](https://github.com/bluefireteam/audioplayers/commit/0bdde4d9f8f62487cdcfe96221216eba03b31060))

## 1.0.1

 - **FIX**: emit position event immediately when resume (#1222). ([94c73482](https://github.com/bluefireteam/audioplayers/commit/94c73482b0141d5f6c202219948fc79bac40b288))
 - **DOCS**: update README, Linux: replace with symlink, update Requirements (#1190). ([72e3d500](https://github.com/bluefireteam/audioplayers/commit/72e3d50067e274a8efb6b646a3318ae5fa097a77))

## 1.0.0

 - **FIX**: missing onDuration event, free previous source when set url on Linux (#1129). ([b523a39e](https://github.com/bluefireteam/audioplayers/commit/b523a39e253dd461b07c360d7547eef9bb54cd65))
 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e](https://github.com/bluefireteam/audioplayers/commit/0d6dae3efc4a73abeb554fd0862d64fda0269066))

## 1.0.0-rc.3

 - **FEAT**: Linux platform support (closes #798) (#1110). ([74616c54](https://github.com/bluefireteam/audioplayers/commit/74616c5471fb942d8f08c41de50c93d4387f8916))

