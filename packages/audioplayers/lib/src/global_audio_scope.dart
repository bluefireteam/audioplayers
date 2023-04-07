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

  @Deprecated('Use `Logger.logLevel` instead. This will be removed in v5.0.0.')
  LogLevel get logLevel => Logger.logLevel;

  GlobalAudioScope() {
    eventStream = _platform.getGlobalEventStream();
    onLog.listen(
      Logger.log,
      onError: Logger.error,
    );
  }

  @Deprecated('Set `Logger.logLevel` instead. This will be removed in v5.0.0.')
  Future<void> changeLogLevel(LogLevel level) async {
    Logger.logLevel = level;
  }

  @Deprecated('Use `Logger.log()` or `Logger.error()` instead. '
      'This will be removed in v5.0.0.')
  void log(LogLevel level, String message) {
    if (level == LogLevel.info) {
      Logger.log(message);
    } else if (level == LogLevel.error) {
      Logger.error(message);
    }
  }

  @Deprecated('Use `Logger.log()` instead. This will be removed in v5.0.0.')
  void info(String message) => Logger.log(message);

  @Deprecated('Use `Logger.error()` instead. This will be removed in v5.0.0.')
  void error(String message) => Logger.error(message);

  Future<void> setAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  @Deprecated('Use `setAudioContext()` instead. '
      'This will be removed in v5.0.0.')
  Future<void> setGlobalAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);
}
