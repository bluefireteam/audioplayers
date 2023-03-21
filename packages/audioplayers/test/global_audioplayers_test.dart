//ignore_for_file: avoid_redundant_argument_values
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
      expect(
        call.value,
        const AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            audioMode: AndroidAudioMode.normal,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: [
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.defaultToSpeaker
            ],
          ),
        ),
      );
    });
  });
}
