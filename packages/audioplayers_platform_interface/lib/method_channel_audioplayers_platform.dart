import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'api/audio_context_config.dart';
import 'api/for_player.dart';
import 'api/player_state.dart';
import 'api/release_mode.dart';
import 'audioplayers_platform_interface.dart';
import 'logger_platform_interface.dart';
import 'method_channel_interface.dart';

class MethodChannelAudioplayersPlatform extends AudioplayersPlatform {
  final MethodChannel _channel = const MethodChannel('xyz.luan/audioplayers');

  MethodChannelAudioplayersPlatform() {
    _channel.setMethodCallHandler(platformCallHandler);
  }

  static LoggerPlatformInterface get _logger =>
      LoggerPlatformInterface.instance;

  @override
  Future<int?> getCurrentPosition(String playerId) {
    return _compute('getCurrentPosition', playerId);
  }

  @override
  Future<int?> getDuration(String playerId) {
    return _compute('getDuration', playerId);
  }

  @override
  Future<void> pause(String playerId) {
    return _call('pause', playerId);
  }

  @override
  Future<void> release(String playerId) {
    return _call('release', playerId);
  }

  @override
  Future<void> resume(String playerId) {
    return _call('resume', playerId);
  }

  @override
  Future<void> seek(String playerId, Duration position) {
    return _call(
      'seek',
      playerId,
      <String, dynamic>{
        'position': position.inMilliseconds,
      },
    );
  }

  @override
  Future<void> setAudioContextConfig(
    String playerId,
    AudioContextConfig config,
  ) {
    return _call(
      'setAudioContextConfig',
      playerId,
      <String, dynamic>{
        'respectSilence': config.respectSilence,
        'duckAudio': config.duckAudio,
        'recordingActive': config.recordingActive,
        'playingRoute': config.playingRoute.toString(),
      },
    );
  }

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) {
    return _call(
      'setPlaybackRate',
      playerId,
      <String, dynamic>{'playbackRate': playbackRate},
    );
  }

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) {
    return _call(
      'setReleaseMode',
      playerId,
      <String, dynamic>{
        'releaseMode': releaseMode.toString(),
      },
    );
  }

  @override
  Future<void> setSourceBytes(String playerId, Uint8List bytes) {
    return _call(
      'setSourceBytes',
      playerId,
      <String, dynamic>{
        'bytes': bytes,
      },
    );
  }

  @override
  Future<void> setSourceUrl(String playerId, String url, {bool? isLocal}) {
    return _call(
      'setSourceUrl',
      playerId,
      <String, dynamic>{
        'url': url,
        'isLocal': isLocal,
      },
    );
  }

  @override
  Future<void> setVolume(String playerId, double volume) {
    return _call(
      'setVolume',
      playerId,
      <String, dynamic>{
        'volume': volume,
      },
    );
  }

  @override
  Future<void> stop(String playerId) {
    return _call('stop', playerId);
  }

  Future<void> platformCallHandler(MethodCall call) async {
    try {
      _doHandlePlatformCall(call);
    } catch (ex) {
      _logger.error('Unexpected error: $ex');
    }
  }

  Future<void> _doHandlePlatformCall(MethodCall call) async {
    _logger.info('_platformCallHandler call ${call.method} ${call.args}');
    final playerId = call.getString('playerId');

    ForPlayer<T> wrap<T>(T t) => ForPlayer<T>(playerId, t);

    switch (call.method) {
      case 'audio.onDuration':
        final millis = call.getInt('value');
        final duration = Duration(milliseconds: millis);
        durationStreamController.add(wrap(duration));
        break;
      case 'audio.onCurrentPosition':
        final millis = call.getInt('value');
        final position = Duration(milliseconds: millis);
        positionStreamController.add(wrap(position));
        break;
      case 'audio.onComplete':
        completionStreamController.add(wrap(null));
        break;
      case 'audio.onSeekComplete':
        final complete = call.getBool('value');
        seekCompleteStreamController.add(wrap(complete));
        break;
      default:
        _logger.error('Unknown method ${call.method} ');
    }
  }

  Future<void> _call(
    String method,
    String playerId, [
    Map<String, dynamic> arguments = const <String, dynamic>{},
  ]) async {
    final enhancedArgs = <String, dynamic>{
      'playerId': playerId,
      ...arguments,
    };
    return _channel.call(method, enhancedArgs);
  }

  Future<T?> _compute<T>(
    String method,
    String playerId, [
    Map<String, dynamic> arguments = const <String, dynamic>{},
  ]) async {
    final enhancedArgs = <String, dynamic>{
      'playerId': playerId,
      ...arguments,
    };
    return _channel.compute<T>(method, enhancedArgs);
  }

  @override
  Stream<ForPlayer<bool>> get seekCompleteStream =>
      seekCompleteStreamController.stream;

  @override
  Stream<ForPlayer<void>> get completionStream =>
      completionStreamController.stream;

  @override
  Stream<ForPlayer<Duration>> get durationStream =>
      durationStreamController.stream;

  @override
  Stream<ForPlayer<PlayerState>> get playerStateStream =>
      playerStateStreamController.stream;

  @override
  Stream<ForPlayer<Duration>> get positionStream =>
      positionStreamController.stream;

  StreamController<ForPlayer<bool>> seekCompleteStreamController =
      StreamController<ForPlayer<bool>>.broadcast();

  StreamController<ForPlayer<void>> completionStreamController =
      StreamController<ForPlayer<void>>.broadcast();

  StreamController<ForPlayer<Duration>> durationStreamController =
      StreamController<ForPlayer<Duration>>.broadcast();

  StreamController<ForPlayer<PlayerState>> playerStateStreamController =
      StreamController<ForPlayer<PlayerState>>.broadcast();

  StreamController<ForPlayer<Duration>> positionStreamController =
      StreamController<ForPlayer<Duration>>.broadcast();

  @mustCallSuper
  Future<void> dispose() async {
    seekCompleteStreamController.close();
    completionStreamController.close();
    durationStreamController.close();
    playerStateStreamController.close();
    positionStreamController.close();
  }
}
