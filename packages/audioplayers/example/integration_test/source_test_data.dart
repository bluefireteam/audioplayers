/// Data of a test source.
class SourceTestData {
  String sourceKey;

  Duration duration;

  bool isStream;

  SourceTestData({
    required this.sourceKey,
    required this.duration,
    this.isStream = false,
  });

  @override
  String toString() {
    return 'SourceTestData('
        'sourceKey: $sourceKey, '
        'duration: $duration, '
        'isStream: $isStream'
        ')';
  }
}
