import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'audioplayers.dart';

/// This class represents a cache for Local Assets to be played.
///
/// Flutter can only play audios on device folders, so first this class copies the files to a temporary folder, and then plays them.
/// You can pre-cache your audio, or clear the cache, as desired.
class AudioCache {
  /// A reference to the loaded files.
  Map<String, File> loadedFiles = {};

  /// This is the path inside your assets folder where your files lie.
  ///
  /// For example, Flame uses the prefix 'assets/audio/' (you must include the final slash!).
  /// The default prefix (if not provided) is 'assets/'
  /// Your files will be found at <prefix><fileName> (so the trailing slash is crucial).
  String prefix;

  /// This is an instance of AudioPlayer that, if present, will always be used.
  ///
  /// If not set, the AudioCache will create and return a new instance of AudioPlayer every call, allowing for simultaneous calls.
  /// If this is set, every call will overwrite previous calls.
  AudioPlayer? fixedPlayer;

  /// This flag should be set to true, if player is used for playing internal notifications
  ///
  /// This flag will have influence of stream type, and will respect silent mode if set to true.
  ///
  /// Not implemented on macOS.
  bool respectSilence;

  /// This flag should be set to true, if player is used for playing sound while there may be music
  ///
  /// Defaults to false, meaning the audio will be paused while playing on iOS and continue playing on Android.
  bool duckAudio;

  AudioCache({
    this.prefix = 'assets/',
    this.fixedPlayer,
    this.respectSilence = false,
    this.duckAudio = false,
  }) : assert(!kIsWeb, 'AudioCache is not available for Flutter Web.');

  /// Clears the cache of the file [fileName].
  ///
  /// Does nothing if the file was not on cache.
  void clear(String fileName) {
    final file = loadedFiles.remove(fileName);
    file?.delete();
  }

  /// Clears the whole cache.
  void clearCache() {
    for (final file in loadedFiles.values) {
      file.delete();
    }
    loadedFiles.clear();
  }

  /// Disables [AudioPlayer] logs (enable only if debugging, otherwise they can be quite overwhelming).
  ///
  /// TODO(luan) there are still some logs on the android native side that we could not get rid of, if you'd like to help, please send us a PR!
  void disableLog() {
    AudioPlayer.logEnabled = false;
  }

  Future<ByteData> _fetchAsset(String fileName) async {
    return await rootBundle.load('$prefix$fileName');
  }

  Future<File> fetchToMemory(String fileName) async {
    final file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.create(recursive: true);
    return await file
        .writeAsBytes((await _fetchAsset(fileName)).buffer.asUint8List());
  }

  /// Loads all the [fileNames] provided to the cache.
  ///
  /// Also returns a list of [Future]s for those files.
  Future<List<File>> loadAll(List<String> fileNames) async {
    return Future.wait(fileNames.map(load));
  }

  /// Loads a single [fileName] to the cache.
  ///
  /// Also returns a [Future] to access that file.
  Future<File> load(String fileName) async {
    if (!loadedFiles.containsKey(fileName)) {
      loadedFiles[fileName] = await fetchToMemory(fileName);
    }
    return loadedFiles[fileName]!;
  }

  AudioPlayer _player(PlayerMode mode) {
    return fixedPlayer ?? new AudioPlayer(mode: mode);
  }

  /// Plays the given [fileName].
  ///
  /// If the file is already cached, it plays immediately. Otherwise, first waits for the file to load (might take a few milliseconds).
  /// It creates a new instance of [AudioPlayer], so it does not affect other audios playing (unless you specify a [fixedPlayer], in which case it always use the same).
  /// The instance is returned, to allow later access (either way), like pausing and resuming.
  ///
  /// isNotification and stayAwake are not implemented on macOS
  Future<AudioPlayer> play(
    String fileName, {
    double volume = 1.0,
    bool? isNotification,
    PlayerMode mode = PlayerMode.MEDIA_PLAYER,
    bool stayAwake = false,
    bool recordingActive = false,
    bool? duckAudio,
  }) async {
    String url = await getAbsoluteUrl(fileName);
    AudioPlayer player = _player(mode);
    player.setReleaseMode(ReleaseMode.STOP);
    await player.play(
      url,
      volume: volume,
      respectSilence: isNotification ?? respectSilence,
      stayAwake: stayAwake,
      recordingActive: recordingActive,
      duckAudio: duckAudio ?? this.duckAudio,
    );
    return player;
  }

  /// Plays the given [fileName] by a byte source.
  ///
  /// This is no different than calling this API via AudioPlayer, except it will return (if applicable) the cached AudioPlayer.
  Future<AudioPlayer> playBytes(
    Uint8List fileBytes, {
    double volume = 1.0,
    bool? isNotification,
    PlayerMode mode = PlayerMode.MEDIA_PLAYER,
    bool loop = false,
    bool stayAwake = false,
    bool recordingActive = false,
  }) async {
    AudioPlayer player = _player(mode);

    if (loop) {
      player.setReleaseMode(ReleaseMode.LOOP);
    }

    await player.playBytes(
      fileBytes,
      volume: volume,
      respectSilence: isNotification ?? respectSilence,
      stayAwake: stayAwake,
      recordingActive: recordingActive,
    );
    return player;
  }

  /// Like [play], but loops the audio (starts over once finished).
  ///
  /// The instance of [AudioPlayer] created is returned, so you can use it to stop the playback as desired.
  ///
  /// isNotification and stayAwake are not implemented on macOS.
  Future<AudioPlayer> loop(
    String fileName, {
    double volume = 1.0,
    bool? isNotification,
    PlayerMode mode = PlayerMode.MEDIA_PLAYER,
    bool stayAwake = false,
  }) async {
    String url = await getAbsoluteUrl(fileName);
    AudioPlayer player = _player(mode);
    player.setReleaseMode(ReleaseMode.LOOP);
    player.play(
      url,
      volume: volume,
      respectSilence: isNotification ?? respectSilence,
      stayAwake: stayAwake,
    );
    return player;
  }

  Future<String> getAbsoluteUrl(String fileName) async {
    if (kIsWeb) {
      return 'assets/$prefix$fileName';
    }
    File file = await load(fileName);
    return file.path;
  }
}
