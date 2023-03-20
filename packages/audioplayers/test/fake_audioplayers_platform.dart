import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';

class FakeGlobalAudioplayersPlatform
    extends GlobalAudioplayersPlatformInterface {
  List<String> calls = <String>[];
  LogLevel _level = LogLevel.error;

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {
    calls.add('setGlobalAudioContext');
  }

  Future<void> dispose() async {
    calls.add('globalDispose');
  }

  @override
  Future<void> changeLogLevel(LogLevel value) async {
    calls.add('changeLogLevel');
    _level = value;
  }

  @override
  LogLevel get logLevel => _level;
}

class FakeAudioplayersPlatform extends AudioplayersPlatformInterface {
  List<String> calls = <String>[];

  @override
  Future<int?> getCurrentPosition(String playerId) async {
    calls.add('getCurrentPosition');
    return 0;
  }

  @override
  Future<int?> getDuration(String playerId) async {
    calls.add('getDuration');
    return 0;
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
    String playerId,
    AudioContext audioContext,
  ) async {
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
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
  }) async {
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

  final durationController = StreamController<ForPlayer<Duration>>.broadcast();
  final positionController = StreamController<ForPlayer<Duration>>.broadcast();
  final completeController = StreamController<ForPlayer<void>>.broadcast();
  final seekCompleteController = StreamController<ForPlayer<void>>.broadcast();

  @override
  Stream<ForPlayer<void>> get completeStream => completeController.stream;

  @override
  Stream<ForPlayer<Duration>> get durationStream => durationController.stream;

  @override
  Stream<ForPlayer<Duration>> get positionStream => positionController.stream;

  @override
  Stream<ForPlayer<void>> get seekCompleteStream =>
      seekCompleteController.stream;

  Future<void> dispose() async {
    durationController.close();
    positionController.close();
    completeController.close();
    seekCompleteController.close();
  }
}
