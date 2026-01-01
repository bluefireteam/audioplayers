import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

/// Represents a function that can stop an audio playing.
typedef StopFunction = Future<void> Function();

/// An AudioPool is a provider of AudioPlayers that are pre-loaded with an asset
/// to minimize delays.
///
/// All AudioPlayers are loaded with the same audio [source].
/// If you want multiple sounds use multiple [AudioPool]s.
///
/// Use this class if you for example have extremely quick firing, repetitive
/// or simultaneous sounds.
class AudioPool {
  @visibleForTesting
  final Map<String, AudioPlayer> currentPlayers = {};
  @visibleForTesting
  final List<AudioPlayer> availablePlayers = [];

  /// Timers to automatically stop players after the duration of the audio.
  final Map<String, Timer> _timers = {};

  /// The duration of the audio source.
  final Duration duration;

  /// Instance of [AudioCache] to be used by all players.
  final AudioCache audioCache;

  /// Platform specific configuration.
  final AudioContext? audioContext;

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

  /// Whether the players in this pool use low latency mode.
  final bool usesLowLatencyMode;

  /// Lock to synchronize access to the pool.
  final Lock _lock = Lock();

  AudioPool._({
    required this.minPlayers,
    required this.maxPlayers,
    required this.source,
    required this.audioContext,
    required this.duration,
    this.usesLowLatencyMode = true,
    AudioCache? audioCache,
  }) : audioCache = audioCache ?? AudioCache.instance;

  /// Creates an [AudioPool] instance with the given parameters.
  static Future<AudioPool> create({
    required Source source,
    required int maxPlayers,
    AudioCache? audioCache,
    AudioContext? audioContext,
    int minPlayers = 1,
    bool useLowLatencyMode = true,
  }) async {
    final duration = await getDuration(source);

    if (duration == null) {
      throw Exception(
        'Could not determine duration for source. '
        'Duration must be available for AudioPool to work properly.',
      );
    }

    final instance = AudioPool._(
      source: source,
      audioCache: audioCache,
      maxPlayers: maxPlayers,
      minPlayers: minPlayers,
      usesLowLatencyMode: useLowLatencyMode,
      audioContext: audioContext,
      duration: duration,
    );

    final players = <AudioPlayer>[];

    for (var i = 0; i < minPlayers; i++) {
      players.add(await instance._createNewAudioPlayer());
    }

    return instance..availablePlayers.addAll(players);
  }

  /// Creates an [AudioPool] instance with the asset from the given [path].
  static Future<AudioPool> createFromAsset({
    required String path,
    required int maxPlayers,
    AudioCache? audioCache,
    int minPlayers = 1,
    bool useLowLatencyMode = true,
  }) async {
    return create(
      source: AssetSource(path),
      audioCache: audioCache,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      useLowLatencyMode: useLowLatencyMode,
    );
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

      Future<void> stop() {
        return _lock.synchronized(() async {
          final removedPlayer = currentPlayers.remove(player.playerId);
          if (removedPlayer != null) {
            final timer = _timers.remove(player.playerId);
            timer?.cancel();
            await removedPlayer.stop();
            if (availablePlayers.length >= maxPlayers) {
              await removedPlayer.release();
            } else {
              availablePlayers.add(removedPlayer);
            }
          }
        });
      }

      // Schedule automatic stop based on audio duration
      _timers[player.playerId] = Timer(duration, stop);

      return stop;
    });
  }

  Future<AudioPlayer> _createNewAudioPlayer() async {
    final player = AudioPlayer()..audioCache = audioCache;

    if (usesLowLatencyMode) {
      await player.setPlayerMode(PlayerMode.lowLatency);
    }

    if (audioContext != null) {
      await player.setAudioContext(audioContext!);
    }
    await player.setSource(source);
    await player.setReleaseMode(ReleaseMode.stop);
    return player;
  }

  /// Disposes the audio pool. Then it cannot be used anymore.
  Future<void> dispose() async {
    // Cancel all active timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    // Dispose all players
    await Future.wait([
      ...currentPlayers.values.map((e) => e.dispose()),
      ...availablePlayers.map((e) => e.dispose()),
    ]);
    currentPlayers.clear();
    availablePlayers.clear();
  }

  /// Use FFprobe to retrieve the [Duration] of the audio source.
  static Future<Duration?> getDuration(Source source) async {
    final path = switch (source) {
      AssetSource() => await AudioCache.instance.loadPath(source.path),
      UrlSource() => source.url,
      DeviceFileSource() => source.path,
      BytesSource() => throw Exception(
          'Cannot get duration for ByteSource, unsupported source type.',
        ),
      _ => throw Exception('Unsupported source type: ${source.runtimeType}'),
    };

    final session = await FFprobeKit.getMediaInformation(path);
    try {
      final information = session.getMediaInformation();
      if (information == null) {
        throw Exception('Failed to get media information for $path');
      }

      final durationString = information.getDuration();
      if (durationString == null) {
        throw Exception('Failed to get media duration for $path');
      }

      final durationInSeconds = double.tryParse(durationString);
      if (durationInSeconds == null) {
        throw Exception(
          'Failed to parse media duration "$durationString" for $path',
        );
      }

      return Duration(milliseconds: (durationInSeconds * 1000).ceil());
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
