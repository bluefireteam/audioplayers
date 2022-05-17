import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'api/audio_context_config.dart';
import 'api/player_mode.dart';
import 'api/release_mode.dart';
import 'audioplayers_platform_interface.dart';
import 'logger_platform_interface.dart';
import 'method_channel_interface.dart';
import 'streams_interface.dart';

class MethodChannelAudioplayersPlatform extends AudioplayersPlatform
    with StreamsInterface {
  final MethodChannel _channel = const MethodChannel('xyz.luan/audioplayers');

  MethodChannelAudioplayersPlatform() {
    _channel.setMethodCallHandler(platformCallHandler);
  }

  static GlobalPlatformInterface get _logger =>
      GlobalPlatformInterface.instance;

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
  Future<void> setAudioContext(
    String playerId,
    AudioContext context,
  ) {
    return _call(
      'setAudioContext',
      playerId,
      context.toJson(),
    );
  }

  @override
  Future<void> setPlayerMode(
    String playerId,
    PlayerMode playerMode,
  ) {
    return _call(
      'setPlayerMode',
      playerId,
      <String, dynamic>{
        'playerMode': playerMode.toString(),
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
    final playerId = call.getString('playerId');

    switch (call.method) {
      case 'audio.onDuration':
        final millis = call.getInt('value');
        final duration = Duration(milliseconds: millis);
        emitDuration(playerId, duration);
        break;
      case 'audio.onCurrentPosition':
        final millis = call.getInt('value');
        final position = Duration(milliseconds: millis);
        emitPosition(playerId, position);
        break;
      case 'audio.onComplete':
        emitComplete(playerId);
        break;
      case 'audio.onSeekComplete':
        emitSeekComplete(playerId);
        break;
      case 'audio.onError':
        throw call.getString('value');
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
}
