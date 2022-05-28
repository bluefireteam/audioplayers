import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers_example/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final PlatformFeatures features = kIsWeb
    ? PlatformFeatures(
        hasBytesSource: false,
        hasLowLatency: false,
        hasReleaseMode: false,
        hasSeek: false,
        hasDuckAudio: false,
        hasRespectSilence: false,
        hasStayAwake: false,
        hasRecordingActive: false,
        hasPlayingRoute: false,
        hasDurationEvent: false,
        hasCompletionEvent: false,
        hasErrorEvent: false,
      )
    : Platform.isAndroid
        ? PlatformFeatures(
            hasRecordingActive: false,
          )
        : Platform.isIOS
            ? PlatformFeatures(
                hasBytesSource: false,
                hasLowLatency: false,
                hasDuckAudio: false,
              )
            : Platform.isMacOS
                ? PlatformFeatures(
                    hasBytesSource: false,
                    hasLowLatency: false,
                    hasDuckAudio: false,
                    hasRespectSilence: false,
                    hasStayAwake: false,
                    hasRecordingActive: false,
                    hasPlayingRoute: false,
                  )
                : Platform.isLinux
                    ? PlatformFeatures(
                        hasBytesSource: false,
                        hasLowLatency: false,
                        hasMp3Duration: false,
                        hasDuckAudio: false,
                        hasRespectSilence: false,
                        hasStayAwake: false,
                        hasRecordingActive: false,
                        hasPlayingRoute: false,
                      )
                    : Platform.isWindows
                        ? PlatformFeatures(
                            hasBytesSource: false,
                            hasLowLatency: false,
                            hasDuckAudio: false,
                            hasRespectSilence: false,
                            hasStayAwake: false,
                            hasRecordingActive: false,
                            hasPlayingRoute: false,
                          )
                        : PlatformFeatures();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app is launched', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(
        find.text('Remote URL WAV 1 - coins.wav'),
        findsOneWidget,
      );
    });
  });

  group('test functionality of sources', () {
    final audioTestDataList = [
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-wav-1',
          duration: const Duration(milliseconds: 451),
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-wav-2',
          duration: const Duration(seconds: 1, milliseconds: 068),
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-mp3-1',
          duration: const Duration(minutes: 3, seconds: 30, milliseconds: 77),
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-mp3-2',
          duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-m3u8',
          duration: const Duration(),
        ),
      if (features.hasAssetSource)
        SourceTestData(
          sourceKey: 'asset-wav',
          duration: const Duration(seconds: 1, milliseconds: 068),
        ),
      if (features.hasAssetSource)
        SourceTestData(
          sourceKey: 'asset-mp3',
          duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
        ),
      if (features.hasBytesSource)
        SourceTestData(
          sourceKey: 'bytes-local',
          duration: const Duration(seconds: 1, milliseconds: 068),
        ),
      if (features.hasBytesSource)
        SourceTestData(
          sourceKey: 'bytes-remote',
          duration: const Duration(minutes: 3, seconds: 30, milliseconds: 76),
        ),
    ];

    for (final audioSourceTestData in audioTestDataList) {
      testWidgets('test source $audioSourceTestData',
          (WidgetTester tester) async {
        Future<void> testDuration() async {
          await tester.tap(find.byKey(const Key('getDuration')));
          await tester.pumpAndSettle();
          expectWidgetHasText(
            const Key('durationText'),
            // Precision for duration:
            // Android: hundredth of a second
            // Windows: second
            matcher: contains(
              audioSourceTestData.duration.toString().substring(0, 8),
            ),
          );
        }

        Future<void> testPosition(String positionStr) async {
          await tester.tap(find.byKey(const Key('getPosition')));
          await tester.pumpAndSettle();
          expectWidgetHasText(
            const Key('positionText'),
            matcher: contains(positionStr),
          );
        }

        Future<void> testOnDuration() async {
          if (features.hasDurationEvent) {
            expectWidgetHasText(
              const Key('onDurationText'),
              matcher: contains(
                'Stream Duration: ${audioSourceTestData.duration.toString().substring(0, 8)}',
              ),
            );
          }
        }

        Future<void> testOnPosition(String positionStr) async {
          if (features.hasPositionEvent) {
            expectWidgetHasText(
              const Key('onPositionText'),
              matcher: contains('Stream Position: $positionStr'),
            );
          }
        }

        app.main();
        await tester.pumpAndSettle();

        // Sources
        await tester.tap(find.byKey(const Key('sourcesTab')));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(Key('setSource-${audioSourceTestData.sourceKey}')),
        );

        await tester.tap(find.byKey(const Key('sourcesTab')));

        await tester.pumpAndSettle();

        await waitFor(
          () => expectWidgetHasText(
            const Key('isSourceSet'),
            matcher: equals('Source is set'),
          ),
          tester,
        );

        // Streams
        await tester.tap(find.byKey(const Key('streamsTab')));
        await tester.pumpAndSettle();

        final isAudioStream = audioSourceTestData.sourceKey.contains('m3u8');
        // Stream position is tracked as soon as source is loaded
        if (!isAudioStream) {
          // Display position before playing
          await testPosition('0:00:00.000000');
        }

        // MP3 duration is estimated: https://bugzilla.gnome.org/show_bug.cgi?id=726144
        final isImmediateDurationSupported = features.hasMp3Duration ||
            !audioSourceTestData.sourceKey.contains('mp3');

        if (!isAudioStream && isImmediateDurationSupported) {
          // Display duration before playing
          await testDuration();
        }

        if (kIsWeb) {
          // Cannot play on web: https://developer.chrome.com/blog/autoplay/
          // Need to add flag: --autoplay-policy=no-user-gesture-required
          // See https://github.com/flutter/flutter/issues/65575
          return;
        }

        await tester.tap(find.byKey(const Key('play_button')));
        await tester.pumpAndSettle();

        // Test if onDurationText is set immediately.
        if (!isAudioStream && isImmediateDurationSupported) {
          await testOnDuration();
        }

        const sampleDuration = Duration(seconds: 2);
        await tester.pump(sampleDuration);

        if (!isAudioStream) {
          // Test if position is set.
          // Cannot test more precisely as initialization takes some time and
          // a longer sampleDuration would decelerate length of overall tests.
          // TODO test position update in seek mode.
          await testOnPosition('0:00:0');
        }

        // Display duration after end / stop (some samples are shorter than sampleDuration, so this test would fail)
        // TODO Not possible at the moment (shows duration of 0)
        // await testDuration();
        // await testOnDuration();

        await tester.tap(find.byKey(const Key('pause_button')));
        await tester.tap(find.byKey(const Key('stop_button')));

        // Controls
        // TODO test volume, rate, player mode, release mode, seek
        // await tester.tap(find.byKey(const Key('controlsTab')));
        // await tester.pumpAndSettle();

        // await tester.tap(find.byKey(const Key('control-resume')));
        // await Future<void>.delayed(const Duration(seconds: 1));

        // Audio context
        // TODO test generic flags
        // await tester.tap(find.byKey(const Key('audioContextTab')));
        // await tester.pumpAndSettle();

        // Logs
        // TODO may test logs
        // await tester.tap(find.byKey(const Key('loggerTab')));
        // await tester.pumpAndSettle();
      });
    }
  });

  group('play multiple sources', () {
    // TODO play sources simultaneously
    // TODO play one source after another
  });
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

Future<void> waitFor(void Function() testExpectation, WidgetTester tester) =>
    waitUntil(
      () async {
        try {
          await tester.pumpAndSettle();
          testExpectation();
          return true;
        } on TestFailure {
          return false;
        }
      },
    );

/// Waits until the [condition] returns true
/// Will raise a complete with a [TimeoutException] if the
/// condition does not return true with the timeout period.
/// Copied from: https://github.com/jonsamwell/flutter_gherkin/blob/02a4af91d7a2512e0a4540b9b1ab13e36d5c6f37/lib/src/flutter/utils/driver_utils.dart#L86
Future<void> waitUntil(
  Future<bool> Function() condition, {
  Duration? timeout = const Duration(seconds: 15),
  Duration? pollInterval = const Duration(milliseconds: 500),
}) async {
  return Future.microtask(
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
}

enum UserPlatform {
  android,
  fuchsia,
  iOS,
  linux,
  macOS,
  windows,
  web,
}

class SourceTestData {
  String sourceKey;

  Duration duration;

  SourceTestData({required this.sourceKey, required this.duration});

  @override
  String toString() {
    return 'SourceTestData(sourceKey: $sourceKey, duration: $duration)';
  }
}

class PlatformFeatures {
  final bool hasUrlSource;
  final bool hasAssetSource;
  final bool hasBytesSource;

  final bool hasLowLatency; // Not yet tested
  final bool hasReleaseMode; // Not yet tested
  final bool hasVolume; // Not yet tested
  final bool hasSeek; // Not yet tested
  final bool hasMp3Duration; // Not yet tested

  final bool hasPlaybackRate; // Not yet tested
  final bool hasDuckAudio; // Not yet tested
  final bool hasRespectSilence; // Not yet tested
  final bool hasStayAwake; // Not yet tested
  final bool hasRecordingActive; // Not yet tested
  final bool hasPlayingRoute; // Not yet tested

  final bool hasDurationEvent;
  final bool hasPositionEvent;
  final bool hasCompletionEvent; // Not yet tested
  final bool hasErrorEvent; // Not yet tested

  PlatformFeatures({
    this.hasUrlSource = true,
    this.hasAssetSource = true,
    this.hasBytesSource = true,
    this.hasLowLatency = true,
    this.hasReleaseMode = true,
    this.hasMp3Duration = true,
    this.hasVolume = true,
    this.hasSeek = true,
    this.hasPlaybackRate = true,
    this.hasDuckAudio = true,
    this.hasRespectSilence = true,
    this.hasStayAwake = true,
    this.hasRecordingActive = true,
    this.hasPlayingRoute = true,
    this.hasDurationEvent = true,
    this.hasPositionEvent = true,
    this.hasCompletionEvent = true,
    this.hasErrorEvent = true,
  });
}
