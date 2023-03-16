import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Handle Global calls and events concerning all [AudioPlayer]s.
class GlobalAudioPlayer {
  static final _platform = GlobalPlatformInterface.instance;

  @Deprecated('Use `Logger.logLevel` instead.')
  Future<void> changeLogLevel(LogLevel level) async {
    Logger.logLevel = level;
  }
  
  Future<void> setAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);
  
  @Deprecated('Use `setAudioContext()` instead.')
  Future<void> setGlobalAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  /// Stream of global events.
  final Stream<GlobalEvent> eventStream = _platform.getGlobalEventStream();

  /// Stream of global log events.
  Stream<String> get onLog => eventStream
      .where((event) => event.eventType == GlobalEventType.log)
      .map((event) => event.logMessage!);

  GlobalAudioPlayer() {
    onLog.listen(
      Logger.log,
      onError: Logger.error,
    );
  }
}
