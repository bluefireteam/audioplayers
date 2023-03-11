import 'package:audioplayers_platform_interface/api/audio_context_config.dart';
import 'package:audioplayers_platform_interface/method_channel_interface.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

abstract class GlobalPlatformInterface {
  static GlobalPlatformInterface instance = MethodChannelGlobalPlatform();

  Future<void> setGlobalAudioContext(AudioContext ctx);

  Future<void> globalLog(String message);

  @visibleForTesting
  Future<void> debugGlobalError(String code, String message);
}

class MethodChannelGlobalPlatform extends GlobalPlatformInterface {
  static const MethodChannel _channel =
      MethodChannel('xyz.luan/audioplayers.global');

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) {
    return _channel.call(
      'setGlobalAudioContext',
      ctx.toJson(),
    );
  }

  @override
  Future<void> globalLog(String message) {
    return _channel.call(
      'log',
      <String, dynamic>{
        'message': message,
      },
    );
  }

  @override
  Future<void> debugGlobalError(String code, String message) {
    return _channel.call(
      'debugError',
      <String, dynamic>{
        'code': code,
        'message': message,
      },
    );
  }
}
