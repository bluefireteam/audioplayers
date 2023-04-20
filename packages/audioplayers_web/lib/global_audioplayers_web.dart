import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';

class WebGlobalAudioplayersPlatform
    extends GlobalAudioplayersPlatformInterface {
  final _eventStreamController = StreamController<GlobalAudioEvent>.broadcast();

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {
    _eventStreamController.add(
      const GlobalAudioEvent(
        eventType: GlobalAudioEventType.log,
        logMessage: 'Setting global AudioContext is not supported on Web',
      ),
    );
  }

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() {
    return _eventStreamController.stream;
  }

  @override
  Future<void> emitGlobalLog(String message) async {
    _eventStreamController.add(
      GlobalAudioEvent(
        eventType: GlobalAudioEventType.log,
        logMessage: message,
      ),
    );
  }

  @override
  Future<void> emitGlobalError(String code, String message) async {
    _eventStreamController
        .addError(PlatformException(code: code, message: message));
  }
}
