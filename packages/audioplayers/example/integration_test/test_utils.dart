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
