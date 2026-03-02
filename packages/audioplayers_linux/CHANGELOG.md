## 4.2.1

 - **FIX**: Migrate to Melos v7 and Pub Workspaces ([#1929]). ([9d0bfe0b])

## 4.2.0

 - **FEAT**: Dispose players on Hot restart (closes [#1120]) ([#1905]). ([92bcb19e])

## 4.1.1

 - **DOCS**: Fix status badge ([#1899]). ([a0c6c4fa])

## 4.1.0

 - **FIX**: No-op on single player setAudioContext in desktop platforms ([#1888]). ([50d7a8b8])
 - **FEAT**: ReleaseMode.release for ios, macos, windows, web, linux ([#1790]). ([4ffc4029])

## 4.0.1

 - **DOCS**: Add Fedora/RHEL Dependency instructions ([#1851]). ([b401a23c])

## 4.0.0

> Note: This release has breaking changes.

 - **FIX**(linux): Handle failures of OnMediaStateChange in OnMediaError ([#1731]). ([3a5c6dca])
 - **FIX**: Wait for seek to complete ([#1712]). ([fd33b1d0])
 - **BREAKING** **FEAT**: FramePositionUpdater & TimerPositionUpdater ([#1664]). ([1ea93536])
 - **BREAKING** **DEPS**: Update min Flutter to v3.13.0, compatibility with v3.16.8 ([#1715]). ([e4262f4c])
 - **BREAKING** **CHORE**: Upgrade to Flutter 3.13.0 ([#1612]). ([1a3de1ac])

## 3.1.0

 - **REFACTOR**: Lint Kotlin, C and C++ code ([#1610]). ([05394668])
 - **FIX**: Improve Error handling for Unsupported Sources ([#1625]). ([a4d84422])
 - **FIX**: Return null for duration and position, if not available ([#1606]). ([2a79644a])
 - **FEAT**: Release source for Web, Linux, Windows ([#1517]). ([09496dcb])
 - **DOCS**: Manual Flutter installation on Linux setup ([#1631]). ([9086e75a])

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **CHORE**: Bump Flutter to version 3.10.x ([#1529]). ([c1296c9b])

## 2.1.0

 - **FIX**: Timeout on setting same source twice  ([#1520]). ([5d164d1f])
 - **FIX**: test and fix compatibility with min flutter version ([#1510]). ([9f39e95f])
 - **FIX**: onPrepared event to wait until player is ready / finished loading the source ([#1469]). ([50f56365])
 - **FIX**: rework dispose ([#1480]). ([c64ef6d9])
 - **FEAT**: Adapt position update interval of darwin, linux, web  ([#1492]). ([ab5bdf6a])

## 2.0.1

 - **FIX**: dispose player implementation ([#1470]). ([d9026c15])

## 2.0.0

> Note: This release has breaking changes.

 - **FEAT**(windows): show nuget download info explicitely in verbose mode ([#1449]). ([136028fa])
 - **DOCS**: update AudioCache explanation, migration guide, replace package READMEs ([#1457]). ([b8eb1974])
 - **DOCS**: Fix LICENSE files for windows and linux ([#1431]). ([1f84e857])
 - **BREAKING** **FEAT**: event channel ([#1352]). ([c9fd6a76])

## 1.0.4

> Note: This release was an accidental bump.

## 1.0.3

 - Update a dependency to the latest release.

## 1.0.2

 - **FIX**: play sound, when initialized ([#1332]). ([2ed91fee])
 - **DOCS**: Fix repos and homepages on pubspecs ([#1349]). ([0bdde4d9])

## 1.0.1

 - **FIX**: emit position event immediately when resume (#1222). ([94c73482])
 - **DOCS**: update README, Linux: replace with symlink, update Requirements (#1190). ([72e3d500])

## 1.0.0

 - **FIX**: missing onDuration event, free previous source when set url on Linux (#1129). ([b523a39e])
 - **FEAT**: Upgrade flame lint dependency (#1132). ([0d6dae3e])

## 1.0.0-rc.3

 - **FEAT**: Linux platform support (closes #798) (#1110). ([74616c54])

