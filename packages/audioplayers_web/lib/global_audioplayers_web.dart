import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';

class WebGlobalAudioplayersPlatform
    extends GlobalAudioplayersPlatformInterface {
  final _eventStreamController = StreamController<GlobalEvent>.broadcast();

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {
    _eventStreamController.add(
      const GlobalEvent(
        eventType: GlobalEventType.log,
        logMessage: 'Setting global AudioContext is not supported on Web',
      ),
    );
  }

  @override
  Stream<GlobalEvent> getGlobalEventStream() {
    return _eventStreamController.stream;
  }

  @override
  Future<void> emitGlobalLog(String message) async {
    _eventStreamController.add(
      GlobalEvent(eventType: GlobalEventType.log, logMessage: message),
    );
  }

  @override
  Future<void> emitGlobalError(String code, String message) async {
    _eventStreamController
        .addError(PlatformException(code: code, message: message));
  }
}
