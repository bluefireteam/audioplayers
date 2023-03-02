import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'platform_features.dart';
import 'source_test_data.dart';
import 'test_utils.dart';

void main() {
  final features = PlatformFeatures.instance();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final audioTestDataList = [
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(wavUrl1),
        duration: const Duration(milliseconds: 451),
      ),
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(wavUrl2),
        duration: const Duration(seconds: 1, milliseconds: 068),
      ),
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(mp3Url1),
        duration: const Duration(minutes: 3, seconds: 30, milliseconds: 77),
      ),
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(mp3Url2),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      ),
    if (features.hasUrlSource && features.hasPlaylistSourceType)
      LibSourceTestData(
        source: UrlSource(m3u8StreamUrl),
        duration: Duration.zero,
        isLiveStream: true,
      ),
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(mpgaStreamUrl),
        duration: Duration.zero,
        isLiveStream: true,
      ),
    if (features.hasAssetSource)
      LibSourceTestData(
        source: AssetSource(wavAsset),
        duration: const Duration(seconds: 1, milliseconds: 068),
      ),
    if (features.hasAssetSource)
      LibSourceTestData(
        source: AssetSource(mp3Asset),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      ),
  ];

  group('play multiple sources', () {
    testWidgets(
      'play multiple sources simultaneously',
      (WidgetTester tester) async {
        final players =
            List.generate(audioTestDataList.length, (_) => AudioPlayer());

        // Start all players simultaneously
        final iterator = List<int>.generate(audioTestDataList.length, (i) => i);
        await Future.wait<void>(
          iterator.map((i) => players[i].play(audioTestDataList[i].source)),
        );
        await tester.pumpAndSettle();
        // Sources take some time to get initialized
        await tester.pump(const Duration(seconds: 8));
        for (var i = 0; i < audioTestDataList.length; i++) {
          final td = audioTestDataList[i];
          if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
            await tester.pump();
            final position = await players[i].getCurrentPosition();
            printWithTimeOnFailure('Test position: $td');
            expect(position, greaterThan(Duration.zero));
          }
          await players[i].stop();
        }
      },
      // FIXME: Causes media error on Android (see #1333, #1353)
      // Unexpected platform error: MediaPlayer error with
      // what:MEDIA_ERROR_UNKNOWN {what:1} extra:MEDIA_ERROR_SYSTEM
      // skip: !kIsWeb && Platform.isAndroid,
    );

    testWidgets('play multiple sources consecutively',
        (WidgetTester tester) async {
      final player = AudioPlayer();

      for (var i = 0; i < audioTestDataList.length; i++) {
        final td = audioTestDataList[i];
        await player.play(td.source);
        await tester.pumpAndSettle();
        // Sources take some time to get initialized
        await tester.pump(const Duration(seconds: 8));
        if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
          await tester.pump();
          final position = await player.getCurrentPosition();
          printWithTimeOnFailure('Test position: $td');
          expect(position, greaterThan(Duration.zero));
        }
        await player.stop();
      }
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
        final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

        final td = audioTestDataList[0];

        var audioContext = AudioContextConfig(
          //ignore: avoid_redundant_argument_values
          forceSpeaker: true,
          //ignore: avoid_redundant_argument_values
          respectSilence: false,
        ).build();
        await AudioPlayer.global.setGlobalAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await player.play(td.source);
        await tester.pumpAndSettle();
        await tester.pump(td.duration + const Duration(seconds: 8));
        expect(player.state, PlayerState.completed);

        audioContext = AudioContextConfig(
          forceSpeaker: false,
          respectSilence: true,
        ).build();
        await AudioPlayer.global.setGlobalAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await player.resume();
        await tester.pumpAndSettle();
        await tester.pump(td.duration + const Duration(seconds: 8));
        expect(player.state, PlayerState.completed);
      },
      skip: !features.hasForceSpeaker,
    );

    /// Android and iOS only: Play the same sound twice with a different audio
    /// context each. This test can be executed on a device, with either
    /// "Silent", "Vibrate" or "Ring" mode. In "Silent" or "Vibrate" mode
    /// the second sound should not be audible.
    testWidgets(
      'test changing AudioContextConfigs in LOW_LATENCY mode',
      (WidgetTester tester) async {
        final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
        player.setPlayerMode(PlayerMode.lowLatency);

        final td = audioTestDataList[0];

        var audioContext = AudioContextConfig(
          //ignore: avoid_redundant_argument_values
          forceSpeaker: true,
          //ignore: avoid_redundant_argument_values
          respectSilence: false,
        ).build();
        await AudioPlayer.global.setGlobalAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await player.setSource(td.source);
        await player.resume();
        await tester.pumpAndSettle();
        await tester.pump(td.duration + const Duration(seconds: 8));
        expect(player.state, PlayerState.playing);
        await player.stop();
        expect(player.state, PlayerState.stopped);

        audioContext = AudioContextConfig(
          forceSpeaker: false,
          respectSilence: true,
        ).build();
        await AudioPlayer.global.setGlobalAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await player.resume();
        await tester.pumpAndSettle();
        await tester.pump(td.duration + const Duration(seconds: 8));
        expect(player.state, PlayerState.playing);
        await player.stop();
        expect(player.state, PlayerState.stopped);
      },
      skip: !features.hasForceSpeaker || !features.hasLowLatency,
    );
  });

  group('Logging', () {
    testWidgets('Platforms show INFO log, when start playing', (tester) async {
      final completer = Completer<String>();
      final player = AudioPlayer();
      player.setLogHandler(
        completer.complete,
        onError: completer.completeError,
      );
      await player.play(audioTestDataList[0].source);
      final log = await completer.future;
      expect(log, 'RESUME');
    });
  });

  group('Error', () {
    testWidgets('Platforms throw PlatformException, when playing invalid file',
        (tester) async {
      final completer = Completer<Object>();
      final player = AudioPlayer();
      // TODO(Gustl22): use common event stream to test
      player.setLogHandler(
        (log) {},
        onError: (e, [_]) => completer.complete(e),
      );
      try {
        await player.setSource(AssetSource(assetInvalid));
        fail('PlatformException not thrown');
      } on PlatformException catch (e) {
        expect(e, isInstanceOf<PlatformException>());
      }
      final exception = await completer.future;
      expect(exception, isInstanceOf<PlatformException>());
    });
  });
}
