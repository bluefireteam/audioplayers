import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:meta/meta.dart';

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
  /// This flag will have influence of stream type, and will respect silent mode if set to true
  bool respectSilence;

  AudioCache({this.prefix = "", this.fixedPlayer, this.respectSilence = false});

  /// Clears the cache of the file [fileName].
  ///
  /// Does nothing if the file was not on cache.
  void clear(String fileName) {
    loadedFiles.remove(fileName);
  }

  /// Clears the whole cache.
  void clearCache() {
    loadedFiles.clear();
  }

  /// Disables [AudioPlayer] logs (enable only if debugging, otherwise they can be quite overwhelming).
  ///
  /// TODO: there are still some logs on the android native side that we could not get rid of, if you'd like to help, please send us a PR!
  void disableLog() {
    AudioPlayer.logEnabled = false;
  }

  Future<ByteData> _fetchAsset(String fileName) async {
    return await rootBundle.load('assets/$prefix$fileName');
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
    return loadedFiles[fileName];
  }

  AudioPlayer _player(PlayerMode mode) {
    return fixedPlayer ?? new AudioPlayer(mode: mode);
  }

  @visibleForTesting
  Future<AudioPlayer> inner_play({
      File file,        // either file object
      String fileName,  // or file name
      double volume = 1.0,
      bool isNotification,
      PlayerMode mode = PlayerMode.MEDIA_PLAYER,
      bool stayAwake,
      AudioPlayer player}) async {

    if (file == null) file = await load(fileName);
    if (player == null) player = _player(mode);
    await player.play(
      file.path,
      isLocal: true,
      volume: volume,
      respectSilence: isNotification ?? respectSilence,
      stayAwake: stayAwake,
    );
    return player;
  }

  /// Plays the given [fileName].
  ///
  /// If the file is already cached, it plays immediately. Otherwise, first waits for the file to load (might take a few milliseconds).
  /// It creates a new instance of [AudioPlayer], so it does not affect other audios playing (unless you specify a [fixedPlayer], in which case it always use the same).
  /// The instance is returned, to allow later access (either way), like pausing and resuming.
  Future<AudioPlayer> play(String fileName,
      {double volume = 1.0,
      bool isNotification,
      PlayerMode mode = PlayerMode.MEDIA_PLAYER,
      bool stayAwake}) async {
    File file = await load(fileName);
    return inner_play(
      file: file,
      volume: volume,
      isNotification: isNotification,
      mode: mode,
      stayAwake: stayAwake
    );
  }

  /// Like [play], but waits until audio has finished playing
  Future<AudioPlayer> playSync(String fileName,
      {double volume = 1.0,
      bool isNotification,
      bool stayAwake}) async {
    Completer<AudioPlayer> c = new Completer();
    StreamSubscription completionListener;

    AudioPlayer playerInstance = await play(fileName,
      volume: volume,
      isNotification: isNotification,
      // force mode to get completion event
      mode: PlayerMode.MEDIA_PLAYER,
      stayAwake: stayAwake
    );

    completionListener = playerInstance.onPlayerCompletion.listen((_) {
      completionListener.cancel();
      c.complete(playerInstance);
    });

    return c.future;
  }

  /// Like [play], but plays multiple files in sequence.
  ///
  /// The instance is returned immediately, to allow later access like pausing and resuming.
  Future<AudioPlayer> playAll(List<String> fileNames,
      {double volume = 1.0,
      bool isNotification,
      bool stayAwake}) async {
    if (fileNames.length == 0) return new Future.value(null);
    AudioPlayer playerInstance;
    StreamSubscription completionListener;

    // inner function
    playNext() async {
      playerInstance = await inner_play(
        fileName: fileNames.removeAt(0),
        volume: volume,
        isNotification: isNotification,
        // force mode to get completion event
        mode: PlayerMode.MEDIA_PLAYER,
        stayAwake: stayAwake,
        // re-use same player instance
        player: playerInstance,
      );
    };

    // pre-load all files
    await loadAll(fileNames);
    await playNext();

    completionListener = playerInstance.onPlayerCompletion.listen((_){
      if (fileNames.length > 0 && playerInstance.state != AudioPlayerState.STOPPED) {
        playNext();
      } else {
        completionListener.cancel();
      }
    });

    return playerInstance;
  }

  /// Like [play], but loops the audio (starts over once finished).
  ///
  /// The instance of [AudioPlayer] created is returned, so you can use it to stop the playback as desired.
  Future<AudioPlayer> loop(String fileName,
      {double volume = 1.0,
      bool isNotification,
      PlayerMode mode = PlayerMode.MEDIA_PLAYER,
      bool stayAwake}) async {
    AudioPlayer player = _player(mode);
    player.setReleaseMode(ReleaseMode.LOOP);
    inner_play(
      fileName: fileName,
      volume: volume,
      isNotification: isNotification,
      stayAwake: stayAwake,
      player: player
    );
    return player;
  }
}
