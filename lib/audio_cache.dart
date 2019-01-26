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

  /// This is an instance of AudioPlayer that, if present, will always be used.
  ///
  /// If not set, the AudioCache will create and return a new instance of AudioPlayer every call, allowing for simultaneous calls.
  /// If this is set, every call will overwrite previous calls.
  AudioPlayer fixedPlayer;

  /// This flag should be set to true, if player is used for playing internal notifications
  ///
  /// This flag will have influence of stream type. And will respect silent mode if set to true
  bool respectSilence;

  AudioCache({this.prefix = "", this.fixedPlayer = null, this.respectSilence = false});

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
    await file.create(recursive: true);
    return await file.writeAsBytes((await _fetchAsset(fileName)).buffer.asUint8List());
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

  AudioPlayer _player() {
    return fixedPlayer ?? new AudioPlayer();
  }

  /// Plays the given [fileName].
  ///
  /// If the file is already cached, it plays imediatelly. Otherwise, first waits for the file to load (might take a few milliseconds).
  /// It creates a new instance of [AudioPlayer], so it does not affect other audios playing (unless you specify a [fixedPlayer], in which case it always use the same).
  /// The instance is returned, to allow later access (either way).
  Future<AudioPlayer> play(String fileName, {double volume = 1.0, bool isNotification}) async {
    File file = await load(fileName);
    AudioPlayer player = _player();
    await player.play(
      file.path,
      isLocal: true,
      volume: volume,
      respectSilence: isNotification ?? respectSilence,
    );
    return player;
  }

  /// Like [play], but loops the audio (starts over once finished).
  ///
  /// The instance of [AudioPlayer] created is returned, so you can use it to stop the playback as desired.
  Future<AudioPlayer> loop(String fileName, {double volume = 1.0, bool isNotification}) async {
    File file = await load(fileName);
    AudioPlayer player = _player();
    player.setReleaseMode(ReleaseMode.LOOP);
    player.play(
      file.path,
      isLocal: true,
      volume: volume,
      respectSilence: isNotification ?? respectSilence,
    );
    return player;
  }
}
