import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../platform_features.dart';
import '../source_test_data.dart';
import 'stream_tab_test.dart';

Future<void> testControlsTab(
  WidgetTester tester,
  SourceTestData audioSourceTestData,
  PlatformFeatures features,
) async {
  await tester.tap(find.byKey(const Key('controlsTab')));
  await tester.pumpAndSettle();

  if (features.hasVolume) {
    await tester.testVolume('0.5');
    await tester.pump(const Duration(seconds: 1));
    await tester.testVolume('2.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('control-stop')));
  }

  if (features.hasPlaybackRate) {
    await tester.testRate('0.5');
    await tester.pump(const Duration(seconds: 1));
    await tester.testRate('2.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('control-stop')));
  }

  if (features.hasSeek) {
    await tester.testSeek('0.5');
    await tester.tap(find.byKey(const Key('streamsTab')));
    await tester.pumpAndSettle();
    await tester.testPosition(
      Duration(milliseconds: audioSourceTestData.duration.inMilliseconds ~/ 2)
          .toString()
          .substring(0, 8),
    );
    await tester.tap(find.byKey(const Key('controlsTab')));
    await tester.pumpAndSettle();
    
    await tester.pump(const Duration(seconds: 1));
    await tester.testSeek('2.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('control-stop')));
  }

  if (features.hasLowLatency) {
    await tester.testPlayerMode(PlayerMode.lowLatency);
  }

  if (features.hasReleaseMode) {
    await tester.testReleaseMode(ReleaseMode.loop);
    await tester.testReleaseMode(ReleaseMode.release);
  }
}

extension ControlsWidgetTester on WidgetTester {
  Future<void> testVolume(String volume) async {
    await tap(find.byKey(Key('control-volume-$volume')));
    await tap(find.byKey(const Key('control-resume')));
    // TODO(Gustl22): get volume from native implementation
  }

  Future<void> testRate(String rate) async {
    await tap(find.byKey(Key('control-rate-$rate')));
    await tap(find.byKey(const Key('control-resume')));
    // TODO(Gustl22): get rate from native implementation
  }

  Future<void> testSeek(String seek) async {
    await tap(find.byKey(Key('control-rate-$seek')));
    await tap(find.byKey(const Key('control-resume')));
    // TODO(Gustl22): get seek from native implementation
  }

  Future<void> testPlayerMode(PlayerMode mode) async {
    await tap(find.byKey(Key('control-player-mode-${mode.name}')));
    await tap(find.byKey(const Key('control-resume')));
    // TODO(Gustl22): get player mode from native implementation
  }

  Future<void> testReleaseMode(ReleaseMode mode) async {
    await tap(find.byKey(Key('control-release-mode-${mode.name}')));
    await tap(find.byKey(const Key('control-resume')));
    // TODO(Gustl22): get release mode from native implementation
  }
}