import 'dart:async';

import 'package:audioplayers_platform_interface/api/audio_context_config.dart';
import 'package:audioplayers_platform_interface/api/player_event.dart';
import 'package:audioplayers_platform_interface/api/player_mode.dart';
import 'package:audioplayers_platform_interface/api/release_mode.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:audioplayers_platform_interface/global_platform_interface.dart';
import 'package:audioplayers_web/global_audioplayers_web.dart';
import 'package:audioplayers_web/num_extension.dart';
import 'package:audioplayers_web/wrapped_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class AudioplayersPlugin {
  /// The entrypoint called by the generated plugin registrant.
  static void registerWith(Registrar registrar) {
    AudioplayersPlatformInterface.instance = WebAudioplayersPlatform();
    GlobalPlatformInterface.instance = GlobalWebAudioplayersPlatform();
  }
}

class WebAudioplayersPlatform extends AudioplayersPlatformInterface {
  // players by playerId
  Map<String, WrappedPlayer> players = {};

  @override
  Future<void> create(String playerId) async {
    players[playerId] = WrappedPlayer(playerId);
  }

  WrappedPlayer getPlayer(String playerId) {
    return players[playerId] != null
        ? players[playerId]!
        : throw Exception('Player with id $playerId was not created!');
  }

  @override
  Future<int?> getCurrentPosition(String playerId) async {
    final position = getPlayer(playerId).player?.currentTime;
    if (position == null) {
      return null;
    }
    return (position * 1000).toInt();
  }

  @override
  Future<int?> getDuration(String playerId) async {
    final jsDuration = getPlayer(playerId).player?.duration;
    if (jsDuration == null) {
      return null;
    }
    return jsDuration.fromSecondsToDuration().inMilliseconds;
  }

  @override
  Future<void> pause(String playerId) async {
    getPlayer(playerId).pause();
  }

  @override
  Future<void> release(String playerId) async {
    getPlayer(playerId).release();
  }

  @override
  Future<void> resume(String playerId) async {
    await getPlayer(playerId).resume();
  }

  @override
  Future<void> seek(String playerId, Duration position) async {
    getPlayer(playerId).seek(position.inMilliseconds);
  }

  @override
  Future<void> setAudioContext(
    String playerId,
    AudioContext audioContext,
  ) async {
    getPlayer(playerId).eventStreamController.add(
          const PlayerEvent(
            eventType: PlayerEventType.log,
            logMessage: 'Setting AudioContext is not supported on Web',
          ),
        );
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
    getPlayer(playerId).setPlaybackRate(playbackRate);
  }

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {
    getPlayer(playerId).setReleaseMode(releaseMode);
  }

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
  }) async {
    await getPlayer(playerId).setUrl(url);
  }

  @override
  Future<void> setSourceBytes(String playerId, Uint8List bytes) {
    // TODO(luan): implement setSourceBytes for web
    throw UnimplementedError();
  }

  @override
  Future<void> setVolume(String playerId, double volume) async {
    getPlayer(playerId).setVolume(volume);
  }

  @override
  Future<void> setBalance(String playerId, double balance) async {
    getPlayer(playerId).setBalance(balance);
  }

  @override
  Future<void> stop(String playerId) async {
    getPlayer(playerId).stop();
  }

  @override
  Future<void> emitLog(String playerId, String message) async {
    getPlayer(playerId).log(message);
  }

  @override
  Future<void> emitError(String playerId, String code, String message) async {
    getPlayer(playerId)
        .eventStreamController
        .addError(PlatformException(code: code, message: message));
  }

  @override
  Stream<PlayerEvent> getEventStream(String playerId) {
    return getPlayer(playerId).eventStreamController.stream;
  }

  @override
  Future<void> dispose(String playerId) async {
    await Future.forEach<WrappedPlayer>(
      players.values,
      (player) => player.dispose(),
    );
  }
}
