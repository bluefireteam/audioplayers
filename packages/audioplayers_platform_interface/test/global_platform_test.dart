import 'dart:async';

import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:audioplayers_platform_interface/src/api/global_audio_event.dart';
import 'package:audioplayers_platform_interface/src/global_audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = GlobalAudioplayersPlatformInterface.instance;

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
    setUp(() {
      clear();
      createNativeMethodHandler(
        channel: 'xyz.luan/audioplayers.global',
        handler: (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          return null;
        },
      );
    });

    test('set AudioContext for Windows', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await platform.setGlobalAudioContext(AudioContext());
      final call = popLastCall();
      expect(call.method, 'setAudioContext');
      expect(call.args, <String, dynamic>{});
    });

    test('set AudioContext for macOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await platform.setGlobalAudioContext(AudioContext());
      final call = popLastCall();
      expect(call.method, 'setAudioContext');
      expect(call.args, <String, dynamic>{});
    });

    test('set AudioContext for Linux', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await platform.setGlobalAudioContext(AudioContext());
      final call = popLastCall();
      expect(call.method, 'setAudioContext');
      expect(call.args, <String, dynamic>{});
    });

    test('set AudioContext for Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await platform.setGlobalAudioContext(AudioContext());
      final call = popLastCall();
      expect(call.method, 'setAudioContext');
      expect(call.args, {
        'isSpeakerphoneOn': false,
        'audioMode': 0,
        'stayAwake': false,
        'contentType': 2,
        'usageType': 1,
        'audioFocus': 1,
      });
    });

    test('set AudioContext for iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await platform.setGlobalAudioContext(AudioContext());
      final call = popLastCall();
      expect(call.method, 'setAudioContext');
      expect(call.args, {'category': 'playback', 'options': []});
    });
  });

  group('Global Event Channel', () {
    test('emit global events', () async {
      final eventController = StreamController<ByteData>.broadcast();

      createNativeEventStream(
        channel: 'xyz.luan/audioplayers.global/events',
        byteDataStream: eventController.stream,
      );

      expect(
        platform.getGlobalEventStream(),
        emitsInOrder(<GlobalAudioEvent>[
          const GlobalAudioEvent(
            eventType: GlobalAudioEventType.log,
            logMessage: 'someLogMessage',
          ),
        ]),
      );

      final byteDataList = <Map<String, dynamic>>[
        <String, dynamic>{
          'event': 'audio.onLog',
          'value': 'someLogMessage',
        },
      ];
      for (final byteData in byteDataList) {
        eventController.add(
          const StandardMethodCodec().encodeSuccessEnvelope(byteData),
        );
      }

      await eventController.close();
    });
  });
}
