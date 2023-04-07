import 'dart:async';

import 'package:audioplayers/src/log_level.dart';
import 'package:audioplayers/src/logger.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';

/// Handle global audio scope like calls and events concerning all AudioPlayers.
class GlobalAudioScope {
  final _platform = GlobalAudioplayersPlatformInterface.instance;

  /// Stream of global events.
  late final Stream<GlobalAudioEvent> eventStream;

  /// Stream of global log events.
  Stream<String> get onLog => eventStream
      .where((event) => event.eventType == GlobalAudioEventType.log)
      .map((event) => event.logMessage!);

  @Deprecated('Use `AudioLogger.logLevel` instead. '
      'This will be removed in v5.0.0.')
  AudioLogLevel get logLevel => AudioLogger.logLevel;

  GlobalAudioScope() {
    eventStream = _platform.getGlobalEventStream();
    onLog.listen(
      AudioLogger.log,
      onError: AudioLogger.error,
    );
  }

  @Deprecated('Set `AudioLogger.logLevel` instead. '
      'This will be removed in v5.0.0.')
  Future<void> changeLogLevel(AudioLogLevel level) async {
    AudioLogger.logLevel = level;
  }

  @Deprecated('Use `AudioLogger.log()` or `AudioLogger.error()` instead. '
      'This will be removed in v5.0.0.')
  void log(AudioLogLevel level, String message) {
    if (level == AudioLogLevel.info) {
      AudioLogger.log(message);
    } else if (level == AudioLogLevel.error) {
      AudioLogger.error(message);
    }
  }

  @Deprecated('Use `AudioLogger.log()` instead. '
      'This will be removed in v5.0.0.')
  void info(String message) => AudioLogger.log(message);

  @Deprecated('Use `AudioLogger.error()` instead. '
      'This will be removed in v5.0.0.')
  void error(String message) => AudioLogger.error(message);

  Future<void> setAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  @Deprecated('Use `setAudioContext()` instead. '
      'This will be removed in v5.0.0.')
  Future<void> setGlobalAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);
}
