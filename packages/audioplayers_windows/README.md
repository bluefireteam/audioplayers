<p align="center">
  <a href="https://pub.dev/packages/audioplayers">
    <img alt="AudioPlayers" height="150px" src="https://raw.githubusercontent.com/bluefireteam/audioplayers/main/images/logo_ap_compact.svg">
  </a>
</p>

---

# audioplayers_windows
<p>
  <a title="Pub" href="https://pub.dev/packages/audioplayers_windows"><img src="https://img.shields.io/pub/v/audioplayers_windows.svg?style=popout&include_prereleases"/></a>
  <a title="Build Status" href="https://github.com/bluefireteam/audioplayers/actions?query=workflow%3Abuild+branch%3Amain"><img src="https://github.com/bluefireteam/audioplayers/actions/workflows/build.yml/badge.svg?branch=main"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

The Windows implementation of [`audioplayers`](https://pub.dev/packages/audioplayers).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `audioplayers` normally. 
This package will be automatically included in your app when you do, so you do not need to add it to your `pubspec.yaml`.

## Setup for Windows

### Flutter

Please follow the Flutter guide to [set up Flutter on Windows](https://docs.flutter.dev/get-started/install/windows#windows-setup).

### Requirements

With **Visual Studio 18 (2026)**, Audioplayers is depending on libraries, which require [CMP0091 NEW policy](https://cmake.org/cmake/help/latest/policy/CMP0091.html#policy:CMP0091).
Therefore, we recommend changing your `windows/CMakeLists.txt` as follows:

```diff
-cmake_minimum_required(VERSION 3.14)
+cmake_minimum_required(VERSION 3.15)

# ...

-cmake_policy(VERSION 3.14...3.25)
+cmake_policy(VERSION 3.15...3.25)
```

Alternatively apply the CMP0091 policy before the first occurrence of `project()`:

```diff
+cmake_policy(SET CMP0091 NEW)
project(my_project_name LANGUAGES CXX)
```

### Optional

Optionally you can add the individual component `NuGet package manager` inside **Visual Studio** or **Visual Studio Build Tools**, otherwise it will be downloaded while building.
