import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/api/global_event.dart';

/// Handle Global calls and events concerning all [AudioPlayer]s.
class GlobalAudioPlayer {
  static final _platform = GlobalPlatformInterface.instance;
  static final logger = Logger.instance;

  @Deprecated("Use `setAudioContext()` instead.")
  Future<void> setGlobalAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  Future<void> setAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  Future<void> log(String message) => _platform.globalLog(message);

  @visibleForTesting
  Future<void> debugError(String code, String message) =>
      _platform.debugGlobalError(code, message);

  /// Stream of global events.
  final Stream<GlobalEvent> eventStream =
  _platform.getGlobalEventStream();

  StreamSubscription _onLogStreamSubscription =
  _onLog.listen(logger.log, onError: logger.error);

  /// Stream of global log events.
  Stream<String> get _onLog =>
      eventStream
          .where((event) => event.eventType == GlobalEventType.log)
          .map((event) => event.logMessage!);

  void setLogHandler(void Function(String log)? onLog, {
    void Function(Object o, [StackTrace? stackTrace])? onError,
  }) {
    _onLogStreamSubscription.cancel();
    _onLogStreamSubscription =
        _onLog.listen(onLog, onError: onError ?? logger.error);
  }
}
