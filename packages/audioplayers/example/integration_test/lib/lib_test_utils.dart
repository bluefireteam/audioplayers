import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

extension LibWidgetTester on WidgetTester {
  Future<void> pumpPlatform([
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      // FIXME(1556): Pump on Linux doesn't work with GStreamer bus callback
      await Future.delayed(duration ?? Duration.zero);
    } else {
      await pump(duration, phase);
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
