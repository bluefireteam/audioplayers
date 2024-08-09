import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../platform_features.dart';
import '../../test_utils.dart';
import '../app_source_test_data.dart';
import '../app_test_utils.dart';
import 'properties.dart';

Future<void> testStreamsTab(
  WidgetTester tester,
  AppSourceTestData audioSourceTestData,
  PlatformFeatures features,
) async {
  printWithTimeOnFailure('Test Streams Tab');
  await tester.tap(find.byKey(const Key('streamsTab')));
  await tester.pumpAndSettle();

  // Stream position is tracked as soon as source is loaded
  // FIXME: Flaky position test for web, remove kIsWeb check.
  if (!kIsWeb && !audioSourceTestData.isLiveStream) {
    // Display position before playing
    await tester.testPosition(Duration.zero);
  }

  if (features.hasDurationEvent && !audioSourceTestData.isVBR) {
    // Display duration before playing
    await tester.testDuration(audioSourceTestData.duration);
  }

  // Sources take some time to get initialized
  const timeout = Duration(seconds: 8);

  await tester.pumpAndSettle();
  await tester.scrollToAndTap(const Key('play_button'));
  await tester.pump();

  // Cannot test more precisely as it is dependent on pollInterval
  // and updateInterval of native implementation.
  if (audioSourceTestData.isLiveStream ||
      audioSourceTestData.duration! > const Duration(seconds: 2)) {
    // Test player state: playing
    if (features.hasPlayerStateEvent) {
      // Only test, if there's enough time to be able to check playing state.
      await tester.testPlayerState(PlayerState.playing, timeout: timeout);
      await tester.testOnPlayerState(PlayerState.playing, timeout: timeout);
    }

    // Test if onPositionText is set.
    await tester.testPosition(
      Duration.zero,
      matcher: (Duration? position) => greaterThan(position ?? Duration.zero),
      timeout: timeout,
    );
    await tester.testOnPosition(
      Duration.zero,
      matcher: greaterThan,
      timeout: timeout,
    );
  }

  if (features.hasDurationEvent && !audioSourceTestData.isLiveStream) {
    // Test if onDurationText is set.
    await tester.testOnDuration(
      audioSourceTestData.duration!,
      timeout: timeout,
    );
  }

  const sampleDuration = Duration(seconds: 3);
  await tester.pump(sampleDuration);

  // Test player states: pause, stop, completed
  if (features.hasPlayerStateEvent) {
    if (!audioSourceTestData.isLiveStream) {
      if (audioSourceTestData.duration! < const Duration(seconds: 2)) {
        await tester.testPlayerState(PlayerState.completed, timeout: timeout);
        await tester.testOnPlayerState(PlayerState.completed, timeout: timeout);
      } else if (audioSourceTestData.duration! > const Duration(seconds: 5)) {
        await tester.scrollToAndTap(const Key('pause_button'));
        await tester.pumpAndSettle();
        await tester.testPlayerState(PlayerState.paused);
        await tester.testOnPlayerState(PlayerState.paused);

        await tester.stopStream();
        await tester.testPlayerState(PlayerState.stopped);
        await tester.testOnPlayerState(PlayerState.stopped);
      } else {
        // Cannot say for sure, if it's stopped or completed, so we just stop
        await tester.stopStream();
      }
    } else {
      await tester.stopStream();
      await tester.testPlayerState(PlayerState.stopped, timeout: timeout);
      await tester.testOnPlayerState(PlayerState.stopped, timeout: timeout);
    }
  }

  // Display duration & position after completion / stop
  // FIXME(Gustl22): Linux does not support duration after completion event
  if (features.hasDurationEvent &&
      (kIsWeb || defaultTargetPlatform != TargetPlatform.linux)) {
    await tester.testDuration(audioSourceTestData.duration);
    if (!audioSourceTestData.isLiveStream) {
      await tester.testOnDuration(
        audioSourceTestData.duration!,
        timeout: timeout,
      );
    }
  }
  if (!audioSourceTestData.isLiveStream) {
    await tester.testPosition(Duration.zero);
  }
}

extension StreamWidgetTester on WidgetTester {
  // Precision for position & duration:
  // Android: millisecond
  // Windows: millisecond
  // Linux: millisecond
  // Web: millisecond
  // Darwin: millisecond

  Future<void> stopStream() async {
    final st = StackTrace.current.toString();

    await scrollToAndTap(const Key('stop_button'));
    await waitOneshot(const Key('toast-player-stopped-0'), stackTrace: st);
    await pumpAndSettle();
  }

  Future<void> testOnDuration(
    Duration duration, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    printWithTimeOnFailure('Test OnDuration: $duration');
    final st = StackTrace.current.toString();
    await waitFor(
      () async => expectWidgetHasDuration(
        const Key('onDurationText'),
        matcher: (Duration? actual) => durationRangeMatcher(
          actual,
          duration,
          deviation: const Duration(milliseconds: 500),
        ),
      ),
      timeout: timeout,
      stackTrace: st,
    );
  }

  Future<void> testOnPosition(
    Duration position, {
    Matcher Function(Duration) matcher = equals,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    printWithTimeOnFailure('Test OnPosition: $position');
    final st = StackTrace.current.toString();
    await waitFor(
      () async => expectWidgetHasDuration(
        const Key('onPositionText'),
        matcher: matcher(position),
      ),
      pollInterval: const Duration(milliseconds: 250),
      timeout: timeout,
      stackTrace: st,
    );
  }

  Future<void> testOnPlayerState(
    PlayerState playerState, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    printWithTimeOnFailure('Test OnState: $playerState');
    final st = StackTrace.current.toString();
    await waitFor(
      () async => expectWidgetHasText(
        const Key('onStateText'),
        matcher: equals(playerState.toString()),
      ),
      pollInterval: const Duration(milliseconds: 250),
      timeout: timeout,
      stackTrace: st,
    );
  }
}
