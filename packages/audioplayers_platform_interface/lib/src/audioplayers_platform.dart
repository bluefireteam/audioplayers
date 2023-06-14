import 'dart:async';

import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:audioplayers_platform_interface/src/api/audio_event.dart';
import 'package:audioplayers_platform_interface/src/api/player_mode.dart';
import 'package:audioplayers_platform_interface/src/api/release_mode.dart';
import 'package:audioplayers_platform_interface/src/audioplayers_platform_interface.dart';
import 'package:audioplayers_platform_interface/src/map_extension.dart';
import 'package:audioplayers_platform_interface/src/method_channel_extension.dart';
import 'package:flutter/services.dart';

class AudioplayersPlatform extends AudioplayersPlatformInterface
    with MethodChannelAudioplayersPlatform, EventChannelAudioplayersPlatform {
  AudioplayersPlatform();
}

mixin MethodChannelAudioplayersPlatform
    implements MethodChannelAudioplayersPlatformInterface {
  static const MethodChannel _methodChannel =
      MethodChannel('xyz.luan/audioplayers');

  @override
  Future<void> create(String playerId) {
    return _call('create', playerId);
  }

  @override
  Future<void> dispose(String playerId) {
    return _call('dispose', playerId);
  }

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
  Future<void> setBalance(
    String playerId,
    double balance,
  ) {
    return _call(
      'setBalance',
      playerId,
      <String, dynamic>{'balance': balance},
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

  @override
  Future<void> emitLog(String playerId, String message) {
    return _call(
      'emitLog',
      playerId,
      <String, dynamic>{
        'message': message,
      },
    );
  }

  @override
  Future<void> emitError(String playerId, String code, String message) {
    return _call(
      'emitError',
      playerId,
      <String, dynamic>{
        'code': code,
        'message': message,
      },
    );
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
    return _methodChannel.call(method, enhancedArgs);
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
    return _methodChannel.compute<T>(method, enhancedArgs);
  }
}

mixin EventChannelAudioplayersPlatform
    implements EventChannelAudioplayersPlatformInterface {
  @override
  Stream<AudioEvent> getEventStream(String playerId) {
    // Only can be used after have created the event channel on the native side.
    final eventChannel = EventChannel('xyz.luan/audioplayers/events/$playerId');

    return eventChannel.receiveBroadcastStream().map(
      (dynamic event) {
        final map = event as Map<dynamic, dynamic>;
        final eventType = map.getString('event');
        switch (eventType) {
          case 'audio.onDuration':
            final millis = map.getInt('value');
            final duration = Duration(milliseconds: millis);
            return AudioEvent(
              eventType: AudioEventType.duration,
              duration: duration,
            );
          case 'audio.onCurrentPosition':
            final millis = map.getInt('value');
            final position = Duration(milliseconds: millis);
            return AudioEvent(
              eventType: AudioEventType.position,
              position: position,
            );
          case 'audio.onComplete':
            return const AudioEvent(eventType: AudioEventType.complete);
          case 'audio.onSeekComplete':
            return const AudioEvent(eventType: AudioEventType.seekComplete);
          case 'audio.onPrepared':
            final isPrepared = map.getBool('value');
            return AudioEvent(
              eventType: AudioEventType.prepared,
              isPrepared: isPrepared,
            );
          case 'audio.onLog':
            final value = map.getString('value');
            return AudioEvent(
              eventType: AudioEventType.log,
              logMessage: value,
            );
          default:
            throw UnimplementedError('Event Method does not exist $eventType');
        }
      },
    );
  }
}
