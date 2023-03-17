import 'dart:async';

import 'package:audioplayers_platform_interface/api/audio_context_config.dart';
import 'package:audioplayers_platform_interface/api/player_event.dart';
import 'package:audioplayers_platform_interface/api/player_mode.dart';
import 'package:audioplayers_platform_interface/api/release_mode.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';

class FakeAudioplayersPlatform extends AudioplayersPlatformInterface {
  List<String> calls = <String>[];
  StreamController<PlayerEvent> eventStreamController =
      StreamController<PlayerEvent>.broadcast();

  @override
  Future<void> create(String playerId) async {
    calls.add('create');
  }

  @override
  Future<void> dispose(String playerId) async {
    calls.add('dispose');
    eventStreamController.close();
  }

  @override
  Future<void> emitError(String playerId, String code, String message) async {
    calls.add('emitError');
  }

  @override
  Future<void> emitLog(String playerId, String message) async {
    calls.add('emitLog');
  }

  @override
  Future<int?> getCurrentPosition(String playerId) async {
    calls.add('getCurrentPosition');
  }

  @override
  Future<int?> getDuration(String playerId) async {
    calls.add('getDuration');
  }

  @override
  Future<void> pause(String playerId) async {
    calls.add('pause');
  }

  @override
  Future<void> release(String playerId) async {
    calls.add('release');
  }

  @override
  Future<void> resume(String playerId) async {
    calls.add('resume');
  }

  @override
  Future<void> seek(String playerId, Duration position) async {
    calls.add('seek');
  }

  @override
  Future<void> setAudioContext(
      String playerId, AudioContext audioContext) async {
    calls.add('setAudioContext');
  }

  @override
  Future<void> setBalance(String playerId, double balance) async {
    calls.add('setBalance');
  }

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async {
    calls.add('setPlaybackRate');
  }

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) async {
    calls.add('setPlayerMode');
  }

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {
    calls.add('setReleaseMode');
  }

  @override
  Future<void> setSourceBytes(String playerId, Uint8List bytes) async {
    calls.add('setSourceBytes');
  }

  @override
  Future<void> setSourceUrl(String playerId, String url,
      {bool? isLocal}) async {
    calls.add('setSourceUrl');
  }

  @override
  Future<void> setVolume(String playerId, double volume) async {
    calls.add('setVolume');
  }

  @override
  Future<void> stop(String playerId) async {
    calls.add('stop');
  }

  @override
  Stream<PlayerEvent> getEventStream(String playerId) {
    calls.add('getEventStream');
    return eventStreamController.stream;
  }
}
