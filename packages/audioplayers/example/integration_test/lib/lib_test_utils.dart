import 'package:flutter_test/flutter_test.dart';

extension LibWidgetTester on WidgetTester {
  /// See [pumpFrames].
  Future<void> pumpGlobalFrames(
    Duration maxDuration, [
    Duration interval = const Duration(milliseconds: 16, microseconds: 683),
  ]) {
    var elapsed = Duration.zero;
    return TestAsyncUtils.guard<void>(() async {
      binding.scheduleFrame();
      while (elapsed < maxDuration) {
        await binding.pump(interval);
        elapsed += interval;
      }
    });
  }
}
