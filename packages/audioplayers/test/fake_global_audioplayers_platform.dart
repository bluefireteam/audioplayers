import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGlobalCall {
  final String method;
  final Object? value;

  FakeGlobalCall({required this.method, this.value});
}

class FakeGlobalAudioplayersPlatform
    extends GlobalAudioplayersPlatformInterface {
  List<FakeGlobalCall> calls = <FakeGlobalCall>[];
  StreamController<GlobalAudioEvent> eventStreamController =
      StreamController<GlobalAudioEvent>.broadcast();

  void clear() {
    calls.clear();
  }

  FakeGlobalCall popCall() {
    return calls.removeAt(0);
  }

  FakeGlobalCall popLastCall() {
    expect(calls, hasLength(1));
    return popCall();
  }

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {
    calls.add(FakeGlobalCall(method: 'setGlobalAudioContext', value: ctx));
  }

  @override
  Future<void> emitGlobalLog(String message) async {
    calls.add(FakeGlobalCall(method: 'emitGlobalLog'));
    eventStreamController.add(
      GlobalAudioEvent(
        eventType: GlobalAudioEventType.log,
        logMessage: message,
      ),
    );
  }

  @override
  Future<void> emitGlobalError(String code, String message) async {
    calls.add(FakeGlobalCall(method: 'emitGlobalError'));
    eventStreamController
        .addError(PlatformException(code: code, message: message));
  }

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() {
    calls.add(FakeGlobalCall(method: 'getGlobalEventStream'));
    return eventStreamController.stream;
  }

  Future<void> dispose() async {
    calls.add(FakeGlobalCall(method: 'globalDispose'));
    eventStreamController.close();
  }
}
