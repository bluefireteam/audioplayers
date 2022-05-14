import 'dart:io' show Platform;

import 'package:audioplayers_example/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final PlatformFeatures features = kIsWeb
    ? PlatformFeatures(
        hasUrlSource: true,
        hasAssetSource: true,
        hasMp3Duration: true,
        hasVolume: true,
        hasPlaybackRate: true,
        hasPositionEvent: true,
      )
    : Platform.isAndroid
        ? PlatformFeatures(
            hasUrlSource: true,
            hasAssetSource: true,
            hasBytesSource: true,
            hasLowLatency: true,
            hasReleaseMode: true,
            hasMp3Duration: true,
            hasVolume: true,
            hasSeek: true,
            hasPlaybackRate: true,
            hasDuckAudio: true,
            hasRespectSilence: true,
            hasStayAwake: true,
            hasPlayingRoute: true,
            hasDurationEvent: true,
            hasPositionEvent: true,
            hasCompletionEvent: true,
            hasErrorEvent: true,
          )
        : Platform.isIOS
            ? PlatformFeatures(
                hasUrlSource: true,
                hasAssetSource: true,
                hasReleaseMode: true,
                hasMp3Duration: true,
                hasVolume: true,
                hasSeek: true,
                hasPlaybackRate: true,
                hasRespectSilence: true,
                hasStayAwake: true,
                hasRecordingActive: true,
                hasPlayingRoute: true,
                hasDurationEvent: true,
                hasPositionEvent: true,
                hasCompletionEvent: true,
                hasErrorEvent: true,
              )
            : Platform.isMacOS
                ? PlatformFeatures(
                    hasUrlSource: true,
                    hasAssetSource: true,
                    hasReleaseMode: true,
                    hasMp3Duration: true,
                    hasVolume: true,
                    hasSeek: true,
                    hasPlaybackRate: true,
                    hasDurationEvent: true,
                    hasPositionEvent: true,
                    hasCompletionEvent: true,
                    hasErrorEvent: true,
                  )
                : Platform.isLinux
                    ? PlatformFeatures(
                        hasUrlSource: true,
                        hasAssetSource: true,
                        hasReleaseMode: true,
                        hasVolume: true,
                        hasSeek: true,
                        hasPlaybackRate: true,
                        hasDurationEvent: true,
                        hasPositionEvent: true,
                        hasCompletionEvent: true,
                        hasErrorEvent: true,
                      )
                    : Platform.isWindows
                        ? PlatformFeatures(
                            hasUrlSource: true,
                            hasAssetSource: true,
                            hasReleaseMode: true,
                            hasMp3Duration: true,
                            hasVolume: true,
                            hasSeek: true,
                            hasPlaybackRate: true,
                            hasDurationEvent: true,
                            hasPositionEvent: true,
                            hasCompletionEvent: true,
                            hasErrorEvent: true,
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
          duration: const Duration(seconds: 1, milliseconds: 067),
        ),
      if (features.hasUrlSource)
        SourceTestData(
          sourceKey: 'url-remote-mp3-1',
          duration: const Duration(minutes: 3, seconds: 30, milliseconds: 76),
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
          duration: const Duration(seconds: 1, milliseconds: 067),
        ),
      if (features.hasAssetSource)
        SourceTestData(
          sourceKey: 'asset-mp3',
          duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
        ),
      if (features.hasBytesSource)
        SourceTestData(
          sourceKey: 'bytes-local',
          duration: const Duration(seconds: 1, milliseconds: 067),
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
          expect(
            find.byKeyAndText(
              const Key('durationText'),
              text: audioSourceTestData.duration.toString(),
            ),
            findsOneWidget,
          );
        }

        Future<void> testPosition(String positionStr) async {
          await tester.tap(find.byKey(const Key('getPosition')));
          await tester.pumpAndSettle();
          expect(
            find.byKeyAndText(
              const Key('positionText'),
              text: positionStr,
            ),
            findsOneWidget,
          );
        }

        Future<void> testOnDuration() async {
          if (features.hasDurationEvent) {
            expect(
              find.byKeyAndText(
                const Key('onDurationText'),
                text: 'Stream Duration: ${audioSourceTestData.duration}',
              ),
              findsOneWidget,
            );
          }
        }

        Future<void> testOnPosition(String positionStr) async {
          if (features.hasPositionEvent) {
            expect(
              find.byKeyAndText(
                const Key('onPositionText'),
                text: 'Stream Position: $positionStr',
              ),
              findsOneWidget,
            );
          }
        }

        app.main();
        await tester.pumpAndSettle();

        // Sources
        await tester.tap(find.byKey(const Key('sourcesTab')));
        await tester.pumpAndSettle();

        await tester
            .tap(find.byKey(Key('setSource-${audioSourceTestData.sourceKey}')));

        // Streams
        await tester.tap(find.byKey(const Key('streamsTab')));
        await tester.pumpAndSettle();

        // Stream position is tracked as soon as source is loaded
        if (!audioSourceTestData.sourceKey.contains('m3u8')) {
          // Display position before playing
          await testPosition('0:00:00.000000');
        }

        // MP3 duration is estimated: https://bugzilla.gnome.org/show_bug.cgi?id=726144
        final isImmediateDurationSupported = features.hasMp3Duration ||
            !audioSourceTestData.sourceKey.contains('mp3');

        if (isImmediateDurationSupported) {
          // Display duration before playing
          await testDuration();
        }

        await tester.tap(find.byKey(const Key('play_button')));
        await tester.pumpAndSettle();

        // Test if onDurationText is set immediately.
        if (isImmediateDurationSupported) {
          await testOnDuration();
        }

        const sampleDuration = Duration(seconds: 2);
        await tester.pump(sampleDuration);

        // Test if position is set.
        // Cannot test more precisely as initialization takes some time and
        // a longer sampleDuration would decelerate length of overall tests.
        // Better test position update in seek mode.
        await testOnPosition('0:00:0');

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
    // TODO simultaneously
    // TODO one after another
  });
}

extension on CommonFinders {
  Finder byKeyAndText(Key key,
      {required String text, bool skipOffstage = true}) {
    return find.byWidgetPredicate(
      (widget) {
        if (widget.key != key || widget is! Text) {
          return false;
        }
        if (widget.data != null && widget.data!.contains(text)) {
          return true;
        }
        return false;
      },
      skipOffstage: skipOffstage,
    );
  }
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
    this.hasUrlSource = false,
    this.hasAssetSource = false,
    this.hasBytesSource = false,
    this.hasLowLatency = false,
    this.hasReleaseMode = false,
    this.hasMp3Duration = false,
    this.hasVolume = false,
    this.hasSeek = false,
    this.hasPlaybackRate = false,
    this.hasDuckAudio = false,
    this.hasRespectSilence = false,
    this.hasStayAwake = false,
    this.hasRecordingActive = false,
    this.hasPlayingRoute = false,
    this.hasDurationEvent = false,
    this.hasPositionEvent = false,
    this.hasCompletionEvent = false,
    this.hasErrorEvent = false,
  });
}
