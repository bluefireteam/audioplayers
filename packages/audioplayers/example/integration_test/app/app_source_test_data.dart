import '../platform_features.dart';
import '../source_test_data.dart';

/// Data of a ui test source.
class AppSourceTestData extends SourceTestData {
  String sourceKey;

  AppSourceTestData({
    required this.sourceKey,
    required super.duration,
    super.isLiveStream,
  });

  @override
  String toString() {
    return 'UiSourceTestData('
        'sourceKey: $sourceKey, '
        'duration: $duration, '
        'isLiveStream: $isLiveStream'
        ')';
  }
}

final _features = PlatformFeatures.instance();

final audioTestDataList = [
  if (_features.hasUrlSource)
    AppSourceTestData(
      sourceKey: 'url-remote-wav-1',
      duration: const Duration(milliseconds: 451),
    ),
  if (_features.hasUrlSource)
    AppSourceTestData(
      sourceKey: 'url-remote-wav-2',
      duration: const Duration(seconds: 1, milliseconds: 068),
    ),
  if (_features.hasUrlSource)
    AppSourceTestData(
      sourceKey: 'url-remote-mp3-1',
      duration: const Duration(minutes: 3, seconds: 30, milliseconds: 77),
    ),
  if (_features.hasUrlSource)
    AppSourceTestData(
      sourceKey: 'url-remote-mp3-2',
      duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
    ),
  if (_features.hasUrlSource && _features.hasPlaylistSourceType)
    AppSourceTestData(
      sourceKey: 'url-remote-m3u8',
      duration: Duration.zero,
      isLiveStream: true,
    ),
  if (_features.hasUrlSource)
    AppSourceTestData(
      sourceKey: 'url-remote-mpga',
      duration: Duration.zero,
      isLiveStream: true,
    ),
  if (_features.hasAssetSource)
    AppSourceTestData(
      sourceKey: 'asset-wav',
      duration: const Duration(seconds: 1, milliseconds: 068),
    ),
  if (_features.hasAssetSource)
    AppSourceTestData(
      sourceKey: 'asset-mp3',
      duration: const Duration(minutes: 1, seconds: 34, milliseconds: 119),
    ),
  if (_features.hasBytesSource)
    AppSourceTestData(
      sourceKey: 'bytes-local',
      duration: const Duration(seconds: 1, milliseconds: 068),
    ),
  if (_features.hasBytesSource)
    AppSourceTestData(
      sourceKey: 'bytes-remote',
      duration: const Duration(minutes: 3, seconds: 30, milliseconds: 76),
    ),
];
