import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'lib/lib_source_test_data.dart';
import 'platform_features.dart';
import 'source_test_data.dart';
import 'test_utils.dart';

const _defaultTimeout = Duration(seconds: 30);

final isLinux = !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool canDetermineDuration(SourceTestData td) {
  // TODO(gustl22): cannot determine duration for VBR on Linux
  // FIXME(gustl22): duration event is not emitted for short duration
  // WAV on Linux (only platform tests, may be a race condition).
  if (td.duration == null) {
    return true;
  }
  if (isLinux) {
    return !(td.isVBR || td.duration! < const Duration(seconds: 5));
  }
  return true;
}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final features = PlatformFeatures.instance();
  final audioTestDataList = await getAudioTestDataList();

  group('Platform method channel', () {
    late AudioplayersPlatformInterface platform;
    late String playerId;
    late Stream<AudioEvent> eventStream;

    setUp(() async {
      platform = AudioplayersPlatformInterface.instance;
      playerId = 'somePlayerId';
      await platform.create(playerId);
      eventStream = platform.getEventStream(playerId);
    });

    tearDown(() async {
      // Tear down is executed AFTER all expectations are fullfilled
      await platform.dispose(playerId);
    });

    testWidgets(
      'Throw PlatformException, when loading invalid file',
      (tester) async {
        // Throws PlatformException instead of returning prepared event.
        await tester.expectSettingSourceFailure(
          future: tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: invalidAssetTestData,
          ),
        );

        if (isLinux) {
          // Linux throws a second failure event for invalid files.
          // If not caught, it would be randomly thrown in the following tests.
          final nextEvent = platform.getEventStream(playerId).first;
          await tester.expectSettingSourceFailure(future: nextEvent);
        }
      },
    );

    testWidgets(
      'Throw PlatformException, when loading non existent file',
      (tester) async {
        // Throws PlatformException instead of returning prepared event.
        await tester.expectSettingSourceFailure(
          future: tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: nonExistentUrlTestData,
          ),
        );
      },
      // FIXME(Gustl22): for some reason, the error propagated back from the
      //  Android MediaPlayer is only triggered, when the timeout has reached,
      //  although the error is emitted immediately.
      //  Further, the other future is not fulfilled and then mysteriously
      //  failing in later tests.
      //  The feature works with audioplayers_android_exo.
      skip: testIsAndroidMediaPlayer,
    );

    testWidgets('#create and #dispose', (tester) async {
      await platform.dispose(playerId);

      try {
        // Call method after player has been released should throw a
        // PlatformException
        await platform.stop(playerId);
        fail('PlatformException not thrown');
      } on PlatformException catch (e) {
        expect(
          e.message,
          'Player has not yet been created or has already been disposed.',
        );
      }

      // Create player again, so it can be disposed in tearDown
      await platform.create(playerId);
    });

    for (final td in audioTestDataList) {
      testWidgets(
        '#setSource #getPosition and #getDuration ${td.source}',
        (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );
          if (!td.isLiveStream) {
            // Live stream position is not aligned yet.
            expect(await platform.getCurrentPosition(playerId), 0);
          }
          final durationMs = await platform.getDuration(playerId);
          expect(
            durationMs != null ? Duration(milliseconds: durationMs) : null,
            // TODO(gustl22): once duration is always null for streams,
            //  then can remove fallback for Duration.zero
            (Duration? actual) => durationRangeMatcher(
              actual ?? Duration.zero,
              td.duration ?? Duration.zero,
              deviation: Duration(milliseconds: td.isVBR ? 100 : 1),
            ),
          );
        },
        // FIXME(gustl22): determines wrong initial position for m3u8 on Linux
        skip: !canDetermineDuration(td) ||
            isLinux && td.source == m3u8UrlTestData.source,
      );
    }

    if (features.hasVolume) {
      for (final td in audioTestDataList) {
        testWidgets('#volume ${td.source}', (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );
          for (final volume in [0.0, 0.5, 1.0]) {
            await platform.setVolume(playerId, volume);
            await platform.resume(playerId);
            await tester.pump(const Duration(seconds: 1));
            await platform.stop(playerId);
          }
          // May check native volume here
        });
      }
    }

    if (features.hasBalance) {
      for (final td in audioTestDataList) {
        testWidgets('#balance ${td.source}', (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );
          for (final balance in [-1.0, 0.0, 1.0]) {
            await platform.setBalance(playerId, balance);
            await platform.resume(playerId);
            await tester.pump(const Duration(seconds: 1));
            await platform.stop(playerId);
          }
          // May check native balance here
        });
      }
    }

    for (final td in audioTestDataList) {
      if (features.hasPlaybackRate && !td.isLiveStream) {
        testWidgets('#playbackRate ${td.source}', (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );
          for (final playbackRate in [0.5, 1.0, 2.0]) {
            await platform.setPlaybackRate(playerId, playbackRate);
            await platform.resume(playerId);
            await tester.pump(const Duration(seconds: 1));
            await platform.stop(playerId);
          }
          // May check native playback rate here
        });
      }
    }

    testWidgets('Avoid resume on setting playbackRate (#468)', (tester) async {
      await tester.prepareSource(
        playerId: playerId,
        platform: platform,
        testData: mp3Url1TestData,
      );
      await platform.setPlaybackRate(playerId, 2.0);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(await platform.getCurrentPosition(playerId), 0);
    });

    for (final td in audioTestDataList) {
      if (features.hasSeek && !td.isLiveStream) {
        testWidgets('#seek with millisecond precision ${td.source}',
            (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );

          final eventStream = platform.getEventStream(playerId);
          final seekCompleter = Completer<void>();
          final onSeekSub = eventStream
              .where((event) => event.eventType == AudioEventType.seekComplete)
              .listen(
                (_) => seekCompleter.complete(),
                onError: seekCompleter.completeError,
              );
          await platform.seek(playerId, const Duration(milliseconds: 22));
          await seekCompleter.future.timeout(_defaultTimeout);
          await onSeekSub.cancel();
          final positionMs = await platform.getCurrentPosition(playerId);
          expect(
            positionMs != null ? Duration(milliseconds: positionMs) : null,
            (Duration? actual) => durationRangeMatcher(
              actual,
              const Duration(milliseconds: 22),
              deviation: const Duration(milliseconds: 1),
            ),
          );
        });
      }
    }

    for (final td in audioTestDataList) {
      if (features.hasReleaseModeLoop &&
          !td.isLiveStream &&
          td.duration! < const Duration(seconds: 2)) {
        testWidgets('#ReleaseMode.loop ${td.source}', (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );
          await platform.setReleaseMode(playerId, ReleaseMode.loop);
          await platform.resume(playerId);
          await tester.pump(const Duration(seconds: 3));
          await platform.stop(playerId);

          // May check number of loops here
        });
      }
    }

    for (final td in audioTestDataList) {
      if (features.hasReleaseModeRelease && !td.isLiveStream) {
        testWidgets('#ReleaseMode.release ${td.source}', (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );
          await platform.setReleaseMode(playerId, ReleaseMode.release);
          await platform.resume(playerId);
          if (td.duration! < const Duration(seconds: 2)) {
            await tester.pumpAndSettle(const Duration(seconds: 3));
            // No need to call stop, as it should be released by now
          } else {
            await tester.pumpAndSettle(const Duration(seconds: 1));
            await platform.stop(playerId);
          }
          // TODO(Gustl22): test if source was released
          expect(await platform.getDuration(playerId), null);
          expect(await platform.getCurrentPosition(playerId), null);
        });
      }
    }

    for (final td in audioTestDataList) {
      testWidgets('#release ${td.source}', (tester) async {
        await tester.prepareSource(
          playerId: playerId,
          platform: platform,
          testData: td,
        );
        await tester.pump(const Duration(seconds: 1));
        await platform.release(playerId);
        // TODO(Gustl22): test if source was released
        // Check if position & duration is zero after play & release
        expect(await platform.getDuration(playerId), null);
        expect(await platform.getCurrentPosition(playerId), null);
      });
    }

    testWidgets('Set same source twice (#1520)', (tester) async {
      final td = wavUrl1TestData;
      for (var i = 0; i < 2; i++) {
        if (i == 0) {
          // We don't expect the duration event is emitted again,
          // if the same source is set twice
          tester.expectDurationInStream(
            eventStream,
            (Duration? actual) => actual != null,
          );
        }

        await tester.prepareSource(
          playerId: playerId,
          platform: platform,
          testData: td,
        );
      }
    });
  });

  group('Platform event channel', () {
    late AudioplayersPlatformInterface platform;
    late String playerId;
    late Stream<AudioEvent> eventStream;

    setUp(() async {
      platform = AudioplayersPlatformInterface.instance;
      playerId = 'somePlayerId';
      await platform.create(playerId);
      eventStream = platform.getEventStream(playerId);
    });

    tearDown(() async {
      // Tear down is executed AFTER all expectations are fullfilled
      await platform.dispose(playerId);
    });

    for (final td in audioTestDataList) {
      if (features.hasDurationEvent && !td.isLiveStream) {
        testWidgets(
          '#durationEvent ${td.source}',
          (tester) async {
            // Wait for duration before event is emitted.
            tester.expectDurationInStream(
              eventStream,
              (Duration? actual) => durationRangeMatcher(
                actual,
                td.duration,
                deviation: Duration(
                  milliseconds: td.isVBR || isWindows ? 100 : 1,
                ),
              ),
            );

            await tester.prepareSource(
              playerId: playerId,
              platform: platform,
              testData: td,
            );
          },
          skip: !canDetermineDuration(td),
        );
      }
    }

    for (final td in audioTestDataList) {
      if (!td.isLiveStream && td.duration! < const Duration(seconds: 2)) {
        testWidgets('#completeEvent ${td.source}', (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );

          expect(
            eventStream.map((event) => event.eventType),
            emitsThrough(AudioEventType.complete),
          );

          await platform.resume(playerId);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        });
      }
    }

    testWidgets('Listen and cancel twice', (tester) async {
      final eventStream = platform.getEventStream(playerId);
      for (var i = 0; i < 2; i++) {
        final eventSub = eventStream.listen(null);
        await eventSub.cancel();
      }
    });

    testWidgets('Emit platform log', (tester) async {
      final eventStream = platform.getEventStream(playerId);
      expect(
        eventStream,
        emitsThrough(
          const AudioEvent(
            eventType: AudioEventType.log,
            logMessage: 'SomeLog',
          ),
        ),
      );
      await platform.emitLog(playerId, 'SomeLog');
    });

    testWidgets('Emit global platform log', (tester) async {
      final global = GlobalAudioplayersPlatformInterface.instance;

      final globalEventStream = global.getGlobalEventStream();
      expect(
        globalEventStream,
        emitsThrough(
          const GlobalAudioEvent(
            eventType: GlobalAudioEventType.log,
            logMessage: 'SomeGlobalLog',
          ),
        ),
      );

      await global.emitGlobalLog('SomeGlobalLog');
    });

    testWidgets('Emit platform error', (tester) async {
      final eventStream = platform.getEventStream(playerId);
      expect(
        eventStream,
        emitsThrough(
          emitsError(
            isA<PlatformException>()
                .having(
                  (PlatformException e) => e.code,
                  'code',
                  'SomeErrorCode',
                )
                .having(
                  (PlatformException e) => e.message,
                  'message',
                  'SomeErrorMessage',
                ),
          ),
        ),
      );

      await platform.emitError(
        playerId,
        'SomeErrorCode',
        'SomeErrorMessage',
      );
    });

    testWidgets('Emit global platform error', (tester) async {
      final global = GlobalAudioplayersPlatformInterface.instance;
      final globalEventStream = global.getGlobalEventStream();
      expect(
        globalEventStream,
        emitsThrough(
          emitsError(
            isA<PlatformException>()
                .having(
                  (PlatformException e) => e.code,
                  'code',
                  'SomeGlobalErrorCode',
                )
                .having(
                  (PlatformException e) => e.message,
                  'message',
                  'SomeGlobalErrorMessage',
                ),
          ),
        ),
      );

      await global.emitGlobalError(
        'SomeGlobalErrorCode',
        'SomeGlobalErrorMessage',
      );
    });
  });
}

extension on WidgetTester {
  Future<void> prepareSource({
    required String playerId,
    required AudioplayersPlatformInterface platform,
    required LibSourceTestData testData,
  }) async {
    final eventStream = platform.getEventStream(playerId);
    final preparedFuture = eventStream
        .firstWhere(
          (event) =>
              event.eventType == AudioEventType.prepared &&
              (event.isPrepared ?? false),
        )
        .timeout(_defaultTimeout);

    Future<void> setSource(Source source) async {
      if (source is UrlSource) {
        return platform.setSourceUrl(playerId, source.url);
      } else if (source is AssetSource) {
        final cachePath = await AudioCache.instance.loadPath(source.path);
        return platform.setSourceUrl(playerId, cachePath, isLocal: true);
      } else if (source is BytesSource) {
        return platform.setSourceBytes(playerId, source.bytes);
      } else {
        throw 'Unknown source type: ${source.runtimeType}';
      }
    }

    // Need to await the setting the source to propagate immediate errors.
    final setSourceFuture = setSource(testData.source);

    // Wait simultaneously to ensure all errors are propagated through the same
    // future.
    await Future.wait([setSourceFuture, preparedFuture]);
  }

  void expectDurationInStream(Stream<AudioEvent> eventStream, dynamic matcher) {
    expect(
      eventStream,
      emitsThrough(
        isA<AudioEvent>()
            .having((e) => e.eventType, 'eventType', AudioEventType.duration)
            .having((e) => e.duration, 'duration', matcher),
      ),
    );
  }

  Future<void> expectSettingSourceFailure({
    required Future<void> future,
  }) async {
    try {
      await future;
      fail('PlatformException not thrown');
    } on PlatformException catch (e) {
      expect(e.message, startsWith('Failed to set source.'));
    }
  }
}
