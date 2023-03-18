import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:audioplayers_platform_interface/src/api/log_level.dart';
import 'package:audioplayers_platform_interface/src/global_audioplayers_platform_interface.dart';
import 'package:audioplayers_platform_interface/src/method_channel_interface.dart';
import 'package:flutter/services.dart';

class GlobalAudioplayersPlatform extends GlobalAudioplayersPlatformInterface {
  static const MethodChannel _channel =
      MethodChannel('xyz.luan/audioplayers.global');

  static LogLevel _logLevel = LogLevel.error;

  @override
  Future<void> changeLogLevel(LogLevel value) {
    _logLevel = value;
    return _channel.call(
      'changeLogLevel',
      <String, dynamic>{'value': value.toString()},
    );
  }

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) {
    return _channel.call(
      'setGlobalAudioContext',
      ctx.toJson(),
    );
  }

  @override
  LogLevel get logLevel => _logLevel;
}
