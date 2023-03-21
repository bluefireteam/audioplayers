import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_global_audioplayers_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeGlobalAudioplayersPlatform globalPlatform;
  setUp(() {
    globalPlatform = FakeGlobalAudioplayersPlatform();
    GlobalAudioplayersPlatformInterface.instance = globalPlatform;
  });

  group('Global Method Channel', () {
    test('set AudioContext', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await AudioPlayer.global.setAudioContext(const AudioContext());
      final call = globalPlatform.popLastCall();
      expect(call.method, 'setGlobalAudioContext');
      expect(call.value, const AudioContext());
    });
  });
}
