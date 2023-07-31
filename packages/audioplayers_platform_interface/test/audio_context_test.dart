//ignore_for_file: avoid_redundant_argument_values

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('create default AudioContext', () async {
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
          options: const [],
        ),
      ),
    );
  });

  test('create invalid AudioContextIOS', () async {
    try {
      // Throws AssertionError:
      AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const [AVAudioSessionOptions.mixWithOthers],
      );
      fail('AssertionError not thrown');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      expect(e, isInstanceOf<AssertionError>());
      expect((e as AssertionError).message,
          'You can set the option `mixWithOthers` explicitly only if the audio session category is `playAndRecord`, `playback`, or `multiRoute`.')
    }
  });
}
