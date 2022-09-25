import 'dart:io';

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
    await tester.testPosition('0:00:00.000000');
  }

  final isImmediateDurationSupported =
      features.hasMp3Duration || !audioSourceTestData.sourceKey.contains('mp3');

  if (features.hasDurationEvent &&
      !audioSourceTestData.isStream &&
      isImmediateDurationSupported) {
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
      // TODO(Gustl22): avoid flaky onPosition test for Android only.
      // Reason is, that some frames are skipped on CI and position is not
      // updated in time. Once one can reproduce it reliably, we can fix
      // and enable it again.
      if (kIsWeb || !Platform.isAndroid) {
        await tester.testOnPosition('0:00:00');
      }
    }
  }

  if (features.hasDurationEvent &&
      !audioSourceTestData.isStream &&
      isImmediateDurationSupported) {
    // Test if onDurationText is set.
    await tester.testOnDuration(audioSourceTestData);
  }

  // Test player state: playing
  if (features.hasPlayerStateEvent &&
      (audioSourceTestData.isStream ||
          audioSourceTestData.duration > const Duration(seconds: 1))) {
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
    await tester.testDuration(audioSourceTestData);
    await tester.testOnDuration(audioSourceTestData);
  }
  if (features.hasPositionEvent && !audioSourceTestData.isStream) {
    await tester.testPosition('0:00:00.000000');
  }
}

extension StreamWidgetTester on WidgetTester {
  Future<void> testDuration(SourceTestData sourceTestData) async {
    final durationStr = sourceTestData.duration.toString().substring(0, 8);
    printOnFailure('Test Duration: $durationStr');
    final st = StackTrace.current.toString();
    await waitFor(
      () async {
        await tap(find.byKey(const Key('getDuration')));
        expectWidgetHasText(
          const Key('durationText'),
          // Precision for duration:
          // Android: two tenth of a second
          // Windows: second
          // Linux: second
          matcher: contains(durationStr),
        );
      },
      timeout: const Duration(seconds: 2),
      stackTrace: st,
    );
  }

  Future<void> testPosition(String positionStr) async {
    printOnFailure('Test Position: $positionStr');
    final st = StackTrace.current.toString();
    await waitFor(
      () async {
        await tap(find.byKey(const Key('getPosition')));
        expectWidgetHasText(
          const Key('positionText'),
          matcher: contains(positionStr),
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

  Future<void> testOnDuration(SourceTestData sourceTestData) async {
    final durationStr = sourceTestData.duration.toString().substring(0, 8);
    printOnFailure('Test OnDuration: $durationStr');
    final st = StackTrace.current.toString();
    await waitFor(
      () async => expectWidgetHasText(
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
      () async => expectWidgetHasText(
        const Key('onPositionText'),
        matcher: contains('Stream Position: $positionStr'),
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
