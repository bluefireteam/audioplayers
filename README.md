<p align="center">
  <a href="https://pub.dev/packages/audioplayers">
    <img alt="AudioPlayers" height="150px" src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/logo_ap_compact.svg">
  </a>
</p>

<p align="center">
  <b>Hardened Fork | Fork Robuste</b>
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/audioplayers"><img src="https://img.shields.io/pub/v/audioplayers.svg?style=popout&include_prereleases"/></a>
  <a title="Build Status" href="https://github.com/Sebastien-VZN/audioplayers/actions?query=workflow%3Abuild+branch%3Amain"><img src="https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build.yml/badge.svg?branch=main"/></a>
</p>

[![Build Check](https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build_check.yml/badge.svg)](https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build_check.yml)

This fork of `bluefireteam/audioplayers` was created to transform a fragmented and aging plugin into an **industrial-grade, stable, and high-performance** tool. The goal is to provide a clean codebase, stripped of obsolescence, and protected by a rigorous testing suite.

## 🛠️ Why this fork? (Technical Decisions)

The original repository suffered from excessive fragmentation and accumulated technical debt. This fork brings the following structural improvements:

### 1. Native Desktop Stability (Windows & Linux C/C++)
- **Robust Error Handling:** Unlike the original codebase, which often tolerated native crashes or "dirty" exits just to bypass test failures, this fork fixes root causes in the C/C++ layer.
- **Crash Prevention:** Memory management and error propagation in the native Windows (C++) and Linux (C) implementations have been hardened to ensure the host application remains stable even during playback failures.
- **Production-Ready:** We prioritize system integrity over "green tests." No more segmentation faults or silent crashes on desktop platforms.

### 2. Android Modernization (Media3 / ExoPlayer)
- **Full Migration:** Completely switched to `androidx.media3:exoplayer`. The obsolete native `MediaPlayer` implementation (notoriously unstable for remote streams) has been removed.
- **Unification:** Merged `audioplayers_android` and `audioplayers_android_exo` into a single, modern Android codebase. No more redundancy.
- **Native Cleanup:** Removed legacy classes like `SoundPoolPlayer` and `MediaPlayerWrapper` to drastically reduce the bug surface.

### 3. Professional Testing Strategy (Mocktail)
While the original integration tests were slow and flaky, this fork implements production-level unit testing:
- **Functional Mocks:** Systematic use of `mocktail` to isolate Dart logic from native dependencies. Tests are **deterministic** and run in under a second.
- **Full Coverage:** Core commands (`play`, `pause`, `stop`, `seek`, `dispose`) and all sources (`Url`, `Asset`, `Bytes`) are unit-tested.
- **Bulletproof CI:** GitHub Actions now validates static analysis (strict Linter), formatting, unit tests, and **actual compilation** for all platforms (Android, iOS, macOS, Windows, Linux, Web) on every commit.

### 4. Code Health & Optimization
- **Zero Dead Code:** Massive removal of useless abstractions and "just-in-case" code that hindered maintenance.
- **Strict Linting:** Enforced rigorous linting rules to ensure a uniform and readable codebase.
- **API Reliability:** Focus on the reliability of core functions rather than the frantic addition of unstable features.

## 🎯 Philosophy

This fork is for developers who don't "mess around" with app stability. We prioritize **predictability** and **development speed** (through fast, reliable tests) over unnecessary complexity.
