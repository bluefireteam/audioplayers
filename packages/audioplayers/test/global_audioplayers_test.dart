import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_audioplayers_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeGlobalAudioplayersPlatform platform;
  setUp(() {
    platform = FakeGlobalAudioplayersPlatform();
    GlobalAudioplayersPlatformInterface.instance = platform;
  });

  group('Global Method Channel', () {
    test('set AudioContext', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await AudioPlayer.global.setAudioContext(const AudioContext());
      expect(platform.calls, ['setGlobalAudioContext']);
    });
  });
}
