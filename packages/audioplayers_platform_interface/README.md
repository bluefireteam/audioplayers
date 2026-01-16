<p align="center">
  <a href="https://pub.dev/packages/audioplayers">
    <img alt="AudioPlayers" height="150px" src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/logo_ap_compact.svg">
  </a>
</p>

---

# audioplayers_platform_interface
<p>
  <a title="Pub" href="https://pub.dev/packages/audioplayers_platform_interface"><img src="https://img.shields.io/pub/v/audioplayers_platform_interface.svg?style=popout&include_prereleases"/></a>
  <a title="Build Status" href="https://github.com/Sebastien-VZN/audioplayers/actions?query=workflow%3Abuild+branch%3Amain"><img src="https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build.yml/badge.svg?branch=main"/></a>
</p>

A common platform interface for the [`audioplayers`](https://pub.dev/packages/audioplayers) plugin.

## Usage

This package will be automatically included in your app, 
which means you can simply use `audioplayers` normally, without adding this package to your `pubspec.yaml`.

To implement a new platform-specific implementation of `audioplayers`, extend
[`AudioplayersPlatformInterface`](lib/src/audioplayers_platform_interface.dart)
with an implementation that performs the platform-specific behavior.
When you register your plugin, set the default
`AudioplayersPlatformInterface` by calling `AudioplayersPlatformInterface.instance = MyAudioplayersPlatform()`.
Then do the same for [`GlobalAudioplayersPlatformInterface`](lib/src/global_audioplayers_platform_interface.dart).
