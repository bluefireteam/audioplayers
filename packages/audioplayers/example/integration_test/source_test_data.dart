/// Data of a ui test source.
abstract class SourceTestData {
  Duration duration;

  bool isLiveStream;

  /// Whether this source has variable bitrate
  bool isVBR;

  SourceTestData({
    required this.duration,
    this.isLiveStream = false,
    this.isVBR = false,
  });

  @override
  String toString() {
    return 'SourceTestData('
        'duration: $duration, '
        'isLiveStream: $isLiveStream'
        ')';
  }
}
