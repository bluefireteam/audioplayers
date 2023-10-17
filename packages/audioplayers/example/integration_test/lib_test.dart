import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'lib/lib_source_test_data.dart';
import 'lib/lib_test_utils.dart';
import 'platform_features.dart';
import 'test_utils.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final features = PlatformFeatures.instance();
  final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  final isMacOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  final audioTestDataList = await getAudioTestDataList();

  testWidgets('test asset source with special char',
      (WidgetTester tester) async {
    final player = AudioPlayer();

    await tester.pumpLinux();
    await player.play(specialCharAssetTestData.source);
    await tester.pumpAndSettle();
    // Sources take some time to get initialized
    await tester.pump(const Duration(seconds: 8));
    await player.stop();

    await tester.pumpLinux();
    await player.dispose();
  });

  testWidgets(
    'test device file source with special char',
    (WidgetTester tester) async {
      final player = AudioPlayer();

      await tester.pumpLinux();
      final path = await player.audioCache.loadPath(specialCharAsset);
      expect(path, isNot(contains('%'))); // Ensure path is not URL encoded
      await player.play(DeviceFileSource(path));
      await tester.pumpAndSettle();
      // Sources take some time to get initialized
      await tester.pump(const Duration(seconds: 8));
      await player.stop();

      await tester.pumpLinux();
      await player.dispose();
    },
    skip: kIsWeb,
  );

  testWidgets('test url source with special char', (WidgetTester tester) async {
    final player = AudioPlayer();

    await tester.pumpLinux();
    await player.play(specialCharUrlTestData.source);
    await tester.pumpAndSettle();
    // Sources take some time to get initialized
    await tester.pump(const Duration(seconds: 8));
    await player.stop();

    await tester.pumpLinux();
    await player.dispose();
  });

  testWidgets(
    'test url source with no extension',
    (WidgetTester tester) async {
      final player = AudioPlayer();

      await tester.pumpLinux();
      await player.play(noExtensionAssetTestData.source);
      await tester.pumpAndSettle();
      // Sources take some time to get initialized
      await tester.pump(const Duration(seconds: 8));
      await player.stop();

      await tester.pumpLinux();
      await player.dispose();
    },
    // Darwin does not support files without extension unless its specified
    // #803, https://stackoverflow.com/a/54087143/5164462
    skip: isIOS || isMacOS,
  );

  group('play multiple sources', () {
    testWidgets(
      'play multiple sources simultaneously',
      (WidgetTester tester) async {
        final players =
            List.generate(audioTestDataList.length, (_) => AudioPlayer());

        // Start all players simultaneously
        final iterator = List<int>.generate(audioTestDataList.length, (i) => i);
        await tester.pumpLinux();
        await Future.wait<void>(
          iterator.map((i) => players[i].play(audioTestDataList[i].source)),
        );
        await tester.pumpAndSettle();
        // Sources take some time to get initialized
        await tester.pump(const Duration(seconds: 8));
        for (var i = 0; i < audioTestDataList.length; i++) {
          final td = audioTestDataList[i];
          if (td.isLiveStream || td.duration! > const Duration(seconds: 10)) {
            await tester.pump();
            final position = await players[i].getCurrentPosition();
            printWithTimeOnFailure('Test position: $td');
            expect(position, greaterThan(Duration.zero));
          }
          await players[i].stop();
          await tester.pumpLinux();
        }
        await Future.wait(players.map((p) => p.dispose()));
      },
      // FIXME: Causes media error on Android (see #1333, #1353)
      // Unexpected platform error: MediaPlayer error with
      // what:MEDIA_ERROR_UNKNOWN {what:1} extra:MEDIA_ERROR_SYSTEM
      skip: isAndroid,
    );

    testWidgets('play multiple sources consecutively',
        (WidgetTester tester) async {
      final player = AudioPlayer();

      for (final td in audioTestDataList) {
        await tester.pumpLinux();
        await player.play(td.source);
        await tester.pumpAndSettle();
        // Sources take some time to get initialized
        await tester.pump(const Duration(seconds: 8));
        if (td.isLiveStream || td.duration! > const Duration(seconds: 10)) {
          await tester.pump();
          final position = await player.getCurrentPosition();
          printWithTimeOnFailure('Test position: $td');
          expect(position, greaterThan(Duration.zero));
        }
        await player.stop();
      }
      await tester.pumpLinux();
      await player.dispose();
    });
  });

  group('Audio Context', () {
    /// Android and iOS only: Play the same sound twice with a different audio
    /// context each. This test can be executed on a device, with either
    /// "Silent", "Vibrate" or "Ring" mode. In "Silent" or "Vibrate" mode
    /// the second sound should not be audible.
    testWidgets(
      'test changing AudioContextConfigs',
      (WidgetTester tester) async {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);

        final td = wavUrl1TestData;

        var audioContext = AudioContextConfig(
          //ignore: avoid_redundant_argument_values
          route: AudioContextConfigRoute.system,
          //ignore: avoid_redundant_argument_values
          respectSilence: false,
        ).build();
        await AudioPlayer.global.setAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await tester.pumpLinux();
        await player.play(td.source);
        await tester.pumpAndSettle();
        await tester
            .pump((td.duration ?? Duration.zero) + const Duration(seconds: 8));
        expect(player.state, PlayerState.completed);

        audioContext = AudioContextConfig(
          //ignore: avoid_redundant_argument_values
          route: AudioContextConfigRoute.system,
          respectSilence: true,
        ).build();
        await AudioPlayer.global.setAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await player.resume();
        await tester.pumpAndSettle();
        await tester
            .pump((td.duration ?? Duration.zero) + const Duration(seconds: 8));
        expect(player.state, PlayerState.completed);
        await tester.pumpLinux();
        await player.dispose();
      },
      skip: !features.hasRespectSilence,
    );

    /// Android and iOS only: Play the same sound twice with a different audio
    /// context each. This test can be executed on a device, with either
    /// "Silent", "Vibrate" or "Ring" mode. In "Silent" or "Vibrate" mode
    /// the second sound should not be audible.
    testWidgets(
      'test changing AudioContextConfigs in LOW_LATENCY mode',
      (WidgetTester tester) async {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        player.setPlayerMode(PlayerMode.lowLatency);

        final td = wavUrl1TestData;

        var audioContext = AudioContextConfig(
          //ignore: avoid_redundant_argument_values
          route: AudioContextConfigRoute.system,
          //ignore: avoid_redundant_argument_values
          respectSilence: false,
        ).build();
        await AudioPlayer.global.setAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await tester.pumpLinux();
        await player.setSource(td.source);
        await player.resume();
        await tester.pumpAndSettle();
        await tester
            .pump((td.duration ?? Duration.zero) + const Duration(seconds: 8));
        expect(player.state, PlayerState.playing);
        await player.stop();
        expect(player.state, PlayerState.stopped);

        audioContext = AudioContextConfig(
          //ignore: avoid_redundant_argument_values
          route: AudioContextConfigRoute.system,
          respectSilence: true,
        ).build();
        await AudioPlayer.global.setAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await player.resume();
        await tester.pumpAndSettle();
        await tester
            .pump((td.duration ?? Duration.zero) + const Duration(seconds: 8));
        expect(player.state, PlayerState.playing);
        await player.stop();
        expect(player.state, PlayerState.stopped);
        await tester.pumpLinux();
        await player.dispose();
      },
      skip: !features.hasRespectSilence || !features.hasLowLatency,
    );
  });

  group(
    'Android only:',
    () {
      /// The test is auditory only!
      /// It will succeed even if the wrong source is played.
      testWidgets('Released wrong source on LOW_LATENCY (#1672)',
          (WidgetTester tester) async {
        var player = AudioPlayer()
          ..setPlayerMode(PlayerMode.lowLatency)
          ..setReleaseMode(ReleaseMode.stop);

        await player.play(wavAsset1TestData.source);
        await tester.pump(const Duration(seconds: 1));
        await player.stop();

        await player.play(wavAsset2TestData.source);
        await tester.pump(const Duration(seconds: 1));
        await player.stop();

        player = AudioPlayer()
          ..setPlayerMode(PlayerMode.lowLatency)
          ..setReleaseMode(ReleaseMode.stop);

        // This should play the new source, not the old one:
        await player.play(wavAsset1TestData.source);
        await tester.pump(const Duration(seconds: 1));
        await player.stop();

        await player.play(wavAsset2TestData.source);
        await tester.pump(const Duration(seconds: 1));
        await player.stop();
      });
    },
    skip: !isAndroid,
  );
}
