import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';

import '../platform_features.dart';
import '../source_test_data.dart';

/// Data of a library test source.
class LibSourceTestData extends SourceTestData {
  Source source;

  LibSourceTestData({
    required this.source,
    required super.duration,
    super.isVBR,
  });

  @override
  String toString() {
    return 'LibSourceTestData('
        'source: $source, '
        'duration: $duration, '
        'isVBR: $isVBR, '
        'isLiveStream: $isLiveStream'
        ')';
  }
}

final _features = PlatformFeatures.instance();

final wavUrl1TestData = LibSourceTestData(
  source: UrlSource(wavUrl1),
  duration: const Duration(milliseconds: 451),
);

final mp3Url1TestData = LibSourceTestData(
  source: UrlSource(mp3Url1),
  duration: const Duration(minutes: 3, seconds: 30, milliseconds: 77),
  isVBR: true,
);

final m3u8UrlTestData = LibSourceTestData(
  source: UrlSource(m3u8StreamUrl),
  duration: null,
);

final mpgaUrlTestData = LibSourceTestData(
  source: UrlSource(mpgaStreamUrl),
  duration: null,
);

final wavAssetTestData = LibSourceTestData(
  source: AssetSource(wavAsset),
  duration: const Duration(seconds: 1, milliseconds: 068),
);

final invalidAssetTestData = LibSourceTestData(
  source: AssetSource(invalidAsset),
  duration: Duration.zero,
);

final nonExistentUrlTestData = LibSourceTestData(
  source: UrlSource('non_existent.txt'),
  duration: Duration.zero,
);

// Some sources are commented which are considered redundant
Future<List<LibSourceTestData>> getAudioTestDataList() async {
  return [
    if (_features.hasUrlSource) wavUrl1TestData,
    /*if (_features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(wavUrl2),
        duration: const Duration(seconds: 1, milliseconds: 068),
      ),*/
    if (_features.hasUrlSource) mp3Url1TestData,
    /*if (_features.hasUrlSource)
      LibSourceTestData(
        source: UrlSource(mp3Url2),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      ),*/
    if (_features.hasUrlSource && _features.hasPlaylistSourceType)
      m3u8UrlTestData,
    if (_features.hasUrlSource) mpgaUrlTestData,
    if (_features.hasAssetSource) wavAssetTestData,
    /*if (_features.hasAssetSource)
      LibSourceTestData(
        source: AssetSource(mp3Asset),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      ),*/
    if (_features.hasBytesSource)
      LibSourceTestData(
        source: BytesSource(await AudioCache.instance.loadAsBytes(wavAsset)),
        duration: const Duration(seconds: 1, milliseconds: 068),
      ),
    /*if (_features.hasBytesSource)
      LibSourceTestData(
        source: BytesSource(await readBytes(Uri.parse(mp3Url1))),
        duration: const Duration(minutes: 3, seconds: 30, milliseconds: 76),
      ),*/
  ];
}
