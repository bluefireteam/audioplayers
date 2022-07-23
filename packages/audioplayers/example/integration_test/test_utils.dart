import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'source_test_data.dart';

extension WidgetTesterUtils on WidgetTester {
  Future<void> testDuration(SourceTestData sourceTestData) async {
    await tap(find.byKey(const Key('getDuration')));
    await waitFor(
      () => expectWidgetHasText(
        const Key('durationText'),
        // Precision for duration:
        // Android: hundredth of a second
        // Windows: second
        matcher: contains(
          sourceTestData.duration.toString().substring(0, 8),
        ),
      ),
      timeout: const Duration(seconds: 2),
    );
  }

  Future<void> testPosition(String positionStr) async {
    await tap(find.byKey(const Key('getPosition')));
    await waitFor(
      () => expectWidgetHasText(
        const Key('positionText'),
        matcher: contains(positionStr),
      ),
      timeout: const Duration(seconds: 2),
    );
  }

  Future<void> testOnDuration(SourceTestData sourceTestData) async {
    final durationStr = sourceTestData.duration.toString().substring(0, 8);
    await waitFor(
      () => expectWidgetHasText(
        const Key('onDurationText'),
        matcher: contains(
          'Stream Duration: $durationStr',
        ),
      ),
      stackTrace: StackTrace.current.toString(),
    );
  }

  Future<void> testOnPosition(String positionStr) async {
    await waitFor(
      () => expectWidgetHasText(
        const Key('onPositionText'),
        matcher: contains('Stream Position: $positionStr'),
      ),
      pollInterval: const Duration(milliseconds: 250),
      stackTrace: StackTrace.current.toString(),
    );
  }

  // Add [stackTrace] to work around https://github.com/flutter/flutter/issues/89138
  Future<void> waitFor(
    void Function() testExpectation, {
    Duration? timeout = const Duration(seconds: 15),
    Duration? pollInterval = const Duration(milliseconds: 500),
    String? stackTrace,
  }) =>
      _waitUntil(
        (setFailureMessage) async {
          try {
            await pump();
            testExpectation();
            return true;
          } on TestFailure catch (e) {
            setFailureMessage(e.message ?? '');
            return false;
          }
        },
        timeout: timeout,
        pollInterval: pollInterval,
        stackTrace: stackTrace,
      );

  /// Waits until the [condition] returns true
  /// Will raise a complete with a [TimeoutException] if the
  /// condition does not return true with the timeout period.
  /// Copied from: https://github.com/jonsamwell/flutter_gherkin/blob/02a4af91d7a2512e0a4540b9b1ab13e36d5c6f37/lib/src/flutter/utils/driver_utils.dart#L86
  Future<void> _waitUntil(
    Future<bool> Function(Function(String message) setFailureMessage)
        condition, {
    Duration? timeout = const Duration(seconds: 15),
    Duration? pollInterval = const Duration(milliseconds: 500),
    String? stackTrace,
  }) async {
    var firstFailureMsg = '';
    var lastFailureMsg = '';
    try {
      await Future.microtask(
        () async {
          final completer = Completer<void>();
          final maxAttempts =
              (timeout!.inMilliseconds / pollInterval!.inMilliseconds).round();
          var attempts = 0;

          while (attempts < maxAttempts) {
            final result = await condition((String message) {
              if (firstFailureMsg.isEmpty) {
                firstFailureMsg = message;
              }
              lastFailureMsg = message;
            });
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
      throw Exception(
        '''$e

Stacktrace: 
$stackTrace
First Failure: 
$firstFailureMsg
Last Failure: 
$lastFailureMsg''',
      );
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
