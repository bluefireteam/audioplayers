<p align="center">
  <a href="https://pub.dev/packages/audioplayers">
    <img alt="AudioPlayers" height="150px" src="https://raw.githubusercontent.com/bluefireteam/audioplayers/main/images/logo_ap_compact.svg">
  </a>
</p>

---

# audioplayers_android
<p>
  <a title="Pub" href="https://pub.dev/packages/audioplayers_android"><img src="https://img.shields.io/pub/v/audioplayers_android.svg?style=popout&include_prereleases"/></a>
  <a title="Build Status" href="https://github.com/bluefireteam/audioplayers/actions?query=workflow%3Abuild+branch%3Amain"><img src="https://github.com/bluefireteam/audioplayers/actions/workflows/build.yml/badge.svg?branch=main"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

The Android implementation of [`audioplayers`](https://pub.dev/packages/audioplayers), based on the Android
[`MediaPlayer`](https://developer.android.com/reference/android/media/MediaPlayer) and
[`SoundPool`](https://developer.android.com/reference/android/media/SoundPool).

> [!WARNING]
> This package is **deprecated** in favor of [`audioplayers_android_exo`](https://pub.dev/packages/audioplayers_android_exo),
> which is based on [Media3 ExoPlayer](https://developer.android.com/media/media3/exoplayer) and is now the default Android implementation of `audioplayers`.
> It only receives critical fixes and will be discontinued in a future release.

## Usage

This package is [not endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#non-endorsed-federated-plugin) anymore.
If you still need it (e.g. for `PlayerMode.lowLatency`), you can override the default Android implementation
by adding `audioplayers_android` to your app's `pubspec.yaml`:

```yaml
dependencies:
  audioplayers: any
  audioplayers_android: any
```
