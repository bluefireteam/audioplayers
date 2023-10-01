<p align="center">
  <a href="https://pub.dev/packages/audioplayers">
    <img alt="AudioPlayers" height="150px" src="https://raw.githubusercontent.com/bluefireteam/audioplayers/main/images/logo_ap_compact.svg">
  </a>
</p>

---

# audioplayers_linux
<p>
  <a title="Pub" href="https://pub.dev/packages/audioplayers_linux"><img src="https://img.shields.io/pub/v/audioplayers_linux.svg?style=popout&include_prereleases"/></a>
  <a title="Build Status" href="https://github.com/bluefireteam/audioplayers/actions?query=workflow%3Abuild+branch%3Amain"><img src="https://github.com/bluefireteam/audioplayers/workflows/build/badge.svg?branch=main"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

The Linux implementation of [`audioplayers`](https://pub.dev/packages/audioplayers).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `audioplayers` normally. 
This package will be automatically included in your app when you do, so you do not need to add it to your `pubspec.yaml`.

## Setup for Linux

> Note: If Flutter was installed via [Snap](https://docs.flutter.dev/get-started/install/linux#install-flutter-using-snapd), you might encounter build errors due to dependency mismatching (like `glibc`). Check out how to [install the Flutter SDK manually](https://docs.flutter.dev/get-started/install/linux#install-flutter-manually) or build your application on a former Ubuntu release, e.g. `ubuntu:20.04` via `lxd`.

### Debian

#### Dev Dependencies

[Flutter](https://docs.flutter.dev/get-started/install/linux#linux-setup) dependencies:

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

[GStreamer](https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c):

```bash
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```

#### App Dependencies

Optional GStreamer Plugins (e.g. for `.m3u8`):

```bash
sudo apt-get install gstreamer1.0-plugins-good gstreamer1.0-plugins-bad
```

### ArchLinux

For Arch, simply install gstreamer and its plugins via `pacman`:

```bash
sudo pacman -S gstreamer gst-libav gst-plugins-base gst-plugins-good
```

You can install additional plugins as needed following [the Wiki](https://wiki.archlinux.org/title/GStreamer).
