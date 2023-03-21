import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:audioplayers_platform_interface/src/global_audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final methodCalls = <MethodCall>[];

  void clear() {
    methodCalls.clear();
  }

  MethodCall popCall() {
    return methodCalls.removeAt(0);
  }

  MethodCall popLastCall() {
    expect(methodCalls, hasLength(1));
    return popCall();
  }

  group('Global Method Channel', () {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async {
        methodCalls.add(methodCall);
        return 1;
      },
    );

    setUp(clear);

    final platform = GlobalAudioplayersPlatformInterface.instance;

    test('set AudioContext for Windows', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await platform.setGlobalAudioContext(const AudioContext());
      final call = popLastCall();
      expect(call.method, 'setGlobalAudioContext');
      expect(call.args, <String, dynamic>{});
    });

    test('set AudioContext for macOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await platform.setGlobalAudioContext(const AudioContext());
      final call = popLastCall();
      expect(call.method, 'setGlobalAudioContext');
      expect(call.args, <String, dynamic>{});
    });

    test('set AudioContext for Linux', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await platform.setGlobalAudioContext(const AudioContext());
      final call = popLastCall();
      expect(call.method, 'setGlobalAudioContext');
      expect(call.args, <String, dynamic>{});
    });

    test('set AudioContext for Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await platform.setGlobalAudioContext(const AudioContext());
      final call = popLastCall();
      expect(call.method, 'setGlobalAudioContext');
      expect(call.args, {
        'isSpeakerphoneOn': true,
        'audioMode': 0,
        'stayAwake': true,
        'contentType': 2,
        'usageType': 1,
        'audioFocus': 1,
      });
    });

    test('set AudioContext for iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await platform.setGlobalAudioContext(const AudioContext());
      final call = popLastCall();
      expect(call.method, 'setGlobalAudioContext');
      expect(call.args, {
        'category': 'playback',
        'options': [
          'mixWithOthers',
          'defaultToSpeaker',
        ]
      });
    });
  });
}
