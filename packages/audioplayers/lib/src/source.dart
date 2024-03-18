import 'package:audioplayers/src/audioplayer.dart';
import 'package:flutter/foundation.dart';

/// A generic representation of a source from where audio can be pulled.
///
/// This can be a remote or local URL, an application asset, or the file bytes.
abstract class Source {
  String? get mimeType;

  Future<void> setOnPlayer(AudioPlayer player);
}

/// Source representing a remote URL to be played from the Internet.
/// This can be an audio file to be downloaded or an audio stream.
class UrlSource extends Source {
  final String url;

  @override
  final String? mimeType;

  UrlSource(this.url, {this.mimeType});

  @override
  Future<void> setOnPlayer(AudioPlayer player) {
    return player.setSourceUrl(url, mimeType: mimeType);
  }

  @override
  String toString() {
    return 'UrlSource(url: $url, mimeType: $mimeType)';
  }
}

/// Source representing the absolute path of a file in the user's device.
class DeviceFileSource extends Source {
  final String path;

  @override
  final String? mimeType;

  DeviceFileSource(this.path, {this.mimeType});

  @override
  Future<void> setOnPlayer(AudioPlayer player) {
    return player.setSourceDeviceFile(path, mimeType: mimeType);
  }

  @override
  String toString() {
    return 'DeviceFileSource(path: $path, mimeType: $mimeType)';
  }
}

/// Source representing the path of an application asset in your Flutter
/// "assets" folder.
/// Note that a prefix might be applied by your [AudioPlayer]'s audio cache
/// instance.
class AssetSource extends Source {
  final String path;

  @override
  final String? mimeType;

  AssetSource(this.path, {this.mimeType});

  @override
  Future<void> setOnPlayer(AudioPlayer player) {
    return player.setSourceAsset(path, mimeType: mimeType);
  }

  @override
  String toString() {
    return 'AssetSource(path: $path, mimeType: $mimeType)';
  }
}

/// Source containing the actual bytes of the media to be played.
///
/// This is currently only supported for Android (SDK >= 23).
class BytesSource extends Source {
  final Uint8List bytes;

  @override
  final String? mimeType;

  BytesSource(this.bytes, {this.mimeType});

  @override
  Future<void> setOnPlayer(AudioPlayer player) {
    return player.setSourceBytes(bytes, mimeType: mimeType);
  }

  @override
  String toString() {
    final bytesHash =
        Object.hashAll(bytes).toUnsigned(20).toRadixString(16).padLeft(5, '0');
    return 'BytesSource(bytes: $bytesHash, mimeType: $mimeType)';
  }
}
