import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'source_test_data.dart';

extension WidgetTesterUtils on WidgetTester {
  Future<void> testDuration(SourceTestData sourceTestData) async {
    await tap(find.byKey(const Key('getDuration')));
    await pumpAndSettle();
    expectWidgetHasText(
      const Key('durationText'),
      // Precision for duration:
      // Android: hundredth of a second
      // Windows: second
      matcher: contains(
        sourceTestData.duration.toString().substring(0, 8),
      ),
    );
  }

  Future<void> testPosition(String positionStr) async {
    await tap(find.byKey(const Key('getPosition')));
    await pumpAndSettle();
    expectWidgetHasText(
      const Key('positionText'),
      matcher: contains(positionStr),
    );
  }

  Future<void> testOnDuration(SourceTestData sourceTestData) async {
    final durationStr = sourceTestData.duration.toString().substring(0, 8);
    final currentDurationStr = (find
            .byKey(const Key('onDurationText'))
            .evaluate()
            .single
            .widget as Text)
        .data;
    await waitFor(
      () => expectWidgetHasText(
        const Key('onDurationText'),
        matcher: contains(
          'Stream Duration: $durationStr',
        ),
      ),
      stackTrace: [
        StackTrace.current.toString(),
        'Current: $currentDurationStr',
        'Expected: $durationStr',
      ],
    );
  }

  Future<void> testOnPosition(String positionStr) async {
    final currentPositionStr = (find
            .byKey(const Key('onPositionText'))
            .evaluate()
            .single
            .widget as Text)
        .data;
    await waitFor(
      () => expectWidgetHasText(
        const Key('onPositionText'),
        matcher: contains('Stream Position: $positionStr'),
      ),
      stackTrace: [
        StackTrace.current.toString(),
        'Current: $currentPositionStr',
        'Expected: $positionStr',
      ],
    );
  }

  // Add [stackTrace] to work around https://github.com/flutter/flutter/issues/89138
  Future<void> waitFor(
    void Function() testExpectation, {
    Duration? timeout = const Duration(seconds: 15),
    List<String>? stackTrace,
  }) =>
      _waitUntil(
        () async {
          try {
            await pumpAndSettle();
            testExpectation();
            return true;
          } on TestFailure {
            return false;
          }
        },
        timeout: timeout,
        stackTrace: stackTrace,
      );

  /// Waits until the [condition] returns true
  /// Will raise a complete with a [TimeoutException] if the
  /// condition does not return true with the timeout period.
  /// Copied from: https://github.com/jonsamwell/flutter_gherkin/blob/02a4af91d7a2512e0a4540b9b1ab13e36d5c6f37/lib/src/flutter/utils/driver_utils.dart#L86
  Future<void> _waitUntil(
    Future<bool> Function() condition, {
    Duration? timeout = const Duration(seconds: 15),
    Duration? pollInterval = const Duration(milliseconds: 500),
    List<String>? stackTrace,
  }) async {
    try {
      await Future.microtask(
        () async {
          final completer = Completer<void>();
          final maxAttempts =
              (timeout!.inMilliseconds / pollInterval!.inMilliseconds).round();
          var attempts = 0;

          while (attempts < maxAttempts) {
            final result = await condition();
            if (result) {
              completer.complete();
              break;
            } else {
              await Future<void>.delayed(pollInterval);
            }
            attempts++;
          }
        },
      ).timeout(
        timeout!,
      );
    } on TimeoutException catch (e) {
      throw Exception('$e\nStacktrace:\n${stackTrace?.join('\n')}');
    }
  }

  Future<void> scrollTo(Key widgetKey) async {
    await dragUntilVisible(
      find.byKey(widgetKey),
      find.byType(SingleChildScrollView).first,
      const Offset(0, 100),
    );
    await pumpAndSettle();
  }
}

void expectWidgetHasText(
  Key key, {
  required Matcher matcher,
  bool skipOffstage = true,
}) {
  final widget =
      find.byKey(key, skipOffstage: skipOffstage).evaluate().single.widget;
  if (widget is Text) {
    expect(widget.data, matcher);
  } else {
    throw 'Widget with key $key is not a Widget of type "Text"';
  }
}
