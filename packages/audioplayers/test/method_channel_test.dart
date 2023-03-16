// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final _channelLogs = <String>[];

  group('Global Method Channel', () {
    const MethodChannel('xyz.luan/audioplayers.global')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      _channelLogs.add('${methodCall.method} ${methodCall.arguments}');
      return 1;
    });

    setUp(_channelLogs.clear);

    test('set AudioContext for Windows', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await AudioPlayer.global.setAudioContext(const AudioContext());
      expect(_channelLogs, ['setAudioContext {}']);
    });

    test('set AudioContext for macOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await AudioPlayer.global.setAudioContext(const AudioContext());
      expect(_channelLogs, ['setAudioContext {}']);
    });

    test('set AudioContext for Linux', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await AudioPlayer.global.setAudioContext(const AudioContext());
      expect(_channelLogs, ['setAudioContext {}']);
    });

    test('set AudioContext for Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await AudioPlayer.global.setAudioContext(const AudioContext());
      const audioContextJson = 'setAudioContext {'
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
      await AudioPlayer.global.setAudioContext(const AudioContext());
      const audioContextJson = 'setAudioContext {'
          'category: playback, '
          'options: ['
          'mixWithOthers, '
          'defaultToSpeaker'
          ']}';
      expect(_channelLogs, [audioContextJson]);
    });
  });
}
