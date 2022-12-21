import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'platform_features.dart';
import 'source_test_data.dart';

void main() {
  final features = PlatformFeatures.instance();

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('play multiple sources', () {
    final audioTestDataList = [
      if (features.hasUrlSource)
        LibSourceTestData(
          source: UrlSource(wavUrl1),
          duration: const Duration(milliseconds: 451),
        ),
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
          source: AssetSource(asset1),
          duration: const Duration(seconds: 1, milliseconds: 068),
        ),
      if (features.hasAssetSource)
        LibSourceTestData(
          source: AssetSource(asset2),
          duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
        ),
    ];

    testWidgets('test mp3 on Android', (WidgetTester tester) async {
      // FIXME: Unexpected platform error: MediaPlayer error with what:MEDIA_ERROR_UNKNOWN {what:1} extra:MEDIA_ERROR_SYSTEM
      // Source: UrlSource(url: http://10.0.2.2:8080/files/audio/ambient_c_motion.mp3)
      final mp3_1 = LibSourceTestData(
        source: UrlSource(mp3Url1),
        duration: const Duration(minutes: 3, seconds: 30, milliseconds: 77),
      );
      final mp3_2 = LibSourceTestData(
        source: UrlSource(mp3Url2),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      );
      final m3u8_1 = LibSourceTestData(
        source: UrlSource(m3u8StreamUrl),
        duration: Duration.zero,
        isLiveStream: true,
      );
      final asset_1 = LibSourceTestData(
        source: AssetSource(asset1),
        duration: const Duration(seconds: 1, milliseconds: 068),
      );
      final asset_2 = LibSourceTestData(
        source: AssetSource(asset2),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      );
      final playerA = AudioPlayer();
      final playerB = AudioPlayer();
      final playerC = AudioPlayer();
      final playerD = AudioPlayer();
      final playerE = AudioPlayer();
      print('players initialized');
      await Future.wait<void>([
        playerA.play(mp3_1.source),
        playerB.play(mp3_2.source),
        playerC.play(m3u8_1.source),
        playerD.play(asset_1.source),
        playerE.play(asset_2.source),
      ]);
      print('all players started playing');

      await tester.pumpAndSettle();
      print('pump and settle');
      await tester.pump(const Duration(seconds: 8));
      print('pump 8s');

      await playerA.stop();
      await playerB.stop();
      await playerC.stop();
      await playerD.stop();
      await playerE.stop();
      print('test finished');
    });

    // for (int k = 6; k < audioTestDataList.length; k++) {
    //   testWidgets(
    //     'play multiple sources simultaneously $k',
    //     (WidgetTester tester) async {
    //       print('\n\n\n ######################## simultan $k\n');
    //       final players = List.generate(k, (_) => AudioPlayer());
    //
    //       // Start all players simultaneously
    //       final iterator = List<int>.generate(k, (i) => i);
    //       await Future.wait<void>(
    //         iterator.map((i) async {
    //           print('initialize $i: ${audioTestDataList[i].source}');
    //           final a = await players[i].play(audioTestDataList[i].source);
    //           print('start playing $i: ${audioTestDataList[i].source}');
    //           return a;
    //         }),
    //       );
    //       await tester.pumpAndSettle();
    //       print('pump and settle');
    //       // Sources take some time to get initialized
    //       await tester.pump(const Duration(seconds: 8));
    //       print('pump 8s');
    //       for (var i = 0; i < k; i++) {
    //         final td = audioTestDataList[i];
    //         if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
    //           await tester.pump();
    //           final position = await players[i].getCurrentPosition();
    //           printOnFailure('Test position: $td');
    //           expect(position, greaterThan(Duration.zero));
    //         }
    //         print('stop player $i');
    //         await players[i].stop();
    //       }
    //     },
    //     timeout: const Timeout(Duration(minutes: 5)),
    //   );
    // }

    // final l = audioTestDataList.length;
    // for (int k = 2; k < l; k++) {
    //   testWidgets(
    //     'play multiple sources reverted $k',
    //     (WidgetTester tester) async {
    //       print('\n\n\n ######################## reverted $k\n');
    //       final players = List.generate(k, (_) => AudioPlayer());
    //
    //       // Start all players simultaneously
    //       final iterator = List<int>.generate(k, (i) => i);
    //       await Future.wait<void>(
    //         iterator.map((i) async {
    //           print('initialize $i: ${audioTestDataList[l - i - 1].source}');
    //           final a =
    //               await players[i].play(audioTestDataList[l - i - 1].source);
    //           print('start playing $i: ${audioTestDataList[l - i - 1].source}');
    //           return a;
    //         }),
    //       );
    //       await tester.pumpAndSettle();
    //       print('pump and settle');
    //       // Sources take some time to get initialized
    //       await tester.pump(const Duration(seconds: 8));
    //       print('pump 8s');
    //       for (var i = 0; i < k; i++) {
    //         final td = audioTestDataList[l - i - 1];
    //         if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
    //           await tester.pump();
    //           final position = await players[i].getCurrentPosition();
    //           printOnFailure('Test position: $td');
    //           expect(position, greaterThan(Duration.zero));
    //         }
    //         print('stop player $i');
    //         await players[i].stop();
    //       }
    //     },
    //     timeout: const Timeout(Duration(minutes: 5)),
    //   );
    // }
    //
    // testWidgets('play multiple sources consecutively',
    //     (WidgetTester tester) async {
    //   final player = AudioPlayer();
    //
    //   for (var i = 0; i < audioTestDataList.length; i++) {
    //     final td = audioTestDataList[i];
    //     await player.play(td.source);
    //     await tester.pumpAndSettle();
    //     // Sources take some time to get initialized
    //     await tester.pump(const Duration(seconds: 8));
    //     if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
    //       await tester.pump();
    //       final position = await player.getCurrentPosition();
    //       printOnFailure('Test position: $td');
    //       expect(position, greaterThan(Duration.zero));
    //     }
    //     await player.stop();
    //   }
    // });
  });
}
