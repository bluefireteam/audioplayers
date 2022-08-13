import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../platform_features.dart';
import '../source_test_data.dart';
import '../test_utils.dart';
import 'source_tab.dart';
import 'stream_tab.dart';

Future<void> testControlsTab(
  WidgetTester tester,
  SourceTestData audioSourceTestData,
  PlatformFeatures features,
) async {
  printOnFailure('Test Controls Tab');
  await tester.tap(find.byKey(const Key('controlsTab')));
  await tester.pumpAndSettle();

  if (features.hasVolume) {
    await tester.testVolume('0.5');
    await tester.pump(const Duration(seconds: 1));
    await tester.testVolume('2.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.testVolume('1.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('control-stop')));
  }

  if (features.hasPlaybackRate && !audioSourceTestData.isStream) {
    // TODO(Gustl22): also test for playback rate in streams
    await tester.testRate('0.5');
    await tester.pump(const Duration(seconds: 1));
    await tester.testRate('2.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.testRate('1.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('control-stop')));
  }

  if (features.hasSeek && !audioSourceTestData.isStream) {
    // TODO(Gustl22): also test seeking in streams
    await tester.testSeek('0.5', isResume: false);
    await tester.tap(find.byKey(const Key('streamsTab')));
    await tester.pumpAndSettle();
    
    final isImmediateDurationSupported =
        features.hasMp3Duration || !audioSourceTestData.sourceKey.contains('mp3');
    
    if(isImmediateDurationSupported) {
      await tester.testPosition(
        Duration(milliseconds: audioSourceTestData.duration.inMilliseconds ~/ 2)
            .toString()
            .substring(0, 8),
      );
    }
    await tester.tap(find.byKey(const Key('controlsTab')));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 1));
    await tester.testSeek('1.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('control-stop')));
  }

  final isBytesSource = audioSourceTestData.sourceKey.contains('bytes');
  if (features.hasLowLatency &&
      !audioSourceTestData.isStream &&
      !isBytesSource) {
    await tester.testPlayerMode(PlayerMode.lowLatency);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('control-stop')));
    await tester.testPlayerMode(PlayerMode.mediaPlayer, isResume: false);
    await tester.pumpAndSettle();
  }

  if (audioSourceTestData.duration < const Duration(seconds: 2) &&
      !audioSourceTestData.isStream) {
    if (features.hasReleaseModeLoop) {
      await tester.testReleaseMode(ReleaseMode.loop);
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const Key('control-stop')));
      await tester.testReleaseMode(ReleaseMode.stop, isResume: false);
      await tester.pumpAndSettle();
    }

    if (features.hasReleaseModeRelease) {
      await tester.testReleaseMode(ReleaseMode.release);
      await tester.pump(const Duration(seconds: 3));
      // No need to call stop, as it should be released by now
      // TODO(Gustl22): test if source was released

      // Reinitialize source
      await tester.tap(find.byKey(const Key('sourcesTab')));
      await tester.pumpAndSettle();
      await tester.testSource(audioSourceTestData.sourceKey);

      await tester.tap(find.byKey(const Key('controlsTab')));
      await tester.pumpAndSettle();

      await tester.testReleaseMode(ReleaseMode.stop, isResume: false);
      await tester.pumpAndSettle();
    }
  }
}

extension ControlsWidgetTester on WidgetTester {
  Future<void> testVolume(String volume) async {
    printOnFailure('Test Volume: $volume');
    await tap(find.byKey(Key('control-volume-$volume')));
    await tap(find.byKey(const Key('control-resume')));
    // TODO(Gustl22): get volume from native implementation
  }

  Future<void> testRate(String rate) async {
    printOnFailure('Test Rate: $rate');
    await tap(find.byKey(Key('control-rate-$rate')));
    await tap(find.byKey(const Key('control-resume')));
    // TODO(Gustl22): get rate from native implementation
  }

  Future<void> testSeek(String seek, {bool isResume = true}) async {
    printOnFailure('Test Seek: $seek');
    await tap(find.byKey(Key('control-seek-$seek')));
    if (isResume) {
      await tap(find.byKey(const Key('control-resume')));
    }
  }

  Future<void> testPlayerMode(PlayerMode mode, {bool isResume = true}) async {
    printOnFailure('Test Player Mode: ${mode.name}');
    await tap(find.byKey(Key('control-player-mode-${mode.name}')));
    await waitFor(
      () => expectEnumToggleHasSelected(
        const Key('control-player-mode'),
        matcher: equals(mode),
      ),
    );
    if (isResume) {
      await tap(find.byKey(const Key('control-resume')));
    }
    // TODO(Gustl22): get player mode from native implementation
  }

  Future<void> testReleaseMode(ReleaseMode mode, {bool isResume = true}) async {
    printOnFailure('Test Release Mode: ${mode.name}');
    await tap(find.byKey(Key('control-release-mode-${mode.name}')));
    await waitFor(
      () => expectEnumToggleHasSelected(
        const Key('control-release-mode'),
        matcher: equals(mode),
      ),
    );
    if (isResume) {
      await tap(find.byKey(const Key('control-resume')));
    }
    // TODO(Gustl22): get release mode from native implementation
  }
}
