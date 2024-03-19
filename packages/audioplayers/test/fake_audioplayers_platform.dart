import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCall {
  final String id;
  final String method;
  final Object? value;

  FakeCall({required this.id, required this.method, this.value});

  @override
  String toString() => 'FakeCall(id: $id, method: $method, value: $value)';
}

class FakeAudioplayersPlatform extends AudioplayersPlatformInterface {
  List<FakeCall> calls = [];

  Map<String, StreamController<AudioEvent>> eventStreamControllers = {};

  void clear() {
    calls.clear();
  }

  FakeCall popCall() {
    return calls.removeAt(0);
  }

  FakeCall popLastCall() {
    expect(calls, hasLength(1));
    return popCall();
  }

  @override
  Future<void> create(String playerId) async {
    calls.add(FakeCall(id: playerId, method: 'create'));
    eventStreamControllers[playerId] = StreamController<AudioEvent>.broadcast();
  }

  @override
  Future<void> dispose(String playerId) async {
    calls.add(FakeCall(id: playerId, method: 'dispose'));
    eventStreamControllers[playerId]?.close();
  }

  @override
  Future<void> emitError(String playerId, String code, String message) async {
    calls.add(FakeCall(id: playerId, method: 'emitError'));
  }

  @override
  Future<void> emitLog(String playerId, String message) async {
    calls.add(FakeCall(id: playerId, method: 'emitLog'));
  }

  @override
  Future<int?> getCurrentPosition(String playerId) async {
    calls.add(FakeCall(id: playerId, method: 'getCurrentPosition'));
    return 0;
  }

  @override
  Future<int?> getDuration(String playerId) async {
    calls.add(FakeCall(id: playerId, method: 'getDuration'));
    return 0;
  }

  @override
  Future<void> pause(String playerId) async {
    calls.add(FakeCall(id: playerId, method: 'pause'));
  }

  @override
  Future<void> release(String playerId) async {
    calls.add(FakeCall(id: playerId, method: 'release'));
  }

  @override
  Future<void> resume(String playerId) async {
    calls.add(FakeCall(id: playerId, method: 'resume'));
  }

  @override
  Future<void> seek(String playerId, Duration position) async {
    calls.add(FakeCall(id: playerId, method: 'seek', value: position));
  }

  @override
  Future<void> setAudioContext(
    String playerId,
    AudioContext audioContext,
  ) async {
    calls.add(
      FakeCall(id: playerId, method: 'setAudioContext', value: audioContext),
    );
  }

  @override
  Future<void> setBalance(String playerId, double balance) async {
    calls.add(FakeCall(id: playerId, method: 'setBalance', value: balance));
  }

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async {
    calls.add(
      FakeCall(id: playerId, method: 'setPlaybackRate', value: playbackRate),
    );
  }

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) async {
    calls.add(
      FakeCall(id: playerId, method: 'setPlayerMode', value: playerMode),
    );
  }

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {
    calls.add(
      FakeCall(id: playerId, method: 'setReleaseMode', value: releaseMode),
    );
  }

  @override
  Future<void> setSourceBytes(
    String playerId,
    Uint8List bytes, {
    String? mimeType,
  }) async {
    calls.add(FakeCall(id: playerId, method: 'setSourceBytes', value: bytes));
    eventStreamControllers[playerId]?.add(
      const AudioEvent(eventType: AudioEventType.prepared, isPrepared: true),
    );
  }

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
    String? mimeType,
  }) async {
    calls.add(FakeCall(id: playerId, method: 'setSourceUrl', value: url));
    eventStreamControllers[playerId]?.add(
      const AudioEvent(eventType: AudioEventType.prepared, isPrepared: true),
    );
  }

  @override
  Future<void> setVolume(String playerId, double volume) async {
    calls.add(FakeCall(id: playerId, method: 'setVolume', value: volume));
  }

  @override
  Future<void> stop(String playerId) async {
    calls.add(FakeCall(id: playerId, method: 'stop'));
  }

  @override
  Stream<AudioEvent> getEventStream(String playerId) {
    calls.add(FakeCall(id: playerId, method: 'getEventStream'));
    return eventStreamControllers[playerId]!.stream;
  }
}
