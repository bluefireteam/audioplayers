import 'package:audioplayers/audioplayers.dart';

/// Data of a ui test source.
abstract class SourceTestData {
  Duration duration;

  bool isLiveStream;

  SourceTestData({
    required this.duration,
    this.isLiveStream = false,
  });

  @override
  String toString() {
    return 'SourceTestData('
        'duration: $duration, '
        'isLiveStream: $isLiveStream'
        ')';
  }
}

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

/// Data of a library test source.
class LibSourceTestData extends SourceTestData {
  Source source;

  LibSourceTestData({
    required this.source,
    required super.duration,
    super.isLiveStream,
  });

  @override
  String toString() {
    return 'RawSourceTestData('
        'source: $source, '
        'duration: $duration, '
        'isLiveStream: $isLiveStream'
        ')';
  }
}
