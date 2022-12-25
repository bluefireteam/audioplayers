# AudioPlayer Example

This is an example usage of audioplayers plugin.

It's a simple app with three tabs.

- Remote Url: Plays audio from a remote url from the Internet.
- Local File: Downloads a file to your device in order to play it from your device.
- Local Asset: Play one of the assets bundled with this app.

This example bundles a `PlayerWidget` that could be used as a very simple audio player interface.

## Dart Environment Variables

Set the following variables as additional args `--dart-define MY_VAR=xyz`:

- `USE_LOCAL_SERVER`: uses links to local server instead of public accessible links, default: `false`.
