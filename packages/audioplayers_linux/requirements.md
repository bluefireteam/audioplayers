Need to [install flutter manually](https://docs.flutter.dev/get-started/install/linux#install-flutter-manually), as snap does not support the according cmake version. 
Should be fixed when updated to [core20](https://github.com/canonical/flutter-snap/pull/61).

// TODO may can downgrade implementation to work with cmake 3.10

Flutter dependencies:
```
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

GStreamer:
```
sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```

Optional GStreamer Bad Plugins (e.g. for `.m3u8`):
```
sudo apt-get install gstreamer1.0-plugins-bad
```
