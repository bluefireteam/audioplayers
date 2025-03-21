import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:openhiit_audioplayers/src/audio_logger.dart';

GlobalAudioplayersPlatformInterface? _lastGlobalAudioplayersPlatform;

/// Handle global audio scope like calls and events concerning all AudioPlayers.
class GlobalAudioScope {
  Completer<void>? _initCompleter;

  GlobalAudioplayersPlatformInterface get _platform =>
      GlobalAudioplayersPlatformInterface.instance;

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

  /// Ensure the global platform is initialized.
  Future<void> ensureInitialized() async {
    if (_lastGlobalAudioplayersPlatform != _platform) {
      // This will clear all open players on the platform when a full restart is
      // performed.
      _lastGlobalAudioplayersPlatform = _platform;
      _initCompleter = Completer<void>();
      try {
        await _platform.init();
        _initCompleter?.complete();
      } on Exception catch (e, stackTrace) {
        _initCompleter?.completeError(e, stackTrace);
      }
    }
    await _initCompleter?.future;
  }

  Future<void> setAudioContext(AudioContext ctx) async {
    await ensureInitialized();
    await _platform.setGlobalAudioContext(ctx);
  }
}
