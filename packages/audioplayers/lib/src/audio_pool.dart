import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

/// Represents a function that can stop an audio playing.
typedef StopFunction = Future<void> Function();

/// An AudioPool is a provider of AudioPlayers that are pre-loaded with an asset
/// to minimize delays.
///
/// All AudioPlayers are loaded with the same file from `soundPath` or [source].
/// If you want multiple sounds use multiple [AudioPool]s.
///
/// Use this class if you for example have extremely quick firing, repetitive
/// or simultaneous sounds.
class AudioPool {
  @visibleForTesting
  final Map<String, AudioPlayer> currentPlayers = {};
  @visibleForTesting
  final List<AudioPlayer> availablePlayers = [];

  /// Instance of [AudioCache] to be used by all players.
  final AudioCache audioCache;

  /// The source of the sound for this pool.
  final Source source;

  /// The minimum numbers of players, this is the amount of players that the
  /// pool is initialized with.
  final int minPlayers;

  /// The maximum number of players to be kept in the pool.
  ///
  /// If `start` is called after the pool is full there will still be new
  /// [AudioPlayer]s created, but once they are stopped they will not be
  /// returned to the pool.
  final int maxPlayers;

  final Lock _lock = Lock();

  AudioPool._({
    required this.minPlayers,
    required this.maxPlayers,
    String? assetPath,
    Source? source,
    AudioCache? audioCache,
  })  : assert(
          (assetPath != null) ^ (source != null),
          'Either provide a assetPath or a source.',
        ),
        audioCache = audioCache ?? AudioCache.instance,
        source = source ?? AssetSource(assetPath!);

  /// Creates an [AudioPool] instance from the given [source].
  static Future<AudioPool> create({
    required Source source,
    AudioCache? audioCache,
    int minPlayers = 1,
    required int maxPlayers,
  }) async {
    return _create(
      source: source,
      audioCache: audioCache,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
    );
  }

  /// Creates an [AudioPool] instance with the asset from the given [assetPath].
  static Future<AudioPool> createFromAsset({
    required String assetPath,
    AudioCache? audioCache,
    int minPlayers = 1,
    required int maxPlayers,
  }) async {
    return _create(
      assetPath: assetPath,
      audioCache: audioCache,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
    );
  }

  /// Creates an [AudioPool] instance with the given parameters.
  static Future<AudioPool> _create({
    String? assetPath,
    Source? source,
    AudioCache? audioCache,
    int minPlayers = 1,
    required int maxPlayers,
  }) async {
    final instance = AudioPool._(
      assetPath: assetPath,
      source: source,
      audioCache: audioCache,
      maxPlayers: maxPlayers,
      minPlayers: minPlayers,
    );

    final players = await Future.wait(
      List.generate(minPlayers, (_) => instance._createNewAudioPlayer()),
    );

    return instance..availablePlayers.addAll(players);
  }

  /// Starts playing the audio, returns a function that can stop the audio.
  Future<StopFunction> start({double volume = 1.0}) async {
    return _lock.synchronized(() async {
      if (availablePlayers.isEmpty) {
        availablePlayers.add(await _createNewAudioPlayer());
      }
      final player = availablePlayers.removeAt(0);
      currentPlayers[player.playerId] = player;
      await player.setVolume(volume);
      await player.resume();

      late StreamSubscription<void> subscription;

      Future<void> stop() {
        return _lock.synchronized(() async {
          final removedPlayer = currentPlayers.remove(player.playerId);
          if (removedPlayer != null) {
            subscription.cancel();
            await removedPlayer.stop();
            if (availablePlayers.length >= maxPlayers) {
              await removedPlayer.release();
            } else {
              availablePlayers.add(removedPlayer);
            }
          }
        });
      }

      subscription = player.onPlayerComplete.listen((_) => stop());

      return stop;
    });
  }

  Future<AudioPlayer> _createNewAudioPlayer() async {
    final player = AudioPlayer()..audioCache = audioCache;
    await player.setSource(source);
    await player.setReleaseMode(ReleaseMode.stop);
    return player;
  }
}
