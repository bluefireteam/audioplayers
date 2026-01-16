import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void printWithTimeOnFailure(String message) {
  printOnFailure('${DateTime.now()}: $message');
}

bool durationRangeMatcher(
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

extension ExtendedWidgetTester on WidgetTester {
  // Add [stackTrace] to work around https://github.com/flutter/flutter/issues/89138
  Future<void> waitFor(
    Future<void> Function() testExpectation, {
    Duration? timeout = const Duration(seconds: 15),
    Duration? pollInterval = const Duration(milliseconds: 500),
    String? stackTrace,
  }) async =>
      _waitUntil(
        (setFailureMessage) async {
          try {
            await pump();
            await testExpectation();
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
    Future<bool> Function(void Function(String message) setFailureMessage)
        condition, {
    Duration? timeout = const Duration(seconds: 15),
    Duration? pollInterval = const Duration(milliseconds: 500),
    String? stackTrace,
  }) async {
    var firstFailureMsg = '';
    var lastFailureMsg = 'same as first failure';
    void setFailureMessage(String message) {
      if (firstFailureMsg.isEmpty) {
        firstFailureMsg = '${DateTime.now()}:\n $message';
      } else {
        lastFailureMsg = '${DateTime.now()}:\n $message';
      }
    }

    try {
      await Future.microtask(
        () async {
          final completer = Completer<void>();
          final maxAttempts =
              (timeout!.inMilliseconds / pollInterval!.inMilliseconds).round();
          var attempts = 0;

          while (attempts < maxAttempts) {
            final result = await condition(setFailureMessage);
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
}
