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

    /// Note that the [AudioContextIOS.category] has to be
    /// [AVAudioSessionCategory.playback] to default the audio to the receiver
    /// (e.g. built-in speakers or BT-device, if connected).
    /// If using [AVAudioSessionCategory.playAndRecord] the audio will come from
    /// the earpiece unless [AVAudioSessionOptions.defaultToSpeaker] is used.
    test('set AudioContext', () async {
      await globalScope.setAudioContext(AudioContext());
      final call = globalPlatform.popLastCall();
      expect(call.method, 'setGlobalAudioContext');
      expect(
        call.value,
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            audioMode: AndroidAudioMode.normal,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {},
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
