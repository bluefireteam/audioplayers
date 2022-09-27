import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
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
  if (features.hasPositionEvent && !audioSourceTestData.isStream) {
    // Display position before playing
    await tester.testPosition(Duration.zero);
  }

  final isImmediateDurationSupported =
      features.hasMp3Duration || !audioSourceTestData.sourceKey.contains('mp3');

  if (features.hasDurationEvent && isImmediateDurationSupported) {
    // Display duration before playing
    await tester.testDuration(audioSourceTestData.duration);
  }

  await tester.tap(find.byKey(const Key('play_button')));
  await tester.pump();

  if (!audioSourceTestData.isStream) {
    // Test if onPositionText is set.
    // Cannot test more precisely as it is dependent on pollInterval.
    // TODO(Gustl22): test position update in seek mode.
    if (features.hasPositionEvent) {
      if (kIsWeb) {
        await tester.testOnPosition(Duration.zero, matcher: greaterThan);
      }
    }
  }

  if (features.hasDurationEvent &&
      !audioSourceTestData.isStream &&
      isImmediateDurationSupported) {
    // Test if onDurationText is set.
    await tester.testOnDuration(audioSourceTestData.duration);
  }

  // Test player state: playing
  if (features.hasPlayerStateEvent &&
      (audioSourceTestData.isStream ||
          audioSourceTestData.duration > const Duration(seconds: 2))) {
    // Only test, if there's enough time to be able to check playing state.
    await tester.testPlayerState(PlayerState.playing);
    await tester.testOnState(PlayerState.playing);
  }

  const sampleDuration = Duration(seconds: 3);
  await tester.pump(sampleDuration);

  // Test player states: pause, stop, completed
  if (features.hasPlayerStateEvent) {
    if (!audioSourceTestData.isStream) {
      if (audioSourceTestData.duration < const Duration(seconds: 2)) {
        await tester.testPlayerState(PlayerState.completed);
        await tester.testOnState(PlayerState.completed);
      } else if (audioSourceTestData.duration > const Duration(seconds: 4)) {
        await tester.tap(find.byKey(const Key('pause_button')));
        await tester.testPlayerState(PlayerState.paused);
        await tester.testOnState(PlayerState.paused);

        await tester.tap(find.byKey(const Key('stop_button')));
        await tester.testPlayerState(PlayerState.stopped);
        await tester.testOnState(PlayerState.stopped);
      } else {
        // Cannot say for sure, if it's stopped or completed, so we just stop
        await tester.tap(find.byKey(const Key('stop_button')));
      }
    } else {
      await tester.tap(find.byKey(const Key('stop_button')));
      await tester.testPlayerState(PlayerState.stopped);
      await tester.testOnState(PlayerState.stopped);
    }
  }

  // Display duration & position after completion / stop
  if (features.hasDurationEvent) {
    await tester.testDuration(audioSourceTestData.duration);
    await tester.testOnDuration(audioSourceTestData.duration);
  }
  if (features.hasPositionEvent && !audioSourceTestData.isStream) {
    await tester.testPosition(Duration.zero);
  }
}

extension StreamWidgetTester on WidgetTester {
  bool _durationRangeMatcher(
    Duration? actual,
    Duration? expected, {
    Duration deviation = const Duration(seconds: 1),
  }) {
    if (actual == null && expected == null) {
      return true;
    }
    if (actual == null || expected == null) {
      return false;
    }
    return actual >= (expected - deviation) && actual <= (expected + deviation);
  }

  Future<void> testDuration(Duration duration) async {
    printOnFailure('Test Duration: $duration');
    final st = StackTrace.current.toString();
    await waitFor(
      () async {
        await tap(find.byKey(const Key('getDuration')));
        expectWidgetHasDuration(
          const Key('durationText'),
          // Precision for duration:
          // Android: two tenth of a second
          // Windows: second
          // Linux: second
          matcher: (Duration? actual) =>
              _durationRangeMatcher(actual, duration),
        );
      },
      timeout: const Duration(seconds: 2),
      stackTrace: st,
    );
  }

  Future<void> testPosition(
    Duration position, {
    Matcher Function(Duration) matcher = equals,
  }) async {
    printOnFailure('Test Position: $position');
    final st = StackTrace.current.toString();
    await waitFor(
      () async {
        await tap(find.byKey(const Key('getPosition')));
        expectWidgetHasDuration(
          const Key('positionText'),
          matcher: matcher(position),
        );
      },
      timeout: const Duration(seconds: 2),
      stackTrace: st,
    );
  }

  Future<void> testPlayerState(PlayerState playerState) async {
    printOnFailure('Test PlayerState: $playerState');
    final st = StackTrace.current.toString();
    await waitFor(
      () async {
        await tap(find.byKey(const Key('getPlayerState')));
        expectWidgetHasText(
          const Key('playerStateText'),
          matcher: contains(playerState.toString()),
        );
      },
      timeout: const Duration(seconds: 2),
      stackTrace: st,
    );
  }

  Future<void> testOnDuration(Duration duration) async {
    printOnFailure('Test OnDuration: $duration');
    final st = StackTrace.current.toString();
    await waitFor(
      () async => expectWidgetHasDuration(
        const Key('onDurationText'),
        matcher: (Duration? actual) => _durationRangeMatcher(actual, duration),
      ),
      stackTrace: st,
    );
  }

  Future<void> testOnPosition(
    Duration position, {
    Matcher Function(Duration) matcher = equals,
  }) async {
    printOnFailure('Test OnPosition: $position');
    final st = StackTrace.current.toString();
    await waitFor(
      () async => expectWidgetHasDuration(
        const Key('onPositionText'),
        matcher: matcher(position),
      ),
      pollInterval: const Duration(milliseconds: 250),
      stackTrace: st,
    );
  }

  Future<void> testOnState(PlayerState playerState) async {
    printOnFailure('Test OnState: $playerState');
    final st = StackTrace.current.toString();
    await waitFor(
      () async => expectWidgetHasText(
        const Key('onStateText'),
        matcher: contains('Stream State: $playerState'),
      ),
      pollInterval: const Duration(milliseconds: 250),
      stackTrace: st,
    );
  }
}
