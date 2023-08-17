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
  });

  @override
  String toString() {
    return 'RawSourceTestData('
        'source: $source, '
        'duration: $duration'
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
);

final audioTestDataList = [
  if (_features.hasUrlSource) wavUrl1TestData,
  if (_features.hasUrlSource)
    LibSourceTestData(
      source: UrlSource(wavUrl2),
      duration: const Duration(seconds: 1, milliseconds: 068),
    ),
  if (_features.hasUrlSource) mp3Url1TestData,
  if (_features.hasUrlSource)
    LibSourceTestData(
      source: UrlSource(mp3Url2),
      duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
    ),
  if (_features.hasUrlSource && _features.hasPlaylistSourceType)
    LibSourceTestData(
      source: UrlSource(m3u8StreamUrl),
      duration: null,
    ),
  if (_features.hasUrlSource)
    LibSourceTestData(
      source: UrlSource(mpgaStreamUrl),
      duration: null,
    ),
  if (_features.hasAssetSource)
    LibSourceTestData(
      source: AssetSource(wavAsset),
      duration: const Duration(seconds: 1, milliseconds: 068),
    ),
  if (_features.hasAssetSource)
    LibSourceTestData(
      source: AssetSource(mp3Asset),
      duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
    ),
];
