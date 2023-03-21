// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'package:audioplayers_platform_interface/src/api/audio_context.dart';
import 'package:audioplayers_platform_interface/src/global_audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final _channelLogs = <String>[];

  group('Global Method Channel', () {
    TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async {
        _channelLogs.add('${methodCall.method} ${methodCall.arguments}');
        return 1;
      },
    );

    setUp(_channelLogs.clear);

    final platform = GlobalAudioplayersPlatformInterface.instance;

    test('set AudioContext for Windows', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await platform.setGlobalAudioContext(const AudioContext());
      expect(_channelLogs, ['setGlobalAudioContext {}']);
    });

    test('set AudioContext for macOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await platform.setGlobalAudioContext(const AudioContext());
      expect(_channelLogs, ['setGlobalAudioContext {}']);
    });

    test('set AudioContext for Linux', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await platform.setGlobalAudioContext(const AudioContext());
      expect(_channelLogs, ['setGlobalAudioContext {}']);
    });

    test('set AudioContext for Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await platform.setGlobalAudioContext(const AudioContext());
      const audioContextJson = 'setGlobalAudioContext {'
          'isSpeakerphoneOn: true, '
          'audioMode: 0, '
          'stayAwake: true, '
          'contentType: 2, '
          'usageType: 1, '
          'audioFocus: 1'
          '}';
      expect(_channelLogs, [audioContextJson]);
    });

    test('set AudioContext for iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await platform.setGlobalAudioContext(const AudioContext());
      const audioContextJson = 'setGlobalAudioContext {'
          'category: playback, '
          'options: ['
          'mixWithOthers, '
          'defaultToSpeaker'
          ']}';
      expect(_channelLogs, [audioContextJson]);
    });
  });
}
