import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'audioplayers.dart';

/// This class represents a cache for Local Assets to be played.
///
/// Flutter can only play audios on device folders, so this first copies files to a temporary folder and the plays then.
/// You can pre-cache your audio, or clear the cache, as desired.
class AudioCache {
  /// A reference to the loaded files.
  Map<String, File> loadedFiles = {};

  /// This is the path inside your assets folder where your files lie.
  ///
  /// For example, Flame uses the prefix 'audio/' (must include the slash!).
  /// Your files will be found at assets/<prefix><fileName>
  String prefix;

  AudioCache([this.prefix = ""]);

  /// Clear the cache of the file [fileName].
  ///
  /// Does nothing if there was already no cache.
  void clear(String fileName) {
    loadedFiles.remove(fileName);
  }

  /// Clear the whole cache.
  void clearCache() {
    loadedFiles.clear();
  }

  /// Disable [AudioPlayer] logs (enable only if debuggin, otherwise they can be quite overwhelming).
  void disableLog() {
    AudioPlayer.logEnabled = false;
  }

  Future<ByteData> _fetchAsset(String fileName) async {
    return await rootBundle.load('assets/$prefix$fileName');
  }

  Future<File> fetchToMemory(String fileName) async {
    final file = new File('${(await getTemporaryDirectory()).path}/$fileName');
    return await file
        .writeAsBytes((await _fetchAsset(fileName)).buffer.asUint8List());
  }

  /// Load all the [fileNames] provided to the cache.
  ///
  /// Also retruns a list of [Future]s for those files.
  Future<List<File>> loadAll(List<String> fileNames) async {
    return Future.wait(fileNames.map(load));
  }

  /// Load a single [fileName] to the cache.
  ///
  /// Also retruns a [Future] to access that file.
  Future<File> load(String fileName) async {
    if (!loadedFiles.containsKey(fileName)) {
      loadedFiles[fileName] = await fetchToMemory(fileName);
    }
    return loadedFiles[fileName];
  }

  /// Plays the given [fileName].
  ///
  /// If the file is already cached, it plays imediatelly. Otherwise, first waits for the file to load.
  /// It creates a new instance of [AudioPlayer], so it does not affect other audios playing.
  /// The instance is returned, to allow later access.
  Future<AudioPlayer> play(String fileName, {double volume = 1.0}) async {
    File file = await load(fileName);
    return await new AudioPlayer()
      ..play(file.path, isLocal: true, volume: volume);
  }

  /// Like [play], but loops the audio (starts over once finished).
  ///
  /// It adds a completion handler that starts to play again once finished.
  /// The instance of [AudioPlayer] created is returned, so you can use it to stop the playback as desired.
  Future<AudioPlayer> loop(String fileName, {double volume = 1.0}) async {
    File file = await load(fileName);
    AudioPlayer player = new AudioPlayer();
    player.completionHandler = () {
      player.play(file.path, isLocal: true, volume: volume);
    };
    return await player
      ..play(file.path, isLocal: true);
  }
}
