import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'lib/lib_source_test_data.dart';
import 'lib/lib_test_utils.dart';
import 'platform_features.dart';
import 'test_utils.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final features = PlatformFeatures.instance();
  final isLinux = !kIsWeb && Platform.isLinux;
  final audioTestDataList = await getAudioTestDataList();

  group('Logging', () {
    testWidgets('Emit platform log', (tester) async {
      final logCompleter = Completer<String>();

      const playerId = 'somePlayerId';
      final player = AudioPlayer(playerId: playerId);
      final onLogSub = player.onLog.listen(
        logCompleter.complete,
        onError: logCompleter.completeError,
      );

      await player.creatingCompleter.future;
      final platform = AudioplayersPlatformInterface.instance;
      await platform.emitLog(playerId, 'SomeLog');

      final log = await logCompleter.future;
      expect(log, 'SomeLog');
      await onLogSub.cancel();
      await tester.pumpLinux();
      await player.dispose();
    });

    testWidgets('Emit global platform log', (tester) async {
      final completer = Completer<String>();
      final eventStreamSub = AudioPlayer.global.onLog.listen(
        completer.complete,
        onError: completer.completeError,
      );

      final global = GlobalAudioplayersPlatformInterface.instance;
      await global.emitGlobalLog('SomeGlobalLog');

      final log = await completer.future;
      expect(log, 'SomeGlobalLog');
      await eventStreamSub.cancel();
    });
  });

  group('Errors', () {
    testWidgets(
      'Throw PlatformException, when loading invalid file',
      (tester) async {
        final player = AudioPlayer();
        try {
          await tester.pumpLinux();
          // Throws PlatformException via MethodChannel:
          await player.setSource(AssetSource(invalidAsset));
          fail('PlatformException not thrown');
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          expect(e, isInstanceOf<PlatformException>());
        }
        await tester.pumpLinux();
        await player.dispose();
      },
    );

    testWidgets(
      'Throw PlatformException, when loading non existent file',
      (tester) async {
        final player = AudioPlayer();
        try {
          await tester.pumpLinux();
          // Throws PlatformException via MethodChannel:
          await player.setSource(UrlSource('non_existent.txt'));
          fail('PlatformException not thrown');
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          expect(e, isInstanceOf<PlatformException>());
        }
        await tester.pumpLinux();
        await player.dispose();
      },
    );
  });

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

    testWidgets('#create and #dispose', (tester) async {
      await tester.pumpAndSettle();
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
      await tester.pumpLinux();
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
          expect(await platform.getCurrentPosition(playerId), 0);
          final durationMs = await platform.getDuration(playerId);
          expect(
            durationMs != null ? Duration(milliseconds: durationMs) : null,
            (Duration? actual) => durationRangeMatcher(
              actual,
              td.duration,
              deviation: const Duration(milliseconds: 1),
            ),
          );
          await tester.pumpLinux();
        },
        // FIXME(gustl22): cannot determine initial duration for VBR on Linux
        // FIXME(gustl22): determines wrong initial position for m3u8 on Linux
        skip: isLinux && td.isVBR ||
            isLinux && td.source == m3u8UrltestData.source,
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
          await tester.pumpLinux();
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
          await tester.pumpLinux();
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
          await tester.pumpLinux();
        });
      }
    }

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
          await seekCompleter.future.timeout(const Duration(seconds: 30));
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
          await tester.pumpLinux();
        });
      }
    }

    for (final td in audioTestDataList) {
      if (features.hasReleaseModeLoop &&
          !td.isLiveStream &&
          td.duration < const Duration(seconds: 2)) {
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
          await tester.pumpLinux();
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
          await tester.pump(const Duration(seconds: 3));
          // No need to call stop, as it should be released by now
          // TODO(Gustl22): test if source was released

          // May check number of loops here
          await tester.pumpLinux();

          // TODO(Gustl22): test 'platform.release()'
        });
      }
    }

    testWidgets('Set same source twice (#1520)', (tester) async {
      for (var i = 0; i < 2; i++) {
        await tester.prepareSource(
          playerId: playerId,
          platform: platform,
          testData: wavUrl1TestData,
        );
      }
      await tester.pumpLinux();
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
            final eventStream = platform.getEventStream(playerId);
            final durationCompleter = Completer<Duration?>();
            final onDurationSub = eventStream
                .where((event) => event.eventType == AudioEventType.duration)
                .listen(
                  (event) => durationCompleter.complete(event.duration),
                  onError: durationCompleter.completeError,
                );

            await tester.prepareSource(
              playerId: playerId,
              platform: platform,
              testData: td,
            );

            expect(
              await durationCompleter.future
                  .timeout(const Duration(seconds: 30)),
              (Duration? actual) => durationRangeMatcher(
                actual,
                td.duration,
                deviation: const Duration(milliseconds: 1),
              ),
            );
            await onDurationSub.cancel();
            await tester.pumpLinux();
          },
          // TODO(gustl22): cannot determine duration for VBR on Linux
          skip: isLinux && td.isVBR,
        );
      }
    }

    for (final td in audioTestDataList) {
      if (features.hasPositionEvent &&
          (td.isLiveStream || td.duration > const Duration(seconds: 2))) {
        testWidgets('#positionEvent ${td.source}', (tester) async {
          await tester.prepareSource(
            playerId: playerId,
            platform: platform,
            testData: td,
          );

          final eventStream = platform.getEventStream(playerId);
          Duration? position;
          final onPositionSub = eventStream
              .where((event) => event.eventType == AudioEventType.position)
              .listen(
                (event) => position = event.position,
              );

          await platform.resume(playerId);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          expect(position, greaterThan(Duration.zero));
          await platform.stop(playerId);
          await onPositionSub.cancel();
          await tester.pumpLinux();
        });
      }
    }

    testWidgets('Listen and cancel twice', (tester) async {
      final eventStream = platform.getEventStream(playerId);
      for (var i = 0; i < 2; i++) {
        final eventSub = eventStream.listen(null);
        await eventSub.cancel();
      }
      await tester.pumpLinux();
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
      await tester.pumpLinux();
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
  }) async {
    final eventStream = platform.getEventStream(playerId);
    final preparedCompleter = Completer<void>();
    final onPreparedSub = eventStream
        .where((event) => event.eventType == AudioEventType.prepared)
        .map((event) => event.isPrepared!)
        .listen(
      (isPrepared) {
        if (isPrepared) {
          preparedCompleter.complete();
        }
      },
      onError: preparedCompleter.completeError,
    );
    await pumpLinux();
    final source = testData.source;
    if (source is UrlSource) {
      await platform.setSourceUrl(playerId, source.url);
    } else if (source is AssetSource) {
      final url = await AudioCache.instance.load(source.path);
      await platform.setSourceUrl(playerId, url.path, isLocal: true);
    } else if (source is BytesSource) {
      await platform.setSourceBytes(playerId, source.bytes);
    }
    await preparedCompleter.future.timeout(const Duration(seconds: 30));
    await onPreparedSub.cancel();
  }
}
