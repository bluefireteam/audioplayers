import 'dart:async';

import 'package:audioplayers_platform_interface/api/audio_context_config.dart';
import 'package:audioplayers_platform_interface/api/global_event.dart';
import 'package:audioplayers_platform_interface/global_platform_interface.dart';
import 'package:flutter/services.dart';

class GlobalWebAudioplayersPlatform extends GlobalPlatformInterface {
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
