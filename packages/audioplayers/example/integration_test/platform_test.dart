import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'lib/lib_source_test_data.dart';
import 'lib/lib_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  group('Platform method channel', () async {
    late AudioplayersPlatformInterface platform;
    late String playerId;
    final audioTestDataList = await getAudioTestDataList();

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
      testWidgets('#setSource #getPosition and #getDuration', (tester) async {
        await tester.prepareSource(
          playerId: playerId,
          platform: platform,
          testData: td,
        );
        expect(await platform.getCurrentPosition(playerId), 0);
        expect(
          await platform.getDuration(playerId),
          td.duration.inMilliseconds,
        );
        await tester.pumpLinux();
      });

      testWidgets('#seek with millisecond precision', (tester) async {
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
          (_) {
            seekCompleter.complete();
          },
          onError: seekCompleter.completeError,
        );
        await platform.seek(playerId, const Duration(milliseconds: 21));
        await seekCompleter.future.timeout(const Duration(seconds: 30));
        await onSeekSub.cancel();
        expect(await platform.getCurrentPosition(playerId), 21);
        await tester.pumpLinux();
      });
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
    await platform.setSourceUrl(
      playerId,
      (testData.source as UrlSource).url,
    );
    await preparedCompleter.future.timeout(const Duration(seconds: 30));
    await onPreparedSub.cancel();
  }
}
