import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers_platform_interface/api/audio_context_config.dart';
import 'package:audioplayers_platform_interface/api/player_mode.dart';
import 'package:audioplayers_platform_interface/api/release_mode.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:audioplayers_platform_interface/streams_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'wrapped_player.dart';

class AudioplayersPlugin extends AudioplayersPlatform with StreamsInterface {
  /// The entrypoint called by the generated plugin registrant.
  static void registerWith(Registrar registrar) {
    AudioplayersPlatform.instance = AudioplayersPlugin();
  }

  // players by playerId
  Map<String, WrappedPlayer> players = {};

  WrappedPlayer getOrCreatePlayer(String playerId) {
    return players.putIfAbsent(playerId, () => WrappedPlayer(playerId, this));
  }

  @override
  Future<int?> getCurrentPosition(String playerId) async {
    final position = getOrCreatePlayer(playerId).player?.currentTime;
    if (position == null) {
      return null;
    }
    return (position * 1000).toInt();
  }

  @override
  Future<int?> getDuration(String playerId) async {
    final duration = getOrCreatePlayer(playerId).player?.duration;
    if (duration == null) {
      return null;
    }
    return (duration * 1000).toInt();
  }

  @override
  Future<void> pause(String playerId) async {
    getOrCreatePlayer(playerId).pause();
  }

  @override
  Future<void> release(String playerId) async {
    getOrCreatePlayer(playerId).release();
  }

  @override
  Future<void> resume(String playerId) async {
    getOrCreatePlayer(playerId).resume();
  }

  @override
  Future<void> seek(String playerId, Duration position) async {
    getOrCreatePlayer(playerId).seek(position.inMilliseconds);
  }

  @override
  Future<void> setAudioContext(
    String playerId,
    AudioContext audioContext,
  ) async {
    // no-op: web doesn't have any audio context
  }

  @override
  Future<void> setPlayerMode(
    String playerId,
    PlayerMode playerMode,
  ) async {
    // no-op: web doesn't have multiple modes
  }

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async {
    getOrCreatePlayer(playerId).setPlaybackRate(playbackRate);
  }

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {
    getOrCreatePlayer(playerId).setReleaseMode(releaseMode);
  }

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
  }) async {
    getOrCreatePlayer(playerId).setUrl(url);
  }

  @override
  Future<void> setSourceBytes(String playerId, Uint8List bytes) {
    // TODO: implement setSourceBytes
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(String playerId, double volume) async {
    getOrCreatePlayer(playerId).setVolume(volume);
  }

  @override
  Future<void> stop(String playerId) async {
    getOrCreatePlayer(playerId).stop();
  }
}
