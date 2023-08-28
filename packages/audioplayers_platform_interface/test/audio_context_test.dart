//ignore_for_file: avoid_redundant_argument_values

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:audioplayers_platform_interface/src/api/audio_context_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Create default AudioContext', () async {
    final context = AudioContext();
    expect(
      context,
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

  test('Compare AudioContextConfig with AudioContext', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    const boolValues = {true, false};
    const routeValues = AudioContextConfigRoute.values;

    final throwsAssertion = [];
    for (final isDuckAudio in boolValues) {
      for (final isRespectSilence in boolValues) {
        for (final isStayAwake in boolValues) {
          for (final route in routeValues) {
            final config = AudioContextConfig(
              duckAudio: isDuckAudio,
              respectSilence: isRespectSilence,
              stayAwake: isStayAwake,
              route: route,
            );
            try {
              config.build();
              throwsAssertion.add(false);
            } on AssertionError catch (e) {
              // if(e.startsWith('...')) {}
              throwsAssertion.add(true);
              print('#########');
              print(e);
            }
          }
        }
      }
    }

    // Ensure assertions keep thrown on the correct cases.
    expect(
      throwsAssertion,
      const [
        true,
        true,
        true,
        true,
        true,
        true,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        true,
        false,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
        false
      ],
    );
  });

  test('Create invalid AudioContextIOS', () async {
    try {
      // Throws AssertionError:
      AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: const {AVAudioSessionOptions.mixWithOthers},
      );
      fail('AssertionError not thrown');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      expect(e, isInstanceOf<AssertionError>());
      expect(
          (e as AssertionError).message,
          'You can set the option `mixWithOthers` explicitly only if the audio '
          'session category is `playAndRecord`, `playback`, or `multiRoute`.');
    }
  });

  test('Equality of AudioContextIOS', () async {
    final context1 = AudioContextIOS(
      category: AVAudioSessionCategory.playAndRecord,
      options: const {
        AVAudioSessionOptions.mixWithOthers,
        AVAudioSessionOptions.defaultToSpeaker,
      },
    );
    final context2 = AudioContextIOS(
      category: AVAudioSessionCategory.playAndRecord,
      options: const {
        AVAudioSessionOptions.defaultToSpeaker,
        AVAudioSessionOptions.mixWithOthers,
      },
    );
    expect(context1, context2);
  });
}
