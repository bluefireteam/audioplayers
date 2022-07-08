import 'package:audioplayers_example/main.dart' as app;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'platform_features.dart';
import 'source_test_data.dart';
import 'test_utils.dart';

void main() {
  final features = PlatformFeatures.instance();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app is launched', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(
        find.text('Remote URL WAV 1 - coins.wav'),
        findsOneWidget,
      );
    });
  });

  group('test functionality of sources', () {
    final audioTestDataList = [
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-wav-1',
          duration: const Duration(milliseconds: 451),
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-wav-2',
          duration: const Duration(seconds: 1, milliseconds: 068),
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-mp3-1',
          duration: const Duration(minutes: 3, seconds: 30, milliseconds: 77),
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-mp3-2',
          duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
        ),
      if (features.hasUrlSource && features.hasPlaylistSourceType)
        SourceTestData(
          sourceKey: 'url-remote-m3u8',
          duration: Duration.zero,
          isStream: true,
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-mpga',
          duration: Duration.zero,
          isStream: true,
        ),
      if (features.hasAssetSource)
        SourceTestData(
          sourceKey: 'asset-wav',
          duration: const Duration(seconds: 1, milliseconds: 068),
        ),
      if (features.hasAssetSource)
        SourceTestData(
          sourceKey: 'asset-mp3',
          duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
        ),
      if (features.hasBytesSource)
        SourceTestData(
          sourceKey: 'bytes-local',
          duration: const Duration(seconds: 1, milliseconds: 068),
        ),
      if (features.hasBytesSource)
        SourceTestData(
          sourceKey: 'bytes-remote',
          duration: const Duration(minutes: 3, seconds: 30, milliseconds: 76),
        ),
    ];

    for (final audioSourceTestData in audioTestDataList) {
      testWidgets('test source $audioSourceTestData',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Sources
        await tester.tap(find.byKey(const Key('sourcesTab')));
        await tester.pumpAndSettle();

        final sourceWidgetKey =
            Key('setSource-${audioSourceTestData.sourceKey}');
        await tester.scrollTo(sourceWidgetKey);
        await tester.tap(find.byKey(sourceWidgetKey));

        const sourceSetKey = Key('isSourceSet');
        await tester.scrollTo(sourceSetKey);
        final currentSourceSetStatusText =
            (find.byKey(sourceSetKey).evaluate().single.widget as Text).data;
        await tester.waitFor(
          () => expectWidgetHasText(
            sourceSetKey,
            matcher: equals('Source is set'),
          ),
          timeout: const Duration(seconds: 90),
          stackTrace: [
            StackTrace.current.toString(),
            'Current: $currentSourceSetStatusText',
            'Expected: Source is set',
          ],
        );

        // Streams
        await tester.tap(find.byKey(const Key('streamsTab')));
        await tester.pumpAndSettle();

        // Stream position is tracked as soon as source is loaded
        if (!audioSourceTestData.isStream) {
          // Display position before playing
          await tester.testPosition('0:00:00.000000');
        }

        // MP3 duration is estimated: https://bugzilla.gnome.org/show_bug.cgi?id=726144
        final isImmediateDurationSupported = features.hasMp3Duration ||
            !audioSourceTestData.sourceKey.contains('mp3');

        if (!audioSourceTestData.isStream && isImmediateDurationSupported) {
          // Display duration before playing
          await tester.testDuration(audioSourceTestData);
        }

        await tester.tap(find.byKey(const Key('play_button')));
        await tester.pumpAndSettle();

        // Test if onDurationText is set immediately.
        if (!audioSourceTestData.isStream && isImmediateDurationSupported) {
          if (features.hasDurationEvent) {
            await tester.testOnDuration(audioSourceTestData);
          }
        }

        const sampleDuration = Duration(seconds: 2);
        await tester.pump(sampleDuration);

        if (!audioSourceTestData.isStream) {
          // Test if position is set.
          // Cannot test more precisely as initialization takes some time and
          // a longer sampleDuration would decelerate length of overall tests.
          // TODO(Gustl22): test position update in seek mode.
          if (features.hasPositionEvent) {
            await tester.testOnPosition('0:00:0');
          }
        }

        // Display duration after end / stop (some samples are shorter than sampleDuration, so this test would fail)
        // TODO(Gustl22): Not possible at the moment (shows duration of 0)
        // await testDuration();
        // await testOnDuration();

        await tester.tap(find.byKey(const Key('pause_button')));
        await tester.tap(find.byKey(const Key('stop_button')));

        // Controls
        // TODO(Gustl22): test volume, rate, player mode, release mode, seek
        // await tester.tap(find.byKey(const Key('controlsTab')));
        // await tester.pumpAndSettle();

        // await tester.tap(find.byKey(const Key('control-resume')));
        // await Future<void>.delayed(const Duration(seconds: 1));

        // Audio context
        // TODO(Gustl22): test generic flags
        // await tester.tap(find.byKey(const Key('audioContextTab')));
        // await tester.pumpAndSettle();

        // Logs
        // TODO(Gustl22): may test logs
        // await tester.tap(find.byKey(const Key('loggerTab')));
        // await tester.pumpAndSettle();
      });
    }
  });

  group('play multiple sources', () {
    // TODO(Gustl22): play sources simultaneously
    // TODO(Gustl22): play one source after another
  });
}
