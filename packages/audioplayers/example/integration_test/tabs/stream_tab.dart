import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../platform_features.dart';
import '../source_test_data.dart';
import '../test_utils.dart';

Future<void> testStreamsTab(
  WidgetTester tester,
  SourceTestData audioSourceTestData,
  PlatformFeatures features,
) async {
  printOnFailure('Test Streams Tab');
  await tester.tap(find.byKey(const Key('streamsTab')));
  await tester.pumpAndSettle();

  // Stream position is tracked as soon as source is loaded
  if (!audioSourceTestData.isStream) {
    // Display position before playing
    await tester.testPosition('0:00:00.000000');
  }

  // MP3 duration is estimated: https://bugzilla.gnome.org/show_bug.cgi?id=726144
  final isImmediateDurationSupported =
      features.hasMp3Duration || !audioSourceTestData.sourceKey.contains('mp3');

  if (!audioSourceTestData.isStream && isImmediateDurationSupported) {
    // Display duration before playing
    await tester.testDuration(audioSourceTestData);
  }

  await tester.tap(find.byKey(const Key('play_button')));
  await tester.pump();

  if (!audioSourceTestData.isStream) {
    // Test if onPositionText is set.
    // Cannot test more precisely as it is dependent on pollInterval.
    // TODO(Gustl22): test position update in seek mode.
    if (features.hasPositionEvent) {
      await tester.testOnPosition('0:00:00');
    }
  }

  if (!audioSourceTestData.isStream && isImmediateDurationSupported) {
    // Test if onDurationText is set.
    if (features.hasDurationEvent) {
      await tester.testOnDuration(audioSourceTestData);
    }
  }

  const sampleDuration = Duration(seconds: 2);
  await tester.pump(sampleDuration);

  // Display duration after end / stop (some samples are shorter than sampleDuration, so this test would fail)
  // TODO(Gustl22): Not possible at the moment (shows duration of 0)
  // await testDuration();
  // await testOnDuration();

  await tester.tap(find.byKey(const Key('pause_button')));
  await tester.tap(find.byKey(const Key('stop_button')));
}

extension StreamWidgetTester on WidgetTester {
  Future<void> testDuration(SourceTestData sourceTestData) async {
    final durationStr = sourceTestData.duration.toString().substring(0, 8);
    printOnFailure('Test Duration: $durationStr');
    final st = StackTrace.current.toString();
    await tap(find.byKey(const Key('getDuration')));
    await waitFor(
      () => expectWidgetHasText(
        const Key('durationText'),
        // Precision for duration:
        // Android: hundredth of a second
        // Windows: second
        // Linux: second
        matcher: contains(durationStr),
      ),
      timeout: const Duration(seconds: 2),
      stackTrace: st,
    );
  }

  Future<void> testPosition(String positionStr) async {
    printOnFailure('Test Position: $positionStr');
    final st = StackTrace.current.toString();
    await tap(find.byKey(const Key('getPosition')));
    await waitFor(
      () => expectWidgetHasText(
        const Key('positionText'),
        matcher: contains(positionStr),
      ),
      timeout: const Duration(seconds: 2),
      stackTrace: st,
    );
  }

  Future<void> testOnDuration(SourceTestData sourceTestData) async {
    final durationStr = sourceTestData.duration.toString().substring(0, 8);
    printOnFailure('Test OnDuration: $durationStr');
    final st = StackTrace.current.toString();
    await waitFor(
      () => expectWidgetHasText(
        const Key('onDurationText'),
        matcher: contains(
          'Stream Duration: $durationStr',
        ),
      ),
      stackTrace: st,
    );
  }

  Future<void> testOnPosition(String positionStr) async {
    printOnFailure('Test OnPosition: $positionStr');
    final st = StackTrace.current.toString();
    await waitFor(
      () => expectWidgetHasText(
        const Key('onPositionText'),
        matcher: contains('Stream Position: $positionStr'),
      ),
      pollInterval: const Duration(milliseconds: 250),
      stackTrace: st,
    );
  }
}
