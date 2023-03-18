import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';

class WebGlobalAudioplayersPlatform
    extends GlobalAudioplayersPlatformInterface {
  // Web implementation currently does not log anything
  LogLevel _level = LogLevel.error;

  @override
  Future<void> changeLogLevel(LogLevel value) async {
    _level = value;
  }

  @override
  LogLevel get logLevel => _level;

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {
    // no-op: web does not support changing audio context
  }
}
