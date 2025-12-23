import 'dart:async';
import 'dart:io';

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
final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

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

  bool isLocalServerAvailable = false;
  // Check if local server is available
  if (!kIsWeb) {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 1);
      final request = await client.getUrl(Uri.parse('http://localhost:8080'));
      final response = await request.close();
      isLocalServerAvailable = response.statusCode >= 200;
      client.close();
    } catch (_) {
      isLocalServerAvailable = false;
    }
  }
  print('Local server available: $isLocalServerAvailable');

  group('Platform method channel', () {
    late AudioplayersPlatformInterface platform;
    late String playerId;

    setUp(() async {
      platform = AudioplayersPlatformInterface.instance;
      playerId = 'somePlayerId';
      await platform.create(playerId);
    });

    tearDown(() async {
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
      skip: isAndroid || (!isLocalServerAvailable && nonExistentUrlTestData.source is UrlSource && (nonExistentUrlTestData.source as UrlSource).url.contains('localhost')),
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
            (isLinux && td.source == m3u8UrlTestData.source) ||
            (!isLocalServerAvailable && td.source is UrlSource && (td.source as UrlSource).url.contains('localhost')),
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
      for (var i = 0; i < 2; i++) {
        await tester.prepareSource(
          playerId: playerId,
          platform: platform,
          testData: wavUrl1TestData,
          // We don't expect the duration event is emitted again,
          // if the same source is set twice
          waitForDurationEvent: i == 0,
        );
      }
    });
  });

  group('Platform event channel', () {
    late AudioplayersPlatformInterface platform;
    late String playerId;

    setUp(() async {
      platform = AudioplayersPlatformInterface.instance;
      playerId = 'somePlayerId';
      await platform.create(playerId);
    });

    tearDown(() async {
      await platform.dispose(playerId);
    });

    for (final td in audioTestDataList) {
      if (features.hasDurationEvent && !td.isLiveStream) {
        testWidgets(
          '#durationEvent ${td.source}',
          (tester) async {
            // Wait for duration before event is emitted.
            final durationFuture = tester
                .getDurationFromEvent(
                  playerId: playerId,
                  platform: platform,
                )
                .timeout(_defaultTimeout);

            await tester.prepareSource(
              playerId: playerId,
              platform: platform,
              testData: td,
              waitForDurationEvent: false,
            );

            expect(
              await durationFuture,
              (Duration? actual) => durationRangeMatcher(
                actual,
                td.duration,
                deviation:
                    Duration(milliseconds: td.isVBR || isWindows ? 100 : 1),
              ),
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

          final eventStream = platform.getEventStream(playerId);
          final completeFuture = eventStream.firstWhere(
            (event) => event.eventType == AudioEventType.complete,
          );

          await platform.resume(playerId);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          await completeFuture.timeout(_defaultTimeout);
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
      final logFuture = platform
          .getEventStream(playerId)
          .firstWhere((event) => event.eventType == AudioEventType.log)
          .then((event) => event.logMessage);

      await platform.emitLog(playerId, 'SomeLog');

      expect(await logFuture, 'SomeLog');
    });

    testWidgets('Emit global platform log', (tester) async {
      final global = GlobalAudioplayersPlatformInterface.instance;
      final logCompleter = Completer<Object>();

      /* final eventStreamSub = */
      global
          .getGlobalEventStream()
          .where((event) => event.eventType == GlobalAudioEventType.log)
          .map((event) => event.logMessage)
          .listen(logCompleter.complete, onError: logCompleter.completeError);

      await global.emitGlobalLog('SomeGlobalLog');

      final log = await logCompleter.future;
      expect(log, 'SomeGlobalLog');
      // FIXME: cancelling the global event stream leads to
      // MissingPluginException on Android, if dispose app afterwards
      // await eventStreamSub.cancel();
    });

    testWidgets('Emit platform error', (tester) async {
      final errorCompleter = Completer<Object>();
      final eventStreamSub = platform
          .getEventStream(playerId)
          .listen((_) {}, onError: errorCompleter.complete);

      await platform.emitError(
        playerId,
        'SomeErrorCode',
        'SomeErrorMessage',
      );

      final exception = await errorCompleter.future;
      expect(exception, isInstanceOf<PlatformException>());
      final platformException = exception as PlatformException;
      expect(platformException.code, 'SomeErrorCode');
      expect(platformException.message, 'SomeErrorMessage');
      await eventStreamSub.cancel();
    });

    testWidgets('Emit global platform error', (tester) async {
      final global = GlobalAudioplayersPlatformInterface.instance;
      final errorCompleter = Completer<Object>();

      /* final eventStreamSub = */
      global
          .getGlobalEventStream()
          .listen((_) {}, onError: errorCompleter.complete);

      await global.emitGlobalError(
        'SomeGlobalErrorCode',
        'SomeGlobalErrorMessage',
      );
      final exception = await errorCompleter.future;
      expect(exception, isInstanceOf<PlatformException>());
      final platformException = exception as PlatformException;
      expect(platformException.code, 'SomeGlobalErrorCode');
      expect(platformException.message, 'SomeGlobalErrorMessage');
      // FIXME: cancelling the global event stream leads to
      // MissingPluginException on Android, if dispose app afterwards
      // await eventStreamSub.cancel();
    });
  });
}

extension on WidgetTester {
  Future<void> prepareSource({
    required String playerId,
    required AudioplayersPlatformInterface platform,
    required LibSourceTestData testData,
    bool waitForDurationEvent = true,
  }) async {
    final Future<void>? durationFuture;

    if (waitForDurationEvent &&
        testData.duration != null &&
        canDetermineDuration(testData)) {
      // Need to wait for the duration event,
      // otherwise it gets fired/received after the test has ended,
      // and therefore then ends up being received in the next test.
      durationFuture = getDurationFromEvent(
        playerId: playerId,
        platform: platform,
      );
    } else {
      durationFuture = null;
    }

    final eventStream = platform.getEventStream(playerId);
    final preparedCompleter = Completer<void>();
    final subscription = eventStream.listen(
      (event) {
        if (event.eventType == AudioEventType.prepared &&
            (event.isPrepared ?? false)) {
          preparedCompleter.complete();
        }
      },
      onError: preparedCompleter.completeError,
    );

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
    try {
      final start = DateTime.now();
      while (!preparedCompleter.isCompleted) {
        if (DateTime.now().difference(start) > _defaultTimeout) {
          throw TimeoutException('Timeout waiting for prepared event');
        }
        
        // Windows specific: The C++ plugin requires active method calls to 
        // flush the event queue (ProcessPendingTasks).
        if (isWindows) {
          // This call is harmless but triggers the native event dispatch
          try {
            await platform.getCurrentPosition(playerId);
          } catch (_) {}
        }
        
        // Wait a bit to let the platform process events
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      await preparedCompleter.future;
      await setSourceFuture;
    } finally {
      await subscription.cancel();
    }
    if (durationFuture != null) {
      await durationFuture;
    }
  }

  Future<Duration?> getDurationFromEvent({
    required String playerId,
    required AudioplayersPlatformInterface platform,
  }) async {
    final eventStream = platform.getEventStream(playerId);
    final durationFuture = eventStream
        .firstWhere(
          (event) => event.eventType == AudioEventType.duration,
        )
        .then((event) => event.duration);
    return durationFuture.timeout(_defaultTimeout);
  }

  Future<void> expectSettingSourceFailure({
    required Future<void> future,
  }) async {
    try {
      await future;
      fail('PlatformException not thrown');
    } on PlatformException catch (e) {
      // Allow both old and new safe error messages
      expect(
        e.message, 
        anyOf(
          startsWith('Failed to set source.'),
          contains('System error'),
        )
      );
    }
  }
}
