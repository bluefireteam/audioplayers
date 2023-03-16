import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Handle Global calls and events concerning all [AudioPlayer]s.
class GlobalAudioPlayer {
  static final _platform = GlobalPlatformInterface.instance;

  @Deprecated('Use `setAudioContext()` instead.')
  Future<void> setGlobalAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  Future<void> setAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);

  /// Stream of global events.
  final Stream<GlobalEvent> eventStream = _platform.getGlobalEventStream();

  /// Stream of global log events.
  Stream<String> get _onLog => eventStream
      .where((event) => event.eventType == GlobalEventType.log)
      .map((event) => event.logMessage!);

  late StreamSubscription _onLogStreamSubscription;

  /// Handle globally emitted logs, which concern all players.
  /// Replaces the default of using [Logger].
  void setLogHandler(
    void Function(String log) onLog, {
    void Function(Object o, [StackTrace? stackTrace]) onError = Logger.error,
  }) {
    _onLogStreamSubscription.cancel();
    _onLogStreamSubscription = _onLog.listen(onLog, onError: onError);
  }

  GlobalAudioPlayer() {
    _onLogStreamSubscription = _onLog.listen(
      Logger.log,
      onError: Logger.error,
    );
  }
}
