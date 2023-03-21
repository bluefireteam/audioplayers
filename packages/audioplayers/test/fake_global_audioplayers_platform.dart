import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGlobalCall {
  final String method;
  final Object? value;

  FakeGlobalCall({required this.method, this.value});
}

class FakeGlobalAudioplayersPlatform
    extends GlobalAudioplayersPlatformInterface {
  List<FakeGlobalCall> calls = <FakeGlobalCall>[];
  LogLevel _level = LogLevel.error;

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

  Future<void> dispose() async {
    calls.add(FakeGlobalCall(method: 'globalDispose'));
  }

  @override
  Future<void> changeLogLevel(LogLevel level) async {
    calls.add(FakeGlobalCall(method: 'changeLogLevel', value: level));
    _level = level;
  }

  @override
  LogLevel get logLevel => _level;
}
