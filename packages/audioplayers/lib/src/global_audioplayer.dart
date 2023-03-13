import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/api/global_event.dart';
import 'package:meta/meta.dart';

/// Handle Global calls and events concerning all [AudioPlayer]s.
class GlobalAudioPlayer {
  static final _platform = GlobalPlatformInterface.instance;
  static final logger = Logger.instance;

  @Deprecated('Use `setAudioContext()` instead.')
  Future<void> setGlobalAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  Future<void> setAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  @visibleForTesting
  Future<void> emitLog(String message) => _platform.emitGlobalLog(message);

  @visibleForTesting
  Future<void> emitError(String code, String message) =>
      _platform.emitGlobalError(code, message);

  /// Stream of global events.
  final Stream<GlobalEvent> eventStream = _platform.getGlobalEventStream();

  /// Stream of global log events.
  Stream<String> get _onLog => eventStream
      .where((event) => event.eventType == GlobalEventType.log)
      .map((event) => event.logMessage!);

  late StreamSubscription _onLogStreamSubscription;

  void setLogHandler(
    void Function(String log)? onLog, {
    void Function(Object o, [StackTrace? stackTrace])? onError,
  }) {
    _onLogStreamSubscription.cancel();
    _onLogStreamSubscription =
        _onLog.listen(onLog, onError: onError ?? logger.error);
  }

  GlobalAudioPlayer() {
    _onLogStreamSubscription = _onLog.listen(logger.log, onError: logger.error);
  }
}
