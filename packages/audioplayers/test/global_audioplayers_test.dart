//ignore_for_file: avoid_redundant_argument_values
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_global_audioplayers_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final globalPlatform = FakeGlobalAudioplayersPlatform();
  GlobalAudioplayersPlatformInterface.instance = globalPlatform;

  late GlobalAudioScope globalScope;

  test('test getGlobalEventStream', () async {
    // Global scope can only be initialized once statically, as changing it
    // while connected to native platform can lead to inconsistencies.
    globalScope = AudioPlayer.global;
    expect(globalPlatform.popLastCall().method, 'getGlobalEventStream');
  });

  group('Global Methods', () {
    setUp(() {
      // Ensure that globalScope was initialized and calls are reset.
      globalScope = AudioPlayer.global;
      globalPlatform.clear();
    });

    test('set AudioContext', () async {
      await globalScope.setAudioContext(const AudioContext());
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

  group('Global Events', () {
    test('global event stream', () async {
      final globalEvents = <GlobalAudioEvent>[
        const GlobalAudioEvent(
          eventType: GlobalAudioEventType.log,
          logMessage: 'someLogMessage',
        ),
      ];

      expect(
        globalScope.eventStream,
        emitsInOrder(globalEvents),
      );

      globalEvents.forEach(globalPlatform.eventStreamController.add);
      await globalPlatform.eventStreamController.close();
    });
  });
}
