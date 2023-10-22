import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../platform_features.dart';
import '../../test_utils.dart';
import '../app_source_test_data.dart';
import '../app_test_utils.dart';
import 'properties.dart';
import 'source_tab.dart';

Future<void> testControlsTab(
  WidgetTester tester,
  AppSourceTestData audioSourceTestData,
  PlatformFeatures features,
) async {
  printWithTimeOnFailure('Test Controls Tab');
  await tester.tap(find.byKey(const Key('controlsTab')));
  await tester.pumpAndSettle();

  // Sources take some time to get initialized
  const stopDuration = Duration(seconds: 5);

  if (features.hasVolume) {
    await tester.testVolume('0.5', stopDuration: stopDuration);
    await tester.testVolume('0.0', stopDuration: stopDuration);
    await tester.testVolume('1.0', stopDuration: stopDuration);
    // No tests for volume > 1
  }

  if (features.hasBalance) {
    await tester.testBalance('-1.0', stopDuration: stopDuration);
    await tester.testBalance('1.0', stopDuration: stopDuration);
    await tester.testBalance('0.0', stopDuration: stopDuration);
  }

  if (features.hasPlaybackRate && !audioSourceTestData.isLiveStream) {
    // TODO(Gustl22): also test for playback rate in streams
    await tester.testRate('0.5');
    await tester.testRate('2.0');
    await tester.testRate('1.0');
  }

  if (features.hasSeek && !audioSourceTestData.isLiveStream) {
    // TODO(Gustl22): also test seeking in streams
    final isImmediateDurationSupported = features.hasMp3Duration ||
        !audioSourceTestData.sourceKey.contains('mp3');

    // Linux cannot complete seek if duration is not present.
    await tester.testSeek('0.5', isResume: false);
    await tester.doInStreamsTab((tester) async {
      if (isImmediateDurationSupported) {
        await tester.testPosition(
          Duration(seconds: audioSourceTestData.duration!.inSeconds ~/ 2),
          matcher: (Object? value) =>
              greaterThanOrEqualTo(value ?? Duration.zero),
        );
      }
    });

    await tester.pump(const Duration(seconds: 1));
    await tester.testSeek('1.0');
    await tester.pump(const Duration(seconds: 1));
    await tester.stop();
  }

  // Test all features in low latency mode:
  final isBytesSource = audioSourceTestData.sourceKey.contains('bytes');
  if (features.hasLowLatency &&
      !audioSourceTestData.isLiveStream &&
      !isBytesSource) {
    await tester.testPlayerMode(PlayerMode.lowLatency);

    // Test resume
    await tester.resume();
    await tester.pump(const Duration(seconds: 1));
    // Test pause
    await tester.scrollToAndTap(const Key('control-pause'));
    await tester.resume();
    await tester.pump(const Duration(seconds: 1));
    await tester.stop();

    // Test volume
    await tester.testVolume('0.5');
    await tester.testVolume('1.0');

    // Test release mode: loop
    await tester.testReleaseMode(ReleaseMode.loop);
    await tester.pump(const Duration(seconds: 3));
    await tester.stop();
    await tester.testReleaseMode(ReleaseMode.stop, isResume: false);
    await tester.pumpAndSettle();

    // Reset to media player
    await tester.testPlayerMode(PlayerMode.mediaPlayer);
    await tester.pumpAndSettle();
  }

  if (!audioSourceTestData.isLiveStream &&
      audioSourceTestData.duration! < const Duration(seconds: 2)) {
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    // FIXME(gustl22): Android provides no position for samples shorter
    //  than 0.5 seconds.
    if (features.hasReleaseModeLoop &&
        !(isAndroid &&
            audioSourceTestData.duration! < const Duration(seconds: 1))) {
      await tester.testReleaseMode(ReleaseMode.loop);
      await tester.pump(const Duration(seconds: 3));
      // Check if sound has started playing.
      await tester.doInStreamsTab((tester) async {
        await tester.testPosition(
          Duration.zero,
          matcher: (Duration? position) =>
              greaterThan(position ?? Duration.zero),
        );
      });
      await tester.stop();
      await tester.testReleaseMode(ReleaseMode.stop, isResume: false);
      await tester.pumpAndSettle();
    }

    if (features.hasReleaseModeRelease) {
      await tester.testReleaseMode(ReleaseMode.release);
      await tester.pump(const Duration(seconds: 3));
      // No need to call stop, as it should be released by now.
      // Ensure source was released by checking `position == null`.
      await tester.doInStreamsTab((tester) async {
        await tester.testPosition(null);
      });

      // Reinitialize source
      await tester.tap(find.byKey(const Key('sourcesTab')));
      await tester.pumpAndSettle();
      await tester.testSource(audioSourceTestData.sourceKey);

      await tester.tap(find.byKey(const Key('controlsTab')));
      await tester.pumpAndSettle();

      await tester.testReleaseMode(ReleaseMode.stop, isResume: false);
      await tester.pumpAndSettle();

      // TODO(Gustl22): test 'control-release'
    }
  }
}

extension ControlsWidgetTester on WidgetTester {
  Future<void> resume() async {
    await scrollToAndTap(const Key('control-resume'));
    await pump();
  }

  Future<void> stop() async {
    final st = StackTrace.current.toString();

    await scrollToAndTap(const Key('control-stop'));
    await waitOneshot(const Key('toast-player-stopped-0'), stackTrace: st);
    await pump();
  }

  Future<void> testVolume(
    String volume, {
    Duration stopDuration = const Duration(seconds: 1),
  }) async {
    printWithTimeOnFailure('Test Volume: $volume');
    await scrollToAndTap(Key('control-volume-$volume'));
    await resume();
    await pump(stopDuration);
    await stop();
  }

  Future<void> testBalance(
    String balance, {
    Duration stopDuration = const Duration(seconds: 1),
  }) async {
    printWithTimeOnFailure('Test Balance: $balance');
    await scrollToAndTap(Key('control-balance-$balance'));
    await resume();
    await pump(stopDuration);
    await stop();
  }

  Future<void> testRate(
    String rate, {
    Duration stopDuration = const Duration(seconds: 2),
  }) async {
    printWithTimeOnFailure('Test Rate: $rate');
    await scrollToAndTap(Key('control-rate-$rate'));
    await resume();
    await pump(stopDuration);
    await stop();
  }

  Future<void> testSeek(
    String seek, {
    bool isResume = true,
  }) async {
    printWithTimeOnFailure('Test Seek: $seek');
    final st = StackTrace.current.toString();

    await scrollToAndTap(Key('control-seek-$seek'));

    await waitOneshot(const Key('toast-seek-complete-0'), stackTrace: st);

    if (isResume) {
      await resume();
    }
  }

  Future<void> testPlayerMode(PlayerMode mode) async {
    printWithTimeOnFailure('Test Player Mode: ${mode.name}');
    final st = StackTrace.current.toString();

    await scrollToAndTap(Key('control-player-mode-${mode.name}'));
    await waitFor(
      () async => expectEnumToggleHasSelected(
        const Key('control-player-mode'),
        matcher: equals(mode),
      ),
      stackTrace: st,
    );
  }

  Future<void> testReleaseMode(ReleaseMode mode, {bool isResume = true}) async {
    printWithTimeOnFailure('Test Release Mode: ${mode.name}');
    final st = StackTrace.current.toString();

    await scrollToAndTap(Key('control-release-mode-${mode.name}'));
    await waitFor(
      () async => expectEnumToggleHasSelected(
        const Key('control-release-mode'),
        matcher: equals(mode),
      ),
      stackTrace: st,
    );
    if (isResume) {
      await resume();
    }
  }

  Future<void> doInStreamsTab(
    Future<void> Function(WidgetTester tester) foo,
  ) async {
    await tap(find.byKey(const Key('streamsTab')));
    await pump();

    await foo(this);

    await tap(find.byKey(const Key('controlsTab')));
    await pump();
  }
}
