/// Data of a ui test source.
abstract class SourceTestData {
  Duration? duration;

  bool get isLiveStream => duration == null;

  /// Whether this source has variable bitrate
  bool isVBR;

  SourceTestData({
    required this.duration,
    this.isVBR = false,
  });

  @override
  String toString() {
    return 'SourceTestData('
        'duration: $duration, '
        'isVBR: $isVBR'
        ')';
  }
}
