import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:flutter_test/flutter_test.dart';

import 'platform_features.dart';
import 'source_test_data.dart';

void main() {
  final features = PlatformFeatures.instance();

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

    testWidgets('play multiple sources simultaneously',
        (WidgetTester tester) async {
      final players =
          List.generate(audioTestDataList.length, (_) => AudioPlayer());

      // Start all players simultaneously
      final iterator = List<int>.generate(audioTestDataList.length, (i) => i);
      await Future.wait<void>(
        iterator.map((i) => players[i].play(audioTestDataList[i].source)),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 8));
      for (var i = 0; i < audioTestDataList.length; i++) {
        final td = audioTestDataList[i];
        if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
          await tester.pump();
          final position = await players[i].getCurrentPosition();
          printOnFailure('Test position: $td');
          expect(position, greaterThan(Duration.zero));
        }
        await players[i].stop();
      }
    });

    testWidgets('play multiple sources consecutively',
        (WidgetTester tester) async {
      final player = AudioPlayer();

      for (var i = 0; i < audioTestDataList.length; i++) {
        final td = audioTestDataList[i];
        await player.play(td.source);
        await tester.pumpAndSettle();
        // Live stream takes some time to get initialized
        await tester.pump(Duration(seconds: td.isLiveStream ? 8 : 2));
        if (td.isLiveStream || td.duration > const Duration(seconds: 10)) {
          await tester.pump();
          final position = await player.getCurrentPosition();
          printOnFailure('Test position: $td');
          expect(position, greaterThan(Duration.zero));
        }
        await player.stop();
      }
    });
  });
}
