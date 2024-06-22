import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/tabs/sources.dart';
import 'package:http/http.dart';

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
        'isVBR: $isVBR'
        ')';
  }
}

final _features = PlatformFeatures.instance();

final wavUrl1TestData = LibSourceTestData(
  source: UrlSource(wavUrl1),
  duration: const Duration(milliseconds: 451),
);

final specialCharUrlTestData = LibSourceTestData(
  source: UrlSource(wavUrl3),
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

final wavAsset1TestData = LibSourceTestData(
  source: AssetSource(wavAsset1),
  duration: const Duration(milliseconds: 451),
);

final wavAsset2TestData = LibSourceTestData(
  source: AssetSource(wavAsset2),
  duration: const Duration(seconds: 1, milliseconds: 068),
);

final invalidAssetTestData = LibSourceTestData(
  source: AssetSource(invalidAsset),
  duration: null,
);

final specialCharAssetTestData = LibSourceTestData(
  source: AssetSource(specialCharAsset),
  duration: const Duration(milliseconds: 451),
);

final noExtensionAssetTestData = LibSourceTestData(
  source: AssetSource(noExtensionAsset, mimeType: 'audio/wav'),
  duration: const Duration(milliseconds: 451),
);

final nonExistentUrlTestData = LibSourceTestData(
  source: UrlSource('non_existent.txt'),
  duration: null,
);

final wavDataUriTestData = LibSourceTestData(
  source: UrlSource(wavDataUri),
  duration: const Duration(milliseconds: 451),
);

final mp3DataUriTestData = LibSourceTestData(
  source: UrlSource(mp3DataUri),
  duration: const Duration(milliseconds: 444),
);

Future<LibSourceTestData> mp3BytesTestData() async => LibSourceTestData(
      source: BytesSource(
        await readBytes(Uri.parse(mp3Url1)),
        mimeType: 'audio/mpeg',
      ),
      duration: const Duration(minutes: 3, seconds: 30, milliseconds: 76),
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
    if (_features.hasDataUriSource) wavDataUriTestData,
    // if (_features.hasDataUriSource) mp3DataUriTestData,
    if (_features.hasAssetSource) wavAsset2TestData,
    /*if (_features.hasAssetSource)
      LibSourceTestData(
        source: AssetSource(mp3Asset),
        duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
      ),*/
    if (_features.hasBytesSource) await mp3BytesTestData(),
    /*if (_features.hasBytesSource)
      // Cache not working for web
      LibSourceTestData(
        source: BytesSource(
          await AudioCache.instance.loadAsBytes(wavAsset2),
          mimeType: 'audio/wav',
        ),
        duration: const Duration(seconds: 1, milliseconds: 068),
      ),*/
  ];
}
