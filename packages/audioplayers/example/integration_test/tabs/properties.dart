import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_utils.dart';

extension PropertiesWidgetTester on WidgetTester {
  Future<void> testDuration(
    Duration duration, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    printWithTimeOnFailure('Test Duration: $duration');
    final st = StackTrace.current.toString();
    await waitFor(
      () async {
        await scrollToAndTap(const Key('refreshButton'));
        await pump();
        expectWidgetHasDuration(
          const Key('durationText'),
          matcher: (Duration? actual) => durationRangeMatcher(actual, duration),
        );
      },
      timeout: timeout,
      stackTrace: st,
    );
  }

  Future<void> testPosition(
    Duration position, {
    Matcher Function(Duration) matcher = equals,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    printWithTimeOnFailure('Test Position: $position');
    final st = StackTrace.current.toString();
    await waitFor(
      () async {
        await scrollToAndTap(const Key('refreshButton'));
        await pump();
        expectWidgetHasDuration(
          const Key('positionText'),
          matcher: matcher(position),
        );
      },
      timeout: timeout,
      stackTrace: st,
    );
  }

  Future<void> testPlayerState(
    PlayerState playerState, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    printWithTimeOnFailure('Test PlayerState: $playerState');
    final st = StackTrace.current.toString();
    await waitFor(
      () async {
        await scrollToAndTap(const Key('refreshButton'));
        await pump();
        expectWidgetHasText(
          const Key('playerStateText'),
          matcher: contains(playerState.toString()),
        );
      },
      timeout: timeout,
      stackTrace: st,
    );
  }
}
