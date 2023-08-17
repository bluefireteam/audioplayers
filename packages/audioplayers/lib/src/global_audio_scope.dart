import 'dart:async';

import 'package:audioplayers/src/audio_logger.dart';
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

  GlobalAudioScope() {
    eventStream = _platform.getGlobalEventStream();
    onLog.listen(
      AudioLogger.log,
      onError: AudioLogger.error,
    );
  }

  Future<void> setAudioContext(AudioContext ctx) =>
      _platform.setGlobalAudioContext(ctx);
}
