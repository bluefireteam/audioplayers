import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

extension LibWidgetTester on WidgetTester {
  Future<void> pumpLinux() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      // FIXME(gustl22): Linux needs additional pump (#1556)
      await pump();
    }
  }

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
