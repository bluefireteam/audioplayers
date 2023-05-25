import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'platform_features.dart';
import 'source_test_data.dart';
import 'test_utils.dart';

void main() {
  final features = PlatformFeatures.instance();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final isAndroid = !kIsWeb && Platform.isAndroid;
  final isLinux = !kIsWeb && Platform.isLinux;

  final wavUrl1TestData = LibSourceTestData(
    source: UrlSource(wavUrl1),
    duration: const Duration(milliseconds: 451),
  );
  final audioTestDataList = [
    if (features.hasUrlSource) wavUrl1TestData,
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(wavUrl2),
        duration: const Duration(seconds: 1, milliseconds: 068),
      ),
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(mp3Url1),
        duration: const Duration(minutes: 3, seconds: 30, milliseconds: 77),
      ),
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(mp3Url2),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      ),
    if (features.hasUrlSource && features.hasPlaylistSourceType)
      LibSourceTestData(
        source: UrlSource(m3u8StreamUrl),
        duration: Duration.zero,
        isLiveStream: true,
      ),
    if (features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(mpgaStreamUrl),
        duration: Duration.zero,
        isLiveStream: true,
      ),
    if (features.hasAssetSource)
      LibSourceTestData(
        source: AssetSource(wavAsset),
        duration: const Duration(seconds: 1, milliseconds: 068),
      ),
    if (features.hasAssetSource)
      LibSourceTestData(
        source: AssetSource(mp3Asset),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      ),
  ];

  group('play multiple sources', () {
    testWidgets(
      'play multiple sources simultaneously',
      (WidgetTester tester) async {
        final players =
            List.generate(audioTestDataList.length, (_) => AudioPlayer());

        // Start all players simultaneously
        final iterator = List<int>.generate(audioTestDataList.length, (i) => i);
        if (isLinux) {
          // FIXME(gustl22): Linux needs additional pump (#1507)
          await tester.pump();
        }
        await Future.wait<void>(
          iterator.map((i) => players[i].play(audioTestDataList[i].source)),
        );
        await tester.pumpAndSettle();
        // Sources take some time to get initialized
        await tester.pump(const Duration(seconds: 8));
        for (var i = 0; i < audioTestDataList.length; i++) {
          final td = audioTestDataList[i];
          if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
            await tester.pump();
            final position = await players[i].getCurrentPosition();
            printWithTimeOnFailure('Test position: $td');
            expect(position, greaterThan(Duration.zero));
          }
          await players[i].stop();
        }
        if (!isLinux) {
          // FIXME(gustl22): Linux not disposing properly (#1507)
          await Future.wait(players.map((p) => p.dispose()));
        }
      },
      // FIXME: Causes media error on Android (see #1333, #1353)
      // Unexpected platform error: MediaPlayer error with
      // what:MEDIA_ERROR_UNKNOWN {what:1} extra:MEDIA_ERROR_SYSTEM
      skip: isAndroid,
    );

    testWidgets('play multiple sources consecutively',
        (WidgetTester tester) async {
      final player = AudioPlayer();

      for (var i = 0; i < audioTestDataList.length; i++) {
        final td = audioTestDataList[i];
        if (isLinux) {
          // FIXME(gustl22): Linux needs additional pump (#1507)
          await tester.pump();
        }
        await player.play(td.source);
        await tester.pumpAndSettle();
        // Sources take some time to get initialized
        await tester.pump(const Duration(seconds: 8));
        if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
          await tester.pump();
          final position = await player.getCurrentPosition();
          printWithTimeOnFailure('Test position: $td');
          expect(position, greaterThan(Duration.zero));
        }
        await player.stop();
      }
      if (!isLinux) {
        // FIXME(gustl22): Linux not disposing properly (#1507)
        await player.dispose();
      }
    });
  });

  group('Audio Context', () {
    /// Android and iOS only: Play the same sound twice with a different audio
    /// context each. This test can be executed on a device, with either
    /// "Silent", "Vibrate" or "Ring" mode. In "Silent" or "Vibrate" mode
    /// the second sound should not be audible.
    testWidgets(
      'test changing AudioContextConfigs',
      (WidgetTester tester) async {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);

        final td = wavUrl1TestData;

        var audioContext = AudioContextConfig(
          //ignore: avoid_redundant_argument_values
          forceSpeaker: true,
          //ignore: avoid_redundant_argument_values
          respectSilence: false,
        ).build();
        await AudioPlayer.global.setAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        if (isLinux) {
          // FIXME(gustl22): Linux needs additional pump (#1507)
          await tester.pump();
        }
        await player.play(td.source);
        await tester.pumpAndSettle();
        await tester.pump(td.duration + const Duration(seconds: 8));
        expect(player.state, PlayerState.completed);

        audioContext = AudioContextConfig(
          forceSpeaker: false,
          respectSilence: true,
        ).build();
        await AudioPlayer.global.setAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await player.resume();
        await tester.pumpAndSettle();
        await tester.pump(td.duration + const Duration(seconds: 8));
        expect(player.state, PlayerState.completed);
        if (!isLinux) {
          // FIXME(gustl22): Linux not disposing properly (#1507)
          await player.dispose();
        }
      },
      skip: !features.hasForceSpeaker,
    );

    /// Android and iOS only: Play the same sound twice with a different audio
    /// context each. This test can be executed on a device, with either
    /// "Silent", "Vibrate" or "Ring" mode. In "Silent" or "Vibrate" mode
    /// the second sound should not be audible.
    testWidgets(
      'test changing AudioContextConfigs in LOW_LATENCY mode',
      (WidgetTester tester) async {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        player.setPlayerMode(PlayerMode.lowLatency);

        final td = wavUrl1TestData;

        var audioContext = AudioContextConfig(
          //ignore: avoid_redundant_argument_values
          forceSpeaker: true,
          //ignore: avoid_redundant_argument_values
          respectSilence: false,
        ).build();
        await AudioPlayer.global.setAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        if (isLinux) {
          // FIXME(gustl22): Linux needs additional pump (#1507)
          await tester.pump();
        }
        await player.setSource(td.source);
        await player.resume();
        await tester.pumpAndSettle();
        await tester.pump(td.duration + const Duration(seconds: 8));
        expect(player.state, PlayerState.playing);
        await player.stop();
        expect(player.state, PlayerState.stopped);

        audioContext = AudioContextConfig(
          forceSpeaker: false,
          respectSilence: true,
        ).build();
        await AudioPlayer.global.setAudioContext(audioContext);
        await player.setAudioContext(audioContext);

        await player.resume();
        await tester.pumpAndSettle();
        await tester.pump(td.duration + const Duration(seconds: 8));
        expect(player.state, PlayerState.playing);
        await player.stop();
        expect(player.state, PlayerState.stopped);
        if (!isLinux) {
          // FIXME(gustl22): Linux not disposing properly (#1507)
          await player.dispose();
        }
      },
      skip: !features.hasForceSpeaker || !features.hasLowLatency,
    );
  });

  group('Logging', () {
    testWidgets('Emit platform log', (tester) async {
      final logCompleter = Completer<String>();

      // FIXME(gustl22): Cannot reuse event channel with same id on Linux (flutter/flutter#126209)
      final playerId = isLinux ? 'somePlayerId0' : 'somePlayerId';
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
          // Throws PlatformException via MethodChannel:
          if (isLinux) {
            // FIXME(gustl22): Linux needs additional pump (#1507)
            await tester.pump();
          }
          await player.setSource(AssetSource(invalidAsset));
          fail('PlatformException not thrown');
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          expect(e, isInstanceOf<PlatformException>());
        }
        if (!isLinux) {
          // FIXME(gustl22): Linux not disposing properly (#1507)
          await player.dispose();
        }
      },
    );

    testWidgets(
      'Throw PlatformException, when loading non existent file',
      (tester) async {
        final player = AudioPlayer();
        try {
          // Throws PlatformException via MethodChannel:
          if (isLinux) {
            // FIXME(gustl22): Linux needs additional pump (#1507)
            await tester.pump();
          }
          await player.setSource(UrlSource('non_existent.txt'));
          fail('PlatformException not thrown');
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          expect(e, isInstanceOf<PlatformException>());
        }
        if (!isLinux) {
          // FIXME(gustl22): Linux not disposing properly (#1507)
          await player.dispose();
        }
      },
    );
  });

  group('Platform method channel', () {
    testWidgets('#create and #dispose', (tester) async {
      final platform = AudioplayersPlatformInterface.instance;

      // FIXME(gustl22): Cannot reuse event channel with same id on Linux (flutter/flutter#126209)
      final playerId = isLinux ? 'somePlayerId1' : 'somePlayerId';
      await platform.create(playerId);
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
    });

    testWidgets('#setSource #getPosition and #getDuration', (tester) async {
      final platform = AudioplayersPlatformInterface.instance;

      // FIXME(gustl22): Cannot reuse event channel with same id on Linux (flutter/flutter#126209)
      final playerId = isLinux ? 'somePlayerId2' : 'somePlayerId';
      await platform.create(playerId);

      final preparedCompleter = Completer<void>();
      final eventStream = platform.getEventStream(playerId);
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
      if (isLinux) {
        // FIXME(gustl22): Linux needs additional pump (#1507)
        await tester.pump();
      }
      await platform.setSourceUrl(
        playerId,
        (wavUrl1TestData.source as UrlSource).url,
      );
      await preparedCompleter.future.timeout(const Duration(seconds: 30));

      expect(await platform.getCurrentPosition(playerId), 0);
      expect(
        await platform.getDuration(playerId),
        wavUrl1TestData.duration.inMilliseconds,
      );

      await onPreparedSub.cancel();
      if (!isLinux) {
        // FIXME(gustl22): Linux not disposing properly (#1507)
        await platform.dispose(playerId);
      }
    });
  });

  testWidgets('Set same source twice (#1520)', (tester) async {
    final platform = AudioplayersPlatformInterface.instance;

    // FIXME(gustl22): Cannot reuse event channel with same id on Linux (flutter/flutter#126209)
    final playerId = isLinux ? 'somePlayerId3' : 'somePlayerId';
    await platform.create(playerId);

    final eventStream = platform.getEventStream(playerId);
    for (var i = 0; i < 2; i++) {
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
      if (isLinux) {
        // FIXME(gustl22): Linux needs additional pump (#1507)
        await tester.pump();
      }
      await platform.setSourceUrl(
        playerId,
        (wavUrl1TestData.source as UrlSource).url,
      );
      await preparedCompleter.future.timeout(const Duration(seconds: 30));
      await onPreparedSub.cancel();
    }
    if (!isLinux) {
      // FIXME(gustl22): Linux not disposing properly (#1507)
      await platform.dispose(playerId);
    }
  });

  group('Platform event channel', () {
    // TODO(gustl22): remove once https://github.com/flutter/flutter/issues/126209 is fixed
    testWidgets(
      'Reuse same platform event channel id',
      (tester) async {
        final platform = AudioplayersPlatformInterface.instance;

        const playerId = 'somePlayerId';
        await platform.create(playerId);

        final eventStreamSub = platform.getEventStream(playerId).listen((_) {});

        await eventStreamSub.cancel();
        await platform.dispose(playerId);

        // Recreate player with same player Id
        await platform.create(playerId);

        final eventStreamSub2 =
            platform.getEventStream(playerId).listen((_) {});

        await eventStreamSub2.cancel();
        await platform.dispose(playerId);
      },
      skip: isLinux,
    );

    testWidgets('Emit platform error', (tester) async {
      final errorCompleter = Completer<Object>();
      final platform = AudioplayersPlatformInterface.instance;

      // FIXME(gustl22): Cannot reuse event channel with same id on Linux (flutter/flutter#126209)
      final playerId = isLinux ? 'somePlayerId4' : 'somePlayerId';
      await platform.create(playerId);

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
      await platform.dispose(playerId);
    });

    testWidgets('Emit global platform error', (tester) async {
      final errorCompleter = Completer<Object>();
      final global = GlobalAudioplayersPlatformInterface.instance;

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
