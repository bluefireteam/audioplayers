<p align="center">
  <a href="https://pub.dev/packages/audioplayers">
    <img alt="AudioPlayers" height="150px" src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/logo_ap_compact.svg">
  </a>
</p>

<p align="center">
  <b>Hardened Fork</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-6.6.2-blueviolet?style=flat-square&logo=github" alt="Version"/>
  <img src="https://img.shields.io/badge/Release%20Date-2026--02--03-blue?style=flat-square&logo=calendar" alt="Release Date"/>
</p>

[![Build Check](https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build_check.yml/badge.svg)](https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build_check.yml)

`audioplayers_stable` is an **industrial-grade, stable, and high-performance** audio plugin for Flutter. The goal is to provide a clean codebase, stripped of obsolescence, and protected by a rigorous testing suite.

## 🛠️ Why this fork? (Technical Decisions)

The original repository suffered from excessive fragmentation and accumulated technical debt. This fork brings the following structural improvements:

### 1. Native Desktop Stability (Windows & Linux C/C++)
- **Robust Error Handling:** Root causes in the C/C++ layer have been fixed to ensure stability.
- **Crash Prevention:** Memory management and error propagation in the native Windows (C++) and Linux (C) implementations have been hardened.
- **Production-Ready:** System integrity is prioritized over "green tests." No more segmentation faults or silent crashes on desktop platforms.

### 2. Android Modernization (Media3 / ExoPlayer)
- **Full Migration:** Completely switched to `androidx.media3:exoplayer`.
- **Min SDK 26:** Support for Android 4.4 to 7.1 has been dropped. This fork requires **Android 8.0 (Oreo) API 26** minimum to ensure modern background handling and stable streaming.
- **Unification:** Merged `audioplayers_android` and `audioplayers_android_exo` into a single, modern Android codebase. No more redundancy.
- **Native Cleanup:** Removed legacy classes like `SoundPoolPlayer` and `MediaPlayerWrapper` to drastically reduce the bug surface.

### 3. Professional Testing Strategy (Mocktail)
- **Functional Mocks:** Systematic use of `mocktail` to isolate Dart logic from native dependencies.
- **Full Coverage:** Core commands (`play`, `pause`, `stop`, `seek`, `dispose`) and all sources (`Url`, `Asset`, `Bytes`) are unit-tested.
- **Bulletproof CI:** GitHub Actions validates static analysis, formatting, unit tests, and **actual compilation** for all platforms.

### 4. Code Health & Optimization
- **Zero Dead Code:** Removed useless abstractions and "just-in-case" code.
- **Strict Linting:** Enforced rigorous linting rules for a uniform codebase.
- **API Reliability:** Focus on the reliability of core functions.

## 🎯 Platform Setup

### Windows
Please follow the Flutter guide to [set up Flutter on Windows](https://docs.flutter.dev/get-started/install/windows#windows-setup).

Optionally you can add the individual component `NuGet package manager` inside **Visual Studio** or **Visual Studio Build Tools**, otherwise it will be downloaded while building.

### Linux
> Note: If Flutter was installed via Snap, you might encounter build errors due to dependency mismatching (like `glibc`). Check out how to install the Flutter SDK manually or build your application on a former Ubuntu release, e.g. `ubuntu:20.04` via `lxd`.

#### Debian / Ubuntu
**Dev Dependencies:**
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```
**App Dependencies (Optional for .m3u8):**
```bash
sudo apt-get install gstreamer1.0-plugins-good gstreamer1.0-plugins-bad
```

#### ArchLinux
```bash
sudo pacman -S gstreamer gst-libav gst-plugins-base gst-plugins-good
```

#### Fedora / RHEL
```bash
sudo dnf install clang cmake ninja-build pkg-config gstreamer1-devel gstreamer1-plugins-base-devel
```

## 🎯 Philosophy
This fork is for developers who don't "mess around" with app stability. We prioritize **predictability** and **development speed** over unnecessary complexity.
