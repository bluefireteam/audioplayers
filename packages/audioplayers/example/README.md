# AudioPlayer Example

This is an example usage of audioplayers plugin.
Check out the live [example app](https://bluefireteam.github.io/audioplayers/) as demonstration.

It's a simple app with several tabs:
- **Src**: Manage audio sources.
  - Url: Plays audio from a remote Url from the Internet.
  - Asset: Play one of the assets bundled with this app.
  - Device File: Play a file from your device from the specified path.
  - Byte Array: Play from an array of bytes.
- **Ctrl**: Control playback, such as volume, balance and rate.
- **Stream**: Display of stream updates and properties.
- **Ctx**: Customize the audio context for mobile devices. 
- **Log**: Display of logs.

This example bundles a `PlayerWidget` that could be used as a very simple audio player interface.

## Setup

In order to successfully run the example locally, you have to [set up](https://github.com/bluefireteam/audioplayers/blob/main/contributing.md#environment-setup) your environment with `melos`.

## Dart Environment Variables

Set the following variables as additional args `--dart-define MY_VAR=xyz`:

- `USE_LOCAL_SERVER`: uses links to local server instead of public accessible links, default: `false`.
