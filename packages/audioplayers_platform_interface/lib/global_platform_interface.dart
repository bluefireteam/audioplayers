import 'package:audioplayers_platform_interface/api/audio_context_config.dart';
import 'package:audioplayers_platform_interface/method_channel_interface.dart';
import 'package:flutter/services.dart';

abstract class GlobalPlatformInterface {
  static GlobalPlatformInterface instance = MethodChannelGlobalPlatform();

  Future<void> setGlobalAudioContext(AudioContext ctx);
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
}
